{
michael a vincze

Below I have re-written your Paint method.  It is commented where I made the
changes. Get in touch with me if you have any questions.
}

procedure TNumConWindow.Paint(PaintDC : HDC; var PaintInfo : TPaintStruct);
var
  X, Y    : Integer;
  WRect   : TRect;
  DeltaX,
  DeltaY,
  XSize,
  YSize   : Integer;
  Perc    : Real;
  Str     : string;
  PC      : PChar;
  PCP     : Integer;
  SaveBK  : LongInt;
  ThePen  : HPen;
  TheBrush: HBrush;
  TheRect : TRect;

const
  CP       = 1;
  NumLic   = 64;
  MaxCount = 6;
  Count    : array [1..MaxCount] of Integer = (2, 4, 8, 16, 32, 64);
  OutStr   : string = 'Hello Allen E. Stoner ';

begin
  GetClientRect(HWindow, WRect);
  XSize := WRect.Right - WRect.Left;
  YSize := WRect.Bottom - WRect.Top - 40;

  Perc   := YSize / (NumLic * 1.05);
  DeltaY := Round(Perc * 10);

  { Draw fat line at bottom of graph.  The color is the system default. }
  MoveTo(PaintDC, 0, YSize);
  LineTo(PaintDC, XSize, YSize);
  MoveTo(PaintDC, 0, YSize + 1);
  LineTo(PaintDC, XSize, YSize + 1);
  MoveTo(PaintDC, 0, YSize + 2);
  LineTo(PaintDC, XSize, YSize + 2);

  { Draw horizontal lines.  The color is the system default. }
  Y := YSize;
  while Y > 0 do
  begin
    Rectangle(PaintDC, 0, Y, XSize, Y - DeltaY);
    Y := Y - (DeltaY * 2);
  end;

  { Fill in rectangle at bottom yellow.  This is the same size as WRect
    except the top is at YSize + 3. }
  TheBrush := CreateSolidBrush(RGB($FF, $FF, $00));
  CopyRect(TheRect, WRect);
  TheRect.Top := YSize + 3;
  FillRect(PaintDC, TheRect, TheBrush);

  { Draw vertical lines red. If you wanted to, you could draw rectangles
    instead of lines. Notice how I've selected a width of 4 for ThePen.
    You could also have a different color for each "bar" by having X index
    into an array of TColorRefs and changing ThePen for each new value of X.}
  ThePen := CreatePen(PS_SOLID, 4, RGB($FF, $00, $00));
  SelectObject(PaintDC, ThePen);
  for X := 1 to MaxCount do
  begin
    MoveTo(PaintDC, X * 10, YSize);
    LineTo(PaintDC, X * 10, Round(YSize - (Count[X] * Perc)));
  end;

  if CP = 1 then
    PCP := 300
  else
    PCP := CP - 1;
  PC := @OutStr[1];

  { Set the color of the text.  Note GetSysColor is used merely as an example.
    Don't forget that the background of the text must also be colored.  This
    color should be yellow, as in TheBrush, however a different color was
    selected for illustration purposes.  Alternatively SetBkMode() could
    be used }
  SetTextColor(PaintDC, GetSysColor(COLOR_HIGHLIGHT));
  SetBkColor(PaintDC, RGB($00, $FF, $FF));
  { Use SetBkMode () instead of SetBkColor () to see what happens.
    SetBkMode (PaintDC, TRANSPARENT); }

  TextOut(PaintDC, 10, YSize+15, PC, Length(OutStr)-1);

  { Don't forget to delete the selected objects. }
  DeleteObject(ThePen);
  DeleteObject(TheBrush);
end;
