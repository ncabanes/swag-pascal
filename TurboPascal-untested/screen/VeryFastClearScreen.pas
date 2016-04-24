(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0038.PAS
  Description: Very FAST Clear Screen
  Author: BRIAN PAPE
  Date: 11-02-93  05:26
*)

{
BRIAN PAPE

>Mike, thought i would share a different way to clear the screen
>it clears the screen directly and tends to be faster
}

Procedure ClrScr(attr : Byte; ch : Char); Assembler;
Asm
  mov  ax, $b800
  mov  es, ax
  xor  di, di
  mov  cx, 80*25
  mov  ah, attr
  mov  al, &ch
  rep  stosw
end;

