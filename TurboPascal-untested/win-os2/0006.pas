{
MICHAEL A VINCZE

Below is an example I whipped up that shows how to vary the font in an edit control.
The method can be extended to other controls as well.  Two methods are presented:
using a stock object to get a fixed font, and using a created font.

I have not figured out how to get the colors to change though.
}

program Font_Ctl;

uses
  Win31, WinTypes, WinProcs,
  Objects, OWindows, ODialogs;

const
  ApplicationName : PChar = 'Font_Ctl';

  id_Edit1 = 201;
  id_Edit2 = 202;
  id_Edit3 = 203;

type
  TFont_CtlApplication = object (TApplication)
    procedure InitMainWindow; virtual;
  end;

  PFont_CtlWindow = ^TFont_CtlWindow;
  TFont_CtlWindow = object (TWindow)
    EditBox : PEdit;
    VarFont : HFont;
    FixFont : THandle;

    constructor Init(AParent : PWindowsObject; ATitle : PChar);
    procedure   SetupWindow; virtual;
    destructor  Done; virtual;
  end;

procedure TFont_CtlApplication.InitMainWindow;
begin
  MainWindow := New(PFont_CtlWindow, Init(nil, ApplicationName));
end;

constructor TFont_CtlWindow.Init(AParent : PWindowsObject; ATitle : PChar);
begin
  inherited Init(AParent, ATitle);
    EditBox := New(PEdit, Init (@Self, id_Edit1, 'EditBox 1 (normal)',
                10, 10, 500, 30, $FF, False));
    EditBox := New(PEdit, Init (@Self, id_Edit2, 'EditBox 2 (fixed font)',
                10, 50, 500, 30, $FF, False));
    EditBox := New(PEdit, Init (@Self, id_Edit3, 'EditBox 3 (variable font)',
                10, 90, 500, 30, $FF, False));
    FixFont := GetStockObject (System_Fixed_Font);

    VarFont := CreateFont(20, 20, 0, 0, fw_DontCare, 0, 0, 0,
                          Default_CharSet, Out_Default_Precis,
                          Clip_Default_Precis, Default_Quality,
                          Variable_Pitch or ff_DontCare, nil);
end;

destructor TFont_CtlWindow.Done;
begin
  inherited Done;
  DeleteObject(VarFont);
end;

procedure TFont_CtlWindow.SetupWindow;
begin
  inherited SetupWindow;
  SendMessage(GetDlgItem (HWindow, id_Edit2), wm_SetFont, FixFont, 1);
  SendMessage(GetDlgItem (HWindow, id_Edit3), wm_SetFont, VarFont, 1);
end;

var
  Application : TFont_CtlApplication;

begin
  Application.Init (ApplicationName);
  Application.Run;
  Application.Done;
end.
