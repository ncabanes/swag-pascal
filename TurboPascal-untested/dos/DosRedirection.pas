(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0096.PAS
  Description: Dos Redirection
  Author: HENNING RUST
  Date: 11-22-95  15:50
*)

{
 LG> I am trying to write a routine using PKZIP.  I can get it to work
 LG> except I am having a problem using the -z <comment.fil option with
 LG> EXEC.
the trouble is that the exec procedure doesn't support redirection of standard
input and standard output devices using the ">" and "<" chars, i.e. PKZIP
usually expects the comment to come from the "STDIN" standard input device
which normally is the keyboard. and with <MYBANNER.TXT from the commandline
you redirect the STDIN to the file MYBANNER.TXTSo you have to do the
redirection yourself ;)
That's how it works:

(The STDIN file handle is always handle #0.)
1. copy this STDIN handle into a new one (to restore it afterwards)
2. open your redirection file
3. force the duplication of your redirection file's handle into the
   STDIN handle #0 (and close the redirection file's hadle)
4. the STDIN handle now no longer refers to the keyboard, but to your
   redirection file. Run EXEC without the "<blabla..." stuff.
5. restore the old STDIN handle by forcing the duplication of your
   saved handle (from 1.) into handle 0.

hey, don't worry .. i did it for you ;)
i did a little error handling .. but it still could not work if there are too
few free file handles .. but this usually doesn't happen ;) and if it happens,
increase your FILES=?? in your CONFIG.SYSand if you change it in order to make
it fit into your prog: remember that ASCIIZfilename must always be declared as
a global variable!!

=== Cut ===
{$M 4096, 0, 0}
program redirection;

uses dos;

const STDIN = 0;

var   error  : boolean;
      ASCIIZfilename : string;

procedure MyExec(Path, CmdLine, STDINFile : STRING);
var filehandle     : word;
    dupSTDINhandle : word;
begin
  asciizfilename := STDINfile + #0;
  error := false;
  asm
    mov ax, 3d00h               {OPEN A FILE}
    mov dx, offset asciizfilename
    inc dx
    int 21h
    jnc @noerror
    mov error, 1
   @noerror:
    mov filehandle, ax
  end;
  if error then begin
    writeln('redirection file not found!');
    exit;
  end;
  asm
    mov ah, 45h
    mov bx, STDIN  {set bx to 0 = STDIN handle}
    int 21h        {DUPLICATE FILE HANDLE}
    jnc @noerror2
    mov error, 1
   @noerror2:
    mov dupSTDINhandle, ax
  end;
  if error then begin
    writeln('cannot duplicate STDIN handle');
    asm
      mov ah, 3eh   {CLOSE FILE}
      mov bx, filehandle
      int 21h
    end;
    exit;
  end;
  asm
    mov ah, 46h      {FORCE DUPLICATE HANDLE}
    mov bx, filehandle
    mov cx, STDIN
    int 21h
    mov ah, 3eh      {CLOSE FILE}
    mov bx, filehandle
    int 21h
  end;
  swapvectors;
  exec(Path, CmdLine);
  swapvectors;
  asm
    mov ah, 46h      {FORCE DUPLICATE HANDLE}
    mov bx, dupSTDINhandle
    mov cx, STDIN
    int 21h
    mov ah, 3eh      {CLOSE FILE}
    mov bx, dupSTDINhandle
    int 21h
  end;
end;

begin
  myexec('PKZIP.EXE', 'MYZIP.ZIP -z', 'MYCOMMENT.TXT');
end.


