(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0042.PAS
  Description: Customizing the Slidebars
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  15:50
*)

unit SlideBar;

interface

{$R SLIDEBAR.RES} { see below for XX3401 code for resource file }

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus;

type
  TBarStyle    = (bsLowered,bsRaised);
  TOrientation = (orVertical,orHorizontal);
  TThumbStyle  = (tsBar1,tsBar2,tsBar3,tsBar4,tsCircle1,tsSquare1,
                  tsDiamond1,tsDiamond2,tsDiamond3,tsDiamond4);
  TSlideBar = class(TCustomControl)
  private
    FFocusColor              : TColor;
    FHandCursor              : Boolean;
    FLabels                  : TStringList;
    FMax,FMin,FPosition      : Integer;
    FOrientation             : TOrientation;
    FStyle                   : TBarStyle;
    FThickness               : Byte;
    FThumbStyle              : TThumbStyle;
    FTicks                   : Boolean;
    FOnChange                : TNotifyEvent;
    ThumbBmp,MaskBmp,BkgdBmp : TBitmap;
    DragVal,HalfTW,HalfTH    : Integer;
    ThumbRect                : TRect;
    TempDC                   : HDC;
    HandPointer              : HCursor;
    OriginalCursor           : HCursor;
    procedure SetLabels(A: TStringList);
    procedure SetMax(A: Integer);
    procedure SetMin(A: Integer);
    procedure SetOrientation(A: TOrientation);
    procedure SetPosition(A: Integer);
    procedure SetStyle(A: TBarStyle);
    procedure SetThickness(A: Byte);
    procedure SetThumbStyle(A: TThumbStyle);
    procedure SetTicks(A: Boolean);
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSize(var Message: TWMSize);             message WM_SIZE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  protected
    Dragging                 : Boolean;
    procedure Paint; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function  NewPosition(WhereX,WhereY: Integer): Integer;
    function  IsVert: Boolean;
    procedure RemoveThumbBar;
    procedure DrawThumbBar;
    procedure DrawTrench;
    procedure SaveBackground;
    procedure WhereIsBar;
    procedure SetTLColor;
    procedure SetBRColor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CurrentLabel: String;
  published
    property Enabled;
    property FocusColor: TColor read FFocusColor
                         write FFocusColor default clBlack;
    property HandCursor: Boolean read FHandCursor
                         write FHandCursor default True;
    property Labels: TStringList read FLabels write SetLabels;
    property Max: Integer read FMax write SetMax default 10;
    property Min: Integer read FMin write SetMin default 1;
    property Orientation: TOrientation read FOrientation
                          write SetOrientation default orHorizontal;
    property ParentShowHint;
    property Position: Integer read FPosition write SetPosition default 1;
    property PopupMenu;
    property ShowHint;
    property Style: TBarStyle read FStyle write SetStyle default bsLowered;
    property TabStop default True;
    property TabOrder;
    property Thickness: Byte read FThickness write SetThickness default 1;
    property ThumbStyle: TThumbStyle read FThumbStyle
                         write SetThumbStyle default tsCircle1;
    property Ticks: Boolean read FTicks write SetTicks default True;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

procedure Register;

implementation

function MinInt(A,B: Integer): Integer;
begin
  If A > B Then MinInt := B Else MinInt := A;
end;

function MaxInt(A,B: Integer): Integer;
begin
  If A > B Then MaxInt := A Else MaxInt := B;
end;

procedure Register;
begin
  RegisterComponents('Standard', [TSlideBar]);
end;

(******************
 TSlideBar Methods
******************)

constructor TSlideBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 15;
  Width := 100;
  ThumbBmp := TBitmap.Create;
  MaskBmp := TBitmap.Create;
  BkgdBmp := TBitmap.Create;
  HandPointer := LoadCursor(HInstance, 'HandPointer');
  FFocusColor := clBlack;
  FHandCursor := True;
  FLabels := TStringList.Create;
  FMin := 1;
  FMax := 10;
  FOrientation := orHorizontal;
  FPosition := 1;
  FStyle := bsLowered;
  FThickness := 1;
  FTicks := True;
  Dragging := False;
  DragVal := 0;
  ThumbStyle := tsCircle1;
  TabStop := True;
