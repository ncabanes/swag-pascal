(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0294.PAS
  Description: stream for a buffered line by line acces
  Author: MARTIN WALDENBURG
  Date: 08-30-97  10:08
*)


{+--------------------------------------------------------------------------+
 | Class:       TLineStream
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: TLineStream gives a buffered access to the lines of a
file.
 |              Every line must end with CRLF. Don't forget to flush the
 |              Memory after writing.
 | Version:     1.2
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
    fMaxLineSize:Longint;
    fMemorySize: LongInt;
    fLineSize:Longint;
    fMemory:PChar;
    fLine: PChar;
    fFileEof:Boolean;
    fMemoryPos: LongInt;
    fEof:Boolean;
    function GetMemoryFull:Boolean;
    procedure SetMaxLineSize(NewValue:Longint);
    procedure SetMaxMemorySize(NewValue:Longint);
  protected
  public
    constructor create(Const FileName: string;  Mode: Word);
    destructor destroy;override;
    procedure FillMemory;
    function ReadLine:PChar;
    procedure WriteLine(NewLine: String);
    procedure FlushMemory;
    procedure Reset;
    property MaxMemorySize:Longint read fMaxMemorySize write
SetMaxMemorySize;
    property MaxLineSize:Longint read fMaxLineSize write SetMaxLineSize;
    property Memory:PChar read fMemory write fMemory;
    property MemoryFull:Boolean read GetMemoryFull;
    property FileEof:Boolean read fFileEof;
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
  fFileEof:= False;
  MaxMemorySize:= 65535;
  fMemorySize:= 0;
  fMemoryPos:= 0;
  MaxLineSize:= 4096;
  Position:= 0;
end;  { create }

destructor TLineStream.destroy;
begin
  ReallocMem(fMemory, 0);
  ReallocMem(fLine, 0);
  inherited destroy;
end;  { destroy }


procedure TLineStream.SetMaxMemorySize(NewValue:Longint);
begin
  fMaxMemorySize:= NewValue;
  ReallocMem(fMemory, fMaxMemorySize +1);
end; { SetMaxMemorySize }

procedure TLineStream.SetMaxLineSize(NewValue:Longint);
begin
  fMaxLineSize:= NewValue;
  ReallocMem(fLine, fMaxLineSize +1);
end;  { SetMaxLineSize }

procedure TLineStream.FillMemory;
var
  Readed: LongInt;
begin
  Readed:= Read(fMemory^, fMaxMemorySize);
  fMemorySize:= Readed;
  if Readed = 0 then fFileEof:= True;
  if fMemorySize > 0 then
  while fMemory[fMemorySize -2] <> #13 do  dec(fMemorySize);
  fMemory[fMemorySize]:= #0;
  Position:= Position -Readed + fMemorySize +1;
  fLineStart:= fMemory;
end;   { FillMemory }

function TLineStream.GetMemoryFull:Boolean;
begin
  if fMemorySize > 0 then Result:= True else Result:= False;
end;  { GetMemoryFull }

function TLineStream.ReadLine:PChar;
var
  Run: PChar;
begin
  if (fMemorySize = 0) and not FileEof then FillMemory;
  if fMemorySize > 0 then
  begin
    Run:= fLineStart;
    while Run^ <> #13 do inc(Run);
    fLineSize:= Run - fLineStart;
    inc(Run, 2);
    StrLCopy(fLine, fLineStart, fLineSize);
    fLine[fLineSize]:= #0;
    Result:= fLine;
    fLineStart:= Run;
    Case Run^ of #0: FillMemory end;
  end;
  if fMemorySize = 0 then fEof:= True;
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
  fFileEof:= False;
  fMemorySize:= 0;
  fMemoryPos:= 0;
  Position:= 0;
end;  { Reset }

end.

