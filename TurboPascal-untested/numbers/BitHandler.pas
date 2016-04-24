(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0037.PAS
  Description: Bit Handler
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:25
*)

UNIT Bits;
(**) INTERFACE (**)
TYPE
  bbit = 0..7;
  wbit = 0..15;
  lbit = 0..31;

  PROCEDURE SetBitB(VAR B : Byte; bit : bbit);
  PROCEDURE ClearBitB(VAR B : Byte; bit : bbit);
  PROCEDURE ToggleBitB(VAR B : Byte; bit : bbit);
  FUNCTION BitSetB(B : Byte; bit : bbit) : Boolean;
  FUNCTION BitClearB(B : Byte; bit : bbit) : Boolean;

  PROCEDURE SetBitW(VAR W : Word; bit : wbit);
  PROCEDURE ClearBitW(VAR W : Word; bit : wbit);
  PROCEDURE ToggleBitW(VAR W : Word; bit : wbit);
  FUNCTION BitSetW(W : Word; bit : wbit) : Boolean;
  FUNCTION BitClearW(W : Word; bit : wbit) : Boolean;

  PROCEDURE SetBitL(VAR L : LongInt; bit : lbit);
  PROCEDURE ClearBitL(VAR L : LongInt; bit : lbit);
  PROCEDURE ToggleBitL(VAR L : LongInt; bit : lbit);
  FUNCTION BitSetL(L : LongInt; bit : lbit) : Boolean;
  FUNCTION BitClearL(L : LongInt; bit : lbit) : Boolean;

(**) IMPLEMENTATION (**)
  PROCEDURE SetBitB(VAR B : Byte; bit : bbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BL, 1
    SHL BL, CL      {BL contains 2-to-the-bit}
    LES DI, B
    OR ES:[DI], BL  {OR turns on bit}
  END;

  PROCEDURE ClearBitB(VAR B : Byte; bit : bbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BL, 1
    SHL BL, CL      {BL contains 2-to-the-bit}
    NOT BL
    LES DI, B
    AND ES:[DI], BL {AND of NOT BL turns off bit}
  END;

  PROCEDURE ToggleBitB(VAR B : Byte; bit : bbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BL, 1
    SHL BL, CL      {BL contains 2-to-the-bit}
    LES DI, B
    XOR ES:[DI], BL {XOR toggles bit}
  END;

  FUNCTION BitSetB(B : Byte; bit : bbit) : Boolean;
             Assembler;
  ASM
    MOV CL, bit
    MOV BL, 1
    SHL BL, CL      {BL contains 2-to-the-bit}
    MOV AL, 0       {set result to FALSE}
    TEST B, BL
    JZ @No
    INC AL          {set result to TRUE}
    @No:
  END;

  FUNCTION BitClearB(B : Byte; bit : bbit) : Boolean;
             Assembler;
  ASM
    MOV CL, bit
    MOV BL, 1
    SHL BL, CL      {BL contains 2-to-the-bit}
    MOV AL, 0       {set result to FALSE}
    TEST B, BL
    JNZ @No
    INC AL          {set result to TRUE}
    @No:
  END;

  PROCEDURE SetBitW(VAR W : Word; bit : wbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    LES DI, W
    OR ES:[DI], BX  {OR turns on bit}
  END;

  PROCEDURE ClearBitW(VAR W : Word; bit : wbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    NOT BX
    LES DI, W
    AND ES:[DI], BX {AND of NOT BX turns off bit}
  END;

  PROCEDURE ToggleBitW(VAR W : Word; bit : wbit);
              Assembler;
  ASM
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    LES DI, W
    XOR ES:[DI], BX {XOR toggles bit}
  END;

  FUNCTION BitSetW(W : Word; bit : wbit) : Boolean;
             Assembler;
  ASM
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    MOV AL, 0       {set result to FALSE}
    TEST W, BX
    JZ @No
    INC AL          {set result to TRUE}
    @No:
  END;

  FUNCTION BitClearW(W : Word; bit : wbit) : Boolean;
             Assembler;
  ASM
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    MOV AL, 0       {set result to FALSE}
    TEST W, BX
    JNZ @No
    INC AL          {set result to TRUE}
    @No:
  END;

  PROCEDURE SetBitL(VAR L : LongInt; bit : lbit);
              Assembler;
  ASM
    LES DI, L
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    JZ @TopWord     {if zero, use high word}
    OR ES:[DI], BX  {OR turns on bit}
    JMP @Finish
    @TopWord:
    SUB CL, 16
    MOV BX, 1
    SHL BX, CL
    OR ES:[DI+2], BX
    @Finish:
  END;

  PROCEDURE ClearBitL(VAR L : LongInt; bit : lbit);
              Assembler;
  ASM
    LES DI, L
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    JZ @TopWord     {if zero, use high word}
    NOT BX
    AND ES:[DI], BX {AND of NOT BX turns off bit}
    JMP @Finish
    @TopWord:
    SUB CL, 16
    MOV BX, 1
    SHL BX, CL
    NOT BX
    AND ES:[DI+2], BX
    @Finish:
  END;

  PROCEDURE ToggleBitL(VAR L : LongInt; bit : lbit);
              Assembler;
  ASM
    LES DI, L
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    JZ @TopWord     {if zero, use high word}
    XOR ES:[DI], BX {XOR toggles bit}
    JMP @Finish
    @TopWord:
    SUB CL, 16
    MOV BX, 1
    SHL BX, CL
    XOR ES:[DI+2], BX
    @Finish:
  END;

  FUNCTION BitSetL(L : LongInt; bit : lbit) : Boolean;
             Assembler;
  ASM
    MOV AL, 0       {set result to FALSE}
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    JZ @TopWord     {if zero, use high word}
    TEST Word(L), BX
    JMP @Finish
    @TopWord:
    SUB CL, 16
    MOV BX, 1
    SHL BX, CL
    TEST Word(L+2), BX
    @Finish:
    JZ @No
    INC AL          {set result to TRUE}
    @No:
  END;

  FUNCTION BitClearL(L : LongInt; bit : lbit) : Boolean;
             Assembler;
  ASM
    MOV AL, 0       {set result to FALSE}
    MOV CL, bit
    MOV BX, 1
    SHL BX, CL      {BX contains 2-to-the-bit}
    JZ @TopWord     {if zero, use high word}
    TEST Word(L), BX
    JMP @Finish
    @TopWord:
    SUB CL, 16
    MOV BX, 1
    SHL BX, CL
    TEST Word(L+2), BX
    @Finish:
    JNZ @No
    INC AL          {set result to TRUE}
    @No:
  END;
END.

