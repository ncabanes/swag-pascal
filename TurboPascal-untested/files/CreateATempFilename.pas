(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0030.PAS
  Description: Create a TEMP filename
  Author: MARTIN RICHARDSON
  Date: 09-26-93  09:30
*)

{*****************************************************************************
 * Function ...... TempFile()
 * Purpose ....... To create a unique file name for use as a temporary work
 *                 file
 * Parameters .... Path       Location to create the file
 * Returns ....... Name of temporary file
 * Notes ......... Uses the functions Right, ItoS, Exist, and Empty
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION TempFile( Path: STRING ): STRING;
VAR 
   DateStr  : DateTime;
   Trash    : WORD;
   Time     : LONGINT;
   FileName : STRING;
BEGIN
     IF (NOT Empty( Path )) AND (Right( Path, 1 ) <> '\') THEN
        Path := Path + '\';
     REPEAT
           WITH DateStr DO BEGIN
                GETDATE( Year, Month, Day, Trash );
                GETTIME( Hour, Min, Sec, Trash );
           END;
           PackTime( DateStr, Time );
           FileName := Right( ItoS( Time, 0 ), 8 ) + '.$$$';
     UNTIL NOT Exist( Path + FileName );
     TempFile := Path + FileName;
END;

