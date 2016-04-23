unit ZipView;

interface
uses dos;

type
 barray= array[1..8192] of byte;
 ZipPtr=^ZipRec;
 ZipRec= Record
          version_made: word;
          version_extr: word;
          flags: word;
          comp_method: word;
          last_mod_time: word;
          last_mod_date: word;
          crc_32: longint;
          compressed_size: longint;
          uncompressed_size: longint;
          fname_length: word;
          extra_length: word;
          comment_length: word;
          disk_num_start: word;
          internal_attr: word;
          external_attr: longint;
          rel_ofs: longint;
          name: string[12];
          Next: ZipPtr;
         end;
 bptr = ^barray;
const
 ZipMethod: array[0..9] of string[15] =
           ('stored   ',          'shrunk   ',       'reduced-1',
            'reduced-2',          'reduced-3',       'reduced-4',
            'imploded ',          'unknown  ',       'unknown  ',
            'unknown  ');

var
 totallength,totalsize,numfiles: longint;
 firstzip: zipptr;
 lineout: string;
 outPtr: pointer;

procedure LoadZip(filename: string);
procedure DisplayZip;
procedure DisposeZip;

implementation

var
 f: file of barray;
 buffer: barray;
 addr: longint;
 bufptr: word;

{$F+}
Procedure CallProc;
inline($FF/$1E/OutPtr);
{$F-}

Function NextByte: byte;
var i: integer;
begin;
 inc(addr);
 inc(bufptr);
 if bufptr=8193 then begin;
  {$I-}
  read(f,buffer);
  {$I+}
  i:=ioresult;
  bufptr:=1;
 end;
 nextbyte:=buffer[bufptr];
end;

procedure LoadZip(filename: string);
var
 b: byte;
 f2: file of byte;
 fs: longint;
 LastZip,Zip: ZipPtr;
 Bytes: Bptr absolute zip;
 a: integer;
 sr: searchrec;
begin;
 firstzip:=nil;
{ assign(f2,filename);
 reset(F2);
 fs:=filesize(f2);
 close(f2);}
 findfirst(filename,anyfile,sr);
 fs:=sr.size;
 assign(f,filename);
 reset(f);
 addr:=0;
 if fs>65535 then begin;
  seek(f,(fs div 8192)-4);
  addr:=addr+((fs div 8192)-4)*8192;
 end;
 {$I-}
 read(f,buffer);
 {$I+}
 a:=ioresult;
 bufptr:=0;
 b:=nextbyte;
 repeat;
  if b=$50 then begin;
   b:=nextbyte;
   if b=$4b then begin;
    b:=nextbyte;
    if b=$01 then begin;
     b:=nextbyte;
     if b=$02 then begin;
      new(zip);
      zip^.next:=nil;
      if firstzip=nil then firstzip:=zip else lastzip^.next:=zip;
      lastzip:=zip;
      for a:=1 to 42 do bytes^[a]:=nextbyte;
      zip^.name:='';
      for a:=1 to zip^.fname_length do zip^.name:=zip^.name+chr(nextbyte);
      b:=nextbyte;
     end;
    end;
   end;
  end else b:=nextbyte;
 until addr>=fs;
end;

procedure OutLine(s: string);
begin;
 lineout:=s;
 if OutPtr=NIL then writeln(s) else CallProc;
end;

function format_date(date: word): string;
var
 s,s2: string;
 y,m,d: word;
begin
 m:=(date shr 5) and 15;
 d:=( (date      ) and 31);
 y:=(((date shr 9) and 127)+80);
 str(m,s);
 while length(s)<2 do s:='0'+s;
 s:=s+'-';
 str(d,s2);
 while length(s2)<2 do s2:='0'+s2;
 s:=s+s2+'-';
 str(y,s2);
 while length(s2)<2 do s2:='0'+s2;
 s:=s+s2;
 format_date:=s;
end;

function format_time(time: word): string;
var
 s,s2: string;
 h,m,se: word;
begin
 h:=(time shr 11) and 31;
 m:=(time shr  5) and 63;
 se:=(time shl  1) and 63;
 str(h,s);
 while length(S)<2 do s:='0'+s;
 s:=s+':';
 str(m,s2);
 while length(s2)<2 do s2:='0'+s2;
 s:=s+s2;
 format_time:=s;
end;

procedure DisplayHeader;
begin;
 OutLine('Filename      Length   Size     Method     Date      Time   Ratio');
 OutLine('------------  -------  -------  ---------  --------  -----  -----');
end;

procedure DisplayFooter;
var
 s,s2: string;
 average: real;
begin;
 OutLine('------------  -------  -------                              -----');
 average:=100-totalsize/totallength*100;
 str(numfiles:12,s);
 str(totallength:7,s2);
 s:=s+'  '+s2+'  ';
 str(totalsize:7,s2);
 s:=s+s2+'                              ';
 str(average:4:0,s2);
 s:=s+s2+'%';
 outline(s);
end;

procedure DisplayZip;
var
 curzip: zipptr;
 s,s2: string;
begin;
 numfiles:=0;
 totallength:=0;
 totalsize:=0;
 DisplayHeader;
 curzip:=firstzip;
 while curzip<>nil do begin;
  s:=curzip^.name;
  while length(s)<14 do s:=s+' ';
  str(curzip^.uncompressed_size,s2);
  while length(s2)<7 do s2:=' '+s2;
  s:=s+s2+'  ';
  str(curzip^.compressed_size,s2);
  while length(s2)<7 do s2:=' '+s2;
  s:=s+s2+'  ';
  s:=s+ZipMethod[curzip^.comp_method]+'  ';
  s:=s+format_date(curzip^.last_mod_date)+'  '+format_time(curzip^.last_mod_time)+'  ';
  str(100-curzip^.compressed_size/curzip^.uncompressed_size*100:1:1,s2);
  s2:=s2+'%';
  while length(s2)<5 do s2:=' '+s2;
  s:=s+s2;
  Outline(s);
  totallength:=totallength+curzip^.uncompressed_size;
  totalsize:=totalsize+curzip^.compressed_size;
  inc(numfiles);
  curzip:=curzip^.next;
 end;
 if (numfiles=0) or (totallength=0) or (totalsize=0) then begin;
  outline('No valid file entries detected.');
 end else begin;
  displayfooter;
 end;
end;

procedure DisposeZip;
var
 curzip,savezip: zipptr;
begin;
 curzip:=firstzip;
 while curzip<>nil do begin;
  savezip:=curzip^.next;
  dispose(curzip);
  curzip:=savezip;
 end;
end;

begin;
 OutPtr:=Nil;
end.

{ --------------------------   CUT HERE -----------------------------}
{ TEST PROGRAM }

uses zipview;

var
 s: string;
begin;
 write('File to Zip-View ? ');
 readln(s);
 LoadZip(s);
 DisplayZip;
 DisposeZip;
end.