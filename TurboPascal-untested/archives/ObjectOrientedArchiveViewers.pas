(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0038.PAS
  Description: Object Oriented Archive Viewers
  Author: EDWIN GROOTHUIS
  Date: 02-21-96  21:04
*)


{ OOAVTEST.PAS
  cut out each of the units below and compile to test the use of this package}

uses      OOAV,Dos;

var       a:PArchive;
          sr:SearchRec;
          DT:DateTime;

begin
  writeln('avail: ',memavail);

  { It's not necessary that you call IdentifyArchive,
    but it's easy for checking when you've add new archive-types }
  case IdentifyArchive(paramstr(1)) of
    '?': writeln('Cannot open/identify current archive');
    'Z': writeln('It''s a ZIP-archive');
    'A': writeln('It''s an ARJ-archive');
    'L': writeln('It''s an LZH-archive');
    'C': writeln('It''s an ARC-archive');
    'O': writeln('It''s a ZOO-archive');
  end;

  a:=New(PArchive,Init);
  if not a^.Name(paramstr(1)) then
  begin
    writeln('Cannot open file');
    exit;
  end;
  writeln('Name':15,'Size':10,'Date':10,'Time':12);
  a^.FindFirst(sr);
  while sr.Name<>'' do
  begin
    write  (sr.Name:15,sr.Size:10);
    UnpackTime(sr.Time,DT);
    writeln(dt.day:10,dt.month:3,dt.year:5,dt.hour:4,dt.min:3,dt.sec:3);
    a^.FindNext(sr);
  end;
  Dispose(A,Done);
  writeln('End');
  writeln('avail: ',memavail);
end.

{ the rest of the units follow }
{ CUT ----------------------------------------------------------- }

