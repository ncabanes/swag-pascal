(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0426.PAS
  Description: Using the Multi Select option of a DBGRI
  Author: MIKE TANCSA
  Date: 01-02-98  07:34
*)

mike@sentex.net (Mike Tancsa)

There is an example in the Delphi TIs... Have a look at

http://loki.borland.com/winbin/bds.exe?getdoc+2976+Delphi 



--------------------------------------------------------------------------------


{*
   This example iterates through the selected rows
   of the grid and displays the second field of
   the dataset.

   The Method DisableControls is used so that the
   DBGrid will not update when the dataset is changed.
   The last position of the dataset is saved as
   a TBookmark.

   The IndexOf method is called to check whether or
   not the bookmark is still existent.
   The decision of using the IndexOf method rather
   than the Refresh method should be determined by the
   specific application.
*}

procedure TForm1.SelectClick(Sender: TObject);
var
  x: word;
  TempBookmark: TBookMark;
begin
  DBGrid1.Datasource.Dataset.DisableControls;
  with DBgrid1.SelectedRows do
  if Count  0 then
  begin
    TempBookmark:= DBGrid1.Datasource.Dataset.GetBookmark;
    for x:= 0 to Count - 1 do
    begin
      if IndexOf(Items[x])  -1 then
      begin
        DBGrid1.Datasource.Dataset.Bookmark:= Items[x];
        showmessage(DBGrid1.Datasource.Dataset.Fields[1].AsString);
      end;
    end;
  end;
  DBGrid1.Datasource.Dataset.GotoBookmark(TempBookmark);
  DBGrid1.Datasource.Dataset.FreeBookmark(TempBookmark);
  DBGrid1.Datasource.Dataset.EnableControls;
end;

