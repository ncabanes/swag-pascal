(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0096.PAS
  Description: Wormhole
  Author: ALEX CHALFIN
  Date: 05-25-94  08:25
*)

{
MSGID: 1:108/180 868965DB
Well, here is the cool wormhole program that everybody has been awaiting.

It consists of three programs, WGEN, PGEN, and WORMHOLE. The WGen program
generates the data file for the wormhole. PGen generates a palette file
for the wormhole. WORMHOLE actually runs the program once everything is done.

************  Listing of WGEN.PAS
}

{$N+,E+,G+}
Program WGen;
{actually generates the Wormhole, SLOW}
{ math co-processor HIGHLY recommended }

Uses Crt;

Const
  Stretch = 25;     XCenter = 160;
  YCenter = 50;     DIVS = 1200;
  SPOKES = 2400;

Procedure TransArray;

Var
  x, y, z : Real;
  i, j, color : Integer;

Begin
  For j := 1 to DIVS do
    Begin
      For i := 0 to (Spokes-1) do
        Begin
          z := (-1.0)+(Ln(2.0*j/DIVS));
          x := (320.0*j/DIVS*cos(2*Pi*i/SPOKES));
          y := (240.0*j/DIVS*sin(2*Pi*i/Spokes));
          y := y-STRETCH*z;
          x := x + XCenter;
          y := y + YCenter;
          Color := (Round(i/8) Mod 15)+15*(Round(j/6) MOD 15)+1;
          if ((X>=0)and(x<320)and(Y>=0)and(y<200))
            Then Mem[$A000:Round(x) + (Round(y) * 320)] := Color;
        End;
    End;
End;

Procedure SaveImage;

Var
  i, j : Integer;
  Diskfile : File of Byte;

Begin
  Assign(Diskfile, 'Ln.DAT');
  Rewrite(Diskfile);
  For i := 0 to 199 do
    For j := 0 to 319 do
      Write(Diskfile, Mem[$A000:j + (320 * i)]);
  Close(Diskfile);
End;

Begin
  Asm  MOV  AX,$13; INT $10; End;
  FillChar(Mem[$A000:$0000], 64000, 0);
  transarray;
  SaveImage;
  Asm MOV  AX,3; INT $10; End;
End.

