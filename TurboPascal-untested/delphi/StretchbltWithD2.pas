(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0232.PAS
  Description: Re: StretchBlt with D2
  Author: MIKE SHANE
  Date: 03-04-97  13:18
*)

{
Here is some code I use to print a bitmap with StretchDIBits.  The
function accomplishes the same thing as StretchBlt.  The difference is
that it operates with Device Independent Bitmaps (DIBs).  If you want to
use
StretchBlt, you would use it like this:
}

StretchBlt(DestinationRectangle.Handle, DestX, DestY, DestWidth,
              DestH, Bitmap.Handle,SourceX, SourceY, SourceWidth,
              SourceHeight, SRCCOPY);

{ ----- begin code ----- }
procedure TfrmMain.PrintBitmap(Bitmap: TBitmap; X, Y, W, H: Integer);
  var
    Info: PBitmapInfo;
    InfoSize: Integer;
    Image: Pointer;
    ImageSize: Longint;
  begin
    with Bitmap do
    begin
      GetDIBSizes(Handle, InfoSize, ImageSize);
      Info := MemAlloc(InfoSize);
      try
        Image := MemAlloc(ImageSize);
        try
          GetDIB(Handle, Palette, Info^, Image^);
          with Info^.bmiHeader do
            StretchDIBits(Printer.Canvas.Handle, X, Y, W,H,
                                0, 0, biWidth,biHeight,Image,Info^,
                                DIB_RGB_COLORS,SRCCOPY);
        finally
          FreeMem(Image, ImageSize);
        end;
      finally
        FreeMem(Info, InfoSize);
      end;
    end;
  end;
{ ----- end code ----- }

