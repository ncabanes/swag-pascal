{ >>> Does anyone know how I can get the size of a file? }

function GetFileTime(FileName: string): longint;
var
  Srec: SearchRec;
begin
  FindFirst(FileName, $01+$04+$20, Srec);
  if DosError = 0 then GetFileTime := Srec.Time
  else GetFileTime := 0;
end;

function  GetFileSize(FileName: string): longint;
var
  Srec: SearchRec;
begin
  FindFirst(FileName, $01+$04+$20, Srec);
  if DosError = 0 then GetFileSize := Srec.Size
  else GetFileSize := 0;
end;
