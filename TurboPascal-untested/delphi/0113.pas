{
Q:  "How can I determine the current record number for a dataset?"

A:  If the dataset is based upon a Paradox or dBASE table then
the record number can be determined with a couple of calls to
the BDE (as shown below).  The BDE doesn't support record
numbering for datasets based upon SQL tables, so if your server
supports record numbering you will need to refer to its
documentation.

    The following function is given as part of a whole unit and
takes as its parameter any component derived from TDataset
(i.e. TTable, TQuery, TStoredProc) and returns the current
record number (greater than zero) if it is a Paradox or dBASE
table.  Otherwise, the function returns zero.


    NOTE: for dBASE tables the record number returned is always
the physical record number.  So, if your dataset is a TQuery or
you have a range set on your dataset then the number returned
won't necessarily be relative to the dataset being viewed,
rather it will be based on the record's physical position in
the underlying dBASE table.
}

uses
  DB, DBTables, DbiProcs, DbiTypes, DbiErrs;

function GetRecordNumber(Dataset: TDataset): Longint;
var
  CursorProps: CurProps;
  RecordProps: RECProps;
begin
  { Return 0 if dataset is not Paradox or dBASE }
  Result := 0;
  with Dataset do
  begin
    { Is the dataset active? }
    if State = dsInactive then
      raise EDatabaseError.Create('Cannot perform this operation '+
                                  'on a closed dataset');

    { We need to make this call to grab the cursor's iSeqNums }
    Check(DbiGetCursorProps(Handle, CursorProps));

    { Synchronize the BDE cursor with the Dataset's cursor }
    UpdateCursorPos;

    { Fill RecordProps with the current record's properties }
    Check(DbiGetRecord(Handle, dbiNOLOCK, nil, @RecordProps));

    { What kind of dataset are we looking at? }
    case CursorProps.iSeqNums of
      0: Result := RecordProps.iPhyRecNum;  { dBASE   }
      1: Result := RecordProps.iSeqNum;     { Paradox }
    end;
  end;
end;

end.
