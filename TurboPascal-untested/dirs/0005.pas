{
> Can any one tell me a way to make pascal (TP 6.0) search a Complete
> drive, including all subdirectories, even ones that are not in the
> path, looking For a specific File extension?  I.E., having the Program
> search For *.doC and saving that to a Text File?

Ok, here goes nothing.
}

{$M 65000 0 655360}
{Assign enough stack space For recursion}

Program FindAllFiles;

Uses Dos;

Var
  FileName : Text;

Procedure ScanDir(path : PathStr);

Var
  SearchFile : SearchRec;
begin
  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  FindFirst(Path + '*.*', $37, SearchFile); { Find Files and Directories }
  While DosError = 0 do { While There are more Files }
  begin
    if ((SearchFile.Attr and $10) = $10) and (SearchFile.Name[1] <> '.') then
      ScanDir(Path + SearchFile.Name)
      { Found a directory Make sure it's not . or .. Scan this dir also }
    else
    if Pos('.doC',SearchFile.Name)>0 then
      Writeln(FileName, Path + SearchFile.Name);
      { if the .doC appears in the File name, Write path to File. }
    FindNext(SearchFile);
  end;
end;

begin
  Assign(FileName,'doCS'); { File to contain list of .doCs }
  ReWrite(FileName);
  ScanDir('C:\'); { Drive to scan. }
  Close(FileName);
end.
