{
This unit draws polygons fast. It draws only polygons which are monotone
vertical. That means only polygons which you can fill with continues horizontal
lines. Fortunately that are the polygons which are mostly used in 3d graphics.
}

{*****************************************************************}
{* UnitName    : FASTPOLY.PAS                                    *}
{* Purpose     : Draw monotone vertical polygons fast            *}
{* Version     : 1.5                                             *}
{* Author      : Daan de Haas                                    *}
{* Date        : 20/10/1993                                      *}
{* Last update :  9/06/1994                                      *}
{* Language    : Borland Turbo Pascal 7.0                        *}
{* Fidonet     : Daan de Haas (2:500/104.6141)                   *}
{* Internet    : Daan.de.Haas@p6141.f104.n500.z2.fidonet.org     *}
{*****************************************************************}

{* VGA mode $13 and 386 processor *}
{* Literatur : Dr Dobb's XSharp   *}

{$R-,S-,Q-,I-}

UNIT FastPoly;

{**************************} INTERFACE {**************************}

TYPE
  PPoint = ^TPoint;
  TPoint = RECORD
             x,y:integer;
           END;
  PPolygon = ^TPolygon;
  PPointsList = ^TPointsList;
  TPointsList = ARRAY[0..9999] OF TPoint;
  TPolygon = RECORD
               length,color:word;
               PointPtr:PPointsList;
             END;
  PHLine = ^THLine;
  THLine = RECORD
             XStart,XEnd:word;
           END;
  PHLineArray = ^THLineArray;
  THLineArray = ARRAY[0..9999] OF THLine;
  THLineList = RECORD
                 length,YStart:integer;
                 HLinePtr : PHLineArray;
               END;

PROCEDURE HLine(x1,y1,x2:word; color:word);
PROCEDURE InitPoly(VAR p:TPolygon; len,col:word);
PROCEDURE DonePoly(VAR p:TPolygon);
PROCEDURE FillMonotoneVerticalPolygon(XOffset,YOffset:word;
                                      VertexList:TPolygon);

CONST
  MaxX=320;
  MaxY=200;
  VidSegment=$A000;

{************************} IMPLEMENTATION {***********************}

PROCEDURE HLine; ASSEMBLER;
ASM
  mov ax,x1             { x1 < x2 }
  cmp ax,x2
  jl  @@skip1
  je  @@lijnexit
  xchg ax,x2
  mov  x1,ax
@@skip1:
  mov ax,maxX           { calculate y1*maxX+x1 }
  mul y1
  add ax,x1
@@1:
  mov di,ax             { dx=segment, di=offset }
  mov ax,VidSegment

@@skip2:
  cld                   { forward direction }
  mov cx,x2
  sub cx,x1
  inc cx                { cx = number of pixels in line }
  mov dx,di
  add dx,cx
  mov es,ax             { load segment register }
  mov ax,color          { get color into 386 register eax }
  mov ah,al
  mov dx,ax
  db  $66,$c1,$e0,$10   { shl eax,16 (386 code) }
  mov ax,dx
  test di,00000011b
  jz @@skip             { test for doubleword border, if so jump }
@@waitdd:
  mov  es:[di],al       { put one pixel }
  inc  di               { di:=next pixel address }
  test di,00000011b     { doubleword border  ? }
  loopnz @@waitdd       { stop if cx=0 or zeroflag 1 }
  or  cx,cx             { cx=0 ? }
  jz  @@lijnexit        { if so, line is ready }
  cmp cx,4              { is a stosd possible ? }
  jl  @@waitdd          { no, then pixel after pixel }
@@skip:
  mov  dx,cx
  shr  cx,2
  db   $f3,$66,$AB      { rep stosd (386 code) }
  mov  cx,dx
  and cx,00000011b      { line finished ? }
  jnz @@waitdd
@@lijnexit:
END;

PROCEDURE ScanEdge(x1,y1,x2,y2,SetXStart,SkipFirst:integer;
                   VAR EdgePointPtr:PHLineArray); ASSEMBLER;
{ Scan converts an edge from (X1,Y1) to (X2,Y2), not including the
 point at (X2,Y2). If SkipFirst == 1, the point at (X1,Y1) isn't
 drawn; if SkipFirst == 0, it is. For each scan line, the pixel
 closest to the scanned edge without being to the left of the scanned
 edge is chosen. Uses an all-integer approach for speed & precision.

 Edges must not go bottom to top; that is, Y1 must be <= Y2.
 Updates the pointer pointed to by EdgePointPtr to point to the next
 free entry in the array of HLine structures. }

VAR
  AdvanceAmt,Height:word;

ASM
 les di,EdgePointPtr
 les di,es:[di]  { point to the HLine array }
 cmp SetXStart,1      { set the XStart field of each HLine
     { struc? }
 jz @@HLinePtrSet  { yes, DI points to the first XStart }
 add di,2   { no, point to the XEnd field of the }
     {  first HLine struc }
@@HLinePtrSet:
 mov bx,Y2
 sub bx,Y1         { edge height }
 jle @@ToScanEdgeExit{ guard against 0-length & horz edges }
 mov Height,bx { Height = Y2 - Y1 }
 sub cx,cx  { assume ErrorTerm starts at 0 (true if }
                                {  we're moving right as we draw) }
 mov dx,1  { assume AdvanceAmt = 1 (move right) }
 mov ax,X2
 sub ax,X1           { DeltaX = X2 - X1 }
        jz      @@IsVertical   { it's a vertical edge--special case it }
 jns @@SetAdvanceAmt { DeltaX >= 0 }
 mov cx,1  { DeltaX < 0 (move left as we draw) }
 sub cx,bx  { ErrorTerm = -Height + 1 }
 neg dx  { AdvanceAmt = -1 (move left) }
        neg     ax              { Width = abs(DeltaX) }
@@SetAdvanceAmt:
 mov AdvanceAmt,dx
{ Figure out whether the edge is diagonal, X-major (more horizontal), }
{ or Y-major (more vertical) and handle appropriately. }
 cmp ax,bx  { if Width==Height, it's a diagonal edge }
 jz @@IsDiagonal { it's a diagonal edge--special case }
 jb @@YMajor { it's a Y-major (more vertical) edge }
    { it's an X-major (more horz) edge }
        sub     dx,dx           { prepare DX:AX (Width) for division }
        div     bx  { Width/Height }
    { DX = error term advance per scan line }
 mov si,ax  { SI = minimum # of pixels to advance X }
    { on each scan line }
        test    AdvanceAmt,8000h { move left or right? }
        jz      @@XMajorAdvanceAmtSet   { right, already set }
        neg     si              { left, negate the distance to advance }
    { on each scan line }
@@XMajorAdvanceAmtSet:
 mov ax,X1  { starting X coordinate }
        cmp     SkipFirst,1 { skip the first point? }
        jz @@XMajorSkipEntry  { yes }
@@XMajorLoop:
 mov es:[di],ax  { store the current X value }
 add di,4     { point to the next HLine struc }
@@XMajorSkipEntry:
 add ax,si  { set X for the next scan line }
 add cx,dx  { advance error term }
 jle @@XMajorNoAdvance { not time for X coord to advance one }
    { extra }
 add ax,AdvanceAmt { advance X coord one extra }
        sub     cx,Height     { adjust error term back }
@@XMajorNoAdvance:
        dec     bx  { count off this scan line }
        jnz     @@XMajorLoop
 jmp @@ScanEdgeDone
@@ToScanEdgeExit:
 jmp @@ScanEdgeExit
@@IsVertical:
 mov ax,X1 { starting (and only) X coordinate }
 sub bx,SkipFirst { loop count = Height - SkipFirst }
        jz      @@ScanEdgeExit  { no scan lines left after skipping 1st }
@@VerticalLoop:
 mov es:[di],ax  { store the current X value }
 add di,4 { point to the next HLine struc }
 dec bx  { count off this scan line }
 jnz @@VerticalLoop
 jmp @@ScanEdgeDone
@@IsDiagonal:
 mov ax,X1 { starting X coordinate }
        cmp     SkipFirst,1 { skip the first point? }
 jz @@DiagonalSkipEntry { yes }
@@DiagonalLoop:
 mov es:[di],ax  { store the current X value }
 add di,4 { point to the next HLine struc }
@@DiagonalSkipEntry:
 add ax,dx  { advance the X coordinate }
 dec bx  { count off this scan line }
 jnz @@DiagonalLoop
 jmp @@ScanEdgeDone

@@YMajor:
 push bp { preserve stack frame pointer }
 mov si,X1  { starting X coordinate }
        cmp     SkipFirst,1 { skip the first point? }
 mov bp,bx { put Height in BP for error term calcs }
        jz @@YMajorSkipEntry { yes, skip the first point }
@@YMajorLoop:
 mov es:[di],si { store the current X value }
 add di,4 { point to the next HLine struc }
@@YMajorSkipEntry:
 add cx,ax  { advance the error term }
 jle @@YMajorNoAdvance { not time for X coord to advance }
 add si,dx  { advance the X coordinate }
        sub     cx,bp  { adjust error term back }
@@YMajorNoAdvance:
        dec     bx  { count off this scan line }
        jnz     @@YMajorLoop
 pop bp  { restore stack frame pointer }
@@ScanEdgeDone:
 cmp SetXStart,1 { were we working with XStart field? }
 jz @@UpdateHLinePtr { yes, DI points to the next XStart  }
 sub di,2  { no, point back to the XStart field }
@@UpdateHLinePtr:
        mov     bx,word ptr EdgePointPtr { point to pointer to HLine array }
 mov ss:[bx],di  { update caller's HLine array pointer }
@@ScanEdgeExit:
END;

PROCEDURE DrawHorizontalLineList(VAR list:THLineList; color:word); ASSEMBLER;
ASM
  les si,list
  mov cx,es:[si]                { cx = number of lines }
  mov ax,es:[si+2]              { ax = startY }
  les si,es:[si+4]              { es:si points to pointlist }
@@loop:
  mov bx,es:[si]                { get startX }
  mov dx,es:[si+2]              { get endX }
  push cx                       { save registers }
  push ax
  push si
  push es

  push bx                       { draw horizontal line }
  push ax
  push dx
  mov  dx,color                 { get color }
  push dx
  call HLine

  pop es                        { restore registers }
  pop si
  pop ax
  pop cx
  inc ax                        { y:=y+1 }
  add si,4                      { next points }
  loop @@loop                   { if length=0 then stop }
END;

PROCEDURE FillMonotoneVerticalPolygon;
VAR
  i,MinIndex,MaxIndex,MinPoint_y,MaxPoint_y,NextIndex,
  CurrentIndex,PreviousIndex:integer;
  WorkingHLineList:THLineList;
  EdgePointPtr:PHLineArray;
  VertexPtr:PPointsList;
BEGIN
  IF VertexList.Length=0 THEN Exit;
  VertexPtr:=VertexList.PointPtr;
  MaxPoint_y:=VertexPtr^[0].y;
  MinPoint_y:=MaxPoint_y;
  MinIndex:=0;
  MaxIndex:=0;
  FOR i:=1 TO VertexList.Length-1 DO
    WITH VerTexPtr^[i] DO
      IF y<MinPoint_y THEN
        BEGIN
          MinPoint_y:=y;
          MinIndex:=i;
        END
      ELSE
        IF y>MaxPoint_y THEN
          BEGIN
            MaxPoint_y:=y;
            MaxIndex:=i;
          END;
  WITH WorkingHLineList DO
    BEGIN
      length:=MaxPoint_y-MinPoint_y;
      IF length<=0 THEN Exit;
      YStart:=YOffset+MinPoint_y;
      GetMem(HLinePtr,SizeOf(THLine)*length);
      EdgePointPtr:=HLinePtr;
    END;
  CurrentIndex:=MinIndex;
  PreviousIndex:=MinIndex;
  REPEAT
    CurrentIndex:=(CurrentIndex+VertexList.length-1) MOD VertexList.length;
    ScanEdge(VertexPtr^[PreviousIndex].x+XOffset,
             VertexPtr^[PreviousIndex].y,
             VertexPtr^[CurrentIndex].x+XOffset,
             VertexPtr^[CurrentIndex].y,
             1,0,EdgePointPtr);
    PreviousIndex:=CurrentIndex;
  UNTIL CurrentIndex=MaxIndex;
  EdgePointPtr:=WorkingHLineList.HLinePtr;
  CurrentIndex:=MinIndex;
  PreviousIndex:=MinIndex;
  REPEAT
    CurrentIndex:=(CurrentIndex+1) MOD VertexList.length;
    ScanEdge(VertexPtr^[PreviousIndex].x+XOffset,
             VertexPtr^[PreviousIndex].y,
             VertexPtr^[CurrentIndex].x+XOffset,
             VertexPtr^[CurrentIndex].y,
             0,0,EdgePointPtr);
    PreviousIndex:=CurrentIndex;
  UNTIL CurrentIndex=MaxIndex;
  DrawHorizontalLineList(WorkingHLineList,VertexList.color);
  WITH WorkingHLineList DO FreeMem(HLinePtr,SizeOf(THLine)*length);
END;

PROCEDURE InitPoly;
BEGIN
  WITH p DO
    BEGIN
      length:=len;
      color:=col;
      { No Error checking !}
      GetMem(PointPtr,len*SizeOf(TPoint));
    END;
END;

PROCEDURE DonePoly;
BEGIN
  WITH p DO
    BEGIN
      IF PointPtr<>NIL THEN FreeMem(PointPtr,length*SizeOf(TPoint));
      PointPtr:=NIL;
    END;
END;

END.

{*****************************************************************}
{* ProgramName : FASTPOL.PAS                                     *}
{* Purpose     : Demonstration of unit FastPoly                  *}
{* Version     : 1.0                                             *}
{* Author      : Daan de Haas                                    *}
{* Date        : 9 jun 1994                                      *}
{* Last update : 9 jun 1994                                      *}
{* Language    : Borland Pascal 7.0                              *}
{* Fidonet     : Daan de Haas (2:500/104.6141)                   *}
{* Internet    : Daan.de.Haas@p6141.f104.n500.z2.fidonet.org     *}
{*****************************************************************}

{$R-,I-,Q-,S-}

USES
  Crt, FastPoly;

PROCEDURE SetVideo(m:word); ASSEMBLER;
ASM
  mov ax,m
  int $10
END;

PROCEDURE Polydemo;
VAR
  p1,p2:TPolygon;
BEGIN
  InitPoly(p1,6,YELLOW);
  p1.PointPtr^[0].X:=10;
  p1.PointPtr^[0].Y:=0;
  p1.PointPtr^[1].X:=20;
  p1.PointPtr^[1].Y:=0;
  p1.PointPtr^[2].X:=30;
  p1.PointPtr^[2].Y:=10;
  p1.PointPtr^[3].X:=20;
  p1.PointPtr^[3].Y:=20;
  p1.PointPtr^[4].X:=10;
  p1.PointPtr^[4].Y:=20;
  p1.PointPtr^[5].X:=0;
  p1.PointPtr^[5].Y:=10;
  InitPoly(p2,6,BLUE);
  p2.PointPtr^[0].X:=10;
  p2.PointPtr^[0].Y:=0;
  p2.PointPtr^[1].X:=20;
  p2.PointPtr^[1].Y:=0;
  p2.PointPtr^[2].X:=30;
  p2.PointPtr^[2].Y:=10;
  p2.PointPtr^[3].X:=20;
  p2.PointPtr^[3].Y:=20;
  p2.PointPtr^[4].X:=10;
  p2.PointPtr^[4].Y:=20;
  p2.PointPtr^[5].X:=0;
  p2.PointPtr^[5].Y:=10;
  REPEAT
    FillMonotoneVerticalPolygon(Random(MaxX-35),Random(MaxY-25),p1);
    FillMonotoneVerticalPolygon(Random(MaxX-35),Random(MaxY-25),p2);
  UNTIL KeyPressed;
  ReadKey;
  DonePoly(p1);
  DonePoly(p2);
END;

BEGIN
  ClrScr;
  Randomize;
  SetVideo($13);
  PolyDemo;
  SetVideo(3);
END.
