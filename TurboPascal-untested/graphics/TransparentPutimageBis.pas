(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0184.PAS
  Description: Transparent PutImage
  Author: JASON RENNIE
  Date: 05-26-95  23:25
*)

{
> 1) I want to write some fast sprite-routines, which can put a sprite EXCEPT
> all pixels with colour 0. The reason is obvious I think (hope :-). But this
> condition requires a compare for each pixel, which slows the routine down f
> too much. Can this be resolved?

I don't know how fast your is, but the following code is pretty darn fast.
It may actually be just as fast as a regular putimage because it doens't have
to send black colors to the vid memory.  There are a couple words of warning,
however.  The following code will only work for 320x200x256 mode and was
written with a specific getimage format in mind.  The format is simple
(xsize:word,ysize:word,image data), but may be different than TP's getimage.
It's all nice and confusing assembler, but it does work effectively.
One last thing: CurBuf is the location of where the image is to be sent.  If
you want it sent to the vidmem, set CurBuf := ptr($A000,$0);
}
Procedure PutTransparent(x, y : integer; ImagePtr : pointer; tcolor : byte);

{ Similar to PutImage, but if the color is tcolor, it is not plotted }

label jump1,jump2,jump3,jump4;

var
  Addr : word;
  cols : word;
  bcolor : byte;

begin
  Addr := x + (y shl 8) + (y shl 6);

  asm
    push ds
    les di, CurBuf
    add di, Addr
    lds si, ImagePtr
    lodsw
    mov dx, ax                         { image width }
    lodsw
    mov bx, ax                         { image height }

jump1:
    mov cols,dx

  jump2:
      mov ax, 0
      lodsb
      mov bcolor, al
      xor al, tcolor
      not al
      inc ax
      shr ax,8
      inc ax
      mov cx,ax

    loop jump3
        mov al,bcolor
        stosb
        mov cx,5
      loop jump4
    jump3:
      inc di
    jump4:
      mov cx,cols
      dec cols
  loop jump2

    add di, SW
    sub di, dx
    dec bx
jnz jump1
    pop ds
  end
end;

