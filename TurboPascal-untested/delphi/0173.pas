(*
 DESCRIPTION :  A improved version of the stringgrid component
 AUTHOR      : Harm v. Zoest, email : 4923559@hsu1.HVU.nl
 VERSION     :  0.95 (beta) 06-27- 1996
 REMARKS     : If you have comments, found bugs, ore you have added some
               nice features, please mail me!
 *)

{$S-,I-,D-,L-}
unit ImpGrid;

interface

uses
   WinTypes, SysUtils, Messages, Classes, Controls, Grids;

type
  { own exeptions}}
  EErrorInCell = class(Exception);
  EFileNotFound = class(Exception);


  TImpGrid = class(TStringGrid)
  private
    FHCol, FHRow: TStrings;
    procedure InitHCol;
    procedure InitHRow;
  protected
    procedure Loaded; override;
  published
    property HCol: TStrings read FHCol write SetHCol;
    property HRow: TStrings read FHRow write SetHRow;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RemoveRows(RowIndex, RCount: LongInt);
    procedure InsertRows(RowIndex, RCount: LongInt);
    procedure RemoveCols(ColIndex, CCount: LongInt);
    procedure InsertCols(ColIndex, CCount: LongInt);
    procedure Clear;
    function isCell(SubStr: String; var ACol, ARow: LongInt): Boolean;
    procedure SaveToFile(FileName: String);
    procedure LoadFromFile(FileName: String);
    function CellToReal(ACol, ARow: LongInt): Real;
  end;

procedure Register;

implementation


constructor TImpGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHCol:=TStringList.Create;
  FHRow:=TStringList.Create;
end;

procedure Timpgrid.Loaded;
begin
  inherited Loaded;
  initHCol;
  initHRow;
end;

procedure TImpGrid.SetHCol(Value: TStrings);
begin
  FHCol.Assign(Value);
  InitHCol;
  Refresh;
end;

procedure TImpGrid.SetHRow(Value: TStrings);
begin
  FHRow.Assign(Value);
  InitHRow;
  Refresh;
end;

procedure TImpgrid.InitHCol;
var
  I: Integer;
begin
  if (FHCol <> nil) then
    for I :=0 to pred( ColCount) do
    begin
      if I <FHCol.Count then
         Cells[I, 0] :=FHCol[I]
      else Cells[I, 0] :='';
    end;{for}
end;

procedure ImpGrid.InitHRow;
var
  I: Integer;
begin
  if (FHRow <> nil) then
    for I :=0 to RowCount -2 do
    begin
      if I <FHRow.Count then
      Cells[0, I + 1]:=FHRow[I]
      else Cells[0, I + 1]:='';
    end;
end;

procedure TImpGrid.RemoveRows(RowIndex, RCount : LongInt);
var
  i: LongInt;
begin
  for i := RowIndex to RowCount - 1 do
      Rows[i] := Rows[i + RCount];
  RowCount := RowCount - RCount;
end;


procedure TImpGrid.InsertRows(RowIndex, RCount : LongInt);
var
  i: LongInt;
begin
  RowCount := RowCount + RCount;
  for i := RowCount - 1 downto RowIndex do
      Rows[i] := Rows[i - RCount];
end;


procedure TImpGrid.RemoveCols(ColIndex, CCount : LongInt);
var
  i: LongInt;
begin
  for i := ColIndex to ColCount - 1 do
      Cols[i] := Cols[i + CCount];
  ColCount := ColCount - CCount;
end;


procedure TImpGrid.InsertCols(ColIndex, CCount : LongInt);
var
  i: LongInt;
begin
  ColCount := ColCount + CCount;
  for i := ColCount - 1 downto ColIndex do
      Cols[i] := Cols[i - CCount];
end;


procedure TImpGrid.Clear;
var
  i: LongInt;
begin
  for i:= 0 to ColCount - 1 do
      Cols[i].Clear;
end;


function TImpGrid.isCell(SubStr: String; var ACol, ARow: LongInt): Boolean;
var
  i, j: LongInt;
begin
  for i := 0 to RowCount - 1 do
  begin
    for j := 0 to ColCount - 1 do
    begin
      if Rows[i].Strings[j] = SubStr then
      begin
        ARow := i;
        ACol := j;
        Result := True;
        exit;
      end;
    end;
  end;
  Result := False;
end;


procedure TImpGrid.SaveToFile(FileName: String);
var
  i, j: LongInt;
  ss: string;
  f: TextFile;
begin
  AssignFile(f, FileName);
  Rewrite(f);
  ss := IntToStr(ColCount) + ',' + IntToStr(RowCount);
  Writeln(f, ss);

  for i := 0 to RowCount - 1 do
  begin
    for j := 0 to ColCount - 1 do
    begin
      if Cells[j, i] <> '' then
      begin
        ss := IntToStr(j) + ',' + IntToStr(i) + ',' + Cells[j, i];
        Writeln(f, ss);
      end;
    end;
  end;
  CloseFile(f);
end;


procedure TImpGrid.LoadFromFile(FileName: String);
var
  X, Y: Integer;
  ss, ss1: string;
  f: TextFile;
begin
  AssignFile(f, FileName);
  Reset(f);
  if IOResult <> 0 then raise EFileNotFound.Create('File ' + FileName + ' not found');
  Readln(f, ss);
  if ss <> '' then
  begin
    ss1 := Copy(ss, 1, Pos(',', ss) - 1);
    ColCount := StrToInt(ss1);
    ss1 := Copy(ss, Pos(',', ss) + 1, Length(ss));
    RowCount := StrToInt(ss1);
  end;

  while not Eof(f) do
  begin
    Readln(f, ss);
    ss1 := Copy(ss, 1, Pos(',', ss) - 1);
    ss := Copy(ss, Pos(',', ss) + 1, Length(ss));
    X := StrToInt(ss1);
    ss1 := Copy(ss, 1, Pos(',', ss) - 1);
    ss := Copy(ss, Pos(',', ss) + 1, Length(ss));
    Y := StrToInt(ss1);
    Cells[X, Y] := ss;
  end;
  CloseFile(f);
end;


function TImpGrid.CellToReal(ACol, ARow: LongInt): Real;
var
  i: Real;
  Code: Integer;
begin
  if Cells[ACol, ARow] <> '' then
  begin
    Val(Cells[ACol, ARow], i, Code);
    if Code <> 0 then raise
          EErrorInCell.Create('Error at position: ' +
          IntToStr(Code) + ' in Cell [' + IntToStr(ACol) + ', ' +
          IntToStr(ARow) + '].')
    else
    Result := i;
  end;
end;


procedure Register;
begin
  RegisterComponents('Improved Components', [TImpGrid]);
end;


end.
