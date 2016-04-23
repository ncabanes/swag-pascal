
{************************************************}
{                                                }
{   Turbo Pascal for Windows                     }
{   Tips & Techniques Demo Program               }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

program DblClick;

uses WinTypes, WinProcs, WObjects;

type
  TApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

  PMyWindow = ^TMyWindow;
  TMyWindow = Object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure Paint(PaintDC: HDC; var PaintInfo :TPaintStruct); virtual;
    function  GetClassName: PChar; virtual;
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    procedure DblClk(var Message: TMessage);
      virtual wm_lButtonDblClk;
  end;

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PMyWindow, Init(Nil, 'Double Click'));
end;

constructor TMyWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
end;
procedure TMyWindow.Paint(PaintDC: HDC; var PaintInfo :TPaintStruct);
begin
  TWindow.Paint(PaintDC, PaintInfo);
  TextOut(PaintDC, 30, 30, 'Please Double Click in the Client Region'#0,
    40);
end;

function TMyWindow.GetClassName: PChar;
begin
  GetClassName := 'DoubleClickDemoWindow';
end;

procedure TMyWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  TWindow.GetWindowClass(AWndClass);
  AWndClass.Style := AWndClass.Style or cs_DblClks;
end;

procedure TMyWindow.DblClk(var Message: TMessage);
begin
  MessageBox(HWindow, 'Double Click', 'Message', mb_Ok);
end;

var
  App: TApp;

begin
  App.Init('DblClick');
  App.Run;
  App.Done;
end.
