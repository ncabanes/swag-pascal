{
Here my tiny icofuncs unit for Windows. As I recall it, I also posted the C
version in windows.prog. Here my special translation for you Pascal users.
Note: the undocumented DumpIcon function I use, works 100% guaranteed in Win16.
Users of Win32 (NOT Win32s) should resort to the documented GetIconInfo. Now is
this code useful? I don't know. Perhaps if you want to convert your icons to
their monochrome equivalents. Well anyway, try it.

Bye, Alfons (2:500/121.6252 or a.hoogervorst@dosgg.nl)

{ icofuncs.pas.
  Originally written in Pascal, then translated to C, reconverted to
  Pascal, then again to C.

  First posted in WINDOWS.PROG. Should have come to you through other
  mail areas. Perhaps it's already translated to other languages.
  But this one is authorized by me <g>.

  No copyrights claimed: I donate the source to the public domain.
  If you use it in your code, I won't mind my name appearing in any
  credits. It's such a nice name :-).

  Written by Alfons Hoogervorst
  Internet E-mail <a.hoogervorst@dosgg.nl>
  Fido     E-mail <2:500/121.6252 (Alfons Hoogervorst)>

  Only works with Win16. For Win32 users: use the GetIconInfo function.
}
unit icofuncs;

interface

uses
  WinTypes;

type
  HINSTANCE = THandle; { Clashes with System.hInstance :-) }
  HGLOBAL   = THandle;

  { When you resourcelock an HICON or HCURSOR you'll get a pointer to a
    TCursorIconInfo structure. }
  PCursorIconInfo = ^TCursorIconInfo;
  TCursorIconInfo = record
    ptHotSpot: TPoint;
    wWidth, wHeight, wWidthBytes: Word;
    byPlanes, byBitsPix: Byte;
  end;

function DumpIcon(AInfo: PCursorIconInfo; var HeaderLen: Word;
  var AndBits, XORMask: Pointer): LongInt;
function ColorToMonoIcon(hInst: HINSTANCE; hIconIn: HICON): HICON;
function IconToCursor(hInst: HINSTANCE; hIconIn: HICON; nHotSpotX,
  nHotSpotY: Integer): HCURSOR;

implementation

uses
  WinProcs;

const
  COLORWHITE = $00FFFFFF;
  COLORHALF  = Longint(COLORWHITE div 2);
  COLORBLACK = Longint(0);
  COLORMAXDISTANCE  = Longint(3 * Longint($ff * $ff));
  COLORHALFDISTANCE = Longint(COLORMAXDISTANCE div 2);

{ In my C module the next x functions were macros. I could have created
  some inline functions, but I didn't do this for the sake of
  "portability" (whatever that means in PASCAL world)
}

{ What a pity Turbo Pascal doesn't support unsigned long integers }
function ColorDistance(r, g, b: Word): Longint; near;
begin
  { To get the real distance you should take the square root of
    ColorDistance, but this is (ofcourse) unnecessary.
    By the by: casting to Longint absolutely necessary. Try it without
    the casts, and see what happens :-) }
  ColorDistance := Longint(r * r) + Longint(g * g) + Longint(b * b)
end;

function Conv2Mono(r, g, b: Integer): Longint; near;
begin
  if ColorDistance(r, g, b) > COLORHALFDISTANCE then
    CONV2MONO := COLORWHITE
  else CONV2MONO := COLORBLACK
end;

