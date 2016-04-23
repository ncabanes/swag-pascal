
unit WinG;  {WinG import unit for Borland Pascal}
interface
uses winTypes;

function WinGCreateDC:hDC;
function WinGRecommendDIBFormat(pFormat:pBitmapInfo):boolean;
function WinGCreateBitmap(WinGDC:hDC; pHeader:pBitmapInfo; var 
ppBits:pointer):hBitmap;
function WinGGetDIBPointer(WinGBitmap:hBitmap; 
pHeader:pBitmapInfo):pointer;
function WinGGetDIBColorTable(WinGDC:hDC; StartIndex, NumberOfEntries:word; 
pColors:pointer):word;
function WinGSetDIBColorTable(WinGDC:hDC; StartIndex, NumberOfEntries:word; 
pColors:pointer):word;

function WinGCreateHalftonePalette:hPalette;
type tWinGDither=(winG4x4Dispersed,winG8x8Dispersed,winG4x4Clustered);
function WinGCreateHalftoneBrush(context:hDC; crColor:tColorRef; 
ditherType:tWinGDither):hBrush;

function WinGBitBlt(hdcDst:hDC; nXOriginDst, nYOriginDst, nWidthDst, 
nHeightDst:integer;
                    hdcSrc:hDC; nXOriginSrc, nYOriginSrc:integer):boolean;
function WinGStretchBlt(hdcDst:hDC; nXOriginDst, nYOriginDst, nWidthDst, 
nHeightDst:integer;
                        hdcSrc:hDC; nXOriginSrc, nYOriginSrc, nWidthSrc, 
nHeightSrc:integer):boolean;

implementation

function WinGCreateDC:hDC; external 'WinG';
function WinGRecommendDIBFormat; external 'WinG';
function WinGCreateBitmap; external 'WinG';
function WinGGetDIBPointer; external 'WinG';
function WinGGetDIBColorTable; external 'WinG';
function WinGSetDIBColorTable; external 'WinG';

function WinGCreateHalftonePalette; external 'WinG';
function WinGCreateHalftoneBrush; external 'WinG';

function WinGBitBlt; external 'WinG';
function WinGStretchBlt; external 'WinG';

end.

Here is an example of how to implement Delphi with WING..

{$A+,B-,D-,F+,G+,I-,K-,L-,N-,P-,Q-,R-,S-,T-,V-,W-,X+,Y-}
{$M 8192,8192}
PROGRAM BPWinG;

{ - Demonstration of WinG with Borland Pascal
    Written by Lars Fosdal, lfosdal@falcon.no,

    Initial version: 11 NOV 1994
    Version 2: 24 NOV 1994

    Released to the public domain, 11 NOV 1994

    Based on:
      WinG DLL import unit
        by Matthew R Powenski, dv224@cleveland.Freenet.Edu

      STATIC - A WinG Sample Application (written in C)
        by Robert B. Hess, Microsoft Corp.

      flames.pas from the SWAG libraries (DOS VGA demo)
        by Keith DegrΓce, ekd0840@bosoleil.ci.umoncton.ca.
                       or 9323767@info.umoncton.ca

    Note: WinG must be installed before this program can be run.

    Hopefully, the latest version of this program can be found as
      garbo.uwasa.fi:/windows/turbopas/bpwing##.zip
    where ## is a version number.

    Comments:
      Actually, this is a pretty lame demo (source translated, ideas stolen,
      performance sucks, usability nil), but it shows you the general idea
      of WinG.  On a VL or PCI local bus graphics adapter, the performance
      isn't to bad, but it gets real slow on ISA-only cards.
      In an intelligent WinG app. you don't usually repaint the entire 
bitmap,
      but only the changed sections. You would also tune the bitmap 
generation
      and manipulation routines with assembly, and apply the usual bag of
      animations tricks.

      However, thats for you to do!  Have fun!

    Changes, Version 2:
     - Range error caused GPF under Win16 (Wonder why it worked under 
Win32/WOW?)
     - Fixed bitmap orientation problem (Didn't work on bottom-up 
oriented bmps)
     - Restructured and added run-time selectable animation style
     - added more comments

     And:
       Yep, I know I should have erased the bitmap before I changed the 
palette
       to avoid the "wrong color" flash... You do it :-)

    Thanks to:
      Eivind Bakkestuen (hillbilly@programmers.bbs.no)
      for reporting the GPF problem in the initial release.

      Timo Salmi, Ari Hovila, and Jouni Ikonen
      for keeping garbo.uwasa.fi a great site to visit.

}

