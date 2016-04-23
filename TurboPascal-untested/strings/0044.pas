{*****************************************************************************
 * Function ...... LowerCase()
 * Purpose ....... To convert a string to all lower case
 * Parameters .... s          String to convert
 * Returns ....... <s> in all lower case leters
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION LowerCase( s: STRING ): STRING; ASSEMBLER;
ASM
      PUSH   DS
      CLD
      LDS    SI, s
      XOR    AX, AX
      LODSB
      XCHG   AX, CX
      LES    DI, @Result
      MOV    BYTE PTR ES:[DI], CL
      JCXZ   @@3

@@1:  LODSB
      CMP    AL, 'A'
      JB     @@2
      CMP    AL, 'Z'
      JA     @@2
      OR     AL, $20

@@2:  STOSB
      LOOP   @@1

@@3:  POP    DS
END;

