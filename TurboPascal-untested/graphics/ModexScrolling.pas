(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0055.PAS
  Description: ModeX Scrolling
  Author: JENS LARSSON
  Date: 01-27-94  12:14
*)

{
> does anyone know how to scroll up or down in 320*200*256 mode ??

     Enter mode-x (look for source on any board, quite common), and
     then pan the screen like this:
}

     Asm
      mov     bx,StartMem
      mov     ah,bh
      mov     al,0ch
      mov     dx,3d4h
      out     dx,ax
      mov     ah,bl
      inc     al
      out     dx,ax
     End;
{
     To begin, zero StartMem and then increase it with 80 each time -
     tada - the screen pans down. Oh, btw, If I were you I would call
     a sync just before running it...
}
