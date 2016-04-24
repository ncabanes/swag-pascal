(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0030.PAS
  Description: HUGE Objects unit
  Author: SWAG SUPPORT TEAM
  Date: 08-24-94  13:24
*)

unit BigStuff;
interface
uses
  Objects,
  WinAPI;

type
  PBigData = ^TBigData;
  TBigData = object(TObject)
    NumRecs: Longint;
    RecSize: Word;
    Start: Word;
    constructor Init(ANumRecs: Longint; ARecSize: Word);
    destructor Done; virtual;
    procedure GetSetData(Index: Longint; var Data; SetData: Boolean);
      virtual;
  end;
implementation

constructor TBigData.Init(ANumRecs: Longint; ARecSize: Word);
begin
  TObject.Init;
  NumRecs := ANumRecs;
  RecSize := ARecSize;
  while 65536 mod RecSize <> 0 do Inc(RecSize);
  Start := GlobalAlloc(gmem_Moveable, RecSize * NumRecs);
  if Start = 0 then
    Runerror(201);
end;

destructor TBigData.Done;
begin
  TObject.Done;
  GlobalFree(Start);
end;

procedure TBigData.GetSetData(Index: Longint; var Data; SetData: Boolean);
var
  Selector, Offset: Word;
  P: Pointer;
begin
  if Index >= NumRecs then
    begin
      RunError(201);
    end;
  Index := Index * RecSize;
  Selector := (Index div 65536) * SelectorInc + Start;
  OffSet := Index mod 65536;
  P := GlobalLock(Selector);
  P := Ptr(Selector, Offset);
  if SetData then
    Move(Data, P^, RecSize)
  else
    Move(P^, Data, RecSize);
  GlobalUnlock(Selector);
end;

type
  PBigInt = ^TBigInt;
  TBigInt = object(TBigData)
    constructor Init(ANumRecs: Longint);
    procedure PutItem(Index: Longint; Value: Integer);
    function GetItem(Index: Longint): Integer;
  end;

constructor TBigInt.Init(ANumRecs: Longint);
begin
  TBigData.Init(ANumRecs, SizeOf(Integer));
end;

procedure TBigInt.PutItem(Index: Longint; Value: Integer);
begin
  TBigData.GetSetData(Index, Value, True);
end;

function TBigInt.GetItem(Index: Longint): Integer;
var
  Value: Integer;
begin
  TBigData.GetSetData(Index, Value, False);
  GetItem := Value;
end;

var
  BI: TBigInt;
begin
  BI.Init(200000);
  BI.PutItem(100000, 777);
  Writeln(BI.GetItem(100000));
  BI.Done;
end.

