(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0217.PAS
  Description: Nice Graphics Unit
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

unit gru; { GRaphic Unit. }
{$g+}

INTERFACE

type
  palrec=record
           r,g,b:byte;
         end;
  paltype=array[0..255]of palrec;
  palptr=^paltype;
const
  vidseg:word=$a000;

procedure plot(const x,y:word;const c:byte);
procedure plot2(const x,y,where:word;const c:byte);
procedure setmode(const mode:word);
procedure flip386(const a,b:word);
procedure clear386(const where:word;const c:byte);
procedure flip286(const a,b:word);
procedure clear286(const where:word;const c:byte);
procedure flip(const a,b:word);
procedure clear(const where:word;const c:byte);
procedure vret;
procedure hline(const x1,x2,y:word;const c:byte);
procedure hline2(const x1,x2,y,where:word;const c:byte);
procedure vline(const x,y1,y2:word;const c:byte);
procedure vline2(const x,y1,y2,where:word;const c:byte);
procedure line(const x1,y1,x2,y2:word;const c:byte);
procedure line2(const x1,y1,x2,y2,where:word;const c:byte);
function  getpix(const x,y:word):byte;
function  getpix2(const x,y,where:word):byte;
function  rad(theta:real):real;
procedure setpal(c,r,g,b:byte);
procedure getvgapal(var pal:paltype);
procedure setvgapal(var pal:paltype);
procedure smooth(where:word);
procedure smooth1(x,y,where:word);
procedure smooth2(where,size:word);
procedure drawsprite(const x,y,where:word;const w,h,c:byte;var sprite);
procedure fadefrompaltopal(oldpal,newpal:paltype);
procedure ffblack(palin:paltype);
procedure f2black(palin:paltype);
procedure scanlines(numl:word);
procedure combine(const in1,in2,out,eline:word);

var
  clipon:boolean;
  cx1,cx2,cy1,cy2:word;

IMPLEMENTATION

var
  scrofs:array[0..199]of word; { Holding screen offsets. }
  blackp:paltype;
  whitep:paltype;
  tempal:paltype;

procedure plot(const x,y:word;const c:byte); assembler;
asm
  cmp clipon,0
  je @@sc
  mov ax,[x]
  cmp ax,cx1
  jb @@exit
  cmp ax,cx2
  ja @@exit
  mov ax,[y]
  cmp ax,cy1
  jb @@exit
  cmp ax,cy2
  ja @@exit
  @@sc: { SkipCheck :-) }
  mov es,sega000
  mov bx,[y]
  shl bx,1
  mov di,word ptr[scrofs+bx]
  add di,[x]
  mov al,[c]
  mov es:[di],al
@@exit:
end;

procedure plot2(const x,y,where:word;const c:byte); assembler;
asm
  cmp clipon,0
  je @@sc
  mov ax,[x]
  cmp ax,cx1
  jb @@exit
  cmp ax,cx2
  ja @@exit
  mov ax,[y]
  cmp ax,cy1
  jb @@exit
  cmp ax,cy2
  ja @@exit
  @@sc: { SkipCheck :-) }
  mov ax,where
  mov es,ax
  mov bx,[y]
  shl bx,1
  mov di,word ptr[scrofs+bx]
  add di,[x]
  mov al,[c]
  mov es:[di],al
@@exit:
end;

procedure setmode(const mode:word);assembler;
asm
  mov ax,mode
  int 10h
end;

procedure flip386(const a,b:word); assembler;
asm
  push ds
  mov ds,a
  mov es,b
  xor si,si
  xor di,di
  mov cx,16000
  db 66h; rep movsw
  pop ds
end;

procedure clear386(const where:word;const c:byte); assembler;
asm
  mov es,where
  xor ax,ax
  xor di,di
  mov al,[c]
  mov ah,al
  db 66h; shr ax,16
  mov al,[c]
  mov ah,al
  mov cx,16000
  db 66h; rep stosw
end;

procedure flip286(const a,b:word); assembler;
asm
  push ds
  mov ds,a
  mov es,b
  xor si,si
  xor di,di
  mov cx,32000
  rep movsw
  pop ds
end;

procedure clear286(const where:word;const c:byte); assembler;
asm
  mov es,where
  xor ax,ax
  xor di,di
  mov al,[c]
  mov ah,al
  mov cx,32000
  rep stosw
end;

procedure flip(const a,b:word); assembler;
asm
  push ds
  mov ds,a
  mov es,b
  xor si,si
  xor di,di
  mov cx,64000
  rep movsb
  pop ds
