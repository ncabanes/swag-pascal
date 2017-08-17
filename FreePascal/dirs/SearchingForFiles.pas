(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0050.PAS
  Description: Searching for files .
  Author: ALEXIS DOMJAN
  Date: 11-22-95  13:30
*)

{
 PO>    How is one supposed to search for files? For example there is a DOS
 PO> function for finding the next file and some others, but I tried those and
 PO> they need a DTA (disk x-fer area). I've tried to generate my own DTA but
 PO> it never works.

Here's a program I wrote sometimes ago to search files through a hard disk.
You can also redirect output to a file!
}

{ Note, 2017: not working propoerly with long names in Windows }

USES Dos, Crt;

TYPE
DIRT   = STRING[127];

CONST
Atr    = $10; { Scan only Directories (system, read only and hidden) }


VAR
ActualDir               : DIRT;
drv                     : STRING[2];
FileDir                 : DIRT;
File_To_Search_For      : STRING[12];
TotalSize               : LONGINT;
NbFiles                 : LONGINT;
F                       : Text;
outp, quit              : boolean;
ch                      : char;

PROCEDURE ScanFor(direc : DIRT);
VAR
FileS   : SEARCHREC;
pth     : PATHSTR;
Diro    : DIRSTR;
Nme     : NAMESTR;
Ext     : EXTSTR;


BEGIN
  FindFirst(direc+'\'+File_To_Search_For, AnyFile, FileS);

  While DosError=0 Do Begin
    IF (FileS.Name <> '.') AND (FileS.Name <> '..') Then Begin
      {pth:=FileS.Name;
      fSplit(pth, Diro, Nme, Ext);}
      Write(direc+'\'+FileS.Name);
      if outp then WriteLn(f, direc+'\'+FileS.Name);
      GotoXY(60, WhereY);
      WriteLn(FileS.Size);
      INC(TotalSize, FileS.Size);
      INC(NbFiles);
    End;
    FindNext(FileS);
  End;
END;

PROCEDURE ScanDir(ddr : DIRT);
VAR
S               : SEARCHREC;

BEGIN
 { WriteLn(ddr); }

  ChDir(ddr);

  ScanFor(ddr);

  FindFirst('*.*', AnyFile, S);

  While (DOSERROR=0) Do Begin

    IF S.Attr=$10 Then Begin
       IF (S.Name <> '.') AND (S.Name <> '..') Then Begin
         IF Length(ddr)>3 then ScanDir(ddr+'\'+S.Name) ELSE
ScanDir(ddr+S.Name);         ChDir(ddr);
       End;
    End;

    if keypressed then begin
      ch:=readkey;
      if ch=#27 then quit:=true;
    end;

    if quit then exit;

    FindNext(S);
  End;
END;


PROCEDURE DoIt;
BEGIN
  quit:=false;
  TotalSize:=0;
  NbFiles:=0;
  File_To_Search_For:=ParamStr(1);
  if paramcount=2 then outp:=true else outp:=false;
  WriteLn('File output : ', outp);
  If outp then begin
    assign(f, paramstr(2));
    rewrite(f);
  end;

  WriteLn('Searching : ');
  WriteLn;
  FileDir:='';

  GetDir(0, ActualDir);

  drv:=''; {Copy(ActualDir, 1, 2);  }

  ScanDir(actualdir);

  If quit then begin
      writeln;
      writeln('Research aborted by user with ESC...');
  end;
  ChDir(ActualDir);

  WriteLn(NbFiles, ' files listed in ', TotalSize, ' Bytes.');
  WriteLn(DiskFree(0), ' free bytes.');
  if outp then close(f);
END;



BEGIN
  WriteLn;
  WriteLn('■ Search For v1.0    By Discovery/EfS! (c)1994');
  WriteLn;
  IF ParamCount=0 Then Begin
    WriteLn('- Syntax : SF [FileName] [OutPut]');
    WriteLn;
    WriteLn('. Where [FileName] will be searched on all directories of');
    WriteLn('  current drive from current directory. ');
    WriteLn('  [FileName] Accept WildCards (*, ?)');
    WriteLn;
    WriteLn('  If [Output] is specified, display is copied to file[output],');
    WriteLn('  wihtout size... Very useful to create modules lists:)');
    WriteLn;
  End ELSE DoIt;
END.
