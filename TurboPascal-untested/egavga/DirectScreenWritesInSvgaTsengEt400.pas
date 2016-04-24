(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0217.PAS
  Description: Direct screen writes in SVGA Tseng ET400
  Author: BAS VAN GAALEN
  Date: 05-26-95  23:22
*)

program et4000_supervga;
{ Direct screen writing in SuperVGA mode on a TsengLabs ET4000 }
{ By Bas van Gaalen, Holland, PD }
uses crt;
const vidseg:word=$a000;
var page:byte;

procedure setvideo(md:word); assembler;
{ 02dh -  630x350x256
  02eh -  640x480x256
  02fh -  640x400x256
  030h -  800x600x256
  038h - 1024x768x256
}
asm mov ax,md; int 10h; end;

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

procedure putpixel(x,y:word; c:byte); assembler;
asm
  mov es,vidseg
  mov ax,640
  mul y
  add ax,x
  adc dx,0
  mov di,ax
  cmp dl,page
  je @skip
  mov page,dl
  mov al,dl
  mov dx,03cdh
  out dx,al
 @skip:
  mov al,c
  mov es:[di],al
end;

var x,y,i:word;
begin
  setvideo($2e);
  for i:=1 to 255 do setpal(i,255-i div 4,255-i div 4,30);
  for x:=0 to 639 do for y:=0 to 479 do putpixel(x,y,(x*y+x*y) shr 2);
  repeat until keypressed;
  textmode(lastmode);
end.