{ DumpIcon. This is a not documented function. Look in Undocumented Windows
  what it's doing or how it works. Or mail me. }
function DumpIcon; external 'USER' index 459;

function ColorToMonoIcon(hInst: HINSTANCE; hIconIn: HICON): HICON;
label { For goto haters only <g> }
  c2mi_unlockicon, c2mi_freebits;
var
  hdcScreen, hdcSource, hdcResult: HDC;
  hbmpSource, hbmpResult: HBITMAP;
  lpIcon: PCursorIconInfo;
  dwColor: Longint;
  lpAnd, lpXor: PChar;
  bmp: TBitmap;
begin
  ColorToMonoIcon := 0;
  lpIcon := PCursorIconInfo(LockResource(HGLOBAL(hIconIn)));
  if (lpIcon = nil) then exit;
  if (lpIcon^.byPlanes = $01) and (lpIcon^.byBitsPix = $01) then
    goto c2mi_unlockicon;

  {   Init. DCs. Icons Init DC's. Icons always seem to have device
      dependent bitmaps. On a 4 bpp screen device, icon bitmaps have a
      4 bpp DDB format. That's why a GetDIBits-conversion doesn't work.
      So, the resulting mono icon is not real monochrome. It looks
      monochrome, but it's just based on a device dependent bitmap }
  hdcScreen := GetDC(0);
  hdcSource := CreateCompatibleDC(hdcScreen);
  hdcResult := CreateCompatibleDC(hdcScreen);
  hbmpSource := CreateCompatibleBitmap(hdcScreen, lpIcon^.wWidth,
    lpIcon^.wHeight);
  hbmpResult := CreateCompatibleBitmap(hdcScreen, lpIcon^.wWidth,
    lpIcon^.wHeight);
  ReleaseDC(0, hdcScreen);

  if (hdcSource = 0) or (hdcResult = 0) or (hbmpResult = 0) or
     (hbmpSource = 0) then goto c2mi_freebits;

  hbmpSource := SelectObject(hdcSource, hbmpSource);
  hbmpResult := SelectObject(hdcResult, hbmpResult);

  { Draw & convert icon, OK not fast... First we need to black out
    source (hbmResult will contain XOR-bitmap }
  PatBlt(hdcSource, 0, 0, lpIcon^.wWidth, lpIcon^.wHeight, BLACKNESS);
  DrawIcon(hdcSource, 0, 0, hIconIn);
  for bmp.bmWidth := 0 to pred(lpIcon^.wWidth) do
    for bmp.bmHeight := 0 to pred(lpIcon^.wHeight) do
    begin
      dwColor := GetPixel(hdcSource, bmp.bmWidth, bmp.bmHeight);
      SetPixel(hdcResult, bmp.bmWidth, bmp.bmHeight, Conv2Mono(
         GetRValue(dwColor), GetGValue(dwColor),
         GetBValue(dwColor)))
    end;

  { OK to restore old state of DC }
  hbmpSource := SelectObject(hdcSource, hbmpSource);
  hbmpResult := SelectObject(hdcResult, hbmpResult);

  { Now a starter's guide on creating icons. First we need a pointer
    to our new data. We could use the data of lpIcon, but since this
    struct is undocumented I've switched to paranoid level 100.
    Win32 (not Win32s) offers the function GetIconInfo, so for
    32-bits apps use GetIconInfo, not DumpIcon }
  DumpIcon(lpIcon, Word(bmp.bmWidth), Pointer(lpAnd), Pointer(lpXor));
  GetObject(hbmpResult, sizeof(TBitmap), @bmp);
  dwColor := bmp.bmWidthBytes * bmp.bmHeight * bmp.bmPlanes;

  { Must allocate a little bit o' memory }
  GetMem(lpXor, dwColor);
  if (lpXor = nil) then goto c2mi_freebits;
  GetBitmapBits(hbmpResult, dwColor, lpXor);
  ColorToMonoIcon := CreateIcon(hInst, lpIcon^.wWidth, lpIcon^.wHeight,
    lpIcon^.byPlanes, lpIcon^.byBitsPix, lpAnd, lpXor);
  FreeMem(lpXor, dwColor);

  { Labels for goto haters only }
c2mi_freebits:
  if (hbmpResult <> 0) then DeleteObject(hbmpResult);
  if (hbmpSource <> 0) then DeleteObject(hbmpSource);
  if (hdcSource <> 0) then DeleteDC(hdcSource);
  if (hdcResult <> 0) then DeleteDC(hdcResult);

c2mi_unlockicon:
  UnlockResource(HGLOBAL(hIconIn));
end;

function IconToCursor(hInst: HINSTANCE; hIconIn: HICON; nHotSpotX,
  nHotSpotY: Integer): HCURSOR;
label
  i2c_freebits, i2c_unlockicon;
var
  hPseudoMonoIcon: HICON;
  hdcScreen, hdcMonoIcon, hdcPseudoMonoIcon: HDC;
  hbmpMonoIcon, hbmpPseudoMonoIcon: HBITMAP;
  MonoIconBitmap: TBitmap;
  lpXor, lpAnd: PChar;
  lpIcon: PCursorIconInfo;
  dummy: Longint;
begin
  IconToCursor := 0;
  hPseudoMonoIcon := ColorToMonoIcon(hInst, hIconIn);
  if (hPseudoMonoIcon = 0) then exit;
  lpIcon := PCursorIconInfo(LockResource(HGLOBAL(hIconIn)));
  if lpIcon = nil then exit;

  { Create GDI objects }
  hdcScreen := GetDC(0);
  hdcMonoIcon := CreateCompatibleDC(hdcScreen);
  hdcPseudoMonoIcon := CreateCompatibleDC(hdcScreen);
  hbmpMonoIcon := CreateCompatibleBitmap(hdcMonoIcon, lpIcon^.wWidth,
    lpIcon^.wHeight);
  hbmpPseudoMonoIcon := CreateCompatibleBitmap(hdcScreen, lpIcon^.wWidth,
    lpIcon^.wHeight);
  ReleaseDC(0, hdcScreen);

  { Sanity checks }
  if (hdcMonoIcon = 0) or (hdcPseudoMonoIcon = 0) or (hbmpMonoIcon = 0) or
     (hbmpPseudoMonoIcon = 0) then goto i2c_freebits;

  hbmpPseudoMonoIcon := SelectObject(hdcPseudoMonoIcon,
    hbmpPseudoMonoIcon);
  hbmpMonoIcon := SelectObject(hdcMonoIcon, hbmpMonoIcon);

  { Recreate Xor mask }
  PatBlt(hdcPseudoMonoIcon, 0, 0, lpIcon^.wWidth, lpIcon^.wHeight,
    BLACKNESS);
  DrawIcon(hdcPseudoMonoIcon, 0, 0, hPseudoMonoIcon);

  { Convert to mono icon }
  SetBkColor(hdcPseudoMonoIcon, COLORWHITE);
  BitBlt(hdcMonoIcon, 0, 0, lpIcon^.wWidth, lpIcon^.wHeight,
    hdcPseudoMonoIcon, 0, 0, SRCCOPY);

  { Reselect old bitmaps }
  hbmpPseudoMonoIcon := SelectObject(hdcPseudoMonoIcon,
    hbmpPseudoMonoIcon);
  hbmpMonoIcon := SelectObject(hdcMonoIcon, hbmpMonoIcon);

  { Now we have a monochrome XOR bitmap. Time to get the XOR and
    AND masks }
  GetObject(hbmpMonoIcon, sizeof(TBitmap), @MonoIconBitmap);
  DumpIcon(lpIcon, Word(dummy), Pointer(lpAnd), Pointer(lpXor));
  dummy := MonoIconBitmap.bmWidthBytes * MonoIconBitmap.bmHeight *
    MonoIconBitmap.bmPlanes;
  GetMem(lpXor, dummy);
  if (lpXor = nil) then goto i2c_freebits;
  GetBitmapBits(hbmpMonoIcon, dummy, lpXor);

  { Create cursor }
  IconToCursor := CreateCursor(hInst, nHotSpotX, nHotSpotY,
    lpIcon^.wWidth, lpIcon^.wHeight, lpAnd, lpXor);
  FreeMem(lpXor, dummy);

i2c_freebits:
  if (hbmpPseudoMonoIcon <> 0) then DeleteObject(hbmpPseudoMonoIcon);
  if (hbmpMonoIcon <> 0) then DeleteObject(hbmpMonoIcon);

  if (hdcPseudoMonoIcon <> 0) then DeleteDC(hdcPseudoMonoIcon);
  if (hdcMonoIcon <> 0) then DeleteDC(hdcMonoIcon);

i2c_unlockicon:
  UnlockResource(HGLOBAL(hIconIn));
end;

function IconToBitmap(hIconIn: HICON): HBITMAP;
label itb_freebitmap, itb_freedc;
var
  hbmpBitmap: HBITMAP;
  hdcScreen, hdcBitmap: HDC;
  x, y: Integer;
begin
  IconToBitmap := 0;

   x := GetSystemMetrics(SM_CXICON);
   y := GetSystemMetrics(SM_CYICON);

   hdcScreen := GetDC(0);
   hdcBitmap := CreateCompatibleDC(hdcScreen);
   hbmpBitmap := CreateCompatibleBitmap(hdcScreen, x, y);
   ReleaseDC(0, hdcScreen);

   if (hdcBitmap = 0) or (hbmpBitmap = 0) then goto itb_freebitmap;

   hbmpBitmap := SelectObject(hdcBitmap, hbmpBitmap);
   PatBlt(hdcBitmap, 0, 0, x, y, WHITENESS);
   DrawIcon(hdcBitmap, 0, 0, hIconIn);
   IconToBitmap := SelectObject(hdcBitmap, hbmpBitmap);
   goto itb_freedc;

   (* Are there any goto haters out there??? *)
itb_freebitmap:
   if (hbmpBitmap = 0) then DeleteObject(hbmpBitmap);

itb_freedc:
   if (hdcBitmap = 0) then DeleteDC(hdcBitmap);
end;


function CursorToIcon(hInst: HINSTANCE; hCursorIn: HCURSOR): HICON;
var
  lpCursor: PCursorIconInfo;
  wDummy: Word;
  lpAnd, lpXor: POinter;
begin
  CursorToIcon := 0;
  lpCursor := PCursorIconInfo(LockResource(HGLOBAL(hCursorIn)));
  if (lpCursor = nil) then exit;
  if (DumpIcon(lpCursor, wDummy, lpAnd, lpXor) <> 0) then
    CursorToIcon := CreateIcon(hInst, lpCursor^.wWidth,
      lpCursor^.wHeight, 1, 1, lpAnd, lpXor);
  UnlockResource(HGLOBAL(hCursorIn));
end;

end.
