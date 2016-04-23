{
SEAN PALMER

> I've been trying For some time to get a Pascal Procedure that can
> SCALE and/or ROTATE Graphic images. if anyone has any idea how to do this,
> or has a source code, PLEEEAASSEE drop me a line.. THANK YOU!

This is an out-and-out blatant hack of the routines from Abrash's
XSHARP21. They are too slow to be usable as implemented here.
}

{$A-,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S-,V-,X+}
{$M $2000,0,0}
Program VectTest;
Uses
  Crt, b320x200; {<-this Unit just implements Plot(x, y) and Color : Byte; }

Const
  ClipMinY = 0;
  ClipMaxY = 199;
  ClipMinX = 0;
  ClipMaxX = 319;
  VertMax  = 3;

Type
  fixed = Record
    Case Byte of
      0 : (f : Byte; si : shortint);
      1 : (f2, b : Byte);
      2 : (w : Word);
      3 : (i : Integer);
    end;

  ByteArray = Array [0..63999] of Byte;

  VertRec   = Record
    X, Y : Byte;
  end;

  VertArr   = Array [0..VertMax] Of VertRec;
  EdgeScan  = Record
    scansLeft   : Integer;
    Currentend  : Integer;
    srcX, srcY  : fixed;
    srcStepX,
    srcStepY    : fixed;
    dstX        : Integer;
    dstXIntStep : Integer;
    dstXdir     : Integer;
    dstXErrTerm : Integer;
    dstXAdjUp   : Integer;
    dstXAdjDown : Integer;
    dir         : shortInt;
  end;

Const
  numVerts = 4;
  mapX     = 7;
  mapY     = 7;

  Vertex : Array [0..vertMax] of vertRec =
    ((x : 040; y : 020),
     (x : 160; y : 050),
     (x : 160; y : 149),
     (x : 040; y : 179));

  Points : Array [0..vertMax] of vertRec =
    ((x : 0; y : 0),
     (x : mapX; y : 0),
     (x : mapX; y : mapY),
     (x : 0; y : mapY));

  texMap : Array [0..mapY, 0..mapX] of Byte =
    (($F, $F, $F, $F, $F, $F, $F, $0),
     ($F, $7, $7, $7, $7, $7, $F, $0),
     ($F, $7, $2, $2, $2, $7, $F, $0),
     ($F, $7, $2, $2, $2, $7, $F, $0),
     ($F, $7, $2, $2, $9, $7, $F, $0),
     ($F, $7, $2, $2, $2, $7, $F, $0),
     ($F, $7, $2, $2, $2, $7, $F, $0),
     ($0, $0, $0, $0, $0, $0, $0, $0));

Var
  lfEdge,
  rtEdge : EdgeScan;
  z, z2  : Integer;

Function fixedDiv(d1, d2 : LongInt) : LongInt; Assembler;
Asm
  db  $66; xor dx, dx
  mov cx, Word ptr D1+2
  or  cx, cx
  jns @S
  db  $66; dec dx
 @S:
  mov dx, cx
  mov ax, Word ptr D1
  db  $66; shl ax, 16
  db  $66; idiv Word ptr d2
  db  $66; mov dx, ax
  db  $66; shr dx, 16
end;

Function div2Fixed(d1, d2 : LongInt) : LongInt; Assembler;
Asm
  db $66; xor dx, dx
  db $66; mov ax, Word ptr d1
  db $66; shl ax, 16
  jns @S
  db $66; dec dx
 @S:
  db $66; idiv Word ptr d2
  db $66; mov dx, ax
  db $66; shr dx, 16
end;

Function divfix(d1, d2 : Integer) : Integer; Assembler;
Asm
  mov  al, Byte ptr d1+1
  cbw
  mov  dx, ax
  xor  al, al
  mov  ah, Byte ptr d1
  idiv d2
end;

