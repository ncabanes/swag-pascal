(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0074.PAS
  Description: T.V. Rubberband Example
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:56
*)


{************************************************}
{                                                }
{   Turbo Pascal for Windows                     }
{   Tips & Techniques Demo Program               }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

Program Rubberband;

uses WinTypes, WinProcs, WObjects;

type
  TApp  = object (TApplication)
    procedure InitMainWindow; virtual;
  end;

  PRubberWin = ^TRubberWin;
  TRubberWin = object(TWindow)
    DC : HDC;
    PS : TPaintStruct;
    ABrush: hBrush;
    APen: hPen;
    OTrack, Track : boolean;
    NextX, NextY, OrgX, OrgY, PrevX, PrevY, X, Y, SX, SY : longint;
    procedure Destroy; virtual;
    procedure SetupWindow; virtual;
    procedure WMLButtonDown(var Message: TMessage);
      virtual wm_First + wm_LButtonDown;
    procedure WMLButtonUp(var Message: TMessage);
      virtual wm_First + wm_LButtonUp;
    procedure WMMouseMove(var Message: TMessage);
      virtual wm_First + wm_MouseMove;
  end;

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PRubberWin, Init(Nil,'RUBBER BAND'));
end;

procedure TRubberWin.Destroy;
begin
  TWindow.Destroy;
  DeleteObject(ABrush);
  DeleteObject(APen);
end;

procedure TRubberWin.SetupWindow;
begin
  Track := False;
  OTrack := True;
  OrgX := 0;
  OrgY := 0;
  PrevX := 0;
  PrevY := 0;
  X := 0;
  Y := 0;
  SX := 0;
  SY := 0;
  ABrush := CreateSolidBrush(RGB(255, 0, 0));
  APen := CreatePen(ps_Solid, 1, RGB(0, 0, 255));
end;

procedure TRubberWin.WMLButtonDown(var Message: TMessage);
begin
  Track := True;
  with Message do
  begin
    PrevX := lParamLo;
    PrevY := lParamHi;
    OrgX := PrevX;
    OrgY := PrevY;

    if OTrack then
    begin
      SX := lParamLo;
      SY := lParamHi;
      OTrack := False;
    end;
    SetCapture(HWindow);
  end;
end;

procedure TRubberWin.WMLButtonUp(var Message: TMessage);
var
  OldPen: HPen;
  OldBrush: HBrush;
begin
  Track := False;
  OTrack := True;
  ReleaseCapture;
  X := integer(Message.lParamLo);
  Y := integer(Message.lParamHi);
  DC := GetDC(HWindow);
  OldPen := SelectObject(DC, APen);
  OldBrush := SelectObject(DC, ABrush);
  if (OrgX <> X) or (OrgY <> Y) then
    Ellipse(DC, OrgX, OrgY, X, Y);
  SelectObject(DC, OldPen);
  SelectObject(DC, OldBrush);
  ReleaseDC(HWindow, DC);
end;

procedure TRubberWin.WMMouseMove(var Message: TMessage);
begin
  if Track then
  begin
    NextX := integer(Message.lParamLo);
    NextY := integer(Message.lParamHi);
    if (NextX <> PrevX) or (NextY <> PrevY) then
    begin
      DC := GetDC(HWindow);
      SetROP2(DC, r2_NOT);
      SelectObject(DC, GetStockObject(null_Brush));
      Ellipse(DC, OrgX, OrgY, PrevX, PrevY);
      PrevX := NextX;
      PrevY := NextY;
      Ellipse(DC, SX, SY, PrevX, PrevY);
      ReleaseDC(HWindow, DC);
    end;
  end;
end;

var
  App: TApp;

begin
  App.Init('Rubber Band');
  App.Run;
  App.Done;
end.

