(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0039.PAS
  Description: SConvert Upgrade
  Author: SCOTT F. EARNEST
  Date: 08-25-94  09:05
*)

{
From: "Scott F. Earnest" <tiobe+@CMU.EDU>

About a month ago, I posted a program called "SmartConvert" which does auto-
matic conversions between DOS and UNIX format text files.

Unfortunately, there were a couple problems with the code I posted I wasn't
aware of:

1.)  While debugging, I accidentally removed the code which called the
     procedures to check that the files existed.  Hopefully nobody's
     gotten in trouble by overwriting files they didn't mean to. . . .
2.)  S . . . L . . . O . . . W . . . !  I clocked a large file (~650K)
     both ways, and got a time over 7 minutes.  In this version, I
     reassigned the text file buffers to 8K, and got much better times.

I've also added an overwrite switch to ignore the output file.

And could the kind soul(s) who donated the previous version to SWAG please
make sure this replaces the old version in the next upgrade?  Thanks!

 ■ Done! - Kerry ■
}
program SConvert;

{Smart-converts UN*X/DOS format files

 Usage:  sconvert infile [outfile] [/u | /d] [/o]

         /u -- force output to UNIX  (LF only)
         /d -- force output to DOS   (CR/LF)
         /o -- Overwrite output file if it exists (for batch support)

         -- or --

         sconvert /?  (-?, /h, -h, /H, and -H analogous)
           for help message

         This program is capabable of having its output piped, provided
          it is the first in the pipeline.  Doesn't do well as an inter-
          mediary pipe section.

 Written by Scott F. Earnest, Aug 1993
 Original version:  30 Aug 1993
 Updated versions:   9 May 1994  (Added force flags.)
                     9 Jun 1994  (Bug fix, added /o flag.)

 This version uses 8K input/output buffers instead of the default 128-byte
 text buffers.  The result is a performance of over 250% (only noticeable
 with large files).  Untyped files turned out to be worthless here--they
 performed worse than text files, believe it or not.

 Unless I come up with a phenomenal improvement, this is the last version
 I plan to post.
}

uses Crt;

const
  CR = chr(13);               {Carriage Return}
  LF = chr(10);               {Line Feed}

