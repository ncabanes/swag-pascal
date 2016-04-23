
From: Jukka PalomΣki <jukpalom@utu.fi>

This is how I have solved the problem:


--------------------------------------------------------------------------------

procedure TextOutVertical(var bitmap: TBitmap; x, y: Integer; s: String);
var b1, b2: TBitmap;
    i, j: Integer;
begin
  with bitmap.Canvas do
  begin
    b1 := TBitmap.Create;
    b1.Canvas.Font := lpYhFont;
    b1.Width  := TextWidth(s) + 1;
    b1.Height := TextHeight(s) + 1;
    b1.Canvas.TextOut(1, 1, s);

    b2 := TPackedBitmap.Create;
    b2.Width  := TextHeight(s);
    b2.Height := TextWidth(s);
    for i := 0 to b1.Width - 1 do
        for j := 0 to b1.Height do
            b2.Canvas.Pixels[j, b2.Height + 1 - i] := b1.Canvas.Pixels[i, j];
    Draw(x, y, b2);
    b1.Free;
    b2.Free;
  end
end;
