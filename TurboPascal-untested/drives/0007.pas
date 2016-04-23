Program DriveID;
Uses
  Dos;
Const
  First : Boolean = True;
Var
  Count : Integer;
begin
  Write('You have the following Drives: ');
  For Count := 3 to 26 do
  if DiskSize(Count) > 0 then
  begin
    if not First then
      Write(', ');
    First := False;
    Write(UpCase(Chr(ord('a') - 1 + Count)),':')
  end;
  WriteLn;
end.
