(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0322.PAS
  Description: Re: EmptyTable Generic procedure
  Author: HUTTEMAN <HUTTEMAN@PERIGEE.NET>
  Date: 08-30-97  10:09
*)


what you need to do is create a new TTable object inside of your procedure.
The following code will do what you need:

procedure TForm1.EmptyTable(const DbName, TbName: string);
begin
  if MessageDlg('Empty ' + TbName + ' Table? Are you sure?', mtConfirmation,
                [mbYes, mbNo], 0) = mrYes then begin
    with TTable.Create(nil) do try
      DatabaseName := DbName;
      TableName := TbName;
      repeat
        try
          EmptyTable;
          ShowMessage(TbName + ' Table Empty!');
          exit;
        except
          on EDatabaseError do begin
            { Ask if it is OK to retry }
            if MessageDlg('EmptyTable failed',mtError, [mbAbort, mbRetry], 0)
                          <> mrRetry then begin
              raise; { If not, reraise to abort }
            end
            { Otherwise resume the repeat loop }
          end
        end;
      until false;
    finally
      Free
    end;
  end;
end;

