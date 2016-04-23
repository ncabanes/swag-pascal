
From: "Peter Szymiczek" <szymicpe@bmw.com.au>


--------------------------------------------------------------------------------

procedure AngleTextOut(CV: TCanvas; const sText: String; x, y, angle:integer);
var
  LogFont: TLogFont;
  SaveFont: TFont;
begin
  SaveFont := TFont.Create;
  SaveFont.Assign(CV.Font);
  GetObject(SaveFont.Handle, sizeof(TLogFont), @LogFont);
  with LogFont do
    begin
      lfEscapement := angle *10;
      lfPitchAndFamily := FIXED_PITCH or FF_DONTCARE;
    end; {with}
  CV.Font.Handle := CreateFontIndirect(LogFont);
  SetBkMode(CV.Handle, TRANSPARENT);
  CV.TextOut(x, y, sText);
  CV.Font.Assign(SaveFont);
  SaveFont.Free;
end;
