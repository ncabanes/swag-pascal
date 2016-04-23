{*****************************************************************************
 * Function ...... StrZero()
 * Purpose ....... To return a number as a string with leading zeros
 * Parameters .... Num        Number to make into a string
 *                 Len        Length of resultant string
 * Returns ....... <Num> as a string, <Len> in length with leading zeros
 * Notes ......... Uses the functions PadL and ITOS
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION StrZero( Num, Len : LONGINT ) : STRING;
BEGIN
     StrZero := PadL( ITOS( Num, 0 ), Len, '0' );
END; { StrZero }

