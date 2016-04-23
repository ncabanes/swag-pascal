{*****************************************************************************
 * Function ...... Left()
 * Purpose ....... To return the left part of a string
 * Parameters .... s         String to return the left part of
 *                 n         Number of characters to return
 * Returns ....... A string containing the <n> leftmost characters of <n>.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION Left( s: STRING; n: BYTE ): STRING; ASSEMBLER;
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
      MOV    CL, AL

      REP    MOVSB
      JMP    @@3

@@1:  MOV     CL, 0
@@2:  MOV     ES:[DI],CL

@@3:  POP     DS
END;
       
