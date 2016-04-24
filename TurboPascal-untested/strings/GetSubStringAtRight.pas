(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0051.PAS
  Description: Get SUB STRING at RIGHT
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:24
*)

{*****************************************************************************
 * Function ...... RightAt()
 * Purpose ....... Return the last position of a substring as viewed from
 *                 the right side of the string
 * Parameters .... sub       Substring to locate
 *                 s         String to find <sub> in
 * Returns ....... Numeric last position of <sub> in s, counting from
 *                 right to left.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
*****************************************************************************}
FUNCTION RightAt( sub: STRING; s: STRING ): BYTE; ASSEMBLER;
VAR
   nResult: WORD;
ASM
      PUSH    DS
      XOR     CX, CX

      LDS     SI, sub
      XOR     AX, AX
      LODSB
      MOV     BX, AX
      CMP     BX, 0
      JBE     @@3

      LES     DI, s
      XOR     DX, DX
      MOV     DL, BYTE PTR ES:[DI]
      INC     DI
      CMP     DX, 0
      JBE     @@3

      PUSH    DX

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
      POP     BX
      MOV     AX, nResult
      CMP     AX, 0
      JE      @@6
      XCHG    AX, BX
      SUB     AX, BX
      INC     AX
@@6:  POP     DS
END;


