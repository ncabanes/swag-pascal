(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0420.PAS
  Description: Allowing Query By Form for DbGrid compon
  Author: RICK RUTT
  Date: 01-02-98  07:34
*)


From: 'Rick Rutt, Midland, MI' <RRUTT@delphi.com>

Here is a Delphi unit for a modal dialog to support Query By Form (QBF) for DbGrid components which receive data from Table components (not Query components).
The lack of this as a built-in feature makes it harder for Delphi to compete with more resource-intensive tools like Oracle Forms. This unit is not as powerful as the built-in QBF features of Oracle Forms, but it does fill a significant gap in functionality.

Note that the unit is copyrighted, as required by Borland's license, and as desired by me to retain credit for its development. Note that the copyright terms allow free use for any purpose.



--------------------------------------------------------------------------------

unit Db_QBF;  { Database Query By Form -- Version 19950731 }

{ Copyright 1995 by Rick Rutt.
  This work may be used, copied, or distributed by anyone for any purpose,
  provided all copies retain this copyright notice,
  and provided no fee is charged for the contents of this work.
  The author grants permission to anyone to create a derivative work,
  provided each derivative work contains a copyright notice and the notice
  "Portions of this work are based on Db_QBF.PAS as written by Rick Rutt."
}

{ This unit provides a basic but effective Query By Form service
  for database access applications written using Borland Delphi.
  This unit also provides a similar Sort By Form service.

  The Query By Form service displays a modal dialog box with a StringGrid
  of searchable fields, taken from the calling DbGrid.  The user may
  enter an exact search value for any number of fields, and may use
  drag and drop to rearrange the sort order of the fields.
  (Only the fields that contain search values are relevant to the sort.)
  When the user clicks the dialog's OK button, this unit modifies the
  calling DbGrid's IndexFieldNames property, applies a search range
  (of exact values), and refreshes the data.
  If the user leaves all search values empty, this unit clears the
  calling DbGrid's IndexFieldNames property, clears the search range,
  and refreshes the data.

  The Sort By Form service works in a similar manner, except that it
  does not accept search values from the user.  The user drags and drops
  the field sort order, then clicks the OK button.  This unit modifies
  the calling DbGrid's IndexFieldNames property, clears the search range,
  and refreshes the data.
}

