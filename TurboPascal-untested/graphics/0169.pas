{
Here is a re-vamped version of my texture mapper. Code has been used from
several sources. The texture mapper is mine. The rotation code is from
Bas van Gaalan (look like anything from GFXFX? :). The whole thing was
thrown together by Daniel Wakefield (including some conversion of my texture
maper to ASM). I hope everyone finds this useful. The texture mapper it self
isn't very good, but it gives you an idea of how it can be done (if you
want source for a good texture mapper, register GFXFX2!!).

Without further delay.....

{ -------------- Begin Code -----------------}

{$r-,g+}
program texure_poly;
uses crt;

Type TE = Record  X : Integer; px, py : Byte; End;
  Table = Array[0..199] of TE; PTable = ^Table;

Var
  Left, Right : Table;  stab:array[0..255] of integer;
  polyz:array[0..7] of integer; pind:array[0..7] of byte;
  page,virscr:pointer; pageseg,virseg:word; Frame, St, Et : Longint;
  Time : Longint Absolute $0000:$046c; pxVal, pxStep : Integer;
  pyVal, pyStep : Integer; Count, res : Integer; O1 : Word; b:byte;

Const
  Bitmap :Array[0..16*16-1] of Byte = (
  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,5,5,5,5,5,5,5,5,5,5,5,5,5,5,2,
  2,5,5,1,1,1,1,1,1,1,1,1,1,5,5,2,2,5,1,5,1,1,1,1,1,1,1,1,5,1,5,2,
  2,5,1,1,5,1,1,1,1,1,1,5,1,1,5,2,2,5,1,1,1,5,1,1,1,1,5,1,1,1,5,2,
  2,5,1,1,1,1,5,1,1,5,1,1,1,1,5,2,2,5,1,1,1,1,1,5,5,1,1,1,1,1,5,2,
  2,5,1,1,1,1,1,5,5,1,1,1,1,1,5,2,2,5,1,1,1,1,5,1,1,5,1,1,1,1,5,2,
  2,5,1,1,1,5,1,1,1,1,5,1,1,1,5,2,2,5,1,1,5,1,1,1,1,1,1,5,1,1,5,2,
  2,5,1,5,1,1,1,1,1,1,1,1,5,1,5,2,2,5,5,1,1,1,1,1,1,1,1,1,1,5,5,2,
  2,5,5,5,5,5,5,5,5,5,5,5,5,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2);
  pointnum=11; planenum=7; border=false; vidseg:word=$a000;
  divd=128; dist=200; points:array[0..pointnum,0..2] of integer=(
    (-20,-20, 30),( 20,-20, 30),( 40,-40,  0),( 20,-20,-30),
    (-20,-20,-30),(-40,-40,  0),(-20, 20, 30),( 20, 20, 30),
    ( 40, 40,  0),( 20, 20,-30),(-20, 20,-30),(-40, 40,  0));
  planes:array[0..planenum,0..3] of byte=(
    (1,2,8,7),(9,8,2,3),(10,4,5,11),(6,11,5,0),
    (0,1,2,5),(5,2,3,4),(6,7,8,11),(11,8,9,10));
{ -------------------------------------------------------------------------- }
Procedure TextureHLine(X1, X2, px1, py1, px2, py2, Y : Integer; Dim : Word);
 Begin pxStep := ((px2-px1) Shl 8) Div (x2-x1+1);
  pyStep := ((py2-py1) Shl 8) Div (x2-x1+1);
  asm
   mov     bx, px1; shl bx, 8; mov pxval,bx;  {  pxVal := px1 Shl 8;}
   mov     bx, py1; shl bx, 8; mov pyval,bx;  {  pyVal := py1 Shl 8;}
   mov     ax,y; shl     ax,6; mov     di,ax; shl     ax,2
   add     di,ax; add     di,x1; mov     o1, di; End;
  For Count := X1 to X2 do
    Begin
     b:= Bitmap[Hi(pxVal)+(Hi(pyVal)) Shl 4];
     Asm mov ax,virseg; mov es,ax; mov ax,o1; mov di,ax; mov al, b;
      mov es:[di],al; mov ax, pxval; add ax, pxstep;mov pxval, ax;
      mov ax, pyval; add ax, pystep; mov pyval, ax; inc o1; end;
    End; ; End;

Procedure Swap(Var A, B : Integer);
Var t : Integer; Begin t := a; a := b; b := t; End;

