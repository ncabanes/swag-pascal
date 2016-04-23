{*****************************************************************************
 * Function ...... StripChar;
 * Purpose ....... To removed a specified character from a string.
 * Parameters .... s       String to remove character from
 *                 c       Character to remove
 * Returns ....... String <s> with character <c> removed.
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION StripChar( s: STRING; c: CHAR ): STRING; Assembler;
ASM
      PUSH   DS
      CLD
      LDS    SI, s
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      INC    DI
      JCXZ   @@3
      MOV    BL, c

@@1:  LODSB
      CMP    AL, BL
      JE     @@2
      STOSB

@@2:  LOOP   @@1

@@3:  XCHG   AX, DI
      MOV    DI, WORD PTR @Result
      SUB    AX, DI
      DEC    AX
      STOSB
      POP    DS
END;

