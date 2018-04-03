(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0116.PAS
  Description: Finding All Directories
  Author: MICHAEL DAY
  Date: 08-30-96  09:35
*)


{$I-}
{$M 65000,0,1024}
program KillDir;
uses crt,dos;

type String12 = string[12];
var TotalSize : longint;
    ThisSize : longint;

procedure UpString(var S:string);
var i:word;
begin
  for i := 1 to length(S) do
    S[i] := upcase(S[i]);
end;

function AbortIt:boolean;

var ch : char;
begin
  AbortIt := false;
  if not(KeyPressed) then Exit;
  ch := readkey;
  if ch = #0 then ch := chr(ord(readkey) or $80);
  if (ch = ^C) or (ch = ^X) or (ch = ^Q) or (ch = #$1B) then
    AbortIt := true;
end;

function GetSize(var F:file):string12;
var RawSize : longint;
    Size:string;
begin
   Reset(F,1);
   RawSize := FileSize(F);
   Close(F);
   ThisSize := RawSize;
   if IOresult <> 0 then {nop};
   if RawSize < 10000 then
   begin
     str(RawSize,Size);
   end
   else if RawSize < (1024*999) then
   begin

     str(RawSize div 1024,Size);
     Size[length(Size)+1] := 'K';
     inc(Size[0]);
   end
   else
   begin
     str(RawSize div (1000*1024),Size);
     Size[length(Size)+1] := 'M';
     Inc(Size[0]);
   end;
   while length(Size) < 4 do
   begin
     Size := ' '+Size;
   end;
   GetSize := Size;
end;

function SizeIt(Which:string):byte;
var DirInfo:SearchRec;
    f : file;
    Attr,Result:word;
    Size,Who:string12;
    Current:string;
begin
  SizeIt := 1;
  if IOresult <> 0 then {nop};
  GetDir(0,Current);

  chdir(Which);
  if IOresult <> 0 then Exit;
  Who := '*.*';
  findfirst(Who, $3F, DirInfo);
  while DosError = 0 do
  begin
    if AbortIt then
    begin
      SizeIt := 2;
      Exit;
    end;
    if (DirInfo.Name <> '.') and (DirInfo.Name <> '..') then
    begin
      Assign(F,DirInfo.Name);
      GetFAttr(F,Attr);
      if (Attr and Directory) <> 0 then
      begin
        Result := SizeIt(DirInfo.Name);
        SizeIt := Result;
        if Result <> 0 then Exit;
      end
      else
      begin
        SetFAttr(F,0);
        Size := GetSize(F);

        Who := DirInfo.Name+'            ';
        writeln(Current+'\'+Which,'  ',Who,' Size:',Size);
        TotalSize := TotalSize+ThisSize;
      end;
    end;
    FindNext(DirInfo);
  end;
  if IOresult <> 0 then {nop};
  ChDir(Current);
  SizeIt := 0;
end;


var Where:string;
    Current:string;
    Yorn:string;
    Result:word;

begin
  TotalSize := 0;
  writeln;
  Writeln('Directory Sizer V1.01  Written by Michael Day as of 05 Sept 94');
  if ParamCount < 0 then
  begin
    writeln('Format is: FSIZE DIRNAME');

    writeln('This program will find the size of all files and all directories');
    writeln('in and below the directory DIRNAME.');
    halt(1);
  end;

  Where := ParamStr(1);
  UpString(Where);
  if pos(Where,':') <> 0 then
  begin
    writeln('Sorry, you cannot size directories on another drive with this program.');
    writeln('Please move to that drive first.');
    halt(2);
  end;

  if IOresult <> 0 then {nop};
  GetDir(0,Current);
  chdir(Where);
  if IOresult <> 0 then
    Result := 1
  else
    Result := 0;
  chdir(Current);


  if Result = 0 then
  begin

    writeln('This will find the size of ALL files and ALL directories in and below:');
    writeln(Current+'\'+Where);

    Result := SizeIt(Where);
    chdir(Current);

    write('Total size of the directory');
    write(Current+'\'+Where);
    writeln(TotalSize);

    if Result = 2 then
    begin
      writeln('Directory size operation terminated by the user.');
      Halt(3);
    end;
  end;

  if Result = 1 then
  begin
    writeln('Error finding directory: ',Where);
    writeln('The directory probably does not exist.');
    halt(4);
  end;

end.

Here is the short version written for BP7 in DOS:

This program simply lists the names of the files, but you could change the output line do
accumulate sizes just as easily.

program search;

uses dos;
var i:integer;
    d:dirstr; n:namestr; x:extstr;

  procedure helpmsg;
  begin
    writeln('SEARCH filespec [filespec]...');
  end;

  procedure dosearch(const d:string);
  var sr:searchrec;

    procedure dofilesearch;
    begin
      findfirst(d+n+x,archive+readonly,sr);
      while doserror=0 do begin
        writeln(d+sr.name);        { THE output }
        findnext(sr);
      end;
    end;

    procedure dodirsearch;
    begin
      findfirst(d+'*.*',directory,sr);
      while doserror=0 do begin

        if (sr.attr and directory = directory)
        and (sr.name[1]<>'.') then              { ignores "." and ".." }
          dosearch(d+sr.name+'\');
        findnext(sr);
      end;
    end;

  begin {dosearch}
    dofilesearch;
    dodirsearch;
  end;

begin
  if paramcount<1 then helpmsg
  else begin
    for i:=1 to paramcount do begin
      fsplit(paramstr(i),d,n,x);
      dosearch(d);
    end;
  end;
end.
