(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0043.PAS
  Description: Moving to a tab by name on a TabSet
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:50
*)


Moving to a page by name on a TabSet.

Place a Tabset(TabSet1) and an Edit (Edit1) on
your form. Change the Tabset's Tabs Property in
the String List Editor to include 4 Tabs:
             Hello, 
             World, 
             Of,
             Delphi,
   
Change Edit1's onChange event to:

procedure TForm1.Edit1Change(Sender: TObject);
var
  I : Integer;
begin
  for  I:= 0 to tabset1.tabs.count-1 do
   if  edit1.text = tabset1.tabs[I] then
     tabset1.tabindex:=I;

end;

If You type any of the Tabs names in edit1 it 
will focus on the appropriate tab.


