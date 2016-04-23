{*****************************************************************************
 * Function ...... Rat()
 * Purpose ....... Locate the last occurance of a substring in a string
 * Parameters .... sub        Substring to locate
 *                 s          String to look for <sub> in
 * Returns ....... Numeric last position of <sub> in s, counting from
 *                 left to right.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION Rat( sub: STRING; s: STRING ): BYTE; ASSEMBLER;
VAR
   nResult: WORD;
ASM
      PUSH    DS
      XOR     CX, CX
      XOR     BX, BX

      LDS     SI, sub
      XOR     AX, AX
      LODSB
      XCHG    BX, AX

      CMP     BX, 0
      JBE     @@3

      LES     DI, s
      LODSB
      MOV     DX, AX
      CMP     DX, 0
      JBE     @@3

      CMP     BX, DX
      JAE     @@3

      DEC     BX
      CLD
@@1:  MOV     SI, WORD PTR sub
      INC     SI
      LODSB

      MOV     CX, DX
      REPNE   SCASB
      JNZ     @@3

      MOV     DX, CX
      MOV     CX, BX
      REPE    CMPSB
      JZ      @@4

      ADD     DI, CX
      SUB     DI, BX
@@2:  CMP     DX, BX
      JA      @@1
@@3:  XOR     AL, AL
      JMP     @@5
@@4:  SUB     DI, BX
      DEC     DI
      SUB     DI, WORD PTR s
      MOV     nResult, DI
      ADD     DI, WORD PTR s
      ADD     DI,CX
      INC     DI
      JMP     @@2
@@5:
      MOV     AX, nResult
      POP     DS
END;

