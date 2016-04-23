{.$DEFINE SECURE}

unit DataFile; {- managing the .ini - type datafile}

interface

type
  DataStr = String[80];

  PDataFile = ^TDataFile;
  TDataFile = object
    F, FTmp  : Text;
    FileName : String;
    EndTopic : Boolean;
    CurTopic : DataStr;
    constructor Init(FN : String);
    destructor  Done;
    procedure   WriteMode(Topic: DataStr);
    procedure   Flush;
    procedure   ReadMode(Topic: DataStr);
    procedure   Write(S: DataStr);
    function    Read: DataStr;
    procedure   Delete(Topic: DataStr);
    function    IsTopicExist(Topic: DataStr): Boolean;
    function    GenerateNewTopic: DataStr;
    function    CountTopics : LongInt;
  private
    ReserveStr : DataStr;
  end;

procedure CodeFile(FN: String);

const
  GenTopicSize: Byte = 7;
  TopicChar = '■';

implementation
uses Dos;

{$I-}

const
  CodeStr : DataStr =
  '(c) 1996 Tigers of SoftLand. Coded by Anton Zhuchkov. All rights not reserved. AZ';

var
  PC : Integer;
function Code(S: DataStr): DataStr;
var
  I : Integer;
  St : DataStr;
begin
  St := S;
  PC := 1;
  for I := 1 to Length(S) do
  begin
    Byte(St[I]) := Byte(St[I]) xor Byte(CodeStr[PC]);
    inc(PC);
    if PC > Length(CodeStr) then PC := 1;
  end;
  Code := St;
end;

procedure CodeFile(FN: String);
var
  F, FTo: Text;
  St    : String;
begin
  Assign(F, FN);
  Reset(F);
  if IOResult <> 0 then
  begin
    Writeln('■ CodeFile ■ File not found: ', FN);
    Halt(10);
  end;
  Assign(FTo, '$CODE$.$$$');
  Rewrite(FTo);
  while not EOF(F) do
  begin
    Readln(F, St);
    if St[1] <> TopicChar then Writeln(FTo, Code(St)) else Writeln(FTo, St);
  end;
  Close(F);
  Close(FTo);
  Erase(F);
  Rename(FTo, FN);
end;


function ReplaceExt(FN, NewExt: String): String;
var
  D, N, E: String;
begin
  FSplit(FN, D, N, E);
  ReplaceExt := D + N + NewExt;
end;

function TrimStr(S: String): String;
var
  STmp: String;
  I   : Integer;
begin
  STmp := S;
  while STmp[Byte(STmp[0])] = ' ' do
     Dec(Byte(STmp[0]));
  TrimStr := STmp;
end;



constructor TDataFile.Init(FN : String);
begin
  FileName := FN;
  Assign(F, FileName);
  Reset(F);
  if IOResult <> 0 then
    Rewrite(F);
end;

destructor TDataFile.Done;
begin
  Close(F);
end;


procedure TDataFile.WriteMode(Topic: DataStr);
var
  St: DataStr;
  Search : DataStr;
begin
  Assign(FTmp,ReplaceExt(FileName, '.$$$'));
  Rewrite(FTmp);
  Search := TopicChar+TrimStr(Topic);
  if not EOF(F) then
    repeat
      Readln(F, St);
      Writeln(FTmp, St);
    until (St = Search) or EOF(F);
  if EOF(F) then Writeln(FTmp, Search);
  CurTopic := Topic;
end;

procedure TDataFile.Flush;
var
  St: DataStr;
begin
  if not EOF(F) then
  begin
    repeat
      Readln(F, St);
    until EOF(F) or (St[1] = TopicChar);
    if not EOF(F) then
    begin
      Writeln(FTmp, St);
      repeat
        Readln(F, St);
        Writeln(FTmp, St);
      until EOF(F);
    end;
  end;
  Close(F);
  Close(FTmp);
  Erase(F);
  Rename(FTmp, FileName);
  Reset(F);
end;

procedure TDataFile.ReadMode(Topic: DataStr);
var
  St: DataStr;
  Search : DataStr;
begin
  Close(F);
  Reset(F);
  Search := TopicChar+TrimStr(Topic);
  repeat
    Readln(F, St);
  until (St = Search) or EOF(F);
  if EOF(F) then
  begin
    Writeln('■ TDataFile.Readmode ■  Topic not found: ',Topic);
    Halt(10);
  end;
  Readln(F, ReserveStr);
  if EOF(F) or (ReserveStr[1] = TopicChar) then
    EndTopic := True else EndTopic := False;
  CurTopic := Topic;
end;

procedure TDataFile.Write(S: DataStr);
begin
{$IFDEF SECURE}
  Writeln(FTmp, Code(S));
{$ELSE}
  Writeln(FTmp, S);
{$ENDIF}
end;

function TDataFile.Read: DataStr;
begin
  if EndTopic then
  begin
    Writeln('■ TDataFile.Read ■ Topic data overflow: ', CurTopic);
    Halt(10);
  end;

{$IFDEF SECURE}
  Read := Code(ReserveStr);
{$ELSE}
  Read := ReserveStr;
{$ENDIF}
  if not EOF(F) then
  begin
    Readln(F, ReserveStr);
    if (ReserveStr[1] = TopicChar) then
      EndTopic := True else EndTopic := False;
  end else EndTopic := True;
end;

procedure TDataFile.Delete(Topic: DataStr);
var
  Search,
  Current : DataStr;
  LastOne : Boolean;
begin
  Assign(FTmp,ReplaceExt(FileName, '.$$$'));
  Rewrite(FTmp);
  Search := TopicChar+TrimStr(Topic);
  Close(F);
  Reset(F);
  Readln(F, Current);
  LastOne := False;
  while (Current <> Search) and not LastOne do
  begin
    Writeln(FTmp, Current);
    if EOF(F) then LastOne := True;
    if not LastOne then Readln(F, Current);
  end;

  if LastOne then
  begin
    Writeln('■ TDataFile.Delete ■ Topic not found: ',Topic);
    Halt(100);
  end;

  Readln(F, Current);
  while (Current[1] <> TopicChar) and not EOF(F) do
    Readln(F, Current);

  if not EOF(F) then
  begin
    Writeln(FTmp, Current);
    while not EOF(F) do
    begin
      Readln(F, Current);
      Writeln(FTmp, Current);
    end;
  end;

  Close(F);
  Close(FTmp);
  Erase(F);
  Rename(FTmp, FileName);
  Reset(F);
end;

function TDataFile.IsTopicExist(Topic: DataStr): Boolean;
var
  Found : Boolean;
  S1    : DataStr;
begin
  Reset(F);
  Found := False;
  while not EOF(F) and not Found do
  begin
    Readln(F, S1);
    if S1[1] = TopicChar then
    begin
      System.Delete(S1, 1, 1);
      if S1 = Topic then Found := True;
    end;
  end;
  IsTopicExist := Found;
end;

function TDataFile.GenerateNewTopic: DataStr;
var
  S: DataStr;
  I: Byte;
  Valid : Boolean;
begin
  S[0] := Char(GenTopicSize);
  repeat
    for I := 1 to GenTopicSize do
      S[I] := Char(Random(25) + 65);
    if IsTopicExist(S) then Valid := False else Valid := False;
  until Valid;
  GenerateNewTopic := S;
end;

function TDataFile.CountTopics : LongInt;
var
  I : LongInt;
  S : DataStr;
begin
  Reset(F);
  I := 0;
  while not EOF(F) do
  begin
    Readln(F, S);
    if S[1] = TopicChar then Inc(I);
  end;
  CountTopics := I;
end;

end.
