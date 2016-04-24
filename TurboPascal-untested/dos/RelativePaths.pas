(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0042.PAS
  Description: Relative paths
  Author: PETER GEDECK
  Date: 01-27-94  12:20
*)

{
bcp100@cd4680fs.rrze.uni-erlangen.de (Peter Gedeck)

: Does anyone have a relative path routine?   An example of what I mean by a
: relative path routine is the Turbo Pascal IDE's editor window titles. It
: only displays as much of the files path name as is necessary. It should be
: something like
:     function RelativePath(FullPath: string): string;

This is what I use to get a relative file name. I think it works correctly
and hope you will find it useful.
}

Uses
  Dos;


function GetCurDir : DirStr;
var
  CurDir : DirStr;
begin
  GetDir(0, CurDir);
  GetCurDir := CurDir;
end;


function GetCurDrive : Char; assembler;
asm
  MOV     AH,19H
  INT     21H
  ADD     AL,'A'
end;


function GetRelativeFileName(F : String) : String;
var
  D  : DirStr;
  N  : NameStr;
  E  : ExtStr;
  i  : integer;
  rd : string;

begin
  F := FExpand(F);
  FSplit(F, D, N, E);
  if GetCurDrive = D[1] then
  begin
    { Same Drive - remove Driveinformation from D }
    Delete(D, 1, 2);
    F := GetCurDir + '\';
    Delete(F, 1, 2);
    { Maybe it is a file in a directory higher than the actual directory }
    i := Pos(F, d);
    if i > 0 then
      Delete(d, 1, length(F))
    else
    begin
      rd := '';
      if Pos(d, F) = 0 then
      repeat
        repeat
          rd := d[Ord(d[0])] + rd;
          dec(d[0]);
        until d[Ord(d[0])] = '\';
      until Pos(d, F) > 0;

      { Maybe it  is a file in a directory lower than the actual directory }
      if Pos(d, F) > 0 then
      begin
        repeat
          rd := '..\' + rd;
          dec(F[0]);
          while F[Ord(F[0])] <> '\' do
            dec(F[0]);
        until (Pos(d, F) > 0) and not ((d = '\') and (F <> '\'));
        d := rd;
      end;
    end;
  end;
  GetRelativeFileName := (D + N + E);
end;


begin
  Writeln(GetRelativeFileName('C:\qmpro\dl\bp\lib\ansi.pas'));
end.
