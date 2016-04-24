(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0021.PAS
  Description: Automatic Menu Unit
  Author: ANDAL PROGRAMMING
  Date: 01-02-98  07:35
*)

{ features include }
{ automatic string resizing }
{ hack proof, just leave the menucnst.pas available for general use}
{ easy to change colors }
{ automatic centring }
{ easy to use hot keys }
{ function to return value }
{ first declared is = 0, second is = 1, etc, etc }

{ if you use this program we take no responsiblity for anything that may
  happen to your computer }

{ THE ANDAL PROGRAMMING CORPORATION }

{ any bugs or ideas or help with dos or menus etc, please contact
  us at FERRET_@HOTMAIL.COM}


uses
crt,menubox;

var
   a:byte;
   x:menu;
begin
     x.setup;
     x.additem(' m~e~nu item 1'); {example of a hotkey }
     x.additem(' menu item 2');   {without a hotkey }
     x.additem(' ~m~enu item 3'); {with one again}
     x.additem(' menu item 4');
     a := x.run(' this is a little demo ',true);
     x.shutdown;
end.

{ ----------------   UNITS NEEDED HERE ------------ }

UNIT MenuBox;

{──────────────────────────────────────────────────────────────────────────}

INTERFACE
USES CRT,Shorten,MenuCnst;

{──────────────────────────────────────────────────────────────────────────}

                        { -- CONSTANT VALUES -- }

CONST
     Up     = TRUE;                             {Up arrow goes up -);        }
     Down   = FALSE;                            {Down arrow does the opposite}

{──────────────────────────────────────────────────────────────────────────}

                         { -- THE MENU OBJECT -- }

TYPE

  Menu = OBJECT                                 {The Whole Kit + Kabodal     }
  Items   : ARRAY [0..24] OF ^STRING;           {Pointers to 25 strings      }
  NoItems : BYTE;                               {How many items do I have??  }
  CurItem : BYTE;                               {Which Item am I up to??     }
  PROCEDURE Setup;                              {Call this every time you run}
  PROCEDURE AddItem(Str : STRING);              {Call to add an item new line}
  PROCEDURE ShutDown;                           {Dynamic shutdown            }
  FUNCTION Run(TitleStr  : STRING;              {Run!!! - returns value = to }
               DrawTitle : BOOLEAN) : BYTE;     {the item number 0 = the 1st }
  END;

{──────────────────────────────────────────────────────────────────────────}

                       { -- PUBLIC PROCEDURES -- }
PROCEDURE MenuExit;

                        { -- PUBLIC VARIABLES -- }
VAR
   M : Menu;

{──────────────────────────────────────────────────────────────────────────}

IMPLEMENTATION

                         { -- PRIVATE CALLS -- }

{PROCEDURE MWriteXY(Index : BYTE);}
{PROCEDURE Main(Dir : BOOLEAN);}
{PROCEDURE ElseAnalyse;}

                       { -- PRIVATE VARIABLES -- }

VAR
   ExitPtr : POINTER;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE Menu.Setup;                           {Do the standard object VAR  }