type
  sys = (dos,unix,bad);       {system identifier}
                              {Note to people who make upgrades--if you
                               need the DOS unit, you'll have to modify
                               this variable so that "DOS" isn't a label.}
  fbuf = array [0 .. 8191] of char;

var
  sysID : sys;                {system identifier for case branch}
  infile, outfile : string;   {input/output files}
  force : sys;                {what mode to work in}
  overwrite : boolean;        {(don't) check if outfile exists}
  ibuf, obuf : fbuf;          {increase text buffers}

function exist (filename : string) : boolean;

{Check if a file exists or not
 returns:  true  -->  file exists
           false -->  file non-existent}

var
  openfile : text;
  errcode : integer;

begin
  {$I-}                       {Turn off error-checking}
  assign (openfile, filename);
  reset (openfile);
  {$I+}                       {Turn it back on}
  errcode := IOResult;        {Get error code}
  if  errcode <> 0  then      {There's an error if non-zero}
    exist := false            {So flag that it doesn't exist.}
  else
    begin
      close (openfile);       {Otherwise, close file}
      exist := true;          {Flag that it does exist}
    end;
end;

function selectyn : boolean;

{Get a yes/no single-keypress response
 returns:  true  -->  yes response, y or Y
           false -->  no response, n or N}

var
  getchar : char;             {Need something to read into}

begin
  while KeyPressed do         {Clean keyboard buffer}
    getchar := ReadKey;
  repeat                      {Get a key until it's a (Y)es or (N)o.}
    getchar := ReadKey;
    getchar := upcase (getchar);
  until (getchar in ['Y', 'N']);
  writeln (getchar);          {Print the response}
  case getchar of             {Tell it what it should return}
    'Y' : selectyn := true;
    'N' : selectyn := false;
  end;
end;

procedure help (badflag : boolean);

{brief message if command format was abused}

begin
  writeln ('SmartConvert, Written by Scott F. Earnest -- v1.4 -- 9 Jun 1994');
  writeln;
  if badflag then
    begin
      writeln ('Invalid flag.');
      writeln;
    end;
  writeln ('Usage');
  writeln ('  sconvert infile [outfile] [/d | /u] [/o]');
  writeln;
  writeln ('  /d -- convert input to DOS format');
  writeln ('  /u -- convert input to UNIX format');
  writeln ('  /o -- unconditionally overwrite output');
  writeln ('        (for batch files or writing to devices)');
  halt (1);
end;

procedure incheck (filename : string);

{Make sure source exists, if specified}

begin
  if not (exist (filename)) then
    begin
      writeln ('Source file does not exist!');
      halt (3);
    end;
end;

procedure outcheck (filename : string);

{Make sure target does NOT exist, if specified, allow overwrite}

var
  select : boolean;

begin
  if exist (filename) and (filename <> '') then
    begin
      write ('Target file exists!  Overwrite?  [y/n] ');
      select := selectyn;
      case select of
        true : ;
        false : halt (4);
      end;
    end;
end;

function checktype (readfile : string) : sys;

var
  FileCheck : text;
  checkvar : sys;
  CROk, LFOk : boolean;
  ReadBuf : char;

begin
  CROk := False;
  LFOk := False;                        {Init flags.}
  checkvar := bad;                      {Assume that type isn't known.}
  assign (FileCheck, readfile);
  reset (FileCheck);
  while (not eof(FileCheck)) and (not CROk) and (not LFOk) do
    begin                               {Look for CR or LF}
      read (FileCheck, ReadBuf);
      if ReadBuf = CR then              {CR found?}
        begin
          CROk := True;                 {If yes, set the CR flag.}
          Read (FileCheck, ReadBuf);    {and get next char}
          if ReadBuf = LF then          {next one a LF?}
            LFOk := True;               {Flag it as found.}
          if CROk and LFOk then         {So is it CR/LF?}
             begin
               checktype := dos;        {If yes, specify DOS, and exit.}
               close (FileCheck);
               exit;
             end;
        end;
      if ReadBuf = LF then              {Found a LF?}
         begin
           checktype := unix;           {If yes, assume unix.}
           close (FileCheck);           {Close and exit.}
           exit;
         end;
    end;
  if checkvar = bad then                {If there was a problem:}
    begin
      writeln ('Ambiguous file type.  Can''t determine type.');
      close (FileCheck);
      halt(2);
    end;
end;

procedure dos2unix (infile, outfile : string);

var
  intext, outtext : text;
  ReadBuf1, ReadBuf2 : char;

begin
  writeln ('Converting DOS -> UNIX. . . .');
  assign (intext, infile);
  settextbuf (intext, ibuf, sizeof(ibuf));
  reset (intext);
  assign (outtext, outfile);
  settextbuf (outtext, obuf, sizeof(obuf));
  rewrite (outtext);
  while not eof(intext) do
    begin
      read (intext, ReadBuf1);          {Get character}
      if ReadBuf1 = CR then             {If it's CR then. . . }
        begin
          read (intext, ReadBuf2);      {. . . get next . . .}
          if ReadBuf2 = LF then         {. . . and see if it's LF.}
            write (outtext, LF)         {If yes, just put LF into new file.}
          else
            write (outtext, ReadBuf1, ReadBuf2); {Not CR/LF, dump to file.}
        end
      else
        write (outtext, ReadBuf1);      {Dump the character to file.}
    end;
  close (intext);
  close (outtext);
end;

procedure unix2dos (infile, outfile : string);

var
  intext, outtext : text;
  ReadBuf : char;

begin
  writeln ('Converting UNIX -> DOS. . . .');
  assign (intext, infile);
  settextbuf (intext, ibuf, sizeof(ibuf));
  reset (intext);
  assign (outtext, outfile);
  settextbuf (outtext, obuf, sizeof(obuf));
  rewrite (outtext);
  while not eof(intext) do
    begin
      read (intext, ReadBuf);           {Get a character.}
      if ReadBuf = LF then              {Is it LF?}
        write (outtext, CR+LF)          {If yes, put a CR/LF in its place.}
      else
        write (outtext, ReadBuf);       {Otherwise, replace the character.}
    end;
  close (intext);
  close (outtext);
end;

procedure getcommandline;

{get commandline info. . . .}

var
  pnum : byte;                          {paramater counter}
  pstr : string[2];                     {string snippet}
  fname : string;                       {temporary string}

begin
  if (paramcount < 1) or (paramcount > 4) then
    help (false);                       {too few, too many--show help}
  infile := '';                         {Init names.}
  outfile := '';
  force := bad;
  for pnum := 1 to paramcount do        {Do this in two passes.}
    begin                               {#1.)  Flags}
      pstr := paramstr(pnum);           {Get parameter.}
      pstr[2] := upcase(pstr[2]);
      if pstr[1] in ['-', '/'] then     {Flag?}
        case pstr[2] of  
          'H', '?' : help (false);      {Is help.}
          'D'      : force := dos;      {Is force DOS.}
          'U'      : force := unix;     {Is force UNIX.}
          'O'      : overwrite := true; {is overwrite.}
        else
          help (true);                  {Bad switch.}
        end;
    end;
  for pnum := 1 to paramcount do        {#2.)  Filenames}
    begin  
      fname := paramstr(pnum);          {Get parameter.}
      if not (fname[1] in ['-', '/']) then
        begin                           {If not flag then}
          if infile = '' then           {Get infile}
            infile := fname
          else if (infile <> '') and (outfile = '') then
            outfile := fname            {Get outfile}
          else
            help (false);               {Oops, too many.}
        end;
    end;
end;

begin
  overwrite := false;                   {Initialize flag}
  getcommandline;                       {Parse parameters}
  sysID := checktype (infile);          {Check the input file type}
  incheck (infile);                     {verify that infile exists}
  if not overwrite then                 {/o specified?}
    outcheck (outfile);                 {verify that outfile doesn't exist}
  if sysID = force then                 {If it's getting forced, then}
    begin                               {compare types and skip if same.}
      write ('Input file is already type ');
      case sysID of
        dos  : write ('DOS');
        unix : write ('UNIX');
      end;
      writeln (', skipped.');
      halt(5);
    end;
  case sysID of
    dos : dos2unix (infile, outfile);    {DOS -> UNIX}
    unix : unix2dos (infile, outfile);   {UNIX -> DOS}
    bad : begin                          {Not likely to happen but. . . .}
            writeln ('Internal error!  Check source code and recompile.');
            halt (6);
          end;
  end;
end.