end;

destructor TSlideBar.Destroy;
begin
  FLabels.Free;
  ThumbBmp.Free;
  MaskBmp.Free;
  BkgdBmp.Free;
  inherited Destroy;
end;

procedure TSlideBar.CMEnter(var Message: TCMGotFocus);
begin
  inherited;
  Refresh;
end;

procedure TSlideBar.CMExit(var Message: TCMExit);
begin
  inherited;
  Refresh;
end;

function TSlideBar.IsVert: Boolean;
begin
  IsVert := (Orientation = orVertical);
end;

procedure TSlideBar.KeyDown(var Key: Word; Shift: TShiftState);
var
  b : Integer;
begin
  b := MaxInt(1,(Max-Min) div 10);
  case Key of
    VK_PRIOR : if (Position-b) > Min then
                 Position := Position - b else Position := Min;
    VK_NEXT  : if (Position+b) < Max then
                 Position := Position + b else Position := Max;
    VK_END   : if IsVert then Position := Min else Position := Max;
    VK_HOME  : if IsVert then Position := Max else Position := Min;
    VK_LEFT  : if Position > Min then Position := Position - 1;
    VK_UP    : if Position < Max then Position := Position + 1;
    VK_RIGHT : if Position < Max then Position := Position + 1;
    VK_DOWN  : if Position > Min then Position := Position - 1;
  end;
end;

procedure TSlideBar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
  OriginalCursor := GetClassWord(Handle, GCW_HCURSOR);
end;

procedure TSlideBar.WMSize(var Message: TWMSize);
begin
  if Height > Width then
    Orientation := orVertical else Orientation := orHorizontal;
end;

procedure TSlideBar.SetLabels(A: TStringList);
begin
  FLabels.Assign(A);
end;

procedure TSlideBar.SetMin(A: Integer);
begin
  FMin := A;
  Refresh;
end;

procedure TSlideBar.SetMax(A: Integer);
begin
  FMax := A;
  Refresh;
end;

procedure TSlideBar.SetOrientation(A: TOrientation);
begin
  FOrientation := A;
  Refresh;
end;

procedure TSlideBar.SetPosition(A: Integer);
begin
  if csDesigning in ComponentState then
    begin
      if (A >= Min) and (A <= Max) Then FPosition := A;
      Refresh;
    end
  else
    begin
      RemoveThumbBar;
      if (A >= Min) and (A <= Max) Then FPosition := A;
      WhereIsBar;
      SaveBackground;
      DrawThumbBar;
      if Assigned(FOnChange) then FOnChange(Self);
    end;
end;

procedure TSlideBar.SetStyle(A: TBarStyle);
begin
  FStyle := A;
  Refresh;
end;

procedure TSlideBar.SetThickness(A: Byte);
begin
  If (A > 0) and (A < 6) then
    begin FThickness := A; Refresh; end;
end;

