(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0047.PAS
  Description: File Searching
  Author: JOHN STEPHENSON
  Date: 09-04-95  11:01
*)

{
 RA> Does anyone have a procedure for search for wildcards on Harddisks?
 RA> It needs to check multiple hard disks and all directories.  I tried
 RA> some TP built in functions (Fsearch, and another one) but one doesn't
 RA> support wildcards and neither scan all dirs unless I do alot of fancy
 RA> stuff...

   Here's some code, written by another of the frequent contributors
here, which should help:
}
program Tree_Search;                          { by John Stephenson 1994 }
Uses DOS,CRT;
var files : word;

Function UpCaseStr(st: String): String;
var loop: byte;
Begin
  for loop := 1 to length(st) do st[loop] := upcase(st[loop]);
  upcasestr := st
end;

Procedure FileList(Path: PathStr; Var OutFile: Text; lookingfor: string);
Var
  dir,fs: SearchRec;
  final: String;
Begin
  textattr := lightred; write(#13,'Scanning: ', path); clreol;
  FindFirst(path+'*.*',directory,dir);
  with dir do While DosError = 0 Do
    Begin
      if (name[1] <> '.') and (attr and directory = directory) then
        FileList(Path+Name+'\',outfile,lookingfor);
      FindNext(dir)
    end;
  FindFirst(path+lookingfor,anyfile-directory,fs);
  with fs do While DosError = 0 do
    Begin
      inc(files); fillchar(final,sizeof(final),' ');
      final := #13 + path + name;
      final[0] := #60; textattr := lightcyan;
      write(#13,final); textattr := lightblue;
      write(size, ' bytes'); clreol; writeln;
      FindNext(fs)
    end
End;

Procedure Help;
begin
  textattr := lightcyan; writeln('FDir v1.00b by John Stephenson');
  textattr := lightgray;
  writeln(#10'USAGE: FDir (path\)filename.ext');
  halt
end;

var
  lookingfor: string;
  d: dirstr;
  n: namestr;
  e: extstr;
Begin
  lookingfor := upcasestr(paramstr(1));
  fsplit(lookingfor, d, n, e);
  if d = '' then d := '\';
  lookingfor := n + e;
  if lookingfor = '' then help;
  textattr := white; writeln('Searching for: ', lookingfor);
  files := 0;
  FileList(d,output,lookingfor); write(#13); clreol;
  textattr := white; write(#10, files, ' files(s) found');
  textattr := lightgray; writeln
End.

