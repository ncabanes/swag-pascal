(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0041.PAS
  Description: ANSI Screen Bounce
  Author: AARON SCHROEDER
  Date: 11-22-95  13:10
*)

{
MC> I once saw an advo for TMP BBS.
MC> It had an ANSi screen that "bounced" up and down.
MC>
MC> It was coded in ASM, but I wondered if Pascal could do the same. (without
MC> having to do all ASM calls.)

     Of course, but there are some calls to ports that have to be  done.

MC> The screen would bounce once, and then again, but with less height, ...
MC> It looked like a ball bouncing.

     Well, Here's some of my code.. It does a pretty good job of  imitating a
ball bouncing, but one of the bounces goes higher than  the other.. Haven't
really had time to look into it. Hopefully you  have TheDraw because I made
the program such that you have to save  your ANSI as a normal Pascal file in
The Draw and then cut and  paste it into the program. Hope this helps!

{/////////////////////////////Program/////////////////////////////////////}
Program AnsiBounce;
{Right here you place all the ANSI data from TheDraw.. When I tried, I just
 saved my picture in The Draw as a Normal pascal file and used the
 default identifier. THen I cut and pasted!                        }


Var
  start,Speed : integer;   {Where to position the screen and how fast to inc}
  cnt,Winc : byte;         {two dummy counters}

procedure SetScreenStart(ScanLine:word);            { MAIN PROCEDURE !!!!   }
{This procedure just adjusts the text viewport.. Jon Merkel gave it to me   }
var    StartAddress: word; begin    StartAddress := (ScanLine div 16)*80;
    portw[$3D4] := hi(StartAddress) shl 8 + $0C;    { Set start address     }
    portw[$3D4] := lo(StartAddress) shl 8 + $0D;
    repeat until port[$3DA] and 8<>0;               { wait for retrace      }
    portw[$3D4] := (ScanLine mod 16) shl 8 + 8;     { Set start scanline    }
    repeat until port[$3DA] and 8=0;                { wait out retrace      }
end;
begin
  asm mov ax,3; int 10h; end;     {set to 80x25 text mode just in case}
  asm in al,21h; or al,2; out 21h,al; end;        { Disable the keyboard  }
  asm mov ax,0100h; mov cx,2000h; int 10h; end;   { Hide the cursor       }
  fillchar(mem[$B800:0], 32768, 0);        {Clear the screen }
  Start := 25*16;
  SetScreenStart(start);
  Move(ImageData,mem[$B800:20*16],ImageData_length); {put our image on screen}
  Speed := -3;  cnt := 0; Winc:=0;
  Repeat      {Repeat Repeat Repeat Repeat Repeat... sorry ;) }
    inc(cnt);                          {Dummy counter for the gravity}
    Inc(start,SPeed);                  {Where to position screenStart}
    If Cnt mod 2 = 0 then              {Gives the gravity effect}
      Dec(Speed);
    If Start <=0  Then Begin           {We have reached the top!}
      Speed := abs(- (Speed) - 2);
      Inc(Winc)                  {When this gets to 15, we stop the loop}
    End;                {A term used to close the argument =) }
    SetScreenStart(start);             {Position the Screen!}
  Until (Winc>=15) or (port[$60] = $1);   {or escape is hit}
  repeat until port[$60] = $1;            {wait till you hit escape }
  asm in al,21h; and al,253; out 21h,al; end;         { enable keyboard   }
  asm mov ax,3; int 10h; end;      { reset the text mode   } end.

