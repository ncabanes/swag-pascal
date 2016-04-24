(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0031.PAS
  Description: Redirecting to a File
  Author: DAVID G. EDWARDS
  Date: 05-26-95  23:01
*)

{
>This should do the job, but actually I'm interested in letting the text
>appear in a seperate window, like dizman or something like that..... So
>if you know anything about that, please respond.....

Try something like this:
}

{ Thanks to DJ, TeeCee, Charles Falconer, Mike Copeland, et al. for their help
on this echo over the years ...... }
{$A-,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R+,S+,T-,V+,X-,Y+}
{$M 16384,0,0}

uses
  crt,
  dos;

function FileExists(name : string):boolean;
{ may not work with subdirs }
var f : searchrec;
begin
  findfirst(name, anyfile, f);
  FileExists:= (DOSerror = 0);
end;

procedure Compress(filespec : string);
const
  stderr = 2;
  compressor : pathstr = 'lha.exe';
var
  outfilename : pathstr;
  outfile : text;
  OldStdErr : word;
     procedure DOSclose(handle : word);
     var regs : registers;
     begin
       with regs do
         begin
           bx:= handle;
           ah:= $3e;
           MsDos(regs);
           if (flags and fcarry) <> 0 then
             writeln('Error ',ax,'. Closing DOS handle ', handle);
         end;
     end;
     procedure dup_handle(oldhandle : word; var newhandle : word);
     var regs : registers;
     begin
       newhandle:= 0;
       with regs do
         begin
           bx:= oldhandle;
           ah:= $45;
           MsDos(regs);
           if (flags and fcarry) <> 0 then
             writeln('Error ',ax,'. Dup''ing DOS handle ', oldhandle)
           else newhandle:= ax;
         end;
     end;
     procedure force_dup(existing, second:word);
     var regs : registers;
     begin
       with regs do
         begin
           ah := $46;  bx := existing; cx := second;
           msdos(regs);
           if (flags and fcarry) <> 0 then
             writeln('Error ',ax,'. Changing DOS handle ',
                      existing,' to ', second);
         end;
     end;
begin
  if not FileExists(compressor) then
    compressor:= FSearch(compressor, getenv('path'));
  if not FileExists(compressor) then
    begin
      write('File compressor not found.  Press Enter to acknowledge...');
      readln;
      halt;
    end;
  outfilename:= 'lha.log';
  assign(outfile, outfilename);
  rewrite(outfile);
  dup_handle(StdErr, OldStdErr);
  { redirect stderr to outfile }
  force_dup(textrec(outfile).handle, stderr);
  swapvectors;
  exec(compressor, 'a squished '+ filespec);
  swapvectors;
  flush(outfile);

  if (DOSerror<>0) or (DOSexitcode<>0) then
    begin
      writeln('DOSerror=', DOSerror);
      writeln('DOSexitcode=',DOSexitcode);
    end;

  { restore stderr }
  force_dup(OldStdErr, stderr);
  DosClose(OldStdErr);
  close(outfile);
end;


begin
  clrscr;
  write(' File Archiving by:  LHA version 2.13   Copyright (c) Yoshi 1988-1991.');
  Compress('dowwndw.pas');
  Readln;
end.


