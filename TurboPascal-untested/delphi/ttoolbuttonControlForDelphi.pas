(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0273.PAS
  Description: tToolButton Control for Delphi
  Author: MATTHEW CSULIK
  Date: 05-30-97  18:17
*)

{
Hello again!

I send to You a toolbar button component, which looks like the Explorer
3.0's toolbar button. Resource file and a number of button images are included.
These need to extracted using XX3402.  See below for more information.

This component made under Delphi 2.0, and NOT tested with Delphi 1.0 (but I
think it works under 1.0).

Kind regards
        Matthew Csulik
        matthew-c@usa.net

---------------------------------------------------------
-                                                       -
-  ToolButton.pas                                       -
-  **************                                       -
-  This component and it's bitmaps are completely FREE. -
-                                                       -
---------------------------------------------------------

{usage:                                                                        }
{ just assign three bitmap (included) to the Color, Disabled, and Mono bitmaps;}
{ set the right color for transparentcolor;                                    }
{ and USE IT!                                                                  }

unit Toolbutton;

interface

{ written by Matthew }
{ matthew-c@usa.net  }

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls;

type
   TToolButtonState = (tbsUp, tbsDown);
   TToolButtonStyle = (tstTextBitmap, tstBitmap);
   TMouseState = (msIn, msOut);

   TToolButton = class(TGraphicControl)
   private
      State: TToolButtonState;
      MouseState: TMouseState;
      FStyle: TToolButtonStyle;
      FColorBitmap, FMonoBitmap, FDisabledBitmap: TBitmap;
      FTransparentColor: TColor;
      procedure SetColorBitmap(Value: TBitmap);
      procedure SetMonoBitmap(Value: TBitmap);
      procedure SetDisabledBitmap(Value: TBitmap);
      procedure SetStyle(Value: TToolButtonStyle);
      procedure SetTransparentColor(Value: TColor);
      procedure CMMouseEnter(var Message: TMessage);
         message CM_MOUSEENTER;
      procedure CMMouseLeave(var Message: TMessage);
         message CM_MOUSELEAVE;
      procedure CMEnabledChanged(var Message: TMessage);
         message CM_ENABLEDCHANGED;
      procedure CMSysColorChange(var Message: TMessage);
      	 message CM_SYSCOLORCHANGE;
      procedure CMTextChanged(var Message: TMessage);
      	 message CM_TEXTCHANGED;
   protected
      procedure Paint; override;
   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure Click; override;
      procedure DblClick; override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
         X, Y: integer); override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer);
         override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
         X, Y: integer); override;
   published
      property Caption;
      property ColorBitmap: TBitmap read FColorBitmap write SetColorBitmap;
      property DisabledBitmap: TBitmap read FDisabledBitmap write
SetDisabledBitmap;
      property MonoBitmap: TBitmap read FMonoBitmap write SetMonoBitmap;
      property TransparentColor: TColor read FTransparentColor write
SetTransparentColor default clOlive;
      property Style: TToolButtonStyle read FStyle write SetStyle;
      property Enabled;
      property ParentShowHint;
      property ShowHint;
      property Visible;
      property OnClick;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
   end;

procedure Register;

implementation

constructor TToolButton.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FTransparentColor:= clOlive;
   FColorBitmap:= TBitmap.Create;
   FMonoBitmap:= TBitmap.Create;
   FDisabledBitmap:= TBitmap.Create;
   Caption:= Name;
   State:= tbsUp;
   Style:= tstTextBitmap;
   MouseState:= msOut;
end;

destructor TToolButton.Destroy;
begin
   FColorBitmap.Free;
   FMonoBitmap.Free;
   FDisabledBitmap.Free;
   inherited Destroy;
end;

procedure TToolButton.Paint;
var
   CX,CY: integer;
begin
   CX:= Width div 2;
   CY:= Height div 2;
   if csDesigning in ComponentState then
   begin
      with inherited Canvas do
      begin
         Pen.Style := psDash;
         Brush.Style := bsClear;
         Rectangle(0, 0, Width, Height);
         Brush.Color:= clBtnFace;
	 FillRect(Rect(0,0,Width,Height));
         if Style = tstTextBitmap then
         begin
            BrushCopy(Rect(CX-(MonoBitmap.Width div 2),CY-(MonoBitmap.Height
div 2)-10,
	       CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)-10),
	          MonoBitmap, Rect(0,0,MonoBitmap.Width,MonoBitmap.Height),