Procedure Texture4Poly(X1, Y1, X2, Y2, X3, Y3, X4, Y4 : Integer; Dim : Byte);
Var yMin, yMax : Integer; xStart, xEnd : Integer; yStart, yEnd : Integer;
  pxStart, pxEnd : Integer; pyStart,pyEnd  : Integer; XVal, XStep : Longint;
  pxVal, pxStep : Integer; pyVal, pyStep : Integer; Count : Integer;
  Side : PTable;
Begin
  yMin := Y1; yMax := Y1;
  If Y2 > yMax Then yMax := Y2; If Y3 > yMax Then yMax := Y3;
  If Y4 > yMax Then yMax := Y4; If Y2 < yMin Then yMin := Y2;
  If Y3 < yMin Then yMin := Y3; If Y4 < yMin Then yMin := Y4;
  xStart := X1; yStart := Y1; xEnd := X2; yEnd := Y2;
  pxStart := 0; pyStart := 0; pxEnd := Dim-1; pyEnd := 0;
  If yStart > yEnd Then Begin
      Swap(xStart, xEnd); Swap(yStart, yEnd); Swap(pxStart, pxEnd);
      Side := @Left; End Else Side := @Right;
  XVal := Longint(xStart) Shl 8;
  XStep := (Longint(xEnd-xStart) Shl 8) Div (yEnd-yStart+1);
  pxVal := pxStart Shl 8;
  pxStep := ((pxEnd-pxStart) Shl 8) Div (yEnd-yStart+1);
  For Count := yStart to yEnd do
    Begin Side^[Count].x := XVal Shr 8; Side^[Count].px := pxVal Shr 8;
      Side^[Count].py := pyStart; XVal := XVal + XStep;
      pxVal := pxVal + pxStep; End;
  xStart := X2; yStart := Y2; xEnd := X3; yEnd := Y3;
  pxStart := Dim-1; pyStart := 0; pxEnd := Dim-1; pyEnd := Dim-1;
  If yStart > yEnd Then Begin Swap(xStart, xEnd); Swap(yStart, yEnd);
      Swap(pyStart, pyEnd); Side := @Left; End Else Side := @Right;
  XVal := Longint(xStart) Shl 8;
  XStep := (Longint(xEnd-xStart) Shl 8) Div (yEnd-yStart+1);
  pyVal := pyStart Shl 8;
  pyStep := ((pyEnd-pyStart) Shl 8) Div (yEnd-yStart+1);
  For Count := yStart to yEnd do
    Begin Side^[Count].x := XVal Shr 8; Side^[Count].py := pyVal Shr 8;
      Side^[Count].px := pxStart; XVal := XVal + XStep;
      pyVal := pyVal + pyStep; End;
  xStart := X3; yStart := Y3; xEnd := X4; yEnd := Y4;
  pxStart := Dim-1; pyStart := Dim-1; pxEnd := 0; pyEnd := Dim-1;
  If yStart > yEnd Then Begin Swap(xStart, xEnd); Swap(yStart, yEnd);
      Swap(pxStart, pxEnd); Side := @Left; End Else Side := @Right;
  XVal := Longint(xStart) Shl 8;
  XStep := (Longint(xEnd-xStart) Shl 8) Div (yEnd-yStart+1);
  pxVal := pxStart Shl 8;
  pxStep := ((pxEnd-pxStart) Shl 8) Div (yEnd-yStart+1);
  For Count := yStart to yEnd do
    Begin Side^[Count].x := XVal Shr 8; Side^[Count].px := pxVal Shr 8;
      Side^[Count].py := pyStart; XVal := XVal + XStep;
      pxVal := pxVal + pxStep; End;
  xStart := X4; yStart := Y4;xEnd := X1; yEnd := Y1;
  pxStart := 0;  pyStart := Dim-1; pxEnd := 0; pyEnd := 0;
  If yStart > yEnd
    Then Begin Swap(xStart, xEnd); Swap(yStart, yEnd);
      Swap(pyStart, pyEnd); Side := @Left; End
    Else Side := @Right;
  XVal := Longint(xStart) Shl 8;
  XStep := (Longint(xEnd-xStart) Shl 8) Div (yEnd-yStart+1);
  pyVal := pyStart Shl 8;
  pyStep := ((pyEnd-pyStart) Shl 8) Div (yEnd-yStart+1);
  For Count := yStart to yEnd do
    Begin Side^[Count].x := XVal Shr 8; Side^[Count].py := pyVal Shr 8;
      Side^[Count].px := pxStart; XVal := XVal + XStep;
      pyVal := pyVal + pyStep; End;
  For Count := yMin to yMax do
    If Left[Count].x < Right[Count].x
      Then TextureHLine(Left[Count].x, Right[Count].x, Left[Count].px, Left[Count].py,
              Right[Count].px, Right[Count].py, Count, Dim)
      Else TextureHLine(Right[Count].x, Left[Count].x, Right[Count].px, Right[Count].py,
              Left[Count].px, Left[Count].py, Count, Dim);
