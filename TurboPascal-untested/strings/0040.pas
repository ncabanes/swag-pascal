{*****************************************************************************
 * Function ...... InStrR
 * Purpose ....... To locate a substring in a string starting at a given
 *                 position from the right of the string.
 * Parameters .... n        Position in the string to start searching
 *                 sub      Substring to search for
 *                 s        String to search in
 * Returns ....... Numeric position of <sub> in string <s> after position <n>
 *                 from right to left.
 * Notes ......... Uses function Right
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION InStrR( n: BYTE; sub: STRING; s: STRING ): BYTE;
VAR i: INTEGER;
BEGIN
     i := POS( sub, Right( s, LENGTH(s)-n+1 ) ) + n - 1;
     IF i = 0 THEN
         InStrR := i
     ELSE
         InStrR := LENGTH( s ) - i + 1;
END;

