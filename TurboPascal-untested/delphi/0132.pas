{
Here is a function I've written to test if a disk is in a drive (without
generating the Windows error message).  There may be a better way of doing
it in Delphi 2, but this is how it's done in Delphi 1.x:
}

function DiskExists(Drive: Char): Boolean;
var
  ErrorMode: Word;
begin
  Drive := UpCase(Drive);
  { Make sure drive is a valid letter }
  if not (Drive in ['A'..'Z']) then
    raise EConvertError.Create('Not a valid drive letter');
  { Turn off critical errors }
  ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    Application.ProcessMessages;
    Result := (DiskSize(Ord(Drive) - Ord('A') + 1) <> -1);
  finally
    { Restore the old error mode }
    SetErrorMode(ErrorMode);
    Application.ProcessMessages;
  end;
end;

If you want to test if a drive exists, with or without a disk in it, the
take a look at the API call GetDriveType()...

