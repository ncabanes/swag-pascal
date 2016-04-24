(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0068.PAS
  Description: WinG Interface
  Author: ERIC NIELSEN
  Date: 11-24-95  10:16
*)


There are a couple of problems with using WinG and the Delphi IDE.  First,
WinG has some sort of problem with ToolHelp that causes GPF's all the time.
Second, WinG apps created with Delphi don't always seem to load the WING.DLL
file correctly (!) so the programs will not run.

Using LoadLibrary to access WinG seems to alleviate both problems.  Here is
my WinG import unit:


unit Newwing;  {WinG import unit for Borland Pascal}
interface
uses winTypes, winProcs;

function InitWinG : Boolean;
function DeInitWinG : Boolean;

type
  TWinGDither = (winG4x4Dispersed,winG8x8Dispersed,winG4x4Clustered);
  TWinGCreateDC =
    function:hDC;
  TWinGRecommendDIBFormat =
    function(pFormat:pBitmapInfo):boolean;
  TWinGCreateBitmap =
    function(WinGDC:hDC; pHeader:pBitmapInfo; var ppBits:pointer):hBitmap;
  TWinGGetDIBPointer =
    function(WinGBitmap:hBitmap;pHeader:pBitmapInfo):pointer;
  TWinGGetDIBColorTable =
    function(WinGDC:hDC; StartIndex, NumberOfEntries:word;pColors:pointer):word;
  TWinGSetDIBColorTable =
    function(WinGDC:hDC; StartIndex, NumberOfEntries:word;pColors:pointer):word;
  TWinGCreateHalftonePalette =
    function:hPalette;
  TWinGCreateHalftoneBrush =
    function(context:hDC; crColor:tColorRef;ditherType:tWinGDither):hBrush;
  TWinGBitBlt =
    function(hdcDst:hDC; nXOriginDst, nYOriginDst, nWidthDst,nHeightDst:integer;
             hdcSrc:hDC; nXOriginSrc, nYOriginSrc:integer):boolean;
  TWinGStretchBlt =
    function(hdcDst:hDC; nXOriginDst, nYOriginDst, nWidthDst,nHeightDst:integer;
             hdcSrc:hDC; nXOriginSrc, nYOriginSrc, nWidthSrc,nHeightSrc:integer)
             :boolean;

var
  WinGCreateDC : TWinGCreateDC;
  WinGRecommendDIBFormat: TWinGRecommendDIBFormat;
  WinGCreateBitmap: TWinGCreateBitmap;
  WinGGetDIBPointer: TWinGGetDIBPointer;
  WinGGetDIBColorTable: TWinGGetDIBColorTable;
  WinGSetDIBColorTable: TWinGSetDIBColorTable;
  WinGCreateHalftonePalette: TWinGCreateHalftonePalette;
  WinGCreateHalftoneBrush: TWinGCreateHalftoneBrush;
  WinGBitBlt: TWinGBitBlt;
  WinGStretchBlt: TWinGStretchBlt;


implementation

Const
  WinGName : String = 'WING.DLL' + chr(0);
  WinGH : THandle = 0;

Function InitWinG : Boolean;
  Begin
    WinGH := LoadLibrary(@WinGName[1]);
    If WinGH < HINSTANCE_ERROR
      Then
        Begin
          InitWinG := False;
          Exit;
        End;
    @WinGCreateDC := GetProcAddress(WinGH,Pointer(1001));
    @WinGRecommendDIBFormat:= GetProcAddress(WinGH,Pointer(1002));
    @WinGCreateBitmap:= GetProcAddress(WinGH,Pointer(1003));
    @WinGGetDIBPointer:= GetProcAddress(WinGH,Pointer(1004));
    @WinGGetDIBColorTable:= GetProcAddress(WinGH,Pointer(1005));
    @WinGSetDIBColorTable:= GetProcAddress(WinGH,Pointer(1006));
    @WinGCreateHalftonePalette:= GetProcAddress(WinGH,Pointer(1007));
    @WinGCreateHalftoneBrush:= GetProcAddress(WinGH,Pointer(1008));
    @WinGStretchBlt:= GetProcAddress(WinGH,Pointer(1009));
    @WinGBitBlt:= GetProcAddress(WinGH,Pointer(1010));

    InitWinG := True;
  End;

Function DeInitWinG : Boolean;
  Begin
    FreeLibrary(WinGH);
    DeInitWinG := True;
  End;

End.

