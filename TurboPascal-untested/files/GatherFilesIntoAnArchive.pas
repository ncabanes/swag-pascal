(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0105.PAS
  Description: Gather files into an archive
  Author: BRUNO OLSEN
  Date: 08-30-97  10:08
*)


{
Hello Gayle!

As I was working on an installation program and needed build-in
compression/decompression I found out the sources available in SWAG only
handled one file at a time thus couldn't create archives. So I created a
little utility to gather several file into one with the ability to
seperate them again.

It can be used for several other things. Just a few weeks ago I presented
this as a solution to a guy who wanted to create one resource file from
several datafiles. So I think this might be usefull enough for SWAG :))

..SWG to include it in: FILES.SWG
Subject proposal: Gather several file into one

The .pas files:
--------------------------------------------------------- }
PROGRAM Gather;  { program to extract files at the end !! }

{Gather v. 1.2

Archive several file in one, still being able to restore the original
files.

Copyright 1996-97 Centennial Innovations by Bruno Olsen,
All rights reserved.

LICENCE:

1. You can distribute this program as long as no fee is charged. 2. You
can use this source free of charge as long as you agree to 3-5. 3. If
using this source, you must notify the auther. This will incurrage
   the auther to update the source, and the auther will know if his
effords
   was worth while.
4. If modifying this source, you must notify the original auther about the
   modifications, and send the full modified source. NOTE: Send ONLY the
source
   for THIS program, NOT the source of the program in which this source is
used. 5. This source may be used in either freeware, shareware or
commercial 
   applications, as long as the author is familiar with the use, see 3-4.

Author can be contacted through these sources:

Bulletin Board: Mountain Online Services
                +45 58841025, +45 58841024

FidoNet: 2:236/42, 2:236/49

Internet: bo@vestnet.dk

Homepage: http://home.vest.net/bo

Snail mail: Centennial Innovations
            Bruno Olsen
            Fugleveanget 30
            DK-4270 Hoeng
            Denmark

History:
Version 1.0    First usable version. Only files with the Archive attribute
               set is archived.
Version 1.2    Extended header to hold attribute information. Directories
are
               now stored and the files within are too. Limitation of
Archive
               files eliminated. Changes in header: Attrib added, DirNum
               added and Numbers changed from Byte to Integer. Rewritten
               most of the code to recursive rutines.}

USES DOS, CRT;

TYPE HeaderType=RECORD
                 Str:String[12];
                                {Record 0: Identifying string='GTH_2'
                                 Record 1 and above: File/directory name}
                 Attrib:Array [1..5] of Boolean;
                                {Attrib: 1   true if   System
                                         2   true if   Hidden
                                         3   true if   Archive
                                         4   true if   ReadOnly
                                         5   true if   Directory}
                 Numbers:Integer;
                                {Numbers:
                                 Record 0: Amount of files stored.
                                 Record 1 and above: The number of the
                                                     directory.
                                                     The root gather
                                                     directory is 0.
                                 NOT used for files.}
                 DirNum:Integer;
                                {DirNum:
                                 Record 0: Amount of directories stored.
                                 Record 1 and above: The number of the
                                                     directory the files/
                                                     directories reside
in.
                                                     The root gather
                                                     directory is 0.}
                 Offsets:LongInt;
                                {Offsets:
                                 Record 0: Where the header ends.
                                 Record 1 and above: Where the current
file
                                                     processed ends.
Previous
                                                     + 1 marks file
start.}
                END;

CONST RecordSize=26;  {The size of header type. Edit this when modifying
header}
      HeaderName='GTH_2';
      VersionNumber='1.2';
      CYear='1996-97';

VAR InFiles,
    OutFile:File;
    MainFile:File of HeaderType;
    Main:HeaderType;
    MaxFiles:Byte;
    Last:Byte;
    NumRead, NumWritten: Word;
    Buf: array[1..4000] of Char;
    FSize:LongInt;
    Error:Word;
    TempSize,
    SizeCount:LongInt;
    FileCount,
    DirCount:Integer;
    DirInfo:SearchRec;
    CurrentDir,
    LastDir,
    DirNum,
    InDirNum:Integer;
    StartDir,
    GatherDir,
    GatherFiles,
    GatherTo,
    ConvStr,
    EnvTemp:String;
    ProcDir:Boolean;

PROCEDURE Get_File_Size(FName : string;
                    var FSize : longint;
                    var Error : word);
