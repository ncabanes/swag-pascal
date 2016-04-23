{
 HK> I have one little question: how do I program my ET4000
 HK> graphics card in SVGA modes??? Without using some sort of
 HK> BGI or unit!

Check this:

>--- cut here
}
program tsenglabs_et4000_640x480x256_mode;
{ Direct screen writing in SuperVGA mode 640x480x256 on a TsengLabs ET4000 }
{ By Bas van Gaalen, Holland, PD }
uses crt;
var x,y:word; i,page:byte;

procedure setvideo(md:word); assembler;
{ 02dh - 630x350
  02eh - 640x480
  02fh - 640x400 }
asm
  mov ax,md
  int 10h
end;

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

procedure writescreen; assembler;
asm
  mov es,sega000
  mov x,0
  mov y,0
 @l1:
  mov ax,y
  mov dx,640
  mul dx
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
  mov ax,x
  add ax,y
  mov [es:di],al
  inc y
  cmp y,480
  jne @l1
  mov y,0
  inc x
  cmp x,640
  jne @l1
end;

begin
  setvideo($2e);
  for i:=1 to 255 do setpal(i,255-i div 4,255-i div 4,30);
  writescreen;
  repeat until keypressed;
  textmode(lastmode);
end.
