{
Here a sample program which shows a smoothly (graphics mode like)
animation of a thermobar display. It works (I think) only on VGA cards

The trick is done by animating one character by changing it's
bitpattern. }


{---------------------------------------------------------}
{  Project : Textmode thermometer bar                     }
{  Unit    : Main Program                                 }
{  By      : Wim van der Vegt                             }
{---------------------------------------------------------}
{  This program shows a thermometer bar display similar   }
{  to the ones in many installation programs. This one    }
{  however is in textmode, but smoothly animated as if in }
{  graphics mode. It is only tested on one (S)VGA card.   }
{---------------------------------------------------------}
{  Date  .Time  Revision                                  }
{  940620.1450  Creation.                                 }
{---------------------------------------------------------}

Uses
  Dos,
  Crt;

Const
  c : Array[1..16] Of Byte = (255,255,255,255,
                              255,255,255,255,
                              255,255,255,255,
                              255,255,255,255);

{---------------------------------------------------------}
{---Procedure to turn cursor on/off.                      }
{---------------------------------------------------------}

Procedure Cursor(on : Boolean);

VAR
  r : registers;

BEGIN
  r.ah:=$03;
  r.bh:=$00;
  Intr($10,r);

  IF ((r.cx< $2020) AND NOT(on)) OR
     ((r.cx>=$2020) AND on)
    THEN
      BEGIN
        r.ah:=$01;
        r.cx:=r.cx XOR $2020;
        Intr($10,r);
      END;
END; {of Cursor}

{---------------------------------------------------------}
{---Procedure to wait for the vertical retrace of the VGA }
{   display. This minimizes screen flickering when the    }
{   CRTC gets reprogrammed.                               }
{---------------------------------------------------------}

PROCEDURE Wait4Retrace;

begin
  while ((Port[$3DA] AND 8) > 0) do;
  while ((Port[$3DA] AND 8) = 0) do;
end; {of Wait4Retrace;}

{---------------------------------------------------------}
{---Procedure to generate an animation scene for character}
{   #1. The cursor is turned off every time the procedure }
{   is called because the cursor keeps showing up when the}
{   CRTC is reprogrammed. And a cursor behind a smoothly  }
{   animated thermobar just doesn't feel right.           }
{---------------------------------------------------------}

Procedure Reprogram(i,bperc : Byte);

VAR
  j : integer;
  r : registers;
  w : Word;

Begin
{----calculate bittpattern. It goes like
     0
     128
     128+64
     128+64+32
     128+64+32+16
     128+64+32+16+8
     128+64+32+16+8+4
     128+64+32+16+8+4+2
     128+64+32+16+8+4+2+1 (This is equivalent to character 219 '█')
     }

   w:=0;
   FOR j:=1 TO i DO w:=w+BYTE(256 SHR j);
   For j:=1 To bperc Do c[j]:=w;

 {----reprogram character #1,
      but wait for retrace so there's no flickering}
   r.ah:=$11;
   r.al:=$10;
   r.bh:=bperc;
   r.bl:=$00;
   r.cx:=$01;
   r.dx:=$01;
   r.bp:=Ofs(c);
   r.es:=Seg(c);
   Wait4Retrace;
   Intr($10,r);
  Cursor(false);
End; {of Reprogram}

{---------------------------------------------------------}
{---Main program, btw the character #1 isn't restored     }
{   because it's seldomly used by application.            }
{   a TEXTMODE(LASTMODE) statement will clear the screen  }
{   and restore character #1. So put that at the end of   }
{   program                                               }
{---------------------------------------------------------}

Var
  r     : registers;
  i,k   : Byte;
  bperc : Byte;

Begin
  Clrscr;

  GotoXY(20,5);
  Write('0%                50%               100%');
  GotoXY(20,4);

{----get bytes per character of current font,
     by requesting font data on font #0 (INT 1F)}
  r.ah:=$11;
  r.al:=$30;
  r.bh:=$00;
  Intr($10,r);
  bperc:=r.cx;

  textcolor(yellow);

{----Do a 30 character bar}
  For k:=1 To 40 Do
    Begin
    {----Use chr(1) to animate, however wipe it before writing it}
      Reprogram(0,bperc);
      Write(#01);

    {----Animate character #1}
      For i:=0 To 7 Do
        Begin
        {----calc bit new patterns,
             bit patterns are reversed in character generator,
             bit 7 is on the left side of a character}
          Reprogram(i,bperc);
          Delay(25);
        End;

   {----Replace fully animated characters by a full block from
        the line drawing set because animation of character #1
        will be started all over}
     GotoXY(WhereX-1,WhereY);
     Write('█');
    End;
  GotoXY(1,6);
  Cursor(true);

 {textmode(lastmode);}
End. {of Main program}
