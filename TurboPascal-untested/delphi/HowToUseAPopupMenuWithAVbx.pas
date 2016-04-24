(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0109.PAS
  Description: How to use a popup menu with a VBX
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
Q:  I want to be able to right click on my VBX and have     a
popup menu display.  When I use a popup menu for the form, it
shows no matter where I right click.  I want to just have it
popup for right clicks on the vbx.

How do I trap for that?

A:  Here it is:
}

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if button = mbRight then
    with (Sender AS TControl) do
      with ClientToScreen(Point(X,Y)) do
      begin
        PopupMenu1.PopupComponent := TComponent(Sender);
        PopupMenu1.Popup(X,Y);
      end;
end;

Note: The form's PopupMenu property must be empty, or it will popup
from everywhere.  If you want the form to be the only place showing
the popup, place this method on the form's OnMouseDown event.  If
you want the VBX to be the only place, then place it on the VBX's
OnMouseDown event, etc.