procedure TSlideBar.SetThumbStyle(A: TThumbStyle);
begin
  If ThumbStyle <> A then
    begin
      FThumbStyle := A;
      case ThumbStyle of
        tsBar1     :   ThumbBmp.Handle := LoadBitmap(HInstance,'Bar1');
        tsBar2     :   ThumbBmp.Handle := LoadBitmap(HInstance,'Bar2');
        tsBar3     :   ThumbBmp.Handle := LoadBitmap(HInstance,'Bar3');
        tsBar4     :   ThumbBmp.Handle := LoadBitmap(HInstance,'Bar4');
        tsCircle1  :   ThumbBmp.Handle := LoadBitmap(HInstance,'Circle1');
        tsSquare1  :   ThumbBmp.Handle := LoadBitmap(HInstance,'Square1');
        tsDiamond1 :   ThumbBmp.Handle := LoadBitmap(HInstance,'Diamond1');
        tsDiamond2 :   ThumbBmp.Handle := LoadBitmap(HInstance,'Diamond2');
        tsDiamond3 :   ThumbBmp.Handle := LoadBitmap(HInstance,'Diamond3');
        tsDiamond4 :   ThumbBmp.Handle := LoadBitmap(HInstance,'Diamond4');
      end;
      case ThumbStyle of
        tsBar1     :   MaskBmp.Handle := LoadBitmap(HInstance,'Bar1Mask');
        tsBar2     :   MaskBmp.Handle := LoadBitmap(HInstance,'Bar2Mask');
        tsBar3     :   MaskBmp.Handle := LoadBitmap(HInstance,'Bar3Mask');
        tsBar4     :   MaskBmp.Handle := LoadBitmap(HInstance,'Bar4Mask');
        tsCircle1  :   MaskBmp.Handle := LoadBitmap(HInstance,'Circle1Mask');
        tsSquare1  :   MaskBmp.Handle := LoadBitmap(HInstance,'Square1Mask');
        tsDiamond1 :   MaskBmp.Handle := LoadBitmap(HInstance,'Diamond1Mask');
        tsDiamond2 :   MaskBmp.Handle := LoadBitmap(HInstance,'Diamond2Mask');
        tsDiamond3 :   MaskBmp.Handle := LoadBitmap(HInstance,'Diamond3Mask');
        tsDiamond4 :   MaskBmp.Handle := LoadBitmap(HInstance,'Diamond4Mask');
      end;
      HalfTH := ThumbBmp.Height div 2;
      HalfTW := ThumbBmp.Width div 2;
      Refresh;
    end;
end;

procedure TSlideBar.SetTicks(A: Boolean);
begin
  FTicks := A;
  Refresh;
end;

function TSlideBar.CurrentLabel: String;
begin
  if ((Position-Min+1) <= Labels.Count) and (Position >= Min) then
    CurrentLabel := Labels[Position-Min]
  else
    CurrentLabel := '<Un-Defined>';
end;

function TSlideBar.NewPosition(WhereX,WhereY: Integer): Integer;
var
  H1,W1 : Integer;
begin
  {Calculate the nearest position to where the mouse is located}
  H1 := Height-HalfTH;
  W1 := Width-HalfTW;
  if IsVert then
    Result := Round(((H1-WhereY)/H1)*(Max-Min)+Min)
  else
    Result := Round((WhereX/W1)*(Max-Min)+Min);
  Result := MinInt(MaxInt(Result,Min),Max);
end;

procedure TSlideBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  A,B,C,D,E : Integer;
begin
  if Button <> mbLeft then exit;
  C := Position-1;
  D := Position;
  E := Position+1;
  {B is the center of the ThumbBar}
  if IsVert then B := ThumbRect.Top+HalfTH else B := ThumbRect.Left+HalfTW;
  if Dragging then
    A := NewPosition(X,Y)
  else
    if IsVert then
      if Y < B then A := E else if Y > B then A := C else A := D
    else
      if X < B then A := C else if X > B then A := E else A := D;
  A := MinInt(MaxInt(A,Min),Max);
  Dragging := False;
  Position := A;
end;

procedure TSlideBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SetFocus;
  Dragging := PtInRect(ThumbRect,Point(X,Y));
  If IsVert then DragVal := Y else DragVal := X;
end;

procedure TSlideBar.MouseMove(Shift: TShiftState; X, Y: Integer);
Var
  LastDragVal : Integer;
