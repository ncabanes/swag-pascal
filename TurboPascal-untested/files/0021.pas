{ Gets size of existing file, in bytes.
  Part of the Heartware Toolkit v2.00 (HTfile.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE Get_File_Size(FName : string;
                    var FSize : longint;
                    var Error : word);
{ DESCRIPTION:
    Gets size of existing file, in bytes.
  SAMPLE CALL:
    Get_File_Size('C:\COMMAND.COM',FSize,Error);
  RETURNS:
    FSize : 0 if error
            else file size
    Error : DosError code }

var
  SR    : SearchRec;

BEGIN { Get_File_Size }
  {$I-}
  FindFirst(FName,Archive,SR);
  Error := DosError;
  {$I+}
  if Error = 0 then
    FSize := SR.Size
  else
    FSize := 0;
END; { Get_File_Size }
