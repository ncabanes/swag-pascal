{************************************************}
{                                                }
{   Turbo Pascal for Windows                     }
{   Demo unit                                    }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

{$R-}

unit LoadBMPs;

interface

uses WinProcs, WinTypes, Strings, WinDos;
  { ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ I do not have these units!!! }

function LoadBMP(Name: PChar; Window: hWnd; var DibPal: Word;
 var Width, Height: LongInt): hBitMap;

implementation

function CreateBIPalette(BI: PBitMapInfoHeader): HPalette;
type
 ARGBQuad = Array[1..5000] of TRGBQuad;
var
 RGB: ^ARGBQuad;
 NumColors: Word;
 Pal: PLogPalette;
 hPal: hPalette;
 I: Integer;
begin
 CreateBiPalette := 0;
 RGB := Ptr(Seg(BI^), Ofs(BI^)+BI^.biSize);
 if BI^.biBitCount<24 then
 begin
   NumColors:= 1 shl BI^.biBitCount;
   if NumColors<>0 then
   begin
     GetMem(Pal, SizeOf(PLogPalette)+NumColors*SizeOf(TPaletteEntry));
     Pal^.palNumEntries := NumColors;
     Pal^.palVersion := $300;
     for I := 0 to NumColors-1 do
     begin
       Pal^.palPalEntry[I].peRed := RGB^[I].rgbRed;
       Pal^.palPalEntry[I].peGreen := RGB^[I].rgbGreen;
       Pal^.palPalEntry[I].peBlue := RGB^[I].rgbBlue;
       Pal^.palPalEntry[I].peFlags := 0;
     end;
     hPal := CreatePalette(Pal^);
     FreeMem(Pal, SizeOf(PLogPalette) + NumColors * SizeOf(TPaletteEntry));
     CreateBiPalette := hPal;
   end;
 end;
end;

function LoadBMP(Name: PChar; Window: hWnd; var DibPal: Word;
 var Width, Height: LongInt): hBitMap;
var
 BitMapFileHeader: TBitMapFileHeader;
 DibSize, ReadSize, ColorTableSize, TempReadSize: LongInt;
 DIB: PBitMapInfoHeader;
 TempDib: Pointer;
 Bits: Pointer;
 F: File;
 BitMap: hBitMap;
 Handle: Word;
 DC: hDC;
 OldCursor: HCursor;
begin
 Assign(F, Name);
 {$I-}Reset(F, 1);{$I+}
 if IOResult<>0 then
 begin
   LoadBMP := 0;
   Exit;
 end;
 OldCursor := SetCursor(LoadCursor(0, IDC_Wait));
 BlockRead(F, BitMapFileHeader, SizeOf(BitMapFileHeader));
 DibSize := BitMapFileHeader.bfSize - BitMapFileHeader.bfOffBits;
 ReadSize := LongInt(BitMapFileHeader.bfSize) - SizeOf(BitMapFileHeader);
 Handle := GlobalAlloc(GMem_Moveable, ReadSize);
 DIB := GlobalLock(Handle);
 TempReadSize := ReadSize;
 TempDib := Dib;
 while TempReadSize > 0 do
 begin
   if TempReadSize > $8000 then
   begin
     BlockRead(F, TempDIB^, $8000);
     if Ofs(TempDib^) = $8000 then
        TempDib := Ptr(Seg(TempDib^) + 8, 0)
     else
        TempDib := Ptr(Seg(TempDib^), $8000);
   end
   else
     BlockRead(F, TempDIB^, TempReadSize);
   Dec(TempReadSize, $8000);
 end;
 if DIB^.biBitCount = 24 then
   ColorTableSize := 0
 else
   ColorTableSize := LongInt(1) shl DIB^.biBitCount * SizeOf(TRGBQuad);
 Bits := Ptr(Seg(DIB^), Ofs(DIB^) + DIB^.biSize + ColorTableSize);
 Close(F);
 DC := GetDC(Window);
 DibPal := CreateBIPalette(DIB);
 if DibPal = 0 then
 begin
   SelectPalette(DC, DibPal, false);
   RealizePalette(DC);
 end;
 BitMap := CreateDIBitMap(DC, DIB^, cbm_Init, Bits, PBitMapInfo(Dib)^,
   dib_RGB_Colors);
 Height := DIB^.biHeight;
 Width := DIB^.biWidth;
 ReleaseDC(Window, DC);
 GlobalUnLock(Handle);
 GlobalFree(Handle);
 LoadBMP := BitMap;
 SetCursor(OldCursor);
end;

end.
