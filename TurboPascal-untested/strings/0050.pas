{*****************************************************************************
 * Function ...... Right()
 * Purpose ....... To return the right part of a string
 * Parameters .... s         String to return the right part of
 *                 n         Number of characters to return
 * Returns ....... A string containing the <n> rightmost characters of <n>.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION Right( s: STRING; n: BYTE ): STRING; ASSEMBLER;
ASM
      PUSH    DS
      LES     DI, @Result

      LDS     SI, s
      MOV     AL, n
      CLD
      XOR     CX, CX

      MOV     CL, BYTE PTR [SI]
      INC     SI
      CMP     CX, 0
      JZ      @@2
      CMP     AL, 0
      JLE     @@1

      MOV    BYTE PTR ES:[DI], AL
      INC    DI

      SUB    CL, AL
      ADD    SI, CX
      MOV    CL, AL

      REP    MOVSB
      JMP    @@3

@@1:  MOV     CL, 0
@@2:  MOV     BYTE PTR ES:[DI], CL
@@3:  POP     DS
END;

