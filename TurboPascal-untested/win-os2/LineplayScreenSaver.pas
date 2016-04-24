(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0080.PAS
  Description: Lineplay Screen Saver
  Author: MARIO VAN DEN ANCKER
  Date: 11-22-95  13:28
*)


Program LinePlayScreensaver;

{ LinePlay.pas - by Mario van den Ancker
                 E-Mail: mario@astro.uva.nl
                 WWW: http://www.astro.uva.nl/mario/
  Windows 3.x screen saver in TPW. Fully configurable via control panel and
  with password support. Requires saver.pas and lineplay.res, included below.
  lineplay.res is encoded with xx3402. Compile this program, copy the .exe
  file to your windows directory with the extension .scr, and the screen
  saver will show up in the desktop section of control panel.
  Donated to the public domain 11/95. }

uses Wintypes, WinProcs, WObjects, Strings, Saver;

{$D SCRNSAVE Line Play}     { This is the name that will show up in control panel. }
{$R LinePlay.Res}

const
  cm_About         = 103;
  cm_SetPassword   = 105;

  id_Color         = 107;
  id_PWProtected   = 104;
  id_RadioColFixed = 121;
  id_RadioColRnd   = 122;
  id_NumLines      = 101;
  id_TimerInterval = 120;

  White        = $00FFFFFF;
  Black        = $00000000;
  LightGray    = $00C0C0C0;
  DarkGray     = $00808080;
  Cyan         = $00FFFF00;
  Magenta      = $00FF00FF;
  Yellow       = $0000FFFF;
  Red          = $000000FF;
  Green        = $0000FF00;
  Blue         = $00FF0000;
  LightBlue    = $00800000;
  LightCyan    = $00808000;
  LightMagenta = $00800080;
  Brown        = $00008080;
  LightRed     = $00000080;
  LightGreen   = $00008000;
  NColors = 16;
  StdColors : array[1..NColors] of TColorRef =
   (White, Black, LightGray, DarkGray, Cyan, Magenta, Yellow, Red, Green,
    Blue, LightBlue, LightCyan, LightMagenta, Brown, LightRed, LightGreen);

  MaxLines = 25;      { Maximum number of bouncing lines }
  id_Timer = 1;


type
  TSaveApplication = Object(TApplication)
    procedure InitMainWindow; virtual;
    destructor Done; virtual;
   end;

  { Create TConfigDialog, a TDlgWindow descendant. }
  PSetPasswordDialog = ^TSetPasswordDialog;
  TSetPasswordDialog = Object(TDlgWindow)
    procedure Ok(var Msg: TMessage);
      virtual id_First + id_Ok;
  end;

  { Create TConfigDialog, a TDialog descendant. }
  PConfigDialog = ^TConfigDialog;
  TConfigDialog = Object(TDlgWindow)
    NumLines, TimerInterval: Integer;
    Color: TColorRef;
    PWProtected, RndColor: Boolean;
    Password: TPasswordString;
    procedure SetupWindow; virtual;
    procedure cmAbout(var Msg: Tmessage);
      virtual id_First + cm_About;
    procedure cmSetPassword(var Msg: Tmessage);
      virtual id_First + cm_SetPassword;
    procedure wmDrawItem(var Msg : TMessage);
      virtual wm_First + wm_DrawItem;
    procedure wmMeasureItem(var Msg : TMessage);
      virtual wm_First + wm_MeasureItem;
    procedure Ok(var Msg: TMessage);
      virtual id_First + id_Ok;
  end;

  { Create TSaveWindow, a TScrSavWindow descendant. }
  PSaveWindow = ^TSaveWindow;
  TSaveWindow = Object(TScrnSavWindow)
    PosX, PosY: array [1..MaxLines, 1..2] of Integer;
    VelX, VelY: array [1..2] of Integer;
    NumLines, TimerInterval: Integer;
    Color: TColorRef;
    RndColor: Boolean;
    MaxX, MaxY, MidX, MidY: Integer;
    constructor Init(aParent: PWindowsObject; aTitle: PChar);
    procedure SetupWindow; virtual;
    destructor Done; virtual;
    procedure wmTimer(var Msg: TMessage);
      virtual wm_First + wm_Timer;
  end;


function GetPrivateProfileLongInt(AppName, KeyName: PChar; Default: LongInt; FileName: 
PChar): LongInt;
var
  Str1: Array[0..31] of Char;
  ScrLongInt: LongInt;
  ErrCode: Integer;