var
  SR    : SearchRec;

BEGIN 
  {$I-}
  FindFirst(FName,Archive,SR);
  Error := DosError;
  {$I+}
  if Error = 0 then
    FSize := SR.Size
  else
    FSize := 0;
END;

PROCEDURE CountFiles(VAR DirCount, FileCount:Integer;VAR
SizeCount:LongInt);

VAR LastDir:String;

 BEGIN
  FindFirst(GatherFiles, AnyFile-VolumeID, DirInfo);
  while DosError = 0 do
   begin
    IF (DirInfo.Attr=Directory) AND NOT((DirInfo.Name='.') OR
(DirInfo.Name='..')) THEN
     BEGIN
      DirCount:=DirCount+1;
      ChDir(DirInfo.Name);
      LastDir:=DirInfo.Name;
      CountFiles(DirCount,FileCount,SizeCount);
      ChDir('..');
      FindFirst('*.*', AnyFile-VolumeID, DirInfo); { Same as DIR *.PAS }
      while (DosError = 0) AND NOT(DirInfo.Name=LastDir) do
       begin
        FindNext(DirInfo);
       end;
     END
     ELSE
      IF DirInfo.Attr IN[Archive,ReadOnly,Hidden,SysFile] THEN
       BEGIN
        FileCount:=FileCount+1;
        SizeCount:=SizeCount+DirInfo.Size;
       END;
    FindNext(DirInfo);
   end;
 END;

PROCEDURE ResetAttrib;

 VAR Counter:Integer;

BEGIN
 FOR Counter:=1 to 5 DO
  Main.Attrib[Counter]:=False;
END;

PROCEDURE SetAttrib;

 VAR Check:Byte;

BEGIN
 ResetAttrib;
 Check:=DirInfo.Attr;
 IF (Check-32) IN[0,1,2,4,8,16] THEN
  BEGIN
   Check:=Check-32;
   Main.Attrib[3]:=TRUE;
  END;
 IF (Check-16) IN[0,1,2,4,8] THEN
  BEGIN
   Check:=Check-16;
   Main.Attrib[5]:=TRUE;
  END;
 IF (Check-8) IN[0,1,2,4] THEN
  BEGIN
   Check:=Check-8;    {VolumeID is not used}
  END;
 IF (Check-4) IN[0,1,2] THEN
  BEGIN
   Check:=Check-4;
   Main.Attrib[1]:=TRUE;
  END;
 IF (Check-2) IN[0,1] THEN
  BEGIN
   Check:=Check-2;
   Main.Attrib[2]:=TRUE;
  END;
 IF Check-1=0 THEN
  BEGIN
   Main.Attrib[4]:=TRUE;
  END;
END;

PROCEDURE AddFile;
BEGIN
 Assign(InFiles,DirInfo.Name);
 Reset(InFiles,1);
 repeat
  BlockRead(InFiles, Buf, SizeOf(Buf), NumRead);
  BlockWrite(OutFile, Buf, NumRead, NumWritten);
 until (NumRead = 0) or (NumWritten <> NumRead);
 Close(InFiles);
END;

PROCEDURE MakeHeader(LastDir:Integer;VAR CurrentDir:Integer);

VAR LastDirName:String;

 BEGIN
  FindFirst(GatherFiles, AnyFile-VolumeID, DirInfo);
  while DosError = 0 do
   begin
    IF (DirInfo.Attr=Directory) AND NOT((DirInfo.Name='.') OR
(DirInfo.Name='..')) THEN
     BEGIN
      CurrentDir:=CurrentDir+1;
      DirNum:=CurrentDir;
      InDirNum:=LastDir;
      ChDir(DirInfo.Name);
      LastDirName:=DirInfo.Name;
      Main.Str:=DirInfo.Name;
      WriteLn('Storing directory: '+DirInfo.Name);
      SetAttrib;
      Main.Numbers:=DirNum;
      Main.DirNum:=InDirNum;
      Main.Offsets:=0;
      Write(MainFile,Main);
      MakeHeader(CurrentDir,CurrentDir);
      ChDir('..');
      FindFirst('*.*', AnyFile-VolumeID, DirInfo);
      while (DosError = 0) AND NOT(DirInfo.Name=LastDirName) do
       begin
        FindNext(DirInfo);
       end;
     END
     ELSE IF (DirInfo.Attr<>Directory) AND (DirInfo.Attr<>VolumeID) THEN
      BEGIN
       Main.Str:=DirInfo.Name;
       WriteLn('Storing file: '+DirInfo.Name);
       SetAttrib;
       Main.Numbers:=DirNum;
       Main.DirNum:=InDirNum;
       Main.Offsets:=TempSize+DirInfo.Size;
       TempSize:=Main.Offsets;
       AddFile;
       Write(MainFile,Main);
      END;
    FindNext(DirInfo);
   end;
 END;

