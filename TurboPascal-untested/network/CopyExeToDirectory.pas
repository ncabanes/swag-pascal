(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0034.PAS
  Description: Copy EXE TO Directory
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:53
*)


{$M 16384,0,655360}

{ Copies EXEs into the LAN release directory:

     RELEASE <ExeFile> <ReleasePath>       }

program Release;

uses
  DOS,Objects;

var
  Error             : Integer;      { Error code for num2str conversions }
  ExeName           : String;       { Name of destination EXE file }
  FindRec           : SearchRec;    { File record from FindFirst }
  FPath             : DirStr;       { Filespec's path }
  FName             : NameStr;      { Filespec's name }
  FExt              : ExtStr;       { Filespec's extension }
  GreatestVersion   : Integer;      { Highest version number found }
  ProgramName       : NameStr;      { Root name (no extension) of program }
  ReleaseDir        : String;       { Location of public EXEs }
  Version           : Integer;      { Version number of an EXE }

procedure CopyFile( SourceFilename, TargetFilename : String );

const
  BufSize           = $1000;

var
  SourceFile,
  TargetFile        : TBufStream;

begin
  WriteLn('Copying ',SourceFilename,' to ',TargetFilename,'...');
  SourceFile.Init(SourceFilename,stOpenRead,BufSize);
  if SourceFile.Status <> stOk then
    WriteLn('Error ',SourceFile.ErrorInfo,' opening ',SourceFilename)
  else
  begin
    TargetFile.Init(TargetFilename,stCreate,BufSize);
    if TargetFile.Status <> stOk then
      Writeln('Error ',TargetFile.ErrorInfo,' opening ',TargetFilename)
    else
    begin
      TargetFile.CopyFrom(SourceFile,SourceFile.GetSize);
      if TargetFile.Status <> stOk then
        WriteLn('Error ',TargetFile.ErrorInfo,' copying file.')
      else
        WriteLn('Copy complete');
    end;
    TargetFile.Done;
  end;
  SourceFile.Done;
end;

begin
  FSplit(ParamStr(1),FPath,ProgramName,FExt);
  ReleaseDir := ParamStr(2);
  if not (ReleaseDir[Length(ReleaseDir)] in [':','\']) then
    ReleaseDir := ReleaseDir + '\';

  { Create program subdirectory if necessary }
  FindFirst(ReleaseDir + ProgramName,Directory,FindRec);
  if DosError <> 0 then
    MkDir(ReleaseDir + ProgramName);

  { Find greatest current version for this file }
  GreatestVersion := 0;
  FindFirst(ReleaseDir + ProgramName + '\*.EXE',AnyFile,FindRec);
  while DOSError = 0 do
  begin
    FSplit(FindRec.Name,FPath,FName,FExt);
    Val(FName,Version,Error);
    if Version > GreatestVersion then
      GreatestVersion := Version;
    FindNext(FindRec);
  end;

  { Construct filename }
  Str(GreatestVersion + 1,ExeName);
  ExeName := ExeName + '.EXE';

  { Copy the program to the version directory }
  CopyFile(ParamStr(1),ReleaseDir + ProgramName + '\' + ExeName);
end.

