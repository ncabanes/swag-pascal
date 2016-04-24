(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0060.PAS
  Description: Replace file extensions
  Author: ANTON ZHUCHKOB
  Date: 01-02-98  07:35
*)

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
