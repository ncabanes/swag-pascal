(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0102.PAS
  Description: Get a file's date and time stamp
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


function GetFileDate(TheFileName: string): string;
var
  FHandle: integer;
begin
  FHandle := FileOpen(TheFileName, 0);
  try
    Result := DateTimeToStr(FileDateToDateTime(FileGetDate(FHandle)));
  finally
    FileClose(FHandle);
  end;
end;