{
        Object-Oriented Archive-viewer, version 3
        ─────────────────────────────────────────
        This Object-Oriented Archive-viewer (OOAV) is copyright (c) by
        Edwin Groothuis, MavEtJu software. You are free to use it
        if you agree with these three rules:

        1. You tell me you're using this unit.

        2. You give me proper credit in the documentation. (Like:
           "This program uses the Object-Oriented Archive-viewer
            (c) Edwin Groothuis, MavEtJu software".

        3. If you make Archive-objects for other archive-types, don't
           hesitate to inform me so I can add them to the unit and
           redistribute it!

        That's all!

        How to use this unit:
        ─────────────────────
        (see also the file ArchTest.pas)

        - Declare a variable Arch of the       var Arch:TArchive;
          type TArchive                        begin
        - Call it's constructor                  Arch.Init;
        - Tell the unit which file you           if not Arch.Name('TEST.ZIP')
          want to view. This function            then begin
          returns a boolean. If this               writeln('TEST.ZIP is not
          boolean is false, then the                        a valid archive');
          file couldn't be identified              exit;
          as a valid archive.                    end;
        - Just like the dos-functions            Arch.FindFirst(sr);
          FindFirst and FindNext, you            while sr.Name<>'' do
          can search through the archive.        begin
          The parameter you give with it           writeln(sr.Name);
          is one of the SearchRec-type.            Arch.FindNext(sr);
          If there are no more files in          end;
          this archive, sr.Name will be
          empty. Valid fields are
          sr.Name, sr.Size and sr.Time
        - Call the destructor                    Arch.Done;
                                               end;

        - You can call the function
          IdentifyArchive() to see what
          kind of archive you're dealing
          with.

        What if you want to add more archive-types
        ──────────────────────────────────────────
        - Add the unit name in the second Uses-statement.
        - Find out how to identify it and add that algoritm
          to the IdentifyArchive()-function. Please choose a
          unique and no-nonsens character to return.
        - Add it to the IdentifyArchive()-case in TArchive.Name.
        - Create a FindFirst-method and FindNext-method for this
          object.
        - That's it! Simple, isn't it? (If it isn't, please see the
          files ZipView, ArjView and others for examples ;-)

        Author:
        ───────
        Edwin Groothuis          email:
        Johann Strausslaan 1     edwing@stack.urc.tue.nl (valid until 10-94)
        5583ZA Aalst-Waalre      Edwin_Groothuis@p1.f205.n284.z2.gds.nl
        The Netherlands          2:284/205.1@fidonet
                                 115:3145/102.1@pascal-net


}

unit      OOAV;

interface

uses      Dos;

{
  General Archive, which is the father of all the specific archives. See
  OOAVZip, OOAVArj and others for examples.
}
type      PGeneralArchive=^TGeneralArchive;
          TGeneralArchive=object
                            _FArchive:file;

                            constructor Init;
                            destructor Done;virtual;

                            procedure FindFirst(var sr:SearchRec);virtual;
                            procedure FindNext(var sr:SearchRec);virtual;
                          end;

{
  TArchive is the object you're working with. See the documentation at the
  begin of this file for more information
}
type      PArchive=^TArchive;
          TArchive=object
                     constructor Init;
                     destructor Done;

                     function  Name(const n:string):boolean;

                     procedure FindFirst(var sr:SearchRec);
                     procedure FindNext(var sr:SearchRec);

                   private
                     _Name:string;
                     _Archive:PGeneralArchive;
                   end;


function  IdentifyArchive(const Name:string):char;

implementation

uses      Objects,Strings,
          OOAVZip,OOAVArj,OOAVLzh,OOAVArc,OOAVZoo;


function  IdentifyArchive(const Name:string):char;
{
  returns:
    '?': unknown archive
    'A': Arj-archive;
    'Z': Zip-archive
    'L': Lzh-archive
    'C': Arc-archive
    'O': Zoo-archive
}
var       f:file;
          a:array[0..10] of char;
          bc:word;
          s:string;
          OldFileMode:byte;
begin
  if Name='' then
  begin
    IdentifyArchive:='?';
    exit;
  end;

  OldFileMode:=FileMode;
  FileMode:=0;
  assign(f,Name);
  {$I-}reset(f,1);{$I+}
  FileMode:=OldFileMode;
  if IOresult<>0 then
  begin
    IdentifyArchive:='?';
    exit;
  end;

  blockread(f,a,sizeof(a),bc);
  close(f);
  if bc=0 then
  begin
    IdentifyArchive:='?';
    exit;
  end;

  if (a[0]=#$60) and (a[1]=#$EA) then
  begin
    IdentifyArchive:='A';  { ARJ }
    exit;
  end;

  if (a[0]='P') and (a[1]='K') then
  begin
    IdentifyArchive:='Z';  { ZIP }
    exit;
  end;

  if a[0]=#$1A then
  begin
    IdentifyArchive:='C';  { ARC }
    exit;
  end;

  if (a[0]='Z') and (a[1]='O') and (a[2]='O') then
  begin
    IdentifyArchive:='O';  { ZOO }
    exit;
  end;

  s:=Name;
  for bc:=1 to length(s) do
    s[bc]:=upcase(s[bc]);
  if copy(s,pos('.',s),4)='.LZH' then
  begin
    IdentifyArchive:='L';  { LZH }
    exit;
  end;

  IdentifyArchive:='?';
end;


constructor TGeneralArchive.Init;
begin
  Abstract;
end;


destructor TGeneralArchive.Done;
begin
end;


procedure TGeneralArchive.FindFirst(var sr:SearchRec);
begin
  Abstract;
end;


procedure TGeneralArchive.FindNext(var sr:SearchRec);
begin
  Abstract;
end;


constructor TArchive.Init;
begin
  _Name:='';
  _Archive:=nil;
end;


destructor TArchive.Done;
begin
  if _Archive<>nil then
  begin
    close(_Archive^._FArchive);
    Dispose(_Archive,Done);
  end;
end;


function  TArchive.Name(const n:string):boolean;
var       sr:SearchRec;
          OldFileMode:byte;
begin
  if _Archive<>nil then
  begin
    close(_Archive^._FArchive);
    Dispose(_Archive,Done);
    _Archive:=nil;
  end;

  Name:=false;
  _Name:=n;
  Dos.FindFirst(_Name,anyfile,sr);
  if DosError<>0 then
    exit;

  case IdentifyArchive(_Name) of
    '?': exit;
    'A': _Archive:=New(PArjArchive,Init);
    'Z': _Archive:=New(PZipArchive,Init);
    'L': _Archive:=New(PLzhArchive,Init);
    'C': _Archive:=New(PArcArchive,Init);
    'O': _Archive:=New(PZooArchive,Init);
  end;

  OldFileMode:=FileMode;
  FileMode:=0;
  Assign(_Archive^._FArchive,n);
  {$I-}reset(_Archive^._FArchive,1);{$I+}
  FileMode:=OldFileMode;
  if IOresult<>0 then
  begin
    Dispose(_Archive);
    exit;
  end;

  Name:=true;
end;


procedure TArchive.FindFirst(var sr:SearchRec);
begin
  FillChar(sr,sizeof(sr),0);
  if _Archive=nil then
    exit;
  _Archive^.FindFirst(sr);
end;

procedure TArchive.FindNext(var sr:SearchRec);
begin
  FillChar(sr,sizeof(sr),0);
  if _Archive=nil then
    exit;
  _Archive^.FindNext(sr);
end;

end.
{ CUT ----------------------------------------------------------- }
{
        Object-Oriented Archive-viewer: ARC-part
}

unit OOAVArc;

interface

uses      Dos,OOAV;

Type      AFHeader = Record
                 HeadId  : byte;
                 DataType : byte;   { 0 = no more data }
                 Name     : array[0..12] of char;
                 CompSize : longint;
                 FileDate : word;
                 FileTime : word;
                 Crc      : word;
                 OrigSize : longint;
               end;


type      PArcArchive=^TArcArchive;
          TArcArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        _FHdr:AFHeader;
                        _SL:longint;
                        procedure GetHeader(var sr:SearchRec);
                      end;

implementation

const     BSize=4096;
var       BUFF:array[1..BSize] of Byte;



constructor TArcArchive.Init;
begin
  FillChar(_FHdr,sizeof(_FHdr),0);
end;


procedure TArcArchive.GetHeader(var sr:SearchRec);
var       bc:word;
          b:byte;
begin
  FillChar(_FHdr,SizeOf(_FHdr),#0);
  FillChar(BUFF,BSize,#0);
  Seek(_FArchive,_SL);
  BlockRead(_FArchive,BUFF,BSIZE,bc);
  Move(BUFF[1],_FHdr,SizeOf(_FHdr));
  with _FHdr do
  begin
    if DataType<>0 then
    begin
      b:=0;sr.Name:='';
      while Name[b]<>#0 do
      begin
        if Name[b]='/' then
          sr.Name:=''
        else
          sr.Name:=sr.Name+Name[b];
        inc(b);
      end;
      sr.Size:=OrigSize;
      if DataType=0 then sr.Size:=0;
      sr.Time:=FileDate*longint(256*256)+FileTime;
      inc(_SL,CompSize);
      inc(_SL,sizeof(_FHDR));
    end;
  end;
end;


Procedure TArcArchive.FindFirst(var sr:SearchRec);
begin
 _SL:=0;
 GetHeader(sr);
end;


procedure TArcArchive.FindNext(var sr:SearchRec);
begin
 GetHeader(sr);
end;


end.
{ CUT ----------------------------------------------------------- }
{
        Object-Oriented Archive-viewer: ARJ-part
}

unit OOAVArj;

interface

uses      Dos,OOAV;

Type      AFHeader = Record
                       HeadId  : Word;                         { 60000 }
                       BHdrSz  : Word;             { Basic Header Size }
                       FHdrSz  : Byte;              { File Header Size }
                       AVNo    : Byte;
                       MAVX    : Byte;
                       HostOS  : Byte;
                       Flags   : Byte;
                       SVer    : Byte;
                       FType   : Byte;    { must be 2 for basic header }
                       Res1    : Byte;
                       DOS_DT  : LongInt;
                       CSize   : LongInt;            { Compressed Size }
                       OSize   : LongInt;            { Original Size }
                       SEFP    : LongInt;
                       FSFPos  : Word;
                       SEDLgn  : Word;
                       Res2    : Word;
                       NameDat : array[1..120] of char;{ start of Name, etc. }
                       Res3    : array[1..10] of char;
                     end;


type      PArjArchive=^TArjArchive;
          TArjArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        _FHdr:AFHeader;
                        _SL:longint;
                        procedure GetHeader(var sr:SearchRec);
                      end;

implementation

const     BSize=4096;
var       BUFF:array[1..BSize] of Byte;



constructor TArjArchive.Init;
begin
  FillChar(_FHdr,sizeof(_FHdr),0);
end;


procedure TArjArchive.GetHeader(var sr:SearchRec);
var       bc:word;
          b:byte;
begin
  FillChar(_FHdr,SizeOf(_FHdr),#0);
  FillChar(BUFF,BSize,#0);
  Seek(_FArchive,_SL);
  BlockRead(_FArchive,BUFF,BSIZE,bc);
  Move(BUFF[1],_FHdr,SizeOf(_FHdr));
  with _FHdr do
  begin
    if BHdrSz>0 then
    begin
      b:=1;sr.Name:='';
      while NameDat[b]<>#0 do
      begin
        if NameDat[b]='/' then
          sr.Name:=''
        else
          sr.Name:=sr.Name+NameDat[b];
        inc(b);
      end;
      sr.Size:=BHdrSz+CSize;
      if FType=2 then sr.Size:=BHdrSz;
      if BHdrSz=0 then sr.Size:=0;
      inc(_SL,sr.Size+10);
      sr.Time:=DOS_DT;
    end;
  end;
end;


Procedure TArjArchive.FindFirst(var sr:SearchRec);
begin
  _SL:=0;
  GetHeader(sr);
  GetHeader(sr);
{ Why a call to GetHeader() twice?
  Because ARJ stores the name of the archive in the first field }
end;


procedure TArjArchive.FindNext(var sr:SearchRec);
begin
  GetHeader(sr);
end;


end.
{ CUT ----------------------------------------------------------- }
{
        Object-Oriented Archive-viewer: LZH-part
}

Unit      OOAVLzh;

Interface

Uses      Dos,OOAV;

Type      LFHeader=Record
                     Headsize,Headchk          :byte;
                     HeadID                    :packed Array[1..5] of char;
                     Packsize,Origsize,Filetime:longint;
                     Attr                      :word;
                     Filename                  :string[12];
                     f32                       :pathstr;
                     dt                        :DateTime;
                   end;


type      PLzhArchive=^TLzhArchive;
          TLzhArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        _FHdr:LFHeader;
                        _SL:longint;
                        procedure GetHeader(var sr:SearchRec);
                      end;


Implementation


constructor TLzhArchive.Init;
begin
  _SL:=0;
  FillChar(_FHdr,sizeof(_FHdr),0);
end;


procedure TLzhArchive.GetHeader(var sr:SearchRec);
var       nr:word;
begin
  fillchar(sr,sizeof(sr),0);
  seek(_FArchive,_SL);
  if eof(_FArchive) then
    exit;
  blockread(_FArchive,_FHdr,sizeof(LFHeader),nr);
  if _FHdr.headsize=0 then
    exit;
  inc(_SL,_FHdr.headsize);
  inc(_SL,2);
  inc(_SL,_FHdr.packsize);
  if _FHdr.headsize<>0 then
    UnPackTime(_FHdr.FileTime,_FHdr.DT);
  sr.Name:=_FHdr.FileName;
  sr.Size:=_FHdr.OrigSize;
  sr.Time:=_FHdr.FileTime;
end;


procedure TLzhArchive.FindFirst(var sr:SearchRec);
begin
  _SL:=0;
  GetHeader(sr);
end;


procedure TLzhArchive.FindNext(var sr:SearchRec);
begin
  GetHeader(sr);
end;


end.

{ CUT ----------------------------------------------------------- }
{
        Object-Oriented Archive-viewer: ZIP-part
}

Unit      OOAVZip;

Interface

Uses      Dos,OOAV;


Type      ZFHeader=Record
                     Signature                         :longint;
                     Version,GPBFlag,Compress,Date,Time:word;
                     CRC32,CSize,USize                 :longint;
                     FNameLen,ExtraField               :word;
                   end;


type      PZipArchive=^TZipArchive;
          TZipArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        Hdr:ZFHeader;
                        procedure GetHeader(var sr:SearchRec);
                      end;

implementation


Const     SIG = $04034B50;                  { Signature }


constructor TZipArchive.Init;
begin
  FillChar(Hdr,sizeof(Hdr),0);
end;


procedure TZipArchive.GetHeader(var sr:SearchRec);
var       b:byte;
          bc:word;
begin
  fillchar(sr,sizeof(sr),0);
  if eof(_FArchive) then
    exit;
  BlockRead(_FArchive,Hdr,SizeOf(Hdr),bc);
  if bc<>Sizeof(Hdr) then
    exit;
{ Why checking for Hdr.FNamelen=0?
  Because the comments inserted in a ZIP-file are at the last field }
  if Hdr.FNameLen=0 then
    exit;
  sr.Name:='';
  Repeat
    BlockRead(_FArchive,b,1);
    If b<>0 Then
      sr.Name:=sr.Name+Chr(b);
  Until (length(sr.Name)=Hdr.FNameLen) or (b=0);
  if b=0 then
    exit;
  Seek(_FArchive,FilePos(_FArchive)+Hdr.CSize+Hdr.ExtraField);
  sr.Size:=Hdr.USize;
  sr.Time:=Hdr.Date+Hdr.Time*longint(256*256);
end;


Procedure TZipArchive.FindFirst(var sr:SearchRec);
begin
  GetHeader(sr);
end;


Procedure TZipArchive.FindNext(var sr:SearchRec);
begin
  GetHeader(sr);
end;


end.

{ CUT ----------------------------------------------------------- }
{
        Object-Oriented Archive-viewer: ZOO-part
}

unit OOAVZoo;

interface

uses      Dos,OOAV;

const     SIZ_TEXT=20;
const     FNAMESIZE=13;
const     MAX_PACK=1;
const     LO_TAG=$a7dc;
const     HI_TAG=$fdc4;


type      ZFHeader=record
                     lo_tag:word;
                     hi_tag:word;
                     _type:byte;
                     packing_method:byte;
                     next:longint;      { pos'n of next directory entry }
                     offset:longint;
                     date:word;         { DOS format date }
                     time:word;         { DOS format time }
                     file_crc:word;     { CRC of this file }
                     org_size:longint;
                     size_now:longint;
                     major_ver:byte;
                     minor_ver:byte;
                     deleted:boolean;
                     comment:longint;   { points to comment;  zero if none }
                     cmt_size:word;     { length of comment, 0 if none }
                     unknown:byte;
                     fname:array[0..FNAMESIZE-1] of char;
                   end;

type      PZooArchive=^TZooArchive;
          TZooArchive=object(TGeneralArchive)
                        constructor Init;
                        procedure FindFirst(var sr:SearchRec);virtual;
                        procedure FindNext(var sr:SearchRec);virtual;
                      private
                        _FHdr:ZFHeader;
                        procedure GetHeader;
                        procedure GetEntry(var sr:SearchRec);
                      end;

implementation



type      zooHeader=record
                      text:array[0..SIZ_TEXT-1] of char;
                      lo_tag:word;
                      hi_tag:word;
                      start:longint;
                      minus:longint;
                      major_ver:char;
                      minor_ver:char;
                    end;


constructor TZooArchive.Init;
begin
  FillChar(_FHdr,sizeof(_FHdr),0);
end;


procedure TZooArchive.GetHeader;
var       hdr:zooHeader;
          bc:word;
begin
  seek(_FArchive,0);
  BlockRead(_FArchive,hdr,sizeof(hdr),bc);
  seek(_FArchive,hdr.start);
end;


procedure TZooArchive.GetEntry(var sr:SearchRec);
var       bc:word;
          b:byte;
begin
  FillChar(_FHdr,SizeOf(_FHdr),#0);
  BlockRead(_FArchive,_FHdr,sizeof(_FHdr),bc);
  with _FHdr do
  begin
    if _Type<>0 then
    begin
      b:=0;sr.Name:='';
      while FName[b]<>#0 do
      begin
        if FName[b]='/' then
          sr.Name:=''
        else
          sr.Name:=sr.Name+FName[b];
        inc(b);
      end;
      sr.Size:=Org_Size;
      if _Type=0 then sr.Size:=0;
      sr.Time:=Date*longint(256*256)+Time;
      Seek(_FArchive,_FHdr.next);
    end;
  end;
end;


procedure TZooArchive.FindFirst(var sr:SearchRec);
begin
 GetHeader;
 GetEntry(sr);
end;


procedure TZooArchive.FindNext(var sr:SearchRec);
begin
 GetEntry(sr);
end;


end.
