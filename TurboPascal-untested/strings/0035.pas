{*****************************************************************************
 * Function ...... GetName()
 * Purpose ....... To return the file name (minus .EXT) from a path/mask
 *                 string.
 * Parameters .... Path         File path/mask to return the name from
 * Returns ....... 8 character DOS file name without extension
 * Notes ......... Uses functions Empty and Replicate
 * Author ........ Martin Richardson
 * Date .......... October 23, 1992
 *****************************************************************************}
FUNCTION GetName( Path : DirStr ): NameStr;
VAR dir  : DirStr;
    name : NameStr;
    ext  : ExtStr;
BEGIN
     FSPLIT( path, dir, name, ext );
     IF NOT Empty( Name ) THEN
        GetName := Name
     ELSE IF NOT Empty( Ext ) THEN
        GetName := Ext
     ELSE
        GetName := Replicate( ' ', SIZEOF( Name ) );
END;

