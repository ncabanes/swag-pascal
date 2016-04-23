{
Here is some gouraud polygon code. I wrote this about a week ago.
This time I tested it on TP7 before posting it :)
Sorry its all scrunched up, but I wanted to keep it to 2 messages.
}

Program GouraudPolygon;
{ A Gouraud polygon demonstration }
{ Requires a 286 and VGA          }
{ Alex Chalfin   11/14/94         }
{ Internet: achalfin@uceng.uc.edu }
{$G+} { Enable 286 instructions }
Const NumColors = 63;   { Number of colors to use }
Type
  LCoord = Record
    x, y, z : Longint; End;
  SCoord = Record
    x, y : Integer;
  End;
  SC = Array[0..7] of SCoord;
  Coords = Array[0..7] of LCoord;
  Norms = Array[0..5,0..2] of Longint;
  NDesc = Array[0..3] of Integer;
  PLT = Array[0..5] of NDesc;
  ColorList = Array[0..7] of Integer;


Const
  Viewer : Array[0..2] of Longint = (0,0,4096);
  LocalCoords : Coords = ((x:50; y:50;  z:50), (x:50; y:-50; z:50),
   (x:-50; y:-50; z:50),(x:-50; y:50; z:50),(x:50; y:50; z:-50),
   (x:50; y:-50; z:-50),(x:-50; y:-50; z:-50),(x:-50; y:50; z:-50));
  PolyDesc:PLT=((0,3,2,1),(5,6,7,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(0,1,5,4));
  CoordNorms : Coords = ((x:2364; y:2364;  z:2364), (x:2364; y:-2364; z:2364),
   (x:-2364; y:-2364; z:2364),(x:-2364; y:2364; z:2364),(x:2364; y:2364; z:-2364),
   (x:2364; y:-2364; z:-2364),(x:-2364; y:-2364; z:-2364),(x:-2364; y:2364; z:-2364));
  LNormals:Norms=((0,0,4096),(0,0,-4096),(0,-4096,0),(-4096,0,0),
               (0,4096,0),(4096,0,0));

Var
  Sine, CoSine : Array[0..511] of Longint;
  Time : Longint ABSOLUTE $0:$046c;
  STime,ETime,Frame:Longint;WNormals:Norms;ScreenCoords:SC;
  Page0,Page1:Word;WorldCoords:Coords;Colors:ColorList;WCoordNorms:Coords;

Procedure CalcSin;
Var C : Longint;
Begin For C := 0 to 511 do
  Begin Sine[C]:=Round(Sin(C*(2*Pi)/512)*4096);
  CoSine[C]:=Round(Cos(C*(2*Pi)/512)*4096); End; End;

Procedure SetPalette;
Var x : Integer;
Begin For x := 1 to NumColors do
Begin Port[$3c8]:=x;Port[$3c9]:=0;Port[$3c9]:=Round(63*x/NumColors) Div 2;
Port[$3c9] := Round(63*x/NumColors); End; End;

Procedure InitGraph;
Var Temp : Pointer;
Begin; Asm Mov AX,13h;Int 10h;End;Page0:=$A000;GetMem(Temp,65535);
Page1 := Seg(Temp^); End;

Procedure CloseGraph;
Var Temp : Pointer;
Begin Asm Mov ax,3;Int 10h;End;Temp:=Ptr(Page1,0);Freemem(Temp,65535); End;

Procedure Cls(P : Word); Assembler;
Asm Mov es,P;Xor di,di;Xor ax,ax;Mov cx,32000;Rep Stosw; End;

Procedure CopyScreen(S, D : Word); Assembler;
Asm Push ds;Mov es,D;Mov ds,S;Xor si,si;Xor di,di;Mov cx,32000;
Rep Movsw; Pop ds; End;

Function SAR(A, B : Longint) : Longint;
Begin If A < 0 Then SAR := -((-A) Shr B) Else SAR := (A Shr B); End;

Procedure RotatePoints(Var Loc,Wor; Num, Xa, Ya, Za : Word);

Var Local:Coords Absolute Loc; World:Coords Absolute Wor;
 x,y,z,Xt,Yt,Zt,C : Longint;

Begin For C := 0 to (Num-1) do Begin
  x:=Local[C].x; y:=Local[C].y; z:=Local[C].z;
  Yt:=Sar(Y*CoSine[Xa]-Z*Sine[Xa],12); Zt:=Sar(Y*Sine[Xa]+Z*CoSine[Xa],12);
  Y:=Yt;Z:=Zt; Xt:=Sar(X*CoSine[Ya]-Z*Sine[Ya],12);
  Zt:=Sar(X*Sine[Ya]+Z*CoSine[Ya],12); X:=Xt;Z:=Zt;
  Xt:=Sar(X*CoSine[Za]-Y*Sine[Za],12);Yt:=Sar(X*Sine[Za]+Y*CoSine[Za],12);
  X:=Xt; Y:=Yt; World[C].x:=X; World[C].y:=Y; World[C].z:=Z; End; End;

Procedure Project(World : Coords; Var Screen : SC; Num : Word);
Var C : Word;
Begin For C := 0 to (Num-1) do Begin
 Screen[C].x:=(World[C].X Shl 9) Div (512-World[C].Z)+160;
 Screen[C].y:=(World[C].Y Shl 9) Div (512-World[C].Z)+100; End; End;

Function Visible(Num : Integer) : Boolean;
Begin Visible := (Viewer[2]*WNormals[Num][2] >= 0); End;

Procedure GouraudHLine(X1, X2, Y, C1, C2 : Integer); Assembler;

Asm Mov cx,X2;Sub cx,X1;Jle @Skip;Inc cx;Mov ax,320;Mul Y;Add ax,X1
    Mov di,ax;Mov es,Page1;Mov bx,C1;Mov ax,C2; Sub ax,bx; Shl ax,8
    Cwd; Idiv cx;Shl bx,8;Shr cx,1;Jnc @SkipSingle;Mov es:[di],bh
    Add bx,ax;Inc di;@SkipSingle:;@GouraudLooper:;Mov dl,bh;Add bx,ax
    Mov dh,bh;Add bx,ax;Mov es:[di],dx;Add di,2;Dec cx; Jnz @GouraudLooper
 @Skip:; End;


Procedure GouraudPoly(V : SC; P : NDesc; Num : Integer; C : ColorList);
Var Lw,MinY,SVert1,SVert2,EVert1,EVert2,Count1,Count2,EdgeCount : Integer;
  XVal1,XVal2,XAdd1,XAdd2,Color1,Color2,ColorAdd1,ColorAdd2,Count:Integer;

Begin
  EdgeCount := Num; MinY := 3000;
  For Count := 0 to (Num-1) do
    Begin
      If V[P[Count]].Y < MinY Then Begin MinY := V[P[Count]].Y;
      SVert1 := Count; End; End;
  SVert2 := SVert1; EVert1 := SVert1 - 1; EVert2 := SVert2 + 1;
  If EVert1 < 0 Then EVert1 := Num-1;
  If EVert2 >= Num Then EVert2 := 0;
  XAdd1 := ((V[P[EVert1]].X-V[P[SVert1]].X) Shl 8) Div
           ((V[P[EVert1]].Y-V[P[SVert1]].Y)+1);
  XAdd2 := ((V[P[EVert2]].X-V[P[SVert2]].X) Shl 8) Div
           ((V[P[EVert2]].Y-V[P[SVert2]].Y)+1);
  XVal1 := (V[P[SVert1]].X) Shl 8; XVal2 := (V[P[SVert2]].X) Shl 8;
  Color1 := C[P[SVert1]] Shl 8; Color2 := C[P[SVert2]] Shl 8;
  ColorAdd1 := ((C[P[EVert1]]-C[P[SVert1]]) Shl 8) Div
               ((V[P[EVert1]].Y-V[P[SVert1]].Y)+1);
  ColorAdd2 := ((C[P[EVert2]]-C[P[SVert2]]) Shl 8) Div
               ((V[P[EVert2]].Y-V[P[SVert2]].Y)+1);
  Count1 := ((V[P[EVert1]].Y-V[P[SVert1]].Y));
  Count2 := ((V[P[EVert2]].Y-V[P[SVert2]].Y));
  MinY := V[P[SVert2]].Y;
  While EdgeCount > 1 do Begin
    While (Count1 > 0) and (Count2 > 0) do Begin
      GouraudHLine(XVal1 Shr 8,XVal2 Shr 8,MinY,Color1 Shr 8,Color2 Shr 8);
      XVal1 := XVal1 + XAdd1; XVal2 := XVal2 + XAdd2;
      Color1 := Color1 + ColorAdd1; Color2 := Color2 + ColorAdd2;
      Count1 := Count1 - 1; Count2 := Count2 - 1; Inc(MinY); End;
      If Count1 = 0 Then Begin
          SVert1 := EVert1; EVert1 := SVert1 - 1;
          If EVert1 < 0 Then EVert1 := Num-1;
          LW := V[P[EVert1]].Y-V[P[SVert1]].Y+1; If LW = 0 Then LW := 1;
          XAdd1 := ((V[P[EVert1]].X-V[P[SVert1]].X) Shl 8) Div LW;
          XVal1 := (V[P[SVert1]].X) Shl 8; Color1 := C[P[SVert1]] Shl 8;
          ColorAdd1 := ((C[P[EVert1]]-C[P[SVert1]]) Shl 8) Div LW;
          Count1 := ((V[P[EVert1]].Y-V[P[SVert1]].Y));
          MinY := V[P[SVert1]].Y; EdgeCount := EdgeCount - 1; End;
      If Count2 = 0 Then Begin
          SVert2:=EVert2;EVert2:=SVert2+1;If EVert2>=Num Then EVert2:=0;
          LW := V[P[EVert2]].Y-V[P[SVert2]].Y+1; If LW = 0 Then LW := 1;
          XAdd2 := ((V[P[EVert2]].X-V[P[SVert2]].X) Shl 8) Div LW;
          XVal2 := (V[P[SVert2]].X) Shl 8; Color2 := C[P[SVert2]] Shl 8;
          ColorAdd2 := ((C[P[EVert2]]-C[P[SVert2]]) Shl 8) Div LW;
          Count2 := ((V[P[EVert2]].Y-V[P[SVert2]].Y));
          MinY := V[P[SVert2]].Y;EdgeCount := EdgeCount - 1;End; End;
End;

Procedure CalcColors(Num : Integer);
Var x : Integer; Dot : Longint;
Begin
  For x := 0 to 3 do Begin Dot := Viewer[2]*WCoordNorms[PolyDesc[Num][x]].z;
  If Dot>=0 Then Colors[PolyDesc[Num][x]] := ((Dot Shr 12)*NumColors) Shr 12
   Else Colors[PolyDesc[Num][x]] := 0; End;
End;

Procedure DrawPoly;
Var x : Integer;
Begin For x := 0 to 5 do Begin
If Visible(x) Then Begin CalcColors(x);
GouraudPoly(ScreenCoords, PolyDesc[x], 4, Colors); End; End;End;

Var Xa, Ya, Za : Word;

Begin
  CalcSin; InitGraph; Cls(Page1); SetPalette; Xa := 0; Ya := 0; Za := 0;
  Frame := 0; STime := Time;
  Repeat
    RotatePoints(LocalCoords, WorldCoords, 8, Xa, Ya, Za);  { Coordinates }
    RotatePoints(LNormals, WNormals, 6, Xa, Ya, Za);      { Face normals }
    RotatePoints(CoordNorms, WCoordNorms, 8, Xa, Ya, Za); { Coord Normals }
    Project(WorldCoords, ScreenCoords, 8);
    DrawPoly; Frame := Frame + 1; CopyScreen(Page1, Page0); Cls(Page1);
    xa:=xa+2;ya:=ya+1;Za:=Za+1;If xa>511 then xa:=0;If ya>511 then ya:=0;
    If za>511 then za:=0;Until Port[$60]=1; ETime:=Time; CloseGraph;
  Writeln((Frame*18.2)/(ETime-STime):5:2, ' fps');
End.

