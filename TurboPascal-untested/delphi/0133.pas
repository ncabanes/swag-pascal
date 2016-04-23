{
  Q: Why doing the 243. version of a LED light.
  A: It does not use bitmaps - so it|s fully scaleable (and saves resources).

  Contact: Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]

  March 9. 1996

  Greetings from germany - enjoy...
}

unit
  LEDPaint;

interface

uses
  WinTypes, WinProcs, Messages, Classes, Graphics, Controls, ExtCtrls;
{------------------------------------------------------------------------------}

type
  TLEDColor = (lcRed,lcGreen,lcBlue,lcYellow,lcNone);
  TLEDType = (ltRound,ltRect);

  TLEDPaint = class(TGraphicControl)
  private
    FBackGround: TColor;
    FBevelOuter: TPanelBevel;
    FBevelInner: TPanelBevel;
    FBevelWidth: Byte;
    FLEDColor: TLEDColor;
    FLEDOn: Boolean;
    FLEDType: TLEDType;
    Border: Byte;
  protected
    procedure Draw(BkGnd:Boolean);
    procedure DrawBevel(Rect: TRect);
    procedure SetBackGround(Value: TColor);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelWidth(Value: Byte);
    procedure SetLED(Value:Boolean);
    procedure SetLEDColor(Value: TLEDColor);
    procedure SetLEDType(Value: TLEDType);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  published
    property BackGround: TColor read FBackGround write SetBackGround default clBtnFace;
    property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default bvRaised;
    property BevelWidth: Byte read FBevelWidth write SetBevelWidth default 1;
    property LEDColor: TLEDColor read FLEDColor write SetLEDColor default lcRed;
    property LEDOn: Boolean read FLEDOn write SetLED default False;
    property LEDType: TLEDType read FLEDType write SetLEDType default ltRound;
  end;
{------------------------------------------------------------------------------}

procedure Register;

implementation
{------------------------------------------------------------------------------}

constructor TLEDPaint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Canvas.Brush.Style:=bsSolid;
  FBackGround:=clBtnFace;
  FBevelOuter:=bvRaised;
  FBevelInner:=bvRaised;
  FBevelWidth:=1;
  FLEDColor:=lcRed;
  FLEDOn:=False;
  FLEDType:=ltRound;
  Border:=2;
  Left:=0;
  Top:=0;
  Width:=19;
  Height:=19;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.Paint;
begin
  Draw(True);
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.DrawBevel(Rect: TRect);
var
  TopColor: TColor;
  BottomColor: TColor;

  procedure SetColors(Bevel: TPanelBevel);
  begin
    TopColor:=clBtnHighlight;
    if Bevel = bvLowered then TopColor:=clBtnShadow;
    BottomColor:=clBtnShadow;
    if Bevel = bvLowered then BottomColor:=clBtnHighlight;
  end;

begin
  if FBevelOuter <> bvNone then
  begin
    SetColors(BevelOuter);
    Frame3D(Canvas,Rect,TopColor,BottomColor,BevelWidth);
  end;

  if FBevelInner <> bvNone then
  begin
    SetColors(FBevelInner);
    Frame3D(Canvas,Rect,TopColor,BottomColor,FBevelWidth);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.Draw(BkGnd: Boolean);
var
  R: TRect;
  OnColor: TColor;
  OffColor: TColor;
  UpColor: TColor;
  DnColor: TColor;
  S: Byte;
begin
  R:=GetClientRect;
  S:=Width div 6;                      {Abstand der Schattierung vom Au-enkreis}

  if BkGnd or (csDesigning in ComponentState) then
  begin
    DrawBevel(R);

    if FBackGround <> clWindow then
    begin
      Canvas.Pen.Color:=FBackGround;
      Canvas.Brush.Color:=FBackGround;
      InflateRect(R,-Border,-Border);
      Canvas.FillRect(R);
    end;
  end
  else InflateRect(R,-Border,-Border);

  case FLEDColor of
    lcNone   : begin
                 OnColor:=clBtnFace;
                 OffColor:=clBtnFace;
               end;
    lcRed    : begin
                 OnColor:=clRed;
                 OffColor:=clMaroon;
               end;
    lcGreen  : begin
                 OnColor:=clLime;
                 OffColor:=clGreen;
               end;
    lcBlue   : begin
                 OnColor:=clBlue;
                 OffColor:=clNavy;
               end;
    lcYellow : begin
                 OnColor:=clYellow;
                 OffColor:=clOlive;
               end;
  end;

  if FLEDOn then Canvas.Brush.Color:=OnColor else Canvas.Brush.Color:=OffColor;

  Canvas.Pen.Width:=1;
  if FLEDType = ltRound then
  begin
    if not FLEDOn then Canvas.Pen.Color:=clSilver else Canvas.Pen.Color:=clGray;
    Canvas.Ellipse(R.Left,R.Top,R.Right,R.Bottom);
    if FLEDOn then Canvas.Pen.Color:=clSilver else Canvas.Pen.Color:=clGray;
    Canvas.Arc(R.Left + S,R.Top + S,
               R.Right - S,R.Bottom - S,
               R.Right - S,R.Top + S,
               R.Left + S,R.Bottom - S);
  end
  else
  begin
    case BevelInner of
      bvRaised  : Frame3D(Canvas,R,clBlack,clWhite,1);
      bvLowered : Frame3D(Canvas,R,clWhite,clBlack,1);
      bvNone    : begin
                    if FBevelOuter = bvLowered then
                      Frame3D(Canvas,R,clWhite,clBlack,1)
                    else Frame3D(Canvas,R,clBlack,clWhite,1);

                  end;
    end;
    Canvas.FillRect(R);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetBackGround(Value: TColor);
begin
  if FBackGround <> Value then
  begin
    FBackGround:=Value;
    Draw(True);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetBevelOuter(Value: TPanelBevel);
begin
  if FBevelOuter <> Value then
  begin
    FBevelOuter:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Draw(True);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetBevelInner(Value: TPanelBevel);
begin
  if FBevelInner <> Value then
  begin
    FBevelInner:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Draw(True);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetBevelWidth(Value: Byte);
begin
  if FBevelWidth <> Value then
  begin
    FBevelWidth:=Value;
    if FBevelOuter <> bvNone then Border:=FBevelWidth else Border:=0;
    if FBevelInner <> bvNone then Inc(Border,FBevelWidth);
    Draw(True);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetLED(Value: Boolean);
begin
  if FLEDOn <> Value then
  begin
    FLEDOn:=Value;
    Draw(False);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetLEDColor(Value: TLEDColor);
begin
  if FLEDColor <> Value then
  begin
    FLEDColor:=Value;
    Draw(False);
  end;
end;
{------------------------------------------------------------------------------}

procedure TLEDPaint.SetLEDType(Value: TLEDType);
begin
  if FLEDType <> Value then
  begin
    FLEDType:=Value;
    Draw(True);
  end;
end;
{------------------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('Udo|s',[TLEDPaint]);
end;
{------------------------------------------------------------------------------}

initialization
end.

