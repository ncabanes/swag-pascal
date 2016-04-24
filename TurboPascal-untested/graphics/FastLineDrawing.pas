(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0107.PAS
  Description: Fast Line Drawing
  Author: JENS LARSSON
  Date: 08-24-94  13:37
*)

{
 SS> I'm looking for a qwick way to draw a line... All I need are
 SS> horizontal and vertical lines, so would it be easiest to use a
 SS> series of PutPixels?

Unfortunately you don't specify which mode you're working in, so
I assume it is 320x200 (which tends to be the most popular mode here):
}

Procedure DHL(x, y, Length : Word; Color : Byte); Assembler;
  Asm
    mov   ax,0a000h
    mov   es,ax
    mov   ax,y
    shl   ax,6
    mov   di,ax
    shl   ax,2
    add   di,ax
    add   di,x
    mov   cx,Length
    mov   al,Color
    cld
    rep   stosb { I bet I'll get loads of replies which uses stosw instead :) }
  End;

Procedure DVL(x, y, Length : Word; Color : Byte); Assembler;
  Asm
    mov   ax,0a000h
    mov   es,ax
    mov   ax,y
    shl   ax,6
    mov   di,ax
    shl   ax,2
    add   di,ax
    add   di,x
    mov   al,Color
    mov   cx,Length
@DVL1:
    mov   es:[di],al
    add   di,320
    dec   cx
    jnz   @DVL1
  End;


