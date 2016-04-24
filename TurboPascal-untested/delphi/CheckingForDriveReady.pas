(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0054.PAS
  Description: Checking for Drive Ready
  Author: SWAG SUPPORT TEAM
  Date: 11-24-95  10:15
*)


function DiskInDrive(Drive: Char): Boolean;
var
  ErrorMode: word;
begin
  { make it upper case }
  if Drive in ['a'..'z'] then Dec(Drive, $20);
  { make sure it's a letter }
  if not (Drive in ['A'..'Z']) then
    raise EConvertError.Create('Not a valid drive ID');
  { turn off critical errors }
  ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    { drive 1 = a, 2 = b, 3 = c, etc. }
    if DiskSize(Ord(Drive) - $40) = -1 then
      Result := False
    else
      Result := True;
  finally
    { restore old error mode }
    SetErrorMode(ErrorMode);
  end;
end;

