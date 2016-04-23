{*****************************************************************************
 * Function ...... RTOS()
 * Purpose ....... To convert a REAL to a string
 * Parameters .... nNum       REAL to convert to string format
 *                 nLength    Length of resultant string
 *                 nDec       Decimal places
 * Returns ....... <nNum> as a string, <nLength> long to <nDec> decimal places
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION RTOS( nNum: REAL; nLength, nDec: INTEGER ): STRING;
VAR
   s: ^STRING;
BEGIN
     ASM  
          mov     sp, bp 
          push    ss
          push    WORD PTR @RESULT
     END;
     STR( nNum:nLength:nDec, s^ );
END;

