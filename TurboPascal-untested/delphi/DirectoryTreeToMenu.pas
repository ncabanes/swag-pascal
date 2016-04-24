(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0370.PAS
  Description: Directory Tree to Menu
  Author: VINCENT CROQUETTE
  Date: 01-02-98  07:33
*)


Procedure FillTreeMenu(MenuItem : TMenuItem;const stPathName : String);
var SearchRec : TSearchRec;
boTrouve : Boolean;
NewMenuItem : TMenuItem;
Begin
  boTrouve :=  (FindFirst(stPathName + '\*.*', faDirectory, SearchRec) =  0);
  While (boTrouve) Do
  Begin
  	If (SearchRec.Name[1] <> '.') Then
    Begin
    	If (DirectoryExists(stPathName + '\' + SearchRec.Name)) Then
      Begin
      	NewMenuItem :=  TMenuItem.Create(MenuItem.Owner);
        NewMenuItem.Caption :=  SearchRec.Name;
        MenuItem.Add(NewMenuItem);
        FillTreeMenu(MenuItem.Items[MenuItem.Count - 1], stPathName + = '\' + SearchRec.Name);
    	End;
    End;
    boTrouve :=  (FindNext(SearchRec) =  0);
  End;
  FindClose(SearchRec);
End;

procedure Tfrm_CassisComponentsTestForm.bbtn_1Click(Sender: TObject);
begin
	FillTreeMenu(mnu_1.Items[0], 'c:');
end;

mnu_1 is your main menu on your form for which U must have at least 1 =
MenuItem (Directory for instance).

Assume that FileCtrl is in the uses...

Vincent Croquette