begin
  if HandCursor then
    SetClassWord(Handle, GCW_HCURSOR, HandPointer)
  else
    SetClassWord(Handle, GCW_HCURSOR, OriginalCursor);
  {Is the left mouse button down and dragging the thumb bar?}
  if (ssLeft in Shift) and Dragging then
    begin
      LastDragVal := DragVal;
      if IsVert then DragVal := Y else DragVal := X;
      {This test eliminates unneccesary repaints}
      if DragVal <> LastDragVal then Position := NewPosition(X,Y);
    end;
end;

procedure TSlideBar.RemoveThumbBar;
begin
  {Place the background bitmap where it was last}
  Canvas.Draw(ThumbRect.Left,ThumbRect.Top,BkgdBmp);
end;

procedure TSlideBar.DrawThumbBar;
var
  TmpBmp  : TBitMap;
  Rect1   : TRect;
begin
  try
    {Define a rectangle to mark the dimensions of the thumbbar}
    Rect1 := Rect(0,0,ThumbBmp.Width,ThumbBmp.Height);
    {Create a working bitmap}
    TmpBmp := TBitmap.Create;
    TmpBmp.Height := ThumbBmp.Height;
    TmpBmp.Width := ThumbBmp.Width;
    {Copy the background area onto the working bitmap}
    TmpBmp.Canvas.CopyMode := cmSrcCopy;
    TmpBmp.Canvas.CopyRect(Rect1,BkgdBmp.Canvas,Rect1);
    {Copy the mask onto the working bitmap with SRCAND}
    TmpBmp.Canvas.CopyMode := cmSrcAnd;
    TmpBmp.Canvas.CopyRect(Rect1,MaskBmp.Canvas,Rect1);
    {Copy the thumbbar onto the working bitmap with SRCPAINT}
    TmpBmp.Canvas.CopyMode := cmSrcPaint;
    TmpBmp.Canvas.CopyRect(Rect1,ThumbBmp.Canvas,Rect1);
    {Now draw the thumb bar}
    Canvas.CopyRect(ThumbRect,TmpBmp.Canvas,Rect1);
  finally
    TmpBmp.Free;
  end;
end;

procedure TSlideBar.WhereIsBar;
var
  Each          : Real;
  ThumbX,ThumbY : Integer;
begin
  {Calculate where to paint the thumb bar - store in ThumbRect}
  if IsVert then
    begin
      Each := (Height-ThumbBmp.Height)/(Max-Min);
      If Dragging then
        ThumbY := DragVal-HalfTH
      else
        ThumbY := Height-Round(Each*(Position-Min))-ThumbBmp.Height;
      ThumbY := MaxInt(0,MinInt(Height-ThumbBmp.Height,ThumbY));
      ThumbX := (Width-ThumbBmp.Width) div 2;
    end
  else
    begin
      Each := (Width-ThumbBmp.Width)/(Max-Min);
      if Dragging then
        ThumbX := DragVal-HalfTW
      else
        ThumbX := Round(Each*(Position-Min));
      ThumbX := MaxInt(0,MinInt(Width-ThumbBmp.Width,ThumbX));
      ThumbY := (Height-ThumbBmp.Height) div 2;
    end;
  ThumbRect := Rect(ThumbX,ThumbY,ThumbX+ThumbBmp.Width,ThumbY+ThumbBmp.Height);
end;

procedure TSlideBar.SetTLColor;
begin
  {Set the Top/Left color for the trench. Controls raised or lowered styles}
  With Canvas do
    if Style = bsLowered then Pen.Color := clGray else Pen.Color := clWhite;
end;

procedure TSlideBar.SetBRColor;
begin
  {Set the Bottom/Right color for the trench. Controls raised or lowered styles}
  With Canvas do
    if Style = bsRaised then Pen.Color := clGray else Pen.Color := clWhite;
end;

procedure TSlideBar.DrawTrench;
var
  X1,Y1,X2,Y2 : Integer;
  Each        : Real;
  Tmp,TickPos : Integer;
