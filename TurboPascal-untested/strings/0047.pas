{*****************************************************************************
 * Function ...... PadR()
 * Purpose ....... To pad the right side of a string with a character
 * Parameters .... s      String to pad
 *                 c      Character to pad with
 *                 n      New length for <s>
 * Returns ....... <s> padded with character <c> with length <n>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION PADR( s: STRING; n: BYTE; c: CHAR ): STRING; ASSEMBLER;
ASM
      PUSH   DS
      CLD
      LDS    SI, s
      XOR    AX, AX
      LODSB
      MOV    CX, AX

      LES    DI, @Result
      INC    DI
      REP    MOVSB

      MOV    CL, n
      SUB    CL, AL

      CMP    CX, 0
      JNB    @@1
      XOR    CX, CX

@@1:  MOV    AL, c
      REP    STOSB

      MOV    DI, WORD PTR @Result
      MOV    AL, n
      MOV    BYTE PTR ES:[DI], AL

      POP    DS
END;