begin
  GetPrivateProfileString(AppName, KeyName, '', Str1, SizeOf(Str1), FileName);
  Val(Str1, ScrLongInt, ErrCode);
  if (ErrCode <> 0) then ScrlongInt := Default;
  GetPrivateProfileLongInt := ScrLongInt;
end;

{ --------TSaveApplication methods------------------ }
procedure TSaveApplication.InitMainWindow;
begin
 if (ParamStr(1) <> '/c') and (ParamStr(1) <> '-c') then
   MainWindow:= New(PSaveWindow, Init(nil, 'ScreenSaver'))
 else
   MainWindow := New(PConfigDialog, Init(Nil, 'SETUP'));
end;

destructor TSaveApplication.Done;
begin
  TApplication.Done;
end;


{ --------TConfigDialog methods------------------ }
procedure TConfigDialog.wmDrawItem(var Msg: TMessage);
var
  Brush: HBrush;
begin
  with PDrawItemStruct(Msg.lParam)^ do
  begin
    if (CtlType = odt_ComboBox) then
    begin
      if ((ItemAction and oda_DrawEntire) <> 0) or
         ((ItemAction and oda_Select) <> 0) then
      begin
        Brush := CreateSolidBrush(ItemData);
        FillRect(hDC, rcItem, Brush);
        DeleteObject(Brush);
      end;
      if ((ItemState and ods_Focus) <> 0) or
         ((ItemState and ods_Selected) <> 0) then
      begin
        InflateRect(rcItem, -2, -2);
        DrawFocusRect(hDC, rcItem);
      end;
    end;
  end;
end;

procedure TConfigDialog.wmMeasureItem(var Msg: TMessage);
begin
  PMeasureItemStruct(Msg.lParam)^.ItemHeight := 16;
end;

procedure TConfigDialog.SetupWindow;

procedure SetupColors(ID: Integer; Color: TColorRef);
var
  i, Sel: Integer;
begin
  Sel := -1;
  for i := 1 to NColors do
  begin
    SendDlgItemMsg(ID, cb_AddString, 0, StdColors[i]);
    if (StdColors[i] = Color) then Sel := pred(i);
  end;
  if (Sel = -1) then
  begin
    SendDlgItemMsg(ID, cb_AddString, 0, Color);
    Sel := NColors;
  end;
  SendDlgItemMsg(ID, cb_SetCurSel, Sel, 0);
end;

begin
  TDlgWindow.SetUpWindow;

  NumLines := GetPrivateProfileInt('Screen Saver.Line Play', 'Number of Lines', 10, 
'CONTROL.INI');
  Color := GetPrivateProfileLongInt('Screen Saver.Line Play', 'Drawing Color', Cyan, 
'CONTROL.INI');
  RndColor := (GetPrivateProfileInt('Screen Saver.Line Play', 'Random Color', 1, 'CONTROL.INI') 
= 1);
  TimerInterval := GetPrivateProfileInt('Screen Saver.Line Play', 'Timer Interval', 30, 
'CONTROL.INI');
  PWProtected := (GetPrivateProfileInt('Screen Saver.Line Play', 'PWProtected', 0, 
'CONTROL.INI') = 1);
  GetPrivateProfileString('ScreenSaver', 'Password', '', Password, SizeOf(Password), 
'CONTROL.INI');

  SetDlgItemInt(HWindow, id_NumLines, NumLines, True);
  SetupColors(id_Color, Color);
  if RndColor then
    CheckRadioButton(HWindow, id_RadioColFixed, id_RadioColRnd, id_RadioColRnd)
  else
    CheckRadioButton(HWindow, id_RadioColFixed, id_RadioColRnd, id_RadioColFixed);
  SetDlgItemInt(HWindow, id_TimerInterval, TimerInterval, True);
  if PWProtected then
    CheckDlgButton(HWindow, id_PWProtected, 1)
  else
    CheckDlgButton(HWindow, id_PWProtected, 0);
end;

{ Respond to pressing About button. }
procedure TConfigDialog.cmAbout(var Msg: TMessage);
begin
  Application^.ExecDialog(new(PDialog, Init(@Self, 'ABOUT')));
end;

