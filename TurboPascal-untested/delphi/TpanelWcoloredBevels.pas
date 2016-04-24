(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0376.PAS
  Description: TPanel w/colored bevels
  Author: EDDIE SHIPMAN
  Date: 01-02-98  07:33
*)


I kinda noticed that even when I changed my TPanel
color, the bevels stayed clBtnShadow and clBtnHighlight.
Well, here is the modified version that allows you to
change the bevel colors as well:

(*
TNewPanel - Eddie Shipman

 TPanel which allows colored bevels.

 Added two properties:
****************************************************************************
***
 Property: - BevelShadowColor-

    This is the color of the Bevel's Shadow if the Panel Bevel is Raised
    or Lowered Default clBtnShadow. Change this color to change the 
    color of the Bevel's Shadow.

****************************************************************************
***
 Property:  BevelHighlightColor-

    This is the color of the Bevel's Highlight if the Panel Bevel is Raised
    or Lowered Default clBtnHighlight. Change this color to change the 
    color of the Bevel's Highlight.

****************************************************************************
***
*)
unit NewPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TNewPanel = class(TPanel)
  private
    { Private declarations }
    FBevelLowColor: TColor;
    FBevelHiColor: TColor;
    procedure SetBvlLowColor(Value: TColor);
    procedure SetBvlHiColor(Value: TColor);
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property BevelShadowColor:TColor  read FBevelLowColor
                                                       write SetBvlLowColor;
    property BevelHighlightColor:TColor read FBevelHiColor
                                                       write SetBvlHiColor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TNewPanel]);
end;

constructor TNewPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  Width := 185;
  Height := 41;
  BevelOuter := bvRaised;
  BevelWidth := 1;
  Color := clBtnFace;
  FBevelLowColor := clBtnShadow;
  FBevelHiColor := clBtnHighlight;
end;

procedure TNewPanel.Paint;
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := FBevelHiColor;
    if Bevel = bvLowered then TopColor := FBevelLowColor;
    BottomColor := FBevelLowColor;
    if Bevel = bvLowered then BottomColor := FBevelHiColor;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with Rect do
    begin
      Top := ((Bottom + Top) - FontHeight) div 2;
      Bottom := Top + FontHeight;
    end;
    DrawText(Handle, PChar(Caption), -1, Rect, (DT_EXPANDTABS or
      DT_VCENTER) or Alignments[Alignment]);
  end;
end;

procedure TNewPanel.SetBvlLowColor(Value: TColor);
begin
  if FBevelLowColor <> Value then
    FBevelLowColor := Value;
  Invalidate;
end;

procedure TNewPanel.SetBvlHiColor(Value: TColor);
begin
  if FBevelHiColor <> Value then
    FBevelHiColor := Value;
  Invalidate;
end;

end.


