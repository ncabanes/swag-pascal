(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0007.PAS
  Description: About box in Windows
  Author: SCOTT SAMET
  Date: 08-27-93  22:10
*)

{
SCOTT SAMET

> I have a program that is always an icon, but I want to add an "about"
> command to it, to display a dialog box with info on the author and
> the program. Anyone know how to do this or where info on it can be found?

All system menu commands, even those you add, are returned as wm_SysCommand
messages.  You need to check wParam to see if it's one of yours, and if not,
pass it to DefWndProc.
}

Uses
  OWindows, WinProcs, WinTypes;

Const
  cm_About = 100;

Type
  TMyApp = Object(TApplication)
    Procedure InitMainWindow; Virtual;
  end;

  PMyWin = ^TMyWin;
  TMyWin = Object(TWindow)
    Procedure SetupWindow; Virtual;
    Procedure wmSysCommand(Var Msg : TMessage);
      virtual wm_First + wm_SysCommand;
    Procedure wmQueryOpen(Var Msg : TMessage);
      virtual wm_First + wm_QueryOpen;
  end;

Procedure TMyApp.InitMainWindow;
Begin
  MainWindow := New(PMyWin, Init (Nil, 'Test Window'));
  { This gives the window a system menu with Move, Switch and Close }
  PWindow(MainWindow)^.Attr.Style := ws_Overlapped or ws_Sysmenu;
end;

Procedure TMyWin.SetupWindow;
Var
  SysMenu: hMenu;
Begin
  SysMenu := GetSystemMenu(hWindow, False);
  AppendMenu(SysMenu, mf_Separator, 0, Nil);
  AppendMenu(SysMenu, mf_String, cm_About, '&About');
end;

Procedure TMyWin.wmQueryOpen(Var Msg : TMessage);
Begin
  { This keeps the window an icon at all times }
  Msg.Result := 0;
end;

Procedure TMyWin.wmSysCommand(Var Msg : TMessage);
Begin
  Case Msg.wParam of
    cm_About :
      MessageBox(hWindow, 'About Text', 'About Box', mb_ok)
    Else
      DefWndProc (Msg);
  end;
end;

Var
  App:  TMyApp;
Begin
  CmdShow := sw_ShowMinimized;
  App.Init ('Test');
  App.Run;
  App.Done;
end.

