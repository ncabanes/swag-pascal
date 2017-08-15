(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0005.PAS
  Description: Searching a Complete Drv
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
> Can any one tell me a way to make pascal (TP 6.0) search a Complete
> drive, including all subdirectories, even ones that are not in the
> path, looking For a specific File extension?  I.E., having the Program
> search For *.doC and saving that to a Text File?

Ok, here goes nothing.
}


Program FindAllFiles;

Uses Dos;


Procedure ScanDir(path : PathStr; var outputFile : text);

Var
  SearchFile : SearchRec;
begin
  writeln('Examining: '+path);
  if Path[Length(Path)] <> '\' then
    Path := Path + '\';
  FindFirst(Path + '*.*', $37, SearchFile); { Find Files and Directories }
  While DosError = 0 do { While There are more Files }
  begin
    if ((SearchFile.Attr and $10) = $10) and (SearchFile.Name[1] <> '.') then
      ScanDir(Path + SearchFile.Name, outputFile)
      { Found a directory Make sure it's not . or .. Scan this dir also }
    else
    if Pos('.doc',SearchFile.Name)>0 then
      Writeln(outputFile, Path + SearchFile.Name);
      { if the .doC appears in the File name, Write path to File. }
    FindNext(SearchFile);
  end;
end;

Var
  outputFile : Text;

begin
  Assign(outputFile,'docs.txt'); { File to contain list of .doCs }
  ReWrite(outputFile);
  ScanDir('D:\', outputFile); { Drive to scan. }
  Close(outputFile);
end.
