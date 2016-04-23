{ This function replaces ext of given file name }
{ uses Dos }
function ReplaceExt(Name: PathStr; NewExt: ExtStr;
                    CurDir: Boolean): PathStr;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FSplit(Name, D, N, E);
  if NewExt[1] <> '.' then NewExt:= '.' + NewExt;
  if CurDir then ReplaceExt:= N + NewExt
  else ReplaceExt:= D + N + NewExt;
end;
