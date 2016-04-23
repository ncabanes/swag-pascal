{
Here is a fast polygon fill I wrote in an hour. It requires that the polygon
is convex, and the verticies are in sequential order. Right now, the verticies
must be in counter clockwise rotation, but that can be changed by removing
the conditional statement in the HLine procedure. It handles an arbitrary
number of verticies.

achalfin@uceng.uc.edu
}

Procedure HLine(X1, X2, Y : Integer; Color : Byte);
{ Fill using words to speed up alot! }

Label Offscreen;

Begin
  If Y < 0 Then Goto Offscreen;
  If Y > 199 Then Goto Offscreen;
  If X2 > X1
    Then Begin
      If X1 < 0 Then X1 := 0;
      If X2 > 319 Then X2 := 319;
      FillChar(Mem[$A000:Y*320+X1], X2-X1+1, Color);
    End;
 OffScreen:
End;

Procedure FillPoly(P:MappedCoords; Num : Word; Color : Byte);
{ Mapped Coords is an array of (x, y) coords, each is an integer }

Var
  x1, y1, x2, y2, x11, y11, x22, y22 : Integer;
  StartV1, EndV1, StartV2, EndV2 : Integer;
  Dx1, Dx2, Count1, Count2 : Integer;
  XVal1, XVal2 : Longint;
  EdgeCount, MinY : Word;
  C : Integer;

Begin
  EdgeCount := Num;
  MinY := 300;
  For C := 0 to (EdgeCount-1) do  { Find Top Vertex }
    Begin
      If P[c].Y < MinY
        Then Begin MinY := P[c].Y; StartV1 := C; End;
    End;
  StartV2 := StartV1;
  EndV1 := StartV1 - 1;
  EndV2 := StartV2 + 1;
  If EndV1 < 0 Then EndV1 := (Num-1);
  If EndV2 >= Num Then EndV2 := 0;
  MinY := P[StartV1].Y;
  X1:=P[StartV1].X; Y1:=P[StartV1].Y; X2:=P[EndV1].X; Y2:=P[EndV1].Y;
  Dx1 := ((X2 - X1) Shl 8) Div (Y2 - Y1 + 1);
  Count1 := Y2-Y1; XVal1 := Longint(X1) Shl 8;
  X11:=P[StartV2].X; Y11:=P[StartV2].Y; X22:=P[EndV2].X; Y22:=P[EndV2].Y;
  Dx2 := ((X22 - X11) Shl 8) Div (Y22 - Y11 + 1);
  Count2 := Y22-Y11;  XVal2 := Longint(X11) Shl 8;
  While EdgeCount > 1 do
    Begin
      While (Count1 > 0) and (Count2 > 0) do
        Begin
          HLine(XVal1 Shr 8, XVal2 Shr 8, MinY, Color);
          XVal1 := XVal1 + Dx1; XVal2 := XVal2 + Dx2;
          Count1 := Count1 - 1; Count2 := Count2 - 1;
          MinY := MinY + 1;
        End;
      If Count1 = 0
        Then Begin
          StartV1 := EndV1;  EndV1 := EndV1 - 1;
          If EndV1 < 0 Then EndV1 := (Num-1);
          EdgeCount := EdgeCount - 1; MinY := P[StartV1].Y;
          X1 := P[StartV1].X; Y1 := P[StartV1].Y;
          X2 := P[EndV1].X; Y2 := P[EndV1].Y;
          Dx1 := ((X2 - X1) Shl 8) Div (Abs(Y2 - Y1) + 1);
          Count1 := Y2-Y1; XVal1 := Longint(X1) Shl 8;
        End;
      If Count2 = 0
        Then Begin
          StartV2 := EndV2; EndV2 := EndV2 + 1;
          If EndV2 >= Num  Then EndV2 := 0;
          EdgeCount := EdgeCount - 1; MinY := P[StartV2].Y;
          X11 := P[StartV2].X; Y11 := P[StartV2].Y;
          X22 := P[EndV2].X; Y22 := P[EndV2].Y;
          Dx2 := ((X22 - X11) Shl 8) Div (Abs(Y22 - Y11) + 1);
          Count2 := Y22-Y11; XVal2 := Longint(X11) Shl 8;
        End;
    End;
End;

