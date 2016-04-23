{*****************************************************************************
 * Function ...... GetMask()
 * Purpose ....... To return the mask from a path/mask string
 * Parameters .... Path       String to extract the mask from
 * Returns ....... The file mask portion of <Path>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
TYPE
     String13 = STRING[13];
FUNCTION GetMask( Path: DirStr ): String13;
VAR dir  : DirStr;
    name : NameStr;
    ext  : ExtStr;
BEGIN
     FSPLIT( path, dir, name, ext );
     GetMask := name + ext;
END;