end;

procedure clear(const where:word;const c:byte); assembler;
asm
  mov es,where
  xor ax,ax
  xor di,di
  mov al,[c]
  mov cx,64000
  rep stosb
end;

procedure vret; assembler;
asm
        mov dx,3dah;
@vert1: in al,dx
        test al,8
        jz @vert1
@vert2: in al,dx
        test al,8
        jnz @vert2
end;

procedure hline(const x1,x2,y:word;const c:byte); assembler;
asm
  cld
  mov es,sega000
  mov ax,[x1]
  mov cx,[x2]
  sub cx,ax
  mov di,[y]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,ax
  mov al,[c]
  mov ah,al
  shr cx,1
  rep stosw
  adc cx,cx
  rep stosb
end;

procedure hline2(const x1,x2,y,where:word;const c:byte); assembler;
asm
  cld
  mov ax,where
  mov es,ax
  mov ax,[x1]
  mov cx,[x2]
  sub cx,ax
  mov di,[y]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,ax
  mov al,[c]
  mov ah,al
  shr cx,1
  rep stosw
  adc cx,cx
  rep stosb
end;

procedure vline(const x,y1,y2:word;const c:byte);assembler;
asm
  mov es,sega000
  mov ax,[y1]
  mov bx,ax
  shl ax,8
  shl bx,6
  add ax,bx
  mov di,ax
  mov ax,[y2]
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  mov al,[c]
  mov cx,[x]
  add di,cx
  add bx,cx

  @@loop1:
    mov es:[di],al
    add di,320
    cmp di,bx
    jne @@loop1
end;

procedure vline2(const x,y1,y2,where:word;const c:byte);assembler;
asm
  mov ax,where
  mov es,ax
  mov ax,[y1]
  mov bx,ax
  shl ax,8
  shl bx,6
  add ax,bx
  mov di,ax
  mov ax,[y2]
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  mov al,[c]
  mov cx,[x]
  add di,cx
  add bx,cx

  @@loop1:
    mov es:[di],al
    add di,320
    cmp di,bx
    jne @@loop1
end;

procedure line(const x1,y1,x2,y2:word;const c:byte);assembler;
var
  dex,dey,incf:Integer;
  offset:word;
asm
  mov ax,[x2]
  sub ax,[x1]
  jnc @@dont1
  neg ax
@@dont1:
  mov [dex],ax
  mov ax,[y2]
  sub ax,[y1]
  jnc @@dont2
  neg ax
@@dont2:
  mov [dey],ax
  cmp ax,[dex]
  jbe @@otherline
  mov  ax,[y1]
  cmp  ax,[y2]
  jbe  @@dontswap1
  mov  bx,[y2]
  mov  [y1],bx
  mov  [y2],ax
  mov  ax,[x1]
  mov  bx,[x2]
  mov  [x1],bx
  mov  [x2],ax
@@dontswap1:
  mov [incf],1
  mov ax,[x1]
  cmp ax,[x2]
  jbe @@skipnegate1
  neg [incf]
@@skipnegate1:
  mov di,[y1]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[x1]
  mov bx,[dey]
  mov cx,bx
  mov ax,$a000
  mov es,ax
  mov dl,[c]
  mov si,[dex]
@@drawloop1:
  mov es:[di],dl
  add di,320
  sub bx,si
  jnc @@goon1
  add bx,[dey]
  add di,[incf]
@@goon1:
  loop @@drawloop1
  jmp  @@exitline
@@otherline:
  mov ax,[x1]
  cmp ax,[x2]
  jbe @@dontswap2
  mov bx,[x2]
  mov [x1],bx
  mov [x2],ax
  mov ax,[y1]
  mov bx,[y2]
  mov [y1],bx
  mov [y2],ax
@@dontswap2:
  mov [incf],320
  mov ax,[y1]
  cmp ax,[y2]
  jbe @@skipnegate2
  neg [incf]
@@skipnegate2:
  mov di,[y1]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[x1]
  mov bx,[dex]
  mov cx,bx
  mov ax,$a000
  mov es,ax
  mov dl,[c]
  mov si,[dey]
@@drawloop2:
  mov es:[di],dl
  inc di
  sub bx,si
  jnc @@goon2
  add bx,[dex]
  add di,[incf]
@@goon2:
  loop @@drawloop2
@@exitline:
end;

procedure line2(const x1,y1,x2,y2,where:word;const c:byte);assembler;
var
  dex,dey,incf:Integer;
  offset:word;
asm
  mov ax,[x2]
  sub ax,[x1]
  jnc @@dont1
  neg ax
