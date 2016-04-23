{
  Program MAKEDCT, written by Steve Rogers, 1991. Takes an ASCII text
  file as ParamStr(1) and creates a "dictionary file" of all the unique
  words in the input file. Feel free to use it all you want and mention
  my name if you feel like it... :)
}

uses
  dos,
  strg;  { Eagle Performance Software's STRG unit. Shareware version is
           available on most TP oriented BBSs. If you use the shareware
           version your program will need to be compiled with $E+. }

const
  MAXPTR=5000; { Max string pointers before paging out to disk }

type
  pS20=^tS20;
  tS20=string[20];

var
  f    : text;
  s,
  s2   : string;
  s_   : array[0..MAXPTR] of pS20;
  i,
  n    : word;

  ndx,
  NTempFile
       : byte;
  max  : tS20;

{-----------------------}
procedure QSort(Lo,Hi : integer);
(*
  Just a generic QuickSort using Eagle's string comparison routines
*)

var
  i,j : integer;
  x,y: pS20;

begin
  i:= lo;
  j:= hi;
  x:= s_[(lo+hi) div 2];
  repeat
    while (strcmp(s_[i]^,x^,1,1,255)<0) do
      inc(i);
    while (strcmp(s_[j]^,x^,1,1,255)>0) do
      dec(j);

    if (i<=j) then begin
      y:= s_[i];
      s_[i]:= s_[j];
      s_[j]:= y;
      inc(i);
      dec(j);
    end;

  until (i>j);
  if (lo<j) then
    qsort(lo,j);

  if (i<hi) then
    qsort(i,hi);
end;

{-----------------------}
procedure WriteTempFile;
var
  i : word;
  tempf : text;
  stmp   : string;

begin
  inc(NTempFile);
  qsort(1,n);
  writeln('Filing to outfile #',NTempFile);
  assign(tempf,'wordtemp.'+strl(NTempFile));
  rewrite(tempf);
  stmp:= '';
  for i:= 1 to n do if (strcmp(s_[i]^,stmp,1,1,255)<>0) then begin
    strmov(stmp,s_[i]^);
    if (max<stmp) then
      strmov(max,stmp);
    writeln(tempf,s_[i]^);
  end;
  n:= 0;
  close(tempf);
end;

{-----------------------}
procedure MergeTempFiles;
var
  f_ : array[1..50] of text;
  outf : text;
  i : byte;
  s_ : array[1..50] of tS20;
  min : tS20;

begin
  writeln('Merging ',strl(NTempFile),' temp files');

  for i:= 1 to NTempFile do begin
    assign(f_[i],'wordtemp.'+strl(i));
    reset(f_[i]);
    readln(f_[i],s_[i]);
  end;

  strmov(min,paramstr(1));
  strovrl(min,'.DCT',strposr(min,'.',1));
  assign(outf,min);
  rewrite(outf);

  repeat
    min:= max;
    for i:= 1 to NTempFile do if (s_[i]<min) then
      min:= s_[i];
    writeln(outf,min);

    for i:= 1 to NTempFile do if (s_[i]<=min) then
      if not eof(f_[i]) then
        readln(f_[i],s_[i])
      else
        s_[i]:= #254;
  until (min=max);

  close(outf);
  for i:= 1 to NTempFile do begin
    close(f_[i]);
    erase(f_[i]);
  end;
end;

{-----------------------}
procedure StripPunctuation(var s : string);

const
  LCCHARS=['a'..'z']; { lower case chars }

var
  i : byte;

begin
  { Replace all non-alpha chars with spaces. It's lower case already. }
  for i:= 1 to length(s) do
    if not (s[i] IN LCCHARS) then
      s[i]:= ' ';

  { Remove all double spaces }
  while (strqty(s,'  ')>0) do
    strrepl(s,'  ',' ',1,255);

end;

{-----------------------}
begin
  NTempFile:= 0;
  n:= 0;
  max:= '';
  for i:= 1 to MAXPTR do
    new(s_[i]);

  assign(f,paramstr(1));
  reset(f);

  writeln('Reading');
  while not eof(f) do begin
    readln(f,s);
    strlwr(s);
    StripPunctuation(s);
    ndx:= 1;
    while (ndx<>0) do begin
      wrdparse(s2,s,' ',ndx);
      inc(n);
      strmov(s_[n]^,s2);
      if (n=MAXPTR) then
        WriteTempFile;
    end;
  end;
  close(f);

  WriteTempFile;

  if (NTempFile>1) then
    MergeTempFiles
  else begin
    s:= paramstr(1);
    strovrl(s,'.DCT',strposr(s,'.',1));

    { Remove output file if it already exists }
    if (FSearch(s,'')<>'') then begin
      assign(f,s);
      erase(f);
    end;

    assign(f,'wordtemp.1');
    rename(f,s);
  end;
end.

