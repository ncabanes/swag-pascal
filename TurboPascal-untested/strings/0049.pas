{*****************************************************************************
 * Function ...... Replicate()
 * Purpose ....... To duplicate a character a certain number of times
 * Parameters .... c         Character to duplicate
 *                 n         Number of times to duplicate <c>
 * Returns ....... A string <n> long filled with character <c>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION Replicate( c: CHAR; n: BYTE ): STRING; ASSEMBLER;
ASM
      XOR    CX, CX
      MOV    AL, c
      MOV    CL, n
      LES    DI, @Result
      MOV    BYTE PTR ES:[DI], CL
      INC    DI
      CLD
      REP    STOSB
END;