End;

procedure setpal(c,r,g,b:byte); assembler;
asm; mov dx,3c8h; mov al,[c]; out dx,al; inc dx; mov al,[r]; out dx,al
  mov al,[g]; out dx,al; mov al,[b]; out dx,al; end;

procedure flip(src,dst:word); assembler; asm
push ds; mov es,[dst]; mov ds,[src]; xor si,si; xor di,di; mov cx,320*200/2
rep movsw; pop ds; end;

procedure quicksort(lo,hi:integer);

procedure sort(l,r:integer);
var i,j,x,y:integer;
begin
  i:=l; j:=r; x:=polyz[(l+r) div 2];
  repeat
    while polyz[i]<x do inc(i); while x<polyz[j] do dec(j);
    if i<=j then begin y:=polyz[i]; polyz[i]:=polyz[j]; polyz[j]:=y;
      y:=pind[i]; pind[i]:=pind[j]; pind[j]:=y; inc(i); dec(j); end;
  until i>j; if l<j then sort(l,j); if i<r then sort(i,r);
end;
begin sort(lo,hi); end;

function sinus(i:byte):integer; begin sinus:=stab[i]; end;
function cosinus(i:byte):integer; begin cosinus:=stab[(i+192) mod 255]; end;

procedure rotate_cube;
const xst=2; yst=3; zst=-4;
var
  xp,yp,z:array[0..11] of integer;
  x,y,i,j,k:integer;
  n,Key,phix,phiy,phiz:byte;
begin
  phix:=0; phiy:=0; phiz:=40; fillchar(xp,sizeof(xp),0);
  fillchar(yp,sizeof(yp),0); Frame := 0; St := Time;
  repeat
    flip(pageseg,virseg);
    for n:=0 to pointnum do begin
      i:=(cosinus(phiy)*points[n,0]-sinus(phiy)*points[n,2]) div divd;
      j:=(cosinus(phiz)*points[n,1]-sinus(phiz)*i) div divd;
      k:=(cosinus(phiy)*points[n,2]+sinus(phiy)*points[n,0]) div divd;
      x:=(cosinus(phiz)*i+sinus(phiz)*points[n,1]) div divd;
      y:=(cosinus(phix)*j+sinus(phix)*k) div divd;
      z[n]:=(cosinus(phix)*k-sinus(phix)*j) div divd+cosinus(phix) div 3;
      xp[n]:=160+sinus(phix) div 2+(-x*dist) div (z[n]-dist);
      yp[n]:=100+(-y*dist) div (z[n]-dist);
    end;
    for n:=0 to planenum do begin
      polyz[n]:=(z[planes[n,0]]+z[planes[n,2]]) div 2; pind[n]:=n; end;
    quicksort(0,planenum);
    for n:=0 to planenum do
      texture4poly(xp[planes[pind[n],0]],yp[planes[pind[n],0]],
                   xp[planes[pind[n],1]],yp[planes[pind[n],1]],
                   xp[planes[pind[n],2]],yp[planes[pind[n],2]],
                   xp[planes[pind[n],3]],yp[planes[pind[n],3]],16);
    inc(phix,xst); inc(phiy,yst); inc(phiz,zst); flip(virseg,vidseg);
    inc(frame); until keypressed; Et:=time; end;

var i,j:word;
begin
  asm mov ax,13h; int 10h; end;
  getmem(virscr,64000);
  virseg:=seg(virscr^);
  getmem(page,64000);
  pageseg:=seg(page^);
  for i:=0 to 255 do stab[i]:=round(sin(i*pi/128)*divd);
  for i:=1 to 104 do setpal(150+i,0,20+i div 4,30+i div 5);
  for i:=0 to 319 do for j:=0 to 199 do mem[pageseg:j*320+i]:=151+(i*i+j*j) mod
104;
  rotate_cube;
  freemem(page,64000);
  freemem(virscr,64000);
  textmode(lastmode);
  Writeln(Frame*18.2/(Et-St):5:2, ' fps');
end.

