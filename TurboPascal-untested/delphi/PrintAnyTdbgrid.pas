(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0366.PAS
  Description: Print any TDBGrid
  Author: MIKE KELLY
  Date: 01-02-98  07:33
*)


QuickReport includes the TQRListBuilder, a component for dynamically
creating a simple list report with only a few lines of code. You can
assign the report's dataset to your grid's datasource.dataset and have a
report that displays the same data as your grid:


procedure TformMain.ToolButton1Click(Sender: TObject);
var
  aReport : TQuickRep;
begin
  with TQRListBuilder.Create(Self) do
    try
      DataSet := DBGrid1.DataSource.DataSet;
      Active := True;
      try
        aReport := FetchReport;
        aReport.Preview;
      finally
       aReport.Free;
    end;
  finally
    Free;
  end;
end;

