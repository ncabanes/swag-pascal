{
>  YES!!! Thats it exactly...!!!! If your procedures are Masked then
>  post away :) Umm.. Don't 'spose your procedures are really fast ASM
>  versions eh??

How'd you guess?

These will only work in 320x200x256 video mode.  I might be able to set them
up for SVGA modes, but that would be a pain and you would really have to beg
and plead and everything to get me to do them.
}

Function GetImage(x1, y1, x2, y2 : integer) : pointer;

{ Gets an image from the current buffer }

label gi1;

var
  temp : integer;
  Addr, XReps : word;
  ImageSize : word;
  ImagePtr : pointer;

begin
  if (x1>x2) then begin
    temp := x1;
    x1 := x2;
    x2 := temp end;
  if (y1>y2) then begin
    temp := y1;
    y1 := y2;
    y2 := temp end;

  ImageSize := (x2-x1+1) * (y2-y1+1) + 4;
  GetMem(ImagePtr,ImageSize);
  GetImage := ImagePtr;

  Addr := x1 + y1 shl 8 + y1 shl 6;
  XReps := x2-x1+1;
  asm
    push ds
    lds si, CurBuf
    add si, Addr
    les di, ImagePtr
    mov bx, y2
    sub bx, y1
    inc bx
    mov ax, XReps                      { store image height }
    stosw
    mov ax, bx                         { store image width }
    stosw
gi1:                                   { store image }
    mov cx, XReps
    rep movsb
    add si, SW
    sub si, XReps
    dec bx
    jnz gi1
    pop ds
  end
end;

Procedure PutImage(x, y : integer; ImagePtr : pointer);

{ Puts an image on the current buffer }

label pi1;

var
  Addr : word;

begin
  Addr := x + y shl 8 + y shl 6;

  asm
    push ds
    les di, CurBuf
    add di, Addr
    lds si, ImagePtr
    lodsw
    mov dx, ax                         { image width }
    lodsw
    mov bx, ax                         { image height }
pi1:
    mov cx, dx
    rep movsb
    add di, SW
    sub di, dx
    dec bx
    jnz pi1
    pop ds
  end
end;

