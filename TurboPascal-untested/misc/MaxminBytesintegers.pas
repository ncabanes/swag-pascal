(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0056.PAS
  Description: MAXMIN Bytes/Integers
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:41
*)

{$R-}
UNIT MaxMin;
(**) INTERFACE (**)
  FUNCTION MaxS(A, B : ShortInt) : ShortInt;
  FUNCTION MinS(A, B : ShortInt) : ShortInt;
  FUNCTION MaxB(A, B : Byte)     : Byte;
  FUNCTION MinB(A, B : Byte)     : Byte;
  FUNCTION MaxI(A, B : Integer)  : Integer;
  FUNCTION MinI(A, B : Integer)  : Integer;
  FUNCTION MaxW(A, B : Word)     : Word;
  FUNCTION MinW(A, B : Word)     : Word;
  FUNCTION MaxL(A, B : LongInt)  : LongInt;
  FUNCTION MinL(A, B : LongInt)  : LongInt;
  FUNCTION MaxU(A, B : LongInt)  : LongInt;
  FUNCTION MinU(A, B : LongInt)  : LongInt;

(**) IMPLEMENTATION (**)
  FUNCTION MaxS(A, B : ShortInt) : ShortInt; Assembler;
  ASM
    MOV AL, A
    CMP AL, B
    JGE @no
    MOV AL, B
    @no:
  END;

  FUNCTION MinS(A, B : ShortInt) : ShortInt; Assembler;
  ASM
    MOV AL, A
    CMP AL, B
    JLE @no
    MOV AL, B
    @no:
  END;

  FUNCTION MaxB(A, B : Byte) : Byte; Assembler;
  ASM
    MOV AL, A
    CMP AL, B
    JAE @no
    MOV AL, B
    @no:
  END;

  FUNCTION MinB(A, B : Byte) : Byte; Assembler;
  ASM
    MOV AL, A
    CMP AL, B
    JBE @no
    MOV AL, B
    @no:
  END;

  FUNCTION MaxI(A, B : Integer) : Integer; Assembler;
  ASM
    MOV AX, A
    CMP AX, B
    JGE @no
    MOV AX, B
    @no:
  END;

  FUNCTION MinI(A, B : Integer) : Integer; Assembler;
  ASM
    MOV AX, A
    CMP AX, B
    JLE @no
    MOV AX, B
    @no:
  END;

  FUNCTION MaxW(A, B : Word) : Word; Assembler;
  ASM
    MOV AX, A
    CMP AX, B
    JAE @no
    MOV AX, B
    @no:
  END;

  FUNCTION MinW(A, B : Word) : Word; Assembler;
  ASM
    MOV AX, A
    CMP AX, B
    JBE @no
    MOV AX, B
    @no:
  END;

  FUNCTION MaxL(A, B : LongInt) : LongInt; Assembler;
  ASM
    MOV DX, Word(A+2)
    MOV AX, Word(A)
    CMP DX, Word(B+2)
    JL @yes
    JG @no
    CMP AX, Word(B)
    JGE @no
    @yes:
    MOV DX, Word(B+2)
    MOV AX, Word(B)
    @no:
  END;

  FUNCTION MinL(A, B : LongInt) : LongInt; Assembler;
  ASM
    MOV DX, Word(A+2)
    MOV AX, Word(A)
    CMP DX, Word(B+2)
    JG @yes
    JL @no
    CMP AX, Word(B)
    JLE @no
    @yes:
    MOV DX, Word(B+2)
    MOV AX, Word(B)
    @no:
  END;

  FUNCTION MaxU(A, B : LongInt) : LongInt; Assembler;
  ASM
    MOV DX, Word(A+2)
    MOV AX, Word(A)
    CMP DX, Word(B+2)
    JB @yes
    JA @no
    CMP AX, Word(B)
    JAE @no
    @yes:
    MOV DX, Word(B+2)
    MOV AX, Word(B)
    @no:
  END;

  FUNCTION MinU(A, B : LongInt) : LongInt; Assembler;
  ASM
    MOV DX, Word(A+2)
    MOV AX, Word(A)
    CMP DX, Word(B+2)
    JA @yes
    JB @no
    CMP AX, Word(B)
    JBE @no
    @yes:
    MOV DX, Word(B+2)
    MOV AX, Word(B)
    @no:
  END;
END.
