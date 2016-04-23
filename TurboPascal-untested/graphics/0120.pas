{
Yesterday I saw Bas' plasma routine. Real nice! But... a little slow I thought
so I improved it. Another thing, Bas, the bouble buffer didn't work on my
et4000, the bplptr never changed in your mode.

Well, enjoy this new routine!
}

program plasma;

{ bigscreenplasma, by Bas van Gaalen & Sven van Heel, Holland, PD   }
{ Improved by GEM, Sweden (convertion to asm --> many times faster) }

uses
  crt;

const
  vidseg:word=$a000;

var
  stab1,stab2:array[0..255+80] of byte;
  x:word;

procedure setpal(c,r,g,b:byte); assembler;
asm
   mov dx,3c8h
   mov al,[c]
   out dx,al
   inc dx
   mov al,[r]
   out dx,al
   mov al,[g]
   out dx,al
   mov al,[b]
   out dx,al
end;

begin
  asm
     mov ax,0013h
     int 10h
     mov dx,03c4h
     mov ax,0604h
     out dx,ax
     mov dx,03d4h
     mov ax,4609h
     out dx,ax
     mov ax,0014h
     out dx,ax
     mov ax,0e317h
     out dx,ax
     mov es,vidseg
     xor di,di
     xor ax,ax
     mov cx,16000
     rep stosw
  end;
  for x:=0 to 63 do begin
    setpal(x,x div 4,x div 2,x);
    setpal(127-x,x div 4,x div 2,x);
    setpal(127+x,20+x div 4,x div 2,x);
    setpal(254-x,20+x div 4,x div 2,x);
  end;
  for x:=0 to 255+80 do begin
    stab1[x]:=round(sin(2*pi*x/255)*128)+128;
    stab2[x]:=round(cos(2*pi*x/255)*128)+128;
  end;
  asm
     mov cl,50
     mov ch,90
     mov es,vidseg
     push bp
   @main:

{     mov dx,3c8h    (* For checking rastertime *)
     xor al,al
     out dx,al
     inc dx
     out dx,al
     out dx,al
     out dx,al}

     mov dx,3dah
   @vert1:
     in al,dx
     test al,8
     jz @vert1
   @vert2:
     in al,dx
     test al,8
     jnz @vert2

     mov dx,3dah    (* This is kinda rediculous! *)
   @vert1b:         (* I have to insert another vbl to slow it down.... *)
     in al,dx
     test al,8
     jz @vert1b
   @vert2b:
     in al,dx
     test al,8
     jnz @vert2b

{     mov dx,3c8h    (* For checking rastertime *)
     xor al,al
     out dx,al
     mov al,30
     inc dx
     out dx,al
     out dx,al
     out dx,al}

     inc cl
     inc ch
     xor di,di
     mov bp,di
   @loooooop:
     mov si,offset stab1
     mov bx,bp
     add bl,cl
     mov dl,[si+bx]
     xor dh,dh
     mov bl,ch
     mov al,[si+bx]
     add si,dx
     mov bx,bp
     add bl,al
     mov bl,[bx+offset stab2]
     mov bh,bl
     mov dx,40
   @again:
     lodsw
     add ax,bx
     stosw
     dec dx
     jnz @again
     cmp si,offset stab1[256]
     jb @1
     sub si,256
   @1:
     inc bp
     cmp bp,58
     jne @loooooop
     in al,60h
     cmp al,1
     jne @main
     pop bp
  end;
  textmode(lastmode);
end.

