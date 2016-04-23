{*****************************************************************************
 * Function ...... Stuff()
 * Purpose ....... To stuff a string with a sub-string
 * Parameters .... Dest       String to stuff into
 *                 Pos        Position in <Dest> to start inserting
 *                 Num        Number of characters to overwrite in <Dest>
 *                 Source     String to stuff into <Dest>
 * Returns ....... <Dest> stuffed with <Source> at postion <Pos>
 * Notes ......... Uses the function Left.
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Stuff( Dest : STRING; Pos, Num : INTEGER; Source : STRING ) : STRING;
BEGIN
     IF LENGTH( Source ) > Num THEN Source := Left( Source, Num );
     DELETE( Dest, Pos, Num );
     INSERT( Source, Dest, Pos );
     Stuff := Dest;
END; { Stuff }