Procedure Draw;
Var
  MinY,
  MaxY,
  MinVert,
  MaxVert,
  I, dstY  : Integer;

  Function SetUpEdge(Var Edge : EdgeScan; StartVert : Integer) : Boolean;
  Var
    NextVert   : shortint;
    dstXWidth  : Integer;
    T,
    dstYHeight : fixed;
  begin
    SetUpEdge := True;
    While (StartVert <> MaxVert) Do
    begin
      NextVert := StartVert + Edge.dir;
      if (NextVert >= NumVerts) Then
        NextVert := 0
      else
      if (NextVert < 0) Then
        NextVert := pred(NumVerts);

      With Edge Do
      begin
       scansLeft := vertex[NextVert].Y - vertex[StartVert].Y;
       if (scansLeft <> 0) Then
       begin
         dstYHeight.f  := 0;
         dstYHeight.si := scansLeft;
         Currentend    := NextVert;
         srcX.f  := 0;
         srcX.si := Points[StartVert].X;
         srcY.f  := 0;
         srcY.si := Points[StartVert].Y;
         srcStepX.i := divFix(points[nextVert].x - srcX.si, scansLeft);
         srcStepY.i := divFix(points[nextVert].y - srcY.si, scansLeft);
         dstX       := vertex[StartVert].X;
         dstXWidth  := vertex[NextVert].X-vertex[StartVert].X;

         if (dstXWidth < 0) Then
         begin
           dstXdir     := -1;
           dstXWidth   := -dstXWidth;
           dstXErrTerm := 1 - scansLeft;
           dstXIntStep := -(dstXWidth Div scansLeft);
         end
         else
         begin
           dstXdir     := 1;
           dstXErrTerm := 0;
           dstXIntStep := dstXWidth Div scansLeft;
         end;
         dstXAdjUp   := dstXWidth Mod scansLeft;
         dstXAdjDown := scansLeft;
         Exit;
       end;
       StartVert := NextVert;
      end;
    end;
    SetUpEdge := False;
  end;

  Function StepEdge(Var Edge : EdgeScan) : Boolean;
  begin
    Dec(Edge.scansLeft);
    if (Edge.scansLeft = 0) Then
    begin
      StepEdge := SetUpEdge(Edge, Edge.Currentend);
      Exit;
    end;
    With Edge Do
    begin
      Inc(srcX.i, srcStepX.i);
      Inc(srcY.i, srcStepY.i);
      Inc(dstX, dstXIntStep);
      Inc(dstXErrTerm, dstXAdjUp);
      if (dstXErrTerm > 0) Then
      begin
        Inc(dstX, dstXdir);
        Dec(dstXErrTerm, dstXAdjDown);
      end;
    end;
    StepEdge := True;
  end;

  Procedure ScanOutLine;
  Var
    srcX,
    srcY     : fixed;
    dstX,
    dstXMax  : Integer;
    dstWidth,
    srcXStep,
    srcYStep : fixed;
  begin
    srcX.w  := lfEdge.srcX.w;
    srcY.w  := lfEdge.srcY.w;
    dstX    := lfEdge.dstX;
    dstXMax := rtEdge.dstX;

    if (dstXMax <= ClipMinX) Or (dstX >= ClipMaxX) Then
      Exit;
    dstWidth.f  := 0;
    dstWidth.si := dstXMax - dstX;
    if (dstWidth.i <= 0) Then
      Exit;
    srcXStep.i := divFix(rtEdge.srcX.i - srcX.i, dstWidth.i);
    srcYStep.i := divFix(rtEdge.srcY.i - srcY.i, dstWidth.i);
    if (dstXMax > ClipMaxX) Then
      dstXMax := ClipMaxX;
    if (dstX < ClipMinX) Then
    begin
      Inc(srcX.i, srcXStep.i * (ClipMinX - dstX));
      Inc(srcY.i, srcYStep.i * (ClipMinX - dstX));
      dstX := ClipMinX;
    end;

    Asm
     mov  ax, $A000
     mov  es, ax
     mov  ax, xRes
     mul  dstY
     add  ax, dstX
     mov  di, ax
     mov  cx, dstXMax
     sub  cx, dstX
     mov  bx, srcXStep.i
     mov  dx, srcYStep.i
    @L:
     mov  al, srcY.&si
     xor  ah, ah
     shl  ax, 3
     add  al, srcX.&si
     add  ax, offset texmap
     mov  si, ax
     movsb
     add  srcX.i,bx
     add  srcY.i,dx
     loop @L
     end;
   end;

begin
  if (NumVerts < 3) Then
    Exit;
  MinY := vertex[numVerts - 1].y;
  maxY := vertex[numVerts - 1].y;
  maxVert := numVerts - 1;
  minVert := numVerts - 1;
  For I := numVerts - 2 downto 0 Do
  begin
    if (vertex[I].Y < MinY) Then
    begin
      MinY    := vertex[I].Y;
      MinVert := I;
    end;
    if (vertex[I].Y > MaxY) Then
    begin
      MaxY    := vertex[I].Y;
      MaxVert := I;
    end;
  end;
  if (MinY >= MaxY) Then
    Exit;
  dstY := MinY;
  lfEdge.dir := -1;
  SetUpEdge(lfEdge, MinVert);
  rtEdge.dir := 1;
  SetUpEdge(rtEdge, MinVert);
  While (dstY < ClipMaxY) Do
  begin
    if (dstY >= ClipMinY) Then
      ScanOutLine;
    if Not StepEdge(lfEdge) Then
      Exit;
    if Not StepEdge(rtEdge) Then
      Exit;
    Inc(dstY);
  end;
end;

begin
  directVideo := False;
  TextAttr    := 63;
  { For z:=0 to mapY do For z2:=0 to mapx do texMap[z,z2]:=random(6+53);}
  For z := 4 to 38 do
  begin
    clearGraph;
    vertex[0].x := z * 4;
    vertex[3].x := z * 4;
    draw;
    if KeyPressed then
    begin
      ReadKey;
      ReadKey;
    end;
  end;
  readln;
end.

