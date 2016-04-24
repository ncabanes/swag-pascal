(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0159.PAS
  Description: Wormhole
  Author: BAS VAN GAALEN
  Date: 11-26-94  05:02
*)

{ Turbo Pascal version 7.0 directive settings }
{$a+,b-,d+,e+,f-,g+,i+,l+,n-,o-,p-,q-,r-,s+,t-,v+,x+}

{ if you have a 386 or better 'uncomment' the next line }
{-$define cpu386}

program wormhole;
{ Asm-version of Wormhole, by Bas van Gaalen, Holland, PD }
uses
  crt;
const
  vidseg:word=$a000;
  divd=128;
  astep=6;
  xst=4;
  yst=5;
var
  sintab:array[0..449] of integer;
  stab,ctab:array[0..255] of integer;
  virscr:pointer;
  virseg:word;
  lstep:byte;

procedure setpal(col,r,g,b : byte); assembler;
asm
  mov dx,03c8h
  mov al,col
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
end;

procedure drawpolar(xo,yo,r,a:word; c:byte; lvseg:word); assembler;
asm
  mov es,lvseg

  mov bx,a
  add bx,a
  mov cx,word ptr sintab[bx]
  add bx,2*90
  mov ax,word ptr sintab[bx]
  mul r
  mov bx,divd
  xor dx,dx
  cwd
  idiv bx
  add ax,xo
  add ax,160
  cmp ax,320
  ja @out
  mov si,ax

  mov ax,cx
  mul r
  mov bx,divd
  xor dx,dx
  cwd
  idiv bx
  add ax,yo
  add ax,100
  cmp ax,200
  ja @out

  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,si
  mov al,c
  mov [es:di],al
 @out:
end;

procedure cls(lvseg:word); assembler;
asm
  mov es,[lvseg]
  xor di,di
  xor ax,ax
{$ifdef cpu386}
  mov cx,320*200/4
  rep
  db $66; stosw
{$else}
  mov cx,320*200/2
  rep stosw
{$endif}
end;

procedure flip(src,dst:word); assembler;
asm
  push ds
  mov ax,[dst]
  mov es,ax
  mov ax,[src]
  mov ds,ax
  xor si,si
  xor di,di
{$ifdef cpu386}
  mov cx,320*200/4
  rep
  db $66; movsw
{$else}
  mov cx,320*200/2
  rep movsw
{$endif}
  pop ds
end;

procedure retrace; assembler;
asm
  mov dx,03dah
 @vert1:
  in al,dx
  test al,8
  jnz @vert1
 @vert2:
  in al,dx
  test al,8
  jz @vert2
end;

var x,y,i,j:word; c:byte;
begin
  asm mov ax,13h; int 10h; end;
  for i:=0 to 255 do begin
    ctab[i]:=round(cos(pi*i/128)*60);
    stab[i]:=round(sin(pi*i/128)*45);
  end;
  for i:=0 to 449 do sintab[i]:=round(sin(2*pi*i/360)*divd);
  getmem(virscr,64000);
  virseg:=seg(virscr^);
  cls(virseg);
  x:=30; y:=90;
  repeat
    {retrace;}
    c:=22; lstep:=2; j:=10;
    while j<220 do begin
      i:=0;
      while i<360 do begin
        drawpolar(ctab[(x+(200-j)) mod 255],stab[(y+(200-j)) mod
255],j,i,c,virseg);
        inc(i,astep);
      end;
      inc(j,lstep);
      if (j mod 5)=0 then begin inc(lstep); inc(c); if c>31 then c:=22; end;
    end;
    x:=xst+x mod 255;
    y:=yst+y mod 255;
    flip(virseg,vidseg);
    cls(virseg);
  until keypressed;
  while keypressed do readkey;
  freemem(virscr,64000);
  textmode(lastmode);
end.


