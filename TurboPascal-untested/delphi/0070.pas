{usual stuff at the top of the project source file
var hwnd: Word;
 
begin
  if hPrevInst = 0 then
  begin
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end
  else
  begin
    hwnd := FindWindow('TForm1', nil);
    if (not IsWindowVisible(hwnd)) then
    begin
      ShowWindow(hwnd, sw_ShowNormal);
      PostMessage(hwnd, wm_User, 0, 0);
    end;
    else
      SetWindowPos(hwnd, HWND_TOP, 0,0,0,0,
        SWP_NOSIZE or SWP_NOMOVE);
  end;
end.
====================================================

In the form's PAS file add a message response function for the wm_User
message.

====================================================
{in the form declaration}
public
  procedure WMUser(var msg: TMessage); message wm_User;

{in the implementation section}
procedure TForm1.WMUser(var msg: TMessage);
begin
  Application.Restore;
end;
