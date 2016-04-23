{ Checks the existance of a file.
  Part of the Heartware Toolkit v2.00 (HTfile.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION File_Found(FName : string) : integer;
{ DESCRIPTION:
    Checks the existance of a file.
  SAMPLE CALL:
    I := File_Found('C:\COMMAND.COM');
  RETURNS:
     0   : file was found
    18   : file was NOT found
    else : DosError code }

var
  SR : SearchRec;

BEGIN { File_Found }
  {$I-}
  FindFirst(FName,Archive,SR);
  File_Found := DosError;
  {$I+}
END; { File_Found }
