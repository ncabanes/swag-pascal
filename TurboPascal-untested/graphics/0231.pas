(*      Green Fire       *)
(* By Nick Slaughter '96 *)

(* Feel free to use this source!  *)
(* I had fun making it! ;)        *)

(*              //Nick Slaughter  *)

(* Sorry about my bad ENGLISH! ;) heheh *)
Program gfire;

Uses Crt;

Var Buffer : Array[0..16000] of Byte;

procedure mcga;  { Mcga (mode 13) }
  begin
  Asm
    Mov  ax,13h
    Int  10h
  End;
end;
Procedure Firecalc;
{ Calculating of the Fire!}

Var
  x, y, ColorVal : Integer;

Begin
  For y := 98 downto 0 do
  For x := 159 downto 0 do
  Begin
  ColorVal := (Buffer[(Y+1)*160+x]+Buffer[(Y+1)*160+(x+1)]+
    Buffer[(Y+1)*160+(x-1)]+Buffer[Y*160+x]) Shr 2;
  If ColorVal > 0
   Then ColorVal := ColorVal - 1;
    Buffer[Y*160+x] := ColorVal;
  End;
End;

Procedure Kordinat;
{Sets the cordinates at the bottom of the screen!}

Var  q : Integer;

Begin
  For q := 0 to 159 do
    Buffer[99*160+q] := Random(2) * 255;
End;


Procedure Kopiera;
{ Copy the fire using 2*2 squars }

Var
  x,y : Integer;

Begin
  For y := 197 downto 0 do
  For x := 319 downto 0 do
  Mem[$A000:y*320+x] := Buffer[(y Shr 1)*160+(x Shr 1)];
End;

Procedure Greencolor;
{ Makes the green COLOR! }

Var
 col : Integer;

Begin
 For col := 255 Downto 0 do
  Begin
   Port[$3c8] := col;
   Port[$3c9] := col Div 12;
   Port[$3c9] := col Div 7;
   Port[$3c9] := 0;
 End;
End;

begin
  mcga;  { Get the mode13 procedure }
  FillChar(Buffer, Sizeof(Buffer), 0);
  Greencolor;   { Get the Greencolor procedure }
  Repeat              { Repeats until a key is pressed }
    Kordinat;
    Firecalc;
    Kopiera;
  Until KeyPressed;
  Asm
  Mov  ax,0003h   { Back in text mode }
  Int  10h
  End;
End.


Contact me:

E-MAIL:

jimmy.painless@falkenberg.mail.telia.com

cya

                        //Nick Slaughter
