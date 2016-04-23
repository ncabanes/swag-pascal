{*****************************************************************************
 * Function ...... StrTran()
 * Purpose ....... To replace portions of a string
 * Parameters .... Source          Master string to do the replace in
 *                 Old             Portion to replace
 *                 New             New portion to replace <old> with
 * Returns ....... Source with all occurances of <old> replaced with <new>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION StrTran( Source, Old, New : STRING ) : STRING;
VAR p : INTEGER;
BEGIN
     WHILE POS( Old, Source ) <> 0 DO BEGIN
           p := POS( Old, Source );
           DELETE( Source, p, LENGTH( Old ) );
           INSERT( New, Source, p );
     {W}END;
     StrTran := Source;
END; { StrTran }

