(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0031.PAS
  Description: Parse file by words
  Author: MIKE CHAMBERS
  Date: 02-03-94  16:18
*)


program ReadWord;
uses dos,crt;
Const
  delimiters = ' ,./?;:"[]{}!';
  CrLf       = #13#10;
type
  tfilename = string;
  word_type = string;
  wp_type   = ^word_type;

var
  i          : word;
  filter     : string;
  sr         : searchrec;
  path       : pathstr;
  dir        : dirstr;
  fname      : namestr;
  ext        : extstr;
  Lines       : word;


procedure ShowSyntax;
begin
  writeln('USAGE       OBJDIC     <input fileset>                         ');
  writeln('                                                               ');
  writeln('       <input fileset> is a DOS filename (wildcards allowed)   ');
  writeln('                                                               ');
  writeln('                                                               ');
  writeln('Example    OBJDIC *.TXT                                        ');
  halt;
end;


function GetNextWord (buf:string; apos:byte; var aword:word_type; var delim:string) : byte;
var i,j,ch: byte;
begin
  i := apos;
  while (i <= length(buf)) and (pos(buf[i],delimiters) = 0) do inc (i);
  aword := copy(buf,apos, i - apos);
  j:= i;
  while (i <= length(buf)) and
       ( ( (upcase(buf[i]) < 'A') or (upcase(buf[i]) > 'Z') ) and
         ( (buf[i] <  '0'       ) or (buf[i] > '9'        ) ) )
        do inc(i);
  delim := copy(buf,j,i-j);
  if i = length(buf) then i := 0;
  GetNextWord :=i;
end;



procedure scanfile(filename : string);
var
  infile : text;
  inbuf  : string;
  aword  : word_type;
  adelim : word_type;
  len    : byte;
  inpos  : byte;
  index  : word;

begin
  path := fexpand(filename);
  fsplit(path,dir,fname,ext);
  assign(infile,path);
  reset(infile);
  clrscr;
  lines:=0;
  writeln('Scanning ',filename);
  while not eof(infile) do begin
     readln(infile,inbuf); inc(lines);
     inpos := 1;
     while (inpos < length(inbuf)) and (inpos <> 0) do begin
       inpos := GetNextWord(inbuf,inpos,aword,adelim);
       if length(aword) > 0 then write(aword);
       if length(adelim) > 0 then write(adelim);
     end;
     writeln;
   end;
   close(infile);
   writeln;
 end;

 begin
   filter := Paramstr(1);
   FindFirst(Filter,AnyFile,sr);
   while DosError = 0 do with sr do begin
      scanfile(fexpand(name));
      FindNext(sr);
   end;
 end.

