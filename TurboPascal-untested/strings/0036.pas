{*****************************************************************************
 * Function ...... GetPath()
 * Purpose ....... To return the path from a path/mask string
 * Parameters .... Path       String to extract the path from
 * Returns ....... <Path> minus the mask
 * Notes ......... Trailing slash *IS* included if it is there
 *                 (eg, C:\PROGRAM\PASCAL\)
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION GetPath( Path: DirStr ): DirStr;
VAR
   dir : DirStr;
   name: NameStr;
   ext : ExtStr;
BEGIN
     FSPLIT( path, dir, name, ext );
     GetPath := Dir;
END;

