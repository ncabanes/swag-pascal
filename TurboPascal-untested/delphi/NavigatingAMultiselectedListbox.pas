(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0187.PAS
  Description: Navigating a Multiselected Listbox
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)


This example shows a message for every element in a listbox that
has been selected by the user.

procedure TForm1.Button1Click(Sender: TObject);
var
  Loop: Integer;
begin
  for Loop := 0 to Listbox1.Items.Count - 1 do begin
    if Listbox1.Selected[Loop] then
      ShowMessage(Listbox1.Items.Strings[Loop]);
  end;
end;

