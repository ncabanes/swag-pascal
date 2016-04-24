(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0052.PAS
  Description: DOS pipe as input
  Author: LEE KIRBY
  Date: 05-25-94  08:08
*)


PROGRAM DFile;

{ Purpose: Given, DIR [filespec] /S /B, delete all occurrences of [filespec] }
{          from the current directory on.                                    }
{ Example: dir *.bak /s /b | dfile                                           }

VAR
   In_File       : TEXT;    { for standard input }
   Key           : CHAR;    { for user confirmation }
   Files_Deleted : INTEGER; { for number of files deleted }

FUNCTION GetKey : CHAR;

{ The ASCII code is in AL, which is the place you need }
{ it to be as the byte return value of a function. }
{ Provided by Drew Veliath of 1:272/60@fidonet.org }

INLINE ( $B4 / $00 /  { MOV AH,0 }
         $CD / $16 ); { INT $16 }

PROCEDURE Delete_Files ( VAR In_File       : TEXT;
                         VAR Files_Deleted : INTEGER );
VAR
   Trgt_File : TEXT;    { for file to be deleted }
   File_Spec : STRING;  { for filespec entered by user }

BEGIN
   WHILE NOT EOF ( In_File ) DO BEGIN
      READLN ( In_File, File_Spec );
      ASSIGN ( Trgt_File, File_Spec );
      {$I-}
      ERASE ( Trgt_File );
      {$I+}
      IF IORESULT = 0 THEN BEGIN
         INC ( Files_Deleted );
         WRITELN ( 'Deleted ', File_Spec )
         END { IF IORESULT = 0 }
      END { WHILE NOT EOF ( In_File ) }
END; { PROCEDURE Delete_Files }

BEGIN { main program }
   WRITE (  'Are you sure [yn]?  ' );
   Key := GetKey;
   WRITELN;
   Files_Deleted := 0;
   IF UPCASE ( Key ) = 'Y' THEN BEGIN
      ASSIGN ( In_File, '' );  { assign In_File to standard input }
      RESET ( In_File );
      Delete_Files ( In_File, Files_Deleted );
      CLOSE ( In_File )
      END; { IF UPCASE ( Key ) = 'Y' }
   WRITELN;
   WRITELN ( Files_Deleted, ' file(s) deleted.' )
END. { main program }

