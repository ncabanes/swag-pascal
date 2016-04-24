(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0201.PAS
  Description: Nice Light Vector with Box
  Author: ALEX CHALFIN
  Date: 05-26-95  23:05
*)

{
Well, here is yet another version of my light vector. This time, I
fully tested it on TP7 (I got the blip thing that everybody was saying).
But it really works this time, and it should for you as well.
In case you were wondering, the problem was in the Intensity function.
There was a Longint overflow.
}
Program Display3D;

Const NumColors : Longint = 63;

Type
  ScreenVertType = Record x, y : Integer; End;
  ScreenList = Array[0..7] of ScreenVertType;
  _3DCT = Record x, y, z : Longint; End;
  Coords = Array[0..7] of _3DCT;
  SinglePoly = Array[0..3] of Byte;
  PLT = Array[0..5] of SinglePoly;
  NormCoord = Array[0..2] of Longint;
  Norms = Array[0..5] of NormCoord;
  VScreen = Array[0..63999] of Byte;
  PVScreen = ^VScreen;

Const
  LocalCds : Coords = ((x:50; y:50;  z:50), (x:50; y:-50; z:50),
   (x:-50; y:-50; z:50),(x:-50; y:50; z:50),(x:50; y:50; z:-50),
   (x:50; y:-50; z:-50),(x:-50; y:-50; z:-50),(x:-50; y:50; z:-50));
  PolyDesc:PLT=((0,3,2,1),(5,6,7,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(0,1,5,4));
  LNormals:Norms=((0,0,4096),(0,0,-4096),(0,-4096,0),(-4096,0,0),
               (0,4096,0),(4096,0,0));

Var
  Time : Longint ABSOLUTE $0:$046c; STime, ETime, Frame : Longint;
  WNormals : Norms; Sine, CoSine : Array[0..511] of Longint;
  WorldCds : Coords; ScreenCoords : ScreenList; Page0, Page1 : PVScreen;

Procedure InitGraph;
Begin New(Page1);Asm Mov AX,13h;Int 10h;End;Page0:=Ptr($A000,0);End;

Procedure CloseGraph;
Begin Dispose(Page1); Asm Mov ax,3; Int 10h; End;End;

Procedure Cls(Var Screen); Assembler;
Asm Les  di,Screen; Xor  ax,ax; Mov  cx,32000; Rep  Stosw; End;

Procedure CopyWin(Var Source, Dest); Assembler;
Asm Push ds; Les di,Dest; Lds si,Source; Mov cx,32000;Rep Movsw;Pop ds;End;

Procedure InitPal;
Var c : Byte;
Begin For c := 0 to NumColors do Begin Port[$3c8] := c;
Port[$3c9] := Round(63*c/NumColors); Port[$3c9] := 0;
Port[$3c9] := Round(63*c/NumColors);End; End;

Procedure CalcSinus;
Var C : Longint;
Begin For C := 0 to 511 do Begin
Sine[C]:=Round(Sin(C*(2*Pi)/512)*4096);
CoSine[C]:=Round(Cos(C*(2*Pi)/512)*4096); End; End;

Function SAR(S, B : Longint) : Longint;
Begin If S<0 Then SAR:=-((-S) Shr B) Else SAR:=(S Shr B); End;

Procedure Rotate3D(Xa, Ya, Za : Word; Num : Word; Var Loc, Wor);
Var Local : Coords Absolute Loc; World : Coords Absolute Wor;
  x,y,z,Xt,Yt,Zt,C : Longint;
Begin For C := 0 to (Num-1) do Begin
  x:=Local[C].x; y:=Local[C].y; z:=Local[C].z;
  Yt:=Sar(Y*CoSine[Xa]-Z*Sine[Xa],12); Zt:=Sar(Y*Sine[Xa]+Z*CoSine[Xa],12);
  Y:=Yt;Z:=Zt; Xt:=Sar(X*CoSine[Ya]-Z*Sine[Ya],12);
  Zt:=Sar(X*Sine[Ya]+Z*CoSine[Ya],12); X:=Xt;Z:=Zt;
  Xt:=Sar(X*CoSine[Za]-Y*Sine[Za],12);Yt:=Sar(X*Sine[Za]+Y*CoSine[Za],12);
  X:=Xt; Y:=Yt; World[C].x:=X; World[C].y:=Y; World[C].z:=Z; End; End;

Procedure Project(World : Coords; Var Screen : ScreenList);
Var C : Integer;
Begin For C := 0 to 7 do Begin
 Screen[C].x := (World[C].X Shl 9) Div (512-World[C].Z) + 160;
 Screen[C].y := (World[C].Y Shl 9) Div (512-World[C].Z) + 100; End;End;

Function Intensity(World:Coords;Poly:SinglePoly;Normal:NormCoord):Word;
Const Viewer : NormCoord = (0,0,4096);
Var Dot : Longint; Temp : Word;
Begin
  Dot := Viewer[2]*Normal[2]; If Dot < 0 Then Temp := $ff00 Else Temp := 0;
  If Hi(Temp) = 0 Then Temp:=Temp+((Dot Shr 12)*NumColors) Shr 12;
  Intensity := Temp; End;

Procedure HLine(X1, X2, Y : Integer; Color : Byte; P:PVScreen);
Begin
  If Y < 0 Then Exit; If Y > 199 Then Exit;
  If X2 > X1 Then Begin If X1 < 0 Then X1 := 0;
  If X2 > 319 Then X2 := 319;
  FillChar(Mem[Seg(P^):Ofs(P^)+Y*320+X1], X2-X1+1, Color); End;
End;

Procedure DrawPoly(S : ScreenList; P : SinglePoly; Color : Byte; Page:PVScreen);
Var
  x1,y1,x2,y2,x11,y11,x22,y22,StartV1,EndV1,StartV2,EndV2 : Integer;
  Dx1, Dx2,Count1, Count2,XVal1, XVal2,MinY,C, EdgeCount : Integer;
Begin
  EdgeCount := 4; MinY := 22300;
  For C := 0 to (EdgeCount-1) do
   Begin If S[P[c]].Y < MinY Then Begin MinY := S[P[c]].Y; StartV1 := C; End;
    End;
  StartV2:=StartV1; EndV1:=StartV1-1; EndV2:=StartV2+1;
  If EndV1 < 0 Then EndV1 := (4-1); If EndV2 >= 4 Then EndV2 := 0;
  MinY:=S[P[StartV1]].Y; X1:=S[P[StartV1]].X; Y1:=S[P[StartV1]].Y;
  X2:=S[P[EndV1]].X; Y2:=S[P[EndV1]].Y; Dx1:=((X2-X1) Shl 8) Div (Y2-Y1+1);
  Count1:=Y2-Y1; XVal1:=X1 Shl 8; X11:=S[P[StartV2]].X; Y11:=S[P[StartV2]].Y;
  X22:=S[P[EndV2]].X; Y22:=S[P[EndV2]].Y;
  Dx2:=((X22-X11) Shl 8) Div (Y22-Y11+1);
  Count2:=Y22-Y11; XVal2 :=X11 Shl 8;
  While EdgeCount > 1 do
    Begin
      While (Count1 > 0) and (Count2 > 0) do
        Begin HLine(XVal1 Shr 8, XVal2 Shr 8, MinY, Color, Page);
          XVal1 := XVal1 + Dx1; XVal2 := XVal2 + Dx2;
          Count1 := Count1 - 1; Count2 := Count2 - 1; MinY := MinY + 1;
        End;
      If Count1 = 0
        Then Begin
          StartV1:=EndV1;EndV1:=EndV1-1; If EndV1 < 0 Then EndV1:=(4-1);
          EdgeCount := EdgeCount - 1; MinY := S[P[StartV1]].Y;
          If MinY > 319 Then Exit;
          X1 := S[P[StartV1]].X; Y1 := S[P[StartV1]].Y; X2 := S[P[EndV1]].X;
          Y2:=S[P[EndV1]].Y; Dx1:=((X2-X1) Shl 8) Div (Abs(Y2-Y1)+1);
          Count1 := Y2-Y1; XVal1:=X1 Shl 8;
        End;
      If Count2 = 0
        Then Begin
          StartV2:=EndV2;EndV2:=EndV2+1; If EndV2 >= 4 Then EndV2 := 0;
          EdgeCount:=EdgeCount-1; MinY:=S[P[StartV2]].Y;
          If MinY > 319 Then Exit; X11:=S[P[StartV2]].X;Y11:=S[P[StartV2]].Y;
          X22:=S[P[EndV2]].X;Y22:=S[P[EndV2]].Y;
          Dx2:=((X22-X11) Shl 8) Div (Abs(Y22-Y11)+1); Count2 := Y22-Y11;
          XVal2 := X11 Shl 8;
        End;
    End;
End;

Procedure Display(World : Coords; Normals : Norms);
Var x : Integer; Temp : Word;
Begin Project(WorldCds, ScreenCoords);
  For x := 0 to 5 do
    Begin Temp := Intensity(WorldCds, PolyDesc[x], WNormals[x]);
     If Hi(Temp) = 0 Then DrawPoly(ScreenCoords,PolyDesc[x],Lo(Temp),Page1);
    End;
End;
{ ******************** End Display Procedures ******************** }

Var a, b, c : Word;
Begin
  InitGraph; CalcSinus; InitPal; a:=0; b:=0; c:=0; Frame:=0;STime:=Time;
  Repeat Cls(Page1^);
    Rotate3D(a,b,c,8,LocalCds,WorldCds);Rotate3D(a,b,c,6,LNormals,WNormals);
    Display(WorldCds, WNormals); CopyWin(Page1^, Page0^);
    a:=a+1;b:=b+2;c:=c+1;Frame:=Frame+1;
    If a>511 Then a:=0; If b>511 Then b:=0; If c>511 Then c:=0;
  Until Port[$60]=1; ETime := Time;
  CloseGraph; Writeln((Frame*18.2)/(ETime-STime):5:2, ' fps');
End.

