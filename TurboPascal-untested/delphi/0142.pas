{
>I am trying to change the color of specific cell in TStringGrid.
>Whenever I change the color of TStringGrid.Color, then the whole thing
>(TStringGrid) is changed to the given color.
>
>If there is no way for doing this, are there any ways to change the
>font of the text only for the specific cell ?
>


This is off the top of my head:

1.  You must set the DrawAutomatic property to False.
2.  You must create a method for the OnDrawCell event.
}

The OnDrawCell event would look something like:

  var
    Text: array[0..255] of Char;
  begin
  StrPCopy (Text, StringGrid1.Cells[Row, Col]);
  if Col = 2 then
    StringGrid1.Canvas.Brush.Color := clYellow
  else
    StringGrid1.Canvas.Brush.Color := clWhite;
  ExTextOut (..., Rect.Left + 2, Rect.Bottom + 2, ..., Text, StrLen (Text));
  end;

This will draw the third column yellow and all others
white.

Again the code and property names are off the top of my
head.  If you have the VCL source, then take a look in
the GRIDS.PAS file and you will see how the default
OnDrawCell event uses the ExTextOut() function.  You
could take the code from there and paste it into your
source and then add the test for what color to draw the
grid with.

Best regards,
Michael Vincze
mav@asd470.dseg.ti.com





