(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0090.PAS
  Description: Bank Switching
  Author: JOHN IOZIA
  Date: 01-27-94  12:21
*)


Procedure SetBank(b : byte); Assembler; {vesa}
Asm
  mov AX, 4f05h
  xor DX, DX
  mov Dl, b
  Int 10h
END;


