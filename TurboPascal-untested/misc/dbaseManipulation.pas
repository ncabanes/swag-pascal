(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0066.PAS
  Description: dBase Manipulation
  Author: BILL HIMMELSTOSS
  Date: 01-27-94  11:57
*)

{
{ If this code is used commercially, please send a few bucks to      }
{ Bill Himmelstoss, PO BOX 23246, Jacksonville, FL  32241-3246,      }
{ Otherwise, it's freely distributable.                              }

unit DBF;

interface

uses
  Objects,
  OString;

type
  TYMDDate = record
    Year,
    Month,
    Day: Byte;
  end;

  PDatabase = ^TDatabase;
  TDatabase = object(TObject)
    DatabaseType: Byte;
    LastUpdate: TYMDDate;
    NumRecords: Longint;
    FirstRecordPos: Word;
    RecordLength: Word;

    S: TDosStream;
    Pathname: TOString;
    Modified: Boolean;
    Fields: TCollection;

    constructor Init(APathname: TOString);
    constructor InitCreate(APathname: TOString; AFields: PCollection);
    destructor Done; virtual;
    procedure RefreshHeader;
    procedure UpdateHeader;
    function GetRecord(RecordNum: Longint): Pointer;
    procedure PutRecord(RecordNum: Longint; Rec: Pointer);
    procedure Append(Rec: Pointer);
    procedure Zap;
    procedure RefreshFields;
  end;

  PFieldDef = ^TFieldDef;
  TFieldDef = object(TObject)
    Name: TOString;
    DataType: Char;
    Displacement: Longint;
    Length: Byte;
    Decimal: Byte;

    constructor Init(
      AName: String;
      ADataType: Char;
      ALength,
      ADecimal: Byte);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

implementation

uses
  WinDos;

constructor TDatabase.Init(APathname: TOString); begin
  inherited Init;
  Pathname.InitText(APathname);
  S.Init(Pathname.CString, stOpen);
  if S.Status <> stOk then Fail;
  Fields.Init(5, 5);
  RefreshHeader;
end;

constructor TDatabase.InitCreate(APathname: TOString; AFields: PCollection);
const
  Terminator: Byte = $0D;
var
  Year, Month, Day, Dummy: Word;

  procedure CopyField(Item: PFieldDef); far;
  begin
    Fields.Insert(Item);
  end;

  procedure WriteFieldSubrecord(Item: PFieldDef); far;
  begin
    Item^.Store(S);
    Inc(RecordLength, Item^.Length);
  end;

begin
  inherited Init;

  DatabaseType := $03;
  GetDate(Year, Month, Day, Dummy);
  LastUpdate.Year := Year - 1900;
  LastUpdate.Month := Month;
  LastUpdate.Day := Day;
  NumRecords := 0;
  RecordLength := 0;

  Pathname.InitText(APathname);
  S.Init(Pathname.CString, stCreate);
  if S.Status <> stOk then Fail;
  UpdateHeader;

  S.Seek(32); { beginning of field subrecords }
  Fields.Init(AFields^.Count, 5);
  AFields^.ForEach(@CopyField);
  Fields.ForEach(@WriteFieldSubrecord);

  S.Write(Terminator, SizeOf(Terminator));
  Modified := true;
  FirstRecordPos := S.GetPos;
  UpdateHeader;
end;

destructor TDatabase.Done;
begin
  if Modified then UpdateHeader;
  Pathname.Done;
  S.Done;
  Fields.Done;
  inherited Done;
end;

procedure TDatabase.RefreshHeader;
var
  OldPos: Longint;
begin
  OldPos := S.GetPos;
  S.Seek(0);
  S.Read(DatabaseType, SizeOf(DatabaseType));
  S.Read(LastUpdate, SizeOf(LastUpdate));
  S.Read(NumRecords, SizeOf(NumRecords));
  S.Read(FirstRecordPos, SizeOf(FirstRecordPos));
  S.Read(RecordLength, SizeOf(RecordLength));
  S.Seek(OldPos);
  RefreshFields;
end;

procedure TDatabase.UpdateHeader;
var
  OldPos: Longint;
  Reserved: array[12..31] of Char;
begin
  OldPos := S.GetPos;
  S.Seek(0);
  S.Write(DatabaseType, SizeOf(DatabaseType));
  S.Write(LastUpdate, SizeOf(LastUpdate));
  S.Write(NumRecords, SizeOf(NumRecords));
  S.Write(FirstRecordPos, SizeOf(FirstRecordPos));
  S.Write(RecordLength, SizeOf(RecordLength));
  FillChar(Reserved, SizeOf(Reserved), #0);
  S.Write(Reserved, SizeOf(Reserved));
  S.Seek(OldPos);
end;

function TDatabase.GetRecord(RecordNum: Longint): Pointer; var
  Temp: Pointer;
  Pos: Longint;
begin
  Temp := NIL;
  GetMem(Temp, RecordLength);
  if Temp <> NIL then
  begin
    Pos := FirstRecordPos + ((RecordNum - 1) * RecordLength);
    if S.GetPos <> Pos then
      S.Seek(Pos);
    S.Read(Temp^, RecordLength);
  end;
  GetRecord := Temp;
end;

procedure TDatabase.Append(Rec: Pointer); begin
  if Assigned(Rec) then
  begin
    Modified := true;
    Inc(NumRecords);
    PutRecord(NumRecords, Rec);
  end;
end;

procedure TDatabase.PutRecord(RecordNum: Longint; Rec: Pointer); var
  Pos: Longint;
begin
  if Assigned(Rec) and (RecordNum <= NumRecords) then
  begin
    Pos := FirstRecordPos + ((RecordNum - 1) * RecordLength);
    if S.GetPos <> Pos then
      S.Seek(Pos);
    S.Write(Rec^, RecordLength);
  end;
end;

procedure TDatabase.Zap;
var
  T: TDosStream;
  Temp, D, N, E: TOString;
  F: File;
begin
  D.Init(fsDirectory);
  N.Init(fsFilename);
  E.Init(fsExtension);
  FileSplit(Pathname.CString, D.CString, N.CString, E.CString);
  D.RecalcLength;
  N.RecalcLength;
  E.RecalcLength;
  Temp.InitText(D);
  Temp.Append(N);
  Temp.AppendP('.TMP');
  D.Done;
  N.Done;
  E.Done;

  T.Init(Temp.CString, stCreate);
  S.Seek(0);
  T.CopyFrom(S, FirstRecordPos - 1);
  T.Done;
  S.Done;
  Assign(F, Pathname.CString);
  Erase(F);
  Assign(F, Temp.CString);
  Rename(F, Pathname.CString);
  S.Init(Pathname.CString, stOpen);
  NumRecords := 0;
  Modified := false;
  UpdateHeader;
end;

procedure TDatabase.RefreshFields;
var
  Terminator: Byte;
  HoldPos: Longint;
  FieldDef: PFieldDef;
begin
  S.Seek(32); { beginning of Field subrecords }

  repeat
    HoldPos := S.GetPos;
    S.Read(Terminator, SizeOf(Terminator));
    if Terminator <> $0D then
    begin
      S.Seek(HoldPos);
      FieldDef := New(PFieldDef, Load(S));
      Fields.Insert(FieldDef);
    end;
  until Terminator = $0D;
end;

constructor TFieldDef.Init(
  AName: String;
  ADataType: Char;
  ALength,
  ADecimal: Byte);
begin
  inherited Init;
  Name.InitTextP(AName);
  DataType := ADataType;
  Length := ALength;
  Decimal := ADecimal;
  Displacement := 0;
end;

destructor TFieldDef.Done;
begin
  Name.Done;
  inherited Done;
end;

constructor TFieldDef.Load(var S: TStream); var
  AName: array[1..11] of Char;
  Reserved: array[18..31] of Char;
begin
  S.Read(AName, SizeOf(AName));
  Name.Init(SizeOf(AName));
  Name.SetText_(@AName[1], 11);
  S.Read(DataType, SizeOf(DataType));
  S.Read(Displacement, Sizeof(Displacement));
  S.Read(Length, SizeOf(Length));
  S.Read(Decimal, SizeOf(Decimal));
  S.Read(Reserved, SizeOf(Reserved));
end;

procedure TFieldDef.Store(var S: TStream); var
  Reserved: array[18..31] of Char;
begin
  S.Write(Name.CString^, 11);
  S.Write(DataType, SizeOf(DataType));
  S.Write(Displacement, Sizeof(Displacement));
  S.Write(Length, SizeOf(Length));
  S.Write(Decimal, SizeOf(Decimal));
  FillChar(Reserved, SizeOf(Reserved), #0);
  S.Write(Reserved, SizeOf(Reserved));
end;

end.





program DbfTest;

uses
  dbf, wincrt, ostring, objects, strings;

type
  PDbfTest = ^TDbfTest;
  TDbfTest = record
    Deleted: Char; { ' '=no, '*'=yes }
    AcctNo: array[1..16] of Char;
    Chunk: array[1..8] of Char;
    Baskard: array[1..5] of Char;
    Extra: array[1..8] of Char;
    Sandwich: array[1..25] of Char;
  end;

var
  rec: PDbfTest;
  database: tdatabase;
  pathname: tostring;
  temp: string;
  fields: tcollection;

  procedure DoShow;

    procedure show(item: pfielddef); far;
    begin
      writeln(
        item^.name.cstring:15, ' ',
        item^.datatype, ' ',
        item^.length:10, ' ',
        item^.decimal:10, ' ');
    end;

  begin
    database.fields.foreach(@show);
  end;


begin
  InitWinCrt;

  fields.init(5, 0);
  fields.insert(new(pfielddef, init('ACCTNO',   'C', 16, 0)));
  fields.insert(new(pfielddef, init('CHUNK',    'N',  8, 2)));
  fields.insert(new(pfielddef, init('BASKARD',  'C',  5, 0)));
  fields.insert(new(pfielddef, init('EXTRA',    'D',  8, 0)));
  fields.insert(new(pfielddef, init('SANDWICH', 'C', 25, 0)));
  pathname.inittextp('c:\dbftest.dbf');
  database.initcreate(pathname, @fields);
  pathname.done;
  DoShow;

  New(Rec);
  with Rec^ do
  begin
    Acctno   := '1313558000001005'; { <-will self-check, but not valid }
    Chunk    := '   10.00';
    Baskard  := 'ABCDE';
    Extra    := '19931125';
    Sandwich := 'Turkey Leftovers         ';
  end;
  database.append(rec);
  dispose(rec);

  rec := database.getrecord(1);
  writeln(rec^.acctno, ' ', rec^.Sandwich);
  dispose(rec);

  database.done;
end.

