(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0430.PAS
  Description: Conversion from ICO to BMP
  Author: MICHAEL VINCZE
  Date: 01-02-98  07:34
*)

From: vincze@ti.com (Michael Vincze)

Try:


--------------------------------------------------------------------------------

  var
    Icon   : TIcon;
    Bitmap : TBitmap;
  begin
     Icon   := TIcon.Create;
     Bitmap := TBitmap.Create;
     Icon.LoadFromFile('c:\picture.ico');
     Bitmap.Width := Icon.Width;
     Bitmap.Height := Icon.Height;
     Bitmap.Canvas.Draw(0, 0, Icon );
     Bitmap.SaveToFile('c:\picture.bmp');
     Icon.Free;
     Bitmap.Free;
  end;

