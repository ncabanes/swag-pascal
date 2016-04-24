(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0181.PAS
  Description: Mode 13 Fast Clear Screen
  Author: SCOTT SEARLE
  Date: 11-26-94  04:59
*)

{
> How do I clear the screen fast (asm code please) in mode 13h
> (320x200x256)???????
}
Procedure ClearScreen(Col : Byte); assembler;
asm
   mov  ax, $A000
   mov  es, ax
   mov  cx, 32000
   xor  di, di
   mov  al, Col
   mov  ah, al
   rep  stosw
end;
{ that should do it.  It'll clear it to Col }

