(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0204.PAS
  Description: Adding a Stringlist to a Combo Box
  Author: MARK BRACEY
  Date: 11-29-96  08:17
*)

{
I have several combo boxes that I wish to populate at the form creation.
The problem is that I keep getting duplicate values.
}

var
 SList : TStringList;
begin
 SList := TStringList.Create;
 SList.sorted := True;
 SLIST.Duplicates := dupIgnore;
 SList.Add('Dog');  {Only one 'Dog' goes in the list}
 SList.Add('cat');
 SList.Add('Dog');
 ComboBox1.Items.Assign(SList);
 SList.free;
end;

