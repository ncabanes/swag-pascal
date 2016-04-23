{
The following is a unit I wrote yesterday. I am uploading it because it is a
failed component - failed because it ultimately could not do what I needed.
What I needed were resizeable bloxes (hotspots if you will) over a graphic.
I created a component and setup 8 boxes at the perimeter for resizing and
developed the code for the control to be moved (by clicking and holding
while moving inside the control) or resized (at one of the 8 resize blocks
around the edge).  The failure was that after I got all this working I could
not find a way to make the window transparent or automatically copy the area
underneath to its canvas.  I had to have a transparent hotspot - not one
pushbutton grey!

Anyway, when the user presses the mouse button down I take the X,Y, make it
a point and do ClientToScreen on it - I also store the location of the
control in parent coordinates.  Later, when I get the OnMouseMove call, I
take the new X,Y position, convert it to screen coordinates and take the
difference of the original mouse X,Y to the new mouse X,Y and apply that to
the original window X,Y.

I am redoing this control as a descendant of TPaintBox so it can have the
graphic and handling the hotspots as a TList instead of individual windows.
Easier on resources as well.
}
unit Hotspot;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  THotspot = class(TCustomControl)
  private
    { Private declarations }
    xDown: Integer;
    yDown: Integer;
    ptDown: TPoint;
    dragging: Integer;
    wDrag: Integer;
    rcDown: TRect;
    rcDrag: Array [0..7] of TRect;
    rcCursor: Array [0..7] of TCursor;

  protected
    { Protected declarations }
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;

  public
    { Public declarations }
		constructor Create(AOwner: TComponent); override;

		procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure Paint; override;
		procedure MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton; Shift:
TShiftState; X, Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton; Shift:
TShiftState; X, Y: Integer);

  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [THotspot]);
end;

constructor THotspot.Create(AOwner: TComponent);
var
	win: Longint;
begin
	inherited Create(AOwner);
  Canvas.Brush.Style := bsClear;
  dragging := -1;
  wDrag := 5;

  OnMouseMove := MouseMove;
  OnMouseDown := MouseDown;
  OnMouseUp := MouseUp;
  ParentColor := True;

  rcCursor[0] := crSizeNWSE;
  rcCursor[1] := crSizeNS;
  rcCursor[2] := crSizeNESW;
  rcCursor[3] := crSizeWE;
  rcCursor[4] := crSizeNWSE;
  rcCursor[5] := crSizeNS;
  rcCursor[6] := crSizeNESW;
  rcCursor[7] := crSizeWE;
end;

procedure THotspot.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
	r,b,r2,b2: Integer;
	wDrag2: Integer;
begin
	r := AWidth;
  b := AHeight;
  r2:= r div 2;
  b2 := b div 2;
	wDrag2 := wDrag div 2;

  rcDrag[0] := Rect(0,0,wDrag,wDrag);
  rcDrag[1] := Rect(r2-wDrag2,0,r2+wDrag2,wDrag);
  rcDrag[2] := Rect(r-wDrag+1,0,r,wDrag);
  rcDrag[3] := Rect(r-wDrag+1,b2-wDrag2,r,b2+wDrag2);
  rcDrag[4] := Rect(r-wDrag+1,b-wDrag,r,b);
  rcDrag[5] := Rect(r2-wDrag2,b-wDrag,r2+wDrag2,b);
  rcDrag[6] := Rect(0,b-wDrag,wDrag,b);
  rcDrag[7] := Rect(0,b2-wDrag2,wDrag,b2+wDrag2);

	inherited SetBounds(ALeft,ATop,AWidth,AHeight);
end;

procedure THotspot.Paint;
var
	rc: TRect;
  i,w: Integer;
begin
	with Canvas do begin
    Pen.Style := psDot;
    if dragging = -1 then
      Pen.Color := clBlack
    else
      Pen.Color := clWhite;
    rc := GetClientRect;
    w := wDrag div 2;
    Rectangle(w,w,rc.right-w,rc.bottom-w);

    Brush.Style := bsSolid;
    Brush.Color := Pen.Color;
    Pen.Style := psSolid;
    for i := 0 to 7 do
    	Rectangle(rcDrag[i].Left,rcDrag[i].Top,rcDrag[i].Right,rcDrag[i].Bottom);
    Brush.Style := bsClear;
	end;
end;

procedure THotspot.MouseMove(Sender: TObject; Shift: TShiftState; X, Y:
Integer);
var
	i: Integer;
  pt: TPoint;
  xDif,yDif: Integer;

  procedure SetW(leftOff,topOff,rightOff,bottomOff: Integer);
  var
  	rc: TRect;
  begin
  	rc := rcDown;
    Inc(rc.Left,leftOff);
    Inc(rc.Top,topOff);
    Inc(rc.Right,rightOff);
    Inc(rc.Bottom,bottomOff);
    SetBounds(rc.Left,rc.Top,rc.Right-rc.Left+1,rc.Bottom-rc.Top+1);
  end;

begin
	pt := ClientToScreen(Point(X,Y));
	xDif := pt.X - ptDown.X;
  yDif := pt.Y - ptDown.Y;
	if ssLeft in Shift then
    case dragging of
    -1:	SetBounds(left + (X-xDown),top + (Y-yDown),width,height);
    0: SetW(xDif,yDif,0,0);
    1: SetW(0,yDif,0,0);
    2: SetW(0,yDif,xDif,0);
    3: SetW(0,0,xDif,0);
    4: SetW(0,0,xDif,yDif);
    5: SetW(0,0,0,yDif);
    6: SetW(xDif,0,0,yDif);
    7: SetW(xDif,0,0,0);
    end
  else begin
	 	pt := Point(X,Y);
  	Cursor := crArrow;
	  for i := 0 to 7 do
			if PtInRect(rcDrag[i],pt) then
      	Cursor := rcCursor[i];
  end;
end;

procedure THotspot.MouseDown(Sender: TObject; Button: TMouseButton; Shift:
TShiftState; X, Y: Integer);
var
	i: Integer;
  pt: TPoint;
begin
 	pt := Point(X,Y);
  ptDown := ClientToScreen(pt);
	xDown := X;
  yDown := Y;
  rcDown := Rect(left,top,left+Width,top+Height);
  dragging := -1;
  for i := 0 to 7 do
		if PtInRect(rcDrag[i],pt) then
    	dragging := i;
  if dragging <> -1 then
  	Cursor := rcCursor[i]
  else if Cursor <> crArrow then
  	Cursor := crArrow;
  Paint;
end;

procedure THotspot.MouseUp(Sender: TObject; Button: TMouseButton; Shift:
TShiftState; X, Y: Integer);
begin
	dragging := -1;
  Paint;
end;

end.