TransparentColor);
	    Font.Color:= clBlack;
	    Font.Name:= 'MS Sans Serif';
	    Font.Size:= 8;
	    Font.Style:= [];
	    TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
         end
         else
         begin
            BrushCopy(Rect(CX-(MonoBitmap.Width div 2),CY-(MonoBitmap.Height
div 2),
	       CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)),
	       MonoBitmap, Rect(0,0,MonoBitmap.Width,MonoBitmap.Height),
TransparentColor);
         end;
      end;
   end
   else
   begin
      with inherited Canvas do
      begin
         Brush.Style := bsClear;
         Brush.Color:= clBtnFace;
	 FillRect(Rect(0,0,Width,Height));
      end;
      if Enabled then
      begin
         if (State = tbsUp) and (MouseState = msOut) then
         begin
            with Canvas do
            begin
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(MonoBitmap.Width div
2),CY-(MonoBitmap.Height div 2)-10,
                     CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div
2)-10),
                        MonoBitmap,
Rect(0,0,MonoBitmap.Width,MonoBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
 	       end
               else
               begin
                  BrushCopy(Rect(CX-(MonoBitmap.Width div
2),CY-(MonoBitmap.Height div 2),
                     CX+(MonoBitmap.Width div 2),CY+(MonoBitmap.Height div 2)),
                        MonoBitmap,
Rect(0,0,MonoBitmap.Width,MonoBitmap.Height), TransparentColor);
               end;
            end;
         end
         else if (State = tbsUp) and (MouseState = msIn) then
         begin
            with Canvas do
            begin
	       FillRect(Rect(0,0,Width,Height));
	       Pen.Color:= clbtnHighlight;
               Polyline([Point(Width-1,0),Point(0,0),Point(0,Height-1)]);
               Pen.Color:= clbtnShadow;
               Polyline([Point(Width-1,1),Point(Width-1,Height-1),Point(1,He
ight-1)]);
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2),CY-(ColorBitmap.Height div 2)-10,
                     CX+(ColorBitmap.Width div 2),CY+(ColorBitmap.Height div
2)-10),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
	       end
               else
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2),CY-(ColorBitmap.Height div 2),
                     CX+(ColorBitmap.Width div 2),CY+(ColorBitmap.Height div
2)),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
               end;
            end;
         end
         else if (State = tbsDown) and (MouseState = msIn) then
         begin
            with Canvas do
            begin
               Brush.Style:= bsClear;
               Brush.Color:= clBtnFace;
	       FillRect(Rect(0,0,Width,Height));
	       Pen.Color:= clbtnShadow;
               Polyline([Point(Width-1,0),Point(0,0),Point(0,Height-1)]);
               Pen.Color:= clbtnHighlight;
               Polyline([Point(Width-1,1),Point(Width-1,Height-1),Point(1,He
ight-1)]);
	       if Style = tstTextBitmap then
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2)+1,CY-(ColorBitmap.Height div 2)-9,
                     CX+(ColorBitmap.Width div 2)+1,CY+(ColorBitmap.Height
div 2)-9),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
                  Font.Color:= clBlack;
                  Font.Name:= 'MS Sans Serif';
                  Font.Size:= 8;
                  Font.Style:= [];
                  TextOut(CX-(TextWidth(Caption) div 2)+1,CY+6,Caption);
	       end
               else
               begin
                  BrushCopy(Rect(CX-(ColorBitmap.Width div
2)+1,CY-(ColorBitmap.Height div 2)+1,
                     CX+(ColorBitmap.Width div 2)+1,CY+(ColorBitmap.Height
div 2)+1),
                        ColorBitmap,
Rect(0,0,ColorBitmap.Width,ColorBitmap.Height), TransparentColor);
               end;
            end;
         end;
      end
      else
      begin		               {Disabled}
         with Canvas do
         begin
	    Brush.Style:= bsClear;
            Brush.Color:= clBtnFace;
	    FillRect(Rect(0,0,Width,Height));
	    if Style = tstTextBitmap then
            begin
               BrushCopy(Rect(CX-(FDisabledBitmap.Width div
2),CY-(FDisabledBitmap.Height div 2)-10,
                  CX+(FDisabledBitmap.Width div
2),CY+(FDisabledBitmap.Height div 2)-10),
                     FDisabledBitmap,
Rect(0,0,FDisabledBitmap.Width,FDisabledBitmap.Height), TransparentColor);
               Font.Name:= 'MS Sans Serif';
               Font.Size:= 8;
               Font.Style:= [];
               Font.Color:= clbtnHighlight;
               TextOut(CX-(TextWidth(Caption) div 2)+1,CY+6,Caption);
               Font.Color:= clbtnShadow;
               TextOut(CX-(TextWidth(Caption) div 2),CY+5,Caption);
	    end
            else
            begin
               BrushCopy(Rect(CX-(FDisabledBitmap.Width div
2),CY-(FDisabledBitmap.Height div 2),
                  CX+(FDisabledBitmap.Width div
2),CY+(FDisabledBitmap.Height div 2)),
                     FDisabledBitmap,
Rect(0,0,FDisabledBitmap.Width,FDisabledBitmap.Height), TransparentColor);
            end;
         end;
      end;
   end;