PROCEDURE GetParams;

VAR Counter:Integer;

 BEGIN
  ProcDir:=FALSE;
  IF ParamCount=0 THEN
   BEGIN
    WriteLn('Usage:');
    WriteLn('GATHER [ -d | -D ] [DirectoryName] InFiles OutFile');
    WriteLn;
    WriteLn('-d or -D     : Gather files and directory structure');
    WriteLn('DirectoryName: Starting directory');
    WriteLn('InFiles      : Files to gather');
    WriteLn('OutFile      : File to gather the files into');
    WriteLn;
    WriteLn('Examples:');
    WriteLn('GATHER *.PAS PASFILES.GTH    Gather all .PAS-files into the file PASFILES.GTH');
    WriteLn('GATHER -D c:\dos *.* DOSDIR.GTH  GATHER all files in c:\dos and all directories');
    WriteLn('                                 and all files in them into the file DOSDIR.GTH');
    Halt(1);
   END
   ELSE
    BEGIN
     Counter:=1;
     IF (ParamStr(Counter)='-d') OR (ParamStr(Counter)='-D') THEN
      BEGIN
       ProcDir:=TRUE;
       Counter:=Counter+1;
      END;
     IF (ParamCount-Counter)=2 THEN
      BEGIN
       GatherDir:=ParamStr(Counter);
       Counter:=Counter+1;
      END
      ELSE
       GatherDir:=StartDir;
     GatherFiles:=ParamStr(Counter);
     GatherTo:=ParamStr(Counter+1);
    END;
 END;

