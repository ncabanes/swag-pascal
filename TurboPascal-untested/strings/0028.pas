{ KELD R. HANSEN }

PROCEDURE AddStr(VAR STR : OpenString ; CONST ADD : STRING); ASSEMBLER;
ASM
  PUSH    DS
  LDS     SI,ADD
  LES     DI,STR
  CLD
  XOR     BH,BH
  MOV     BL,ES:[DI]
  LODSB
  MOV     AH,BYTE PTR STR-2
  ADD     AL,BL
  JC      @OVF
  CMP     AL,AH
  JBE     @OK
 @OVF:
  MOV     AL,AH
 @OK:
  STOSB
  XOR     CH,CH
  MOV     CL,AL
  SUB     CL,BL
  ADD     DI,BX
  REP     MOVSB
  POP     DS
END;

PROCEDURE AddChar(VAR STR : OpenString ; C : CHAR); ASSEMBLER;
ASM
  LES     DI,STR
  XOR     AH,AH
  MOV     AL,ES:[DI]
  CMP     AX,WORD PTR STR-2
  JAE     @OUT
  INC     AL
  JZ      @OUT
  MOV     ES:[DI],AL
  ADD     DI,AX
  MOV     AL,C
  STOSB
 @OUT:
END;