{ Create the corresponding dialog form using the New Form action,
  selecting a Standard Dialog Box.  Place a StringGrid on the form
  (as found in the Additional tab of the component toolbar.
  Set the StringGrid's Height to 161 and its Width to 305.
  Finally, replace the new form's .PAS source with this unit.
}

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Grids, DBGrids;

{ The following two procedures provide the mechanism for accessing
  the services of this unit.

  Have a button or menu item on the calling form call one of these
  procedures, passing the DbGrid as the argument.  (Remember to add
  "uses Db_QBF;" to the calling form's implementation section.)

  Restriction:  The DbGrid must reference a DataSource that, in turn,
  references a DataSet that is a Table.  This unit does not support
  a DataSet that is a Query, since it has no IndexFieldNames property.
}

procedure QueryByForm(grid: TDbGrid);

procedure SortByForm(grid: TDbGrid);

{ The following section is managed by the Delphi environment. }

type
  TdlgQBF = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    gridQBF: TStringGrid;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgQBF: TdlgQBF;

implementation

{ The following section is managed by the programmer,
  with assistance from the Delphi environment. }

uses Dialogs, Db, DbTables;

{$R *.DFM}

const
  qbfRowHeight = 16;
  qbfColWidth  = 150;

  qbfFieldLabel = '<<Field>>';
  qbfValueLabel = '<<Value>>';

  qbfQueryCaption = 'Query for Table ';
  qbfSortCaption  = 'Sort Order for Table ';

var
  { Remember some things for use by the QBF dialog's OK button. }
  CallingGrid: TDbGrid;
  CallingMode: (modeQuery, modeSort);

procedure SetupAndShowForm;  { Called by the two exported procedures }
var
  i, j, n: integer;
  tbl: TTable;
  f: TField;
begin
  n := CallingGrid.FieldCount;
  if n <= 0 then begin { Exceptions may be raised instead of showing messages }
    MessageDlg(
        'Db_QBF unit called for a DbGrid without any Fields',
        mtWarning, [mbOK], 0);
  end else if CallingGrid.DataSource = NIL then begin
    MessageDlg(
        'Db_QBF unit called for a DbGrid without a DataSource',
        mtWarning, [mbOK], 0);
  end else if CallingGrid.DataSource.DataSet = NIL then begin
    MessageDlg(
        'Db_QBF unit called for a DbGrid with a DataSource without a DataSet',
        mtWarning, [mbOK], 0);
  end else if not (CallingGrid.DataSource.DataSet is TTable) then begin
    MessageDlg(
        'Db_QBF unit called for a DbGrid with a DataSource that is not a Table',
        mtWarning, [mbOK], 0);
  end else with dlgQBF.gridQBF do begin
    { These properties can also be set once at design time }
    DefaultRowHeight := qbfRowHeight;
    Scrollbars := ssVertical;
    ColCount := 2;  { Even the Sort service needs a dummy second column }

    { These properties must be set at run time }
    RowCount := Succ(n);
    Cells[0,0] := qbfFieldLabel;
    Options := Options + [goRowMoving];

    tbl := TTable(CallingGrid.DataSource.DataSet);

    if CallingMode = modeQuery then begin
      dlgQBF.Caption := qbfQueryCaption + tbl.TableName;
      Cells[1,0] := qbfValueLabel;
      Options := Options + [goEditing];  { Allow user to enter values }
      DefaultColWidth  := qbfColWidth;
    end else begin
      dlgQBF.Caption := qbfSortCaption + tbl.TableName;
      Cells[1,0] := '';  { Dummy "value" column to allow fixed "field" column }
      Options := Options - [goEditing];  { User just reorders the rows }
      DefaultColWidth  := (2 * qbfColWidth);  { Shove aside dummy 2nd column }
    end;

    j := 0;  { Actual number of fields shown to user }
    for i := 1 to n do begin
      f := CallingGrid.Fields[Pred(i)];
      if f.DataType in [ftBlob,ftBytes,ftGraphic,ftMemo,ftUnknown,ftVarBytes]
          then  RowCount := Pred(RowCount)  { Ignore unsearchable fields }
      else begin
        Inc(j);
        Cells[0,j] := f.FieldName;
        Cells[1,j] := '';  { Empty search value }
      end;
    end;

    dlgQBF.HelpBtn.Visible := False;  { We haven't implemented Help }
    dlgQBF.ShowModal;
  end;  { with dlgQBF.gridQBF }
end;

procedure QueryByForm(Grid: TDbGrid);
begin
  CallingGrid := Grid;  { Save for use by OK button }
  CallingMode := modeQuery;
  SetupAndShowForm;
end;

procedure SortByForm(Grid: TDbGrid);
begin
  CallingGrid := Grid;  { Save for use by OK button }
  CallingMode := modeSort;
  SetupAndShowForm;
end;

procedure TdlgQBF.CancelBtnClick(Sender: TObject);
begin
  { Just dismiss the dialog, without making changes to the calling grid. }
  dlgQBF.Hide;
end;

procedure TdlgQBF.OKBtnClick(Sender: TObject);
var
  flds, sep, val: string;
  i, n, nfld: integer;
begin
  flds := '';  { List of fields separated by ';'.}
  sep  := '';  { Becomes ';' after the 1st field is appended. }
  nfld := 0;   { Number of fields in the list. }

  with dlgQBF.gridQBF do begin
    n := Pred(RowCount);
    if n > 0 then for i := 1 to n do begin
      val := Cells[1,i];  { The user-entered search value (if any) }
      if (CallingMode = modeSort)
      or (val <> '') then begin
        flds := flds + sep + Cells[0,i];
        sep  := ';';
        nfld := Succ(nfld);
      end;
    end;

    with CallingGrid.DataSource.DataSet as TTable do begin
      IndexFieldNames := flds;
      if (CallingMode = modeSort)
      or (flds = '') then begin
        CancelRange;
      end else begin
        SetRangeStart;
        for i := 1 to n do begin
          val := Cells[1,i];
          if val <> '' then begin
            FieldByName(Cells[0,i]).AsString := val;
          end;
        end;

        SetRangeEnd;  { Set range end to match range start }
        for i := 1 to n do begin
          val := Cells[1,i];
          if val <> '' then begin
            FieldByName(Cells[0,i]).AsString := val;
          end;
        end;
        ApplyRange;
      end;

      Refresh;
    end;  { with CallingGrid.DataSource.DataSet }
  end;  { with dlgQBF.gridQBF }

  dlgQBF.Hide;
end;

end.

