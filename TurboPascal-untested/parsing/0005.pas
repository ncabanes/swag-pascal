{*****************************************************************************
 * Function ...... ParseCount()
 * Purpose ....... To count the number of tokens in a string
 * Parameters .... cString      String to count tokens in
 *                 cChar        Token separator
 * Returns ....... Number of tokens in <cString>
 * Notes ......... Uses function StripChar
 * Author ........ Martin Richardson
 * Date .......... September 30, 1992
 *****************************************************************************}
FUNCTION ParseCount( cString: STRING; cChar: CHAR ): INTEGER;
BEGIN
     ParseCount := LENGTH(cString) - LENGTH(StripChar(cString, cChar)) + 1;
END;

{*****************************************************************************
 * Function ...... Parse()
 * Purpose ....... To parse out tokens from a string
 * Parameters .... cString      String to parse
 *                 nIndex       Token number to return
 *                 cChar        Token separator
 * Returns ....... Token <nIndex> extracted from <cString>
 * Notes ......... If <nIndex> is greater than the number of tokens in
 *                 <cString> then a null string is returned.
 *               . Uses function Left, Right, and ParseCount
 * Author ........ Martin Richardson
 * Date .......... September 30, 1992
 *****************************************************************************}
FUNCTION Parse( cString: STRING; nIndex: INTEGER; cChar: CHAR ): STRING;
VAR 
   i: INTEGER;
   cResult: STRING;
BEGIN
     IF nIndex > ParseCount( cString, cChar ) THEN
        cResult := ''
     ELSE BEGIN
          cString := cString + cChar;
          FOR i := 1 TO nIndex DO BEGIN
              cResult := Left( cString, POS( cChar, cString ) - 1 );
              cString := Right(cString, LENGTH(cString) - POS(cChar, cString));
          END { Next I };
     END { IF };
     Parse := cResult;
END;