begin
  {This procedure simply draws the slot that the thumb bar will travel through}
  {including the tick-marks. The bar itself is not drawn.}
  with Canvas do begin
    {Calculate the corners of the trench dependant on orientation}
    if IsVert then
      begin
        X1 := (Width div 2) - (Thickness div 2) - 1;
        X2 := X1 + Thickness + 1;
        Y1 := HalfTH;
        Y2 := Height-ThumbBmp.Height+Y1;
      end
    else
      begin
        X1 := HalfTW;
        X2 := Width-ThumbBmp.Width+X1;
        Y1 := (Height div 2) - (Thickness div 2) - 1;
        Y2 := Y1 + Thickness + 1;
      end;
    Pen.Style := psSolid;
    {Set the color for the Top & Left edges}
    SetTLColor;
    MoveTo(X2,Y1);
    LineTo(X1,Y1);
    LineTo(X1,Y2);
    {Set the color for the Bottom & Right edges}
    SetBRColor;
    LineTo(X2,Y2);
    LineTo(X2,Y1-1);
    {Now do a filled black rectangle in the center if the control has focus}
    with brush do if Focused then Color := FocusColor else Color := clSilver;
    Pen.Style := psClear;
    {Draw the focus highlight}
    Rectangle(X1+1,Y1+1,X2+1,Y2+1);
    Pen.Style := psSolid;
    {Calculate spacing of tick marks}
    Each := 0;
    if Ticks then
      if (Max-Min) > 0 then
        if IsVert then
          Each := (Height-ThumbBmp.Height)/(Max-Min)
        else
          Each := (Width-ThumbBmp.Width)/(Max-Min);
    {Now draw the tick marks}
    if Ticks then
      for Tmp := Min to Max do
        if IsVert then
          begin
            TickPos := Y2-Trunc(Each*(Tmp-Min))-1;
            if Tmp = Max then TickPos := Y1;
            SetTLColor; MoveTo(X1,TickPos);   LineTo(X1-2,TickPos);
            SetBRColor; MoveTo(X1,TickPos+1); LineTo(X1-2,TickPos+1);
          end
        else
          begin
            TickPos := X1+Trunc(Each*(Tmp-Min));
            if Tmp = Max then TickPos := X2-1;
            SetTLColor; MoveTo(TickPos,Y1);   LineTo(TickPos,Y1-2);
            SetBRColor; MoveTo(TickPos+1,Y1); LineTo(TickPos+1,Y1-2);
          end;
  end;
end;

procedure TSlideBar.SaveBackground;
begin
  {This saves the background image so it can be restored later}
  BkgdBmp.Width := ThumbBmp.Width;
  BkgdBmp.Height := ThumbBmp.Height;
  BkgdBmp.Canvas.CopyRect(Rect(0,0,ThumbBmp.Width,ThumbBmp.Height),
                          Canvas,ThumbRect);
end;

procedure TSlideBar.Paint;
begin
  DrawTrench;
  WhereIsBar;
  SaveBackground;
  DrawThumbBar;
end;


end.

{ SLIDEBAR.RES required to compile  --
  Use XX3401 to DECODE the following block.
  ..Cut the text to a text file named slidebar.xx
  ..execute XX3401 D slidebar.xx
  ..the "slidebar.res" will appear on your disk }

  { cut here -------------------------------------}

