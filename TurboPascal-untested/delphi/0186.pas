// ================================================================================================
// Sizes the specified form perfectly in the Win95/NT4 client area, outside the taskbar, regardless
// of the taskbar's size or location.  Freeware by Peter M. Jagielski.  Works best if called from
// your main form's FormCreate - just pass this proc the name of your main form.  Be sure to
// include the Windows unit in your USES clause.
// ================================================================================================
procedure SizeForWin95(MyForm: TForm);
var
  TaskBarHandle: HWnd;    // Handle to the Win95 Taskbar
  TaskBarCoord:  TRect;   // Coordinates of the Win95 Taskbar
  CxScreen,               // Width of screen in pixels
  CyScreen,               // Height of screen in pixels
  CxFullScreen,           // Width of client area in pixels
  CyFullScreen,           // Heigth of client area in pixels
  CyCaption:     Integer; // Height of a window's title bar in pixels
begin
  TaskBarHandle := FindWindow('Shell_TrayWnd',Nil); // Get Win95 Taskbar handle
  if TaskBarHandle = 0 then // We're running Win 3.x or WinNT w/o Win95 shell, so just maximize
    MyForm.WindowState := wsMaximized
  else // We're running Win95 or WinNT w/Win95 shell
    begin
      MyForm.WindowState := wsNormal;
      GetWindowRect(TaskBarHandle,TaskBarCoord);        // Get coordinates of Win95 Taskbar
      CxScreen        := GetSystemMetrics(SM_CXSCREEN); // Get various screen dimensions and set form's width/height
      CyScreen        := GetSystemMetrics(SM_CYSCREEN);
      CxFullScreen    := GetSystemMetrics(SM_CXFULLSCREEN);
      CyFullScreen    := GetSystemMetrics(SM_CYFULLSCREEN);
      CyCaption       := GetSystemMetrics(SM_CYCAPTION);
      MyForm.Width    := CxScreen - (CxScreen - CxFullScreen) + 1;
      MyForm.Height   := CyScreen - (CyScreen - CyFullScreen) + CyCaption + 1;
      MyForm.Top      := 0;
      MyForm.Left     := 0;
      MyForm.Position := poDefault;
      if (TaskBarCoord.Top = -2) and (TaskBarCoord.Left = -2) then // Taskbar on either top or left
        if TaskBarCoord.Right > TaskBarCoord.Bottom then // Taskbar on top
          MyForm.Top  := TaskBarCoord.Bottom
        else // Taskbar on left
          MyForm.Left := TaskBarCoord.Right;
    end;
end;
