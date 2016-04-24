(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0274.PAS
  Description: Multicolors in stringgrid
  Author: TONY POPIEL
  Date: 05-30-97  18:17
*)

{
Hi Moris

> Can anyon help me. I would like to alter the colour of a cell in a
> stringgrid if certain criteria are met. Can this be done and if so how

You have to write your own OnDrawCell procedure.
Here is some code I wrote a while back that did the trick. It's too
much but you might find something useful in there.

}

procedure TLongChart.StringGrid1DrawCell(Sender: TObject; Col,
  Row: Longint; Rect: TRect; State: TGridDrawState);
var
OldColor : TColor;
OldBrush : TBrush;
begin with StringGrid1.Canvas do begin
    OldColor := Font.Color;
    OldBrush := Brush;

   {paint fridays}
   if StringGrid1.Cells[Col,1] = 'Fr' then begin
   Brush.Color := $02aaaaaa; {light gray}
   FillRect(Rect);
   Font.Color := clWhite;
   TextOut(Rect.Left+2,Rect.Top+2,StringGrid1.Cells[Col,Row]);
   end;

   {paint each alternating month}
   if (Row = 0) and (Col > 0) then begin
   if (Odd(StrToIntDef(StringGrid1.Cells[Col,31],0))) then
   Brush.Color := clBlue
   else
   Brush.Color := clFuchsia;

   FillRect(Rect);
   Font.Color := clWhite;
   TextOut(Rect.Left+2,Rect.Top+2,StringGrid1.Cells[Col,Row]);
   end;

   {paint days of the week}
   if (Row = 1) and (Col > 0) then begin
   if StringGrid1.Cells[Col,1] = 'Fr' then
   Brush.Color := clTeal else
   Brush.Color := clAqua;
   FillRect(Rect);
   if StringGrid1.Cells[Col,1] = 'Fr' then
   Font.Color := clWhite else
   Font.Color := clBlack;

   TextOut(Rect.Left+2,Rect.Top+2,StringGrid1.Cells[Col,Row]);
   end;


   Font.Color := OldColor;
   Brush := OldBrush;

end;
end;

---------------------------------------------------
Tony Popiel
popiel@emirates.net.ae
United Arab Emirates
---------------------------------------------------

