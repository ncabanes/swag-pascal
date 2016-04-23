{
From: bobs@dragons.nest.nl (Bob Swart)

> For what it's worth, I took a look at it and determined that it is
> not useful for Pascal.  One of the main reasons was that the DLL
> used the C calling convention.

Well, I hate to disagree with you, but it can be done. In fact, it has been
done. Mike Scott has written an interface unit, which is included below. The
unit can also be downloaded from CompuServe (BPASCAL forum) and will be
included on the disk with The Pascal Magazine #5 which includes some articles
on using WinG from Borland Pascal.

Anyway, here's the import unit from Mike (I think a newer version will be on
The Pascal Magazine disk):

{*******************************************************}
{                                                       }
{       WinG Import Unit for Borland Pascal             }
{                                                       }
{       Written by Mike Scott, CIS 100140,2420          }
{       Preliminary version 9th July 1994               }
{                                                       }
{*******************************************************}

unit WinG ;

interface

uses WinTypes ;

{ WinG Types }

type
  PPointer = ^pointer ;
  PRGBQuad = ^TRGBQuad ;
  WING_DITHER_TYPE = word ;

const
  WING_DISPERSED_4x4 = 0 ;
  WING_DISPERSED_8x8 = 1 ;
  WING_CLUSTERED_4x4 = 2 ;

{ WinG DC's & WinG Bitmaps }

function  WinGCreateDC : HDC ;
function  WinGCreateBitmap( hWinGDC : HDC ;
                            pHeader : PBitmapInfo ;
                            ppBits  : PPointer ) : HBitmap ;
function  WinGGetDIBPointer( hWinGBitmap : HBitmap ;
                             pHeader     : PBitmapInfo ) : pointer ;
function  WinGRecommendDIBFormat( pHeader : PBitmapInfo ) : Bool ;
function  WinGGetDIBColorTable( hWinGDC         : HDC ;
                                StartIndex      : word ;
                                NumberOfEntries : word ;
                                pColors         : PRGBQuad ) : word ;
function  WinGSetDIBColorTable( hWinGDC         : HDC ;
                                StartIndex      : word ;
                                NumberOfEntries : word ;
                                pColors         : PRGBQuad ) : word ;

{ Blts }

function  WinGBitBlt( hdcDest      : HDC ;
                      nXOriginDest : integer ;
                      nYOriginDest : integer ;
                      nWidthDest   : integer ;
                      nHeightDest  : integer ;
                      hdcSrc       : HDC ;
                      nXOriginSrc  : integer ;
                      nYOriginSrc  : integer ) : Bool ;
function  WinGStretchBlt( hdcDest      : HDC ;
                          nXOriginDest : integer ;
                          nYOriginDest : integer ;
                          nWidthDest   : integer ;
                          nHeightDest  : integer ;
                          hdcSrc       : HDC ;
                          nXOriginSrc  : integer ;
                          nYOriginSrc  : integer ;
                          nWidthSrc    : integer ;
                          nHeightSrc   : integer ) : Bool ;

{ Halftoning }

function  WinGCreateHalftoneBrush( DC         : HDC ;
                                   Color      : TColorRef ;
                                   DitherType : WING_DITHER_TYPE ) : HBrush ;
function  WinGCreateHalftonePalette : HPalette ;


implementation

function  WinGCreateDC ;              external 'WinG' index 1001 ;
function  WinGCreateBitmap ;          external 'WinG' index 1003 ;
function  WinGGetDIBPointer ;         external 'WinG' index 1004 ;
function  WinGRecommendDIBFormat ;    external 'WinG' index 1002 ;
function  WinGGetDIBColorTable ;      external 'WinG' index 1005 ;
function  WinGSetDIBColorTable ;      external 'WinG' index 1006 ;
function  WinGBitBlt ;                external 'WinG' index 1010 ;
function  WinGStretchBlt ;            external 'WinG' index 1009 ;
function  WinGCreateHalftoneBrush ;   external 'WinG' index 1008 ;
function  WinGCreateHalftonePalette ; external 'WinG' index 1007 ;

end.

