{
 Voxel's in a litteral sence are "Volume Pixels" so to do it 100% correctly
 you would have to draw a 3d rectangular box at each coord.

 Fortunitely there is an easy way to make it MUCH faster with out loosing
 much detail.

 Here is a re-work of the voxel code posted earlier. I have renamed
 everything so it would be easier to follow. I have also added color
 interpolation when drawing it. I haven't played with it in a while (cause
 I like to write all my own code), but I'm sure everything is in working
 order.
}
Program VoxelLand; {$G+}
{ Alex Chalfin }
{ Yet another modified source of Voxels (I forget who posted it first) }
{ Added: Gouraud interpolation of the colors for a smoother look }
{        It might be a little faster.                            }
{ Internet: achalfin@uceng.uc.edu }
{ Fidonet: 1:108/180              }

Uses Crt;
Type MapArray = Array[0..65534] of Byte; ScreenArray=Array[0..63999] of Byte;
  PMapArray = ^MapArray; PScreenArray = ^ScreenArray;

Var Map : PMapArray; VScreen : PScreenArray; Screen : PScreenArray;
  Range : Array[0..319] of Byte;
  Sine, Cosine : Array[0..511] of Integer;

Procedure InitGraph;
Begin Screen := Ptr($A000, 0); New(VScreen);
Asm; Mov  ax,13h; Int  10h; End; End;

Procedure CloseGraph;
Begin Asm; Mov ax,3h; Int 10h; End; Dispose(VScreen); End;

Procedure ClearScreen(Var S); Assembler;
Asm; Les di,S; db 66h; Xor ax,ax; Mov cx,16000; db 66h; Rep Stosw; End;

Procedure CopyScreen(Var S, D); Assembler;
Asm; Push ds;Les di,D;Lds si,S;Mov cx,16000;db 66h;Rep Movsw;Pop  ds; End;

Procedure SetColor(Color, R, G, B : Byte);
Begin Port[$3c8]:=Color;Port[$3c9]:=R;Port[$3c9]:=G;Port[$3c9]:=B;End;

Procedure InitPalette;
Var Count : Word;
Begin For Count := 1 to 25 do SetColor(Count, Count*2, Count*2, 63);
For Count := 25 to 127 do SetColor(Count, Count Div 3, Count Div 2, 0); End;

Function NewColor(Mc, N, Dvd : integer) : Byte;
Var Loc : Integer;
Begin Loc := (Mc + N - Random(N Shl 1)) Div Dvd - 1;
 If Loc > 250 Then Loc := 250;
 If Loc < 5 Then Loc:=5; NewColor := Lo(Loc); End;

Procedure MakeFractalMap(X1, Y1, X2, Y2 : Word);
Var Xn, Yn, Dxy, P1, P2, P3, P4 : Word;
Begin If ((x2-x1<2) and (y2-y1<2)) Then Exit;
 P1:=Map^[(Y1 Shl 8)+X1]; P2:=Map^[(Y2 Shl 8)+X1]; P3:=Map^[(Y1 Shl 8)+X2];
 P4:=Map^[(Y2 Shl 8)+X2]; Xn:=(X2+X1) Shr 1; Yn:=(Y2+Y1) Shr 1;
 Dxy:=5 * (X2 - X1 + Y2 - Y1) Div 3;
 If Map^[(Y1 Shl 8)+Xn]=0 Then Map^[(Y1 Shl 8)+Xn]:=NewColor(P1+P3,Dxy,2);
 If Map^[(Yn Shl 8)+X1]=0 Then Map^[(Yn Shl 8)+X1]:=NewColor(P1+P2,Dxy,2);
 If Map^[(Yn Shl 8)+X2]=0 Then Map^[(Yn Shl 8)+X2]:=NewColor(P3+P4,Dxy,2);
 If Map^[(Y2 Shl 8)+Xn]=0 Then Map^[(Y2 Shl 8)+Xn]:=NewColor(P1+P2,Dxy,2);
 Map^[(Yn Shl 8)+Xn] := NewColor(P1 + P2 + P3 + P4, Dxy, 4);
 MakeFractalMap(X1, Y1, Xn, Yn); MakeFractalMap(Xn, Y1, X2, Yn);
 MakeFractalMap(X1, Yn, Xn, Y2); MakeFractalMap(Xn, Yn, X2, Y2); End;

Procedure CreateMap;
Begin Randomize; New(Map); FillChar(Map^[0], (256*256)-1, 0);
  Map^[0]:=128; Writeln('Generating map.'); MakeFractalMap(0,0,256,256); End;

Procedure MakeSinus;
Var Count : Word;
Begin For Count := 0 to 511 do Begin
Sine[Count] := Round(Sin(Count*((2*Pi)/512)) * 256);
Cosine[Count] := Round(Cos(Count*((2*Pi)/512)) * 256); End;End;

