(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0176.PAS
  Description: Texture Mapping
  Author: ALEX CHALFIN
  Date: 11-26-94  04:59
*)

{
Here is a "Perfect" texture mapper. It uses real number to map a square
bitmap into a 4 point polygon. I haven't had any time to optimize it
so I would love to see somebody speed it up for realtime uses. :)
}

Program TextMap;
{$N+,E+}   { Sorry all you out there :) }

Uses Crt;

Type
  PointType = Record
    X, Y : Integer;
  End;

Const
  Top = 1;    Bottom = 2; Left = 3; Right = 4; PWidth : Integer = 15;
  PHeight : Integer = 15;

  Points : Array[0..3] of PointType = ((x : 100; y : 100),
  (x : 150; y : 150),(x : 100; y : 200),(x : 50; y : 150));
  BitMap : Array[0..15, 0..15] of Byte = ((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
      (1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),(1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),
      (1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),(1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),
      (1,5,5,5,5,1,1,1,1,1,1,5,5,5,5,1),(1,5,5,5,5,1,0,0,0,0,1,5,5,5,5,1),
      (1,5,5,5,5,1,0,0,0,0,1,5,5,5,5,1),(1,5,5,5,5,1,0,0,0,0,1,5,5,5,5,1),
      (1,5,5,5,5,1,0,0,0,0,1,5,5,5,5,1),(1,5,5,5,5,1,1,1,1,1,1,5,5,5,5,1),
      (1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),(1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),
      (1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),(1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1),
      (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1));

Var
  LeftTable, RightTable : Array[0..400, 0..2] of Integer;
  Max_Y, Min_Y : Integer;
  LineHeight : Integer;

Procedure PutPixel(X, Y : Integer; C : Byte);

Begin
  Mem[$A000:(Y*320)+x] := c;
End;

Procedure Swap(Var a, b : Integer);

Var
  t : Integer;

Begin
  t := a;
  a := b;
  b := t;
End;

Procedure FindMaxMin;

Var
  c : Integer;

Begin
  For c := 0 to 3 do
    Begin
      If Points[c].Y < Min_y
        Then Min_Y := Points[c].Y;
      If Points[c].Y > Max_y
        Then Max_Y := Points[c].Y;
    End;
End;


Procedure ScanLeft(X1, X2, Y1, LH, Side : Integer);

Var
  y : Integer;
  XAdd, Px, Py, PxAdd, PyAdd, x : Single;

Begin
  LH := LH + 1;
  XAdd := (X2-X1)/LH;
  If Side = Top
    Then Begin
      Px := PWidth;
      Py := 0;
      PxAdd := -PWidth/LH;
      PyAdd := 0;
    End;
  If Side = Right
    Then Begin
      Px := PWidth;
      Py := PHeight;
      PxAdd := 0;
      PyAdd := -PHeight/LH;
    End;
  If Side = Bottom
    Then Begin
      Px := 0;
      Py := PHeight;
      PxAdd := PWidth/LH;
      PyAdd := 0;
    End;
  If Side = Left
    Then Begin
      Px := 0;
      Py := 0;
      PxAdd := 0;
      PyAdd := PHeight/LH;
    End;
  x := X1;
  For y := 0 to LH do
    Begin
      LeftTable[Y1 + y, 0] := Round(x);
      LeftTable[Y1 + y, 1] := Round(Px);
      LeftTable[Y1 + y, 2] := Round(Py);
      X := X + XAdd;   Px := Px + PxAdd; Py := Py + PyAdd;
    End;
End;

Procedure ScanRight(X1, X2, Y1, LH, Side : Integer);

Var
  y : Integer;
  XAdd, Px, Py, PxAdd, PyAdd, x : Single;

Begin
  LH := LH + 1;
  XAdd := (X2-X1)/LH;
  If Side = Top
    Then Begin
      Px := 0;
      Py := 0;
      PxAdd := PWidth/LH;
      PyAdd := 0;
    End;
  If Side = Right
    Then Begin
      Px := PWidth;
      Py := 0;
      PxAdd := 0;
      PyAdd := PHeight/LH;
    End;
  If Side = Bottom
    Then Begin
      Px := PWidth;
      Py := PHeight;
      PxAdd := 0;
      PyAdd := -PHeight/LH;
    End;
  If Side = Left
    Then Begin
      Px := 0;
      Py := PHeight;
      PxAdd := 0;
      PyAdd := -PHeight/LH;
    End;
  x := X1;
  For y := 0 to LH do
    Begin
      RightTable[Y1 + y, 0] := Round(x);
      RightTable[Y1 + y, 1] := Round(Px);
      RightTable[Y1 + y, 2] := Round(Py);
      X := X + XAdd;   Px := Px + PxAdd; Py := Py + PyAdd;
    End;
End;


Procedure ScanConvert(X1, Y1, X2, Y2, PLoc : Integer);

Begin
  If Y2 < Y1
    Then Begin
      Swap(X1, X2);
      Swap(Y1, Y2);
      LineHeight := Y2 - Y1;
      ScanLeft(X1, X2, Y1, LineHeight, PLoc);
    End
    Else Begin
      LineHeight := Y2 - Y1;
      ScanRight(X1, X2, Y1, LineHeight, PLoc);
    End;
End;

Procedure TextureMap;

Var
  LW, x, y : Integer;
  PolyX1, PolyX2, Px1, Px2, Py1, Py2, PxA, PyA : Single;
  Color : Byte;

Begin
  For y := Min_Y to Max_Y do
    Begin
      PolyX1 := LeftTable[y,0];
      Px1 := LeftTable[y,1];
      Py1 := LeftTable[y,2];
      PolyX2 := RightTable[y,0];
      Px2 := RightTable[y,1];
      Py2 := RightTable[y,2];
      LW := Round(PolyX2-PolyX1);
      Lw := Lw + 1;
      PxA := (Px2-Px1)/LW;
      PyA := (Py2-Py1)/LW;
      For x := Round(PolyX1) to Round(PolyX2) do
        Begin
          Color := Bitmap[Round(Py1), Round(Px1)];
          PutPixel(X, Y, Color);
          Px1 := Px1 + PxA;
          Py1 := Py1 + PyA;
        End;
    End;
End;

Begin
  Asm
    Mov AX,$13
    Int 10h
  End;
  Max_Y := 0;
  Min_Y := 32000;
  FindMaxMin;
  ScanConvert(Points[0].X, Points[0].Y, Points[1].x, Points[1].y, Top);
  ScanConvert(Points[1].X, Points[1].Y, Points[2].x, Points[2].y, Right);
  ScanConvert(Points[2].X, Points[2].Y, Points[3].x, Points[3].y, Bottom);
  ScanConvert(Points[3].X, Points[3].Y, Points[0].x, Points[0].y, Left);
  TextureMap;
  Readln;
  TextMode(co80);
End.


