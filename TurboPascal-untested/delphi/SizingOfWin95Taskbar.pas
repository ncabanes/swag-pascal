(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0097.PAS
  Description: Sizing of WIN95 Taskbar
  Author: PETER JAGIELSKI
  Date: 02-21-96  21:04
*)

{
  Pop this procedure into your main form's unit and call it from your
  FormCreate procedure.  Under Win95 or WinNT w/Win95 shell, your main form
  will fit perfectly in the client area of the screen in a wsNormal state.
  The only parm for the proc is the name of your main form.  If Win95 or
  WinNT/wWin95 shell is NOT running, your form will open in a wsMaximized
  state.

  This may or may not be the only way to accomplish this task, but it works.

  Freeware. No guarantees, promises or responsibility. Use to your heart's
  content.  Just give me credit: Peter M. Jagielski
                                 73737,1761@compuserve.com
}

procedure SizeForTaskBar(MyForm: TForm);
var
  TaskBarHandle: HWnd;    { Handle to the Win95 Taskbar }
  TaskBarCoord:  TRect;   { Coordinates of the Win95 Taskbar }
  CxScreen,               { Width of screen in pixels }
  CyScreen,               { Height of screen in pixels }
  CxFullScreen,           { Width of client area in pixels }
  CyFullScreen,           { Heigth of client area in pixels }
  CyCaption:     Integer; { Height of a window's title bar in pixels }
begin
  TaskBarHandle := FindWindow('Shell_TrayWnd',Nil); { Get Win95 Taskbar handle }
  if TaskBarHandle = 0 then { We're running Win 3.x or WinNT w/o Win95 shell, so just maximize }
    MyForm.WindowState := wsMaximized
  else { We're running Win95 or WinNT w/Win95 shell }
    begin
      MyForm.WindowState := wsNormal;
      GetWindowRect(TaskBarHandle,TaskBarCoord);      { Get coordinates of Win95 Taskbar }
      CxScreen      := GetSystemMetrics(SM_CXSCREEN); { Get various screen dimensions and set form's width/height }
      CyScreen      := GetSystemMetrics(SM_CYSCREEN);
      CxFullScreen  := GetSystemMetrics(SM_CXFULLSCREEN);
      CyFullScreen  := GetSystemMetrics(SM_CYFULLSCREEN);
      CyCaption     := GetSystemMetrics(SM_CYCAPTION);
      MyForm.Width  := CxScreen - (CxScreen - CxFullScreen) + 1;
      MyForm.Height := CyScreen - (CyScreen - CyFullScreen) + CyCaption + 1;
      MyForm.Top    := 0;
      MyForm.Left   := 0;
      if (TaskBarCoord.Top = -2) and (TaskBarCoord.Left = -2) then { Taskbar on either top or left }
        if TaskBarCoord.Right > TaskBarCoord.Bottom then { Taskbar on top }
          MyForm.Top  := TaskBarCoord.Bottom
        else { Taskbar on left }
          MyForm.Left := TaskBarCoord.Right;
    end;
end;