{ Respond to pressing Set Password button. }
procedure TConfigDialog.cmSetPassword(var Msg: TMessage);
begin
  if (StrComp(Password, '') = 0) then
    Application^.ExecDialog(new(PSetPasswordDialog, Init(@Self, 'CHPWD2')))
  else
    Application^.ExecDialog(new(PSetPasswordDialog, Init(@Self, 'CHPWD')));
end;

{ Gets an integer value from a input dialog. If the input text
  is not a number or the input number is outside a specified range
  it puts up an errorbox and return false for NoErrors. InputNr is
  not changed when an error has occured. }
procedure GetDlgInt(HWindow: HWnd; ThisID: Integer; MinVal, MaxVal: Integer;
                    var InputNr: Integer; var NoErrors: Boolean);
var
  Str1, Str2: Array[0..12] of Char;
  CS: array[0..80] of Char;
  ErrCode, ScrInt: Integer;
begin
  GetDlgItemText(HWindow, ThisID, CS, SizeOf(CS));
  Val(CS, ScrInt, ErrCode);
  if (ErrCode <> 0) then
  begin
    NoErrors := False;
    MessageBox(HWindow, 'Please input numbers only!', 'Error', mb_Ok or 
mb_IconExclamation);
    SetFocus(GetDlgItem(HWindow, ThisID));
    SendDlgItemMessage(HWindow, ThisID, em_SetSel, 0, MakeLong(32767, 0));
  end
  else
  begin
    if (ScrInt < MinVal) or (ScrInt > MaxVal) then
    begin
      NoErrors := False;
      Str(MinVal, Str1);
      Str(MaxVal, Str2);
      StrCopy(CS, 'Number must be in the range ');
      StrCat(CS, Str1);
      StrCat(CS, '-');
      StrCat(CS, Str2);
      StrCat(CS, '!');
      MessageBox(HWindow, CS, 'Error', mb_Ok or mb_IconExclamation);
      SetFocus(GetDlgItem(HWindow, ThisID));
      SendDlgItemMessage(HWindow, ThisID, em_SetSel, 0, MakeLong(32767, 0));
    end
    else
      InputNr := ScrInt;
  end;
end;

{ Respond to pressing Ok button. }
procedure TConfigDialog.Ok(var Msg: TMessage);
var
  NoErrors: Boolean;

procedure GetCol(ID: Integer; var Color: TColorRef);
var
  Sel: Integer;
begin
  Sel := SendDlgItemMsg(ID, cb_GetCurSel, 0, 0);
  if (Sel > -1) then SendDlgItemMsg(ID, cb_GetLBText, Sel, TColorRef(@Color));
end;

procedure WritePrivateProfileInt(Str1: PChar; ThisInt: LongInt);
var
  Str2: Array[0..12] of Char;
begin
  Str(ThisInt, Str2);
  WritePrivateProfileString('Screen Saver.Line Play', Str1, Str2, 'CONTROL.INI');
end;

begin
  NoErrors := True;
  GetDlgInt(HWindow, id_NumLines, 1, MaxLines, NumLines, NoErrors);
  GetCol(id_Color, Color);
  RndColor := (IsDlgButtonChecked(HWindow, id_RadioColRnd) <> 0);
  if NoErrors then GetDlgInt(HWindow, id_TimerInterval, 1, 500, TimerInterval, NoErrors);
  PWProtected := (IsDlgButtonChecked(HWindow, id_PWProtected) = 1);

  if NoErrors then
  begin
    WritePrivateProfileInt('Number of Lines', NumLines);
    WritePrivateProfileInt('Drawing Color', Color);
    if RndColor then
      WritePrivateProfileInt('Random Color', 1)
    else
      WritePrivateProfileInt('Random Color', 0);
    WritePrivateProfileInt('Timer Interval', TimerInterval);
    if PWProtected then
      WritePrivateProfileInt('PWProtected', 1)
    else
      WritePrivateProfileInt('PWProtected', 0);
    WritePrivateProfileString('ScreenSaver', 'Password', Password, 'CONTROL.INI');
    TDlgWindow.Ok(Msg);
  end;
end;



{ --------TSetPasswordDialog methods------------------ }
{ Respond to pressing Ok button. }
procedure TSetPasswordDialog.Ok(var Msg: TMessage);
const
  id_PWoldPW   = 104;
  id_PWnewPW   = 105;
  id_PWnewPW2  = 106;
