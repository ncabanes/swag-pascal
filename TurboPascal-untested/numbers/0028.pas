{*****************************************************************************
 * Function ...... wLo()
 * Purpose ....... Return the low order word from a longint (double word)
 * Parameters .... n          LONGINT to retrieve low word from
 * Returns ....... Low word from n
 * Notes ......... LO only returns the LOw byte from a word.  I needed
 *                 something that returned the low WORD from a LONGINT.
 * Author ........ Martin Richardson
 * Date .......... October 9, 1992
 *****************************************************************************}
FUNCTION wLo( n: LONGINT ): WORD; ASSEMBLER;
ASM
   MOV  AX, WORD PTR n[0]
END;

