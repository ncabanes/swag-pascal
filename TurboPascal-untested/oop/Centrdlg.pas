(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0001.PAS
  Description: CENTRDLG.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
 > The title says it all. What is the accepted way of bringing up a dialog
 > box in the centre of the screen.
}
Procedure CenterDlg (HWindow : HWnd);
Var
  R       : TRect;
  X       : Integer;
  Y       : Integer;
  Frame   : Integer;
  Caption : Integer;
begin
  Frame   := GetSystemMetrics (sm_CxFrame) * 2;
  Caption := GetSystemMetrics (sm_CyCaption);
  GetClientRect (HWindow, R);
  With R do
    begin
    X := ((GetSystemMetrics (sm_CxScreen) - (Right - Left)) div 2);
    Y := ((GetSystemMetrics (sm_CyScreen) - (Bottom - Top)) div 2);
    MoveWindow (HWindow, X, Y - ((Caption + Frame) div 2),
      Right + Frame, Bottom + Frame + Caption, False);
    end;
  end;
end;
{
 Execute this Function from the dialog's SetupWindow method.
}