Procedure InterPollColor(Y, Y2, X, MapColor: Integer); Assembler;
Asm; Les  di,VScreen; Mov  ax,Y2;Cmp  ax,199;Jl @GouraudColor;@FlatColor:
  Mov bx,320;IMul bx;Add ax,X;Add di,ax;  Mov  cx,Y2;Sub  cx,Y;Mov  ax,MapColor
 @FlatLooper:;Mov  es:[di],al;Sub  di,320;Dec  cx;Jnz @FlatLooper;Jmp @Exit
 @GouraudColor:;Mov  cx,ax;  Sub  cx,Y;Mov  bx,320;IMul bx;Add  ax,X
  Add di,ax;Mov  ax,MapColor;Xor  bx,bx;Mov  bl,Byte Ptr es:[di+320]
  Push bx;Sub  ax,bx;Shl  ax,8;Cwd;Idiv cx;Mov  bx,ax;Pop  ax;Shl  ax,8
  Shr cx,1;Jnc @Gouraud4Looper;Mov  es:[di],ah;Add  ax,bx;Sub  di,320
  Jcxz @Exit;@Gouraud4Looper:;Mov  es:[di],ah;Add  ax,bx;Sub  di,320
  Mov es:[di],ah;Add ax,bx;Sub di,320;Dec cx;Jnz @Gouraud4Looper;@Exit: End;

Procedure DisplayLandScape(XPos, YPos, Dir : Integer);
Const ScreenWidth = 320;
Var ViewerZ, YDepth, ColWidth,XCount, YCount, NewX, NewY : Integer;
  ProjX, ProjY, ZPos, MapColor,BarCount, CrossCount : Integer;
  LeftLine, RightLine,YSin, YCos : Integer;
Begin
  FillChar(Range, 320, 199); ViewerZ := Map^[(YPos Shl 8)+XPos] + 100;
  For YCount := YPos to (YPos + 50) do
    Begin YDepth := ((YCount-YPos) Shl 1)+1; ColWidth:=(300 Div YDepth)+4;
      LeftLine:=(XPos+(YPos-YCount));RightLine:=(XPos + (-YPos + YCount));
      YSin := (YCount-YPos) * Sine[Dir];YCos := (YCount-YPos) * CoSine[Dir];
      For XCount := LeftLine to RightLine do
        Begin
          NewX := ((XCount-XPos)*CoSine[Dir]+YSin) Shr 8 + XPos;
          NewY := (YCos-(XCount-XPos)*Sine[Dir]) Shr 8 + YPos;
          ProjX := ((XCount-XPos) * ScreenWidth) Div YDepth + 160;
          If (ProjX >= 0) And ((ProjX + ColWidth) <= 319)
            Then Begin
              ZPos := Map^[(NewY Shl 8) + NewX]; MapColor := ZPos Shr 1;
              If ZPos <= 50 Then ZPos := 50;
              ProjY := ((ViewerZ - ZPos) Shl 5) Div YDepth + 100;
              If (ProjY >= 0) And (ProjY <= 199)
                Then Begin For BarCount := ProjX to (ProjX + ColWidth) do
                    Begin If ProjY < Range[BarCount] Then Begin
             InterPollColor(ProjY, Range[BarCount], BarCount, MapColor);
 Range[BarCount] := ProjY; End;End;End;End;End;End;End;

Function Voxelize : Real;

Var Time : Longint Absolute $0000:$046c; StartTime, EndTime, Frame : Longint;
  XPos, YPos, Dir : Integer; Quit : Boolean;

Begin
  InitGraph; InitPalette;Quit:=False;XPos:=0;YPos:=0;Dir:=0;StartTime:=Time;
  Frame := 0;
  Repeat
    Dir := Dir And 511; Frame := Frame + 1;
    ClearScreen(VScreen^); DisplayLandscape(XPos Shr 8, YPos Shr 8, Dir);
    CopyScreen(VScreen^, Screen^);
    If KeyPressed Then Begin
        Case ReadKey of #0 : Case ReadKey of
             #75 : Dir := Dir - 10; #77 : Dir := Dir + 10;   { Right Key }
             #72 : Begin XPos:=(XPos+Sine[Dir] Shl 2);
                   YPos := (YPos + CoSine[Dir] Shl 2); End;
             #80 : Begin XPos := (XPos - Sine[Dir] Shl 2);
                     YPos := (YPos - CoSine[Dir] Shl 2); End;
           End; #27 : Quit := True; End; End;
  Until Quit; EndTime := Time; CloseGraph; Dispose(Map);
  Voxelize :=  (Frame*18.2)/(EndTime-StartTime); End;

Begin
  MakeSinus; CreateMap; Writeln(Voxelize:5:2, ' Frames per second');
End.
