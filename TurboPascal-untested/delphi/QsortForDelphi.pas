(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0039.PAS
  Description: QSort for DELPHI
  Author: MIKE JUNKIN
  Date: 11-22-95  15:50
*)

unit Qsort;

{TQSort by Mike Junkin 10/19/95.
 DoQSort routine adapted from Peter Szymiczek's QSort procedure which
 was presented in issue#8 of The Unofficial Delphi Newsletter.}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TSwapEvent = procedure (Sender : TObject; e1,e2 : word) of Object;
  TCompareEvent = procedure (Sender: TObject; e1,e2 : word; var Action : integer) of Object;

  TQSort = class(TComponent)
  private
    FCompare : TCompareEvent;
    FSwap : TSwapEvent;
  public
    procedure DoQSort(Sender: TObject; uNElem: word);
  published
    property Compare : TCompareEvent read FCompare write FCompare;

    property Swap : TSwapEvent read FSwap write FSwap;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Mikes', [TQSort]);
end;

procedure TQSort.DoQSort(Sender: TObject; uNElem: word);
{ uNElem - number of elements to sort }

  procedure qSortHelp(pivotP: word; nElem: word);
  label
    TailRecursion,
    qBreak;
  var
    leftP, rightP, pivotEnd, pivotTemp, leftTemp: word;
    lNum: word;
    retval: integer;
  begin
    retval := 0;
    TailRecursion:
      if (nElem <= 2) then

        begin
          if (nElem = 2) then
            begin
              rightP := pivotP +1;
              FCompare(Sender,pivotP,rightP,retval);
              if (retval > 0) then Fswap(Sender,pivotP,rightP);
            end;
          exit;
        end;
      rightP := (nElem -1) + pivotP;
      leftP :=  (nElem shr 1) + pivotP;
      { sort pivot, left, and right elements for "median of 3" }
      FCompare(Sender,leftP,rightP,retval);
      if (retval > 0) then Fswap(Sender,leftP, rightP);
      FCompare(Sender,leftP,pivotP,retval);

      if (retval > 0) then Fswap(Sender,leftP, pivotP)
      else 
        begin
          FCompare(Sender,pivotP,rightP,retval);
          if retval > 0 then Fswap(Sender,pivotP, rightP);
        end;
      if (nElem = 3) then
        begin
          Fswap(Sender,pivotP, leftP);
          exit;
        end;
      { now for the classic Horae algorithm }
      pivotEnd := pivotP + 1;
      leftP := pivotEnd;
      repeat
        FCompare(Sender,leftP, pivotP,retval);
        while (retval <= 0) do
          begin

            if (retval = 0) then
              begin
                Fswap(Sender,leftP, pivotEnd);
                Inc(pivotEnd);
              end;
            if (leftP < rightP) then
              Inc(leftP)
            else
              goto qBreak;
            FCompare(Sender,leftP, pivotP,retval);
          end; {while}
        while (leftP < rightP) do
          begin
            FCompare(Sender,pivotP, rightP,retval);
            if (retval < 0) then
              Dec(rightP)

            else
              begin
                FSwap(Sender,leftP, rightP);
                if (retval <> 0) then
                  begin
                    Inc(leftP);
                    Dec(rightP);
                  end;
                break;
              end;
          end; {while}

      until (leftP >= rightP);
    qBreak:
      FCompare(Sender,leftP,pivotP,retval);
      if (retval <= 0) then Inc(leftP);

      leftTemp := leftP -1;
      pivotTemp := pivotP;
      while ((pivotTemp < pivotEnd) and (leftTemp >= pivotEnd)) do
        begin
          Fswap(Sender,pivotTemp, leftTemp);
          Inc(pivotTemp);
          Dec(leftTemp);
        end; {while}
      lNum := (leftP - pivotEnd);
      nElem := ((nElem + pivotP) -leftP);

      if (nElem < lNum) then
        begin
          qSortHelp(leftP, nElem);
          nElem := lNum;
        end
      else
        begin

          qSortHelp(pivotP, lNum);
          pivotP := leftP;
        end;
      goto TailRecursion;
    end; {qSortHelp }

begin
  if Assigned(FCompare) and Assigned(FSwap) then
  begin
    if (uNElem < 2) then  exit; { nothing to sort }
    qSortHelp(1, uNElem);
  end;
end; { QSort }

end. 

{ demo }

unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Qsort, StdCtrls;

type
  TForm1 = class(TForm)
    QSort1: TQSort;
    StringGrid1: TStringGrid;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure QSort1Compare(Sender: TObject; e1, e2: Word; var Action: Integer);
    procedure QSort1Swap(Sender: TObject; e1, e2: Word);
    procedure Button1Click(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin

     with StringGrid1 do
     begin
          Cells[1,1] := 'the';
          Cells[1,2] := 'brown';
          Cells[1,3] := 'dog';
          Cells[1,4] := 'bit';
          Cells[1,5] := 'me';
     end;
end;

procedure TForm1.QSort1Compare(Sender: TObject; e1, e2: Word;
  var Action: Integer);
begin
     with Sender as TStringGrid do
    begin
      if (Cells[1, e1] < Cells[1, e2]) then
        Action := -1
      else if (Cells[1, e1] > Cells[1, e2]) then

        Action := 1
      else
        Action := 0;
    end; {with}

end;

procedure TForm1.QSort1Swap(Sender: TObject; e1, e2: Word);
var
  s: string[63];  { must be large enough to contain the longest string in the grid }
  i: integer;
begin
  with Sender as TStringGrid do
    for i := 0 to ColCount -1 do
    begin
      s := Cells[i, e1];
      Cells[i, e1] := Cells[i, e2];
      Cells[i, e2] := s;
    end; {for}

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  QSort1.DoQSort(StringGrid1,STringGrid1.RowCount-1);
end;

end.