BEGIN                                           {setup sequence, set to 0    }
     NoItems := 0;
     CurItem := 0;
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE Menu.AddItem(Str : STRING);           {Get's a bit tricky here...  }
BEGIN
     GETMEM(Items[NoItems],SIZEOF(STRING));     {allocate memory for a string}
     Items[NoItems]^ := Str;                    {give it the value of param  }
     INC(NoItems);                              {you now have another item!  }
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE Menu.ShutDown;                        {  >>> MUST BE CALLED <<<    }
VAR
   DelNo : BYTE;                                {Counter variable            }
BEGIN
     IF NoItems >= 1 THEN
       FOR DelNo := 0 TO NoItems-1 DO           {Start at start + do all items}
         FreeMem(Items[DelNo],SIZEOF(STRING));  {deallocate all mem          }
     NoItems := 0;                              {reset stand. vars for next  }
     CurItem := 0;                              {time                        }
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE ResizeString(VAR   Str  : STRING;     { >>>>     PRIVATE     <<<<  }
                       CONST Maxl : BYTE);      {Cannot be called out of unit}
VAR                                             {Procedure to do Auto resize }
   StrL : BYTE;                                 {on any strings              }
   D1   : BYTE;                                 {   It will append ' ' to end}
   C    : BYTE;                                 { + start of the string till }
BEGIN                                           {it reaches the right length }
     StrL := LENGTH(Str);                       { Save String length         }
     IF POS('~',Str) <> 0 THEN                  { Adjust for '~' chars       }
       DEC(StrL,2);
     StrL := MaxL - StrL;                       {find how many chars out it  }
     D1   := StrL SHR 1;                        {is. Half that number        }
     StrL := StrL - D1;                         {put half in D1, other in    }
     FOR C := 1 TO D1 DO                        {StrL. Then append ' '''s    }
       Str := ' ' + Str;
     FOR C := 1 TO StrL DO
       Str := Str + ' ';
END;

{──────────────────────────────────────────────────────────────────────────}

FUNCTION Menu.Run(TitleStr  : STRING;           { THIS IS IT BOYS + GIRLS    }
                  DrawTitle : BOOLEAN) : BYTE;  {Title + whether to write it }
VAR
   X1    : BYTE;                                {frame co - ordinates        }
   Y1    : BYTE;
   X2    : BYTE;
   Y2    : BYTE;
   Ch    : CHAR;                                {letter to be read in        }
   Stop  : BOOLEAN;                             {stop check variable         }
   Count : BYTE;                                {multipurpose counting VAR   }

{──────────────────────────────────────────────────────────────────────────}

                         { -- PRIVATE CALL -- }

PROCEDURE MWriteXY(Index : BYTE);               {Menu Write at (X,Y)         }
VAR                                             {index is the string number  }
   I : BYTE;                                    {to write. I is a counter    }
   H : BOOLEAN;                                 {H is do hotkey colors??     }
BEGIN
     GOTOXY(X1+1,Y1+1+Index);                   {Move into position          }
     H := FALSE;                                {hotkey starts 'OFF'         }
     FOR I := 1 TO LENGTH(Items[Index]^) DO     {Check each letter           }
       BEGIN
         IF Items[Index]^[I] <> '~' THEN        {if it's a after a '~' then  }
           BEGIN                                {write in Hot Key Colors     }
             IF H THEN
               BEGIN
                 TC(HKCol);
                 WRITE(Items[Index]^[I]);
               END
             ELSE                               {... else do it standard cols}
               BEGIN
                 TC(TCol);
                 WRITE(Items[Index]^[I]);
               END;
           END
         ELSE                                   {code to switch from hot to  }
           BEGIN                                {non hot                     }
             IF H THEN
               H := FALSE
             ELSE
               H := TRUE
           END;
       END;
END;

{──────────────────────────────────────────────────────────────────────────}

                          { -- PRIVATE CALL -- }

PROCEDURE Main(Dir : BOOLEAN);                  {Movement of status bar proc }
BEGIN                                           {unhighlight last item       }
     TBG(BKCol);
     MWriteXY(CurItem);
     IF Dir = Up THEN                           {if it's going up then ...   }
       BEGIN
         IF CurItem <> 0 THEN                   {... go up ...               }
           DEC(CurItem)
         ELSE
           CurItem := NoItems - 1;              {... unless its at top then  }
       END                                      {go back to the bottom       }
     ELSE
       BEGIN                                    {as for up - but down -);    }
         IF CurItem <> NoItems -1 THEN
           INC(CurItem)
         ELSE
           CurItem := 0;
       END;
     TBG(HCol);                                 {Textcolor = Highlight color }
     MWriteXY(CurItem);                         {Write proper item highlit   }
END;

{──────────────────────────────────────────────────────────────────────────}

                         { -- PRIVATE CALL -- }

PROCEDURE ElseAnalyse;                          {analyse non arrow key stroke}
VAR
   I  : BYTE;                                   {multipurpose counting vars  }
   I2 : BYTE;
   L  : CHAR;
BEGIN
     Ch := UPCASE(Ch);                          {set it to upper case        }
     IF Ch = Enter THEN BEGIN Run := CurItem; Stop := TRUE; END
     ELSE                                       {enter conditions ...        }
       FOR I := 0 TO NoItems-1 DO               { ... otherwise get Uppercase}
         BEGIN                                  {of each hotkey + compare it }
           FOR I2 := 1 TO LENGTH(Items[I]^) DO  {to that                     }
             IF Items[I]^[I2] = '~' THEN
               BEGIN
                 L := UPCASE(Items[I]^[I2+1]);
                 BREAK;                         {NB//: Break = Quit loop     }
               END;
           IF Ch = L THEN BEGIN Run := I; Stop := TRUE; EXIT; END;
         END;                                   {if it is stop run + set it  }
END;                                            {to string number            }

{──────────────────────────────────────────────────────────────────────────}

BEGIN {BODY OF RUN PROCEDURE}
                        { - INITIALIZATION PART - }
     CursorOff;
     Stop    := FALSE;
                     { - RANGE CHECKING ON STRINGS - }
     IF NoItems <= 1 THEN                       {If no items have been added }
       BEGIN                                    {then tell the user that and }
         TBG(BKCol);                            {then quit                   }
         TC(BKCol + 2);
         WriteC('Not enough Strings Initialized - Cannot Run Menu',12);
         WriteC('Press Any Key To Quit ...',13);
         READKEY;
         HALT;
       END;
                         { - FRAME X DIMENSION - }
     X1 := LENGTH(TitleStr);                    {Init max len var to title   }
     FOR Count := 0 TO NoItems-1 DO             {Do this for all items       }
       BEGIN
         X2 := LENGTH(Items[Count]^);           {Init tmp len var to str len }
         IF POS('~',Items[Count]^) <> 0 THEN    {if it has 2 '~' chars then  }
           DEC(X2,2);                           {minus them                  }
         IF X2 > X1 THEN                        {if tmp var is > max then    }
           X1 := X2;                            {reset max to show this.     }
       END;
            { - FRAME X DIMENSIONS (SUBBLOCK):- STRING RESIZING - }
     FOR Count := 0 TO NoItems-1 DO
       ResizeString(Items[Count]^,X1);          {Do string autoresize        }
                         { - FRAME X DIMENSIONS - }
     INC(X1);
     Count := X1;                               {move x1 so we can use it    }
     X1 := (80 - Count) SHR 1;                  {define the edges of the     }
     X2 := X1 + Count;                          {menu to a const for speed   }
                         { - FRAME Y DIMENSIONS - }
     Count := NoItems+1;                        {box size = number of items+1}
     IF DrawTitle THEN                          {unless you want a title     }
       INC(Count,TBlockSize);
     Y1 := (25 - Count) SHR 1;                  {calc y co - ords            }
     Y2 := Y1 + count;
                         { - BASIC SCREEN SETUP - }
     FBG(FBGS);                                 {Fill Background to constant }
     TBG(BKCol);                                {Set Text background color   }
     TC(BCol);                                  {Set Text Color              }
     Frame(X1,Y1,X2,Y2,BTyp,TRUE,' ');          {Draw the frame              }
     IF DrawTitle THEN                          {draw the title block        }
       BEGIN
         GOTOXY(X1,Y1+TBlockSize);
         IF BTyp = 1 THEN                       {adjust chars for style 1    }
           BEGIN
             WRITE('├');
             REPEAT
               WRITE('─');
             UNTIL WHEREX = X2;
             WRITE('┤');
           END;
         IF BTyp = 2 THEN                       {adjust chars for style 2    }
           BEGIN
             WRITE('╠');
             REPEAT
               WRITE('═');
             UNTIL WHEREX = X2;
             WRITE('╣');
           END;
         WriteC(TitleStr,Y1 + (TBlockSize SHR 1));
         INC(Y1,TBlockSize);                    {write in the title block +  }
       END;                                     {adjust Y1 for it            }
                           { MENU ITEM LAYOUT }

     FOR Count := 1 TO NoItems-1 DO             {do the original write up    }
       MWriteXY(Count);                         {unhighlit                   }
     TBG(HCol);
     MWriteXY(0);                               {highlighted                 }
     REPEAT                                     {Repeat chance to read in    }
       Ch := READKEY;                           {key strokes                 }
       IF Ch = #0 THEN                          {trap function keys          }
         BEGIN
         Ch := READKEY;
           CASE Ch OF
             #91       : HALT;                  {SHIFT F8 IS THE AUTO QUIT   }
             UpArrow   : Main(Up);              {left arrow                  }
             DownArrow : Main(Down);            {right arrow                 }
           END;
         END
       ELSE
         ElseAnalyse;                           {if not left or right analyse}
     UNTIL Stop;                                {stop when condition is true }
     CursorOn                                   {turn the cursor on          }
END;

{──────────────────────────────────────────────────────────────────────────}

                   { --=THINGS TO DO AFTER THE PROGRAM=-- }

{$F+}
PROCEDURE MenuExit;
BEGIN
     EXITPROC := ExitPtr;
     M.ShutDown;
END;
{$F+}

{──────────────────────────────────────────────────────────────────────────}

               { --=THINGS TO DO BEFORE RUNNING THE PROGRAM=-- }

BEGIN
     ExitPtr := EXITPROC;
     EXITPROC := @MenuExit;
     M.SetUp;
END.
---------------------------- = [Cut Here] = ---------------------------------

UNIT MenuCnst;

{──────────────────────────────────────────────────────────────────────────}

INTERFACE

{──────────────────────────────────────────────────────────────────────────}

CONST
     HKCol  =  10;                              {Text Hot Key Color          }
     TCol   =  15;                              {Standard Text Color         }
     BKCol  =  1;                               {Standard Background Color   }
     HCol   =  3;                               {Highlight Background Color  }
     BTyp   =  2;                               {Boarder Type                }
     BCol   =  15;                              {Boarder Color               }
     FBGS   =  6576;                            {Fill Back Ground Style      }
     TBlockSize = 2;                            {Title Block Size            }

{──────────────────────────────────────────────────────────────────────────}

IMPLEMENTATION

{──────────────────────────────────────────────────────────────────────────}

END.
---------------------------- = [Cut Here] = ---------------------------------


UNIT shorten;

{──────────────────────────────────────────────────────────────────────────}

INTERFACE
USES
    crt,graph;

{──────────────────────────────────────────────────────────────────────────}
TYPE
     Pallette = ARRAY [0..255,1..3] OF BYTE;
{──────────────────────────────────────────────────────────────────────────}

CONST
     UpArrow    = #72;          {special keyboard calls}
     DownArrow  = #80;
     LeftArrow  = #75;
     RightArrow = #77;
     ESC        = #27;
     ALTX       = #45;
     Enter      = #13;

     DUpLeft    = #201;         {double line box operators}
     DUpRight   = #187;
     DLowLeft   = #200;
     DLowRight  = #188;
     DStraight  = #205;
     DDown      = #186;

     SUpLeft    = #218;         {single line box operators}
     SUpRight   = #191;
     SLowLeft   = #192;
     SLowRight  = #217;
     SStraight  = #196;
     SDown      = #179;

     Theta      = #233;         {math operator symbols}
     PIsym      = #227;
     SumOf      = #228;
     ExactEqual = #240;
     ApproxEqual= #247;
     GTOET      = #242;
     LTOET      = #243;
     ElementOf  = #238;
     Intersection = #239;

     Heart      = #3;           {card symbol operators}
     Spade      = #5;
     Diamond    = #4;
     Club       = #6;

     HighBG     = FALSE;
     LowBG      = TRUE;

     MyBG        = 20144;       {fill back ground styles}
     BlueGrayBG  = 5040;
     BlueWhiteBG = 8112;
     LBlueBlueBG = 6576;

     ScreenX    = 640;          {BGI screen size constants}
     ScreenY    = 480;
     HalfX      = 320;
     HalfY      = 240;

     VGA        = $A000;        {Screen memory position}
     MCGA       = $A000;
     DosScreen  = $B800;

{──────────────────────────────────────────────────────────────────────────}

                      { -- BGI BASIC INTERFACE -- }
PROCEDURE GrInit;                            {Initiate the BGI               }
PROCEDURE GrShutDown;                        {Close down the BGI             }

{──────────────────────────────────────────────────────────────────────────}

                     { -- PALLETTE MANIPULATION -- }

PROCEDURE Pal(Col : BYTE;
              R   : BYTE;
              G   : BYTE;
              B   : BYTE);
PROCEDURE GetPal(Col : BYTE;
             VAR R   : BYTE;
             VAR G   : BYTE;
             VAR B   : BYTE);
PROCEDURE WaitRetrace;
PROCEDURE SavePallette(VAR Pall : Pallette);
PROCEDURE RestorePallette(Pall : Pallette);
PROCEDURE FadeToBlack;
PROCEDURE FadeUp(Pall : Pallette);
PROCEDURE BlackOut;

{──────────────────────────────────────────────────────────────────────────}

                        { -- CURSOR MANAGEMENT -- }

PROCEDURE CursorOn;
PROCEDURE CursorOff;

{──────────────────────────────────────────────────────────────────────────}

                  { -- MISCELL. FORMATTING ROUTINES -- }

PROCEDURE WriteXY(Str : STRING;
                  X   : BYTE;
                  Y   : BYTE);
PROCEDURE WriteC(Str : STRING;
                 Y   : BYTE);
PROCEDURE Frame(x1, y1, x2, y2 : byte; {corner coords}
                  typ : byte;         {type of frame}
                  clr : boolean;      {clear inside?}
                  clrch : char);      {clear with what}
PROCEDURE UpString(VAR Str : STRING);
FUNCTION GetCh(X : BYTE;
               Y : BYTE) : WORD;
PROCEDURE TBG(X : BYTE);                   {Change textbackground --> abbr. }
PROCEDURE TC(X : BYTE);                    {change textcolor --> abbr.      }
PROCEDURE FBG(Col : WORD);                 {fill background to a word       }
PROCEDURE FBG2(Where : WORD;               {fill bg --> to a vaddr or       }
               Ascii : BYTE;               {to a specific ascii / color     }
               Col   : BYTE);              {scheme                          }
PROCEDURE SetBG(Back : BOOLEAN);           {turn on / off hi background cols}
{──────────────────────────────────────────────────────────────────────────}

                   { -- FILE MANAGEMENT ROUTINES -- }

FUNCTION CheckForExtension(FileStr : STRING) : BOOLEAN;
FUNCTION Exist(FileName : STRING): BOOLEAN;

{──────────────────────────────────────────────────────────────────────────}

                       { -- EXIT PROCEDURE -- }

PROCEDURE MyExit;

{──────────────────────────────────────────────────────────────────────────}

                       { -- GLOBAL VARIABLES -- }
VAR
   BackUpPalletteStorage : Pallette;

{──────────────────────────────────────────────────────────────────────────}

IMPLEMENTATION
                      { -- PRIVATE VARIABLES -- }
VAR
   ExitPtr : POINTER;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE Frame(x1, y1, x2, y2 : byte; {corner coords}
                  typ : byte;         {type of frame}
                  clr : boolean;      {clear inside?}
                  clrch : char);      {clear with what}
  TYPE fchars = (ulc, top, urc, side, lrc, llc);
  CONST fc : ARRAY[0..2] OF ARRAY[fchars] OF CHAR =
    ('      ', #218#196#191#179#217#192,
     #201#205#187#186#188#200);
  VAR
    ro,co : Byte;
    S     : String[80];
  BEGIN
    FillChar(S, SizeOf(S), fc[typ][top]);
    S[0] := char(pred(x2-x1));
    GotoXY(x1, y1);
    Write(fc[typ][ulc], S, fc[typ][urc]);
    GotoXY(x1, y2);
    Write(fc[typ][llc], S, fc[typ][lrc]);
    FillChar(S[1], pred(SizeOf(S)), clrch);
    FOR ro := succ(y1) TO pred(y2) DO
      IF clr THEN
        BEGIN
          GotoXY(x1, ro);
          Write(fc[typ][side], S, fc[typ][side])
        END
      ELSE
        BEGIN
          GotoXY(x1, ro); Write(fc[typ][side]);
          GotoXY(x2, ro); Write(fc[typ][side]);
        END;
  END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE FBG(Col   : WORD); ASSEMBLER;
ASM
   push    es                           {Save ES segment on the stack        }
   mov     ax,0B800h                    {Put $0B800 in ax, start screen mem  }
   mov     es,ax                        {ES now points locat. in ax          }
   mov     cx,2000                      {CX := 2000                          }
   xor     di,di                        {Fast way of making di = 0           }
   mov     ax,[Col]                     {Hold the color in the AX register   }
   rep     stosw                        {start at ES ($B800), write AX (Fill)}
                                        {to memory at ES + DI, add 1 to DI   }
                                        {Stop when DI = CX (2000)            }
   pop     es                           {Restore ES off the stack            }
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE FBG2(Where : WORD;
               Ascii : BYTE;
               Col   : BYTE); ASSEMBLER;
ASM
   push    es                           {Save ES segment on the stack        }
   mov     cx,2000                      {CX := 2000                          }
   mov     ax,[where]
   mov     es,ax                        {ES now points at start mem location }
   xor     di,di                        {Fast way of making di = 0           }
   mov     al,[Ascii]                   {Hold the character in the AX registr}
   mov     ah,[Col]                     {Hold the color in the AX register   }
   rep     stosw                        {start at ES ($B800), write AX (Fill)}
                                        {to memory at ES + DI, add 1 to DI   }
                                        {Stop when DI = CX (2000)            }
   pop     es                           {Restore ES off the stack            }
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE SetBG(Back : BOOLEAN); ASSEMBLER;
ASM
     mov  AX,$1003
     mov  BL,Back
     int  $10
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE Pal(Col : BYTE;
              R   : BYTE;
              G   : BYTE;
              B   : BYTE); ASSEMBLER;
  { This sets the Red, Green and Blue values of a certain color }
ASM
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE GetPal(Col : BYTE;
             VAR R   : BYTE;
             VAR G   : BYTE;
             VAR B   : BYTE);
  { This gets the Red, Green and Blue values of a certain color }
VAR
   rr : BYTE;
   gg : BYTE;
   bb : BYTE;
BEGIN
   ASM
      mov    dx,3c7h
      mov    al,col
      out    dx,al

      add    dx,2

      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   END;
   r := rr;
   g := gg;
   b := bb;
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE WaitRetrace; ASSEMBLER;
LABEL
  l1, l2;
ASM
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE SavePallette(VAR Pall : Pallette);
VAR
   loop1 : INTEGER;
BEGIN
     FOR loop1 := 0 TO 255 DO
       GetPal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE RestorePallette(Pall : Pallette);
  { This procedure restores the origional pallette }
VAR
   loop1 : INTEGER;
BEGIN
     WaitRetrace;
     For loop1:=0 to 255 do
       Pal (loop1,Pall[loop1,1],Pall[loop1,2],Pall[loop1,3]);
END;

{──────────────────────────────────────────────────────────────────────────}

Procedure FadeToBlack;
  { This procedure fades the screen out to black. }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=1 to 64 do BEGIN
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are not yet zero,
          then, decrease them by one. }
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  END;
END;

{──────────────────────────────────────────────────────────────────────────}

Procedure Fadeup(Pall : Pallette);
  { This procedure slowly fades up the new screen }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=1 to 64 do BEGIN
      { A color value for Red, green or blue is 0 to 63, so this loop only
        need be executed a maximum of 64 times }
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<Pall[loop2,1] then inc (Tmp[1]);
      If Tmp[2]<Pall[loop2,2] then inc (Tmp[2]);
      If Tmp[3]<Pall[loop2,3] then inc (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are less then they
          should be, increase them by one. }
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  END;
END;

{──────────────────────────────────────────────────────────────────────────}

Procedure Blackout;
  { This procedure blackens the screen by setting the pallette values of
    all the colors to zero. }
VAR loop1:integer;
BEGIN
  WaitRetrace;
  For loop1:=0 to 255 do
    Pal (loop1,0,0,0);
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE CursorOff; ASSEMBLER;
ASM
   mov  ah,3
   mov  bh,0
   int  10h
   mov  ah,1
   mov  cx,$100
   int  10h
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE CursorOn; ASSEMBLER;
ASM
   mov  ah,1
   mov  cx,3342
   int  10h
END;

{──────────────────────────────────────────────────────────────────────────}

FUNCTION GetCh(X : BYTE;
               Y : BYTE) : WORD;
VAR
   OffSet : WORD;
   ScrPtr :^WORD;
begin
     OffSet := (((Y - 1) * 80) + X - 1) * 2;
     ScrPtr := PTR($B800,offset);
     GetCh  := ScrPtr^;
end;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE WriteXY(Str : STRING;
                  X   : BYTE;
                  Y   : BYTE);
BEGIN
     GOTOXY(X,Y);
     WRITE(Str);
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE grinit;
VAR
   gd : INTEGER;
   gm : INTEGER;
BEGIN
     gd := DETECT;
     INITGRAPH(gd, gm, '');
     IF GRAPHRESULT <> grOk THEN
       BEGIN
        gd := DETECT;
        INITGRAPH(gd, gm, 'C:\TP\BGI');
        IF GRAPHRESULT <> grOk THEN
          BEGIN
            WRITELN('GRAPHICS DRIVERS MALFUNCTION');
            READKEY;
            HALT;
          END;
       END;
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE GrShutDown;
BEGIN
     CLEARDEVICE;
     CLOSEGRAPH;
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE TBG(X : BYTE);
BEGIN
     TEXTBACKGROUND(X);
END;

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE TC(X : BYTE);
BEGIN
     TEXTCOLOR(X);
END;

{──────────────────────────────────────────────────────────────────────────}


PROCEDURE UpString(VAR Str : STRING);
VAR
   StrLen : BYTE;                    {The total Length of the string         }
   StrPos : BYTE;                    {Where in the string am I               }
BEGIN
     StrLen := LENGTH(Str);          {Get the length of the string           }
     StrPos := 1;                    {The first char in the string is 1      }
     REPEAT                          {Start repeating                        }
       Str[StrPos] := UPCASE(Str[StrPos]);
                                     {Change each letter to uppercase        }
       INC(StrPos);                  {Move to the next letter                }
     UNTIL StrPos = StrLen+1;        {Stop repeating when the word is finish }
END;     {UpString}

{──────────────────────────────────────────────────────────────────────────}

FUNCTION CheckForExtension(FileStr : STRING) : BOOLEAN;
VAR
   StrLen : BYTE;                    {The total Length of the string        }
   StrPos : BYTE;                    {Where in the string am I              }
   Found  : BOOLEAN;                 {Was a period found                    }

BEGIN
     StrLen := LENGTH(FileStr);      {Get the length of the string           }
     StrPos := 1;                    {Standard Pascal strings start at byte 1}
     Found  := FALSE;                {Default is no period                   }
     REPEAT                          {Start Repeating                        }
       IF FileStr[StrPos] = '.' THEN {Stop repeating if a full stop is found }
           Found := True;            {If you find a full stop get organised..}
       INC(StrPos);                  {move to the next spot in the string    }
     UNTIL Found OR (StrPos = StrLen);
     IF Found THEN                   {if you did find an extension output it }
       CheckForExtension := TRUE
     ELSE                            {else tell it you didn't                }
       CheckForExtension := FALSE;
END;   {CheckForExtension}

{──────────────────────────────────────────────────────────────────────────}

PROCEDURE WriteC(Str : STRING;
                 Y   : BYTE);
BEGIN
     GOTOXY(40 - (LENGTH(Str) DIV 2),Y);
     WRITE(Str);
END;

{──────────────────────────────────────────────────────────────────────────}

function Exist(FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;  { Set file access to read only }
 Reset(F);
 Close(F);
 {$I+}
 Exist := (IOResult = 0) and (FileName <> '');
end;  {Exist}

{──────────────────────────────────────────────────────────────────────────}

                { --=THINGS TO DO AFTER THE PROGRAM=-- }

{F+}
PROCEDURE MyExit;
BEGIN
     EXITPROC := ExitPtr;
     NOSOUND;
     RestorePallette(BackUpPalletteStorage);
     CursorOn;
     TEXTBACKGROUND(0);
     TEXTCOLOR(7);
     CLRSCR;
END;
{$F-}

{──────────────────────────────────────────────────────────────────────────}

             { --=THINGS TO DO BEFORE RUNNING THE PROGRAM=-- }

BEGIN
     ExitPtr  := EXITPROC;
     EXITPROC := @MyExit;
     RANDOMIZE;
     SavePallette(BackUpPalletteStorage);
     TEXTBACKGROUND(0);
     TEXTCOLOR(7);
     CLRSCR;
END.
---------------------------- = [Cut Here] = ---------------------------------


