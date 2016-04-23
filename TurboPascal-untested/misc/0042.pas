{*****************************************************************************
 * Function ...... STOI()
 * Purpose ....... To convert a string to an integer
 * Parameters .... cNum       String to convert to integer format
 * Returns ....... cNum as a numeric integer
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION STOI( cNum: STRING ): LONGINT;
VAR
   c: INTEGER;
   i: LONGINT;
BEGIN
     VAL( cNum, i, c );
     STOI := i;
END;

