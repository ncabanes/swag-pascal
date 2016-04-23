{
avictor@cs.sun.ac.za (Andrew Victor 93-42265)

I want this Program to change the hidden attributes of a directory.

 - Parameter FileName of Type String is the Name of the
 - subdirectory to hide or un-hide, it can include a path.
}


Procedure ChangeAttributes(FileName : String);
Var
  AttrFile  : File;
  Attribute : Word;
begin
  Assign(AttrFile, FileName);
  GetFAttr(AttrFile, Attribute);
  if not ((Attribute = $10) or (Attribute = $12)) then
  begin
    WriteLn;
    WriteLn('Not a Directory');
    WriteLn;
    Exit;
  end;
  if Attribute = $10 then
  begin
    SetFAttr(AttrFile, Hidden);
    WriteLn;
    WriteLn('Directory ', FileName, ' hidden.');
    WriteLn;
  end
  else
  begin
    SetFAttr(AttrFile, Directory and not Hidden);
    WriteLn;
    WriteLn('Directory ', FileName, ' shown.');
    WriteLn;
  end;
end;
