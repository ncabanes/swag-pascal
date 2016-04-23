{
  National ASCII Resource Converter v1.1

  Author: Casey Billett
          RR#4,
          Prescott, Ontario,
          Canada
          K0E 1T0
          ** bassman@recorder.ca **

  Date: Monday, August 9, 1997
  License: Freeware
  Agreement: Header stays intact of source code
  Help: This currently has a maximum text file length of 60000 chars.
        If anyone develops an adequate method of delineating this
        problem, please e-mail me. Possible methods include:
                 const FAtype = array [1..60000] of char;
                 var FA: ^FAType;
                 new(FA);
        and referencing it from there. Regardless...
}

program NARC; { National ASCII Resource Converter }

uses
  CRT,DOS;

{
-- Line endings of different format text files --
#13,#10 = DOS
#13 = MAC
#10 = UNIX
}

{
-- Assign writemodes to different formats --
writemode == 1; DOS
writemode == 2; MAC
writemode == 3; UNIX
}
type
  FAtype = array[0..60000] of char;  { Maximum text length = 60000 }

var
  f:text;                       { Assigned paramstr(1) - file to convert }
  writemode: integer;           { Assigned the format of txt file to read }
  readmode: integer;            { Assigned the format of txt file to write }
  FA: FAtype;
  j: integer;                   { Contains length of file }


const
  DOSf=1;                       { DOS file format }
  MACf=2;                       { Macintosh file format }
  UNIXf=3;                      { Unix file format }
  CR=#13;                       { Carriage return character }
  LF=#10;                       { Line feed character }

{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure init;                 { General initialization & logo }
begin
  textcolor(White);
  write('  NARC: ');
  textcolor(LightGray);
  writeln('National ASCII Resource Converter');
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure displayinstructions; { Display if the syntax is not right }
begin
  textcolor(White);
  write('  **');
  textcolor(Red);
  write(' NARC');
  textcolor(DarkGray);
  write(' - usage:');
  textcolor(White);
  write(' narc');
  write(' filename1 filename2');
  textcolor(Green);
  write(' [udm]');
  textcolor(White);
  writeln('  **');
  textcolor(Green);
  write('            u');
  textcolor(LightGray);
  writeln(': Convert filename1 to unix format and save in filename2');
  textcolor(Green);
  write('            d');
  textcolor(LightGray);
  writeln(': Convert filename1 to dos format and save in filename2');
  textcolor(Green);
  write('            m');
  textcolor(LightGray);
  writeln(': Convert filename1 to mac format and save in filename2');
  writeln('            See READ.ME for examples');
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function filesOK: boolean;      { Make sure file in params exists }
var f:text;
begin
{$I-}
  filesOK := TRUE;
  assign(f, paramstr(1));
  reset(f);
  if IOResult <> 0 then begin
    textcolor(White);
    write('  ** Error: ');
    textcolor(LightGray);
    writeln('File ', paramstr(1), ' does not exist');
    filesOK := FALSE;
  end;
  close(f);
{$I+}
  if (paramcount=1) then begin
    textcolor(White);
    write('  ** Error: ');
    textcolor(LightGray);
    writeln('Must specify output file');
    filesOK := FALSE;
  end;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function paramsOK: boolean;     { Checks to make sure sytax ok }
var k:integer;
begin
  paramsOK := FALSE;
  if (ParamCount = 0) then
    displayinstructions
  else begin
    if filesOK then paramsOK := TRUE else displayinstructions;
  end;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure writefile(var f: text);    { Write the file in the new format }
var k:integer; temp:char;
begin
  assign (f, paramstr(2));
  rewrite(f);
  for k:= 0 to j do begin
    temp:=FA[k];
    if (temp <> CR) and (temp <> LF) and (j<>k) then write(f, temp)
    else begin
      if temp = CR then begin
        case writemode of
          DOSf: write(f, CR,LF);
          MACf: write(f, CR);
          UNIXf: write(f, LF);
        end; {case}
      end;
      if (temp = LF) and (readmode = UNIXf) then begin
        case writemode of
          DOSf: write(f, CR,LF);
          MACf: write(f, CR);
          UNIXf: write(f, LF);
        end; {case}
      end;
    end;
  end;
  close(f);
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure readfile(var f:text);  { Read the input file charxchar }
begin
  j:=0;
  while not(EOF(f)) do begin
    read(f,FA[j]);
    inc(j);
  end;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function determinetype:integer;  { Determines format of input file }
var k,l:integer;
begin
  for k:=0 to j do begin
    if (FA[k] = CR) and (FA[k+1] = LF) then begin
      determinetype := DOSf;
      exit;
    end
    else
    if (FA[k] = CR) and (FA[k+1] <> LF) then begin
      determinetype := MACf;
      exit;
    end
    else
    if (FA[k] = LF) then begin
      determinetype := UNIXf;
      exit;
    end;
  end;
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
function determinewrite: integer;  { Checks param to determine write format }
var temp:string;
begin
  temp:=paramstr(3);
  case temp[1] of
    'd': determinewrite := DOSf;
    'u': determinewrite := UNIXf;
    'm': determinewrite := MACf;
    else determinewrite := DOSf;
  end
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
procedure operation(readf,writef:integer);            { Determines conversion operation }
begin
  readmode := readf;
  writemode := writef;
  case readmode of
    DOSf: write('  DOS text file - ');
    MACf: write('  Mac text file - ');
    UNIXf: write('  Unix text file - ');
  end; {case};
  case writemode of
    DOSf: writeln('DOS text file');
    MACf: writeln('Mac text file');
    UNIXf: writeln('Unix text file');
  end; {case}
end;
{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
begin
  init;
  if (paramsOK) then begin
    assign(f, paramstr(1));
    reset(f);
      readfile(f);
    close(f);
    writeln('  Determining file type...');
    operation(determinetype,determinewrite);
    writefile(f);
    writeln('  Complete.');
  end;
end.