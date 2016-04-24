(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0333.PAS
  Description: Nice Various Button Components
  Author: ENDRE I. SIMAY
  Date: 08-30-97  10:09
*)

UNIT DrawnBtn;
(********************************************************************
  TDrawedButton Component For Delphi.
  It Is A "Blank" Component Defined For Buttons Which Have Different
  Active Shape Like Triangular Or Card Figure Caro.

  TNArrowButton Component For Delphi.
  It Was Developed According To TArrowButton Component Authoring
  Originally By Kent Miller  Frederick, MD (Compuserve: 74113,200)

  TNArrowButton Component Will Give A Similar Triangle Button As
  TArrowButton Component But It Is INHERITED From A TDrawedButton Class
  Developed For More Correct Cursor-Image Handling And Support OnMouseMove,
  PopupMenu, And Others As Left Mouse Button.

  TCaroButton Component For Delphi.
  It Will Give A Button Which Has Similar Active Shape To
  Card Figure Caro.

  Author:  Endre I. Simay;
           Budapest, HUNGARY; 1997.

  Freeware: Feel Free To Use And Improve, But Mention The Source

  This Source Is Compatible With Both DELPHI 1.0 & DELPHI 3.0
*********************************************************************)

INTERFACE

USES
  SysUtils, WinTypes, WinProcs, Messages, Classes,
  Graphics, Controls, Menus;

CONST
  { offset from border of control to corner of button }
  S_OFFSET = 3;

TYPE
  TDrawedButton = Class(TGraphicControl)
  PRIVATE
    { Private declarations }
  Protected
    { Protected declarations }
    FButtonColor: TColor;
    FButtonDown: Boolean;
    FRgn: HRgn;
    FInnerCursor:TCursor;
    PROCEDURE FreeRegion;
    PROCEDURE MoveButton; VIRTUAL;
    PROCEDURE SetInnerCursor(Value: TCursor);
    PROCEDURE SetButtonColor(Value: TColor);
    PROCEDURE WMLButtonDown(VAR Message: TWMLButtonDown);
                      Message WM_LBUTTONDOWN;
    PROCEDURE WMLButtonUp(VAR Message: TWMLButtonUp);
                      Message WM_LBUTTONUP;
    PROCEDURE WMRButtonDown(VAR Message: TWMRButtonDown);
                      Message WM_RBUTTONDOWN;
    PROCEDURE WMMButtonDown(VAR Message: TWMMButtonDown);
                      Message WM_MBUTTONDOWN;
    PROCEDURE WMMouseMove(VAR Message: TWMMouseMove);
                      Message WM_MOUSEMOVE;
  PUBLIC
    { Public declarations }
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;
  Published
    { Published declarations }
    Property ButtonColor: TColor Read FButtonColor Write SetButtonColor;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor:TCursor Read FInnerCursor Write SetInnerCursor;

    Property OnMouseMove;
    Property OnClick;
  END;

  TButtonDirection = (ArwUP, ArwRIGHT, ArwLEFT, ArwDOWN);

  TNArrowButton = Class(TDrawedButton)
  PRIVATE
    FDirection: TButtonDirection;
    FPnts: ARRAY[1..3] OF TPoint;
    PROCEDURE SetDirection(Value: TButtonDirection);
  Protected
    PROCEDURE Paint; Override;
    PROCEDURE DrawUpArrow;
    PROCEDURE DrawRightArrow;
    PROCEDURE DrawDownArrow;
    PROCEDURE DrawLeftArrow;
    PROCEDURE MoveButton; Override;
  PUBLIC
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;
  Published
    Property ButtonColor;
    Property Direction: TButtonDirection Read FDirection Write SetDirection;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor;

    Property OnMouseMove;
    Property OnClick;
  END;

  TCaroButton = Class(TDrawedButton)
  PRIVATE
    { Private declarations }
    FPnts: ARRAY[1..4] OF TPoint;
  Protected
    { Protected declarations }
    PROCEDURE Paint; Override;
    PROCEDURE DrawCaro;
    PROCEDURE MoveButton; Override;
  PUBLIC
    { Public declarations }
    CONSTRUCTOR Create(AOwner: TComponent); Override;
    DESTRUCTOR Destroy; Override;

  Published
    { Published declarations }
    Property ButtonColor;
    Property Enabled;
    Property ParentShowHint;
    Property ShowHint;
    Property Visible;
    Property PopupMenu;
    Property InnerCursor;

    Property OnClick;
    Property OnMouseMove;
  END;

PROCEDURE Register;

IMPLEMENTATION

CONSTRUCTOR TDrawedButton.Create(AOwner: TComponent);
BEGIN
 INHERITED Create(AOwner);
 Parent := TWinControl(AOwner);
 FRgn := 0;
END;

DESTRUCTOR TDrawedButton.Destroy;
BEGIN
IF FRgn <> 0 THEN FreeRegion;
INHERITED Destroy;
END;

PROCEDURE TDrawedButton.SetButtonColor(Value: TColor);
BEGIN
  IF Value <> FButtonColor THEN
    BEGIN
      FButtonColor := Value;
      Invalidate;
    END;
END;

PROCEDURE TDrawedButton.FreeRegion;
BEGIN
  IF FRgn <> 0 THEN
    DeleteObject(FRgn);
  FRgn := 0;
END;

PROCEDURE TDrawedButton.MoveButton;
BEGIN
END;

