{
Moin all,

Janusz wrote:
>I use D1 and try to write my first applications. Is it possible to change
>column headers in DBGrid? Default values are field names and I must change
>them.

Try this:
Save your new columnnames in a separate file. It's a tip
Create an Table1.AfterOpen eventhandler
}

procedure Table1.AfterOpen(Dataset : TDataSet);
var
   TmpList : TStringList;
   iCnt    : Integer;
begin
  Try
    TmpList:=TStringList.Create;
    TmpList.LoadFromFile(The file with the new columnnanes);
    For iCnt:=0 to  TmpList.Count-1 do
      begin
      If iCnt<Table1.FieldCount then
        Table1.Fields[iCnt].DisplayLabel:=TmpList.Strings[iCnt];
      end;{For iCnt:=0 to  TmpList.Count-1 do}
  Finally
    TmpList.Free;
end;
