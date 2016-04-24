(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0297.PAS
  Description: How to disable Start menu
  Author: CHANDRAMDE@USA.NET
  Date: 08-30-97  10:08
*)


For some reasons, we don't want our program to be disturbed by any 
program/window. Even we disable all top-level window including Win95 
Taskbar, Start Menu still appear when user press Start Menu Key on keyboard.
Well, here's a trick to avoid user to start a program from Start Menu.

Procedure TForm1.Timer1Timer(Sender : TObject);
Var
   desktop, tophwnd : HWND;
Begin
   desktop := GetDesktopWindow();
   tophwnd := GetTopWindow(desktop);
   if tophwnd <> Form1.Handle then SetForegroundWindow(Form1.Handle);
End;

{Make sure Timer.Enabled is TRUE and Interval = 1}

It's not the only way to do it, but it works.

Hello, Gayle.
My name's Chandra. I'm Indonesian. ;=)
Here's my little procedure to hide Start Button :

	Procedure HideStartButton;
	Var
	   taskbarhandle,
	   buttonhandle : HWND;
	begin
	   taskbarhandle := FindWindow('Shell_TrayWnd', nil);
	   buttonhandle := GetWindow(taskbarhandle, GW_CHILD);
	   ShowWindow(buttonhandle, SW_HIDE);
	end;

*Replace SW_HIDE with SW_RESTORE to show it back.

Is anyone there know how to put an image or text on taskbar Win95?
Please, post it to my address. (chantit@hotmail.com)

