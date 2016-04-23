{*******************************************************************************
  TRichButton
  Copyright ⌐ 1997 Mentor Computer Solutions
  Version 1.0 revised February 2, 1997

  Author:       Garret Wilson
                Garret@MentorComputer.com

  Company:      Mentor Computer Solutions
                RR 2 Box 246
                Chelsea, OK 74016 USA
                (918) 789-2734
                http://www.MentorComputer.com

  Status:       Freeware. Source may be redistributed in whole, providing that
                the copyright information is also included.

  Description:  TRichButton provides a button that can include rich text,
                including bold, italics, different fonts, etc. To use
                TRichButton, access the Lines, Font, Color, DefAttributes,
                SelAttributes, and Paragraph properties, which function
                identically to those that come with the standard TRichEdit
                control.

  Acknowledgements: TRichButton was developed in part by referring to the
                    Borland source code for TCustomPanel and TRichEdit. Some
                    features of TRichButton originated from ideas implemented in
                    TTransBitmap, which is Copyright ⌐ 1996 Alan GARNY,
                    gry@physiol.ox.ac.uk, http://www.physiol.ox.ac.uk/~gry
                    and these instances are indicated.
*******************************************************************************}

unit RichButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls, ExtCtrls;

type

  TRichButtonState = (stUp, stDown, stDisabled);

  TRichButton = class(TCustomControl)
  private
    FAlignment: TAlignment;     {storage for properties}
    FAllowDown: Boolean;
    FBevelInner: TPanelBevel;
    FBevelOuter: TPanelBevel;
    FBevelWidth: TBevelWidth;
    FBorderWidth: TBorderWidth;
    FBorderStyle: TBorderStyle;
    FFocus: Boolean;
    FFocusColor: TColor;
    FFocusWidth: TWidth;
    FFullRepaint: Boolean;
    FLocked: Boolean;
    FState: TRichButtonState;
    FOnResize: TNotifyEvent;
    FSelAttributes: TTextAttributes;
    FDefAttributes: TTextAttributes;
    FParagraph: TParaAttributes;
    HasFocus:Boolean;     {variables used internally}
    MouseCaught:Boolean;
    OrigState:TRichButtonState;
    RichEdit:TRichEdit;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMIsToolControl(var Message: TMessage); message CM_ISTOOLCONTROL;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAllowDown(Value:Boolean);  {modified from TTransBitmap}
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetFocus(Value:Boolean);  {modified from TTransBitmap}
    procedure SetFocusColor(Value:TColor);  {modified from TTransBitmap}
    procedure SetFocusWidth(Value:TWidth);  {modified from TTransBitmap}
    function GetLines:TStrings;
    procedure SetLines(Value:TStrings);
    procedure SetState(Value:TRichButtonState); {modified from TTransBitmap}
    procedure ReadData(Reader: TReader);
        {internal routines}
    function GetWorkRect:TRect;  {modified from TTransBitmap}
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
    procedure Resize; dynamic;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default True;
  public
    constructor Create(AOwner: TComponent); override;
    property DefAttributes:TTextAttributes read FDefAttributes write FDefAttributes; {properties stored in TRichEdit}
    property SelAttributes:TTextAttributes read FSelAttributes write FSelAttributes;
    property Paragraph:TParaAttributes read FParagraph;
  published
    property Align;
    property Alignment:TAlignment read FAlignment write SetAlignment default taCenter;
    property AllowDown:Boolean read FAllowDown write SetAllowDown default False;
    property BevelInner:TPanelBevel read FBevelInner write SetBevelInner default bvNone;
    property BevelOuter:TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelWidth:TBevelWidth read FBevelWidth write SetBevelWidth default 2;
    property BorderWidth:TBorderWidth read FBorderWidth write SetBorderWidth default 0;
    property BorderStyle:TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Color default clBtnFace;
    property Ctl3D;
    property Focus:Boolean read FFocus write SetFocus default False;
    property FocusColor:TColor read FFocusColor write SetFocusColor default clHighlight;
    property FocusWidth:TWidth read FFocusWidth write SetFocusWidth default 2;
    property Font;
    property Height default 25;
    property Locked:Boolean read FLocked write FLocked default False;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property State:TRichButtonState read FState Write SetState default stUp;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width default 75;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnStartDrag;
    property Lines:TStrings read GetLines write SetLines; {properties stored in TRichEdit}
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional', [TRichButton]);
end;

