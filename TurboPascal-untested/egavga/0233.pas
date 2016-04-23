Unit tgr12; {tiny Graph 12- Oct 4/1994 by Wil Barath}
 { (C) 1994, persission granted for free use in freeware programs, and
   licensed for use in any other program that gives me visible credit }
Interface{} Const FBold=$01;FItalic=$02;FULine=$04;FShadow=$08;
  FOLine=$10;FTiny=$20;Shadow:Byte=$08;OutLine:Byte=$00;
  FontScaleS:Byte=$11;PageOffset:Word=0;
Type pFntArray = ^FntArray;FntArray = Array[0..1] of byte;
Type Fixed= Record F:Word;W:Integer;end;
Var F8x8:FntArray absolute $f000:$fa6e;time:Word Absolute $0040:$006c;
Procedure VideoMode(mode:word); procedure SetRGB(n,r,g,b:byte);
procedure SetStart(p:word);     Function AllocMem(pages:Word):Word;
Procedure FreeMem(s:Word);      Function MouseStatus:LongInt;
Function MouseAt(Var X:Word;Var y:Word):Word;
Function Readkey:Char;          Function Keypressed:Boolean;
Procedure WaitHBL;              Procedure WaitVBL;
procedure setColor(c:Word);     procedure pset(x,y:word);
procedure Vline(x,y,dy:word);   procedure Hline(x,y,d:Word);
Procedure Line(x1,y1,x2,y2:Integer);
procedure circle(cx,cy,r:Integer);
procedure Disc(x,y,r:Integer);
procedure clrgraph(c:Word);
Procedure OutTextXY(s:String;x,y:Integer;C:Byte;Style:Byte);
Function SQRoot(n:LongInt):Word;Procedure CharSet_5P;
Implementation{}
Procedure CharSet_5P;assembler;asm
db 00100000b,00100000b,00100000b,00000000b,00100000b{!}
db 01010000b,01010000b,00000000b,00000000b,00000000b{"}
db 01010000b,11111000b,01010000b,11111000b,01010000b{#}
db 00100000b,01110000b,01100000b,00110000b,01110000b{etc.}
db 11001000b,11010000b,00100000b,01011000b,10011000b
db 01100000b,01101000b,01110000b,10010000b,01101000b
db 00100000b,00100000b,00000000b,00000000b,00000000b
db 00010000b,00100000b,00100000b,00100000b,00010000b
db 01000000b,00100000b,00100000b,00100000b,01000000b
db 10101000b,01110000b,00100000b,01110000b,10101000b
db 00100000b,00100000b,11111000b,00100000b,00100000b
db 00000000b,00000000b,00000000b,00100000b,01000000b
db 00000000b,00000000b,11111000b,00000000b,00000000b
db 00000000b,00000000b,00000000b,00000000b,00100000b
db 00001000b,00010000b,00100000b,01000000b,10000000b
db 01110000b,10001000b,10001000b,10001000b,01110000b
db 00010000b,00110000b,00010000b,00010000b,00111000b
db 01110000b,00001000b,01110000b,10000000b,11111000b
db 11110000b,00001000b,01110000b,00001000b,11110000b
db 00010000b,10010000b,11110000b,00010000b,00010000b
db 11110000b,10000000b,11110000b,00001000b,11110000b
db 01110000b,10000000b,11110000b,10001000b,01110000b
db 01111000b,00001000b,00010000b,00100000b,00100000b
db 01110000b,10001000b,01110000b,10001000b,01110000b
db 01110000b,10001000b,01111000b,00001000b,01110000b
db 00000000b,00100000b,00000000b,00100000b,00000000b
db 00000000b,00100000b,00000000b,00100000b,01000000b
db 00010000b,00100000b,01000000b,00100000b,00010000b
db 00000000b,11111000b,00000000b,11111000b,00000000b
db 01000000b,00100000b,00010000b,00100000b,01000000b
db 01110000b,00001000b,00110000b,00000000b,00100000b
db 01110000b,10111000b,10111000b,10000000b,01110000b
db 01110000b,10001000b,11111000b,10001000b,10001000b{A}
db 11110000b,10001000b,11110000b,10001000b,11110000b{B}
db 01110000b,10000000b,10000000b,10000000b,01110000b{C}
db 11110000b,10001000b,10001000b,10001000b,11110000b{etc.}
db 11111000b,10000000b,11110000b,10000000b,11111000b
db 11111000b,10000000b,11110000b,10000000b,10000000b
db 01111000b,10000000b,10111000b,10001000b,01111000b
db 10001000b,10001000b,11111000b,10001000b,10001000b
db 11111000b,00100000b,00100000b,00100000b,11111000b
db 01111000b,00010000b,00010000b,10010000b,01100000b
db 10001000b,10010000b,11100000b,10010000b,10001000b
db 10000000b,10000000b,10000000b,10000000b,11111000b
db 10001000b,11011000b,10101000b,10001000b,10001000b
db 10001000b,11001000b,10101000b,10011000b,10001000b
db 01110000b,10001000b,10001000b,10001000b,01110000b
db 11110000b,10001000b,11110000b,10000000b,10000000b
db 01110000b,10001000b,10101000b,10011000b,01111000b
db 11110000b,10001000b,11110000b,10010000b,10001000b
db 01110000b,10000000b,01110000b,00001000b,01110000b
db 11111000b,00100000b,00100000b,00100000b,00100000b
db 10001000b,10001000b,10001000b,10001000b,01110000b
db 10001000b,10001000b,01010000b,01010000b,00100000b
db 10001000b,10001000b,10101000b,11011000b,10001000b
db 10001000b,01010000b,00100000b,01010000b,10001000b
db 10001000b,10001000b,01111000b,00001000b,01110000b
db 11111000b,00010000b,00100000b,01000000b,11111000b
db 01110000b,01000000b,01000000b,01000000b,01110000b
db 10000000b,01000000b,00100000b,00010000b,00001000b
db 01110000b,00010000b,00010000b,00010000b,01110000b
db 00100000b,01010000b,00000000b,00000000b,00000000b
db 00000000b,00000000b,00000000b,00000000b,11111100b;end;
Procedure VideoMode(mode:word);assembler;Asm Mov ax,mode;Int 10h;end;
procedure SetRGB(n,r,g,b:byte);assembler;asm Mov dx,03c8h;Mov al,n;
Out dx,al;Inc dx;Mov al,r;Out dx,al;Mov al,g;Out dx,al;Mov al,b;Out dx,al;end;
procedure SetStart(p:word);assembler;asm Mov dx,$3d4;Mov bx,p;Mov al,$c;
Mov ah,bh;Out dx,ax;Inc al;Mov ah,bl;Out dx,ax;Mov PageOffset,bx;end;
Function AllocMem(pages:Word):Word;assembler;{allocates pages*16 bytes}
asm mov ah,$48;mov bx,pages;int $21;jnc @ok;xor ax,ax;@ok:end;
Procedure FreeMem(s:Word);assembler;{frees mem at Ptr(s:$00)}
asm mov ah,$49;mov es,s;int $21; end;
Function MouseStatus:LongInt;Assembler;asm Xor ax,ax;Int 33h;end;
Function MouseAt(Var X:Word;Var y:Word):Word;assembler;asm Mov ax,03h;
Int 33h;Les di,x;Mov ES:[DI],cx;Les di,y;Mov ES:[DI],dx;Mov ax,bx;end;
Function Readkey:Char;Assembler;asm Xor ax,ax;Int 16h;end;
Function Keypressed:Boolean;Assembler;asm Mov ax,0100h;int 16h;Jnz @1;
Xor ax,ax;@1:end;
Procedure WaitHBL;assembler;asm Mov dx,03dah;@1:In al,dx;test al,01h;
Jnz @1;@2:In al,dx;test al,01h;Jz @2;end;
Procedure WaitVBL;assembler;asm Mov dx,03dah;@1:In al,dx;test al,08h;
Jz @1;@2:In al,dx;test al,08h;Jnz @2;end;
Procedure SetColor(c:Word);assembler;asm Mov dx,$3ce;Xor al,al;Mov ah,c.byte;
And ah,$0f;Out dx,ax;Mov ax,$0f01;Out dx,ax;Mov al,$08;Out dx,al;end;
Procedure PSET(x,y:Word);assembler;asm Mov es,SegA000;Mov bx,x;Mov cx,bx;
Mov ax,80;Mul Y;SHR bx,3;Add bx,ax;And cl,$07;Mov al,$80;Shr al,cl;
Mov dx,$3cf;Out dx,al;Mov ah,$ff;Add bx,pageoffset;Or es:[bx],ah;end;
Procedure Vline(x,y,dy:Word);assembler;asm Push x;Push y;Call PSet;
Mov cx,dy;Mov di,80;@Loop:Add bx,di;Or es:[bx],ah;Loop @Loop;end;
Procedure Hline(x,y,d:Word);assembler;
asm @loop:Push x;Push y;Call Pset;Inc x;Dec d;Jnz @loop;end;
Procedure Line(x1,y1,x2,y2:Integer);
Var dx,dy,px,py:LongInt;
Begin  dx:=0;dy:=0;px:=0;py:=0;
  Fixed(px).W:=x1;Fixed(dx).W:=(x2-x1);
  Fixed(py).W:=y1;Fixed(dy).W:=(y2-y1);
  x1:=abs(Fixed(dx).w);
  if abs(Fixed(dy).w)>x1 then x1:=abs(Fixed(dy).w);
  If x1=0 then PSet(x2,y2) else
  Begin dx:=dx div x1;dy:=dy div x1;
    Repeat PSet(Fixed(px).W,Fixed(py).W);
      Inc(px,dx);Inc(py,dy);Dec(x1);Until x1=0;end;end;
procedure clrgraph(c:Word);assembler;asm Push C;Call SetColor;Inc dx;
Mov al,-1;out dx,al;mov es,sega000;Xor di,di;Mov ax,-1;mov cx,80*800/2;
rep stosw;end;
Function SQRoot(N:LongInt):Word;Assembler;
asm Mov si,-1;Mov cx,n+2.word;Test ch,$80;JNZ @Error;Mov bx,n.word;
Mov di,32768;Xor si,si;@DoSqrt:Mov ax,si;Or ax,di;Mul ax;Cmp dx,cx;
Ja @NoSet;Jnz @Set;Cmp ax,bx;Ja @Noset;@Set:Or si,di;@Noset:Shr di,1;
Jnz @DoSqrt;@Error:Mov ax,si;end;
procedure Circle(cx,cy,r:Integer);
var x,y,rr,xx,yy:longint;
Procedure Cursors;
Begin
  Pset(cx+x,cy+y);Pset(cx-x,cy+y);Pset(cx+x,cy-y);Pset(cx-x,cy-y);
  Pset(cx+y,cy+x);Pset(cx-y,cy+x);Pset(cx+y,cy-x);Pset(cx-y,cy-x);
end;
begin
  x:=r;y:=0;rr:=x*x;xx:=rr-x;yy:=0;
  Repeat
    Cursors;Inc(yy,y+y+1);inc(y);
    if xx>(rr-yy) then begin Inc(xx,1-x-x);dec(x);Cursors;end;
  Until x<y;
end;
procedure Disc(x,y,r:Integer);Var d,rr,Loop:LongInt;
Begin rr:=r;rr:=rr*rr;For Loop:=0 to Pred(r) do Begin
  d:=sqroot(rr-Loop*Loop);vline(x-Loop,y-d,d+d);vline(x+loop,y-d,d+d);
end;end;
Procedure OutTextXY(s:String;x,y:Integer;C:Byte;Style:Byte);
Var xlp,ylp,pos,size,width,italic,xd,yp,d,p,sx,sy:integer;
    f:pFntArray;us:String;
begin If (@PSET=Nil) or (@SetColor=Nil) then exit;
  sx:=FontScales AND $f; sy:=FontScales SHR 4;
  If Boolean(style AND FShadow) then OutTextXY(s,x+sx,y+sy,shadow,
     style AND (Not (FShadow)));
  If Boolean(Style And FULine) then
  Begin FillChar(us[1],Length(s),'_');us[0]:=s[0];
    OutTextXY(us,x,y+(sy+1)Div 2,c,Style AND Not(FUline+FShadow));end;
  If Boolean(style AND FOLine) then
  Begin If c= Shadow then Pos:=c else Pos:=OutLine;
    For xlp:=-1 to 1 do For ylp:=-1 to 1 do
    Begin If (Style and FItalic)>0 then Italic:=(ylp*(sy+1)) Div 4
    else italic:=0;
    OutTextXY(s,x+xlp*(sx+1)div 2-italic,y+ylp*(sy+1)div 2,pos,
    style and (Not (FOLine+FULine+FShadow)));
  end;end;
  If Boolean(Style AND FBold) then OutTextXY(s,x+(sx+2) div 3,y,c,
     style AND (Not (FBold+FOLine+FShadow+FULine)));
  If Boolean(Style AND FTiny)then Begin size:=5;Width:=6;f:=@CharSet_5p;end
  Else Begin size:=8;Width:=8;f:=@F8x8;end;SetColor(c);Width:=Width*sx;
  If (Style AND FItalic)>0 then Inc (x,Width Div 4);
  For pos:= 1 to Byte(s[0]) do
    Begin p:=byte(s[pos]);If f=@Charset_5p then Begin
      Dec (p,33); if p<0 then continue;If p>62 then dec(p,32);
      If p>95 then continue; end;For ylp:= 0 to Pred(size*SY) do
        Begin
          If (Style and FItalic)>0 then Italic:=ylp SHR 1 else italic:=0;
          d:=f^[p*size+Ylp Div SY];xd:=0;yp:=y+ylp;
          for xlp:=x+Pred(pos)*Width-Italic to x+pos*Width-italic do
            Begin If Boolean(d AND $80) then pset(xlp,yp);
              Inc (xd); if xd=SX then Begin Inc(d,d);xd:=0;end;
end;end;end;end; {OutTextXY}
{for a little demo, uncomment the next section and 'Use' it!}
{Var lp,n,m:longInt;
Begin VideoMode($12);ClrGraph(1);SetColor(3);
  For n:=0 to 639 do For m:=0 to 799 do
  Begin SetColor(m*n Div 40);PSET(n,m);end;
  For lp:=0 to 255 do
  Begin SetColor((lp XOR $3)div 20);Circle(319,400,lp XOR $15);end;
  OutLine:=0;FontScales:=$76;
  OutTextXY('Fonts:',200,80,14,FShadow+fUline+fOLine+FItalic+FBold);
  Shadow:=0;FontScales:=$11; For lp:=0 to 31 do
  OutTextXY('This is a test!',20,30+lp*12,14,lp);
  SetStart(0); FontScales:=$53; For m:=1 to 4 do
    OutTextXY('Wow- 3D!',200+m*3,300+m*2,14,fOLine+fULine);
  FontScales:=$11;
  For m:=0 to 80*5 do Begin WaitVBL;SetStart(m Mod 80);end;
  For n:= 2 to 5 do For lp:=-320 to 320 do
  Begin
    WaitVBL;SetStart((320-ABS(lp))*80);Inc(lp,abs((abs(lp)-320) div 
(n*n)));
  end;
  Lp:=1000;For n:=0 to 1000 do
  Begin Dec(Lp,2);m:=(1000-ABS(Lp))Div 6;
    SetStart(Round(m*(1+Sin(n/14)))*80+Round((m div 8)*cos(n/14)));
    WaitVBL;end;
  ReadKey;VideoMode($03);{end of demo}
end.