end;

procedure TToolButton.Click;
begin
   inherited Click;
end;

procedure TToolButton.DblClick;
begin
   inherited Click;
end;

procedure TToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
   inherited MouseDown(Button, Shift, X, Y);
   if (Button = mbLeft) and Enabled then
   begin
      if State <> tbsDown then
      begin
         State:= tbsDown;
         Invalidate;
      end;
   end;
end;

procedure TToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseMove(Shift, X, Y);
end;

procedure TToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
   inherited MouseUp(Button, Shift, X, Y);
   State:= tbsUp;
   Invalidate;
end;

procedure TToolButton.CMMouseEnter(var Message: TMessage);
begin
   MouseState:= msIn;
   if Enabled then
      Invalidate;
end;

procedure TToolButton.CMMouseLeave(var Message: TMessage);
begin
   if State = tbsDown then
   begin
      State:= tbsUp;
      Invalidate;
   end;
   MouseState:= msOut;
   if Enabled then
      Invalidate;
end;

procedure TToolButton.CMEnabledChanged(var Message: TMessage);
begin
   Invalidate;
end;

procedure TToolButton.CMSysColorChange(var Message: TMessage);
begin
   Invalidate;
end;

procedure TToolButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TToolButton.SetColorBitmap(Value: TBitmap);
begin
   if FColorBitmap <> Value then
   begin
      FColorBitmap.Assign(Value);
      Invalidate;
   end;
end;

procedure TToolButton.SetMonoBitmap(Value: TBitmap);
var
   x,y: integer;
begin
   if FMonoBitmap <> Value then
   begin
      FMonoBitmap.Assign(Value);
      FDisabledBitmap.Height:= FMonoBitmap.Height;
      FDisabledBitmap.Width:= FMonoBitmap.Width;
      for x:= 0 to FDisabledBitmap.Width do
      begin
         for y:= 0 to FDisabledBitmap.Height do
         begin
            if FMonoBitmap.Canvas.Pixels[x,y] = clWhite then
               FDisabledBitmap.Canvas.Pixels[x,y]:= clbtnHighlight;
            if FMonoBitmap.Canvas.Pixels[x,y] = clGray then
               FDisabledBitmap.Canvas.Pixels[x,y]:= clbtnShadow;
         end;
      end;
      Invalidate;
   end;
end;

procedure TToolButton.SetDisabledBitmap(Value: TBitmap);
const
  ROP_DSPDxax = $00E20746;
var
   MonoBmp, TmpImage: TBitmap;
   IRect: TRect;
   IWidth,IHeight: integer;
