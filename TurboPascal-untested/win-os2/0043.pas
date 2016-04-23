{
From: wieger@wsintt02.info.win.tue.nl (Wieger Wesselink)

I have written the following program that contains a wordwrap editor that
inherits from TFileWindow. The wordwrapping is achieved by modifying the
Style field of the Editor-object in TFileWindow. This works fine except
for one thing: saving the contents of the editor goes wrong. Sometimes the
last line is truncated. Can anyone tell me how to fix this problem?
Thanks in advance,

}
program WordWrap;

uses WinTypes, OWindows, OStdWnds;

type
  PMyFileWindow = ^TMyFileWindow;
  TMyFileWindow = object(TFileWindow)
    constructor Init(AParent: PWindowsObject; ATitle, AFileName: PChar);
  end;

  TMyApplication = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

constructor TMyFileWindow.Init(AParent: PWindowsObject; ATitle,
        AFileName: PChar);
begin
  inherited Init(AParent, ATitle, AFileName);
  with Editor^.Attr do begin
    Style := Style and not (es_AutoHScroll or ws_HScroll);
  end;
end;

procedure TMyApplication.InitMainWindow;
begin
  MainWindow := New(PMyFileWindow, Init(nil, 'WordWrapper', nil));
end;

var
  MyApp: TMyApplication;

begin
  MyApp.Init('WordWrap');
  MyApp.Run;
  MyApp.Done;
end.

