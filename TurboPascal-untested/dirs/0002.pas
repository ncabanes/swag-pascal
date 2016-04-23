Uses Crt, Dos, WinDos;
Procedure SearchSubDirs(Dir:PathStr;Target:SearchRec);
Var
  FoundDir: TSearchRec;
  FileSpec: PathStr;
  Path : DirStr;
  DummyName: NameStr;
  DummyExt : ExtStr;
begin
 If KeyPressed then Repeat Until KeyPressed;
 FileSpec:= Dir + '*.';
 FindFirst('*.*', AnyFile, FoundDir);
 While (DosError = 0) do
   begin
     With FoundDir do
       begin
         If Name[1] <> '.' then
           if Directory and Attr <> 0 then
             begin
               FSplit(FileSpec,Path,DummyName,DummyExt);
               FindFirst(Path + Name + '\' ,Target);
             end;
       end; {with FoundDir}
     if KeyPressed then Pause;
     FindNext(FoundDir);
   end; {read loop}
   If DosError <> 18 then DosErrorExit;
end;
