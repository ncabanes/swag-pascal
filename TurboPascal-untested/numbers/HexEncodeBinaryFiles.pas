(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0053.PAS
  Description: Hex encode binary files
  Author: JOSE CAMPIONE
  Date: 08-25-94  09:06
*)

(*************************************************************************

             ===============================================
             Hex-encode binary files in debug-script batches
             ===============================================
                 Copyright (c) 1993,1994 by José Campione
                   Ottawa-Orleans Personal Systems Group
                          Fidonet: 1:163/513.3

        This program reads a binary file and creates a hex-encoded 
        text file. This text file is also a batch file and a debug 
        script which, when run, will use debug.exe or debug.com to 
        reconstruct the binary file. 

**************************************************************************)
{$M 2048,0,0}
program debugbat;

uses crt,dos;

const
  maxsize = $FFEF;

type
  string2 = string[2];

var
  ifile : file of byte;
  ofile : text;
  n : word;
  s : word;
  b : byte;
  fsize : word;
  dir : dirstr;
  nam : namestr;
  ext : extstr;
  filename : string[12];
  i : integer;

function b2x(b: byte): string2;
const hexdigit: array[0..15] of char = '0123456789ABCDEF';
begin
  b2x:= hexdigit[b shr 4] + hexdigit[b and $0F];
end;

procedure myhalt(e: byte);
begin
  gotoxy(1,wherey);
  case e of
    0 : writeln('done.');
    1 : writeln('error in command line.');
    2 : writeln('file exceeds the 65K limit.');
    else begin
      e:= 255;
      writeln('Unknown error.');
    end;
  end;
  halt(e);
end;

begin
  writeln;
  writeln('DEBUGBAT v.1.0. Copyright (c) Feb/93 by J. Campione.');
  write('Wait... ');
  n := 0;
  s := $F0;
  {$I-}
  assign(ifile,paramstr(1));
  reset(ifile);
  {$I+}
  if (paramcount <> 1) or (ioresult <> 0) or (paramstr(1) = '') then myhalt(1);
  fsplit(paramstr(1),dir,nam,ext);
  for i:= 1 to length(ext) do ext[i]:= upcase(ext[i]);
  for i:= 1 to length(nam) do nam[i]:= upcase(nam[i]);
  if ext = '.EXE' then filename:= nam + '.EXX'
                  else filename:= nam + ext;
  fsize:= filesize(ifile);
  if fsize > maxsize then myhalt(2);
  assign(ofile, nam + '.BAT');
  rewrite(ofile);
  writeln(ofile,'@echo off');
  writeln(ofile,'rem');
  writeln(ofile,'rem *************************************************************************');
  writeln(ofile,'rem File ',nam + '.BAT',' was created by program DEBUGBAT.EXE v.1.0');
  writeln(ofile,'rem Copyright (c) Feb. 1993 by J. Campione (1:163/513.3)');
  writeln(ofile,'rem Running this file uses DEBUG to reconstruct file ',nam + ext);
  writeln(ofile,'rem *************************************************************************');
  writeln(ofile,'rem');
  writeln(ofile,'echo DEBUGBAT v.1.0. Copyright (c) Feb/93 by J. Campione.');
  writeln(ofile,'if not exist %1debug.exe goto error1');
  writeln(ofile,'goto decode');
  writeln(ofile,':error1');
  writeln(ofile,'if not exist %1debug.com goto error2');
  writeln(ofile,':decode');
  writeln(ofile,'echo Wait...');
  writeln(ofile,'debug < %0.BAT > nul');
  writeln(ofile,'goto name');
  writeln(ofile,':error2');
  writeln(ofile,'echo Run %0.BAT with DEBUG''s path in the command line');
  writeln(ofile,'echo example:   %0 c:\dos\    ... notice the trailing slash!');
  write(ofile,'goto end');
  while not eof(ifile) do begin
    n:= n + 1;
    read(ifile,b);
    if n mod 16 = 1 then begin
      s := s + 16;
      writeln(ofile);
      write(ofile,'E ',b2x(hi(s)),b2x(lo(s)));
    end;
    write(ofile,' ',b2x(b));
  end;
  writeln(ofile);
  writeln(ofile,'RCX');
  writeln(ofile,b2x(hi(n)),b2x(lo(n)));
  if ext = '.EXE' then begin
    filename:= nam + '.EXX';
  end;
  writeln(ofile,'N ',filename);
  writeln(ofile,'W');
  writeln(ofile,'Q');
  writeln(ofile,':name');
  if ext = '.EXE' then begin
    writeln(ofile,'if exist ',nam + ext,' del ',nam + ext);
    writeln(ofile,'rename ',nam + '.EXX ',nam + ext);
  end;
  writeln(ofile,':end');
  close(ifile);
  close(ofile);
  myhalt(0);
end.