PROCEDURE TDrawedButton.WMLButtonDown(VAR Message: TWMLButtonDown);
BEGIN
  { if mouse is clicked on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
  BEGIN
     SendMessage(Parent.Handle,WM_LBUTTONDOWN,0,0);
  END
 ELSE
  BEGIN
   FButtonDown := True;
   MoveButton;
   INHERITED;
  END;
END;

PROCEDURE TDrawedButton.WMLButtonUp(VAR Message: TWMLButtonUp);
BEGIN
  { if button is down and mouse is released then
    make the button appear raised }
  IF NOT FButtonDown THEN
  BEGIN
   SendMessage(Parent.Handle,WM_LButtonUp,0,0);
  END
  ELSE
  BEGIN
   FButtonDown := False;
   MoveButton;
   IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
      Cursor:=Parent.Cursor;
   INHERITED;
  END;
END;

PROCEDURE TDrawedButton.SetInnerCursor(Value: TCursor);
BEGIN
  IF Value <> FInnerCursor THEN
    BEGIN
      FInnerCursor := Value;
    END;
END;

PROCEDURE TDrawedButton.WMMouseMove(VAR Message: TWMMouseMove);
BEGIN
 {mouse move reaction only on the buttonimage}
IF NOT FButtonDown THEN
 IF PtInRegion(FRgn, Message.Xpos, Message.Ypos) THEN
  BEGIN
  {set the cursor to the one defined for buttonimage}
   Cursor:=FInnerCursor;
   INHERITED
  END
 ELSE
  BEGIN
  {set the cursor to the one defined for Parent of button}
   Cursor:=Parent.Cursor;
   SendMessage(Parent.Handle,WM_MouseMove,0,0);
  END;
END;

PROCEDURE TDrawedButton.WMRButtonDown(VAR Message: TWMRButtonDown);
BEGIN
  { if mouse is clicked by right on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
   SendMessage(Parent.Handle,WM_RButtonDown,0,0)
   ELSE
  INHERITED;
END;

PROCEDURE TDrawedButton.WMMButtonDown(VAR Message: TWMMButtonDown);
BEGIN
  { if mouse is clicked by middle on the button make it appear sunken }
  IF NOT PtInRegion(FRgn, Message.XPos, Message.YPos) THEN
   SendMessage(Parent.Handle,WM_MButtonDown,0,0)
  ELSE
  INHERITED;
END;

CONSTRUCTOR TNArrowButton.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [CsClickEvents, CsCaptureMouse];
  Width := 33;
  Height := 33;
  FDirection := ArwDown;
  FButtonColor := ClBlue;
  FRgn := 0;
  FButtonDown := False;
END;

DESTRUCTOR TNArrowButton.Destroy;
BEGIN
  IF FRgn <> 0 THEN
    FreeRegion;
  INHERITED Destroy;
END;

PROCEDURE TNArrowButton.Paint;
BEGIN
  INHERITED Paint;
  FreeRegion;
  CASE FDirection OF
    ArwUP: DrawUpArrow;
    ArwRIGHT: DrawRightArrow;
    ArwDOWN: DrawDownArrow;
    ArwLEFT: DrawLeftArrow;
  END;
END;

PROCEDURE TNArrowButton.DrawUpArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  { create border region for button }
  FPnts[1] := Point(Width DIV 2, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, Height - S_OFFSET);
  { save region to capture mouse clicks }
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  { draw black border around button }
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  { create region within black border for button }
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 4);
  Dec(FPnts[2].Y, 2);
  Inc(FPnts[3].X, 3);
  Dec(FPnts[3].Y, 2);
  Canvas.Brush.Color := FButtonColor;
  { draw button }
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawRightArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height DIV 2);
  FPnts[3] := Point(S_OFFSET, Height - S_OFFSET);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Inc(FPnts[1].X, 2);
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 3);
  Inc(FPnts[3].X, 2);
  Dec(FPnts[3].Y, 3);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawDownArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(Width - S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width DIV 2, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, S_OFFSET);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Dec(FPnts[1].X, 3);
  Inc(FPnts[1].Y, 2);
  Dec(FPnts[2].Y, 3);
  Inc(FPnts[3].X, 2);
  Inc(FPnts[3].Y, 2);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.DrawLeftArrow;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;
  FPnts[1] := Point(Width - S_OFFSET, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height - S_OFFSET);
  FPnts[3] := Point(S_OFFSET, Height DIV 2);
  FRgn := CreatePolygonRgn(FPnts, 3, ALTERNATE);
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);
  Dec(FPnts[1].X, 2);
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 2);
  Dec(FPnts[2].Y, 2);
  Inc(FPnts[3].X, 3);
  Canvas.Brush.Color := FButtonColor;
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TNArrowButton.MoveButton;
BEGIN
  INHERITED MoveButton;
  IF NOT FButtonDown THEN  { button is in up position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for raised look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := ClWhite;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END
  ELSE  { button is in down position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for sunken look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := FButtonColor;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END;
END;

PROCEDURE TNArrowButton.SetDirection(Value: TButtonDirection);
BEGIN
  IF Value <> FDirection THEN
    BEGIN
      FDirection := Value;
      Invalidate;
    END;
END;

CONSTRUCTOR TCaroButton.Create(AOwner: TComponent);
BEGIN
  INHERITED Create(AOwner);
  Parent := TWinControl(AOwner);
  ControlStyle := [CsClickEvents, CsCaptureMouse];
  Width := 25;
  Height := 40;
  FButtonColor := ClMaroon;
  FRgn := 0;
  FButtonDown := False;
END;

DESTRUCTOR TCaroButton.Destroy;
BEGIN
  IF FRgn <> 0 THEN
    FreeRegion;
  INHERITED Destroy;
END;

PROCEDURE TCaroButton.Paint;
BEGIN
  INHERITED Paint;
  FreeRegion;
  DRawCaro;
END;

PROCEDURE TCaroButton.DrawCaro;
BEGIN
  Canvas.Brush.Color := ClBlack;
  Canvas.Pen.Color := ClBlack;

  { create border region for button }
  FPnts[1] := Point(Width DIV 2, S_OFFSET);
  FPnts[2] := Point(Width - S_OFFSET, Height DIV 2 );
  FPnts[3] := Point(Width DIV 2, Height-S_OFFSET);
  FPnts[4] := Point(S_OFFSET,Height DIV 2);

  { save region to capture mouse clicks }
  FRgn := CreatePolygonRgn(FPnts, 4, ALTERNATE);

  { draw black border around button }
  FrameRgn(Canvas.Handle, FRgn, Canvas.Brush.Handle, 2, 2);

  { create region within black border for button }
  Inc(FPnts[1].Y, 3);
  Dec(FPnts[2].X, 3);
  Dec(FPnts[3].X, 1);
  Dec(FPnts[3].Y, 2);
  Inc(FPnts[4].X, 2);
  Inc(FPnts[4].Y, 1);
  Canvas.Brush.Color := FButtonColor;

  { draw button }
  Canvas.Polygon(FPnts);
  MoveButton;
END;

PROCEDURE TCaroButton.MoveButton;
BEGIN
INHERITED MoveButton;
  IF NOT FButtonDown THEN  { button is in up position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for raised look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
        Pen.Color := ClWhite;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[4].X, FPnts[4].Y);
      END
  ELSE  { button is in down position }
    WITH Canvas DO
      BEGIN
        { draw lines around button for sunken look }
        Pen.Color := ClBlack;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[4].X, FPnts[4].Y);
        Pen.Color := FButtonColor;
        MoveTo(FPnts[1].X, FPnts[1].Y);
        LineTo(FPnts[2].X, FPnts[2].Y);
        MoveTo(FPnts[2].X, FPnts[2].Y);
        LineTo(FPnts[3].X, FPnts[3].Y);
      END;
END;

PROCEDURE Register;
BEGIN
 RegisterComponents('MyComps', [TNArrowButton]);
 RegisterComponents('MyComps', [TCaroButton]);
END;

END.

{ ------------------            CUT              ----------------------}

{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members. 

{ ------------------            CUT              ----------------------}



*XX3402-016356-050897--72--85-56169----DRAWNBTN.ZIP--1-OF--4
I2g1--E++U+++-4+-GA++++++++++++++++2++++F12q9p-9+kEI++6+0+02K8AW+-yCDy++
+++w+k++2++++2ElBWx2IY3LHY7IHWt2Ep9BIYgCUm+ETRMiHQFRZppqGR6HqCtfMalu5NQx
3UTUAdu+nU+no8E9ZloELhsbCa+sM5aAwnmxPgxZaFuktho+3k0bz1EsUijQs8iAcXJCf4jO
S1-3WrCCa-+bEYUP1uNciSuihY-PMpQk8hktBRbC3ymxjVDSOu+Xr8fRGs1g4U-XdrM7F5gC
F5gCQ5hIAG1bF0NPsFoJu5fisnnxlyLM0ZQBq8NMANVKuK4+ocA6H6j+R-MGbMF2Fo3c3akj
D7akNNcDhJROVDFtIH-mUNjEIH1ZFxV8AvP5nluzSgzp+J-9+kEI++6+0+1j1UIXT2-fiZ2N
++0EEU++2++++2ElBWx2IY3LHY7IHWt2EpLhKkhsJ2KKfieyzStCiU27M1+w+m8Ec32U-2Z6
WC2FocE2sWWE++p7lCtAG5UDUV+HN21Y4G64F55EEPwcwb7Zu+xtsncmsmUsgAD5m2haU53l
M4RlgjythqvrjEZ6L5KQrKzOvz-LbLDeJBKdeZBp8qJOOasjVhwNZgwqSuePPKWiz-TR6fv3
EmrKhulqb9y9gLkvuMlphKdKOOzXyEvKtBxQo3xBX8rXGbsghzBGbaBLQfZalUNnTMYnc9qw
27723qDLKMftpdMfSM6cyGNj96rVgoDZHBOooc9dzc3ZTgNyTjRpdGoawwWNIwhwHn8K2425
UtASK9ZZFJCaAdNwAsNTJtWXWzktAohwMAv6Ho1nJOOrB1+-n0jL-zAMVNbdanepM17d1jGC
FTC6OIaRIX-p8j4yCZv8-mi8XtEKZ-EKISanzp57lmfAp60zf1F+ZPyuPlqQF2lHdgxT1guV
zhFVOeNpt9WgxDGFUr6SttkPtTsNL1bIERz2USJZNE5z0LuNqNWhVkErkc56AKP9Z4FJ7KRZ
FggOKLercMRVThM8zXVsX3qfJlnaYTyBM4aaewNOIufoUKaZAJcekH0aChCJGZ61Ik8ZpeIk
a43sYgy3eJG528I3djihmm2NPtX1eQqdIbfqN9xp-JXZVUm3tIkTvDTvGZD9GuT0nWe6ZVYm
L0iUY4ND9zLtgbqHWk7yXxIBGLs2MlMLBL0vEKbUS4VZ-ePtZ+cxfJd-uqQFSI9fd22RyPG6
YPsmHIISOnhcgYXJbYBq64RIAxxiYBIpzTBMio6x9ZFxcZ0b1eDTOOvFaQD0TTMssu3R2w2B
WbOVo5unPGu5ux6Q6SrQ2cyn1rHzDQ6UR3ReRLj6ZfCpZdCVDH3G2hdvhRcbNSpAfLM4hBR2
KcHqJOqqkoXhm+mIHzKF+npC9rFvFH8V4mpdR+iBYXapp3REtijJ8UxedprRVGBGVJe2jMV4
Iv8YyONWvgsQoGcTSgoWPhMfSdCIKMQ4ilkOjr7ms2dd8OijRlUjomeXINY5a2SZZVZQZY5y
Uj3HT-AtnO-TGRqUqG7u-JQp0KqmTJS2hu1ItmwPKFWMbZ5Y9tA9L724co-BKro-WXYf7NRJ
dxf4Z+3JDpGvhpb-pJMstA3qKIMJHGp0AqHBBBCxo9nv5fpF7yVLYgja1NGIZx-WtFiOPy6Z
daHc2abvVb14qdVQ1gq2t1HnOYqfc5bGcDR2VCktZmD95lchzY9n3Tk1InOogljMldFaJmGL
7QiTCeJckVBwbv26sZbEahJ+our215SCa133dPs7NJVfPjBZ95krqY1labsoPsVfRPSHwtH4
e7hGGeTbSdKAD+qgM4EDTWEXVrV89CMKw6MBGdRNVX+f9KjoQ483+hTkZB9Gk5GZ8QgVO0w5
9cfRRQWRs4fUedCf8oHUSYKKTakyNuNUxXVs39WimzIq2s3fcuqfxOOhrBfBTgswrDcVdgc0
SrecdxMpA3RjJbekk7HixNRBhJO1pxjGlL8NiREy0-REcCLmE4A5ABv5apicr26bMYL6dARO
Uj65rKeYa4VF9+WDd7aw-NVlbZMncBLObGCo8WmVECKU07tP6bj1Mto5hMR0lfM6hRuKh+VG
mmuOL3UaB8iUCH8YyIbMc6go8Fk6lKJE9+YdpUj3WFN3QNVjYaeF592YdBXJeWVigSUXvUNc
jStK6ytkcJJj1YSAnR+s2eZ4X58f7a7IK1EFcktuBmDJW33hJLjEC46Qg4cXFdot514efGtP
O0ksCTp9157xTKy9LhQXyoUTLO7hqiV0aadoCK0xNLH7h4aXWpe+cgiLpUPFNMNB4prIJXXY
+R-5ZsoqPLFFXR8YWvMpX0sTqfHFFPJ8oKK4fL3oiKbHFVRJyrPFdNhR4ppIPMciaPNjWWue
7YKLS9D-YNBOI-dE-f16TdbpYdQp5TgeYJhiJdQptFXPWKLx0pbuGzhiiv8gRwf9igugDMxI
CFARHZSZsknwYixsllZSjKhUuGjvKPhyxIeVpSgCfRtXQcqV-FZ2kIQwuc7g4HfNdgZbFie2
lrc6CVAxcIB+K2Sr6Xu0pbmDiW9IAz7iSrV356T41PSu6WcRaVLFoe3N2OSVpwqXfcXL5PRT
2QQRqVJFOEyj04XfNfb-eNrZd8bCwhQRhtnZ1nWpgpkhE9Dwi8D-9-zfpAtmhFLIv8zgyZZS
tRHCQhIcnL81gy2gTwSdbSKeJNfZMtqBNzYNdrOKexcomlxkuiShouKRhueaynPfUH5hSZ0p
6qJhmIebJ5l2Z59f-SFftHYWzJBxzGVEvt9rQrB8pbGsfPpHDiTFlDj0NNF4yeNAEXL2cYw5
dIGo50-0khGEg0w2aMfEB8dUGfajjJoyFWgT+O20l+dP8xNPKqPE0WjpkiousPi8o06yfHfP
tIAs5IxTWEUJGRFJxiR4FEd3YIz1FEd1FSkMn5gWxFqW9kWOJNdabREpOoFYkneiWXfuFMO8
LBIpOq4X6Wh32Lysm2dRYFqBWikJFJs83xaf8r6lgg36oxNA6zpli+Glu8mZZ10vRSsjpkYv
ucJof+Y9YzL00dpkX3usFGSQdFRycVCioEjfRQ7rxA8icRMSUy0gKnyAjGrecHJIc9TCKdGb
UPQcP7Cr17tE0K9F3eOIGD1cuezI0ITcVJzNhI8zLhVGJr8lLdWc2uezSjmIZ56Sxkdybg+G
UFY0wkIK0dkbg2fU163x-0M9P0LgTmHm4kFi3ZUbQ8T+cA-1+dQ7f-PMJRWv6D7L-RsES3nU
OFPuce-xWPLXpByTw4KAw43aZT3NZ0SQknT6K0LmSI7jf8Wh1t0wac7mvM2xQ+V6Y6wFJXM6
y+HOBJ9qFXmPEZARTD7A-IfK+-y3T9j+kw1Jo1gdvDsbo6SIF3QND7yp+GM0Ys1xUMw8zXHU
eqULFN9igDwS7yz2gpxnlQtNaRyCzFJMmUiNlO1cllhcrwZUXldcp26rJF9Hr3+BstePeHma
iN4OknErIFBNy+Ne5xTQD7JknMqHlBGPdV7Xu9MAAHzVgMgRb4bN8OC51wkNrhCPEUtXpnXh
3Qz76qpWfNcrgoTFzf0OpWsgqNit6WbwfoDyFKNVxWXKrAMY0jePk5cJNSkCipqWE9w3X1Tk
UKWL86PHl5c97nUvWqNh6PLNr2mWG9p5baJiCbssK-hN2boLN-GIXo5q4sfX9XVMYaAiC7z7
qcvKX2KuuTjnffNAci-u0SYzIOBMR+lnGlEwfx3-7QmWuDUpK5x5JSWPnSOoFJXAIFELuNvE
kObt3ZQYlI6D4AqsbRbhRej9vMtU2UL-hi1SkpiWsp4gEsRc3gLWaAqALljKlWZF75kE4Uxl
1qaov-kR3OR66OF6aA5dK0+9Mnerp+Ud2Xv4uIWf01j2O6EI0ToE-bVPF9+6-7168DmOFoIN
ASIdQnTZaIEFQ+YIZr89v1AA1MKspK0hEJSI9bjEMsdh4w3xKSollPDLk5WR4DV73ADek5U9
RJ7bKMTCbKAEJFYuX-uPn4NH4oNxdbV4QzuXCnKC1XqLgTmjQ6Z3hAIQC2CLIPkHnYFRK+x1
RtNVuA544remQYAQXV5lC0rokhNwDwsP1y+MY6-xzG3gcbqk8mNWzor0eGMNVtQIBYZ8MmiZ
ESlLIXev6Xr0uBsbnHGMZNW4g3fHADO-8FAbBGyyLPksQrZlBjCmEh-gQnMvNwv-ZqoixctF
q+5ngB2xWjrg7xWq5gDix1UqcH5MIwRVuwn5ZyVsT1RCk8TUF5mtyT1JB+ZTNNDNFZgVyx-K
l4vOba1Rv3DkgFD+ho2dxcVmP+LH2D4bMuSNVEpZBYvYHy4EDExbsjYsjHuBwys0TDcgNCws
8xUNNmJniedkCZmAjXr5jb-FzpOXzyhkB5g+DhY2bqm-9yfM8l5YXnrgosW5s8BXCCbQ1tyQ
MDoWYy0XGwkTGLuulZu8H2HvjqMTFp6Tv5mWlMBDx9NwWyJ-zcYZUxRP5iBRfLvSqv825rCD
EXhLMsCYhavYLxZTkwR95Ixoz7cbiWtnjygSxXb4u0bf9XNMCUmmw-BGBvsJbptPXRqFvU5g
0LkMB+1dN4+8Q0-c-B9Nk75+53+ioVC-Di+Yo4GY0zZUOHpk9z9jUzO-xWBz+5GEbq2lX0X8
q-BxnkKJgjJlgPnKq6ojFFheoMOZlVv+bblxL-9G1mAx+7UAGY3u6DVNG6x+CVgo2iYQM0vs
st4SW9EDC+Ys4JU6acPoBC-os5HU1C+As2nUHC-gs4nU5C+Qs+9U+i-0s29UAw-bU7L+Ga+J
g+es09U6xPs5r6jwyu-xGCw55U+S-5s8z-Fs55UQS+7s+jUNw1DUGS-7s0bU8S1bkAy-Ns3b
USS-ts2LU-S+3s2LUJw+jt1xSHJyAtgGqAcKZqw1vITu8CUIoiS-Zs3LUBS-BxXLxwLmq8Gi
zCjvYc1xUJZ+9r+wQ+9kDS+SqKtqEU8nqVxYlEYDgEvqrikDUzekITOyf0MVYPpWvwTyoWy7
LPLpVpsRixVq8vg7gherELwDxDS1RlGwcx+vUTEdd2x-znngL29yAj8LMSw8v3p1zXfmpq5r
VXkzzaN9-co1nE6x-zeODNbGUHyNoV5I0RELZ+Xe-lc4mUEB-so1tMA8yBxges5PEHh+Co4v
S4PeJR-To9xqP+nj1bc+Z+NOlmN87juvq-Wyf2oATxcMkvCuhCCDF9J1iVqzoPYfN3rtt1O2
QR07srziq+jdrYXrVYtjuDS-TVyYyo0zDqHxcIyM0dpIu8QVDEHd6R+N+jqVo-y8x31cSm5n
Edxk35F4ELwooaCE5UCRAR+T0zqlG6y3zUH67Y0Tg+UuFR+jVYstRAeVIwtbRNn4VrSQ1dk-
b+bN9AVawTrG9D-aUnQ5j8T-SlfuHsCr+9m3s3K+Js5wAwVL+ei+WzUessicuqrIxHPorsPS
JiVhFLcfqfA5gXpc1y2Vu-l0Sst0tlDcT+8RHq1bIxUt1Xk-z+mmroDqSvHbxy0R-CwIS5w2
vszEzmBsbsBr3flns7p1zXnm3s+LUJz6MnUYekjfvMc1rEwOkUNsbqS3QQgFmtSnGRupP29r
Zt1Tlge4PkDi-ytbPwNzUDE5o1y4x4bECSG7nYBy5bU3S+Js+rU1mDW5BgPvlb3ynQrtjs54
l-hsFPmFTtLJb9Tolc1OURQ-p-3wcYvUREL3ULe-ScDuE7s64J2ztDi1IY3dc04UcN+D+qJ0
bcaw3nE8B-co-XEKgb4UTAW70g0P+0c03MB8EIzl0RqLww8shKXnKfGt-aqiENhfICs3Z3a5
BjwGSay1hc8r5PE1z-r+bI0WLN1h+Fo05ELx3bFOxjRSbcpxC+Qo0XE-yE06xfbbEQilxux+
TXKk4bhRBR8ovxLWP20o+SYBs4q0z-SUnO1LYBw0eYBu8zP2fHV1vA6SyGtsSt-y5rEMyGCE
5wJSSFFwqWhzWnA4oSyEzVps7u-r2Xebg5yS+jwoS7SEjslxx19Gpt0yXfroCgsALqBjfgRy
GgHsCPD20o2x10Myra1a4EM9bqqq6yrYmkkibWd36Cx-iUJovy9ltdPMTpjm35AIxi+cZ4q3
***** END OF BLOCK 1 *****



*XX3402-016356-050897--72--85-62807----DRAWNBTN.ZIP--2-OF--4
TPUJnnKrlZvQ4fdhSPqt+ryHRk-q-5M2RU7qUgpMd4C-LM5REDS-icBuU5eW1L5+LhXDvsSR
-t5iWr7xUMb+F4+zM1yIHo6u0RUTy1-c+0UNZ+6O01idk1HM4EEvC0CMVu5QA4+aA-As51UQ
tPCEnU7uUGB+qO0Fc-lE9imA+cu4bHnMSEndQGUr1dUDn+QK++hETXnGss2HU-B-Dh+Yo4FE
6SkI+MhVtkbMwTDhVV9syOTUHEBB-wo+nEHB-go-9E+hF9Y8s1CUGZ+JO-589y3zBR3NtnaA
-x5nG1zDQymfwSJHXPADoJeITF5heIIxum5PWDEf4ABB4AxLYLwBuGos4vq-R-rTPRyCTak5
vU1i+Cs2vUHi+it0qTSETUys-vULx1tc5qUzu+1c6Ccv-1m8gxM5gDZfxD2MujsBS7y0XcBC
U1s1bEGR+boCCchmts1bEFR+3o3Tc6xLMSAjC3IDNxSllf9NYunC54+-hcVJsalOmiTmJR31
qJDwKFZzmzwUsqZyGQP4jnLg5zrHDrgkAKsk40E1je2Bhx8quBJJhcS3jbRhAaAdIqtNi5dZ
Agz8h-TjlCuaop3iohLfRa6BPWGrgkOLvAd3XLeVcpPZM3OhkfqBv1WNSe4irBW2PwXJyz5k
BHclJnLeHEHHLdsHKrj1fRtjOmz0tFgvnNqtSaCiLegP4zohCTHbMzbtXTnrsh+TWRKz18hz
1UuDo0gzkUnGzjrNcgyeGgr0AwHSt-amdd4CVxZozjbL5B9CcT0MzC6TDUioTumoO1DzWV4V
wPrHqBpdz5ALbSoJf743Qyqgn9fUHpMtJnwhcbuOgpTEiqyiqHlOkt9ngTjulxODGI8uJn-q
IQI8dP1ZCHBX0zON3uSP3sym5XtWNq5fI6pRg5g3UtMkdvAhZnT7mQB5n7dmWxDhWoRFdP5x
JWpXtNPMTVJ9KJZoa9o6yRV3Y8ahGXhwl5f9WiqlxRhKA7Id4bvsW8FFpiSc8-LNBlR3mmKE
KSPPUiIl7BjrgnOWyRt0PWVax7yQjRG-l+QeZXCihWcDfeiTNUzri52ftypSnZVthAugEKRq
d4cqpBawPqXXLO8Bs0JdFz4PqU4zmfuiK6KtU+lwh8f-W6GPCiIqBNSpJpepWhqanYjrrv7d
1Lr8h7pjv8ya1cqYwu5vnUDFJACKPqDsTvSwMUwCWfKnsjN0dvWxrZg58hMkMyl-9+54+AhM
DFDnKdYaDxWmp1J1ou-boO+YJatH-vdb2WxrOUPybWGX9VyFN0XLiImvzgWrggxrDwjUy2XJ
0LeqEpDxsY2RpismgCjztGoqVdW98ecdEhEk2jQkAWyk2u34Mlpdp97WsmpY4oWqYQozK6rt
L4kgtVcN52rBI8S2CbgOBhZPP0UqV-pSIMBFKz14CWPVrpda+4S1nBa6RDqqNEnz94pY-2J3
4klexvJX6+90Rr2VCbQ5hkbjzbWSetOxdTfD85jC65jCy4BuHYkyujzhL0VQxoqHHpToyrTS
4xKmkqdYVxK4bJTl6oyv7XWj8QiqwRnwEJmcbLw4rTfxTZmsIp6qZ+JzYjGlJRtomskLrpLg
9tdvwyTdTmSLBb-ZzPNeOYMBAXRpv5L2faoeSkClBqfMVTKgi-vNdZPLmA13jO5FzzOBPqFB
MEiDTshaTIQju0Tugwdt8F5PLdY5aRUed1EbITDrRE7cfGuVfjd7ELjzD4LjNnzirjz1Pi3f
O0ajjQBSx+6djLW5O9iSZ3uuPQlsaQGP21Bc56iZvqDDKWh5WlQcEWl-vEjSS2YC4GxHp8rM
lCsEByFq4DwVQKABBKBhcnLk+f3TP0dvDP3TOYfQi2pp9lBvovSC4oqpRgSswQBsUIP7YXYn
BT-YmJHxOCpV949oHgPSNKlFygp3czuyNCvBZeD3NwIr0UwT1Rp+-68ht7RXUG0xCVg4d3Ra
oGkjqAu8oEQK4VVn+oi+bM1n1DFG9GxM-Qk-oXiUDC+4+vpxmUg4UEb+Xkno7WcjS-nsCD+o
A+Z6xsXtk5kXDKP80wskocgqq+3C+Ksqogir+Q5XW21lE4OVCsw-EGgk1SWa7nJ+9uRrQkC0
yNlSd93UJlCxR4D-Rg+KgCCqogp767bHymYNgEfEjrXtvJQUG8zYOc1oGesKG8zgBU8xwdia
E97By6TSfYL05fp0Ogu4-iZ4d-Dse-DxNQ2u2vIb9xW8mmzst1npVxdJ6j9D6Nx51r96DmXr
Ui1LITwtjPnn-Lwejx190x9zjjYZvBCfhvwVDtzSgTA-kRPoJdo5UjE4vav6uPJT4L0149zB
MjnelDXxrlkrlRwoPer3i9ILsp+cXoAUO9jZC0VymE0KgD+s36hl8FLtNwKs9-TthwGsv-9X
gZjkTmD4tHAl9Zy8QKb-ZL47tgesx-5XwXXsEH2S5sblC0v4szHzYz4sJsl59n2Sx3fI7QP1
6wOXUlWDPg8DuQ9zkoJyYj0zLyGL0Dyj2jtT8zVj0jxj3zvzIDXzeZULBtXWxlNW5-6smb5t
RLnkUeGgTrd+pkJRdXxPN13J5UWutFSlSQ3sm1i1TpIWzsH98xVNxhjRhy0HULhcL6lIfbBk
AmPS+D6vt-B0SccwKgXj2yJ4IpmGsk94YwgLevSo5mjoyd6RSXscwjb0fZzMzJYHqfINwV3B
o8jHuOZyJDO39XFTkFx8TiLI1wKjZMrweikTXTqev0RicRQ4C2xyklg6oVjRzY+uW4M0uNLl
a30tcQ2eM3gULKQbo5mpY1wIT27U7TcFXoOzH5dM5ni+B-sTUJxZdLKgq9a91kpSVHmCTvDx
zU950tkfvBQ6yqw8ykS3zKD0XZDMXvq1zTE4vNwjv9wcv9wZv-wFxXwKRW83zLiPO9zkCzf5
6gs59MHx7013bt3+WYT36XxTt8i3rWw3TuzUbl1wzl7wBpTsLPX05wUJzeC0Lm9mZG7Tmlii
YuPBnzbTMLsSYjSLdgp1jw+J+hwKzjtEyDiAwDRz0ryPi46jHTVvv1ydjmDdrAHd-L+UiJ1S
lk9n04DEnkoKSVOgm-C+h-zoVNkkGQW5gTw-I2g1--E++U+6+AKmg06t300x-kU++4+E+++D
++++F12q9oB-IYx2FIoiF2BJlJRxP3DL3HzrTQJljYkyGaUURHcGVElE+e3WKY6yb4EFkxF9
GAUyo11B6n47vQFqU8kN-EaeF2EeaZUpXIp1qf8V8cVKqVxHhaYD0IoZ2h8YGF4Rh0t3fK-3
2tr4q1FFRPxnrvDxHAeozfAxyzXrnfbrRwvxDhRRUM2akbC51hAvFYpS-7x7T9NsLjEAS4tu
PcViZKV06R9cZ3NNqetQd3w7yeyTIrFA6vcYvXiQEm7THCPkSuJKeeHpXrB85nr3vsdsJSlo
OZsLRUzQHvKsaj4XtkL0WTWk4GJuRzKF5I+ryeSH8HMp3yT1U8ziUKYU3FZD2fIzfVODPCD-
GCn+x6E7swb1Cx5uh14IW9w2ssBzx6deqlUoYwbk0BTg1-p0usEADFtC7hbqxxiHchSiy8J2
S46okikDrbpJ598BULUgZMVnw7zSi6ElMeDS2ox2MPbJQlLxZTuu6i5ly+Vg5zvVifVYIvhD
dU8d-3DDLJt-lyrCd6MRsyG5xwJpqpzEX2r-wbPflq93fhOJ07y6RONWFDBJFDTNe-U5C4vH
wwdT87zmhqZmRheV2SI5BHaahiMVBSyWsB7VtPXmtueTW-bMWCtxMczwPjZPHBTI7KJJLN-n
j3rR+lSe2Ef5nD4aqFbFfdlLnaquVQ-e+IxItpEe3MwpnNt4mM6GwSP1hKfg0lzVuaRVL38K
0yxkxO9x5MZ2z2GOA6im3SIvFXvWeBtET47eUjjPB1iDUUT8tP85HB8vHoNGHPALM3BJHLoc
5WWOZzgPG7XVZ9aipsTCYIuIJyGFnSJ40n6I2U82QZQHUz4dd-aA5kSd2eEH4J70YXGPR36R
3O7NYDBnLh48C7m9v+TtXlbmhTx+LZ2obug-UT56GqDfSij-1lVdzeevlL-IaXB81eIFZ8YA
dIlnIF8etdJXt3HRXOczmpHRsutOdaY4hY6kCP9CosteCn8Rg-y3TXbL6DENB3rbcNT9Ghe7
S5Lxzow5EzsydritTIOz4Fgq2nJSIX44r2AMhLtnz4W56IrQNcBOxDrugAswJILLOsjZc5-D
MQbf1QS4lwrVKeyoQhRRHhVYCpbGLxSLxHTQMLpmgHZVxTvFmB3IHP4owGcscuhWe8NEugqq
Jz3JBBKZduBgnnHJPnnK4kqTYFAZwGZF2YuIiouIl-BF2aiX717Fy1ZW-6qQ6PmqRUWjtH+i
4ezYAZPLAZNn49wprgdZw9dxUZ5aX1+zby0ldxYjTrqIpWcZpZCfl2OeQcufOjhkQyfNhSP2
3Q3yBc9DiArlxYKIZk-r+Ki-ATVf-fN0vtNS8aZ+Sj4F8LSozSmXHCvFm7Jn8gaJOnnYmX43
tAchtNHB8S-bQkYcqFmmYR8tEuBgnY0JP8sc7pSC88FoPY0kP2vMHSbQWRNjzSP0wkK-XfsL
ive1qoARzTOYIAPIpFBYzShmenHUvTCYYjQtXFRx6xEawd6rHmRh2sw49x6KR5cDJmfFS1Jp
MimuQDFuGwd7swKm3lDnNTH+0tqLEUUHx-J5tsYSV8C1nDSa-zQC3YCdIY15ZI6uflHFUZ7A
Goc7fGUySe0gExB8gHr8g5Ufg-nLMs3JMgZgkAOglZao4SIBtBJ9cHRWbpTHTgVqhMLCu4Lo
CiEBm77S1bsbrRIfu152NpFUcno1TrgdO91D29pWgBx-SgjME92WbK8SIYUNOS14D-L+Ns1f
6NKE1TGyIUpg+1M0Kp1S0ik2-c-v6G566DdbG9YuJkpddDTbRh0ztbNFSCM3OTxxn2OjNmTp
8TOvdNF-8W+hYAuAXxFy9gyXiu8+vUpidF96pptcUrFHe4Z6Zf3APGeIi3FMH1wguc5gUzF7
qrmNXzu8QSLr+xsWShYckTVjVXFU19Q0SFlrE5PVjELGWHbd+Ss3vUC4U5r+EGeU4iGElOSQ
uFQzkurnTzAspmFv4vWi28lyuXK-0r7njnmJbYncAiChHRcmGXMl4tV-N-Rm9Z8bVIPiuxBN
sO5odIYIIitJOJvsm5J-iW18mPsK4IzhP7vHqvGSDFa6-iMyO98ynxMPdknXs0y6Zj0uVuVi
fXhOBnQEfrihSl8Gj9bgmOZQL5SyKqYZAJK13uqpWeMedERN51faCoPwYRfBtI7Ory2TWISD
y8DlNAcTBIRWoz5cO1Xphun9ry0qSH1fsiNmAHpfYy7XzdUNRPD0MnJ-KoixByODjdTk5kyD
VuDay5FYn8OYqdveCOrKrTXpKN2P9Hg7zaqNNW92KZytN+xhujWKrnpDbtLzl1lYv8v5h+tX
nQk1ryOA1zkRQ+Ns4rUOS2zZF4ZO5k2r+zw7D+josMUx+8k2BUDfUFS+XFcj-hBepzUwBupS
XJCTOEo-1rAwXJCSOIpcb7JAOlLsDFemuf5KIg-Fs0nkgg5byt1p7b+6q7u5DEwA+Pi+3b+M
S-gs0jk6C+vYDlkHnAQRQGiL+vx-PRNhUvBCayJ1jJtUG51WPtDxfmSmubKNs0qzneYEzGDC
TMjhUbs+ZskzFeNNZDM363w4TUvYt5w90-zo7m-bhcR+zexH67Xrf3+YDmsqWdSh8sUr8LtY
MJTEZ7Wp9C+ox35UhwJrfLgcDkBYzyT+ntTnh4VttDwford5hcigBrajkqyvjAUgbaMg6vCR
fwPfAyJ1QXtfeROuUcPjRCnJsBKUriRsj+JTMKlv+DMhTAhqv5pGfo7ChTKXHfoOq5bbpnbq
LMtxAylTU5q9MxyROMRdnKfQnbw1I2g1--E++U+6+9k-cm7FNO-Vzk2++DQ1+++D++++F12q
9oB-IYx2FIoiF2NBhND9XhAk36NBEiBQ88d49BWmMMbOSMBddcJeqWOO-bK9alua3esRCIsj
fwCK7Ew+9w-nw+-gq63XdnQ7nMuBRQvjbDnTCPPzV0UP7jSH5idqTfc6NSakuqJ16RSxZZaT
***** END OF BLOCK 2 *****



*XX3402-016356-050897--72--85-61313----DRAWNBTN.ZIP--3-OF--4
Xi4XQfwVBlC3yliptbGdJivL7xsvc+wftTt+C0O3cc7vhW+Q0evSl667WNzZP2vtIaknq8b6
PBUmtpRUgWZNUyTBxeK0hGqQeHq106Jrg2wZP0VgUrN8Rw183CG6tmjbUty8YhOCy5YVNfY2
s13k-R7DS0m-8A-VXK9X8C2HINIk2Fj+vJczda4BpE-pY7SBmE8MNpPPhqDPzblcywiVPOTH
ia5oUKCTg9tEGek1Yuwp-zMJgHmDK0BhZl8ivQnOq+peCzpjuzPeu2Owi78Z5aWEmzT3XNFW
4zNV+qn2CIXg9nPrV7Okh47GOKwQ91NXgEI7mtMx10xbPmLNylZN7567oY4DwIJNH8HcJvcr
5dr0-fFfE3xOI0QxQ3t5xWhfuCRgcUg31p7FJAI2S6L1MxW915nH4AtZ92JNLW0xCDAxeTeE
4QozsQvNfZ2EOaRHAlmfhgyHtW7zFlTYpzwapuDegkfy1zTJ-NPFUZge6HRL4VCtjIraIsFE
a-pBnynh+K1HFcG0f-N5yjao-XieSeT5C5WhwuBdO5OPAG5o3p-9+kEI++6+0+15evEW9B13
dO60++19-k++1k+++2ElBWx1EJ7DF2JB9Z--IvJIrqzOA--yFy7zi6R7o+aVxXKcaY6kLHEG
6V78ypENsY5KM2Sq8IKczzjw6k38KwcenMeIwzbiyyvCRlu5TU6StWkZmouxJeztMM74TRR1
SXCCIJmj+QEPANNN9ZckmKWm8MWJ6gtaGUe625WiRJuCVR101QT36hC55eCGAyKeQTeA9tKi
Zy4QnNK+beIbiQOBNJd8+O2fPQDlabMZBI5JOwZxV1F0cW4isBdGBQrqEVw+F7WGzAe-l+UR
exGdRJRGAedDxfjmS60bpgQ6dH7oCKTfjRTVjXG7K92eR8G4fxeIVyUtYpejJPsoRHIycu45
SiAFAaLkCA4GB4B0Iw8JwL1uVwnYlFjPUkE0hV6YM2xjj1cE9v9TIirBDtM8iEBr9Mg3QCy+
HmKN2rvlPWnz-TUUQ0zDNcyTdzeevaTua3eTg6p4zeqP6CiqVMVbHmc5GAYglln9X32-9wNk
r-rsrgtiBJKMvtURQeg70AEQafTi07GUPpnACu0rDn3BQt6uo4Ig7tVKUKyHFGN+TSg3Zf+k
JU9YUg0m586LrSqeVw8SuLk3JUqCPWbnhrAOF+AIc1-l2rwMOgrqqkWyhrjxk21gkvFCvRBB
poIrTeWNr87EaNiIqoBOXfNnPLBJVZJUvn1wOo3qb7sP6yrEfdsG4DNhjGP9VpxYoqBfuZEx
hpgvxuBZo0nQ738rhxmV5OrPlkQISqu251LDEdPQHFheOl6wS6BVX3eLfQjeyZshKsYDZJOe
mjKaK3ySOspypncOjP6K5WvolHbLXMWfP3FHBIv3wCLNzsEwN41sBPZxMRjvkpuKkXpPEK2W
l5E1IpA4yB2sgpsTXbjJ2QSQoBVvklc9morGYsHbjIMTIlvubopuyXafm9mQ0L6+czvhSioj
I2g1--E++U+6+64--GDqbDf9ik++++2-+++E++++F12q9oB-IYx2FIpD9YFEIaKDjEu0A-G3
Rl9SsEsae02Yf-c5d3JAI7d0sg80oa+HO7g02y5RdRL3iBqTvxlnfh8moJI5QOJZnHetRlrL
4LjKikv+GSeixorpLEALsAIFnF0y-WH8DNUA2wsKEelJfuFJZWcFHYZm8LCA085bAZZOHDDD
C2a7ZGxiosf0Be+sbsrnUnJQa3iFIWpzJUCL6WXso19M5Q-1B9cTWxjWbVbh9lNfJUrAt3YL
BdJj5kUrTmERlH7XcUtQtkpEGkA23++0++U+9ZyZ6Z8xm7F7+E++4UA++-++++-2AHMjEo3G
HoF3HIwiIYJHdJAxPsAk21q5GWV9cJ9rAbPg3fOqudGVuJzcpcl65QlKGt3WlekKGzw4Mi4b
NCm6Z6I-tLdbN1uGRCeRburrvcm3SO+580+ATqM+xk+E2Ns6+ev+lUny04I58BIhb0nFJ3IJ
8KU565M97ogwyMrQPbIXrthsYM1ZuzJ56xL+zpCL9V9a2h8Akr3xJUS7hWCnyza-2bJThmx9
Edfdt8+zCwt0ZUNl8VTU-8YCKjaiUEEeov4i+KXrljBwvFeGC9Jx1zqJWViCsMdBEKb4jAW9
ceTnj0VBOIPQtAOASQsRkrvaNXTWdWXnoGSRaoaN1Wmbb-ea7dWP2pSQwho3tyk-UYiUYiR+
1j7foZc0CkMfgQ2O-9OnPqm14czgdQffc2OcT28+i9x1f+bB6y8FU6kjt9W4pyTZOjbmhW9b
rrNLHlZ3cK1TwvwUs-REGkA23++0++++6s+36k++++++++++++++++M+++-2An7TAmxEGkA2
3++0++U+CP8t6iAUo3Ty++++b+A++-6+++-2An7TAmx2IY3LHY7IHWt2Ep8xIX3iVH+ATNEi
ZN+6KoT4Xd5OcKjzro4ee5cRlVsf-wVZC+4pbRU7pFzsGtpMSLfj4K6A+6mIytvmPzkok9jc
1pUksECTh4Nwss6jMVP0IzNuxzGcRGyInnYP75dgXgxqVZPNKBRow06EEe0HaJoqLp+CLb9T
5OybcmrEpnUIX+drkImyWkL5OCx2X3PE2KvB5fK+v3M+lg5gKW1qL01qLA1hIIW-TWQmyEeT
07vTawrj8jCPzq3qD1SSrpqnwlKiyjBBgK7kfR51+8A53NVKUSYg71c7WFN-OFNwfnmNg4KO
jrZjh+fdSW6sbSyah+Wiz0RPOQPriBbXcTQQjp-9+kEI++6+0+-lfzIWgY49r5YF++0EAE++
2U+++2EnAZwn9oFGEJRCEZFC9YF1JSpOTL+PFNPjSR8AqvMWmwPs54Cmggxl4KBfPT-Gral6
yIBKv7kzNHYVQ+YcwZVKI0F5YUbNCjMAHW0qBfh+3efMCisi3Bav99-rKvSdGw957gEPkVNk
0FTqH-Oes0eYEW-Qs-kk8N1jRQx6ad5Zq9-kwAT8n2nrSvzLvzKjLvyScR7kPszxzZd0Bjz9
lR7ZqJCLmABYm4EDiPQ2BYE0hW3rSBSuWuKYLymE+wDV3tNsmUSmLBr-cS2V7hVzvTAZbbvO
5+l2EY4zcgtlfEmtVkNx5ZJOQbHrUM2AJzBk8-kAzOmbx5KjlNM0iTHkwrRtfokFqffRjY1Y
TtszztTSjr13NLNtk1rgXvGu+zpyCQGJWvJ8Lo1i1UK5t3127sStiX0VLWZ5ajoyCF1d0jaw
jU1L3gnKCaJD74JUpBbZCrkSaEbYCmCnHN2kPxgahpRpSaJ0plaAy+Nw5bT23pEwtWJIHhbR
rlhlFqEinoz6StLVCc9xQcc3OffR6JZZlO8JRvcrmGbGBM3ytA91dJQYd4q-CxlyLrzQfIIH
nZ00Q7r9di-kc3yNJot0rXSI4C689PUZsBvUZzitcaVqs9q1kGqhQGyu8SgoGSfPkb33PmEM
IUTKSJnh0zjENEfjn4AwGtY8ov6XC-mKCs7rm0prM0GfejhyWqiMYbDB6JaRpY0qOsojcAdz
ZLjk+wn039-R1iBneyctWKM7cKFcGe8guKVj4ct2UU3vQ2hUBh583YaV7a5HBnF9YtXF91zC
31xOLMRSBk0quqPktprY0SACwBnCuEbTwjNEfhSA6jREN1UYQpRfaGlL4z6OLrxYQDNAKaKT
Rt+j7JM5ZHKZCYU6wkR1bzmwNcBLwjWPzABmZzrlPAmgdh-kS71Hk+-wn+k4Q5hivv9jmT6i
QbL9+PoSEr3XCcRH09ScMyaZCL3kRx0zpOjgFZOLi51THzvfYhQQFn-8LI3iZN0pMqZFNFXK
aY3TFCuovwbqIcyzklo8-UDzUI3uyXCOzStkK6tLmiPUde3U+DZwyXjzNCHIeLpPSx1RfuPn
McpshPctbL6UjeCjp8XLVB-jgaUIOpGxvU4tqSrrhxndYMQGtGMTKEi3TS26UnG4kntjE7p3
rakBdwHYsXJf8oy1DMjyehAfRURlzlIprvbDaySIjQkYZD+PDjv9o2dQtEst54Ppvznhqrwy
M5PdIjob8ldRLjCOXZjPazdQfetCSxSOneSTjA4+jXHdnJ4a78ejyla4MKAtosnZH6vpL-nL
YEPLYQERXjhAP7m2nsuijhuKXevJ9EQFUxD-rQm8dn6RMuhnNSRh3xjz2RCLQy5ShcpsHLPN
9oTYfUoPwQEEP8wwsgreXfE342D-UCTrauzpNjT8ULuJa4q1hrzWhGXpFQp+dnTkoGxaBbUn
4xhR9QvCFZT9kQNf1Jve0C5Gcz7WXfxT0QKpRIVV3fixKwBx2NxTvKNUhmrUWmUx0LgFSFAD
CeAd4DH9vc1vQBxSf7V8a9NCSIhP6-ll-nnlMoRJC28mfBCM4bUe8l3zwUzHDRt3WYEhSplY
R6K4tMAPTxzX3FpiTpUyk7e4hc05sAxfgAiwAG1pFY8yU5RPIOhx68gl2DMZyptnUv775Ps+
NWwTpfCIxhvOtL1ohfX4bo388cZIPfOtq3i7r8wgwQWbUJjzjMdI9h77RpXzTgLzqdO8XO2h
TRrXnFKDpRMEgdFWpxaqghIpPiQGK7e-YjMKVqiwVEiALA+mNBn--J6ZpV+ZZLkVN+QLRARv
DucSeq3VR1O4Eg2hOVUZuvxHRFo9EmjRoPcnteofBxakS6G08b9ktgwirY+egnKm5HwRyqBh
jFJghED9G2KyPWfeIHH0pc8AtleLZlVvNTx+UGqfF9+Jf7-8dAOi9E2tJ7-5DFJLuYrJ3J7g
yqhdkdMehdu8Mfo-CyJtWxRKlOtCOmNWLFeK0wnUeGXIav8wIJ7SAJhKa10HNc5NZZDds4-6
UcabsWcxK3R03Dkz7qCGGXDIbJJEU+kgbgCqPoWlz2BOmo8OXceq+D8e5AO8QKbGaAGdY00B
ooFRISlCdbKuV8ONeXBpeXxCOpiInfNXMPP3O7ijmpBRXiJ0AgbeoWSNnbOi78h97BYJSUDy
Dez+5ougStr2OBEDX9Df4y6G-TqmIEQjbUprghQBXQK9ScifNZgkgfuEEPgw27YvdY8xEKeS
LxGWfIWDVGdrHoKFrd8xzAR9Hicyf2jgkldAjXlB6R2ht5Fm5SjHfSAJKgCtJf2ygMetKfVa
1SgGIueLK47d-oKyK3Q-vVJpm+6hwX72pOQEFSCj5WDgW0+XZiKS0VAzB5kzt7xLWbmkl6c8
mfxUam8-2LPy22g7cio2m19miQ4wYZ-WiwPUC0nGIoNGMdWoHNF8dAfYoBF+ObsPef6RmNp3
mnu28eA1XqKAm6-UHNKUIeuVCWhN0SZI7ZFb7SSqcmcLegrumY8bOVKNpiZIf5eFfinZ4YGu
48enBTIgpt-7Zk91CPKsLBf4VFpOsRKoXlgbuZ8iEO+rUYpGwaIWvw7rAxEAa6VBpqFfMgYr
Kr8EiN3AEsnkFYq4yaqLHz8s+0ycASizuz77TZ75Yx80i3ERGjpcmmS3GLVascAhblHdwRYO
sj8ZMWuwoZ+9QLJL6151T96YlJRLU5zKt-CfHi3dnVHUx-hsqCSkV8XP0ssSWNupYEQANqkH
NNUEKMv2JWEp7MMeoR4BvviYcRNEPR9iIn8p1ud3jXKCJRu3V4ge47rOXgigfp3oOWQiZOs8
oOa5J34Wnh0dFrJ7R8leXqPVr8-NiQqULndWoJCEaEUpjuOIWrm4TT+hKpNGb89wIcj8Zf7y
BnUCWDFx4xZhC8TgPLLdaYcAWMJu2uddj31FeLRGi1ujsTekZigHwr1xPOJn9gMimnDKH2eK
wKPCnAnArt64P1NW5Jp-68SRp-01jPERVEN58Oyi6CIcHtfXPyhd6DeTIRDyCvmSkSgMyKNy
6V2+k+UNUD4aySaz8pXY4LdFT58t755KN59-TY7aq3BEx6n92IeoCQD2xVEISqOGSD6koQMo
W0mGYYZAspC-FCAkap+hd1bBK0MGnmwayigoIGwWmKFXkcYo41DFNVoHcwANRaZFCIGPNInw
C06SHo3NG1l74Ry4KNxU54i69m1zlYhwqgKzuC6TQdT9jLXybTu4QYzzgOXaZZMI1nsjaJhN
***** END OF BLOCK 3 *****



*XX3402-016356-050897--72--85-03421----DRAWNBTN.ZIP--4-OF--4
Lm0rXeJ-tN9Y6T1bz7gjzlOGDKSzcSnFzUw2bXhOkNyfoVlNQTbpLZXSx8tSgyrJ0-qRiA1L
DjdVx3FoCjf8xOx4Lp+2TsWy28InDQijDnFqrm2IPDhX78jzdm9HXIuMcWzQijuK6vqfoSf0
u5C5iAyAu353x1x5zXiahh2e6Hu83eiX3rvkw5u4LXH4bx4XIQiAovvyG4xoAXf8-hdy807p
QkhonGKr544SDcdCtjnKYRKBBxehE-LMxYD1FFhlAEQ3DDqWnKJQe8XEsx3FRXE9oGDAnoos
fGBlXH9amBBAHxEVMCsVW1f2b24MoL+UqbqHuY5fOi+5xoxkWUP4S0D3xtlXFVMDF5RBQBzu
ARxPebT4UmTdUZwEQwNoZfCtaaSIXDZ5KK1G1Sla8Hgkhf9VM+aH8qdhyyVxv4r9wA7xyra4
nt-sbVuxvlYmFvcGRj-wwNlZaObGfnn4Ftbj8W3YWZkFClMdkGjzjJ7JWHCSix2vCX5Bwjkr
P904zChTJMNJytNszuJcQzq7uOq4oSDYc03SbeD4gf5FZpX1LaMQElI5xWsTDKR+yCVNEl7p
Ac4Op81qusRu6k3uWmKEgB4kYkyjf7mmwnP0FYV2eumfij88J9DIcnkWkyUHn9Zlx+ba4IOt
3lEm3waFcfjqlsprva6y1o00VfCOfPPqtcJHlcbODmxP7msVfOyGPkRX9mYQOMUn86m-kdXV
OqJAsK0V0OPasxmIdJi+ftel7ptGC1eiQ1GdNKnouwyl9wPMT+aadi9z-qLu7+DxvjlmZ8pC
J2Lp3AjNzW01z-h1MoJrK-GH84S31lQjeZ3CkOuHwsXSse6rYe81yBZC9Xjk9-Bq+0oYcZa4
0VRTlmmIhu-Z1lzXPo2vy1Dt3fHk2z9Cy+atK5B0JWHPmh2scfl5nLQoTYIbspRro-p9P6CL
tWbRllD6YzBIfAY2wcr9vw4r2g1HmVsoviE-zIa35XQTrsAnD2h4bx-KfFbi8Dp4N6sD49u0
XQW7r5JAatmQgJr5tl3lhbNBnfYFoknAdvDffLYqsY6AInTWJnQ918ZbBpxEMpbotDIjveyD
othSSjAFkjthIEMqCvOmTnAG7brFxr55LbycPt-hjDuNajslusmcT9jQj5NhztVZw9jgRTxR
zgsyXHhhrN5FOju3RqHHEm6F7sYkOFJC3EeHJ7Wo00Mer2A30lICIS3t8YlHMFgJweVk9lLy
VUf3J3V0VH6ez6U86pGsE6Jw8VFEcN+8FJGkIe4I0iJIe8-07FKee40XUdY8iK+J3UAJZi9J
VZQTLXR0aLW808T8aJxO8emr095ZkbAKcOOCrOxfMjQu8hlUMsruCg3c2NPJ0pYKcFOK0wjP
VFpqwHEFHewEHXj2AoEsMlLCKcIn3XOQRU8PsP6nQAA0db+LUjNUj4S7Q9NQC2C3Iz3sHpi2
TJ1z-QAyFsFnJi3xer-iJfEb9VzhsMJ2ymO0ncBJT7w6vtQ8tnHF9XHA5LOAJ9lE+-CZgA6d
HdR-7VF0Ik2QnFBXRK6a963T3cit+C7We62b8w3iUZzJUQAg9cJuria27wiUBExKaQJO8-Jj
V0NJo4u3pZ6CAMhhGSB0u1G9TRdyhpZo+szUkV7Q7GjQJ+Urzp1Q12ckonmMiw+2NXA8Zg3q
m6CRS1q2puBU2fQXQ6AJ-edUj-r4Jw4s+zup-XOKku+7TVC+1JLULm9iJ24ZACuO2zGE0WfX
cBPoc2SH65HbH+zO+qP6lJU5ma4c5298jGXNJFj3Sc-Nr+Rpsi224MRJAXO87rFYj-Ybkknj
6+5j7+ZkwTxGUfdH1SfwZkneQn+8Nke3nm29TdkZb3BPBZ2kt+i0cJ1sc+UT7XVN66c4cz0-
GF6BxtwkB29XJJ07Qwa14cZWl3OsHd7+AZf+N1F9Fd+U5uIKOdH+O19KoHcAnqnAYmH7NAlH
SZ+5lRWKX5ZcUGX6Yp0GJM-GamFVjwtMVn7BGzKMXpkJcboyKA+atO4TDCllzrnQ8inX5sw1
6nBOkEbhlZL48iBefiRzlUf2aRLMANj--OhEcY4+5f282Orn6BfFIrc2lLOFNA8MmxKz6WWL
eV8GMYJe9BSle7qjAZj9fBaegtHM93rUYdkseV8-GPZ9LmM4E7geMnatsk4+pn96UqMPjcCo
pl5mWncwlhuunj6IY-T3EgijULki3ZUi+ib689Fw0iHiX67RVDnA-lTkVL46T3GNxL2ZbOeI
DbP4DfcbBbJDPDcqEaf67FDxn0FRKVzvP5ogVV6f2I0W6gt7VB8M+1KlH4UUl26KUGEhUVhW
SDWkoqslX11ner3O7K0W7R+E8s26jFcSkyRXgOK8yVdIJuCu4dP2eg37fs5Xy1kSesLPq01T
kuyFvkC-vs2pxbqwPUESImBOhO-J0qm9BQ6fgHNZg+sIxu0s-rrpc8wCi-STxwPu3DJOJ8x1
xHdIfoDpKZGhkwgBb++N8fAqEGLpEOKo0Nkl4HuCyT1OfDUQFgihCA6kf6xhlSgiNRNrsunj
VURXqu5-UholF6n-gwPMHeLz+DMTU+D4q2B8zl5gDw9uXmfxrRXTnT-vZ-Xr+dKSUiLo8RU9
gJw1bXxvsJoXhj0q1nXx-t1yNt5yNt5y+oXzMGLwrq5s9qDs9q9s9qDsjsCngFTlCe42zle4
zncuSkp1TlqjBtLkrwPkrwN-rZ50SFQFvw6XMimw2gu54At31CQW0yRH3gu5977DqSpng39q
JaD+tFumW+Oyuivz+p-9+E6I+-E++U+++-4+-GA++++++++++++++++2++++++++++++A+++
++++++-2AHMjI2g-+VE+3++0++U+V3WX6U+TXXzU++++D+A++-+++++++++++++U++++6U++
+2ElBWx2IY3LHY7IHWt2Ep7EGk203++I++6+0+1j1UIXT2-fiZ2N++0EEU++2+++++++++++
+0+++++k+E++F12q9oFGEJRCEZFC9YF1JJ-9+E6I+-E++U+6+AKmg06t300x-kU++4+E+++D
++++++++++++6++++8wO++-2AHMjEo3GHoF3HGt2EpJEGk203++I++6+0+0w+OAWIKKUMTw-
++1r+k++1k+++++++++++0++++1X6U++F12q9oB-IYx2FIoiF2NBI2g-+VE+3++0++U+luio
6WnElOKW+U++mkQ+++w++++++++++++U++++1mI++2ElBWx1EJ7DF2JB9Z--Ip-9+E6I+-E+
+U+6+64--GDqbDf9ik++++2-+++E++++++++++++6++++Bsb++-2AHMjEo3GHoF3HIwiF3-G
I2g-+VE+3++0++U+9ZyZ6Z8xm7F7+E++4UA++-+++++++++++++U++++lmU++2ElBWx1EJ7D
F2JBHmtGFJBEGk203++I++6++++XU+IX++++++++++++++++-U+++++++++++1+++++y8U++
F1AmLnAjI2g-+VE+3++0++U+CP8t6iAUo3Ty++++b+A++-6++++++++++++U++++MWc++2En
AZwn9oFGEJRCEZFC9YF1IZ-9+E6I+-E++U+6+54jxG8mEMjQSF2++7+l+++G++++++++++++
6++++7+f++-2An7TAmx2IY3LHY7IHWt2EpJEGkI4++++++g+0k0J+U++CHo+++++
***** END OF BLOCK 4 *****


