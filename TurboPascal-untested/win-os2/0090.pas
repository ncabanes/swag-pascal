Program MenuAdd;
{
 provided as is, no guarantees, no support

 Question 1: My_ByPosition locates items by position from
             the top of the menu, mf_ByCommand finds an
             idem uses the items id.

 Question 2: These commands start a new column, the one
             separated by a bar the other not separated
             by a bar. If you are not in a PopUpMenu then
             it places the item on a new line.


}

Uses
  WinProcs,
  WinTypes,
  OWindows;

Const
  cmEnable     = 101;
  cmColor      = 102;
  cmBlackWhite = 103;
  cmAddCommand = 104;

Type
  PMyWindow = ^TMyWindow;
  TMyWindow = Object(TWindow)
      mh: HMenu;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    procedure Enable(var Msg: TMessage);
      virtual cm_First + cmEnable;
    procedure Color(var Msg: TMessage);
      virtual cm_First + cmColor;
    procedure BlackWhite(var Msg: TMessage);
      virtual cm_First + cmBlackWhite;
    procedure AddCommand(var Msg: TMessage);
      virtual cm_First + cmAddCommand;
    procedure SetUpWindow; virtual;
    procedure WMLButtonDown(var Msg: TMessage);
      virtual wm_First + wm_LButtonDown;
  end;

  TMyApp = Object(TApplication)
    procedure InitMainWindow; virtual;
  end;

constructor TMyWindow.Init(AParent: PWindowsObject; AName: PChar);
begin
  TWindow.Init(AParent, AName);
  Attr.Menu := CreateMenu;
end;


procedure TMyWindow.SetUpWindow;
begin
  TWindow.SetUpWindow;
  mh := CreatePopUpMenu;
  AppendMenu(Attr.Menu, mf_PopUp, Mh, '&Commands');
  AppendMenu(Mh, mf_String, cmEnable, '&Enable Options');
  AppendMenu(Mh, mf_Separator, 0, Nil);
  AppendMenu(Mh, mf_String, cmColor, '&Color');
  AppendMenu(Mh, mf_String, cmBlackWhite, '&Black/White');
  AppendMenu(Mh, mf_Separator, 0, Nil);
  AppendMenu(Mh, mf_String, cmAddCommand, 'Add Command');
  EnableMenuItem(Mh, 2, mf_ByPosition or mf_Grayed);
  EnableMenuItem(Mh, 3, mf_ByPosition or mf_Grayed);
  EnableMenuItem(Mh, 5, mf_ByPosition or mf_Grayed);
  DrawMenuBar(HWindow);
end;

procedure TMyWindow.WMLButtonDown(var Msg: TMessage);
begin
  MessageBeep(0);
  HiLiteMenuItem(HWindow, Attr.Menu, 0, mf_ByPosition or mf_HiLite);

  SetFocus(Attr.Menu);
end;

procedure TMyWindow.Enable(var Msg: TMessage);
begin
  EnableMenuItem(Mh, 2, mf_ByPosition or mf_Enabled);
  EnableMenuItem(Mh, 3, mf_ByPosition or mf_Enabled);
  EnableMenuItem(Mh, 5, mf_ByPosition or mf_Enabled);
  DeleteMenu(Mh, 0, mf_ByPosition);
  DeleteMenu(Mh, 0, mf_ByPosition);
  CheckMenuItem(Mh, cmColor, mf_ByCommand or mf_Checked);
end;

procedure TMyWindow.Color(var Msg: TMessage);
var
  State: Word;
begin
  State := GetMenuState(Mh, cmColor, mf_ByCommand);
  if (State and mf_Checked) = mf_Checked then
    CheckMenuItem(Mh, cmColor, mf_ByCommand or mf_UnChecked)
  else
    CheckMenuItem(Mh, cmColor, mf_ByCommand or mf_Checked);

  State := GetMenuState(Mh, cmBlackWhite, mf_ByCommand);
  if (State and mf_Checked) = mf_Checked then
    CheckMenuItem(Mh, cmBlackWhite, mf_ByCommand or mf_UnChecked)
end;

procedure TMyWindow.BlackWhite(var Msg: TMessage);
var
  State: Word;
begin
  State := GetMenuState(Mh, cmBlackWhite, mf_ByCommand);
  if (State and mf_Checked) = mf_Checked then
    CheckMenuItem(Mh, cmBlackWhite, mf_ByCommand or mf_UnChecked)
  else
    CheckMenuItem(Mh, cmBlackWhite, mf_ByCommand or mf_Checked);

  State := GetMenuState(Mh, cmColor, mf_ByCommand);
  if (State and mf_Checked) = mf_Checked then
    CheckMenuItem(Mh, cmColor, mf_ByCommand or mf_UnChecked)
end;

procedure TMyWindow.AddCommand(var Msg: TMessage);
begin
  InsertMenu(Mh, cmColor, mf_String, cmEnable, '&Enable Options');
  InsertMenu(Mh, cmColor, mf_Separator, 0, Nil);
  EnableMenuItem(Mh, 2, mf_ByPosition or mf_Grayed);
  EnableMenuItem(Mh, 3, mf_ByPosition or mf_Grayed);
  EnableMenuItem(Mh, 5, mf_ByPosition or mf_Grayed);
  CheckMenuItem(Mh, cmColor, mf_ByCommand or mf_UnChecked);
  CheckMenuItem(Mh, cmBlackWhite, mf_ByCommand or mf_UnChecked);
end;

procedure TMyApp.InitMainWindow;
begin
  MainWindow := New(PMyWindow, Init(nil, 'MenuAdd'));
end;

var
  A: TMyApp;
begin
  A.Init('Ph2SecA');
  A.Run;
  A.Done;
end.