
program XFind(input,output);
  uses Dos,
       FileSpec;

var
  FS: TWildCard;


procedure WriteSpec(Name: string);
begin
   Name := FExpand(Name);
   WriteLn(Name);
end;

procedure FindFiles(Dir: String);
var
  Search:  SearchRec;
  CurDir:  String;
  DirList: array [1..128] of string[12];
  i,
  DirNum:  Byte;
begin
  CurDir := FExpand('.');
  if (Dir<>'.') and (Dir<>'..') then begin
    ChDir(FExpand(Dir));
    DirNum := 0;
    FindFirst('*.*',AnyFile,Search);
    if DosError<>18 then begin
         if Search.Attr=Directory
           then begin
               inc(DirNum);
               DirList[ DirNum ] := Search.Name;
             end
           else if FS.FitSpec(Search.Name)
             then WriteSpec(Search.Name);
         repeat
           FindNext(Search);
           if DosError<>18
             then if Search.Attr=Directory
               then begin
                  inc(DirNum);
                  DirList[ DirNum ] := Search.Name;
                 end
               else if FS.FitSpec(Search.Name)
                  then WriteSpec(Search.Name);
         until DosError = 18;
       end;
    if DirNum<>0
      then for i := 1 to DirNum do FindFiles(DirList[i]);
    ChDir(CurDir);
  end;
end;

var
  i:      Byte;
begin
  if ParamCount = 0
    then WriteLn('Usage: XFIND file1 [file2 file3 ... ]')
    else begin
       FS.Init;
       for i := 1 to ParamCount do FS.AddSpec(ParamStr(i));
       FindFiles('\');
       FS.Done;
      end;
end.
