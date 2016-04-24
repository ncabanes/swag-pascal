(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0041.PAS
  Description: Convert INTEGER to string
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:12
*)

{*****************************************************************************
 * Function ...... ITOS()
 * Purpose ....... Convert an integer to a string <nSpaces> in length
 * Parameters .... nNum       Integer to convert
 *                 nSpaces    Length of resultant string
 * Returns ....... nNum as a string, <nSpaces> in length
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION ITOS( nNum: LONGINT; nSpaces: INTEGER ): STRING;
VAR
   s: ^STRING;
BEGIN
     ASM  
          mov     sp, bp 
          push    ss
          push    WORD PTR @RESULT
     END;

     IF nSpaces > 0 THEN
         STR( nNum:nSpaces, s^ )
     ELSE
         STR( nNum:0, s^ );
END;


