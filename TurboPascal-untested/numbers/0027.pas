{*****************************************************************************
 * Function ...... wHi()
 * Purpose ....... Return the High order word from a longint (double word)
 * Parameters .... n          LONGINT to retrieve high word from
 * Returns ....... High word from n
 * Notes ......... HI only returns the HIgh byte from a word.  I needed
 *                 something that returned the high WORD from a LONGINT.
 * Author ........ Martin Richardson
 * Date .......... October 9, 1992
 *****************************************************************************}
FUNCTION wHi( n: LONGINT ): WORD; ASSEMBLER;
ASM
   MOV  AX, WORD PTR n[2]
END;

