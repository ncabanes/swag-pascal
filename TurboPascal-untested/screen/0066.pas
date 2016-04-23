{
Here is my unit for a screen saver - totally self contained with mouse support
as well (Moving the mouse will reset the screensaver time delay as well, and
placing the mouse in top right corner will blank the screen!)
}
unit blanker;

interface

const
blank_screen     : boolean=true;            {True=blank the screen.         }
blank_screen_now : boolean=false;           {True=blank screen immediately. }
count            : integer = 0;             {To keep track of our calls.    }
screen_cond      : boolean=false;           {True=screen is blanked.        }

var
 rows,columns:byte;

function mouseinbox(x1,y1,x2,y2,butt:word):boolean;

implementation

uses dos,bmouse;   { NOTE : bmouse is in MOUSE.SWG.  SWAG SUPPORT TEAM }

var
 OldInt9       : Procedure;
 OldInt1c      : pointer;
 ExitSave      : pointer;
 r             : Registers;
 loop          : byte;
 x             : array[1..30] of byte;
 y             : array[1..30] of byte;
 xystar        : array[1..30] of char;

{$F+}

{****************************************************************************}
{*                                                                          *}
{*                            MouseinBox Procedure                          *}
{*                                                                          *}
{****************************************************************************}
function mouseinbox(x1,y1,x2,y2,butt:word):boolean;
var
 a1, b1, c : word ;
begin
 ms_read(a1,b1,c);
 a1:=(a1 div 8) + 1;
 b1:=(b1 div 8) + 1;
 if ((a1>=x1) and (a1<=x2) and (b1>=y1) and (b1<=y2) and (c=butt)) then
    mouseinbox:=true
 else
    mouseinbox:=false;
end;



{****************************************************************************}
{*                                                                          *}
{*                       Draw the stars on video page 1                     *}
{*                                                                          *}
{****************************************************************************}
Procedure stars;
begin
 for loop:=1 to 30 do
 begin
    if ((random(80)<10) and (ord(xystar[loop])=15)) then
    begin
       xystar[loop]:=' ';
    end;
    if ((random(80)<5) and (xystar[loop]='∙')) then
    begin
       xystar[loop]:=chr(15);
    end;
    if ((random(80)<5) and (xystar[loop]='·')) then
    begin
       xystar[loop]:='∙';
    end;
    if ((random(80)<20) and (xystar[loop]=' ') and (x[loop]=0) and
(y[loop]=0)) then
    begin
       x[loop]:=random(rows);
       y[loop]:=random(columns);
       xystar[loop]:='·';
    end;
 end;
 for loop:=1 to 30 do
 begin
    r.ah:=$02;
    r.bh:=$01;
    r.dh:=x[loop];
    r.dl:=y[loop];
    intr($10,r);

    r.al:=ord(xystar[loop]);
    r.ah:=$09;
    r.bl:=7;
    r.bh:=$01;
    r.cx:=01;
    intr($10,r);
    if xystar[loop]=' ' then
    begin
       x[loop]:=0;
       y[loop]:=0;
    end;
 end;
end;

{****************************************************************************}
{*                                                                          *}
{*                       Initialize the stars Procedure                     *}
{*                                                                          *}
{****************************************************************************}
Procedure starsinit;
begin
 for loop:=1 to 20 do xystar[loop]:=' ';
 stars;
end;

{****************************************************************************}
{*                                                                          *}
{*                        Check timer & blank the screen                    *}
{*                                                                          *}
{****************************************************************************}
procedure blank; interrupt;
                                            {This will be called every clock}
                                            {tick by hardware interrupt $08.}
