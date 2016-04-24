(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0337.PAS
  Description: Buffered access to lines of file
  Author: MARTIN WALDENBURG
  Date: 08-30-97  10:09
*)

{+--------------------------------------------------------------------------+
 | Class:       TLineStream
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: TLineStream gives a buffered access to the lines of a file.
 |              Every line must end with CRLF. Don't forget to flush the
 |              Memory after writing.
 | Version:     1.6
 | State:       FreeWare
 | Disclaimer:
 | This is provided as is, expressly without a warranty of any kind.
 | You use it at your own risc.
 +--------------------------------------------------------------------------+}

unit mwLineStream;

interface

uses
  SysUtils, Classes;

type
  TLineStream = class(TFileStream)
  private
    fLineStart: PChar;
    fMaxMemorySize:Longint;
    fMemorySize: LongInt;
    fMemory:PChar;
    fMemoryPos: LongInt;
    fEof:Boolean;
    function GetMemoryFull:Boolean;
    procedure SetMaxMemorySize(NewValue:Longint);
    function GetFileEof:Boolean;
  protected
  public
    constructor create(Const FileName: string;  Mode: Word);
    destructor destroy;override;
    procedure FillMemory;
    function ReadLine:PChar;
    procedure WriteLine(NewLine: String);
    procedure FlushMemory;
    procedure Reset;
    property MaxMemorySize:Longint read fMaxMemorySize write SetMaxMemorySize;
    property Memory:PChar read fMemory write fMemory;
    property MemoryFull:Boolean read GetMemoryFull;
    property FileEof:Boolean read GetFileEof;
    property Eof:Boolean read fEof write fEof;
  published
  end;  { TLineStream }

implementation

constructor TLineStream.create(Const FileName: string;  Mode: Word);
var
  fHandle: Integer;
begin
  if not FileExists(FileName) then
    begin
      fHandle:= FileCreate(FileName);
      FileClose(fHandle);
    end;
  inherited create(FileName, Mode);
  fEof:= False;
  MaxMemorySize:= 32383;
  fMemorySize:= 0;
  fMemoryPos:= 0;
  Position:= 0;
end;  { create }

destructor TLineStream.destroy;
begin
  ReallocMem(fMemory, 0);
  inherited destroy;
end;  { destroy }

function TLineStream.GetFileEof:Boolean;
begin
  if Position = Size then Result:= True else Result:= False;
end;   { GetFileEof }

procedure TLineStream.SetMaxMemorySize(NewValue:Longint);
begin
  fMaxMemorySize:= NewValue;
  ReallocMem(fMemory, fMaxMemorySize +1);
end; { SetMaxMemorySize }

procedure TLineStream.FillMemory;
var
  Readed: LongInt;
begin
  Readed:= Read(fMemory^, fMaxMemorySize);
  fMemorySize:= Readed;
  if fMemorySize > 2 then
  while fMemory[fMemorySize -2] <> #13 do  dec(fMemorySize);
  fMemory[fMemorySize]:= #0;
  Position:= Position -Readed + fMemorySize;
  fLineStart:= fMemory;
end;   { FillMemory }

function TLineStream.GetMemoryFull:Boolean;
begin
  if fMemorySize > 0 then Result:= True else Result:= False;
end;  { GetMemoryFull }

function TLineStream.ReadLine:PChar;
var
  Run, LineEnd: PChar;
begin
  if fMemorySize = 0 then FillMemory;
  Run:= fLineStart;
  while Run^ <> #13 do inc(Run);
  LineEnd:= Run;
  inc(Run, 2);
  LineEnd^:= #0;
  Result:= fLineStart;
  fLineStart:= Run;
  if Run^ = #0 then fMemorySize:= 0;
  if (Run^ = #0) and FileEof then Eof:= True;
end;   { ReadLine }

procedure TLineStream.WriteLine(NewLine: String);
var
  Count, Pos: Longint;
begin
  NewLine:= NewLine + #13#10;
  Count:= Length(NewLine);
  if (fMemoryPos >= 0) and (Count >= 0) then
  begin
    Pos := fMemoryPos + Count;
    if Pos > 0 then
    begin
      if Pos > FMaxMemorySize then
        begin
           FlushMemory;
        end;
      StrECopy((fMemory + fMemoryPos), PChar(NewLine));
      fMemoryPos:= fMemoryPos + Count;
      fMemory[fMemoryPos]:= #0;
    end;
  end;
end;  { WriteLine }

procedure TLineStream.FlushMemory;
begin
  Write(fMemory^, fMemoryPos);
  fMemoryPos:= 0;
end;  { FlushMemory }

procedure TLineStream.Reset;
begin
  fEof:= False;
  fMemorySize:= 0;
  fMemoryPos:= 0;
  Position:= 0;
end;  { Reset }

end.