constructor TRichButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csOpaque, csDoubleClicks, csReplicatable];
  RichEdit:=TRichEdit.Create(Self); {create the RTF control}
  RichEdit.Parent:=Self;  {set the TRichButton as the parent}
  FDefAttributes:=RichEdit.DefAttributes;  {use the DefAttributes of the RichEdit}
  FSelAttributes:=RichEdit.SelAttributes;  {use the SelAttributes of the RichEdit}
  FParagraph:=RichEdit.Paragraph;  {use the Paragraph of the RichEdit}
  Width:=75;
  Height:=25;
  FAlignment := taCenter;
  FAllowDown:=False;
  BevelOuter := bvRaised;
  BevelWidth:=2;
  FBorderStyle := bsNone;
  Color:=clBtnFace;
  FFocus:=False;
  FFocusColor:=clHighlight;
  FFocusWidth:=2;
  FFullRepaint := True;
  ParentColor:=False;
  FState:=stUp;
  MouseCaught:=False;
  HasFocus:=False;
end;

procedure TRichButton.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of Longint = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TRichButton.CreateWnd;
begin
  inherited CreateWnd;  {call the inherited CreatWnd() procedure}
  RichEdit.BorderStyle:=bsNone; {don't show a border on the RTF control}
  RichEdit.Enabled:=False;  {disable the RTF control altogether, to get rid of the cursor}
  RichEdit.ReadOnly:=True;  {don't allow the rich text to be changed}
  RichEdit.TabStop:=False;  {don't allow the rich text to tabbed to}
  RichEdit.ParentColor:=False;  {don't use the parent color}
  RichEdit.ParentCtl3D:=False;  {don't use the parent's Ctl3D style}
  RichEdit.ParentFont:=False;  {don't use the parent font}
  RichEdit.Font:=Font;  {set the RichEdit to the same font as the button}
  RichEdit.Color:=Color;  {set the RichEdit to the same color as the button}
  if csDesigning in ComponentState then {if we are designing the component}
  begin
    RichEdit.Paragraph.Alignment:=taCenter; {center the text}
    RichEdit.Lines.Add(Name); {show the name of the control}
  end;
end;

procedure TRichButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TRichButton.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if Parent<>Nil then {if we have a parent (for some reason, we must have this or an error will occur upon creation)}
    RichEdit.Color:=Color;  {set the RichEdit to the same color}
end;

procedure TRichButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  RichEdit.Font:=Font;  {set the RichEdit to the same font}
end;

procedure TRichButton.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TRichButton.CMIsToolControl(var Message: TMessage);
begin
  if not FLocked then Message.Result := 1;
end;

procedure TRichButton.Resize;
begin
  RichEdit.BoundsRect:=GetWorkRect;  {change the size of the RTF control}
  if FullRepaint then Invalidate;
  if Assigned(FOnResize) then FOnResize(Self);
end;

procedure TRichButton.WMSize(var Message: TWMSize);
begin
  inherited;
  if not (csLoading in ComponentState) then Resize;
end;

procedure TRichButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); {modified from TTransBitmap}
var
  rect:TRect;
  overControl:Boolean;
begin
  inherited MouseDown(Button, Shift, X, Y); {call the inherited MouseDown() procedure}
  rect:=GetWorkRect;  {find the working area of the button}
  overControl:=(X>=rect.Left) and (x<=rect.Right) and (y>=rect.Top) and (y<=rect.Bottom); {see if the mouse is inside the pressable part of the button}
  if (overControl) and (Button=mbLeft) and (FState<>stDisabled) then {if this was the left mouse button, and the button isn't disabled}
  begin
    MouseCaught:=True;  {show that the left mouse button has been pressed down on the button}
    OrigState:=FState;  {keep track of the original state of the button, in case we allow it to stay down}
    if FState<>stDown then  {if the button isn't down already, put it down}
    begin
      FState:=stDown; {put the button down}
      Realign;  {realign the controls in the button}
      Invalidate;  {invalidate the button for repainting}
    end;
  end;
end;

procedure TRichButton.MouseMove(Shift: TShiftState; X, Y: Integer); {modified from TTransBitmap}
var
  newState:TRichButtonState;
  needRepaint:Boolean;
  newHasFocus:Boolean;
  rect:TRect;
begin
  inherited MouseMove(Shift, X, Y); {call the inherited MouseMove() procedure}
  needRepaint:=False; {assume we don't need to repaint the button}
  rect:=GetWorkRect;  {find the working area of the button}
  newHasFocus:=(X>=rect.Left) and (x<=rect.Right) and (y>=rect.Top) and (y<=rect.Bottom); {see if the mouse is still inside the button}
  if HasFocus<>newHasFocus then {if we have went to a different focus state by the mouse movement}
  begin
    HasFocus:=newHasFocus;  {show our new focus state}
    needRepaint:=FFocus;  {if should accept show focus, we should repaint}
  end;
  if MouseCaught then {if the mouse was originally clicked on the button}
  begin
    if not FAllowDown or (OrigState<>stDown) then {if we don't allow the button to be down (or it isn't down, anyway)}
    begin
      if HasFocus then  {update the state of the button, based on whether the mouse is inside the button or not}
        newState:=stDown  {if the mouse is inside, put the button down}
      else                  {if the mouse is outside}
        newState:=stUp;       {bring the button up}
      if newState<>FState then  {if the state has changed}
      begin
        FState:=newState; {change the state permanently}
        needRepaint:=True;  {show that we should repaint the button}
      end;
    end;
  end
  else  {if the mouse is just moving over the control, and wasn't originally click in the control}
    MouseCapture:=FFocus and HasFocus; {if we should show focus, and we have the focus, send messages to the control so we'll know when we lose focus}
  if needRepaint then {if we need to repaint}
  begin
    Realign;  {realign the controls in the button}
    Invalidate;  {invalidate the button for repainting}
  end;
end;

procedure TRichButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); {modified from TTransBitmap}
var
  overControl:Boolean;
  rect:TRect;
begin
  inherited MouseUp(Button, Shift, X, Y); {call the inherited MouseUp() procedure}
  if MouseCaught then {if the mouse was originally clicked over the control}
  begin
    MouseCaught:=False; {show that the mouse is no longer caught}
    rect:=GetWorkRect;  {find the working area of the button}
    overControl:=(X>=rect.Left) and (x<=rect.Right) and (y>=rect.Top) and (y<=rect.Bottom); {see if the mouse is still inside the button}
    if FAllowDown and overControl then  {if we should allow the button to stay down, and the mouse button was released over the control}
    begin
      if OrigState=stDown then FState:=stUp else FState:=stDown;  {set the new state to the opposite of what it was originally}
    end
    else  {if this is a typical "non-stay-down" button}
      FState:=stUp; {the button goes up after the mouse is released}
    HasFocus:=False;  {show that we no longer have the focus}
    Realign;  {realign the controls in the button}
    Invalidate;  {invalidate the button for repainting}
    if overControl then Click;  {if they released the mouse button over the control, call the OnClick() event}
  end;
end;

function TRichButton.GetWorkRect:TRect;  {modified from TTransBitmap}
var
  delta:Integer;  {number of units to remove from left, right, top, and bottom to get the work rectangle}
begin
  delta:=FBorderWidth;  {always start with the border width}
  if FFocus then    {if we show the focus when the mouse moves over the button}
    Inc(delta, FFocusWidth);    {allow for the focus rectangle}
  if FBevelOuter<>bvNone then {if we have an outer bevel}
    Inc(delta, FBevelWidth);  {take the outer bevel away from our work rectangle}
  if FBevelInner<>bvNone then {if we have an inner bevel}
    Inc(delta, FBevelWidth);  {take the inner bevel away from our work rectangle}
  Result:=GetClientRect;  {get the coordinates of the control}
  InflateRect(Result, -delta, -delta);  {remove the non-work areas from our work rectangle}
end;

procedure TRichButton.AlignControls(AControl: TControl; var Rect: TRect);
var
  BevelSize: Integer;
begin
  BevelSize := BorderWidth;
  if BevelOuter <> bvNone then Inc(BevelSize, BevelWidth);
  if BevelInner <> bvNone then Inc(BevelSize, BevelWidth);
  InflateRect(Rect, -BevelSize, -BevelSize);
  inherited AlignControls(AControl, Rect);
end;

procedure TRichButton.ReadData(Reader: TReader);
begin
  ShowHint := Reader.ReadBoolean;
end;

procedure TRichButton.Paint;
var
  Rect, WorkRect:TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
  procedure AdjustColors(Bevel: TPanelBevel); {routine supplied by Borland, optimized in TTransBitmap, further optimized in TRichButton}
  begin
    if (Bevel=bvLowered) or (FState=stDown) then {if the bevel is lowered and the button is up}
    begin
      TopColor:=clBtnShadow;          {show the top and bottom colors normally}
      BottomColor:=clBtnHighlight;
    end
    else      {if the bevel is not lowered}
    begin
      TopColor:=clBtnHighlight;  {switch the top and bottom colors}
      BottomColor:=clBtnShadow;
    end;
  end;
begin
  Rect:=GetClientRect;  {get the rectangle that outlines the control}
  WorkRect:=GetWorkRect;  {get the working area}
  if FState=stDown then {if the button is down}
  begin
    OffsetRect(WorkRect, 2, 1);     //move the text down and to the right to similate a click
    InflateRect(WorkRect, -2, -1);  //
  end;
  RichEdit.BoundsRect:=WorkRect;  {make sure the RTF control is positioned correctly}
  RichEdit.Refresh; {make sure that the RTF control is updated (we only need this if the button has been hidden; there should be a way to make this more efficient)}
  RichEdit.Invalidate; {make sure that the RTF control is updated (we only need this if the button has been hidden; there should be a way to make this more efficient)}
  RichEdit.Update; {we need to call both Invalidate and Update; Refresh apparently does *not* do this inside the Paint procedure}
  if FFocus then  {if we should show the focus when the mouse is over the control}
  begin
    if HasFocus then  {if we do actually have the focus}
      Frame3D(Canvas, Rect, FFocusColor, FFocusColor, FFocusWidth)  {show the focus}
    else  {if the mouse isn't over the button}
      Frame3D(Canvas, Rect, clBtnFace, clBtnFace, FFocusWidth); {show the focus outline normally}
  end;
  if BevelOuter<>bvNone then  {if we have an outer bevel}
  begin
    AdjustColors(BevelOuter); {determine the colors to use for the outer bevel}
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth); {draw the outer bevel}
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth); {draw the border}
  if BevelInner<>bvNone then  {if we have an inner bevel}
  begin
    AdjustColors(BevelInner); {determine the colors to use for the outer bevel}
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth); {draw the inner bevel}
  end;
end;

procedure TRichButton.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TRichButton.SetAllowDown(Value:Boolean);  {modified from TTransBitmap}
begin
  if FallowDown<>Value then {if the value is really being changed}
  begin
    FAllowDown:=Value;  {update the variable}
    if (not FAllowDown) and (FState=stDown) then  {if we shouldn't allow the button to be down, but it is}
    begin
      FState:=stUp; {bring the button up}
      Realign;  {realign the controls in the button}
      Invalidate;  {invalidate the button for repainting}
    end;
  end;
end;

procedure TRichButton.SetBevelInner(Value: TPanelBevel);
begin
  FBevelInner := Value;
  Realign;
  Invalidate;
end;

procedure TRichButton.SetBevelOuter(Value: TPanelBevel);
begin
  FBevelOuter := Value;
  Realign;
  Invalidate;
end;

procedure TRichButton.SetBevelWidth(Value: TBevelWidth);
begin
  FBevelWidth := Value;
  Realign;
  Invalidate;
end;

procedure TRichButton.SetBorderWidth(Value: TBorderWidth);
begin
  FBorderWidth := Value;
  Realign;
  Invalidate;
end;

procedure TRichButton.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TRichButton.SetFocus(Value:Boolean);  {modified from TTransBitmap}
begin
  if FFocus<>Value then {if the value is really being changed}
  begin
    FFocus:=Value;  {set the new value}
    Realign;  {realign the controls in the button}
    Invalidate;  {invalidate the button for repainting}
  end;
end;

procedure TRichButton.SetFocusColor(Value:TColor);  {modified from TTransBitmap}
begin
  if FFocusColor<>Value then {if the value is really being changed}
  begin
    FFocusColor:=Value; {change the value}
    Invalidate;  {invalidate the button for repainting}
  end;
end;

procedure TRichButton.SetFocusWidth(Value:TWidth);  {modified from TTransBitmap}
begin
  if FFocusWidth<>Value then {if the value is really being changed}
  begin
    FFocusWidth:=Value; {change the value}
    Realign;  {realign the controls in the button}
    Invalidate;  {invalidate the button for repainting}
  end;
end;

function TRichButton.GetLines:TStrings;
begin
  Result:=RichEdit.Lines;  {get the richedit's lines}
end;

procedure TRichButton.SetLines(Value:TStrings);
begin
  RichEdit.Lines:=Value;  {set the richedit's lines}
end;

procedure TRichButton.SetState(Value:TRichButtonState); {modified from TTransBitmap}
begin
  if FState<>Value then {if the value is really being changed}
  begin
    if (Value=stDown) and (not FAllowDown) then {if they want the button down, but we don't allow it}
    begin
      if FState=stUp then {if the button is up, disable it, otherwise, bring it up}
        FState:=stDisabled
      else
        FState:=stUp;
    end
    else  {if they want to bring the button up, or they want to put it down and we allow it (or they want to disable it)}
      FState:=Value;  {actually change the state of the button}
    Realign;  {realign the controls in the button}
    Invalidate;  {invalidate the button for repainting}
  end;
end;

end.