BEGIN
 CLRSCR;
 WriteLn('Gather version '+VersionNumber+' (C) '+CYear+' Centennial Innovations by Bruno Olsen');
 WriteLn;
 GetDir(0,StartDir); { 0 = Current drive }
 EnvTemp:=GetEnv('TEMP');
 EnvTemp:=EnvTemp+'\';
 DirCount:=0;FileCount:=0;SizeCount:=0;
 GetParams;
 ChDir(GatherDir);
 Write('Analizing... ');
 CountFiles(DirCount,FileCount,SizeCount);
 Str(DirCount,ConvStr);
 Write('Directories: '+ConvStr);
 Str(FileCount,ConvStr);
 Write(' Files: '+ConvStr);
 Str(SizeCount,ConvStr);
 WriteLn(' Bytes: '+ConvStr);
 WriteLn;
 WriteLn('Processing...');
 ChDir(StartDir);
 MaxFiles:=DirCount+FileCount;
 ResetAttrib;
 Main.Str:=HeaderName;
 Main.Numbers:=FileCount;
 Main.DirNum:=DirCount;
 Main.Offsets:=RecordSize*(MaxFiles+1);
 TempSize:=Main.Offsets;
 Assign(MainFile,EnvTemp+'head.tmp');
 Assign(OutFile,EnvTemp+'main.tmp');
 ReWrite(MainFile);
 ReWrite(OutFile);
 Close(OutFile);
 Reset(OutFile,1);
 Write(MainFile,Main);
 CurrentDir:=0;LastDir:=0;
 ChDir(GatherDir);
 MakeHeader(LastDir,CurrentDir);
 ChDir(StartDir);
 Close(MainFile);
 Close(OutFile);
 WriteLn;
 WriteLn('Cleaning up...');
 Assign(InFiles,EnvTemp+'head.tmp');
 Assign(OutFile,GatherTo);
 ReWrite(OutFile);
 Close(OutFile);
 Reset(InFiles,1);
 Reset(OutFile,1);
 repeat
   BlockRead(InFiles, Buf, SizeOf(Buf), NumRead);
   BlockWrite(OutFile, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
 Close(InFiles);
 Close(OutFile);
 Assign(InFiles,EnvTemp+'main.tmp');
 Assign(OutFile,GatherTo);
 Reset(InFiles,1);
 Reset(OutFile,1);
 Seek(OutFile,FileSize(OutFile));
 repeat
   BlockRead(InFiles, Buf, SizeOf(Buf), NumRead);
   BlockWrite(OutFile, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
 Close(InFiles);
 Close(OutFile);
 Erase(InFiles);
 Assign(Infiles,EnvTemp+'head.tmp');
 Erase(Infiles);
 ChDir(StartDir);
 WriteLn('Done.');
END.
---------------------------------------------------------
PROGRAM XTract;

{Xtract v. 1.2

Restore files Gathered with Gather v. 1.2.

Copyright 1996-97 Centennial Innovations by Bruno Olsen,
All rights reserved.

LICENCE:

1. You can distribute this program as long as no fee is charged. 2. You
can use this source free of charge as long as you agree to 3-5. 3. If
using this source, you must notify the auther. This will incurrage
   the auther to update the source, and the auther will know if his
effords
   was worth while.
4. If modifying this source, you must notify the original auther about the
   modifications, and send the full modified source. NOTE: Send ONLY the
source
   for THIS program, NOT the source of the program in which this source is
used. 5. This source may be used in either freeware, shareware or
commercial 
   applications, as long as the author is familiar with the use, see 3-4.

Author can be contacted through these sources:

Bulletin Board: Mountain Online Services
                +45 58841025, +45 58841024

FidoNet: 2:236/42, 2:236/49

Internet: bo@vestnet.dk

Homepage: http://home.vest.net/bo

Snail mail: Centennial Innovations
            Bruno Olsen
            Fugleveanget 30
            DK-4270 Hoeng
            Denmark

History:
Version 1.0    First usable version. Only files with the Archive attribute
               set is archived.
Version 1.2    Extended header to hold attribute information. Directories
are
               now stored and the files within are too. Limitation of
Archive
               files eliminated. Changes in header: Attrib added, DirNum
               added and Numbers changed from Byte to Integer. Rewritten
               most of the code.}

USES DOS, CRT;

TYPE HeaderType=RECORD
                 Str:String[12];
                                {Record 0: Identifying string='GTH_2'
                                 Record 1 and above: File/directory name}
                 Attrib:Array [1..5] of Boolean;
                                {Attrib: 1   true if   System
                                         2   true if   Hidden
                                         3   true if   Archive
                                         4   true if   ReadOnly
                                         5   true if   Directory}
                 Numbers:Integer;
                                {Numbers:
                                 Record 0: Amount of files stored.
                                 Record 1 and above: The number of the
                                                     directory.
                                                     The root gather
                                                     directory is 0.
                                 NOT used for files.}
                 DirNum:Integer;
                                {DirNum:
                                 Record 0: Amount of directories stored.
                                 Record 1 and above: The number of the
                                                     directory the files/
                                                     directories reside
in.
                                                     The root gather
                                                     directory is 0.}
                 Offsets:LongInt;
                                {Offsets:
                                 Record 0: Where the header ends.
                                 Record 1 and above: Where the current
file
                                                     processed ends.
Previous
                                                     + 1 marks file
start.} {                 Compressed:Boolean;}
                                {Compressed:
                                 TRUE if the file was compressed,
                                 FALSE if the file was stored.}
                END;

CONST RecordSize=26;
      HeaderName='GTH_2';
      VersionNumber='1.2';
      CYear='1996-97';

VAR InFiles,
    OutFile:File;
    MainFile,
    HeadTemp:File of HeaderType;
    Main:HeaderType;
    Head:HeaderType;
    MaxFiles:Byte;
    Last:Byte;
    NumRead, NumWritten: Word;
    Buf: array[1..2048] of Char;
    FSize,
    Missing,
    EndSize:LongInt;
    Error:Word;
    TempSize,
    SizeCount:LongInt;
    FileCount,
    DirCount:Integer;
    DirInfo:SearchRec;
    CurrentDir,
    LastDir,
    DirNum,
    InDirNum:Integer;
    StartDir,
    XtractDir,
    XtractFrom,
    XtractFiles,
    ConvStr,
    EnvTemp:String;
    ProcDir:Boolean;

PROCEDURE Get_File_Size(FName : string;
                    var FSize : longint;
                    var Error : word);
var
  SR    : SearchRec;

BEGIN
  {$I-}
  FindFirst(FName,Archive,SR);
  Error := DosError;
  {$I+}
  if Error = 0 then
    FSize := SR.Size
  else
    FSize := 0;
END; 

Function DirExist(st_Dir : DirStr) : Boolean;
Var
  wo_Fattr : Word;
  fi_Temp  : File;
begin
  assign(fi_Temp, (st_Dir + '.'));
  getfattr(fi_Temp, wo_Fattr);
  if (Doserror <> 0) then
    DirExist := False
  else
    DirExist := ((wo_Fattr and directory) <> 0)
end; 

PROCEDURE CountFiles(VAR DirCount, FileCount:Integer;VAR
SizeCount:LongInt);

VAR LastDir:String;
    Counter:Integer;

 BEGIN
  Get_File_Size(XtractFrom,FSize,Error);
  Assign(MainFile,XtractFrom);
  Reset(MainFile);
  Assign(HeadTemp,EnvTemp+'head.tmp');
  ReWrite(HeadTemp);
  Read(MainFile,Main);
  MaxFiles:=Main.Numbers+Main.DirNum;
  TempSize:=RecordSize*(Maxfiles+1);
  SizeCount:=FSize-TempSize;
  DirCount:=Main.DirNum;
  FileCount:=Main.Numbers;
  Write(HeadTemp,Main);
  FOR Counter:=1 TO MaxFiles DO
   BEGIN
    Read(MainFile,Main);
    Write(HeadTemp,Main);
   END;
  Close(MainFile);
  Close(HeadTemp);
  Assign(MainFile,EnvTemp+'head.tm2');
  Reset(HeadTemp);
  ReWrite(MainFile);
  While NOT(EOF(HeadTemp)) DO
   BEGIN
    Read(HeadTemp,Main);
    Write(MainFile,Main);
   END;
 END;

PROCEDURE ResetAttrib;

 VAR Counter:Integer;

BEGIN
 FOR Counter:=1 to 5 DO
  Main.Attrib[Counter]:=False;
END;

PROCEDURE SetAttrib;

 VAR Check:Word;

BEGIN
 Check:=0;
 IF Main.Attrib[3]=TRUE THEN
   Check:=Check+Archive;
 IF Main.Attrib[1]=TRUE THEN
   Check:=Check+SysFile;
 IF Main.Attrib[2]=TRUE THEN
   Check:=Check+Hidden;
 IF Main.Attrib[4]=TRUE THEN
   Check:=Check+ReadOnly;
 SetFAttr(OutFile,Check);
END;

PROCEDURE MakeFile;
BEGIN
 Write('Xtracting file: '+Main.Str+' ');
 Assign(OutFile,Main.Str);
 ReWrite(OutFile);
 Close(OutFile);
 EndSize:=Main.Offsets-TempSize;
 IF EndSize>2048 THEN
  BEGIN
   repeat
    BlockRead(InFiles, Buf, SizeOf(Buf), NumRead);
    Reset(OutFile,1);
    Seek(OutFile,FileSize(OutFile));
    BlockWrite(OutFile, Buf, NumRead, NumWritten);
    Close(OutFile);
    Get_File_Size(Main.Str,FSize,Error);
   until (EndSize-FSize)<2048;
   Missing:=EndSize-FSize;
  END ELSE Missing:=EndSize;
 BlockRead(InFiles,Buf,Missing,NumRead);
 Reset(OutFile,1);
 Seek(OutFile,FileSize(OutFile));
 BlockWrite(OutFile,Buf,Missing,NumWritten);
 Close(OutFile);
 SetAttrib;
 WriteLn('Ok');
END;

PROCEDURE ReadHeader(LastDir:Integer;VAR CurrentDir:Integer);

VAR LastDirName:String;
    Counter:Integer;
    DoneThis:Boolean;

 BEGIN
  Assign(HeadTemp,EnvTemp+'head.tm2');
  CurrentDir:=0;
  Counter:=1;
  While NOT(EOF(MainFile)) DO
   BEGIN
    Read(MainFile,Main);
    IF Main.Attrib[5] THEN
     BEGIN
      Write('Xtracting directory: '+Main.Str+' ');
      IF Main.DirNum=CurrentDir THEN
       BEGIN
        IF NOT(DirExist(Main.Str)) THEN MkDir(Main.Str);
        ChDir(Main.Str);
        CurrentDir:=Main.Numbers;
        Counter:=Counter+1;
        WriteLn('Ok');
       END
        ELSE
         BEGIN
          Write('Searching... ');
          LastDir:=CurrentDir;
          REPEAT
           Reset(HeadTemp);
           Read(HeadTemp,Head);
           While NOT(EOF(HeadTemp)) DO
            BEGIN
             Read(HeadTemp,Head);
             IF (Head.Numbers=LastDir) AND (Head.Attrib[5]) THEN
              BEGIN
               ChDir('..');
               LastDir:=Head.DirNum;
               Counter:=Counter+1;
              END;
            END;
          UNTIL LastDir=Main.DirNum;
          IF NOT(DirExist(Main.Str)) THEN MkDir(Main.Str);
          ChDir(Main.Str);
          CurrentDir:=Main.Numbers;
          Counter:=Counter+1;
          WriteLn('Ok');
         END;
     END
     ELSE
      BEGIN
       MakeFile;
       TempSize:=Main.Offsets;
     END;
   END;
 END;

PROCEDURE GetParams;

VAR Counter:Integer;

 BEGIN
  ProcDir:=FALSE;
  IF ParamCount=0 THEN
   BEGIN
    WriteLn('Usage:');
    WriteLn('XTRACT [ -d | -D ] [DirectoryName] InFile OutFiles');
    WriteLn;
    WriteLn('-d or -D     : Gather files and directory structure');
    WriteLn('DirectoryName: Starting directory');
    WriteLn('InFile       : File to restore from');
    WriteLn('OutFiles     : Files to restore');
    WriteLn;
    WriteLn('Examples:');
    WriteLn('XTRACT PASFILES.GTH *.PAS    Gather all .PAS-files into the
file PASFILES.GTH');
    WriteLn('XTRACT -D c:\dos DOSDIR.GTH *.*  GATHER all files in c:\dos
and all directories');
    WriteLn('                                 and all files in them into
the file DOSDIR.GTH');
    Halt(1);
   END
   ELSE
    BEGIN
     Counter:=1;
     IF (ParamStr(Counter)='-d') OR (ParamStr(Counter)='-D') THEN
      BEGIN
       ProcDir:=TRUE;
       Counter:=Counter+1;
      END;
     IF (ParamCount-Counter)=2 THEN
      BEGIN
       XtractDir:=ParamStr(Counter);
       Counter:=Counter+1;
      END
      ELSE
       XtractDir:=StartDir;
     XtractFrom:=ParamStr(Counter);
     XtractFiles:=ParamStr(Counter+1);
    END;
 END;

BEGIN
 CLRSCR;
 WriteLn('Xtract version '+VersionNumber+' (C) '+CYear+' Centennial
Innovations by Bruno Olsen');
 WriteLn;
 GetDir(0,StartDir); { 0 = Current drive }
 EnvTemp:=GetEnv('TEMP');
 EnvTemp:=EnvTemp+'\';
 DirCount:=0;FileCount:=0;SizeCount:=0;
 GetParams;
 Write('Analizing... ');
 CountFiles(DirCount,FileCount,SizeCount);
 Str(DirCount,ConvStr);
 Write('Directories: '+ConvStr);
 Str(FileCount,ConvStr);
 Write(' Files: '+ConvStr);
 Str(SizeCount,ConvStr);
 WriteLn(' Bytes: '+ConvStr);
 WriteLn;
 WriteLn('Processing...');
 ResetAttrib;
 Assign(MainFile,EnvTemp+'head.tmp');
 Assign(InFiles,StartDir+'\'+XtractFrom);
 Reset(MainFile);
 Read(MainFile,Main);
 Reset(InFiles,1);
 Seek(Infiles,TempSize);
 CurrentDir:=0;LastDir:=0;
 IF NOT(DirExist(XtractDir)) THEN MkDir(XtractDir);
 ChDir(XtractDir);
 ReadHeader(LastDir,CurrentDir);
 ChDir(StartDir);
 Close(MainFile);
 Close(InFiles);
 WriteLn;
 WriteLn('Cleaning up...');
 Assign(InFiles,EnvTemp+'head.tmp');
 Erase(InFiles);
 ChDir(StartDir);
 WriteLn('Done.');
END.
---------------------------------------------------------

Hope you find it a good idea :))

---------------------------------------------------------
Regards,
         Bruno Olsen
         bo@vestnet.dk
         HTTP://home.vest.net/bo
---------------------------------------------------------