*XX3402-004167-011195--72--85-41244----SLIDEBAR.RES--1-OF--1
zk2+zk2+2-+o+E++-U+E+0U++++U++++E+++++2++E++++++U+++++++++++++++++++++++
++++++++zzzz++Ds+++1y+++-zU+++Tw+++Dz+++4zk++-jo+++nJ+++Mp++++A++++1++++
+k++++A++++1+++++k++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++y+DzzzU1zzzk+zzzw+5zzy+-zzz++Tzz
k+5zzs+-zzw6+zzza+zzzzVzzzzsTzzzy5zzzzVzzzzsTzzzzDzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz+U-0
EJ6l+1++Y++++0U++++3++++0U++++2+-+++++++8++++++++++++++++++++-++++++++++
++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z+Dzz
++1zzzw+++++++Vr1RoDVkrR1sQ6W+y506UDVk++1sQ+++y5+++Dy++++++++Dw0+27-IX3B
EJB9+1++Y++++0U++++3++++0U++++2+-+++++++8++++++++++++++++++++-++++++++++
++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z+Dzz
++1zzzw+w+1k++++1Ro+++rR+++6W+++06U+++++++++++++++++++++w+1k+Dw0+27-IX6+
A+0M++++8+++++M++++A+++++E+2+++++++k++++++++++++++++++++2++++++++++++6++
+6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+++1z+Dw+zzw++Dzz
zk++++++05Rk++y6Q++DW51R1sVkrEy6Q6UDW5061sVk++y6Q++DW5++1zy+++++++1z+U-0
EJ6mHI3HGk+k+7U++++c++++-U++++k++++-++E++++++1+++++++++++++++++++++E++++
++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z++++zzw+zk+++Dw+
zk1zzk++zzzz+D++1k+++++++++++++++Bo+++1R++++W++++6U+++++++++++++++++++++
w++D+Dw0+27-IXA+A+0E++++8+++++c++++3+++++E+2+++++++c++++++++++++++++++++
2++++++++++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+
++1z+Dw+zzw++Dzzzk++++++++2E+EVrRrRkJJJJ1sW6W5-JJJIDzzzzU3JJJE++++++JJJJ
zk6+EY3GAop-Iog+A+0E++++8+++++c++++3+++++E+2+++++++c++++++++++++++++++++
2++++++++++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+
++1z+Dw+zzw++Dzzzk1k++++1k+++++++++++++++++++++++++++++++++++D+++++D++++
zk6+EY3GB++k+7U++++c++++1+++++M++++-++E++++++1+++++++++++++++++++++E++++
++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z++++zzw+zk+++Dw+
zk1zzk++zzzz++++++++++++05RrRrRk2F2DW6W6W5-2F+y6W6W6Q-2F1zzzzzy+F2E+++++
+++++Dw0+27-IXFBEJB9+1++a++++0U++++A++++-U++++2+-+++++++A+++++++++++++++
+++++-++++++++++++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1z
zk1z++++zk1z+Dzz++1zzzw+w++++++D+++++++++++F2E+++++++2F2++++++++2F2+++++
++-2FD++++++1k++zk6+EoZGEol3AE+k+6U++++c++++0+++++U++++-++E++++++0++++++
+++++++++++++++E++++++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z
++1z++++zzw+zk+++Dw+zk1zzk++zzzz++++++++VrQ+06W5Q+y6W5+DW6Vk1zW6U+1zy+++
++++zk6+EoZGEol3AIp-Iog+A+06++++8+++++U++++6+++++E+2+++++++U++++++++++++
++++++++2++++++++++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk++
+Dzz+Dw+++1z+Dw+zzw++Dzzzk1z++1zw+++1k++++++++++++++++++++1k+++Dzk++zzw0
+2F7EIpDHYEl+1++W++++0U++++6++++0+++++2+-+++++++6++++++++++++++++++++-++
++++++++++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++
zk1z+Dzz++1zzzw++++++++5Q+++W5Q+1sW5Q+zsW5++zsU+++zk++++++1z+U-2GI3BHot2
AIp-Iog+A+06++++8+++++U++++6+++++E+2+++++++U++++++++++++++++++++2+++++++
+++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+++1z+Dw+
zzw++Dzzzk1zw+zzzk++zz++++w++++++++++D++++zz++1zzz+Dzzw0+2F7EIpDHYEm+1++
m++++0U++++A++++1+++++2+-+++++++M++++++++++++++++++++-++++++++++++0+++0+
++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z+Dzz++1zzzw+
++++++++Xz++++Rk++1zw+++S6Q++CXk++S6W5++vj++S6W6Vk-aM+S6W6W6Q+vU1sW6W6Xk
ti++y6W6Xk1is++DW6Xk+CvU++1sXk++vi++++zk++-as++++++++CvUzk6+F2Z-HIxCF17B
EJB9+1++m++++0U++++A++++1+++++2+-+++++++M++++++++++++++++++++-++++++++++
++0+++0+++++U6++U++++6++U+0+U+++U60++A1+k++++Dw++Dw+++1zzk1z++++zk1z+Dzz
++1zzzw+zzzk1zzzXz1zzk++zzzzwDzk+++DzyXkzk++++1zvj1k++++++xaM+++++++++vU
++++++++ti1k++++++zisDw+++++zyvUzz++++zzvi1zzk++zzxasDzzw+zzzyvUzk6+F2Z-
HIxCF1A+A+0k++++8+++++Y++++7+++++E+2++++++-6++++++++++++++++++++2+++++++
+++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+++1z+Dw+
zzw++Dzzzk++++++-JJJJE++Q+++++++++Vr++JJJJI+W6Rk+E++++zsW5Q++++++Dy6U+++
++++1zU+++++++++w+++++++++++++++++1z+U-2GI3BHot2Aop-Iog+A+0k++++8+++++Y+
+++7+++++E+2++++++-6++++++++++++++++++++2++++++++++++6+++6++++0+U+0+++++
U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+++1z+Dw+zzw++Dzzzk1zzkzzxJJJJTzk
+Dzk++++zk++1zJJJJLk++++wE++++++++++++++w++++D++++1z+++Dw++++Dzk+Dzk++++
zzwDzz++++1z+U-2GI3BHot2B++k+A+++++c++++0k++++g++++-++E++++++3U+++++++++
+++++++++++E++++++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z
++++zzw+zk+++Dw+zk1zzk++zzzz+++++++++++++++5+++++++++6Rk++JJJE+6W5Q+++++
+6W6Vr+3JJIDy6W6Rk++++1zW6W+++++++zsW++++++++Dy+++++++++1k++++++++++++++
++1z+U-2GI3BHot2B2p-Iog+A+1+++++8+++++g++++9+++++E+2++++++-M++++++++++++
++++++++2++++++++++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk++
+Dzz+Dw+++1z+Dw+zzw++Dzzzk1zzz1zzz+++Dzz++zzw+++zz+++DzpJJLz++++1z+++D++
++++xJJJ++++++++++1k+++++D+++Dw++++Dw+++zz+++Dzk++1zzk+Dzz+++DzzwDzzw+++
zk6+Ip3JEJ73AE+k+6U++++c++++0+++++U++++-++E++++++0+++++++++++++++++++++E
++++++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z++++zzw+zk++
+Dw+zk1zzk++zzzz+++++++6RrRk1sW6Q+y6W5+DW6Vk1sW6Q+zzzs++++++zk6+Ip3JEJ73
AIp-Iog+A+06++++8+++++U++++6+++++E+2+++++++U++++++++++++++++++++2+++++++
+++++6+++6++++0+U+0+++++U+0++60+++0+U6++kA1+++++zk++zk+++Dzz+Dw+++1z+Dw+
zzw++Dzzzk+++++++++++++++++++++++++++++++++++++++++++DwA+2V-HYFEHoZCJ2JG
+1+EFU2++++++U+-+0++E++-++2+B+2+++2++++c++++6++++2+++++-++2++++++6++++++
+++++++++++++++++++++++++Dzzzk+1y++++zU+++Ts+++5z+++1zk++-jw+++Px+++ApE+
+4BE+++1+++++k++++A++++1+++++k++++A+++++++++++++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++DU1zzzs+zzzw+Dz
zz+-zzzU+Tzzk+5zzw+-zzy++Tzz0+DzztUDzzzsTzzzy5zzzzVzzzzsTzzzy5zzzznzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzz
***** END OF BLOCK 1 *****




