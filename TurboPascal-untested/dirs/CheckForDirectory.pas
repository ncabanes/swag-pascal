(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0018.PAS
  Description: Check for Directory
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:10
*)


{*****************************************************************************
 * Function ...... IsDir()
 * Purpose ....... To check for the existance of a directory
 * Parameters .... Dir        Dir to check for
 * Returns ....... TRUE if Dir exists
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION IsDir( Dir: STRING ) : BOOLEAN;
VAR
   fHandle: FILE;
   wAttr: WORD;
BEGIN
     WHILE Dir[LENGTH(Dir)] = '\' DO DEC( Dir[0] );
     Dir := Dir + '\.';
     ASSIGN( fHandle, Dir );
     GETFATTR( fHandle, wAttr );
     IsDir := ( (wAttr AND DIRECTORY) = DIRECTORY );
END;


