UNIT HiLo;
(**) INTERFACE (**)
  FUNCTION SwapN(B : Byte) : Byte;
  FUNCTION HiN(B : Byte) : Byte;
  FUNCTION LoN(B : Byte) : Byte;

  FUNCTION SwapW(L : LongInt) : LongInt;
  FUNCTION HiW(L : LongInt) : Word;
  FUNCTION LoW(L : LongInt) : Word;

  FUNCTION WordFromB(H, L : Byte) : Word;
  FUNCTION LongFromW(H, L : Word) : LongInt;

(**) IMPLEMENTATION (**)
  FUNCTION SwapN(B : Byte) : Byte; Assembler;
  ASM
    MOV AL, B         {byte in AL}
    MOV AH, AL        {now in AH too}
    MOV CL, 4         {set up to shift by 4}
    SHL AL, CL        {AL has low nibble -> high}
    SHR AH, CL        {AH has high nibble -> low}
    ADD AL, AH        {combine them}
  END;

  FUNCTION HiN(B : Byte) : Byte; Assembler;
  ASM
    MOV AL, B
    MOV CL, 4
    SHR AL, CL
  END;

  FUNCTION LoN(B : Byte) : Byte; Assembler;
  ASM
    MOV AL, B
    AND AL, 0Fh
  END;

  FUNCTION SwapW(L : LongInt) : LongInt; Assembler;
  ASM
    MOV AX, Word(L+2)
    MOV DX, Word(L)
  END;

  FUNCTION HiW(L : LongInt) : Word; Assembler;
  ASM
    MOV AX, Word(L+2)
  END;

  FUNCTION LoW(L : LongInt) : Word; Assembler;
  ASM
    MOV AX, Word(L);
  END;

  FUNCTION WordFromB(H, L : Byte) : Word; Assembler;
  ASM
    MOV AH, H
    MOV AL, L
  END;

  FUNCTION LongFromW(H, L : Word) : LongInt; Assembler;
  ASM
    MOV DX, H
    MOV AX, L
  END;
END.