(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0029.PAS
  Description: Check if IS File
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:11
*)

uses Dos;

{*****************************************************************************
 * Function ...... IsFile()
 * Purpose ....... Checks for the existance of a file
 * Parameters .... sFile      File to check for
 * Returns ....... TRUE if sFile exists
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
{ Checks for existance of a file }
FUNCTION IsFile( sFile: STRING ): BOOLEAN;
VAR s : SearchRec;
BEGIN
    FINDFIRST( sFile, directory, s );
    IsFile := (DOSError = 0) AND
        (s.Attr AND Directory <> Directory) AND
        (POS( '?', sFile ) = 0) AND
        (POS( '*', sFile ) = 0);
END;

BEGIN
    if IsFile('CheckIfIsFile.pas') then
        WriteLn('CheckIfIsFile.pas is a valid file')
    else
        WriteLn('CheckIfIsFile.pas is not a valid file (or not found)');
    
    if IsFile('1.pas') then
        WriteLn('1.pas is a valid file')
    else
        WriteLn('1.pas is not a valid file (or not found)');
    
    if IsFile('*.pas') then
        WriteLn('*.pas is a valid file')
    else
        WriteLn('*.pas is not a valid file (or not found)');
END.
