
Once again, the dcr is attached...

(*
TTransparentGroupBox - Eddie Shipman

 TGroupBox that is transparent and allows colored bevels.

 Added two properties:
****************************************************************************
***
 Property: - BevelShadowColor-

    This is the color of the Bevel's Shadow, Default clBtnShadow.
    Change this color to change the color of the Bevel's Shadow.

****************************************************************************
***
 Property:  BevelHighlightColor-

    This is the color of the Bevel's Highlight, Default clBtnHighlight.
    Change this color to change the color of the Bevel's Highlight.

****************************************************************************
***
12/22/97 - Added DrawFrame procedure to correct the way the frame
               is drawn to let background actually show thorugh transparent
               text., {ES}

*)
unit TransparentGroupBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TTransparentGroupBox = class(TGroupBox)
  private
    { Private declarations }
    FBevelLowColor: TColor;
    FBevelHiColor: TColor;
    procedure SetBvlLowColor(Value: TColor);
    procedure SetBvlHiColor(Value: TColor);
    Procedure WMEraseBkGnd(Var Message:TWMEraseBkGnd); Message WM_EraseBkGnd;
    Procedure WMMove(Var Message:TWMMove); Message WM_Move;
  protected
    { Protected declarations }
    Procedure CreateParams(Var Params:TCreateParams); Override;
    Procedure Paint; Override;
    Procedure SetParent(AParent:TWinControl); Override;
    procedure DrawFrame(Rect:TRect);
  public
    { Public declarations }
    Constructor Create(AOwner:TComponent); Override;
    Procedure Invalidate; Override;
  published
    { Published declarations }
    property BevelShadowColor:TColor    read FBevelLowColor
                                       write SetBvlLowColor;
    property BevelHighlightColor:TColor read FBevelHiColor
                                       write SetBvlHiColor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TTransparentGroupBox]);
end;

constructor TTransparentGroupBox.Create (AOwner: TComponent);
Begin
  Inherited Create(AOwner);
  ControlStyle:= ControlStyle - [csOpaque];
  FBevelLowColor := clBtnShadow;
  FBevelHiColor := clBtnHighlight;
End;

Procedure TTransparentGroupBox.CreateParams(Var Params:TCreateParams);
Begin
  inherited CreateParams (Params);
  Params.ExStyle := Params.ExStyle + WS_EX_TRANSPARENT;
End;

Procedure TTransparentGroupBox.Paint;
var
  H: Integer;
  R: TRect;
begin
  with Canvas do
  begin
    Font := Self.Font;
    H := TextHeight('0');
    R := Rect(0, H div 2 - 1, Width, Height);
    if Ctl3D then
    begin
      DrawFrame(R);
    end else
    begin
      Brush.Color := clWindowFrame;
      FrameRect(R);
    end;
    if Text <> '' then
    begin
      R := Rect(8, 0, 0, H);
      DrawText(Handle, PChar(Text), Length(Text), R, DT_LEFT or
DT_SINGLELINE or
        DT_CALCRECT);
      if Ctl3D then
        Brush.Style:= bsClear
      else
        Brush.Color := Color;
      DrawText(Handle, PChar(Text), Length(Text), R, DT_LEFT or
DT_SINGLELINE);
    end;
  end;
End;

Procedure TTransparentGroupBox.WMEraseBkGnd(Var Message:TWMEraseBkGnd);
Begin
  Repaint;
End;

Procedure TTransparentGroupBox.SetParent(AParent:TWinControl);
Begin
  Inherited SetParent(AParent);
  If Parent <> Nil then
    SetWindowLong(Parent.Handle, GWL_STYLE,
       GetWindowLong(Parent.Handle, GWL_STYLE)
          And Not WS_ClipChildren);
End;

Procedure TTransparentGroupBox.Invalidate;
Var
  Rect :TRect;
Begin
  Rect:= BoundsRect;
  If (Parent <> Nil) and Parent.HandleAllocated then
    InvalidateRect(Parent.Handle, @Rect, True)
  Else
    Inherited Invalidate;
End;

Procedure TTransparentGroupBox.WMMove(Var Message:TWMMove);
Begin
  Invalidate;
End;

procedure TTransparentGroupBox.SetBvlLowColor(Value: TColor);
begin
  if FBevelLowColor <> Value then
    FBevelLowColor := Value;
  Invalidate;
end;

procedure TTransparentGroupBox.SetBvlHiColor(Value: TColor);
begin
  if FBevelHiColor <> Value then
    FBevelHiColor := Value;
  Invalidate;
end;

procedure TTransparentGroupBox.DrawFrame(Rect: TRect);
var
  CaptionLength: Integer;
begin
  with Canvas do
  begin
    Inc(Rect.Left);
    Inc(Rect.Top);
    Dec(Rect.Right);
    Dec(Rect.Bottom);
    CaptionLength := TextWidth(Text);
    Pen.Color := FBevelHiColor;
    MoveTo(Rect.Left, Rect.Top);
    LineTo(6,Rect.Top);
    MoveTo(8+CaptionLength+2, Rect.Top);
    LineTo(Rect.Right,Rect.Top);
    LineTo(Rect.Right,Rect.Bottom);
    LineTo(Rect.Left,Rect.Bottom);
    LineTo(Rect.Left, Rect.Top);
    OffsetRect(Rect, -1, -1);
    Pen.Color := FBevelLowColor;
    MoveTo(Rect.Left, Rect.Top);
    LineTo(6,Rect.Top);
    MoveTo(8+CaptionLength+2, Rect.Top);
    LineTo(Rect.Right,Rect.Top);
    LineTo(Rect.Right,Rect.Bottom);
    LineTo(Rect.Left,Rect.Bottom);
    LineTo(Rect.Left, Rect.Top);
  end;
end;

end.

{ --------------------------- TransparentGroupbox.dcr ------------------------------
Content-Transfer-Encoding: base64
{ cut this out, and save to a file .. then use a base64 processor to create
  TransparentGroupbox.dcr  .. there is one in SWAG that works fine !}

AAAAACAAAAD//wAA//8AAAAAAAAAAAAAAAAAAAAAAACIAQAASAAAAP//AgBUAFQAUgBBAE4AUwBQ
AEEAUgBFAE4AVABHAFIATwBVAFAAQgBPAFgAAAAAAAAAAAAQEAkEAAAAAAAAAAAoAAAAGAAAABgA
AAABAAQAAAAAACABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAA
AICAgADAwMAAAAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////ADMzMzMzMzMzMzMzMzMzMzMzMzMz
MzMzMzAAAAAAAAAAAAAAAzDMzMzMzMzMzMzMAzDMzMzMzMzMzMzMAzDMzd3d3d3d3d3cAzDMXFVV
VVVVVVXSAzDMXczMzMzMzCXSAzDMXczMzMzMIiXSAzDvXe/v7+8iIiXSAzD+Xf7+/v7+IiXSAzDv
Xe/v7+/v7yXSAzD+Xf7+/v7+/vXSAzDvXe/v7+/v7+XSAzD+Xf74jv7+/vXeAzDvXe+PuO/v7+Xf
AzD+Xf4L+P7+/vXeAzDvXeDoDw8P7+XfAzD+XdDQ3Q0N3d7eAzDvVVAAUFBVVVXvAzD+/v4O8P7+
/v7+AzAAAAAAAAAAAAAAAzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMw==
