(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0125.PAS
  Description: Copy File Routine
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

unit FileUtil;

interface

procedure CopyFile( Source, Dest : string );

implementation

uses
  WinTypes, SysUtils, Dialogs, LZExpand;


procedure CopyFile( Source, Dest : string );
var
  SourceFile  : Integer;   { The LZ* functions use File Handles }
  DestFile    : Integer;
  RetCode     : Longint;
  OpenFileBuf : TOFStruct;        { Record needed by LZOpenFile }
  FileNameStz : array[ 0..255 ] of Char;
  E           : EInOutError;   { Exception Object, just in case }
begin
  StrPCopy( FileNameStz, Source );
  SourceFile := LZOpenFile( FileNameStz, OpenFileBuf, of_Read );

  if SourceFile < 0 then
  begin
    E := EInOutError.CreateFmt( 'Could not open %s', [ Source ] );
    E.ErrorCode := SourceFile;
    raise E;                               { Raise an Exception }
  end;

  StrPCopy( FileNameStz, Dest );
  DestFile := LZOpenFile( FileNameStz, OpenFileBuf, of_Create );

  if DestFile < 0 then
  begin
    LZClose( SourceFile );       { Be sure to close Source File }
    E := EInOutError.CreateFmt( 'Could not create %s', [ Dest ] );
    E.ErrorCode := DestFile;
    raise E;                               { Raise an Exception }
  end;

  RetCode := LZCopy( SourceFile, DestFile );

  LZClose( SourceFile );             { Even if LZCopy fails, we }
  LZClose( DestFile );             { still must close the files }

  if RetCode < 0 then
  begin
    E := EInOutError.CreateFmt( 'Could not copy %s to %s',
                                [ Source, Dest ] );
    E.ErrorCode := RetCode;
    raise E;                               { Raise an Exception }
  end;
end; {= CopyFile =}

end.

