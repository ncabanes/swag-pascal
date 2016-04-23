
Procedure SetBank(b : byte); Assembler; {vesa}
Asm
  mov AX, 4f05h
  xor DX, DX
  mov Dl, b
  Int 10h
END;

