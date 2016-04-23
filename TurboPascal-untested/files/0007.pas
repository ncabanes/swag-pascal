{ 1 }

Function FileExist(FileName : String) : Boolean;
begin
  FileExist := (FSearch(FileName, '') <> '')
end;      (* FileExist.                                           *)

{ 2 }

Function FileExist(FileName : String) : Boolean;
Var
  SRec : SearchRec;
begin
  FindFirst(FileName, AnyFile, SRec);
  FileExist := (DosError = 0);
end;

{ 3 }

Function FileExists(FileName : String) : Boolean;
Var
  DirInfo : SearchRec;
begin
  FindFirst(FileName, AnyFile, DirInfo);
  if (DosError = 0) then
    FileExists := True
  else
    FileExists := False;
end;

