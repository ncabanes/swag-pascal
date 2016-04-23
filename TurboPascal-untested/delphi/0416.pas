From: baisa@tor.hookup.net (Brad Aisa)

In article <4uevrf$331@duke.telepac.pt>, delphinidae@mail.telepac.pt (Claudio Tereso) wrote: >i need to find the component index in the parent's order. >i tried to modify prjexp.dll but with success? >does any one have an idea? 

Here is a function that does this. It gets the parent control, and then iterates through its children, looking for a match. This has been tested and works.



--------------------------------------------------------------------------------


{ function to return index order of a component in its parent's
    component collection; returns -1 if not found or no parent }
function IndexInParent(vControl: TControl): integer;
var
  ParentControl: TWinControl;
begin
  {we "cousin" cast to get at the protected Parent property in base class }
  ParentControl := TForm(vControl.Parent);
  if (ParentControl <> nil) then
  begin
    for Result := 0 to ParentControl.ControlCount - 1 do
    begin
      if (ParentControl.Controls[Result] = vControl) then Exit;
    end;
  end;
  { if we make it here, then wasn't found, or didn't have parent}
  Result := -1;
end;
