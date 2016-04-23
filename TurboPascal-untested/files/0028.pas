{*****************************************************************************
 * Function ...... Exist()
 * Purpose ....... Checks for the existance of a file/directory
 * Parameters .... sExp       File/directory name to check for
 * Returns ....... TRUE if sExp exists
 * Notes ......... Not picky, will even accept wild cards
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Exist( sExp: STRING ): BOOLEAN;
VAR s : SearchRec;
BEGIN
     FINDFIRST( sExp, AnyFile, s );
     Exist := (DOSError = 0);
END;

