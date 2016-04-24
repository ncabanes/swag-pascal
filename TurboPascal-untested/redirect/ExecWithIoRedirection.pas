(*
  Category: SWAG Title: DOS REDIRECTION ROUTINES
  Original name: 0008.PAS
  Description: EXEC with i/o redirection
  Author: MATTHEW MASTRACCI
  Date: 08-25-94  09:11
*)

{
From: Matthew.Mastracci@matrix.cpubbs.cuug.ab.ca (Matthew Mastracci)

 tf> A simple example:
 tf> SwapVectors;
 tf> Exec (GetEnv('comspec'), '/c dir *.* > FileName');
 tf> SwapVectors;

This is a good way to do redirection for directory listings and the like,
but a better way is to use this unit:  (I wrote it from an idea given to me by
someone else posting the same sort of this, except this one includes error
checking and containm much more useful procedures)  From this, you can go:

SwapVectors;
RedirectOutput('\DIRLIST.TXT');
Exec(GetEnv('COMSPEC'), '/C DIR *.*');
StdOutput;
SwapVectors;

Same thing, but more control...

Here's my REDIR.PAS unit:

  Redirection unit

  - Original author unknown, rewritten by Matthew Mastracci
  - Added a bit of asm, pipe support, some better file handling ability, more
     flexibility
  - If you'd like some information on this program, E-Mail me at:
     madhacker@matrix.cpubbs.cuug.ab.ca
  - Feel free to distribute this source anywhere! (Public Domain)
}

unit Redir;

interface

{ Redirects standard input from a textfile/device  ie: command < filename }
procedure RedirectInput(TextFile : String);

{ Redirects standard output to a textfile/device  ie: command > filename }
procedure RedirectOutput(TextFile : String);

{ Redirects standard error to a textfile/device }
procedure RedirectError(TextFile : String);

{ Redirects standard output and error to a textfile/device }
procedure RedirectAllOutput(TextFile : String);

{ Redirects all I/O from a textfile  ie: ctty device }
procedure RedirectAll(TextFile : String);

{ Restores STDIN to CON }
procedure StdInput;

{ Restores STDOUT to CON }
procedure StdOutput;

{ Restores STDERR to CON }
procedure StdError;

{ Creates a unique file and returns its name (used for piping) }
function UniqueFile : String;

implementation

uses Dos;

var InFile, OutFile, ErrFile : Text;

const
  STDIN  = 0;       { Standard Input }
  STDOUT = 1;       { Standard Output }
  STDERR = 2;       { Standard Error }
  Redirected : array[0..2] of Boolean = (False, False, False);

{ Duplicates a file handle }
procedure ForceDup (Existing, Second : Word);
var f, Error : Word;
begin
  asm
    mov ah, $46
    mov bx, Existing
    mov cx, Second
    int $21
    pushf
    pop bx
    mov f, bx
    mov Error, ax
  end;
  if (f and FCarry) <> 0 then
    Writeln ('Error ', Error, ' changing handle ', Second);
end;

{ Redirects standard input from a textfile/device  ie: command < filename }
procedure RedirectInput(TextFile : String);
begin
  if Redirected[STDIN] then StdInput;
  Redirected[STDIN] := True;
  Assign(InFile, TextFile);
  Reset(InFile);
  ForceDup(TextRec(InFile).Handle, STDIN);
end;

{ Redirects standard output to a textfile/device  ie: command > filename }
procedure RedirectOutput(TextFile : String);
begin
  if Redirected[STDOUT] then StdOutput;
  Redirected[STDOUT] := True;
  Assign(OutFile, TextFile);
  Rewrite(OutFile);
  ForceDup(TextRec(OutFile).Handle, STDOUT);
end;

{ Redirects standard error to a textfile/device }
procedure RedirectError(TextFile : String);
begin
  if Redirected[STDERR] then StdError;
  Redirected[STDERR] := True;
  Assign(ErrFile, TextFile);
  Rewrite(ErrFile);
  ForceDup(TextRec(ErrFile).Handle, STDERR);
end;

{ Redirects standard output and error to a textfile/device }
procedure RedirectAllOutput(TextFile : String);
begin
  RedirectOutput(TextFile);
  RedirectError(TextFile);
end;

{ Redirects all I/O from a textfile  ie: ctty device }
procedure RedirectAll(TextFile : String);
begin
  RedirectInput(TextFile);
  RedirectOutput(TextFile);
  RedirectError(TextFile);
end;

{ Restores STDIN to CON }
procedure StdInput;
begin
  if Redirected[STDIN] then begin
    Redirected[STDIN] := False;
    RedirectInput('CON');
    Close(InFile);
  end;
end;

{ Restores STDOUT to CON }
procedure StdOutput;
begin
  if Redirected[STDOUT] then begin
    Redirected[STDOUT] := False;
    RedirectOutput('CON');
    Close(OutFile);
  end;
end;

{ Restores STDERR to CON }
procedure StdError;
begin
  if Redirected[STDERR] then begin
    Redirected[STDERR] := False;
    RedirectOutput('CON');
    Close(OutFile);
  end;
end;

function UniqueFile : String;
const FName : array[1..20] of Char = '\' + #0 + '                  ';
var FSeg, FOfs : Word;
    FileName : String;
begin
  FSeg := Seg(FName);
  FOfs := Ofs(FName) + 1;
  asm
    push ds
    mov ax, FSeg
    mov ds, ax
    mov dx, FOfs
    mov ah, $5a
    mov cx, 0
    int $21
    pop ds
  end;
  Move(FName, FileName[1], 9);
  FileName[0] := #9;
  UniqueFile := FileName;
end;

end.

{ This is how you can do piping.  It is equivilent to: }
{ type \autoexec.bat | find "ECHO" | sort /R }

{$M $1000,0,0}
program PipeDemo;
uses Redir, Dos;
var FName : String;

begin
  FName := UniqueFile;
  WriteLn('Temporary file: ', FName);
  WriteLn('Output from pipe:');
  RedirectInput('\AUTOEXEC.BAT');
  RedirectOutput(FName);
  Exec('C:\DOS\FIND.EXE', '"ECHO"');
  RedirectInput(FName);
  RedirectOutput('CON');
  Exec('C:\DOS\SORT.EXE', '/R');
end.