@@dont1:
  mov [dex],ax
  mov ax,[y2]
  sub ax,[y1]
  jnc @@dont2
  neg ax
@@dont2:
  mov [dey],ax
  cmp ax,[dex]
  jbe @@otherline
  mov  ax,[y1]
  cmp  ax,[y2]
  jbe  @@DontSwap1
  mov  bx,[y2]
  mov  [y1],bx
  mov  [y2],ax
  mov  ax,[x1]
  mov  bx,[x2]
  mov  [x1],bx
  mov  [x2],ax
@@dontswap1:
  mov [incf],1
  mov ax,[x1]
  cmp ax,[x2]
  jbe @@skipnegate1
  neg [incf]
@@skipnegate1:
  mov di,[y1]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[x1]
  mov bx,[dey]
  mov cx,bx
  mov ax,where
  mov es,ax
  mov dl,[c]
  mov si,[dex]
@@drawloop1:
  mov es:[di],dl
  add di,320
  sub bx,si
  jnc @@goon1
  add bx,[dey]
  add di,[incf]
@@goon1:
  loop @@drawloop1
  jmp  @@exitline
@@otherline:
  mov ax,[x1]
  cmp ax,[x2]
  jbe @@dontswap2
  mov bx,[x2]
  mov [x1],bx
  mov [x2],ax
  mov ax,[y1]
  mov bx,[y2]
  mov [y1],bx
  mov [y2],ax
@@dontswap2:
  mov [incf],320
  mov ax,[y1]
  cmp ax,[y2]
  jbe @@skipnegate2
  neg [incf]
@@skipnegate2:
  mov di,[y1]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[x1]
  mov bx,[dex]
  mov cx,bx
  mov ax,where
  mov es,ax
  mov dl,[c]
  mov si,[dey]
@@drawloop2:
  mov es:[di],dl
  inc di
  sub bx,si
  jnc @@goon2
  add bx,[dex]
  add di,[incf]
@@goon2:
  loop @@drawloop2
@@exitline:
end;

function getpix(const x,y:word):byte; assembler;
asm
  cmp clipon,0
  je @@sc
  mov ax,[x]
  cmp ax,cx1
  jb @@exit
  cmp ax,cx2
  ja @@exit
  mov ax,[y]
  cmp ax,cy1
  jb @@exit
  cmp ax,cy2
  ja @@exit
  @@sc: { SkipCheck :-) }
  mov es,sega000
  mov bx,[y]
  shl bx,1
  mov di,word ptr[scrofs+bx]
  add di,[x]
  mov al,es:[di]
@@exit:
end;

function getpix2(const x,y,where:word):byte; assembler;
asm
  cmp clipon,0
  je @@sc
  mov ax,[x]
  cmp ax,cx1
  jb @@exit
  cmp ax,cx2
  ja @@exit
  mov ax,[y]
  cmp ax,cy1
  jb @@exit
  cmp ax,cy2
  ja @@exit
  @@sc: { SkipCheck :-) }
  mov ax,where
  mov es,ax
  mov bx,[y]
  shl bx,1
  mov di,word ptr[scrofs+bx]
  add di,[x]
  mov al,es:[di]
@@exit:
end;

function rad(theta:real):real;
begin
  rad:=theta*pi/180;
end;

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

procedure getvgapal(var pal:paltype); assembler;
asm
  push ds
  xor ax,ax
  mov cx,0300h
  les di,pal
  mov dx,03c7h
  out dx,al
  inc dx
  inc dx
  cld
  rep insb
  pop ds
end;

procedure setvgapal(var pal:paltype); assembler;
asm
  push ds
  xor ax,ax
  mov cx,0300h/2
  lds si,pal
  mov dx,03c8h
  out dx,al
  inc dx
  mov bx,dx
  cld
  mov dx,03dah
  @vsync0:
    in al,dx
    test al,8
  jz @vsync0
  mov dx,bx
  rep outsb
  mov bx,dx
  mov dx,03dah
  @vsync1:
    in al,dx
    test al,8
  jz @vsync1
  mov dx,bx
  mov cx,0300h/2
  rep outsb
  pop ds
end;

procedure smooth(where:word); assembler;
asm
  mov ax,where
  mov es,ax
  xor di,di
  mov cx,64000-320
  xor bh,bh
  @@loop:
    xor ax,ax
    mov al,es:[di]
    mov bl,es:[di+320] ;add ax,bx
    mov bl,es:[di+1]   ;add ax,bx
    mov bl,es:[di+321] ;add ax,bx
    shr ax,2
    mov es:[di],al
    inc di
    loop @@loop
