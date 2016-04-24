(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0044.PAS
  Description: Zip Comment Program
  Author: ZAK SMITH
  Date: 08-30-97  10:09
*)


{
  This code may be used as long as the resulting product is FREE.

  See the end of the file (after end.) for the zipfile data structure

  Written by Zak Smith

       I am reachable the following ways..
             sysop Sirius Cybernetics 414-966-3552
             Zak Smith @ 1:154/736 fido-land
             zak.smith@mixcom.com
}


{$M 32768,0,65520}
Program ZipComment;  { by Zak, mahahaha }
Uses Dos,Crt;
Type FindZipType = record
    id : longint;
    dn : array[1..2] of byte;
    sd : array[1..2] of byte;
    cd : array[1..2] of byte;
    tcd: array[1..2] of byte;
    scd: array[1..4] of byte;
    sdn: array[1..4] of byte;
    cl : word;
   end;
var total    : longint;
    starttime: longint;
type commentfiletype = record
      len : word;
      data : array[1..5120] of byte;
      end;

function SecondsSinceMidnight(h,m,s:word):longint;
  begin
  SecondsSinceMidnight := (h*3600)+(m*60)+s
  end;

procedure CurTime(var h:word; var m: word;var s:word);
 Var Hour,Min,Sec,Sec100:word;
 begin
 GetTime(Hour,Min,Sec,Sec100);
 h:=hour;
 m:=min;
 s:=sec;
 end;

function nowsecondssincemidnight: longint;
 var h,m,s: word;
 begin
 curtime(h,m,s);
 nowsecondssincemidnight:=secondssincemidnight(h,m,s);
 end;

(********* The following search engine routines are sneakly swiped *********)
(********* from Turbo Technix v1n6.  See there for further details *********)

type
  ProcType=             procedure(var S: SearchRec; P: PathStr);
var
  EngineMask:           PathStr;
  EngineAttr:           byte;
  EngineProc:           ProcType;
  EngineCode:           byte;

function ValidExtention(var S: SearchRec): boolean;
var
  Junk1: dirstr                ;
  junk2: namestr;
  E:                    ExtStr;
begin
  if S.Attr and Directory=Directory then
  begin
    ValidExtention := true;
    exit;
  end;
  FSplit(S.Name,Junk1,Junk2,E);

  if (E='.ZIP') then

  ValidExtention := true else ValidExtention := false;
end;

procedure SearchEngine(M: dirstr; Attr: byte; Proc: ProcType;
                       var ErrorCode: byte);
var
  S:                    SearchRec;
  P:                    dirStr;
  Ext:                  ExtStr;
  Mask:                 Namestr;
begin
  FSplit(M, P, Mask, Ext);
  Mask := Mask+Ext;
  FindFirst(P+Mask,Attr,S);
  if DosError<>0 then
  begin
    ErrorCode := DosError;
    exit;
  end;
  while DosError=0 do
  begin
    if ValidExtention(S) then Proc(S, P);
    FindNext(S);
  end;
  if DosError=18 then ErrorCode := 0
  else ErrorCode := DosError;
end;

function GoodDirectory(S: SearchRec): boolean;
begin
  GoodDirectory := (S.name<>'.') and (S.Name<>'..') and
  (S.Attr and Directory=Directory);
end;

procedure SearchOneDir(var S: SearchRec; P: PathStr); far;
begin
  if GoodDirectory(S) then
  begin
    P := P+S.Name;
    SearchEngine(P+'\'+EngineMask,EngineAttr,EngineProc,EngineCode);
    SearchEngine(P+'\*.*',Directory or Archive, SearchOneDir ,EngineCode);
  end;
end;

procedure SearchEngineAll(Path: PathStr; Mask: pathStr; Attr: byte;
                          Proc: ProcType; var ErrorCode: byte);
begin
  EngineMask := Mask;
  EngineProc := Proc;
  EngineAttr := Attr;
  SearchEngine(Path+Mask,Attr,Proc,ErrorCode);
  SearchEngine(Path+'*.*',Directory or Archive,SearchOneDir,ErrorCode);
  ErrorCode := EngineCode;
end;

(************** Thus ends the sneakly swiped code *************)
(**** We now return you to our regularly scheduled program ****)

procedure status(p,f:string);
 var tt:longint;
 begin
 gotoxy(1,wherey);
 textcolor(cyan);
 write('File: ');
 textcolor(lightcyan);
 write(p,f);
 gotoxy(50,wherey);
 textcolor(lightgray);
 write('Time: ');
 textcolor(white);
 tt:=(NowSecondsSinceMidnight-StartTime);
 write(tt:5);
 textcolor(lightgray);
 write(' / ');
 write(total:5);
 end;

var c:^commentfiletype;

procedure AddComment(var s:searchrec; p:pathstr); far;
  type bffrtype = array[1..1500] of byte;
  var f :file;
      b :^bffrtype;
      ofs: longint;
      tv : longint;
      zd : findziptype;
  function inray:word;
   var i:word;
   begin
    inray:=0;
    for i:= 1 to tv do
    begin
    move(b^[i],zd,sizeof(zd));
    if zd.id= $06054b50 then
      begin
      inray:=i;
      exit;
      end;
    end;
   end;

  begin
  assign(f,p+s.name);
  {$I-}
  reset(f,1);
  if ioresult<>0 then exit;
  {$I+}
  new (b);
  fillchar(b^,sizeof(b^),#0);
  tv:=filesize(f);
  if tv>sizeof(b^) then tv:=sizeof(b^);
  seek(f,filesize(f)-tv);
  blockread(f,b^,tv);
  ofs:=inray;
  if not (ofs=0) then
    begin
    zd.cl:=c^.len;
    seek(f,filesize(f)-1-tv+ofs);
    blockwrite(f,zd,sizeof(zd));
    blockwrite(f,c^.data,c^.len);
    end;
  close(f);
  dispose(b);
  inc(total);
  status(p,s.name);
  end;

procedure loadcommentfile;
var f:file;
 begin
 assign(f,getenv('ZIPCOMNT'));
 reset(f,1);
 blockread(f,c^.data,filesize(f));
 c^.len:=filesize(f);
 close(f);
 end;


var err:byte;
begin
total:=0;
StartTime:=NowSecondsSinceMidnight;
writeln;
writeln('ZipC - Zak''s semiPersonal Hyper-Speed Zipfile Commenter');
writeln;
directvideo:=true;
new(c);
loadcommentfile;
SearchEngineAll (
  fExpand('.\'),
  '*.ZIP',
  anyfile,
  AddComment,
  err);

writeln;
writeln;
writeln('ZipC Done.');
dispose(c);
end.

 Specific ZIP data struct. used here..

        end of central dir signature    4 bytes  (0x06054b50)
        number of this disk             2 bytes
        number of the disk with the
        start of the central directory  2 bytes
        total number of entries in
        the central dir on this disk    2 bytes
        total number of entries in
        the central dir                 2 bytes
        size of the central directory   4 bytes
        offset of start of central
        directory with respect to
        the starting disk number        4 bytes
        zipfile comment length          2 bytes
        zipfile comment (variable size)


