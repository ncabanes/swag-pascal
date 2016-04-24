(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0232.PAS
  Description: Text-Mapped Vector Cube
  Author: ALEX CHALFIN
  Date: 05-26-95  23:30
*)

{
OK here is a texture mapped vector cube. Sorry the code is so squashed, but
I wanted to keep it to 2 messages. This code took me about a day to crank out
so it isn't too optimized.
}

Program TextureVector;
{ Alex Chalfin  10/15/94          }
{ Internet: achalfin@uceng.uc.edu }
{ Fidonet: 1:108/180              }
{$G+}

Type LongCoord=Record x,y,z:Longint; End; SCoord=Record x,y:Integer;End;
  VCoords=Array[0..7] of LongCoord; NCoords=Array[0..5] of LongCoord;
  SinglePoly=Array[0..3] of Byte; PLT=Array[0..5] of SinglePoly;
  SideValues=Record X:Integer;Px,Py:Byte;End;
  SideTable=Array[0..199] of SideValues;

Const
  LocalCoords:VCoords=((x:50;y:50;z:50),(x:50;y:-50;z:50),(x:-50;y:-50;z:50),
  (x:-50;y:50;z:50),(x:50;y:50;z:-50),(x:50;y:-50;z:-50),(x:-50;y:-50;z:-50),
  (x:-50; y:50; z:-50));
  LocalNorms:NCoords=((x:0;y:0;z:256),(x:0;y:0;z:-256),(x:0;y:-256;z:0),
             (x:-256;y:0;z:0),(x:0;y:256;z:0),(x:256;y:0;z:0));
  Poly:PLT=((0,3,2,1),(5,6,7,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(0,1,5,4));
  Top=1;Bottom=2;Left=3;Right=4;MapShift=5;PicW=32;

Var Page1,Page0:Pointer; Sine,CoSine:Array[0..511] of Longint;
  LookUp:Array[0..199] of Word; WorldCoords:VCoords; WorldNorms:NCoords;
  SC : Array[0..7] of SCoord; Xa, Ya, Za : Word;
  LeftTable, RightTable : SideTable;

Const BitMap : Array[0..PicW*PicW-1] of Byte = (
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,5,5,
5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,1,5,5,5,5,5,5,5,5,5,5,5,
5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,1,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
5,5,5,5,5,5,5,5,5,5,5,5,5,1,1,5,5,5,2,2,5,5,5,5,2,2,2,2,2,2,2,2,2,5,5,5,2,2,
2,2,2,2,5,5,5,1,1,5,5,2,5,5,2,5,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,
5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,5,1,1,5,2,5,
5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,5,1,1,5,2,5,5,5,5,2,5,5,
2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,
5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,
5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,
5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,
2,5,5,5,5,2,5,5,2,2,2,2,2,2,2,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,2,2,2,2,2,
5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,
5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,
5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,
5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,
1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,
5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,
5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,
5,5,5,2,5,5,5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,
5,5,5,5,5,5,5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,5,5,
5,1,1,5,2,5,5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,5,1,1,5,2,5,
5,5,5,2,5,5,2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,5,1,1,5,2,5,5,5,5,2,5,5,
2,5,5,5,5,5,5,5,5,5,5,2,5,5,5,5,5,5,2,5,5,1,1,5,2,5,5,5,5,2,5,5,2,2,2,2,2,2,
2,2,2,5,5,5,2,2,2,2,2,2,5,5,5,1,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
5,5,5,5,5,5,5,5,5,1,1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
5,5,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);

Procedure ScanLeft(X1, Y1, X2, Y2, Edge : Integer);
Var Count,XVal,XAdd : Integer; Px, Py : Byte; PxConst : Boolean;

Begin;XVal := (X1) Shl 8;XAdd := ((X2-X1) Shl 8) Div (Y2-Y1+1);
  For Count := Y1 to Y2 do Begin
   LeftTable[Count].X:=XVal Shr 8;XVal:=XVal+XAdd; End;
  If Edge = Top Then Begin;X1:=PicW-1;X2:=0;Py:=0;PxConst:=False;End;
  If Edge = Right Then Begin;X1:=PicW-1;X2:=0;Px:=PicW-1;PxConst:=True;End;
  If Edge = Bottom Then Begin;X1:=0;X2:=PicW-1;Py:=PicW-1;PxConst:=False;End;
  If Edge = Left Then Begin;X1:=0;X2:=PicW-1;Px:=0;PxConst:=True;End;
  If PxConst Then Begin
      XVal := X1 Shl 8;XAdd := ((X2-X1) Shl 8) Div (Y2-Y1+1);
      For Count := Y1 to Y2 do Begin
          LeftTable[Count].Px := Px;LeftTable[Count].Py := XVal Shr 8;
          XVal := XVal + XAdd;End;End
    Else Begin XVal := X1 Shl 8;XAdd := ((X2-X1) Shl 8) Div (Y2-Y1+1);
      For Count := Y1 to Y2 do  Begin
          LeftTable[Count].Px := XVal Shr 8;LeftTable[Count].Py := Py;
          XVal := XVal + XAdd;End;End;
End;


Procedure ScanRight(X1, Y1, X2, Y2, Edge : Integer);
Var Count,XVal,XAdd : Integer;Px, Py : Byte;PxConst : Boolean;
Begin
  XVal := X1 Shl 8;XAdd := ((X2-X1) Shl 8) Div (Y2-Y1+1);
  For Count := Y1 to Y2 do Begin RightTable[Count].X:=XVal Shr 8;
    XVal:=XVal+XAdd;End;
 If Edge = Top Then Begin X1 := 0;X2 := PicW-1;Py := 0;PxConst := False;End;
 If Edge = Right Then Begin X1:=0;X2:=PicW-1;Px:=PicW-1;PxConst:=True;End;
 If Edge = Bottom Then Begin X1:=PicW-1;X2:=0;Py:=PicW-1;PxConst:=False;End;
 If Edge = Left Then Begin X1:=PicW-1;X2:=0;Px:=0;PxConst := True; End;
 If PxConst Then Begin XVal:=X1 Shl 8;XAdd:=((X2-X1) Shl 8) Div (Y2-Y1+1);
      For Count := Y1 to Y2+1 do Begin
          RightTable[Count].Px := Px; RightTable[Count].Py := XVal Shr 8;
          XVal := XVal + XAdd; End;End
    Else Begin XVal := X1 Shl 8;XAdd := ((X2-X1) Shl 8) Div (Y2-Y1+1);
      For Count := Y1 to Y2 do Begin RightTable[Count].Px := XVal Shr 8;
          RightTable[Count].Py := Py; XVal := XVal + XAdd;End;End;End;

Procedure Swap(Var a,b : Integer);
Var t : Integer; Begin t := a;a := b;b := t; End;

Procedure ScanConvert(X1, Y1, X2, Y2, Edge : Integer);
Begin If Y2 < Y1 Then Begin Swap(X1, X2);Swap(Y1, Y2);
  ScanLeft(X1,Y1,X2,Y2,Edge); End Else ScanRight(X1,Y1,X2,Y2,Edge); End;

Procedure DisplayTexture(Min, Max : Integer);
Var P1,P2,YCount,XCount,XVal,XAdd,YVal,YAdd : Integer; Offset1 : Word;
Begin For YCount := Min to Max do Begin
 YVal := LeftTable[YCount].Py Shl 8; XVal := LeftTable[YCount].Px Shl 8;
 P1 := LeftTable[YCount].X; P2 := RightTable[YCount].X;
 If P2 < P1 Then Swap(P2,P1);
 XAdd := ((RightTable[YCount].Px-LeftTable[YCount].Px) Shl 8) Div (P2-P1+1);
 YAdd := ((RightTable[YCount].Py-LeftTable[YCount].Py) Shl 8) Div (P2-P1+1);
 Offset1 := LookUp[YCount]+P1+Ofs(Page1^);
 For XCount := P1 to P2 do Begin
   Mem[Seg(Page1^):Offset1]:=BitMap[(XVal Shr 8)+(YVal Shr 8) Shl MapShift];
   XVal:=XVal+XAdd;YVal := YVal+YAdd; Offset1 := Offset1 + 1;End;End;End;

Procedure TextureMap(X1, Y1, X2, Y2, X3, Y3, X4, Y4 : Integer);
Var Count,MinY,MaxY : Integer;
Begin MinY := Y1;MaxY := Y1;
  If Y2 > MaxY Then MaxY := Y2;If Y3 > MaxY Then MaxY := Y3;
  If Y4 > MaxY Then MaxY := Y4;If Y2 < MinY Then MinY := Y2;
  If Y3 < MinY Then MinY := Y3;If Y4 < MinY Then MinY := Y4;
  ScanConvert(X1, Y1, X2, Y2, Top);ScanConvert(X2, Y2, X3, Y3, Right);
  ScanConvert(X3, Y3, X4, Y4, Bottom);ScanConvert(X4, Y4, X1, Y1, Left);
  DisplayTexture(MinY, MaxY);End;

Procedure CalcSinus;
Var C : Longint;
Begin For C := 0 to 511 do Begin
Sine[C]:=Round(Sin(C*(2*Pi)/512)*2048);
CoSine[C]:=Round(Cos(C*(2*Pi)/512)*2048); End;
For c := 0 to 199 do LookUp[c] := c*320; End;

Function SAR(S, B : Longint) : Longint;
Begin If S<0 Then SAR:=-((-S) Shr B) Else SAR:=(S Shr B); End;

Procedure Rotate3D(Var Loc, Wor; Num, Xa, Ya, Za : Word);
Var Local:NCoords Absolute Loc;World:NCoords Absolute Wor;
x,y,z,Xt,Yt,Zt,C : Longint;
Begin For C := 0 to (Num-1) do Begin
  x:=Local[C].x;y:=Local[C].y;z:=Local[C].z;
  Yt:=Sar(Y*CoSine[Xa]-Z*Sine[Xa],11);Zt:=Sar(Y*Sine[Xa]+Z*CoSine[Xa],11);
  Y:=Yt;Z:=Zt;Xt:=Sar(X*CoSine[Ya]-Z*Sine[Ya],11);
  Zt:=Sar(X*Sine[Ya]+Z*CoSine[Ya],11);X:=Xt;Z:=Zt;
  Xt:=Sar(X*CoSine[Za]-Y*Sine[Za],11);Yt:=Sar(X*Sine[Za]+Y*CoSine[Za],11);
  X:=Xt;Y:=Yt;World[C].x:=X;World[C].y:=Y;World[C].z:=Z;End; End;

Procedure DrawPolygons;
Var c : Integer; Dot : Longint;
Begin For c:=0 to 7 do With WorldCoords[c] do Begin
 SC[c].x:=(x Shl 9)Div(512-z)+160; SC[c].y:=(y Shl 9)Div(512-z)+100; End;
 For c := 0 to 5 do Begin Dot:=WorldNorms[c].z Shl 11; If Dot>=0
  Then TextureMap(SC[Poly[c,0]].x,SC[Poly[c,0]].y,
  SC[Poly[c,1]].x,SC[Poly[c,1]].y,SC[Poly[c,2]].x,SC[Poly[c,2]].y,
  SC[Poly[c,3]].x,SC[Poly[c,3]].y); End; End;

Procedure CopyPage(Var S, D); Assembler;
Asm;Push ds;Lds si,S;Les di,d;Mov cx,32000;Rep Movsw;Pop ds;End;

Procedure ClearPage(Var S); Assembler;
Asm; Les  di,S;Mov  ax,0;Mov  cx,32000;Rep  Stosw;End;

Begin
  Asm;Mov ax,13h;Int 10h;End;GetMem(Page1,65530);Page0:=Ptr($A000,0);
  ClearPage(Page1^);Xa:=0;Ya:=0;Za:=0; CalcSinus; Repeat
  Rotate3d(LocalCoords,WorldCoords,8,Xa,Ya,Za);
  Rotate3d(LocalNorms,WorldNorms,6,Xa,Ya,Za);DrawPolygons;
  CopyPage(Page1^,Page0^); ClearPage(Page1^);Xa:=(Xa+6) And 511;
  Ya:=(Ya+3) And 511;Za:=(Za+4) And 511; Until Port[$60]=1;
  Freemem(Page1, 65535); Asm; Mov ax,3; Int 10h; End;
End.


