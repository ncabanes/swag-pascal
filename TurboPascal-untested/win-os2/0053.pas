{************************************************}
{                                                }
{   Turbo Pascal for Windows                     }
{   Tips & Techniques Demo Program               }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program EditControl;

uses WinTypes, WinProcs, WObjects, Strings;

type
TApp = object(TApplication)
  procedure InitMainWindow; virtual;
end;

PMyEdit = ^TMyEdit;
TMyEdit = object(TEdit)
  procedure WMKeyDownProc(var Message: TMessage);
    virtual WM_KeyDown;
end;

PMyWindow = ^TMyWindow;
TMyWindow = Object(TWindow)
  MyEdit: PMyEdit;
  constructor Init(AParent:PWindowsObject; ATitle: PChar);
  procedure SetUpWindow; virtual;
end;

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PMyWindow, Init(Nil, 'Edit Control'));
end;

{ This procedure will look the return key and not allow the Default
  Window procedure to proccess them. }
procedure TMyEdit.WMKeyDownProc(var Message: TMessage);
var
  Focus: THandle;
begin
  if Message.wParam = vk_Return then
  begin
    Focus := GetFocus;
    MessageBox(HWindow, 'The Return Key Was Pressed','Attention', mb_Ok);
    SetFocus(Focus);
  end
  else
    DefWndProc(Message);     {process message normally}
end;

constructor TMyWindow.Init(AParent:PWindowsObject; ATitle:PChar);
const
  Text: PChar = 'Press Return';
begin
  TWindow.Init(AParent, ATitle);
  MyEdit := New(PMyEdit, Init(@Self, 0, Text, 20, 30, 150, 30, 40, False));
end;

procedure TMyWindow.SetUpWindow;
begin
  TWindow.SetUpWindow;
  SetFocus(MyEdit^.HWindow);
end;

var
  App: TApp;
begin
  App.Init('Editing');
  App.Run;
  App.Done;
end.