USES
{$IFDEF Debug}
  WinCRT,
{$ENDIF}
  WinTypes, WinProcs, oWindows, oDialogs, WinG;

{$R BPWinG.RES}

{.DEFINE x2}  {Stretch to 2 x Size (A _LOT_ Slower :-( )}

CONST {Image sizes (flames demo doesn't adapt too well, though)}
  ImageX = 320; {Must be a multiple of two}
  ImageY = 200; {ImageX x ImageY must not exceed 64K}
                {(Unless you want to write your own array access methods...
                  I _REALLY_ want a 32 bit Pascal :-))}

TYPE
  pScreen = ^TScreen; {Bitmap access table}
  TScreen = RECORD
    CASE Integer OF
      0 : (ptb : ARRAY[-(ImageY-1)..0, 0..ImageX-1] OF Byte);
          {ptb = byte coord [y, x]}
      1 : (ptw : ARRAY[-(ImageY-1)..0, 0..(ImageX DIV 2)-1] OF Word);
          {ptw = word coord [y, x div 2]}
      2 : (pta : ARRAY[0..(ImageY*ImageX)-1] OF Byte);
          {pta = byte array [(y*320)+x]}
  END; {REC TScreen}

  TImage = RECORD {DIB Information}
    bi       : TBitmapInfoHeader;
    aColors  : ARRAY[0..255] OF TRGBQUAD;
  END; {REC TImage}

  TPalette = RECORD {Palette Information}
    Version : Word;         {set to $0300 (Windows version 3.0)}
    NumberOfEntries : Word; {set to 256}
    aEntries : ARRAY[0..255] OF TPaletteEntry;
  END; {REC TPalette}

  pWinGApp = ^TWinGApp; {OWL Application}
  TWinGApp = OBJECT(TApplication)
    PROCEDURE InitMainWindow; VIRTUAL;
  END; {OBJ TWinGApp}

  pWinGWin = ^TWinGWin; {OWL Window}
  TWinGWin = OBJECT(TWindow)
    LogicalPalette : TPalette; {Our palette initialization table}
    hPalApp    : hPalette; {Our palette}
    Image      : TImage;   {Our bitmap initialization table}
    hdcImage   : hDC;      {Our WinG DC}
    hOldBitmap : hBitmap;  {Ye olde bitmap of the WinG DC must be restored}
    bmp        : pScreen;  {Assistant bitmap pointer}
    Orientation : Integer; {Indicates bitmap orientation,  1=top-down 
-1=bottom-up}
    Direction   : Integer; {Determines animation direction 1=Up       
-1=Down}
    CONSTRUCTOR Init(aParent:pWindowsObject; aTitle:pChar);
    DESTRUCTOR Done;                                   VIRTUAL;
    PROCEDURE GetWindowClass(VAR aWndClass:TWndClass); VIRTUAL;
    PROCEDURE SetupWindow;                             VIRTUAL;
    PROCEDURE SetDirection(NewDirection:Integer);
    PROCEDURE wmEraseBkGnd(VAR Msg:TMessage);          VIRTUAL wm_First + 
wm_EraseBkGnd;
    PROCEDURE wmPaletteChanged(VAR Msg:TMessage);      VIRTUAL wm_First + 
wm_PaletteChanged;
    PROCEDURE wmQueryNewPalette(VAR Msg:TMessage);     VIRTUAL wm_First + 
wm_QueryNewPalette;
    PROCEDURE wmTimer(VAR Msg:TMessage);               VIRTUAL wm_First + 
wm_Timer;
    PROCEDURE Paint(PaintDC:hDC; VAR PaintInfo:TPaintStruct); VIRTUAL;
    PROCEDURE cmAbout(VAR Msg:TMessage);               VIRTUAL cm_First + 
100;
    PROCEDURE cmQuit(VAR Msg:TMessage);                VIRTUAL cm_First + 
101;
    PROCEDURE cmDirection(VAR Msg:TMessage);           VIRTUAL cm_First + 
102;
  END; {OBJ TWinGWin}


{//////////////////////////////////////////////////////////////// 
TWinGApp ///}

PROCEDURE TWinGApp.InitMainWindow;
BEGIN
  MainWindow:=New(pWinGWin, Init(nil, 'WinG + Pascal!'));
END; {PROC TWinGApp.InitMainWindow}


{//////////////////////////////////////////////////////////////// 
TWinGWin ///}

CONSTRUCTOR TWinGWin.Init(aParent:pWindowsObject; aTitle:pChar);
BEGIN
  Inherited Init(aParent, aTitle);
  Attr.Style:=ws_PopupWindow or ws_Caption;
  Attr.x:=160;
  Attr.y:=110;
  Attr.w:={$IFDEF x2}2* {$ENDIF}ImageX + (2 * GetSystemMetrics(sm_CXBorder));
  Attr.h:={$IFDEF x2}2* {$ENDIF}ImageY + (2 * GetSystemMetrics(sm_CYBorder))
                 + GetSystemMetrics(sm_CYCaption)
                 + GetSystemMetrics(sm_CYMenu);
  Attr.Menu:=LoadMenu(hInstance, pChar('WinG_MNU'));
  hPalApp:=0;
  hdcImage:=0;
  hOldBitmap:=0;
  Orientation:=1;
  Direction:=1;
END; {CONS TWinGWin.Init}

DESTRUCTOR TWinGWin.Done;
VAR
  hbm : hBitmap;
BEGIN
  IF Bool(hDCImage)                      {If we have a valid DC handle}
  THEN BEGIN
    hbm:=SelectObject(hdcImage, hOldBitmap); {Restore old bitmap}
    DeleteObject(hBM);                       {Delete our bitmap}
    DeleteDC(hdcImage);                      {Delete our DC}
  END;
  IF Bool(hPalApp)                       {If we have a valid palette handle}
  THEN DeleteObject(hPalApp);                {delete our palette}
  KillTimer(hWindow, 1);                 {Kill our timer}
  Inherited Done;                        {Leave the rest to OWL}
END; {DEST TWinGWin.Done}

PROCEDURE TWinGWin.GetWindowClass(VAR aWndClass:TWndClass);
BEGIN
  Inherited GetWindowClass(aWndClass);
  aWndClass.hIcon:=LoadIcon(hInstance, pChar('WinG_ICO')); {Load our Icon}
  aWndClass.Style:=cs_ByteAlignClient or cs_VRedraw or cs_HRedraw or 
cs_DblClks;
END; {PROC TWinGWin.GetWindowClass}

PROCEDURE TWinGWin.SetupWindow;
VAR
  Desktop     : hDC;     {Get the system colors via the Desktop DC}
  i           : Integer; {general purpose}
BEGIN
  Inherited SetupWindow;             {Let OWL do it's part}

  Randomize;

  SetTimer(hWindow, 1, 40, nil);     {Create our timer (40ms = 25 
paints/sec)}
  FillChar(Image, SizeOf(Image), 0); {Better safe than sorry}

  {Ask WinG about the preferred bitmap format}
  IF WinGRecommendDIBFormat(pBitmapInfo(@Image.Bi))
  THEN BEGIN
    Image.Bi.biBitCount:=8;          {Force to 8 bits per pixel}
    Image.Bi.biCompression:=bi_RGB;  {Force to no compression}
    Orientation:=Image.bi.biHeight;  {Get height}
  END
  ELSE WITH Image.bi              {If WinG failed to initialize our image 
info}
  DO BEGIN                        {we'll do it ourselves}
    biSize:=SizeOf(Image.bi);
    biPlanes:=1;
    biBitCount:=8;
    biCompression:=bi_RGB;
    biSizeImage:=0;
    biClrUsed:=0;
    biClrImportant:=0;
    Orientation:=1;
  END;

  Image.bi.biWidth:=ImageX;       {Define the image sizes}
  Image.bi.biHeight:=ImageY * Orientation;
  image.bi.biSizeImage := (image.bi.biWidth * image.bi.biHeight);
  image.bi.biSizeImage := image.bi.biSizeImage*Orientation;

  Desktop:=GetDC(0); {Setup our palette init info and get the 20 system 
colors}
  LogicalPalette.Version:=$0300;
  LogicalPalette.NumberOfEntries:=256;
  GetSystemPaletteEntries(Desktop, 0, 10, LogicalPalette.aEntries);
  GetSystemPaletteEntries(Desktop, 246, 10, LogicalPalette.aEntries[246]);
  ReleaseDC(0, Desktop);

  FOR i:=0 TO 9  {Duplicate the system colors into the bitmap}
  DO BEGIN
    Image.aColors[i].rgbRed  :=LogicalPalette.aEntries[i].peRed;
    Image.aColors[i].rgbGreen:=LogicalPalette.aEntries[i].peGreen;
    Image.aColors[i].rgbBlue :=LogicalPalette.aEntries[i].peBlue;
    Image.aColors[i].rgbReserved:=0;
    LogicalPalette.aEntries[i].peFlags:=0;

    Image.aColors[i+246].rgbRed  :=LogicalPalette.aEntries[i].peRed;
    Image.aColors[i+246].rgbGreen:=LogicalPalette.aEntries[i].peGreen;
    Image.aColors[i+246].rgbBlue :=LogicalPalette.aEntries[i].peBlue;
    Image.aColors[i+246].rgbReserved:=0;
    LogicalPalette.aEntries[i+246].peFlags:=0;
  END;

  hdcImage:=WinGCreateDC;                                {Get our WinG DC}

  SetDirection(1);

END; {PROC TWinGWin.SetupWindow}

PROCEDURE TWinGWin.SetDirection(NewDirection:Integer);
  PROCEDURE SetRgb(i,r,g,b:Byte);
  CONST
    c = 4; {Scale up the DOS colors to fit a 24-bit palette}
  BEGIN
    LogicalPalette.aEntries[i].peRed   := r*c;
    LogicalPalette.aEntries[i].peGreen := g*c;
    LogicalPalette.aEntries[i].peBlue  := b*c;
    Image.aColors[i].rgbRed  :=LogicalPalette.aEntries[i].peRed;
    Image.aColors[i].rgbGreen:=LogicalPalette.aEntries[i].peGreen;
    Image.aColors[i].rgbBlue :=LogicalPalette.aEntries[i].peBlue;
    Image.aColors[i].rgbReserved:=0;
    LogicalPalette.aEntries[i].peFlags:=PC_NOCOLLAPSE;
  END;
VAR
  i   : Integer;
  hbm : hBitmap; {Handle to our bitmap}
  mnu : hMenu;
BEGIN
  Direction:=NewDirection;
  mnu:=GetMenu(hWindow);
  IF Direction=1
  THEN BEGIN
    SetWindowText(hWindow,'WinG + Pascal = Hot!');
    ModifyMenu(mnu, 102, mf_ByCommand, 102, 'C&ool!');
    FOR i := 1 TO 32 {Build Black->Red->Yellow->White colors}
    DO BEGIN
     SetRgb(i, (i shl 1)-1, 0, 0 );
     SetRgb(i+32, 63, (i shl 1)-1, 0 );
     SetRgb(i+64, 63, 63, (i shl 1)-1 );
     SetRgb(i+96, 63, 63, 63 );
    END
  END
  ELSE BEGIN
    SetWindowText(hWindow,'WinG + Pascal = Cool!');
    ModifyMenu(mnu, 102, mf_ByCommand, 102, 'H&ot!');
    FOR i := 1 TO 32 {Build Black->Blue->Cyan->White colors}
    DO BEGIN
     SetRgb(i, 0, 0, (i shl 1)-1);
     SetRgb(i+32,  0, (i shl 1)-1, 63 );
     SetRgb(i+64, (i shl 1)-1, 63, 63 );
     SetRgb(i+96, 63, 63, 63 );
    END;
  END;
  DrawMenuBar(hWindow);

  IF Bool(hOldBitmap)
  THEN BEGIN
    DeleteObject(hPalApp);
    DeleteObject(SelectObject(hDCImage, hOldBitmap));
  END;
  hPalApp:=CreatePalette(pLogPalette(@LogicalPalette)^);
  hBM:=WinGCreateBitmap(hdcImage, pBitmapInfo(@Image.Bi), @bmp);

  hOldBitmap:=SelectObject(hdcImage, hBM); {Associate the bitmap with the DC}

  PatBlt(hDCImage, 0,0, ImageX, ImageY, BLACKNESS); {Paint the bitmap black}
  InvalidateRect(hWindow, nil, True);
END; {PROC TWinGWin.SetDirection}

PROCEDURE TWinGWin.wmEraseBkGnd(VAR Msg:TMessage);
BEGIN
  Bool(Msg.Result):=True; {We don't want Windows to erase our background}
END; {FUNC TWinGWin.wmEraseBkGnd}

PROCEDURE TWinGWin.wmPaletteChanged(VAR Msg:TMessage);
BEGIN                           {If some other Windows app has focus and 
changed}
  IF Msg.wParam=hWindow         {the system colors, we'll update too so 
that we}
  THEN wmQueryNewPalette(Msg);  {can get the second best choices}
END; {PROC TWinGWin.wmPaletteChanged}

PROCEDURE TWinGWin.wmQueryNewPalette(VAR Msg:TMessage);
{ - Update palette and repaint if changed}
VAR
  DC : hDC;
  ReMappedColors:Word;
BEGIN
  DC:=GetDC(hWindow);
  IF Bool(hPalApp)
  THEN SelectPalette(DC, hPalApp, False);
  ReMappedColors:=RealizePalette(DC);
  ReleaseDC(hWindow, DC);
  IF (ReMappedColors > 0)
  THEN BEGIN
    InvalidateRect(hWindow, nil, True);
    Bool(Msg.Result):=True;
  END
  ELSE Bool(Msg.Result):=False;
END; {PROC TWinGWin.wmQueryNewPalette}

PROCEDURE TWinGWin.wmTimer(VAR Msg:TMessage);
BEGIN
  InvalidateRect(hWindow, nil, False); {Force a repaint}
END; {PROC TWinGWin.wmTimer}

PROCEDURE TWinGWin.Paint(PaintDC:hDC; VAR PaintInfo:TPaintStruct);
VAR
  x,y,
  x2,y2,c : Integer;
  one, two : Integer;
BEGIN
  SelectPalette(PaintDC, hPalApp, False); {Select our palette}
  RealizePalette(PaintDC);                {and map it to the system palette}
  IF not Assigned(bmp)
  THEN Exit;
  WITH bmp^         {With our bitmap bits}
  DO BEGIN
    one:=1*Orientation*Direction;
    two:=2*Orientation*Direction;
    FOR x := 0 TO 159  {Update the flame bitmap}
    DO BEGIN
      x2:=x shl 1;
      FOR y := 30 TO 98
      DO BEGIN
        IF Orientation=Direction
        THEN y2:=-(y shl 1)
        ELSE y2:=-200+(y shl 1);
        c := (ptb[y2,x2]
            + ptb[y2,x2+2]
            + ptb[y2,x2-2]
            + ptb[y2-two,x2+2]) shr 2;
        IF c <> 0 THEN dec(c);
        ptw[y2+two, x] := Word(c or (c shl 8));
        ptw[y2+one, x] := Word(c or (c shl 8));
      END;
      ptb[y2,x2] := random(2)*160;
    END;
  END;
{$IFDEF x2}
  WinGStretchBlt(PaintDC, 0,0, 2*ImageX, 2*ImageY, hdcImage, 0,0, ImageX, 
ImageY);
{$ELSE}
  WinGBitBlt(PaintDC, 0,0, ImageX, ImageY, hdcImage, 0,0);
{$ENDIF}
END; {PROC TWinGWin.Paint}

PROCEDURE TWinGWin.cmAbout(VAR Msg:TMessage);
VAR
  Dlg : pDialog;
BEGIN
  New(Dlg, Init(@Self, pChar('WinG_DLG')));
  Dlg^.Execute;
  Dispose(Dlg, Done);
END; {PROC TWinGWin.cmAbout}

PROCEDURE TWinGWin.cmDirection(VAR Msg:TMessage);
BEGIN
  SetDirection(-Direction);
END; {PROC TWinGWin.cmDirection}

PROCEDURE TWinGWin.cmQuit(VAR Msg:TMessage);
BEGIN
  CloseWindow;
END; {PROC TWinGWin.cmQuit}

VAR
  App : pWinGApp;
BEGIN
  New(App, Init('BPWinG'));
  App^.Run;
  Dispose(App, Done);
END.

