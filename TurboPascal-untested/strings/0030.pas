{*****************************************************************************
 * Function ...... Comma
 * Purpose ....... To return an integer as a string with separating commas
 * Parameters .... i          Integer to return as string
 * Returns ....... i as a string, with seperating commas
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Comma( i: LONGINT ): STRING;
{ FUNCTION to place commas in a number for printing }
VAR 
   s: STRING;
   x: INTEGER;
BEGIN
     STR( i:0, s );
     x := LENGTH( s ) - 2;
     WHILE x > 1 DO BEGIN
           INSERT( ',', s, x );
           DEC( x, 3 );
     {W}END;
     Comma := s;
END;

