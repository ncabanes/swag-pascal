{
KELD R. HANSEN
}

PROCEDURE TidyString(VAR Str : String); ASSEMBLER;
ASM
  LES     DI,STR
  XOR     BH,BH
  MOV     BL,ES:[DI]
  LEA     DI,[DI+BX+1]
  MOV     SI,WORD PTR STR-2
  NEG     BX
  LEA     CX,[SI+BX]
  XOR     AL,AL
  CLD
  REP     STOSB
END;

{
which fills up the garbage after the current string length with zeroes.
}

