(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0100.PAS
  Description: Read/Write Transfer Speed
  Author: MARNIX TIMMERMANS
  Date: 05-26-95  23:28
*)

{
> Is there any difference in speed between blockreading a given number of
> bytes with a recordlength of 1 and a bigger recordlength, something like

> reset(file1,1);
> reset(file2,256);
> blockread(file1,Buffer^,32768);
> blockread(file2,Buffer^,128);

> Oh yes, it is !
No, the buffer is equally big in both cases (128*256 = 32768).

> With the biggest buffer you have the shortest reading-time, simple isn't
> it? Try to test it with an easy copy-program.
> First with reset(file,1), then with reset(file,4096) or 8192 or 32768.
> Now copy a big file (over 1 MB) an take a look on your watch.

I've changed some program I've made and it doesn't make any difference.
Look at comment:
}

program HD2;

{$R-,S-}

uses Dos;

const
  MaxDirSize = 512;
  BufSize = 32768;

var
  buf: array[1..BufSize] of byte;
  MinSize, TotSize, Tdiff, diff, timer1, timer2, Tsize, size : longint;
  Count,Iter, MaxIter : word;
  Dir: DirStr;
  path : pathstr;
  srec : searchrec;
  options : string;

function capslock(doelwit : string) : string;
var i : integer;
begin
  for i := 1 to length(doelwit) do
    if doelwit[i] in ['a'..'z'] then
      doelwit[i] := chr(ord(doelwit[i])-32);
  capslock := doelwit;
end;

procedure LogTime( var ti : longint);
var
  ho,mi,se,hund : word;
begin
  GetTime(ho,mi,se,hund);
  Ti := hund+se*100+mi*6000+ho*360000;
end;

function ReadNumber(t:byte; s:string): word;
var
  nm:string;
  rn: word;
  code: integer;
begin
  nm := '';
  inc(t,2);
  while (t<=length(s)) and (s[t] in ['0'..'9']) do
  begin
    Nm := Nm + s[t];
    inc(t);
  end;
  Val( Nm, rn, code);
  if code=0 then
    ReadNumber := Rn
  else
    ReadNumber := 0;
end;

procedure Init;
begin
  TotSize := 128;
  MaxIter := 10;
  MinSize := 1;
  Tdiff := 0;  Tsize := 0;
  options := '';
  path := '';
end;

procedure Help;
begin
  writeln('Syntax:  HD [filename] [options]');
  writeln;
  writeln('/Mxxxx : Minimum filesize for files to be tested');
  writeln('/Txxxx : Total size in Kb per file read (default = 128 kb)');
  writeln('/Ixxxx : Maximum iterations');
  writeln('/?     : This helptext');
  writeln;
  writeln('This programs measures how fast the specified file can be read into memory');
  writeln('and then the transfer rate is been calculated.  If a file is smaller than');
  writeln( TotSize, ' Kb the file will be read more than once to accomplish more reliable results.');
  halt;
end;

procedure GetParams;
var
  t:byte;
  f:file;
  Attr:word;
  N:NameStr;
  E:ExtStr;
begin
  for t := 1 to ParamCount do
    if Copy(ParamStr(t),1,1) <> '/' then
      path := ParamStr(t)
    else
      options := options + paramstr(t);


  t := 1;
  while t < length(options) do
  begin
    if options[t]='/' then
    begin
      case upcase(options[t+1]) of
      'T': if ReadNumber(t,options) <>0 then TotSize := ReadNumber(t,options);
      'M': if ReadNumber(t,options) <>0 then MinSize := ReadNumber(t,options);
      'I': if ReadNumber(t,options) <>0 then MaxIter := ReadNumber(t,options);
      '?': Help;
      end;
    end;
    inc(t);
  end;

  writeln('Min.  size: ', MinSize, ' Kb');
  writeln('Total size: ', TotSize, ' Kb');
  writeln('Iterations: ', MaxIter);
  writeln;

  Path := FExpand(Path);
  if Path[Length(Path)] <> '\' then
  begin
    Assign(F, Path);
    GetFAttr(F, Attr);
    if (DosError = 0) and (Attr and Directory <> 0) then
      Path := Path + '\';
  end;
  FSplit(Path, Dir, N, E);
  if N = '' then N := '*';
  if E = '' then E := '.*';
  Path := Dir + N + E;
  writeln('Path:     ', Path);
  writeln;
end;

procedure GetBench;
var
  F:File;
  sr : SearchRec;
  t : word;
  NumRead: Word;
  iterstr : string;
begin
  Count := 0;
  FindFirst(Path, Archive, sr);
  while (DosError = 0) and (Count < MaxDirSize) do
  begin
    if (sr.attr and ReadOnly) <> ReadOnly then
    begin
      assign(f, dir+sr.name);

      size := sr.size;
      if size<MinSize*1024 then
        iter := 0
      else
        iter := (TotSize*1024) div size + 1;
      if iter>MaxIter then Iter := MaxIter;
      write( copy(sr.name+'             ',1,13));
      if iter > 1 then
      begin
        str( iter, iterstr);
        write( '('+iterstr+'x)' : 6)
      end
      else
        write( ' ' : 6);

      LogTime( timer1);

      for t := 1 to iter do
      begin
        Reset(F,1);  { COMMENT: 'reset (f,512)' }
        repeat
          BlockRead(F, buf, SizeOf(buf), NumRead);
          { COMMENT: and 'SizeOf(Buf) div 512' doesn't make any difference }
        until (NumRead = 0);
        Close(F);
      end;

      LogTime( Timer2);
      diff := Timer2-timer1;
      write( '  ', size*iter : 6, ' bytes in ', diff/100 : 5 : 2, ' sec.  ');
      if Diff>0 then
        writeln( 'Transfer speed ', iter*size/diff/10.24 : 3 : 1,
                 ' Kb/sec.')
      else
        writeln;
      inc( Tdiff, diff);
      inc( Tsize, size*iter);
      inc( count);
    end;
    FindNext(sr);
  end;
end;

begin
  writeln;
  writeln('HD Transfer Speed Timer  v2.0 * (c)1991,1993 Marnix Timmermans');
  writeln;

  Init;

  GetParams;

  GetBench;

  writeln;
  writeln( 'Totals of ',count:5,' files : ', Tsize, ' bytes in ', Tdiff/100 : 5 : 2, ' sec.  ');
  if TDiff <> 0 then
    writeln( 'Average Transfer speed: ', Tsize/Tdiff/10.24 : 3 : 1, ' Kb/sec.');
end.

