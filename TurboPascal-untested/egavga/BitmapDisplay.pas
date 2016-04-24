(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0074.PAS
  Description: Bitmap Display
  Author: BO BENDTSEN
  Date: 01-27-94  11:53
*)

{
> Does anyone know how to view BIT map picture, thanx......
}

Type
  PBitmapCoreHeader = ^TBitmapCoreHeader;
  TBitmapCoreHeader = record
    bcSize: Longint;              { used to get to color table }
    bcWidth: Word;
    bcHeight: Word;
    bcPlanes: Word;
    bcBitCount: Word;
  end;

  PBitmapInfoHeader = ^TBitmapInfoHeader;
  TBitmapInfoHeader = record
    biSize: Longint;
    biWidth: Longint;
    biHeight: Longint;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: Longint;
    biSizeImage: Longint;
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: Longint;
    biClrImportant: Longint;
  end;

{ Constants for the biCompression field }

const
  bi_RGB  = 0;
  bi_RLE8 = 1;
  bi_RLE4 = 2;

type
  PBitmapInfo = ^TBitmapInfo;
  TBitmapInfo = record
    bmiHeader: TBitmapInfoHeader;
    bmiColors: array[0..0] of TRGBQuad;
  end;

type
  PBitmapCoreInfo = ^TBitmapCoreInfo;
  TBitmapCoreInfo = record
    bmciHeader: TBitmapCoreHeader;
    bmciColors: array[0..0] of TRGBTriple;
  end;

type
  PBitmapFileHeader = ^TBitmapFileHeader;
  TBitmapFileHeader = record
    bfType: Word;
    bfSize: Longint;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: Longint;
  end;