end;

procedure smooth1(x,y,where:word); assembler;
asm
  mov ax,where
  mov es,ax
  mov di,[y]
  mov bx,di
  shl di,8
  shl bx,6
  add di,bx
  add di,[x]
  xor bh,bh
  xor ax,ax
  mov al,es:[di]
  mov bl,es:[di+320] ;add ax,bx
  mov bl,es:[di+1]   ;add ax,bx
  mov bl,es:[di+321] ;add ax,bx
  shr ax,2
  mov es:[di],al
end;

procedure smooth2(where,size:word); assembler;
asm
  mov ax,where
  mov es,ax
  xor di,di
  mov cx,size
  xor bh,bh
  @@loop:
    xor ax,ax
    mov al,es:[di]
    mov bl,es:[di+320] ;add ax,bx
    mov bl,es:[di+1]   ;add ax,bx
    mov bl,es:[di+321] ;add ax,bx
    shr ax,2
    mov es:[di],al
    inc di
    loop @@loop
end;

procedure drawsprite(const x,y,where:word;const w,h,c:byte;var sprite); assembler;
asm
  push ds
  lds si,[sprite]
  mov ax,where
  mov es,ax
  cld
  mov ax,[y]
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,[x]
  mov bh,[h]
  mov cx,320
  sub cl,[w]
  sbb ch,0
 @l:
  mov bl,[w]
 @l2:
  lodsb
  cmp al,[c]
  je @s
  mov dl,[es:di]
  add dl,al
  mov es:[di],dl
 @s:
  inc di
  dec bl
  jnz @l2
  add di,cx
  dec bh
  jnz @l
  pop ds
end;

procedure fadefrompaltopal(oldpal,newpal:paltype);
var
  dac,c:word;
begin
  for c:=32 downto 0 do
  begin
    for dac:=0 to 255 do
    begin
      tempal[dac].r:=((oldpal[dac].r*c)div 32)+((newpal[dac].r*(32-c))div 32);
      tempal[dac].g:=((oldpal[dac].g*c)div 32)+((newpal[dac].g*(32-c))div 32);
      tempal[dac].b:=((oldpal[dac].b*c)div 32)+((newpal[dac].b*(32-c))div 32);
    end;
    setvgapal(tempal);
  end;
end;

procedure ffblack(palin:paltype);
var dac,i:word;
begin
  for i:=0 to 32 do
  begin
    for dac:=0 to 255 do
    begin
      tempal[dac].r:=(palin[dac].r*i)div 32;
      tempal[dac].g:=(palin[dac].g*i)div 32;
      tempal[dac].b:=(palin[dac].b*i)div 32;
    end;
    setvgapal(tempal);
  end;
end;

procedure f2black(palin:paltype);
var
  dac,i:word;
begin
  for i:=32 downto 0 do
  begin
    for dac:=0 to 255 do
    begin
      tempal[dac].r:=(palin[dac].r*i)div 32;
      tempal[dac].g:=(palin[dac].g*i)div 32;
      tempal[dac].b:=(palin[dac].b*i)div 32;
    end;
    setvgapal(tempal);
  end;
end;

procedure scanlines(numl:word); assembler;
asm
  mov dx, 3d4h
  mov al, 9
  out dx, al
  inc dx
  in al, dx
  and al, 0E0h
  add ax, numl
  out dx, al
end;

procedure combine(const in1,in2,out,eline:word); assembler;
asm
  push ds
  mov ax,out; mov es,ax; xor di,di
  cld
  mov cx,[eline]
  mov bx,cx
  shl cx,8
  shl bx,6
  add cx,bx
  mov bx,cx
  shr cx,2
  mov ax,in1; mov ds,ax; xor si,si
  db 66h; rep movsw; adc cx,cx; rep movsw
  mov ax,in2; mov ds,ax; mov si,bx
  mov cx,64000
  sub cx,bx
  shr cx,2
  db 66h; rep movsw; adc cx,cx; rep movsw
  pop ds
end;

var
  count:word;

begin
  clipon:=false;
  cx1:=0; cx2:=319; cy1:=0; cy2:=199;
  for count:=0 to 199 do scrofs[count]:=count*320; { Set up the offsets. }
  for count:=0 to 255 do
  begin
    blackp[count].r:=0;
    blackp[count].g:=0;
    blackp[count].b:=0;
    whitep[count].r:=63;
    whitep[count].g:=63;
    whitep[count].b:=63;
  end;
end.
