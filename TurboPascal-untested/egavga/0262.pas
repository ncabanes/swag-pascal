
{$G+}
const
  screen=ptr($A000,0);
  font=ptr($F0A0,$F06E);
 
Function ReadKey:Char;Assembler;
Asm
  mov ah,00h;       int 16h
End;
 
Procedure DispStr(x,y:Word;color:Byte;page,font:Pointer;s:String);Assembler;
Asm
  les di,s;         mov al,es:[di];    push ax;           push es;
  push di;          @begin:;           les di,s;          mov al,es:[di];
  cmp al,0;         je @exit;          dec al;            mov es:[di],al;
  inc al;           xor ah,ah;         mov dx,ax;         add di,ax;
  mov al,es:[di];   shl ax,3;          les di,font;       add di,ax;
  mov bx,di;        mov cx,es;         les di,page;       mov ax,y;
  mov dh,al;        shl ax,6;          add ah,dh;         xor dh,dh;
  shl dx,3;         add ax,dx;         add ax,x;          add di,ax;
  mov ah,color;     xchg di,bx;        mov si,es;         mov es,cx;
  mov cx,si;        mov dx,0880h;      @loop1:;           mov al,es:[di];
  xchg di,bx;       mov si,es;         mov es,cx;         mov cx,si;
  @loop2:;          cmp al,dl;         jb @loop3;         sub al,dl;
  mov es:[di],ah;   @loop3:;           inc di;            cmp dl,0;
  shr dl,1;         jne @loop2;        mov dl,80h;        add di,312;
  xchg di,bx;       mov si,es;         mov es,cx;         mov cx,si;
  inc di;           dec dh;            cmp dh,0;          jne @loop1;
  jmp @begin;       @exit:;            pop di;            pop es;
  pop ax;           mov es:[di],al;
End;
 
begin
  asm; mov ax,13h; int 10h; end;
  dispstr(10,10,15,screen,font,'does it work?');
  readkey;
  asm; mov ax,03h; int 10h; end;
end.

