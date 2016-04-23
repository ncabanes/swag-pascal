{
>>DOS will automatically close all open files that belong to your
>>process upon termination.  The only way I know of to do it manually,
>>if you don't know what the actual file variables will be, is to search
>>your PSP

>   I was doing fine until this point, what's a psp?
PSP stands for Program Segment Prefix.  It contains a lot of information
about your program that is important to DOS.  Some of the things it
contains is the file handle table for open files, the command line tail,
information carried over from CP/M, an ISR table, a pointer to a copy of
the master environment, and more.

>for any open file handles, then explicitly call DOS, passing
>>each file handle number. If nobody has a better suggestion, I could
>>probably think up some code to do that.

>   at least psuedo code would be appreciated..
Here is some code that will close all of the files that your program
actually opened.  It won't clear the run-time error; you'll have to
put that code into the exit-proc, or write your own.

{ FCLOSALL.PAS
  file close unit
  12-5-93
  (c) 1993 Brian Pape

  This code may be distributed freely.  However, I would appreciate it
  if modifications made to the code would be noted with the name of the
  modifier and the date.

  This program will demonstrate how to close all open files in
  your program without knowing what the names of the associated
  file variables are.  All that you need to do in order to implement
  this code is put the statement USES FCLOSALL in your main program.

  When your program ends, whether through a run-time error or through
  normal termination, this procedure will attempt to close all open files
  that were opened by your program.  It will not close the standard i/o
  file handles that are maintained by DOS.  In fact, the Turbo RTL will
  automatically close the INPUT and OUTPUT standard files in the standard
  exit procedure.  The other DOS standard I/O files are StdErr, AUX,
  and PRN.

  This code does not clear the ExitCode variable, so if your program is
  terminating with a run-time error, the turbo ExitProc will still
  print the "Runtime Error at xxxx:xxxx" message.  If you want to
  prevent this message from occuring, then write another exitproc to
  clear the ExitCode variable in certain cases.

  This code requires TP 6.0 or greater since it uses BASM
}

unit fclosall;
interface
implementation
var
  saveexit:pointer;

procedure close_files_exit_proc; far;
var
  numhandles : byte;
  hp : ^byte;
begin

  exitproc := saveexit;

  { get number of file handles available }
  numhandles := byte(ptr(prefixseg,$32)^);

  { get the location of the fht, in case it is moved }
  hp := pointer(ptr(prefixseg,$34)^);
  inc(hp,5);

  { skip the first 5 handles because they are standard DOS handles }
  for numhandles := 5 to pred(numhandles) do
    begin
      asm
        mov  ah,3eh
        xor  bh,bh
        push ds
        lds  si,hp
        mov  bl,[si]
        cmp  bl,0ffh  { don't close invalid handle; it will close INPUT }
        je   @invalidhandle
        int  $21
        @invalidhandle:
        pop ds
      end;
      inc(hp);
    end;
end;

begin
  saveexit := exitproc;
  exitproc := @close_files_exit_proc;
end.  { FCLOSALL }


{ tests the FCLOSALL unit }
program test_fcloseall;
uses fclosall;
var
  f : file;
  i : byte;
begin
  for i := 1 to 16 do
    begin
      assign(f,'a.a');
      rewrite(f);
    end;  { for }
end.

