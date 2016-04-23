{
 JK> Could anybody send me a routine that uses graphical mouse pointer
 JK> in 80x25 textmode? I don't want a block cursor which moves from
 JK> character to another (it's not very accurate). I would need a
 JK> arrow pointer which can be moved softly around the screen.

It aint perfect - it's a little shocky - but it works, and might give you a
clue on how to operate. A credit would be in place. ;-)

Check this:

>--- cut here
}
program txtmouse;
{ Graphics mouse cursor in textmode, by Bas van Gaalen,
  fido 2:285/213.8, internet bas.van.gaalen@schotman.nl, Holland, PD }
uses
  crt;
const
  setimg=0; getimg=1;
  vidseg:word=$b800;
  mscursor:array[0..7] of byte=(252,248,248,248,252,142,7,3);
type
  worktype=array[0..3,0..7] of byte;
var
  pdata:array[0..3] of byte;
  px,py:byte;

{ mouse routines ----------------------------------------------------------- }

function mouseinstalled:boolean; assembler; asm
  xor ax,ax; int 33h; cmp ax,-1; je @skip; xor al,al; @skip: end;

function getmousex:word; assembler; asm
  mov ax,3; int 33h; mov ax,cx end;

function getmousey:word; assembler; asm
  mov ax,3; int 33h; mov ax,dx end;

function leftpressed:boolean; assembler; asm
  mov ax,3; int 33h; and bx,1; mov ax,bx end;

function rightpressed:boolean; assembler; asm
  mov ax,3; int 33h; and bx,2; mov ax,bx end;

procedure mousesensetivity(x,y:word); assembler; asm
  mov ax,1ah; mov bx,x; mov cx,y; xor dx,dx; int 33h end;

procedure mousewindow(l,t,r,b:word); assembler; asm
  mov ax,7; mov cx,l; mov dx,r; int 33h; mov ax,8
  mov cx,t; mov dx,b; int 33h end;

function hardx:byte; begin hardx:=getmousex div 8; end;
function hardy:byte; begin hardy:=getmousey div 8; end;
function smoothx:word; begin smoothx:=getmousex mod 8; end;
function smoothy:word; begin smoothy:=getmousey mod 8; end;

{ -------------------------------------------------------------------------- }

procedure getsetimage(chr:byte; var data; getset:byte); assembler;
asm
  push ds
  mov al,32
  mul [chr]
  cmp getset,getimg
  je @goget
  mov di,ax
  mov ax,0a000h
  mov es,ax
  mov cx,8/2
  lds si,data
  jmp @start
 @goget:
  mov si,ax
  mov ax,0a000h
  mov ds,ax
  mov cx,8/2
  les di,data
 @start:
  cli
  mov dx,03c4h; mov ax,0402h; out dx,ax; mov ax,0704h; out dx,ax
  mov dx,03ceh; mov ax,0204h; out dx,ax; mov ax,0005h; out dx,ax; 
  mov ax,0006h; out dx,ax
  rep movsw
  mov dx,03c4h; mov ax,0302h; out dx,ax; mov ax,0304h; out dx,ax
  mov dx,03ceh; mov ax,0004h; out dx,ax; mov ax,1005h; out dx,ax; 
  mov ax,0e06h; out dx,ax
  sti
  pop ds
end;

{ -------------------------------------------------------------------------- }

procedure retrace; assembler; asm
  mov dx,03dah
  @vert1: in al,dx; test al,8; jnz @vert1
  @vert2: in al,dx; test al,8; jz @vert2
end;

{ save old characters to screen }
procedure saveold;
begin
  pdata[0]:=mem[vidseg:py*160+px*2];
  pdata[1]:=mem[vidseg:py*160+(px+1)*2];
  pdata[2]:=mem[vidseg:(py+1)*160+px*2];
  pdata[3]:=mem[vidseg:(py+1)*160+(px+1)*2];
end;

{ restore old characters to screen }
procedure restoreold;
begin
  mem[vidseg:py*160+px*2]:=pdata[0];
  mem[vidseg:py*160+(px+1)*2]:=pdata[1];
  mem[vidseg:(py+1)*160+px*2]:=pdata[2];
  mem[vidseg:(py+1)*160+(px+1)*2]:=pdata[3];
end;

{ clear 'data' }
procedure cleardata(var data:worktype); begin
  fillchar(data,sizeof(data),0); end;

{ get chars from screen and put font-data in 'data' }
procedure getscrdata(var data:worktype);
var ch,i,j,x,y:byte;
begin
  x:=hardx; y:=hardy;
  getsetimage(mem[vidseg:y*160+x*2],data[0],getimg);
  getsetimage(mem[vidseg:y*160+(x+1)*2],data[1],getimg);
  getsetimage(mem[vidseg:(y+1)*160+x*2],data[2],getimg);
  getsetimage(mem[vidseg:(y+1)*160+(x+1)*2],data[3],getimg);
end;

{ add info-font-data and mouse-arrow together }
procedure addata(var data:worktype);
var i:byte;
begin
  for i:=0 to 7-smoothy do data[0,i+smoothy]:=data[0,i+smoothy] or (mscursor[i]
shr smoothx);  for i:=0 to 7-smoothy do data[1,i+smoothy]:=data[1,i+smoothy] or
(mscursor[i] shl (8-smoothx));  for i:=0 to smoothy do data[2,i]:=data[2,i] or
(mscursor[8-smoothy+i] shr smoothx);  for i:=0 to smoothy do
data[3,i]:=data[3,i] or (mscursor[8-smoothy+i] shl (8-smoothx));end;

{ place graphicsmouse on textscreen }
procedure placemouse(data:worktype);
var i,x,y:byte;
begin
  for i:=0 to 3 do getsetimage(219+i,data[i],setimg);
  x:=hardx; y:=hardy; px:=x; py:=y; saveold;
  mem[vidseg:py*160+px*2]:=219;
  mem[vidseg:py*160+(px+1)*2]:=220;
  mem[vidseg:(py+1)*160+px*2]:=221;
  mem[vidseg:(py+1)*160+(px+1)*2]:=222;
end;

{ -------------------------------------------------------------------------- }

var
  ms:worktype;
  i,j,x,y:byte;
begin
  textmode(co80+font8x8);
  mem[$40:$49]:=6; { fool mouse to be in graphics-mode (needed for smooth) }
  if not mouseinstalled then begin writeln('need mouse.'); halt; end;
  mousesensetivity(20,20);
  mousewindow(0,0,639-8,399-8);
  for i:=10 to 69 do for j:=0 to 35 do memw[vidseg:4*160+j*160+i+i]:=((j*20+i)
mod 255)+7*256;  px:=hardx; py:=hardy; saveold;
  while not leftpressed do begin
    write(#13,hardx:2,',',hardy:2);
    retrace;
    restoreold;
    cleardata(ms);
    getscrdata(ms);
    addata(ms);
    placemouse(ms);
  end;
  textmode(lastmode);
end.
