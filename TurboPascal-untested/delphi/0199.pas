

The following TI details a better way to print the contents of
a form, by getting the device independent bits in 256 colors
from the form, and using those bits to print the form to the
printer.

In addition, a check is made to see if the screen or printer
is a palette device, and if so, palette handling for the device
is enabled. If the screen device is a palette device, an additional
step is taken to fill the bitmap's palette from the system palette,
overcoming some buggy video drivers who don't fill the palette in.

Note: Since this code does a screen shot of the form, the form must
be the topmost window and the whole from must be viewable when the
form shot is made.




unit Prntit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, 
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


uses Printers;


procedure TForm1.Button1Click(Sender: TObject);
var
  dc: HDC;
  isDcPalDevice : BOOL;
  MemDc :hdc;
  MemBitmap : hBitmap;
  OldMemBitmap : hBitmap;
  hDibHeader : Thandle;
  pDibHeader : pointer;
  hBits : Thandle;
  pBits : pointer;
  ScaleX : Double;
  ScaleY : Double;
  ppal : PLOGPALETTE;
  pal : hPalette;
  Oldpal : hPalette;
  i : integer;
begin
 {Get the screen dc}
  dc := GetDc(0);
 {Create a compatible dc}
  MemDc := CreateCompatibleDc(dc);
 {create a bitmap}
  MemBitmap := CreateCompatibleBitmap(Dc, 
                                      form1.width, 
                                      form1.height);
 {select the bitmap into the dc}
  OldMemBitmap := SelectObject(MemDc, MemBitmap);

 {Lets prepare to try a fixup for broken video drivers}
  isDcPalDevice := false;
  if GetDeviceCaps(dc, RASTERCAPS) and 
     RC_PALETTE = RC_PALETTE then begin
    GetMem(pPal, sizeof(TLOGPALETTE) + 
      (255 * sizeof(TPALETTEENTRY)));
    FillChar(pPal^, sizeof(TLOGPALETTE) + 
      (255 * sizeof(TPALETTEENTRY)), #0);
    pPal^.palVersion := $300;
    pPal^.palNumEntries := 
      GetSystemPaletteEntries(dc,
                              0,
                              256,
                              pPal^.palPalEntry);
    if pPal^.PalNumEntries <> 0 then begin
      pal := CreatePalette(pPal^);
      oldPal := SelectPalette(MemDc, Pal, false);
      isDcPalDevice := true
    end else
    FreeMem(pPal, sizeof(TLOGPALETTE) + 
           (255 * sizeof(TPALETTEENTRY)));
  end;

 {copy from the screen to the memdc/bitmap}
  BitBlt(MemDc,
         0, 0,
         form1.width, form1.height,
         Dc,
         form1.left, form1.top,
         SrcCopy);

  if isDcPalDevice = true then begin
    SelectPalette(MemDc, OldPal, false);
    DeleteObject(Pal);
  end;

 {unselect the bitmap}
  SelectObject(MemDc, OldMemBitmap);
 {delete the memory dc}
  DeleteDc(MemDc);
 {Allocate memory for a DIB structure}
  hDibHeader := GlobalAlloc(GHND,
                            sizeof(TBITMAPINFO) +
                            (sizeof(TRGBQUAD) * 256));
 {get a pointer to the alloced memory}
  pDibHeader := GlobalLock(hDibHeader);

 {fill in the dib structure with info on the way we want the DIB}
  FillChar(pDibHeader^, 
           sizeof(TBITMAPINFO) + (sizeof(TRGBQUAD) * 256), 
           #0);
  PBITMAPINFOHEADER(pDibHeader)^.biSize := 
    sizeof(TBITMAPINFOHEADER);
  PBITMAPINFOHEADER(pDibHeader)^.biPlanes := 1;
  PBITMAPINFOHEADER(pDibHeader)^.biBitCount := 8;
  PBITMAPINFOHEADER(pDibHeader)^.biWidth := form1.width;
  PBITMAPINFOHEADER(pDibHeader)^.biHeight := form1.height;
  PBITMAPINFOHEADER(pDibHeader)^.biCompression := BI_RGB;

 {find out how much memory for the bits}
  GetDIBits(dc,
            MemBitmap,
            0,
            form1.height,
            nil,
            TBitmapInfo(pDibHeader^),
            DIB_RGB_COLORS);

 {Alloc memory for the bits}
  hBits := GlobalAlloc(GHND, 
                       PBitmapInfoHeader(pDibHeader)^.BiSizeImage);
 {Get a pointer to the bits}
  pBits := GlobalLock(hBits);

 {Call fn again, but this time give us the bits!}
  GetDIBits(dc,
            MemBitmap,
            0,
            form1.height,
            pBits,
            PBitmapInfo(pDibHeader)^,
            DIB_RGB_COLORS);

 {Lets try a fixup for broken video drivers}
  if isDcPalDevice = true then begin
    for i := 0 to (pPal^.PalNumEntries - 1) do begin
      PBitmapInfo(pDibHeader)^.bmiColors[i].rgbRed := 
        pPal^.palPalEntry[i].peRed;
      PBitmapInfo(pDibHeader)^.bmiColors[i].rgbGreen :=
        pPal^.palPalEntry[i].peGreen;
      PBitmapInfo(pDibHeader)^.bmiColors[i].rgbBlue :=
        pPal^.palPalEntry[i].peBlue;
    end;
    FreeMem(pPal, sizeof(TLOGPALETTE) +
           (255 * sizeof(TPALETTEENTRY)));
  end;

 {Release the screen dc}
  ReleaseDc(0, dc);
 {Delete the bitmap}
  DeleteObject(MemBitmap);

 {Start print job}
  Printer.BeginDoc;

 {Scale print size}
  if Printer.PageWidth < Printer.PageHeight then begin
   ScaleX := Printer.PageWidth;
   ScaleY := Form1.Height * (Printer.PageWidth / Form1.Width);
  end else begin
   ScaleX := Form1.Width * (Printer.PageHeight / Form1.Height);
   ScaleY := Printer.PageHeight;
  end;


 {Just incase the printer drver is a palette device}
  isDcPalDevice := false;
  if GetDeviceCaps(Printer.Canvas.Handle, RASTERCAPS) and
      RC_PALETTE = RC_PALETTE then begin
   {Create palette from dib}
    GetMem(pPal, sizeof(TLOGPALETTE) +
          (255 * sizeof(TPALETTEENTRY)));
    FillChar(pPal^, sizeof(TLOGPALETTE) + 
          (255 * sizeof(TPALETTEENTRY)), #0);
    pPal^.palVersion := $300;
    pPal^.palNumEntries := 256;
    for i := 0 to (pPal^.PalNumEntries - 1) do begin
      pPal^.palPalEntry[i].peRed := 
        PBitmapInfo(pDibHeader)^.bmiColors[i].rgbRed;
      pPal^.palPalEntry[i].peGreen := 
        PBitmapInfo(pDibHeader)^.bmiColors[i].rgbGreen;
      pPal^.palPalEntry[i].peBlue := 
        PBitmapInfo(pDibHeader)^.bmiColors[i].rgbBlue;
    end;
    pal := CreatePalette(pPal^);
    FreeMem(pPal, sizeof(TLOGPALETTE) + 
            (255 * sizeof(TPALETTEENTRY)));
    oldPal := SelectPalette(Printer.Canvas.Handle, Pal, false);
    isDcPalDevice := true
  end;

 {send the bits to the printer}
  StretchDiBits(Printer.Canvas.Handle,
                0, 0,
                Round(scaleX), Round(scaleY),
                0, 0,
                Form1.Width, Form1.Height,
                pBits,
                PBitmapInfo(pDibHeader)^,
                DIB_RGB_COLORS,
                SRCCOPY);

 {Just incase you printer drver is a palette device}
  if isDcPalDevice = true then begin
    SelectPalette(Printer.Canvas.Handle, oldPal, false);
    DeleteObject(Pal);
  end;


 {Clean up allocated memory}
  GlobalUnlock(hBits);
  GlobalFree(hBits);
  GlobalUnlock(hDibHeader);
  GlobalFree(hDibHeader);


 {End the print job}
  Printer.EndDoc;


end;