begin
   if FDisabledBitmap <> Value then
   begin
      FDisabledBitmap.Assign(Value);
      IWidth:= FDisabledBitmap.Width;
      IHeight:= FDisabledBitmap.Height;
      IRect:= Rect(0,0,IWidth,IHeight);
      TmpImage:= TBitmap.Create;
      MonoBmp:= TBitmap.Create;
      TmpImage.Width:= FDisabledBitmap.Width;
      TmpImage.Height:= FDisabledBitmap.Height;
      MonoBmp.Width:= FDisabledBitmap.Width;
      MonoBmp.Height:= FDisabledBitmap.Height;
      with MonoBmp do
      begin
         Assign(FDisabledBitmap);
         Canvas.Brush.Color := clBlack;
         if Monochrome then
         begin
            Canvas.Font.Color := clWhite;
            Monochrome := False;
            Canvas.Brush.Color := clWhite;
         end;
         Monochrome := True;
      end;
      with TmpImage.Canvas do
      begin
         Brush.Color := clBtnFace;
         FillRect(IRect);
         Brush.Color := clBtnHighlight;
         SetTextColor(Handle, clBlack);
         SetBkColor(Handle, clWhite);
         BitBlt(Handle, 1, 1, IWidth, IHeight,
         MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
         Brush.Color := clBtnShadow;
         SetTextColor(Handle, clBlack);
         SetBkColor(Handle, clWhite);
         BitBlt(Handle, 0, 0, IWidth, IHeight,
         MonoBmp.Canvas.Handle, 0, 0, ROP_DSPDxax);
      end;
      FDisabledBitmap.Assign(TmpImage);
      TmpImage.Free;
      MonoBmp.Free;
      Invalidate;
   end;
end;

procedure TToolButton.SetStyle(Value: TToolButtonStyle);
begin
   if FStyle <> Value then
   begin
      FStyle:= Value;
      Invalidate;
   end;
end;

procedure TToolButton.SetTransparentColor(Value: TColor);
begin
   if FTransParentColor <> Value then
   begin
      FTransparentColor:= Value;
      Invalidate;
   end;
end;

procedure Register;
begin
   RegisterComponents('Matthew', [TToolButton]);
end;

end.

{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-006403-230497--72--85-59226------TBBMPS.ZIP--1-OF--2
I2g1--E++U+6+AaH6G9hcx9WLE+++DM++++E++++KaxjPIxpR0-BPqtj9a7hQ5JBkF4+A+W9
VkAsVgzSiM3zpz5BO7r8PmK2VxsdB+Y2qiv5-QINK+B9MQ8QjiAjL2Br0NBKICwxb725MoWM
h2WP+WNh5sOKm0kO4mh3ZhZM+ymdtPzqHLTo0Jyw+J-9+kEI++6+0+0eYm2WXHvv6qU+++1q
++++3++++3djPqpDRLEUF4ZnMK7gNKEiMapkRMmx1MIk16GBn+0AEKbd-cV2nnejxaXN8F7h
g5CFc5XMCJzoySQs9q5wEbhcapdY5RnZ8tlBRpdacWWppW-xDCaRZdYc0lWWRDg1C7EpDsNK
22ofE+iU1GUKPW9uxgb5b1tva5RswENEGkA23++0++U+WNAV6ZwDA0Fs++++xU+++-A+++-O
PqxhHrJo62BjP4xmNKEiMapkRMkl0gEk1+FpC71qbb4ZMEhrBZmTjlU0eToozwJDA8HpfOkI
UGCGJUinGBzh38i1yZ1jGmxN7WzmJAL0Igmo3L5JKYb45-b1H3iF9ZVZNlvyEF1N3H1FoCwh
-MMt+dr+BG-tiVRlRyx+dCQ2h3LjShEvL5wkzzs+I2g1--E++U+6+D0G6G6WLTWlLk+++DM+
+++D++++KaxjPIZi62pjPawiMapkRMn-2M+U1+HDWEJMVgzAo63zqz4RoeX89yMsaD4V0Qb0
2XXC4scfOwzOFWpMikzwFSUmEa-GNOipdaZxcHK-GQJK311FDsG4q9Zl5clo6spAOEvMawDD
iTaiX5zoskBEGkA23++0++U+pN6V6Y9+oL-a++++xU+++-A+++-OPqxhGKsUF4ZnMK7gNKEi
MapkRIn71M+k1+g8+n+4noUNc-7zpi4RoPdH7PsVeJi7-nWpLHb5QRs2LA2xi+oihDPQu+y4
dVYg8uCEKagYrVytkv6mGZ4+40sT+MNGwmDOWYNHWb+9tmNQ73m6yCoXbrBnHwQRL5k+I2g1
--E++U+6+D8G6G9sgV4hPU+++DM++++G++++KaxjPIZi62BjP4xmNKEiMapkRMkl0c+k12IX
2JkxVaAUEwS0irQd0AstKixIQ8p7os6U7jrtw5uOzPX-up7hefJfUfZlUPwG1oLQf+rdm1Yf
eSp-fKvKVamkJo9rw+I-s1GUWMJoZVUoH74k9AlM00Cd2k0yjTClBztljwDhvUBEGkA23++0
++U+TMcV6fzoaNhM++++xU++++o+++-HMLNZ62pjPawiMapkQz9xlU+-NI0g+QE0IAn6k+6K
Pk1W6rkEX+cO676B1F+8-230EC9+UEB+YTxUlD1zDsE0EN+EY104+MV-n+MUVX2nRdc-F6A-
Z+yYkE9A-4U4--xe1wlO+3-9+kEI++6+0+-oWW2W6AMO4pU+++1q++++2E+++3BVRaIUF4Zn
MK7gNKEiMapkQz9xlU+-NI0g+QE0IAn6k+6KPk1W6rkEX+cO676B1F+8-230EC9+UEB+YTxU
lD1zDsE0EN+EY104+MV-n+NU-TnMOEME1ENEDd1y+C9m2u+N25mcDH-f+J-9+kEI++6+0+-O
WW2WFXGa0qo+++1q++++2++++3BVRaIUEqxgPr7ZN0tWPL-nwjr4++3ZE8k-l+7EnAX++VNj
+C6XT-0A0VcUYUoB2+c2EI7+sg0-+o0Fzq12wDwzV+7-Y-0EA6M-VU8UH+4nyFYUJQ21cRht
IDYA6-cAc5kUTO1XFwQDcDU-6BL-UsDD+CJnA7iLUk2nn3c+I2g1--E++U+6+D4A6G6fDYx+
NU+++DM++++C++++I57dPbEUHKxiPmtWPL-pXP2JU1+6FD5V+6tVSSylUPrfK4SoH4IPCGvO
0HY65oWCwnPNZRdHqxFWOz3aTxPIP2q7HdGVxttYp92lZCV24S8pSgQ1j+AenRrJN6O3yyFk
nE2OmtPe6A5v283PPKi+sgPrvEBEGkA23++0++U+tMkV6hfB7rxg++++xU+++-6+++-EQaZi
R0-2OLBVMalZN0tWPL-pHH2GU0+AWsRvTMMXRzn+rSwswnGSpAapBWquqN9a2YcsnVhNZqBr
P-A9pj+vzefbNSx7P3cylVXiK-mM7P3dyKVjFItdpIpHHEYdEaoU8on8x3JmHqh6ENDIfGeU
Pp1lM42AaEjCwS9vxU3EGkA23++0++U+kckV6ig1waBt++++xU+++-2+++-EQaZiR0-1Pqlj
QaJY9a7hQ5JBAF60AEVQ7pTElKRMNWMzgDQvqh97X2ymmNBGLFgLCCpQ+Xggg9bSRWHin+jn
TCE7KyW8Tx+QeWNtiAEmle0msa4h7+yLKDcLsJBuAo6pKoUFgxTPsDlwa7F1JwYxPR28SeLP
t44Pk5EXxejEi+6pq-T6QT5vxUBEGkA23++0++U+hcYV6VsLHHpg++++xU++++s+++-EMLBo
NG-BPqtj9a7hQ3JBiF4+A+kHRnFiCANU1bfKcTM6OPBB0aOW1N9BwRWF3AiCgqsbAbNW6SMP
+wPkbHWal1wwaysdGZaYpVeR5USxdmVZYScPgOY+lbgVaIfdIpgoRGkJEMkMsZUp9c-7KIft
fB0bLSzJgAyb3p-9+kEI++6+0+0dWG2WxsTioL++++1q++++2U+++3-VQrFZ62FdQq3WP4JY
9a7hQ3JCiF4+A+knRnFdA4Ak-nrfI5i2hBYa-ECZcUqGnLDMZbGKYnXfRYf21Wn+T4CEoLo1
XWbk1siVKEWH3eXK0eRvGSwVH3eUwcKzZ2IITUAdKhSrJlymIeUI2c98MoIPCeKWdS7OUtzx
-kZfgjCnx+7EGkA23++0++U+VcYV6f6fTtaG++++xU+++-2+++-EMLBoNG-1PqljQaJY9a7h
Q5DmzQM++KJ+f+52+Z1AmA+03aw+sWBw26k84W0G1EoE0UF-EY1Wk621E75zMAHkzny2+Y4E
270MWE+i610-US32FoR50vityKYUhsKtiDXwvzyz6Lnj6msEzUZD2DzzvmAnUTknNwsQa+bY
+s5-HCM0c+Lg-HDN0s0ag+DtlRkA4sc9NU9BrQr+k+aoNU8MV+2+I2g1--E++U+6++SD6G7Y
VhtqV++++DM++++E++++EqxkSG-1PqljQaJY9a7hQ5DmzQM++KJ+f+52+Z1AmA+03axUk+IO
676B1F+8-230EC9+UEB+YTxUlD1zDsE0EN+EY114-0MiE+0YPHcuCZd+x+M4VVOUBdvzyzyr
J5Fox61spJ-yzSzzDFjsXvV+y0SQETnxzswMJnBws1Zntf-lzSwD1G-1ezxzM+PFtSI387M-
+3-9+kEI++6+0+-qVG2Wri2ReK6+++1q++++2E+++2xkNKsUF4ZnMK7gNKEiMapkQz9xlU+-
NI0g+QE0IAn6k+6KPq1+-FcUYUoB2+c2EI7+sg0-+o0Fzq12wDwzV+7-Y-0Ea6YC7Y-AbAYD
ZDrzsECAbj+TaSPzk6xATzUDdm5OzoDJEKWU+0T652ucyQXK+E-EGkA23++0++U+z6EV6ZEM
wCdp++++xU+++-++++-DQ4Ji62BjP4xmNKEiMapkQz9xlU+-NI0g+QE0IAn6k+6KPq1+-FcU
YUoB2+c2EI7+sg0-+o0Fzq12wDwzV+7-Y-0Ea6YCddS1kQkCA4WTqPwP05OInzWBH9SPUsJV
x6tWwruUMTxz37jD+4inBdw-ZhwBdc20ZXCvRyyq-7YzcuANqHc+I2g1--E++U+6+8pN806d
husGIE+++DM++++A++++HaJr62pjPawiMapkQz9xlU+-NI0g+QE0IAn6k+6KPk1W6rkEX+cO
676B1F+8-230EC9+UEB+YTxUlD1zDsE0EN+EY104+MV-lgPA66s-RKWMSQnAI1vI5aOsfQM+
I2g1--E++U+6+AVg9G7OG9EHIk+++DM++++E++++HaJr62FdQq3WP4JY9a7hQ5DmzQM++KJ+
f+52+Z1AmA+03aw+sWBw26k84W0G1EoE0UF-EY1Wk621E75zMAHkzny2+Y4E27+kVU46EQP4
z21FzlycEwDAsqS4we5qAABhBEM+I2g1--E++U+6+6hN806zB2u3Mk+++DM++++D++++HaJr
62BjP4xmNKEiMapkQz9xlU+-NI0g+QE0IAn6k+6KPk1W6rkEX+cO676B1F+8-230EC9+UEB+
YTxUlD1zDsE0EN+EY104+MV-lgMJ5I1EM4lQzTzrzxx+iVt6zGSHLw++sJQkEzZ+Swe-c-Vi
en2+I2g1--E++U+6+07SN0608mxMN++++DM++++B++++G4JgQ0-BPqtj9a7hQ5JBiF4+A+kH
NkNU12fTSEBupe5qO7a8BZVqS-fYFsYQ8xhycb-2fJ59e+ZnucszS+rRWlWIcfLKEiaNu9q6
EGaODJ1YFEL0UtWCFd4Q8LkFUkwPYY5VMPKk2SvFBuoUxnPSzmtEGkA23++0++U+AJtY6cMw
mmNf++++xU+++-2+++-6NKlk62FdQq3WP4JY9a7hQ5JBgEq+A+k9UXqQkFWd5v1n1bBDuoaN
K6DRJ-I9HVorfieQpmC74nn+TL0FfThJzZ1ngRMI3WqopVeQu2QWIZWooAe2GFxAFLbFw6Wp
K--CROeWUSh54EMJ4ZAh28DwtpXYn-DMn-xPQxw9I2g1--E++U+6+5BSN09+uYbrW++++DM+
+++E++++G4JgQ0-1PqljQaJY9a7hQ5JBAEc1AEl9cEzcAvdvv-1criyoV+v7BwkBxsWPPZ9y
R3+sD8FmQbGf53iFF7nvslA4bikfyr9o8NmvLw6zZ-4KAgX99MtO8trKHqVhY7RP5D71HBbd
NXcN4IUN0qK5F4+369njPvCBxrI43UypulTGv3chHPN3O8PaypqNyntZ94BVzszPF9tEGkA2
3++0++U+G6YV6UnHLltW++++xU++++k+++-1RLEUHKxiPmtWPL-hX12CU1+6FH2s4szVGA6B
r9qCAoTfs7auJi0rFVAzzPno3vcTZO1HjPbLvcbanApx9T-LVYQn60cWPuIIHpcSOUq6WgWP
DV64KNF+ILtF03EFPAZMvcjXvjAduXymzXC5PZ-9+kEI++6+0++eWG2W1BBT5a6+++1q++++
2++++2BpR0-2OLBVMalZN0tWPL-hX12CU1+6FH2s4szVGA6Br9qCAoTfs7auJi0rFVAzzPno
3vcTZO1HjPbLvcbanApx9T-LVYQn60cWPuIIHpcSOUq6WgWPDV64KNF+ILtF03EFPAZMvcjX
vjAduXymzXC5PZ-9+kEI++6+0++FWG2W-J+FdKU+++1q++++1k+++2BpR0-1PqljQaJY9a7h
Q5DmzQM++KJ+f+52+Z1AmA+03aw+sWBw26k84W0G1EoE0UF-EY1Wk621E75zMAHkzny2+Y4E
27+kVUAHNkVxqAHM-I9P41gXoHN569GlWQoNW+MKe2ta04I+BQn++26n41-1dP5HM2I+I2g1
--E++U+6+1KD6G8j-+qFM++++DM++++B++++EqxkSG-BPqtj9a7hQ5JBEEu+A+X1p+Ts16wa
ys3rjyCNdypJLaQ9oqWAg29O+Zirkn7qMWOaXg54oBrykhBonuOIl37fdR9WKKjNZ77MmXQK
LJGzEC5Ko1aSb0EtUBWlUZV-+KoRFMnGgTSL7p-9+kEI++6+0++eXm2WVMMAoKI+++1q++++
2E+++2BjQ5YUF4ZnMK7gNKEiMapkRIkl0c-+18iQSrq4cy+DrDqCQtxqHyfYKdBKI--nZsOY
BBhyGi2+Nr0uCQWMiQYTf7Na7LmAA5fjG08zF7HkAQ7MjpXMGALSeGvWYiTV0h9fqwCIpoPD
KgqHhWfK96IqOZIzi+-EGkA23++0++U+X6IV6hlGhr3T++++xU++++o+++-DQ4Ji62pjPawi
MapkQz9xlU+-NI0g+QE0IAn6k+6KPq1+-FcUYUoB2+c2EI7+sg0-+o0Fzq12wDwzV+7-Y-0E
a6YC7Y-AbAY7tYm+oFBa6hCQ2nWFuEYnsHF2yomcCUUB3C+2aQA7BFzNCU-EGk20AUgI++6+
***** END OF BLOCK 1 *****

*XX3402-006403-230497--72--85-03713------TBBMPS.ZIP--2-OF--2
0+17Ym2WvODGsZo+++1q++++2++++++++++++0++hc2+++++KaxjPIxpR0-BPqtj9a7hQ3-9
+E6m0lE++U+6+8eH6G8BDjgXO++++DM++++I++++++++++++6+0qUMg+++-OPqxhHrJo62Fd
Qq3WP4JY9a7hQ3-9+E6m0lE++U+6+6aH6G7T1n+YS++++DM++++H++++++++++++6+0qUGI-
++-OPqxhHrJo62BjP4xmNKEiMapkI2g-+X693++0++U+w76V6W7Ry93T++++xU++++w+++++
+++++++U+9O-nU2++3djPqp7PW-BPqtj9a7hQ3-9+E6m0lE++U+6+BKG6G70kB3kNU+++DM+
+++H++++++++++++6+0qUJc0++-OPqxhGKsUF4ZnMK7gNKEiMapkI2g-+X693++0++U+wd6V
6jWm2Opi++++xU+++-6++++++++++++U+9O-wE6++3djPqp7PW-1PqljQaJY9a7hQ3-9+E6m
0lE++U+6+5q86G8zx7aPK++++DM++++B++++++++++++6+0qUMw1++-HMLNZ62pjPawiMapk
I2g-+X693++0++U+R6cV6W144VhM++++xU+++-2++++++++++++U+9O-2UE++3BVRaIUF4Zn
MK7gNKEiMapkI2g-+X693++0++U+KccV6YModUhh++++xU+++-+++++++++++++U+9O-aEE+
+3BVRaIUEqxgPr7ZN0tWPL-EGk20AUgI++6+0+1lX02W8ntDE4M+++1q++++1U++++++++++
+0++hc2o-E++I57dPbEUHKxiPmtWPL-EGk20AUgI++6+0+1ZX02WqgobTqk+++1q++++2U++
+++++++++0++hc54-E++I57dPbEUF4ZnMK7gNKEiMapkI2g-+X693++0++U+kckV6ig1waBt
++++xU+++-2++++++++++++U+9O-MUM++3-mOKto62BjP4xmNKEiMapkI2g-+X693++0++U+
hcYV6VsLHHpg++++xU++++s++++++++++++U+9O-0UQ++3-VQrFZ62pjPawiMapkI2g-+X69
3++0++U+eMYV6jS5vh3k++++xU+++-6++++++++++++U+9O-cUQ++3-VQrFZ62FdQq3WP4JY
9a7hQ3-9+E6m0lE++U+6+6O76G8m8ryNYU+++DM++++F++++++++++++6+0qUI66++-EMLBo
NG-1PqljQaJY9a7hQ3-9+E6m0lE++U+6++SD6G7YVhtqV++++DM++++E++++++++++++6+0q
UEA7++-1Pr-t62BjP4xmNKEiMapkI2g-+X693++0++U+RcIV6hvV5OZW++++xU+++-2+++++
+++++++U+9O-hEY++2xkNKsUF4ZnMK7gNKEiMapkI2g-+X693++0++U+z6EV6ZEMwCdp++++
xU+++-+++++++++++++U+9O-FUc++2xkNKsUEqxgPr7ZN0tWPL-EGk20AUgI++6+0+0hKGUW
8PSi2Z2+++1q++++1++++++++++++0++hc5d0U++HaJr62pjPawiMapkI2g-+X693++0++U+
m4kh6Zd6h-BH++++xU+++-+++++++++++++U+9O-N+g++2tZRm-2OLBVMalZN0tWPL-EGk20
AUgI++6+0+09KGUWDnFCVKA+++1q++++1k+++++++++++0++hc5Z0k++HaJr62BjP4xmNKEi
MapkI2g-+X693++0++U+6ZtY6U6f9pVY++++xU++++o++++++++++++U+9O-REk++2VZP5+U
HKxiPmtWPL-EGk20AUgI++6+0++lLaEWVXn97ag+++1q++++2E+++++++++++0++hc221E++
G4JgQ0-2OLBVMalZN0tWPL-EGk20AUgI++6+0+-nLaEWkCd7xsU+++1q++++2+++++++++++
+0++hc4S1E++G4JgQ0-1PqljQaJY9a7hQ3-9+E6m0lE++U+6+2W76G6AopwSMU+++DM++++A
++++++++++++6+0qUJEC++-1RLEUHKxiPmtWPL-EGk20AUgI++6+0++eWG2W1BBT5a6+++1q
++++2++++++++++++0++hc5U1U++ErJo62FdQq3WP4JY9a7hQ3-9+E6m0lE++U+6+-476G63
I-4ZO++++DM++++D++++++++++++6+0qUL+D++-1RLEUEqxgPr7ZN0tWPL-EGk20AUgI++6+
0++pXm2WfkEBYK++++1q++++1E+++++++++++0++hc232+++EqxkSG-BPqtj9a7hQ3-9+E6m
0lE++U+6+0eD6G83VUnFNE+++DM++++F++++++++++++6+0qUN+E++-1Pr-t62FdQq3WP4JY
9a7hQ3-9+E6m0lE++U+6+6m36G9QIfRlLk+++DM++++B++++++++++++6+0qUGEF++-DQ4Ji
62pjPawiMapkI2g3-U+++++S+-s+DkQ++8sF++++++++
***** END OF BLOCK 2 *****


{ ---------------------------  CUT   --------------------------- }
{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000267-230497--72--85-31147-------TBRES.ZIP--1-OF--1
I2g1--E++U+6+0Fs9G8avVUYXE+++Bk-+++C++++J4xjP27pR5FjPWtYMr7XM4-UI+1WzzwV
4-poA16ka61ZaFV0UB+T05oMb-V0cHkze1c-+HsKa-sB67O+MYM4W9+06kACo+-41+oB2+c2
EI7+sg0-+m0PkEXYC1+3Ua0rzaQk7UPMZoB-AN1R+EIMP+ukInXEqEoA5EoQ1FmMuXgO4Acf
sCmCPWHq1j934TtXQlgGynwIT0P8uk-EGk20AUgI++6+0++YS0oWdisM76o+++1Q+E++1U++
+++++++++0++hc2+++++J4xjP27pR5FjPWtYMr7EGkI4++++++2++E+w++++iE++++++
***** END OF BLOCK 1 *****


