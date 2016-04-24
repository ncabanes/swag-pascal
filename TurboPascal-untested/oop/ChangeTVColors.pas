(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0045.PAS
  Description: Change T.V. Colors
  Author: SWAG SUPPORT TEAM
  Date: 08-26-94  08:32
*)

program Color;

{$R color.res }

uses
  WinProcs,
  WinTypes,
  WObjects;

const
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

const
  id_Color = 101;

type
  PColorDialog = ^TColorDialog;
  TColorDialog = object(TDialog)
    ColorPtr : ^longint;
    constructor Init(AParent : PWindowsObject; var AColor : longint);
    procedure SetupWindow; virtual;
    function CanClose : boolean; virtual;
    procedure wmDrawItem(var Msg : TMessage); virtual wm_First+wm_DrawItem;
    procedure wmMeasureItem(var Msg : TMessage); virtual wm_First+wm_MeasureItem;
  end;

constructor TColorDialog.Init(AParent : PWindowsObject; var AColor : longint);
begin
  TDialog.Init(AParent,'ColorDlg');
  ColorPtr := @AColor;
end; { Init }

procedure TColorDialog.SetupWindow;
const
  NColors = 16;
  StdColors : array[1..NColors] of longint =
   (White, Black, LightGray, DarkGray, Cyan, Magenta, Yellow, Red, Green,
    Blue, LightBlue, LightCyan, LightMagenta, Brown, LightRed, LightGreen);

  procedure SetupColors(ID : integer; Color : longint);
  var
    i,Sel : integer;
  begin
    Sel := -1;
    for i := 1 to NColors do begin
      SendDlgItemMsg(ID,cb_AddString,0,StdColors[i]);
      if StdColors[i] = Color then Sel := pred(i);
    end;
    if Sel = -1 then begin
      SendDlgItemMsg(ID,cb_AddString,0,Color);
      Sel := NColors;
    end;
    SendDlgItemMsg(ID,cb_SetCurSel,Sel,0);
  end; { SetupColors }

begin { SetupWindow }
  TDialog.SetupWindow;
  SetupColors(id_Color,ColorPtr^);
end; { SetupWindow }

function TColorDialog.CanClose : boolean;

  procedure GetCol(ID : integer; var Color : longint);
  var
    Sel : integer;
  begin
    Sel := SendDlgItemMsg(ID,cb_GetCurSel,0,0);
    if Sel > -1 then
      SendDlgItemMsg(ID,cb_GetLBText,Sel,longint(@Color));
  end; { GetCol }

begin { CanClose }
  GetCol(id_Color,ColorPtr^);
  CanClose := true;
end; { CanClose }


procedure TColorDialog.wmDrawItem(var Msg : TMessage);
var
  Brush : HBrush;
begin
  with PDrawItemStruct(Msg.lParam)^ do begin
    if CtlType = odt_ComboBox then begin
      if ((ItemAction and oda_DrawEntire) <> 0) or
         ((ItemAction and oda_Select) <> 0) then begin
        Brush := CreateSolidBrush(ItemData);
        FillRect(hDC,rcItem,Brush);
        DeleteObject(Brush);
      end;
      if ((ItemState and ods_Focus) <> 0) or
         ((ItemState and ods_Selected) <> 0) then begin
        InflateRect(rcItem,-2,-2);
        DrawFocusRect(hDC,rcItem);
      end;
    end;
  end;
end; { wmDrawItem }

procedure TColorDialog.wmMeasureItem(var Msg : TMessage);
begin
  PMeasureItemStruct(Msg.lParam)^.ItemHeight := 16;
end; { wmMeasureItem }

const
  cm_Color = 100;

type
  PColorWindow = ^TColorWindow;
  TColorWindow = object(TWindow)
    Color : longint;
    constructor Init;
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure CMColor(var Msg: TMessage);
      virtual cm_First + cm_Color;
  end;

constructor TColorWindow.Init;
begin
  Color := White;
  TWindow.Init(nil, 'Color Combo Demo');
  Attr.Menu := LoadMenu(HInstance, 'Menu');
end; { Init }

procedure TColorWindow.cmColor(var Msg: TMessage);
begin
  if Application^.ExecDialog(
       New(PColorDialog,Init(@Self,Color))) = id_Ok then
    InvalidateRect(HWindow,nil,true);
end; { cmColor }

procedure TColorWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  Brush : HBrush;
begin
  Brush := CreateSolidBrush(Color);
  FillRect(PaintDC,PaintInfo.rcPaint,Brush);
  DeleteObject(Brush);
end; { Paint }

type
  TColorApp = object(TApplication)
    procedure InitMainWindow; virtual;
  end;

procedure TColorApp.InitMainWindow;
begin
  MainWindow := New(PColorWindow,Init);
end; { InitMainWindow }

var
  ColorApp: TColorApp;

begin
  ColorApp.Init('Menu');
  ColorApp.Run;
  ColorApp.Done;
end.

{ -------------------------  COLOR.RES ----------------------- }

{ USE XX3402 to decode the following block                              }
{ Cut out and name COLOR.XX.  Use XX3402 d COLOR.XX to create COLOR.RES }

{ ------------------------    CUT -----------------------------}

*XX3402-000206-140792--72--85-25021-------COLOR.RES--1-OF--1
zkE+HIJCJE+k2+w+++++++++U+-Y+0N1PqljQU1z-E-1HolDIYFAFk+k25I+++1++AW+-3Q+
7U-l+2s+++-1O4xjQqIUMqxgPr6+0+-6NKlq++Q+0E+M++c+zzw+++-EUYBjP4xmCU++6++4
+-s+D+-Z+-A+6J03++-4++M+6k+A++2++E+-I6-DOk++FU+N+0A+1++0+++++J0+Eq3iMqJg
++1z1k1z+E+k2-s++++A++E++M++HIJCJE+E++I++c++EoxAHp72H2Q+++++
***** END OF BLOCK 1 *****


