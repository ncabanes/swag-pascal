{$g+,a+}
unit crypt;

INTERFACE

procedure maketable(const seed:word);
procedure encrypt(var data;const size,xoa:word);
procedure setslide(const slide:word);
function  maxslide:word;

IMPLEMENTATION

const
  maxx=2028; { Max is a word! }
var
  xortable:array[0..maxx]of byte;
  slidepos:word;

procedure maketable(const seed:word); assembler;
asm
  mov ax,seg xortable
  mov es,ax
  mov di,offset xortable
  xor cx,cx
  mov cx,maxx
  mov si,seed
  xor ax,ax
  @@loop:
    not ax
    inc ax
    neg ax
    add ax,cx
    and ax,si
    ror si,3
    rol ax,2
    xor ax,si
    inc si
    mov es:[di],al
    inc di
    dec cx
  jnz @@loop
end;

procedure encrypt(var data;const size,xoa:word); assembler;
{
  ds:si => pointer to XorTable
  es:di => pointer to data
  ax    => temporary
           => al is used for the thing that get changed,
              ah to hold a byte from the XORTABLE.
  bx    => used for temporary calculation.
  cx    => holds total end-up size for loop-end-check :-)
  dx    => holds additional XOR value. }
asm
  mov ax,seg [xortable]
  mov ds,ax
  mov si,offset [xortable]
  les di,[data]
  mov cx,di
  add cx,[size]
  mov dx,[xoa]
  jmp @@loop
  @@zeroit:
    mov [slidepos],0
  @@loop:
    cmp [slidepos],maxx
    jg @@zeroit { Slidepos become to big? }
    mov bx,si
    add bx,slidepos
    mov ah,ds:[bx]
    mov bx,[slidepos]

    mov al,es:[di]
    not al
    xor al,ah
    xor al,dl
    xor al,bl
    xor al,dh
    not al
    xor al,bh
    mov es:[di],al
    inc [slidepos]
    inc di
    cmp di,cx
    jb @@loop
end;

procedure setslide(const slide:word); assembler;
asm
  cmp [slide],maxx
  ja @@exit2
  mov ax,[slide]
  mov [slidepos],ax
  jmp @@exit
  @@exit2:
    mov [slidepos],0
  @@exit:
end;

function maxslide:word; assembler;
asm
  mov ax,[maxx]
end;

begin
  slidepos:=0;
end.