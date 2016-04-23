
> I tried : Table1BlobField1.Assign(Memo1.lines) but this
>  won't work. Get an error message telling me that this
>  field is not a BLOB.

I had found this snip of code in a mag. some time back.  It seems to
work well.  It uses a TStringList which should work with the TMemo.

procedure TMain1.ListBoxToDBMemo(DestTable: TTable; Destfield: String;
SourceList: TStringList);
var
BlobStream1: TBlobStream;
begin
BlobStream1:=TBlobStream.Create(TMemoField(DestTable.FieldByName(
DestField)),bmWrite);
try
   BlobStream1.Write(SourceList.GetText^,StrLen(SourceList.GetText));
   finally
      BlobStream1.free;
   end;
end;

procedure TMain1.DBMemoToListBox(SourceTable: TTable; SourceField:
String; DestList: TStringList);
var
BlobStream1:  TBlobStream;
begin
BlobStream1:=TBlobStream.Create(TMemoField(SourceTable.FieldByName(
SourceField)),bmRead);
try
   DestList.LoadFromStream(BlobStream1);
   finally
     BlobStream1.free;
   end;
end;