var
  NoErrors: Boolean;
  OldPW, PWStr1, PWStr2: TPasswordString;
begin
  NoErrors := True;
  GetDlgItemText(HWindow, id_PWoldPW, OldPW, SizeOf(OldPW));
  PWEncode(OldPW);
  GetDlgItemText(HWindow, id_PWnewPW, PWStr1, SizeOf(PWStr1));
  GetDlgItemText(HWindow, id_PWnewPW2, PWStr2, SizeOf(PWStr2));
  if (StrIComp(PWStr1, PWStr2) <> 0) then
  begin
    MessageBox(HWindow, 'The values for New Password and Retype New Password do not 
match.' +
               #13 + 'Please try again.', 'Change Password', mb_Ok or mb_IconStop);
    SetFocus(GetDlgItem(HWindow, id_PWOldPW));
    NoErrors := False;
  end;
  if NoErrors and (StrComp(PConfigDialog(Parent)^.PassWord, OldPW) <> 0) then
  begin
    MessageBox(HWindow, 'The value for Old Password is not correct.' + #13 +
               'Please check your screen saver password and try again.',
               'Change Password', mb_Ok or mb_IconStop);
    SetFocus(GetDlgItem(HWindow, id_PWNewPW));
    NoErrors := False;
  end;
  if NoErrors then
  begin
    PWEncode(PWStr1);
    StrCopy(PConfigDialog(Parent)^.PassWord, PWStr1);
    TDlgWindow.Ok(Msg);
  end;
end;


{ --------TSaveWindow methods------------------ }
constructor TSaveWindow.Init(aParent: PWindowsObject; aTitle: PChar);
var
  DC: HDC;
  i, j: Integer;
begin
  TScrnSavWindow.Init(aParent, aTitle);
  NumLines := GetPrivateProfileInt('Screen Saver.Line Play', 'Number of Lines', 10, 
'CONTROL.INI');
  Color := GetPrivateProfileLongInt('Screen Saver.Line Play', 'Drawing Color', Cyan, 
'CONTROL.INI');
  RndColor := (GetPrivateProfileInt('Screen Saver.Line Play', 'Random Color', 1, 'CONTROL.INI') 
= 1);
  TimerInterval := GetPrivateProfileInt('Screen Saver.Line Play', 'Timer Interval', 30, 
'CONTROL.INI');
  PWProtected := (GetPrivateProfileInt('Screen Saver.Line Play', 'PWProtected', 0, 
'CONTROL.INI') = 1);
  GetPrivateProfileString('ScreenSaver', 'Password', '', Password, SizeOf(Password), 
'CONTROL.INI');

  Randomize;
  if RndColor then
    Repeat
      Color := StdColors[1+Random(NColors)];
    Until (Color <> Black);

  DC := GetWindowDC(HWindow);
  MaxX := GetDeviceCaps(DC, HorzRes);
  MaxY := GetDeviceCaps(DC, VertRes);
  ReleaseDC(HWindow, DC);
  MidX := MaxX shr 1;
  MidY := MaxY shr 1;
  for i := 1 to NumLines do
    for j := 1 to 2 do
    begin
      PosX[i,j] := 0;
      PosY[i,j] := 0;
    end;
  VelX[1] := -20 + Random(50);
  VelY[1] := -20 + Random(50);
  VelX[2] := -20 + Random(50);
  VelY[2] := -20 + Random(50);
end;

procedure TSaveWindow.SetupWindow;
begin
  TScrnSavWindow.SetupWindow;
  SetTimer(HWindow, id_Timer, TimerInterval, nil);
end;

{ Perform our little animation }
procedure TSaveWindow.wmTimer(var Msg: TMessage);
var
  DC: HDC;
  i, j: Integer;
  ox1, ox2, oy1, oy2: Integer;
  Pen: HPen;
begin
  ox1 := PosX[NumLines,1];
  oy1 := PosY[NumLines,1];
  ox2 := PosX[NumLines,2];
  oy2 := PosY[NumLines,2];
  for i := NumLines downto 2 do
    for j := 1 to 2 do
    begin
      PosX[i,j] := PosX[i-1,j];
      PosY[i,j] := PosY[i-1,j];
    end;
  for i := 1 to 2 do
  begin
    PosX[1,i] := PosX[1,i] + VelX[i];
    PosY[1,i] := PosY[1,i] + VelY[i];
    if (PosX[1,i] <= 0) or (PosX[1,i] >= MaxX) then
    begin
      VelX[i] := -VelX[i];
      PosX[1,i] := PosX[1,i] + VelX[i];
    end;
    if (PosY[1,i] <= 0) or (PosY[1,i] >= MaxY) then
    begin
      VelY[i] := -VelY[i];
      PosY[1,i] := PosY[1,i] + VelY[i];
    end;
  end;
  DC := GetDC(HWindow);
  Pen := SelectObject(DC, CreatePen(ps_Solid, 1, Black_Brush));
  MoveTo(DC, ox1, oy1);
  LineTo(DC, ox2, oy2);                  { Erase line. }
  DeleteObject(SelectObject(DC, Pen));
  Pen := SelectObject(DC, CreatePen(ps_Solid, 1, color));
  MoveTo(DC, PosX[1,1], PosY[1,1]);
  LineTo(DC, PosX[1,2], PosY[1,2]);      { Draw new line. }
  DeleteObject(SelectObject(DC, Pen));
  ReleaseDC(HWindow, DC);
end;

destructor TSaveWindow.Done;
begin
  KillTimer(HWindow, id_Timer);
  TScrnSavWindow.Done;
end;


var
  TSApp: TSaveApplication;

begin
  TSApp.Init('Saver');
  TSApp.Run;
  TSApp.Done;
end.

-----8<---------8<---------8<---------8<---------8<---------8<---------8<-----

Unit Saver;

interface

uses WinProcs, WinTypes, wObjects, Strings;

const
  sc_ScreenSave = $F140;

type
  TPasswordString = Array[0..63] of Char;

  PConfigDialog = PWindowsObject;

  PPasswordDialog = ^TPasswordDialog;
  TPasswordDialog = Object(TDlgWindow)
    procedure SetupWindow; virtual;
    procedure Cancel(var Msg: TMessage);
      virtual id_First + id_Cancel;
    procedure Ok(var Msg: TMessage);
      virtual id_First + id_Ok;
  end;

  PScrnSavWindow = ^TScrnSavWindow;
  TScrnSavWindow = Object(TWindow)
    CancelPressed: Boolean;
    PWProtected: Boolean;
    Password: TPasswordString;
    EmptyCursor: HCursor;
    First: Boolean;
    prevPt: TPoint;
    PCfgDialog: PConfigDialog;
    constructor Init(aParent: PWindowsObject; aTitle: PChar);
    destructor Done; virtual;
    procedure HasMoved(var Msg: TMessage);
    function GetClassName: PChar; virtual;
    procedure GetWindowClass(var aWndClass: TWndClass); virtual;
    procedure SetupWindow; virtual;
    procedure DefWndProc(var Msg: TMessage); virtual;
    procedure wmSyscommand(var Msg: TMessage); virtual wm_SysCommand;
  end;

procedure PWEncode(PWStr: PChar);

implementation

{ Encode a windows 3.x screen saver password string. }
procedure PWEncode(PWStr: PChar);
var
  iStrLen, iStrPos: Integer;
  theByte: Byte;

procedure XORProc(byte1: Byte; var byte2: Byte);
begin
  byte1 := byte1 xor byte2;
  if not((byte1 <= $20) or ((byte1 >= $7F) and (byte1 <= $90)) or
         ((byte1 >= $93) and (byte1 <= $9F)) or (byte1 = $3D) or
         (byte1 = $5B) or (byte1 = $5D)) then byte2 := byte1;
end;

begin
  iStrLen := Strlen(PWStr);
  if (iStrLen = 0) then exit;

  AnsiUpper(PWStr);

  { Encode forwards }
  for iStrPos := 0 to iStrLen-1 do
  begin
    TheByte := Byte(PWStr[iStrPos]);
    XORProc(Byte(iStrLen), theByte);            { XOR byte with str len }
    if (iStrPos = 0) then
      XORProc($2A, theByte)          { if pos is first, XOR w/ constant }
    else
    begin
      XORProc(Byte(iStrPos), theByte);          { else, XOR w/ position }
      XORProc(Byte(PWStr[iStrPos - 1]), theByte);    { XOR w/ prev char }
    end;
    PWStr[iStrPos] := Char(theByte);         { store byte back into str }
  end;

  { Encode backwards }
  if (iStrLen <> 1) then
    for iStrPos := iStrLen-1 downto 0 do
    begin
      theByte := Byte(PWStr[iStrPos]);          { XOR byte with str len }
      XORProc(Byte(iStrLen), theByte);
      if (iStrPos = iStrLen-1) then
        XORProc($2A, theByte)         { if pos is last, XOR w/ constant }
      else
      begin
        XORProc(Byte(iStrPos), theByte);        { else, XOR w/ position }
        XORProc(Byte(PWStr[iStrPos+1]), theByte);    { XOR w/ next char }
      end;
      PWStr[iStrPos] := Char(theByte);       { store byte back into str }
    end;
end;


{ --------TPasswordDialog methods------------------ }
procedure TPasswordDialog.SetupWindow;
var
  MyRect: TRect;
  x, y: Integer;
begin
  TDlgWindow.SetupWindow;
  { Make sure Password Dialog Window is centered on the screen. }
  x := GetSystemMetrics(sm_CXScreen) shr 1;
  y := GetSystemMetrics(sm_CYScreen) shr 1;
  GetWindowRect(HWindow, MyRect);
  with MyRect do
    SetWindowPos(HWindow, 0, x - ((Right-Left) shr 1), y - ((Bottom-Top) shr 1),
                 Right, Bottom, swp_NoSize or swp_NoZOrder);
end;

procedure TPasswordDialog.Cancel(var Msg: TMessage);
begin
  TDialog.Cancel(Msg);
  PScrnSavWindow(Parent)^.CancelPressed := True;
end;

procedure TPasswordDialog.Ok(var Msg: TMessage);
const
  id_InputBox = 107;
var
  NoErrors: Boolean;
  PWStr: TPasswordString;
begin
  NoErrors := True;
  GetDlgItemText(HWindow, id_InputBox, PWStr, SizeOf(PWStr));
  PWEncode(PWStr);
  if (StrComp(PScrnSavWindow(Parent)^.PassWord, PWStr) <> 0) then
  begin
    MessageBox(HWindow, 'The password is not correct.' + #13 +
               'Please check your screen saver password and try again.',
               'Screen Saver', mb_Ok or mb_IconStop);
    SetFocus(GetDlgItem(HWindow, id_InputBox));
    NoErrors := False;
  end;
  if NoErrors then TDlgWindow.Ok(Msg);
end;

{ --------TScrnSavWindow methods------------------ }
constructor TScrnSavWindow.Init(aParent: PWindowsObject; aTitle: PChar);
begin
  TWindow.Init(aParent, aTitle);
  PWProtected := False;     { For programs which use this unit, but don't }
  StrCopy(Password, '');    { support passwords. }
  First := True;
  ShowCursor(False);
  { It is also necessary to set the cursor to an empty rectangle, because
    some windows drivers don't support ShowCursor. }
  EmptyCursor := LoadCursor(HInstance, 'EMPTY');
  Attr.ExStyle := $08;          { Screensave 'window' always on top. }
  Attr.Style  := ws_Popup;
  SetCapture(HWindow);          { Get all mouse messages. }
end;

destructor TScrnSavWindow.Done;
begin
  ReleaseCapture;
  TWindow.Done;
end;

function TScrnSavWindow.GetClassName: PChar;
begin
  GetClassName := 'ScreenSaverClass';
end;

procedure TScrnSavWindow.GetWindowClass(var aWndClass: TWndClass);
begin
  TWindow.GetWindowClass(aWndClass);
  aWndClass.hIcon := 0;
  aWndClass.Style := cs_SaveBits;
  AWndClass.HCursor := EmptyCursor;
  aWndClass.hbrBackground := GetStockObject(Black_Brush);
end;

procedure TScrnSavWindow.SetupWindow;
var
  rc: TRect;
begin
  TWindow.SetupWindow;
  GetCursorPos(PrevPt);
  GetWindowRect(GetDesktopWindow, rc);
  MoveWindow(hWindow, rc.Left, rc.Top, rc.Right, rc.Bottom, True);
end;

procedure TScrnSavWindow.HasMoved(var Msg: TMessage);
begin
  CancelPressed := False;
  ShowCursor(True);
  SetCursor(LoadCursor(0, idc_Arrow));
  if PWProtected then
    Application^.ExecDialog(new(PPasswordDialog, Init(@Self, 'TYPEPWD')));
  if not(CancelPressed) then
    PostMessage(HWindow, wm_Close, 0, 0)
  else
    First := True;
end;

procedure TScrnSavWindow.DefWndProc(var Msg: TMessage);
begin
  case msg.Message of
    wm_MouseMove:
      if (MakePoint(msg.LParam).x <> prevPt.x) or
         (MakePoint(msg.LParam).y <> prevPt.y) then
        if Not(First) then       { Do not exit on first mouse move. }
          HasMoved(Msg)
        else
          First := False;
    wm_Activate,
    wm_ActivateApp:
      if (msg.WParam = 0) then
      begin
        TWindow.DefWndProc(Msg);
        exit;
      end;
    wm_KeyDown,
    wm_SyskeyDown,
    wm_LButtonDown,
    wm_MButtonDown,
    wm_RButtonDown: HasMoved(Msg);
  end;
  TWindow.DefWndProc(Msg);
end;

procedure TScrnSavWindow.wmSyscommand(var Msg: TMessage);
begin
  if ((Msg.WParam and $FFF0) = sc_ScreenSave) then
    Msg.Result := 1
  else
    DefWndProc(Msg);
end;


end.

-----8<---------8<---------8<---------8<---------8<---------8<---------8<-----


*XX3402-002779-071294--72--85-18316----LINEPLAY.RES--1-OF--1
zk2+zk2+A-
+o+E++1k+C+0U++++U++++E+++++2++E++++++++2+++++++++++++++++++++
++++++++zzzz+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++
++++++++++++++++++++++++++++++++++++++++zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz1+-3
HJ-IKE+k2-E+++++++6++E+U+2+++E+-+1+-+++-+Dw1+Dw-+1+Eu+6++0U++++U++++E+++
++2+-
+++++++U+6+++++++++++++++++++++++++++++++0+++0+++++U6++U++++6++U+0+
U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z+Dzz++1zzzw+++++++++++++++++++
++
+++++6W6W6W6W6W6W5+++++++++++5Rk++-rQ+++++++++++++++-
rRr++++++++++++++++
06W6W6Q+++++++++++++++++++++++++++++1rRrRrRrRrRrRrRrRrRrQ+y6W6W6W6W6W
6W6
W6+5W5+DW6WeW6W6W6W6W6W+-
sVk1sW6W6W6W6W6W6W6W6W6Q+y6XzzzzzzzzzzzzzzsW5+D
W5++++++++++++++1sVk1sVk++++++++++++++y6Q+y6Q++7+++++++++++DW5+DW5+
++7++
++++++++1sVk1sVk+7+7++++++++++y6Q+y6Q++7+7+++++++++DW5+DW5+7+7+7+++++
+++
1sVk1sVk+7+7+7++++++++y6Q+y6Q7+7+7+++++++++DW5+DW5+7+7+7++++++++1sVk1
sVt
+7+7++++++++++y6Q+y6Q7+7+7+++++++++DW5+DW5+7+7++++++++++1sVk1sVk+7+7+
+++
++++++y6Q+y6Q++7+++++++++++DW5+DW5+++7++++++++++1sVk1sW5RrRrRrRrRrRrRr
W6
Q+y6W6W6W6W6W6W6W6W6W5+DW6W6W6W6W6W6W6W6W6Vk1zzzzzzzzzzzzzzzzz
zzw+++++++
++++++++++++++1s+++zy+++DzU++1zzk+Tzzw+5zs++++2+++++++++++++++++++++++
++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++
++++++++++++++++++++++++++++++++++++U++++TwC+2Z1Hosl+1+E3++++++++E+-
+0+U
2++-++2+u+6+++2+zkI+EI7DJJE+A-1Q++++U+16U+JY+3++Y+-a++++EK7jRLEUH4ZiNG-E
P43t63BXQaJZPW-HMLNZQU+i+2w+B++D++2++++-I6-0OKQUF4JVP02+++c+0+-s++c++U+-
++-EUYldPaIUI4lVSG-HMr7ZNKtnMLNZQU++Dk+q+-++1k+2++A++300GIBDHX2+++c+3U-s
++c+-E+-++-EUYtj68YUAHYtB0-BML7dPm-qMKsUN4Ji623iMqhZQU++0++Y+5U+0U+4++2+
+300FGphMKZgCW-hML7dPo-
VQrFmPmtpRa2iPak++Dw3+2B6I3R2+1+Ew++++A++m6+60++E
+8s+Hk+++2BcMKtbNG-EMLBnRqxmN++6+2pH63BVPbAUIqJmOKM+-++1+3++1U-
Y+++++Z00
7YxgN0-EMLBnRqxmN1c++3E++k-E++s+O++U+63EUE++-++J+3++1U-Z+++++Z007YtZRm-
E
MLBnRqxmN1c++3E+3E-E++s+OE+U+63EUE++-++b+3++1U-a+++++Z007Z7ZR5ZkNG-
CNLQU
I43nQrRjQaEu++-I+0Q+I++C+4c+6+0-I62++0M+Ck+c++s++E+-++3EU2x9++-U+1g+8++C
++6++++-I6-1MKtXNKk++Dw3+2B6I3R2AU+k2D++++1++AW+0+U+2+0i+2w+++-1O43iNqIU
I43nQrRjQaE+0+-BIm-HMKtn63BZQaZa++E++k-E++s+N+++++7MUWNDP4EUI43nQrRjQaEu
+++2+-I+I++C+4I++++0I66aHaJr63-VQrBrPr7YCU++J++J+3++1U-d+0++UJ0-+++2+0Q+
I++C+4M++++0I66aIaJoSL-Z62tZRm-EMLBnRqxmN1c++3E+7k-E++s+OU+U+63EUE++7U+v
+0U+1U+-++2++J0+Hog++4++Ck+c++s++U++++3EU2BVPaBZP+++J++1+3++1U-
c++U++ZW0
++1z-E-HFJFJI++k2AM-++1++AW+2-E+8+1A+5++++-AOKtZ63-gMLYUIqJoRL++0+-6NKlq
+4s+2++P++k+NE+++63EUE++DU+Y++c+0U-t++Y++30+60+aMk++PU+Y+0U+0U-
u++Y++J0+
7Z7VPaFjPE++GE+V+-s+I+-f+-A+6J03++-i+1A+4k+A+5U+++0-I62+++U+K+-E++s+O++1
++BEU0NEMLBnRqxmN0-
EQaxoNKBoNKE++3c+K++u++s+OE++++BEU0NHNLEUI43nQrRjQaEi
9Ws++7w+0++c++s++E+-++3EU2x9++0T+-c+8++C++6++++-I6-1MKtXNKk++7w+9++c++s+
Nk++++3EU0N-MaxpR+++0++Y+1E+1+-g+++++300F57VRqZiNm+aEqxgPrJm+++2++I+ZU--
+Dzz-k++I6-AOKtZQk++0++H+2U+1+1zzk+++Z007YtpPK7ZQW-jNW-gOKtZQk++-+-A+7M+
5U1zzkQ++30+I43nQrRjQaEUHr-oOKxiQk++0++q+3k+1+-r+++++Z007ZFdPKJm62ZiR4Jm
Ra3g60VhOKlgOLBZMmsd++0c+2c+2U+I+5g++k++I677EoxCAE++zkI+J3ZEFJ-LF++k20I-
++1++AW+-V++A+0g+3s+++-AOKtZ63-
gMLYUIqBmNKJi63BVRaJm++U+G4JgRU+T++A+X++c
+Dzz+++0I67IO4IUQqBmNKJi65BVRaJm65ZjRG-VQaIURLBdPaQUOLAUQ43nQrRjQaEUQ57j
R4JXR4JY9W+UKKxp64ppQrEUR5ZkNG-dPW-oO4IUQqBmNKJi65BVRaJm65-VQrBrPr7Y65Fj
65FpQasUPqNa65FcNG-
nMr7ZNKsUQq3qNL6i+++T+0o+8++C+4Q++++0I67EMLBnRqxmN1c+
+2Q+9E-E++s+Ok+U+63EUE++5k-0+0U+1U+-
++2++J0+Hog++4w+EU+c++s++U++++3EU2BV
PaBZP+++-E+3+-++2+-g++A++300zkBz+DwD+Dw-+1+EM+++++o+1++0U+-3HJ-IKE+B++s+
+M++GIBDHX2+1E+3++O++230HpJI++o+-E+5U+-1G3-LF++C++I+06++EoVEJoEm++o+-E+7
U+-HFJFJI++D++I+0c++J3ZEFJ-LF+++++++
***** END OF BLOCK 1 *****


