
Hope this helps:-

procedure CopyFile(varFrom: String; varTo: String; varDelete: Boolean);
{varFrom and varTo can contain path names}
begin
  AssignFile(varFromFile, varFrom);
  AssignFile(varToFile, varTo);
  Reset(varFromFile);
  try
    Rewrite(varToFile);
    try
      if LZCopy(TFileRec(varFromFile).Handle, TFileRec(varToFile).Handle)
          < 0 then
        begin
          varDesc := 'Failed to copy ' + varFrom + ' to ' + varTo;
          varErrors := True;
          Exit;
        end;
    finally
      CloseFile(varToFile);
    end;
  finally
    CloseFile(varFromFile);
  end;
  if varDelete then
    DeleteFile(varFrom);
end;


