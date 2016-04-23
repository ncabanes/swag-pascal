program ListFiles(input,output);
  uses Dos,
       FileSpec;

var
  FS: TWildCard;

procedure WriteName(Name: string; Attr: word);
var T: String;
begin
  if Attr=Directory
    then Name := '['+Name+']';
  Name := Name + '                ';     (* 16 spaces *)
  Write( Copy(Name,1,16) );
end;

procedure ListFiles;
var
  Search:  SearchRec;
begin
    FindFirst('*.*',AnyFile,Search);
    if DosError<>18 then begin
       if FS.FitSpec(Search.Name)
             then WriteName(Search.Name,Search.Attr);
         repeat
           FindNext(Search);
           if DosError<>18
             then if FS.FitSpec(Search.Name)
                  then WriteName(Search.Name,Search.Attr);
         until DosError = 18;
       end;
end;

var
  i:      Byte;
begin
  FS.Init;
  for i := 1 to ParamCount do FS.AddSpec(ParamStr(i));
  ListFiles;
  FS.Done;
  WriteLn;
end.
