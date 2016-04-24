(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0039.PAS
  Description: Recursive Directory lister
  Author: EDDY THILLEMAN
  Date: 02-28-95  09:47
*)

{$M 65520,0,655360}

Uses DOS;

Type
 String12 = string[12];

Const
 FAttr : word = $23; { readonly-, hidden-, archive attributen }

Var
 CurDir : PathStr;
 StartDir: DirStr;
 FMask  : String12;
 subdirs : boolean;


Function UpStr(const s:string):string; assembler;
{ by Brain Pape, found in the SWAG collection }
asm
 push ds
 lds si,s
 les di,@result
 lodsb{ load and store length of string }
 stosb
 xor ch,ch
 mov cl,al
 @upperLoop:
 lodsb
 cmp al,'a'
 jb  @cont
 cmp al,'z'
 ja  @cont
 sub al,' '
 @cont:
 stosb
 loop @UpperLoop
 pop ds
end; { UpStr }


Procedure ParseCmdLine;
var
 t : byte;
 cmd: string;
begin
 for t := 2 to ParamCount do begin
cmd := UpStr(Copy(ParamStr(t),1,2));
if cmd = '/S' then subdirs := true;
 end;
end;


Function NoTrailingBackslash (path : String) : String;
begin
 if (length(path) > 3) and (path[length(path)] = '\') then
  path[0] := chr(length(path) - 1);
 NoTrailingBackslash := path;
end;


Procedure PathAnalyze (P: PathStr; Var D: DirStr; Var Name: String12);
Var
 N: NameStr;
 E: ExtStr;

begin
 FSplit(P, D, N, E);
 Name := N + E;
end;


Procedure Process (var SR: SearchRec);
{ here you can put anything you want to do in each directory with each file }
begin
 writeln(FExpand(SR.Name));
end;


Procedure FindFiles;
var
 FR : SearchRec;

begin
 FindFirst(FMask, FAttr, FR);
 while DosError = 0 do
 begin
Process(FR);
FindNext(FR);
 end;
end;


{$S+}
Procedure AllDirs;
{ recursively roam through subdirectories }
var
 DR : SearchRec;

begin
 FindFirst('*.*', Directory, DR);
 while DosError = 0 do begin
if DR.Attr and Directory = Directory then begin
 if ((DR.Name <> '.') and (DR.Name <> '..')) then begin
ChDir(DR.Name);
AllDirs;  { Recursion!!! }
ChDir('..');
 end
end;
FindNext(DR);
 end;
 FindFiles;
end;
{$S-}


begin

 subdirs := false;
 GetDir (0, CurDir);
 if ParamCount > 1 then ParseCmdLine;

 PathAnalyze (FExpand(ParamStr(1)), StartDir, FMask);
 if Length (StartDir) > 0 then ChDir (NoTrailingBackslash(StartDir));
 if IOResult <> 0 then
 begin
Writeln('Cannot find directory.');
Halt(1);
 end;
 if Length (FMask) = 0 then FMask := '*.*';
 if subdirs then AllDirs else FindFiles;
 ChDir (CurDir);
end.

