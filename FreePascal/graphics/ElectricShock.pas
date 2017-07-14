(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0271.PAS
  Description: Electric Shock
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:08
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
Uses Graph, winCrt;
Var X, Y : Word;
    R : ShortInt;
    Xx : Array[1..10] of Word;
    C : Array[1..10] of Byte;
    W : Array[1..10] of Word;
    B : Byte;
    S : String[1];
    gd, gm: integer;

Begin
gd := detect;
initGraph(gd, gm, 'd:\bp\bgi');
For B := 1 to 63 do SetRgbPalette(B,B,B,B div 3);
Repeat
ClearDevice;
For B := 1 to 10 do C[B] := Random(63);
 X := GetMaxX div 2;
 For B := 1 to 10 do W[b] := Random(300)-150+GetMaxY div 2;
 For Y := 00 to GetMaxY do
  Begin
   For B := 1 to 10 do
    If Y = W[B] then Xx[B] := X;
   If Y mod 10 = 0 then R := Random(3)-1;
   X:=X+R;
   X:=X+Random(3)-1;
   PutPixel(X,Y,63);
   PutPixel(X+1,Y,23);
   PutPixel(X-1,Y,23);
  End;
For B := 1 to 10 do
Begin
 X := Xx[B];
 For Y := w[b] to W[b] + Random(200) do
  Begin
   If Y mod 10 = 0 then R := Random(3)-1;
   X:=X+R+Random(3)-1;
   If Odd(Y) then
    If Odd(B) then Inc(X) else Dec(X);
   PutPixel(X,Y,C[B]);
  End;
End;
{ ReadLn(S);}
Until {Port[$60] = 1} keypressed;
NOSound;
End.
