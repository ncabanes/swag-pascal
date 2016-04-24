(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0386.PAS
  Description: Change the StringGrid's CELL color ?
  Author: EDDIE SHIPMAN
  Date: 01-02-98  07:34
*)

Here's how:

procedure TForm1.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var
  TempPString:Array [0..255] of char;
begin
  If (gdFixed in State){or (gdSelected in State)} then exit;

  StringGrid1.Canvas.Brush.Style:=bsSolid;
  {You could add some color here, if desired:}
  Case Col of
    1: StringGrid1.Canvas.Brush.Color:=clRed;
    2: StringGrid1.Canvas.Brush.Color:=clWhite;
    3: StringGrid1.Canvas.Brush.Color:=clBlue;
  end;
  {Erase data}
  StringGrid1.Canvas.FillRect(Rect);
  {Get text in a PChar string}
  StrPCopy(TempPString,StringGrid1.Cells[Col,Row]);
  {DrawText--see other options in Windows API help;
   Change the DT_LEFT to DT_RIGHT for right justified txt!}
  DrawText(StringGrid1.Canvas.Handle,TempPString,-1,Rect,DT_LEFT);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  I, J, K : Integer;
begin
  with StringGrid1 do
  begin
      for I := 1 to ColCount - 1 do
      for J:= 1 to RowCount - 1 do
        begin
        K := K + 1;
        Cells[I,J] := IntToStr(K);
        end;
   end;
end;

