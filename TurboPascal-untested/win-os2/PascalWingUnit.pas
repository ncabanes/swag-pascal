(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0034.PAS
  Description: Pascal WinG Unit
  Author: MATTHEW R POWENSKI
  Date: 08-25-94  09:06
*)

{ From: dv224@cleveland.Freenet.Edu (Matthew R Powenski) }

Unit WinG;

Interface

Uses
  WinTypes;

Type
  pPointer = ^Pointer;
  Wing_Dither_Type = (WING_DISPERSED_4x4,
                   WING_DISPERSED_8x8, WING_CLUSTERED_4x4);

{**** WingDC and WinGBitmap
************************************************}

  Function WinGCreateDC: HDC;
  Function WinGRecommendDIBFormat (pFormat: pBitmapInfo): Bool;
  Function WinGCreateBitmap (WinGDC: hDC; pHeader: pBitmapInfo;
ppBits: pPointer): hBitmap;
  Function WinGGetDIBPointer (WinGBitmap: hBitmap; pHeader:
pBitmapInfo): Pointer;
  Function WinGGetDIBColorTable (WinGDC:
hDC;StartIndex,NumberOfEntries: Word; Var Colors: tRgbQuad): Word;
  Function WinGSetDIBColorTable (WinGDC:
hDC;StartIndex,NumberOfEntries: Word; Var Colors: tRgbQuad): Word;

{**** Halftoning
***********************************************************}

  Function WinGCreateHalftonePalette: HPALETTE;
  Function WinGCreateHalftoneBrush (Context: HDC;crColor: tColorRef;
DitherType: WING_DITHER_TYPE): hBrush;

{**** Blts
***************************************************************
**}

  Function WinGBitBlt (hdcDest:
HDC;nXOriginDest,nYOriginDest,nWidthDest,nHeightDest: Integer;
                       hdcSrc: HDC;nXOriginSrc,nYOriginSrc: Integer): Bool;

  Function WinGStretchBlt (hdcDest:
HDC;nXOriginDest,nYOriginDest,nWidthDest,nHeightDest: Integer;
                           hdcSrc:
HDC;nXOriginSrc,nYOriginSrc,nWidthSrc,nHeightSrc: Integer): Bool;

Implementation
  Function WinGBitBlt;                    External 'WING'     Index 1010;
  Function WinGCreateBitmap;              External 'WING'     Index 1003;
  Function WinGCreateDC;                  External 'WING'     Index 1001;
  Function WinGCreateHalftoneBrush;       External 'WING'     Index 1008;
  Function WinGCreateHalftonePalette;     External 'WING'     Index 1007;
  Function WinGGetDIBColorTable;          External 'WING'     Index 1005;
  Function WinGGetDIBPointer;             External 'WING'     Index 1004;
  Function WinGRecommendDIBFormat;        External 'WING'     Index 1002;
  Function WinGSetDIBColorTable;          External 'WING'     Index 1006;
  Function WinGStretchBlt;                External 'WING'     Index 1009;
  End.

