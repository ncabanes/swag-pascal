(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0453.PAS
  Description: Stretched bitmap on TPrinter
  Author: ALEXANDER WERNHART
  Date: 01-02-98  07:35
*)


wea@felten.co.at (Alexander Wernhart)

On Tue, 4 Feb 1997 20:54:43 -0300, Ruy Ponce de Leon Junior
<rplj@di.ufpe.br> wrote:


I'm writing a program that prints a bitmap to the printer
via TPrinter object. The problem occurs when I "stretch"
the bitmap to fit the adequate area on paper. Due to the
stretching (bitblts to Printer's DC), dotted patterns appear
on the  bitmap regions, making them almost gray.
This is an obvius undesired effect. Does anybody knows some 
approach to help me?
 
Try this:


--------------------------------------------------------------------------------

procedure DrawImage(Canvas: TCanvas; DestRect: TRect; ABitmap:
TBitmap);
var
  Header, Bits: Pointer;
  HeaderSize: Integer;
  BitsSize: Longint;
begin
  GetDIBSizes(ABitmap.Handle, HeaderSize, BitsSize);
  Header := MemAlloc(HeaderSize);
  Bits := MemAlloc(BitsSize);
  try
    GetDIB(ABitmap.Handle, ABitmap.Palette, Header^, Bits^);
    StretchDIBits(Canvas.Handle, DestRect.Left, DestRect.Top,
        DestRect.Right, DestRect.Bottom,
        0, 0, ABitmap.Width, ABitmap.Height, Bits,TBitmapInfo(Header^),
        DIB_RGB_COLORS, SRCCOPY);
    { you might want to try DIB_PAL_COLORS instead, but this is well
      beyond the scope of my knowledge. }
  finally
    MemFree(Header, HeaderSize);
    MemFree(Bits, BitsSize);
  end;
end;

{ Print a Bitmap using the whole Printerpage }
procedure PrintBitmap(ABitmap: TBitmap);
var
  relheight, relwidth: integer;
begin
  screen.cursor := crHourglass;
  Printer.BeginDoc;
  if ((ABitmap.width / ABitmap.height) > (printer.pagewidth /printer.pageheight)) then
  begin
    { Stretch Bitmap to width of Printerpage }
    relwidth := printer.pagewidth;
    relheight := MulDiv(ABitmap.height, printer.pagewidth,ABitmap.width);
  end else
  begin
    { Stretch Bitmap to height of Printerpage }
    relwidth := MulDiv(ABitmap.width, printer.pageheight, ABitmap.height);
    relheight := printer.pageheight;
  end;
  DrawImage(Printer.Canvas, Rect(0, 0, relWidth, relHeight), ABitmap);
  Printer.EndDoc;
  screen.cursor := crDefault;
end;

--------------------------------------------------------------------------------