begin
 if screen_cond then stars;
 asm cli end;
 if blank_screen then inc(count);
 if ((blank_screen_now) and (blank_screen)) then count:=180;
 if (count >= 180) then                    {Ticks till Screen is blanked.  }
                                            {Time is 18.2 TICKS/SEC, or 1092}
                                            {Per minute, so                 }
                                            {2 Mins = 2184,                 }
                                            {3 Mins = 3276,                 }
                                            {4 Mins = 4368,                 }
                                            {5 Mins = 5460,                 }
                                            {6 Mins = 6552,                 }
                                            {7 Mins = 7644,                 }
                                            {8 Mins = 8736,                 }
                                            {9 Mins = 9828,                 }
                                            {10 Mins = 10920,               }
                                            {20 Mins = 21840,               }
                                            {30 Mins = 32760, which is      }
                                            {maximum limit of Integer       }
                                            {variable used.                 }
 begin
    count       := 0;                       {Equality check and assignment  }
                                            {faster than mod.               }
    asm
    mov AX,$02                              {Turn mouse off.                }
    Int $33

    mov ah,$03                              {Turn the cursor off            }
    mov bh,$00
    int $10
    or ch,$20
    mov ah,$01
    int $10

    mov ah,$05                              {Swaps to video page 1          }
    mov al,$01
    int $10
    end;
    if not screen_cond then starsinit;
    screen_cond:=true;
 end
 else
 begin
    asm
    mov ax,$0006                            {Check for Mouse Button press.  }
    int $33
    cmp bx,0
    je @Test2
    mov count,0
 @test2:
    mov ax,$000b                            {Check for mouse movement.      }
    int $33
    cmp cx,0
    jz @test3
    mov count,0
 @test3:
    cmp dx,0
    jz @test4
    mov count,0
 @test4:
    end;
    if ((count=0) and (screen_cond)) then
    begin
       asm
       mov ah,$05                           {Restore the first video page   }
       mov al,$00;
       int $10

       mov ah,$03                           {Turn the cursor on             }
       mov bh,$00
       int $10
       and ch,$DF
       mov ah,$01
       int $10

       mov AX,$01                           {Turn mouse on                  }
       Int $33
       end;
       screen_cond:=false;
    end;
 end;
 asm
 sti
 pushf                                      {Push flags to set up for IRET. }
 call OldInt1c;                             {Call old ISR entry point.      }
 end;
end;

{****************************************************************************}
{*                                                                          *}
{*                         New Interrupt 9 Procedure                        *}
{*                                                                          *}
{****************************************************************************}
Procedure NewInt9; Interrupt;
Begin
 blank_screen_now:=false;
 if (mouseinbox(80,1,80,1,0))=true then
 asm
 mov ax,0004
 mov cx,630
 mov dx,1
 int $33
 end;
 count:=-1;                                 {Set to -1 because the blank    }
                                            {procedure will increment before}
                                            {it tests, so to get it to 0, it}
                                            {must be set to -1.             }
 asm
 pushf                                      {Push flags to set up for IRET. }
 call OldInt9;                              {Call old ISR entry point.      }
 end;
End;


{****************************************************************************}
{*                                                                          *}
{*                  Reset everything at the end of the unit                 *}
{*                                                                          *}
{****************************************************************************}
procedure ClockExitProc;
                                            {This procedure is VERY         }
                                            {important as you have hooked an}
                                            {interrupt and therefore if this}
                                            {is omitted when the unit is    }
                                            {terminated your system will    }
                                            {crash in an unpredictable and  }
                                            {possibly damaging way.         }
begin
 ExitProc := ExitSave;
 SetIntVec($1c,OldInt1c);                   {This "unhooks" the timer vector}
 SetIntVec($09, Addr(OldInt9));             {This restores normal keyboard  }
                                            {routines.                      }

end;
{$F-}


{****************************************************************************}
{*                                                                          *}
{*                        Unit Initializing procedure                       *}
{*                                                                          *}
{****************************************************************************}
procedure Initialise;
var
 mode : byte absolute $40:$49;
begin
 asm
 mov ah,$05                                 {Swap to video page 1, clear the}
 mov al,$01                                 {screen by scrolling it, then   }
 int $10                                    {return to video page 0.        }

 mov ah,$06
 mov al,$00
 mov bx,$00
 int $10

 mov ah,$05                                 {Restore the first video page   }
 mov al,$00
 int $10
 end;
 GetIntVec($09, Addr(OldInt9));             {These two lines activate the   }
 SetIntVec($09, Addr(NewInt9));             {new keyboard routine handler.  }
 GetIntVec($1c,OldInt1c);                   {Get old timer vector & save it.}
 ExitSave := ExitProc;                      {Save old exit procedure.       }
 ExitProc := @ClockExitProc;                {Setup a new exit procedure.    }
 SetIntVec($1c,@blank);                     {Hook the timer vector to the   }
                                            {new procedure.                 }
end;


{****************************************************************************}
{*                                                                          *}
{*                           Main program starts here                       *}
{*                                                                          *}
{****************************************************************************}
begin
 Initialise;
 Rows:=(mem[$0040:$0084]) + 1;              {Find the size from memory      }
 Columns:=mem[$0040:$004a];
 if rows   =0 then rows   :=25;             {If it could not find anything  }
 if columns=0 then columns:=80;             {assume 25*80 mode.             }
end.

