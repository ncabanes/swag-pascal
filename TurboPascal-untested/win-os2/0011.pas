
{ PURPOSE  :  Demonstrate how to smoothly drag a bitmap across an application.

  AUTHOR   :  Michael Vincze (mav@asd470.dseg.ti.com)

  REFERENCE:  Microsoft vendor note 4-10.zip (ftp.uu.net
              /vendor/microsoft/developer-network)

  DATE     :  07/25/93
}

program DragBmp;

uses
  DragUnit,
  DragBmp_,
  WinTypes,
  WinProcs,
  OWindows,
  ODialogs;

{$R DragBmp }

const
  ApplicationName: PChar = 'Bitmap Drag';

type
  TDragBmpApplication = object (TApplication)
    procedure InitMainWindow; virtual;
    end;

  PDragBmpWindow = ^TDragBmpWindow;
  TDragBmpWindow = object (TWindow)
    bImageDrawn: boolean; { has the image been drawn?     }
    bSelected  : boolean; { has the image been selected?  }
    hbmImg     : HBITMAP; { handles to image and backdrop }
    hbmbk      : HBITMAP;

    constructor Init (AParent: PWindowsObject; ATitle: PChar);
    procedure   SetupWindow; virtual;
    destructor  Done; virtual;
    procedure   GetWindowClass (var AWndClass: TWndClass); virtual;

    procedure   WMLButtonDown    (var Msg: TMessage); virtual wm_First + wm_LButtonDown;
    procedure   WMMouseMove      (var Msg: TMessage); virtual wm_First + wm_MouseMove;
    procedure   WMLButtonUp      (var Msg: TMessage); virtual wm_First + wm_LButtonUp;
    procedure   WMPaint          (var Msg: TMessage); virtual wm_First + wm_Paint;

    procedure   CMDrawBmp        (var Msg: TMessage); virtual cm_First + cm_DrawBmp;
    procedure   CMAbout          (var Msg: TMessage); virtual cm_First + cm_About;
    end;

procedure TDragBmpApplication.InitMainWindow;
begin
MainWindow := New (PDragBmpWindow, Init (nil, ApplicationName));
end;

constructor TDragBmpWindow.Init (AParent: PWindowsObject; ATitle: PChar);
begin
inherited Init (AParent, ATitle);
Attr.Menu   := LoadMenu   (hInstance, 'Main');
hbmImg      := LoadBitmap (hInstance, 'Object');
hbmBk       := LoadBitmap (hInstance, 'BackGround');
bImageDrawn := False;
bSelected   := False;
end;

destructor TDragBmpWindow.Done;
begin
inherited Done;
if hbmImg <> 0 then
  begin
  if bImageDrawn = TRUE then
    DeleteImage
  else
    DeleteObject (hbmImg);
  end;
if hbmBk <> 0 then
  DeleteObject (hbmBk);
end;

procedure TDragBmpWindow.GetWindowClass (var AWndClass : TWndClass);
begin
inherited GetWindowClass (AWndClass);
AWndClass.HIcon := LoadIcon (HInstance, ApplicationName);
end;

procedure TDragBmpWindow.SetupWindow;
begin
inherited SetupWindow;
end;

procedure  TDragBmpWindow.WMLButtonDown (var Msg: TMessage);
begin
if bImageDrawn = TRUE then
  begin
  bSelected := IsSelected (LOWORD (Msg.lParam), HIWORD(Msg.lParam));
  if bSelected = TRUE then
    BeginDrag (HWindow, LOWORD (Msg.lParam), HIWORD (Msg.lParam));
  end;
end;

procedure  TDragBmpWindow.WMMouseMove (var Msg: TMessage);
begin
if bSelected = TRUE then
  Drag (HWindow, LOWORD (Msg.lParam), HIWORD (Msg.lParam));
end;

procedure  TDragBmpWindow.WMLButtonUp (var Msg: TMessage);
begin
if bSelected = TRUE then
  begin
  EndDrag (HWindow, LOWORD (Msg.lParam), HIWORD (Msg.lParam));
  bSelected := FALSE;
  end;
end;

procedure  TDragBmpWindow.WMPaint (var Msg: TMessage);
var
  ps: TPaintStruct;
begin
BeginPaint (hWindow, ps);

if hbmBk <> 0 then
  DrawBackdrop (ps.hdc, hbmBk);

if bImageDrawn = TRUE then
  DrawImage (ps.hdc);

EndPaint (hWindow, ps)
end;

procedure TDragBmpWindow.CMDrawBmp (var Msg: TMessage);
var
  Menu: HMenu;
  Rect : TRect;
begin
{ Initialize image info }
bImageDrawn := TRUE;
InitImageInfo (hWindow, hbmImg, 100, 100);

{ Once drawn, disable and gray this menuitem }
Menu := GetMenu (hWindow);
EnableMenuItem (Menu, cm_DrawBmp, MF_BYCOMMAND or MF_DISABLED or MF_GRAYED);
DrawMenuBar (hWindow);
end;

procedure TDragBmpWindow.CMAbout (var Msg: TMessage);
begin
Application^.ExecDialog (New (PDialog, Init (@Self, 'About')));
end;

var
  Application:TDragBmpApplication;

begin
Application.Init (ApplicationName);
Application.Run;
Application.Done;
end.

---------- CUT HERE ---------- DRAGUNIT.PAS ----------

{ ****************************************************************************
  File: DragUnit.pas

  Purpose: Contains bitmap dragging routines.

  Functions:
    InitImageInfo()
    DrawImage()
    DeleteImage()
    DrawBackdrop()
    IsSelected()
    BeginDrag()
    Drag()
    EndDrag()

  Development Team:
    Michael Vincze
    Patrick Schreiber

  Written by Vincze International.
  Adopted from Microsoft Product Support Services, Windows Developer Support

  COPYRIGHT:

    (C) Copyright Vincze International, 1993.
    (C) Copyright Microsoft Corp. 1993.  All rights reserved.

    You have a royalty-free right to use, modify, reproduce and
    distribute the Sample Files (and/or any modified version) in
    any way you find useful, provided that you agree that
    Vincze International and Microsoft have no warranty obligations
    or liability for any Sample Application Files which are modified.

  ****************************************************************************  }

unit DragUnit;

interface

uses
  WinTypes,
  WinProcs;

{ force C types }
type
  POINT  = TPoint;
  RECT   = TRect;
  BITMAP = TBitmap;
  BOOL   = boolean;

procedure InitImageInfo (hWnd_: HWND; hbm: HBITMAP; nX, nY: integer);
procedure DeleteImage;
function  IsSelected (nX, nY: integer): BOOL;
procedure BeginDrag (hWnd_: HWND; nX, nY: integer);
procedure Drag (hwnd_: HWND; nX, nY: integer);
procedure EndDrag (hwnd_: HWND; nX, nY: integer);
procedure DrawBackdrop (hdc_: HDC; hbm: HBITMAP);
procedure DrawImage (hdc_: HDC);

implementation

{ Image data structure }
type
  IMAGE= record
    bmX     : integer;  { Bitmap origin           }
    bmY     : integer;  { Bitmap origin           }
    bmWidth : integer;  { Bitmap width            }
    bmHeight: integer;  { Bitmap height           }
    hbmImage: HBITMAP;  { Image's bitmap          }
    hbmBkg  : HBITMAP;  { What's behind our image }
    end;

{ Global variables to this unit }
var
  domino  : IMAGE;    { Image's info                    }
  rcClient: RECT;     { Client area bounding rectangle  }
  xPrev   : integer;  { Previous mouse position         }
  yPrev   : integer;

{ ****************************************************************************
  Function: InitImageInfo()

  Purpose:  Initialize info for our object.

  Parameters:
    HDC  hdc_   - Handle to window dc
    int  nX     - X-coordinate of object origin
    int  nY     - Y-coordinate of object origin

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created
            7/23/93    MAV         Corrected rect_.right and rect_.bottom to
                                   reflect the actual update rectangle.
  ****************************************************************************  }

procedure InitImageInfo (hWnd_: HWND; hbm: HBITMAP; nX, nY: integer);
var
  hdc_,             { Handles to window and memory dcs  }
  hdcMem : HDC;
  hbmNew,           { Handles to bitmaps                }
  hbmPrev: HBITMAP;
  bm     : BITMAP;  { BITMAP data structure             }
  rect_  : RECT;    { Invalid rectangle                 }
begin
{ Get window and memory dcs }
hdc_   := GetDC (hWnd_);
hdcMem := CreateCompatibleDC (hdc_);

{ Get width and height of bitmap }
GetObject (hbm, sizeof (BITMAP), @bm);

{ Initialize image's info and store rect for updating }
rect_.left      := nX;
rect_.top       := nY;
rect_.right     := nX + bm.bmWidth;
rect_.bottom    := nY + bm.bmHeight;
domino.bmX      := nX;
domino.bmY      := nY;
domino.bmWidth  := bm.bmWidth;
domino.bmHeight := bm.bmHeight;
domino.hbmImage := hbm;

{ Create and select a new bitmap to store our background }
hbmNew  := CreateCompatibleBitmap (hdc_, bm.bmWidth, bm.bmHeight);
hbmPrev := SelectObject (hdcMem, hbmNew);

{ Get the background from the screen }
BitBlt (hdcMem, 0, 0, domino.bmWidth, domino.bmHeight,
        hdc_, domino.bmX, domino.bmY, SRCCOPY);

{ Tidy up }
SelectObject (hdcMem, hbmPrev);
DeleteDC (hdcMem);
ReleaseDC (hWnd_, hdc_);

{ Store the new background bitmap }
domino.hbmBkg := hbmNew;

{ Update client area where image is }
InvalidateRect (hWnd_, @rect_, FALSE);
UpdateWindow (hWnd_);
end;


{****************************************************************************
  Function: DeleteImage()

  Purpose:  Delete image and background bitmaps.

  Parameters:
    None.

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }
procedure DeleteImage;
begin
if domino.hbmImage <> 0 then DeleteObject (domino.hbmImage);
if domino.hbmBkg   <> 0 then DeleteObject (domino.hbmBkg);
end;


{ ****************************************************************************
  Function: DrawImage()

  Purpose:  Draws image at it's current position.

  Parameters:
    HDC hdc_    - Handle to window dc

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }
procedure DrawImage (hdc_: HDC);
var
  hdcMem : HDC;     { Handle to memory dc       }
  hbmPrev: HBITMAP; { Handle to previous bitmap }
begin
{ Create a memory dc and select our object's bitmap into it }
hdcMem  := CreateCompatibleDC (hdc_);
hbmPrev := SelectObject (hdcMem, domino.hbmImage);

{ BitBlt it to the screen }
BitBlt (hdc_, domino.bmX, domino.bmY, domino.bmWidth, domino.bmHeight,
        hdcMem, 0, 0, SRCCOPY);

{ Tidy up }
SelectObject (hdcMem, hbmPrev);
DeleteDC (hdcMem);
end;


{ ****************************************************************************
  Function: DrawBackdrop()

  Purpose:  Draws the backdrop bitmap so we know this bitmap dragging
            technique really works for any background.

  Parameters:
    HDC hdc_    - Handle to window dc
    HBITMAP hbm - Handle to backdrop bitmap

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }
procedure DrawBackdrop (hdc_: HDC; hbm: HBITMAP);
var
  hdcMem : HDC;     { Handle to memry dc        }
  hbmPrev: HBITMAP; { Handle to previous bitmap }
  bm     : BITMAP;  { BITMAP data structure     }
begin
{ Get dimensions of backdrop bitmap }
GetObject (hbm, sizeof (BITMAP), @bm);

{ Create a memory dc and select our backdrop's bitmap into it }
hdcMem  := CreateCompatibleDC (hdc_);
hbmPrev := SelectObject (hdcMem, hbm);

{ BitBlt it to the upper-left part of client area }
BitBlt (hdc_, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);

{ Tidy up }
SelectObject (hdcMem, hbmPrev);
DeleteDC (hdcMem);
end;


{ ****************************************************************************
  Function: IsSelected()

  Purpose:  Specifies whether our image has been selected for dragging.

  Parameters:
    WORD wX     - X-coordinate of mouse position
    WORD wY     - Y-coordinate of mouse position

  Returns:
    Returns TRUE if specified point is in object's bounding rectangle,
    FALSE otherwise.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }

function IsSelected (nX, nY: integer): BOOL;
var
  pt   : POINT; { POINT data structure  }
  rect_: RECT;  { RECT data structure   }
begin
{ Current mouse position }
pt.x := nX;
pt.y := nY;

{ Current bitmap position }
rect_.left   := domino.bmX;
rect_.top    := domino.bmY;
rect_.right  := domino.bmX + domino.bmWidth - 1;
rect_.bottom := domino.bmY + domino.bmHeight - 1;

{ Return TRUE if pt in rect of image }
IsSelected := PtInRect (rect_, pt);
end;


{ ****************************************************************************
  Function: BeginDrag()

  Purpose:  Starts the bitmap dragging process.

  Parameters:
    HWND hWnd_  - Handle to window
    int  nX     - X-coordinate of mouse position
    int  nY     - Y-coordinate of mouse position

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }
procedure BeginDrag (hWnd_: HWND; nX, nY: integer);
begin
{ Get all mouse messages }
SetCapture (hWnd_);

{ Save previous mouse position }
xPrev := nX;
yPrev := nY;

{ Get client area rect }
GetClientRect (hWnd_, rcClient);
end;


{ ****************************************************************************
  Function: Drag()

  Purpose:  Perform the bitmap dragging.

  Parameters:
    HWND hWnd_  - Handle to window
    int  nX     - X-coordinate of mouse position
    int  nY     - Y-coordinate of mouse position

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created

  **************************************************************************** }
procedure Drag (hwnd_: HWND; nX, nY: integer);
var
  hdc_,               { Handles to dcs            }
  hdcMem   : HDC;
  hdcNewBkg,          { Handles to dcs            }
  hdcOldBkg: HDC;
  hbmNew,             { Handles to bitmaps        }
  hbmNPrev : HBITMAP;
  hbmOPrev,           { Handles to bitmaps        }
  hbmPrev,
  hbmTemp  : HBITMAP;
  dx,                 { Mouse delta x and delta y }
  dy       : integer;
begin
{ Get window and memory dcs for our BitBlt'ing }
hdc_      := GetDC (hWnd_);
hdcMem    := CreateCompatibleDC (hdc_);
hdcNewBkg := CreateCompatibleDC (hdc_);
hdcOldBkg := CreateCompatibleDC (hdc_);

{ Create a temp bitmap for our new background }
hbmNew    := CreateCompatibleBitmap (hdc_, domino.bmWidth, domino.bmHeight);

{ Select our bitmaps }
hbmPrev  := SelectObject (hdcMem, domino.hbmImage);
hbmNPrev := SelectObject (hdcNewBkg, hbmNew);
hbmOPrev := SelectObject (hdcOldBkg, domino.hbmBkg);

{ Calculate delta x and delta y }
dx:= xPrev - nX;
dy:= yPrev - nY;

{ Save previous mouse position }
xPrev:= nX;
yPrev:= nY;

{ Update image's position }
dec (domino.bmX, dx);
dec (domino.bmY, dy);

{ Copy screen to new background }
BitBlt (hdcNewBkg, 0, 0, domino.bmWidth, domino.bmHeight,
        hdc_, domino.bmX, domino.bmY, SRCCOPY);

{ Replace part of new bkg with old background }
BitBlt (hdcNewBkg, dx, dy, domino.bmWidth, domino.bmHeight,
        hdcOldBkg, 0, 0, SRCCOPY);

{ Copy image to old background }
BitBlt (hdcOldBkg, -dx, -dy, domino.bmWidth, domino.bmHeight,
        hdcMem, 0, 0, SRCCOPY);

{ Copy image to screen }
BitBlt (hdc_, domino.bmX, domino.bmY, domino.bmWidth, domino.bmHeight,
        hdcMem, 0, 0, SRCCOPY);

{ Copy old background to screen }
BitBlt(hdc_, domino.bmX+dx, domino.bmY+dy, domino.bmWidth, domino.bmHeight,
       hdcOldBkg, 0, 0, SRCCOPY);

{ Tidy up }
SelectObject (hdcMem, hbmPrev);
SelectObject (hdcNewBkg, hbmNPrev);
SelectObject (hdcOldBkg, hbmOPrev);

{ Swap old with new background }
hbmTemp       := domino.hbmBkg;
domino.hbmBkg := hbmNew;
hbmNew        := hbmTemp;
DeleteObject (hbmNew);

{ Tidy up some more }
DeleteDC (hdcMem);
DeleteDC (hdcNewBkg);
DeleteDC (hdcOldBkg);
ReleaseDC (hWnd_, hdc_);
end;


{ ****************************************************************************
  Function: EndDrag()

  Purpose:  Ends the bitmap dragging process.

  Parameters:
    HWND hWnd_  - Handle to window
    int  nX     - X-coordinate of mouse position
    int  nY     - Y-coordinate of mouse position

  Returns:
    No return value.

  Comments:

  History:  Date       Author      Reason
            3/9/92     PES         Created
            3/12/92    PES         Added code to restrict domino to visible
                                   area of screen.

  **************************************************************************** }
procedure EndDrag (hwnd_: HWND; nX, nY: integer);
var
  hdc_,               { Handles to dcs                  }
  hdcMem: HDC;
  hdcNewBkg,          { Handles to dcs                  }
  hdcOldBkg: HDC;
  hbmNew,             { Handles to bitmaps              }
  hbmNPrev : HBITMAP;
  hbmOPrev,           { Handles to dcs                  }
  hbmPrev,
  hbmTemp  : HBITMAP;
  dx,                 { Delta x and delta y of mouse    }
  dy       : integer;
  x,                  { X and y for position correction }
  y        : integer;
begin
{ Calculate delta x and delta y }
dx:= xPrev - nX;
dy:= yPrev - nY;

{ Check if we've moved since last time  }
if (dx <> 0) or (dy <> 0) then
  begin
  { Get window and memory dcs }
  hdc_      := GetDC (hWnd_);
  hdcMem    := CreateCompatibleDC (hdc_);
  hdcNewBkg := CreateCompatibleDC (hdc_);
  hdcOldBkg := CreateCompatibleDC (hdc_);

  { Create a temp bitmap for our new background }
  hbmNew    := CreateCompatibleBitmap (hdc_, domino.bmWidth, domino.bmHeight);

  { Select our bitmaps }
  hbmPrev   := SelectObject (hdcMem, domino.hbmImage);
  hbmNPrev  := SelectObject (hdcNewBkg, hbmNew);
  hbmOPrev  := SelectObject (hdcOldBkg, domino.hbmBkg);

  { Update bitmap's position }
  dec (domino.bmX, dx);
  dec (domino.bmY, dy);

  { Copy screen to new background }
  BitBlt (hdcNewBkg, 0, 0, domino.bmWidth, domino.bmHeight,
          hdc_, domino.bmX, domino.bmY, SRCCOPY);

  { Replace part of new bkg with old background }
  BitBlt (hdcNewBkg, dx, dy, domino.bmWidth, domino.bmHeight,
          hdcOldBkg, 0, 0, SRCCOPY);

  { Copy image to old background }
  BitBlt (hdcOldBkg, -dx, -dy, domino.bmWidth, domino.bmHeight,
          hdcMem, 0, 0, SRCCOPY);

  { Copy image to screen }
  BitBlt (hdc_, domino.bmX, domino.bmY, domino.bmWidth, domino.bmHeight,
          hdcMem, 0, 0, SRCCOPY);

  { Copy old background to screen }
  BitBlt (hdc_, domino.bmX + dx, domino.bmY + dy,
          domino.bmWidth, domino.bmHeight,
          hdcOldBkg, 0, 0, SRCCOPY);

  { Clean up }
  SelectObject (hdcMem, hbmPrev);
  SelectObject (hdcNewBkg, hbmNPrev);
  SelectObject (hdcOldBkg, hbmOPrev);

  { Swap old with new background }
  hbmTemp       := domino.hbmBkg;
  domino.hbmBkg := hbmNew;
  hbmNew        := hbmTemp;
  DeleteObject (hbmNew);

  { Tidy up }
  DeleteDC (hdcMem);
  DeleteDC (hdcNewBkg);
  DeleteDC (hdcOldBkg);
  ReleaseDC (hWnd_, hdc_);
  end;

{ Reset previous mouse position }
xPrev:= 0;
yPrev:= 0;

{ Release mouse capture }
ReleaseCapture;

{ Make sure our domino stays completely visible }
if domino.bmX < 0 then
  x:= 0
else if domino.bmX + domino.bmWidth > rcClient.right then
  x:= rcClient.right - domino.bmWidth
else
  x:= domino.bmX;

if domino.bmY < 0 then
  y:= 0
else if domino.bmY + domino.bmHeight > rcClient.bottom then
  y:= rcClient.bottom - domino.bmHeight
else
  y:= domino.bmY;

if (x <> domino.bmX) or (y <> domino.bmY) then
  begin
  xPrev:= domino.bmX;
  yPrev:= domino.bmY;
  Drag (hWnd_, x, y);
  xPrev := 0;
  yPrev := 0;
  end;
end;

end.

---------- CUT HERE ---------- DRAGBMP_.PAS ---------- 

unit DragBmp_;

interface

{ menu IDs }
const
  cm_DrawBmp = 101;
  cm_About   = 102;

implementation
end.

---------- CUT HERE ---------- DRAGBMP.RC ---------- 

BACKGROUND BITMAP 
BEGIN
        '42 4D BE 25 00 00 00 00 00 00 3E 00 00 00 28 00'
        '00 00 40 01 00 00 F0 00 00 00 01 00 01 00 00 00'
        '00 00 80 25 00 00 00 00 00 00 00 00 00 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 FF FF FF 00 48 55'
        '48 95 56 BE B6 EB 6D AB 62 20 44 91 5B AE B7 6F'
        'D7 FB 7B B6 B6 EF 5D 55 57 5A AB 6A 89 5A 4A 49'
        '49 56 B6 D2 24 B5 92 84 92 6A AD E9 ED B6 9A 54'
        '08 DA 91 24 F5 75 AD 5B 7D 56 D6 ED FF FE FB DA'
        'DA B5 AD 4A 72 24 94 AA 92 A9 4A AC C9 4A 24 29'
        '24 85 59 4F BB 65 75 D5 55 05 26 49 56 DB 76 F6'
        'D7 FD BD BB 6D DD EE B5 B5 56 52 B4 85 49 4A 91'
        '55 56 B5 52 12 B5 D1 4A 49 2A A7 7B 6E DD AA 5A'
        'A2 54 48 92 B9 AE DB AD FE D7 77 6E FF BB DD EB'
        '55 B5 AD 49 28 52 15 AA AA A9 56 AD 45 6B 02 10'
        '92 49 5A D6 DB B7 55 A2 8C 95 52 24 67 75 AD 77'
        'B5 BD ED DB DD F7 7B 56 AB 6A 5A B2 52 88 A8 25'
        '55 55 55 52 AB 4A A4 A5 24 B4 A5 2D B6 6D 76 5D'
        '51 22 84 88 DA DB 7B DD 6F 6B 5A AF 7B BF D6 DA'
        'D6 8D B5 4C 85 23 2A DA AA AA AA AD 44 B5 09 09'
        '49 01 5A DB 6D DB 4D E6 AD 4A 29 23 35 AE D6 97'
        'FD DE EF FA F6 ED 7D 95 2D 72 AA B1 28 4C 45 25'
        '55 55 56 A9 53 4D 52 52 24 56 A5 55 DB 76 F5 19'
        '52 55 4A 48 6B 7B B5 FA AB 75 BD 6F DF FF EB 76'
        'DA 8D 55 4A 53 11 12 D5 52 8A B5 56 A6 BA 88 94'
        '89 91 5A AB 36 DD AA F6 AE 82 90 92 9A D6 6F 2F'
        'FE EF 6B DD 7D AD DE AA B5 7A AA B4 84 24 6A 2A'
        'AD 7D 4A AA C9 52 21 21 B2 25 26 AA ED AB 5B 45'
        '51 55 25 24 2B B5 DA FB 6B D5 DE BB F7 FF B5 55'
        '49 95 6D 49 29 69 89 55 52 81 B5 2D B6 AD 4A 4A'
        '04 94 98 AB 5B 7E F6 BA AE A5 49 49 55 5F 77 56'
        'DE BF 75 D7 6F 7D 6E D5 B6 6A D2 AA 4A 02 52 AA'
        'AD 5E 4A DB 49 73 10 94 A9 22 63 AA B6 D5 AA CD'
        '52 AA 92 12 2E EA DA F5 75 EA AF 7E FD EB D9 2E'
        '49 AA AD 54 90 AD 25 55 52 A1 B5 35 B7 AE 45 21'
        '24 48 94 55 6D BE ED 32 AD 55 B4 A5 5B BB B7 AF'
        'EF 5D F5 D5 D7 DF 76 D1 B7 55 53 52 25 20 8A 4A'
        'AD 5E A2 EB 49 55 28 4A 49 93 2A A2 CB 6B 9A ED'
        '6A AA 42 88 35 6E ED 6A D5 F7 5F 7F FF 7E D9 2E'
        'AA B5 AD 44 48 4A 28 B5 52 A1 5D 56 B7 6A 82 92'
        '92 24 55 2D 3E DE F5 95 9B 55 B4 22 AA DB 9B 5D'
        'BF 6D F5 EB 5E F5 AA D3 55 4B 5A A8 95 92 D2 8A'
        'AA 8A A3 AD 6A AD 24 24 48 8A A9 52 D5 75 AB 6A'
        '74 AA 49 54 57 B6 76 F7 75 DB 5F 5F FB DF 75 2E'
        'AA B6 A5 51 20 24 05 55 25 55 5D 55 4D 55 49 49'
        '13 34 92 49 2A AF 5A 55 8B 5D B4 81 2C D5 DD AD'
        'EE B5 F5 F6 B7 76 D2 DA AA D5 5A 82 4A 92 AA 55'
        '52 AA AB AA BB AD 92 5A 64 41 24 94 D5 F6 F5 DB'
        '75 6A CA 34 5B 6F 6B 7B 5B EF 6F 5F FD DD A5 53'
        '55 2A A7 24 94 49 6A AA AD 55 77 6D 64 5A A4 80'
        '89 2A 89 21 2E AD 96 AA 96 95 3A 82 B5 BA DD D6'
        'F6 BA DA F5 6F 77 4D AD 56 D5 5C 49 21 92 95 55'
        '52 AA DE DA DF B5 09 2B 52 94 52 4A 51 5B 69 55'
        '69 6A C5 68 2A 56 B7 35 5D DB B7 AF DD DD 55 56'
        'A9 5A AB 12 4A 25 55 55 55 54 B5 95 A5 6B 52 48'
        '24 41 14 98 AD 6E B6 AA 96 AD BA 95 4B B5 DA EE'
        'F3 76 ED 7B BB 77 AB 59 56 A5 B4 A4 94 95 55 55'
        '52 AB EF 7A BA AC 94 92 89 16 A9 23 43 5B CA DB'
        '6A A9 4B 70 2C 66 B7 5B AE AD 5B D7 76 CE AA B7'
        '6D 5B 4D 09 21 55 55 55 55 55 7A D6 D6 EB 21 24'
        '52 68 22 48 3C D6 35 24 AD 56 B4 EA 93 DD 6A F6'
        'FB FB F7 7E ED BD 56 D4 C9 6A B2 52 4A 2A AA AA'
        'AA AA EF AB AB 55 4A 49 94 82 CC 95 43 2D EA DB'
        '52 F9 AB F0 2C A5 BF 4D B6 AD 5E D7 DB 6D AD 2B'
        '36 D5 48 88 92 AA AA D5 55 55 DA AE 5A D6 A4 92'
        '22 55 11 21 1C D7 55 B6 DD 87 6D E5 5B 5D 6D FB'
        '6B F7 F5 FE BD DB 5A DE CA AA B2 21 25 55 55 2A'
        'A9 56 FF 59 E6 BB 11 24 89 24 4A 4A 61 2A AB 24'
        'A3 79 4B D8 55 6A DB 2E DF 5D 6F DD F7 6E D5 31'
        '35 55 84 96 52 AA AA D5 52 A9 B5 57 5D 65 44 49'
        '34 89 B2 99 0B 5D B6 DB 5E 96 B7 B2 AA D5 B6 E9'
        'AA F7 DF B7 DD B5 AA EE D6 AA 51 20 C5 55 55 2A'
        'AD 57 FE DA 6A DF A9 92 42 52 04 22 54 5B 6A B6'
        'A9 69 EF 68 B5 16 6D BF 7F AE FA FE BA DE AD 52'
        'A9 52 84 95 2A AA AA D5 52 AB 7B 35 D5 A8 02 24'
        '94 94 A9 48 A2 AA 95 A9 56 B7 1E F5 4A ED DB 65'
        'D5 7D BF D5 F7 75 6A AD 56 AE 29 25 55 55 55 55'
        '55 6E F6 EE AA 57 54 89 31 21 22 9B 15 95 6E 57'
        'BA CA FB E8 B5 2A AE DD 7F DB F7 7F AD D6 D5 55'
        'AA A0 42 48 4A AA AA AA AA 9B ED 59 57 DA 85 22'
        '46 4A 4A 20 64 25 A9 DA 55 BD B7 DA 6A D5 59 B7'
        'DA FF 6D EB 7B 6D AA EA 54 94 94 93 5A 95 55 55'
        '55 57 BD D7 DA 35 28 4D 10 91 54 CA 89 9A 56 B5'
        'AB 53 7F 74 95 AA B7 6D 77 BA FF 5E EE DA AD 15'
        'AA A9 25 24 A5 55 55 AD 52 BE F6 9A 35 EB 52 90'
        '6A 25 12 12 22 25 AD 56 B6 AE DE FD 65 2A AD DB'
        'DE F7 DB FB DB B6 B2 EA B5 22 48 49 5A AA AA 52'
        'AA 6D ED 75 D6 96 84 4A 82 C9 64 A4 D5 5A A9 AA'
        'D5 59 7B EA 9A D5 55 36 BB ED BE B6 B6 6D 6D 2B'
        '49 48 92 92 A5 55 55 AD 55 DB BF D6 B5 6D 51 12'
        '54 12 09 92 04 8B 57 6D 5A B7 DF DE A5 2A AB EB'
        'EF BF FB ED EB D2 D2 D4 B2 11 24 A5 5A AA AA 52'
        'AA 37 FD 35 6A B3 0A 64 92 A5 52 24 A9 24 AA 9A'
        'A5 D5 7F BD 5A D5 56 5F BD 7B 77 5B 5E AE AD AB'
        '44 A2 49 0A A5 55 55 AE AB EF 6A DA D6 CE A0 89'
        '24 94 A4 89 24 AB 5D 75 DF 2D DB 77 45 2B 2D D7'
        '77 EE EE F5 F5 59 55 54 91 04 92 55 5A AA AA B1'
        '54 3E FF B5 99 B9 09 22 49 21 09 32 49 05 62 AA'
        'A8 DB 7F DE DA D4 EA BE EE DB FD AF AA D6 DA AB'
        '46 49 25 2A AA AA AD 4E AB FB DD 6B 77 57 92 4C'
        '92 4A 52 44 A4 6A 9D AB 57 2D DB FF A5 2B 15 6D'
        'FB FF D7 7B 6D AB 55 54 98 92 48 A5 55 55 52 B1'
        '55 6F BB 96 A9 AA 24 91 24 94 94 91 12 83 65 6D'
        '5A F6 BF B5 54 D4 AA DB DF BA BD EE DB 54 B5 55'
        '22 24 92 5A AA AA AD 4E AA DE FE 6D 57 75 49 4A'
        '49 21 21 26 49 5C 9A 9A B5 4B FB 7F D5 29 55 77'
        'B6 F7 F7 55 B6 AB 55 54 94 89 34 A5 55 55 69 B2'
        'AA BD EB AA DA CD 92 24 92 4A 4A 48 A4 13 6B 75'
        '6A BD 77 FF AA A2 2A DD 7F EE EE FF 69 56 AA A9'
        '21 12 41 49 5A AA 96 4D 6B FB BE D5 B5 BB 24 91'
        '24 92 92 92 49 6D 4A AA D5 D7 DF EB 54 4A D5 B7'
        'EE BD DD AA D6 AC D5 52 4A 24 95 56 A5 55 69 B5'
        '56 F7 FD AD 2B 52 89 26 49 24 24 45 12 82 B5 55'
        'AB 34 BD DF EA 95 29 6F 7D F7 B5 7B A9 B3 5A A4'
        '90 49 22 A9 5A AA 96 AA AD DF 6B 52 ED EE 12 48'
        '92 49 51 2A 49 2D 4D 6B 56 EF F7 FF 95 35 56 BD'
        'EF BE EF D6 B7 4E A5 49 24 92 4D 56 A5 55 6D 55'
        '53 BE FE AD 55 19 24 92 24 92 4A 88 92 52 B5 96'
        'AD 5A BD AF 68 44 A9 5B DE F5 B9 6D AA B4 DA 92'
        '49 24 92 A9 5A AA A9 6A EF 75 ED 69 AA F7 49 24'
        'C9 24 92 52 34 85 4A 6D 5A B5 F7 FE AE B3 56 BF'
        '7D EF 6F BB 55 6B 29 24 92 49 25 46 AA B5 56 95'
        '16 FF DD 96 B5 94 94 49 12 49 24 94 C1 2A B5 DA'
        'B5 E7 6F BF D1 4C A9 76 FB BD DA ED 5A 94 D2 49'
        '48 92 4A A9 55 4B 69 6A ED D6 FB 75 4B 6B 22 92'
        '44 92 49 21 15 45 56 2B 6B 5D FE F6 AE 91 56 CF'
        'EF FB 77 B6 B5 6B 24 92 22 26 95 56 AA B4 96 D5'
        '5B 7F DE AA B6 9E 54 24 99 24 92 4A A4 9A A9 D4'
        'D6 B7 6D FF D5 57 54 BE DF 56 AD 6D 6A D4 D9 24'
        '89 48 2A AA AA AB 6A A5 D7 FD B5 55 55 71 02 C9'
        '22 49 A4 92 49 29 56 5B AC ED DF B7 AA A8 2B 5D'
        'FA FD FB D9 AD AB 22 49 22 25 54 A5 55 55 55 5E'
        '1E EB FD AA AA AE 54 12 48 92 12 24 92 42 A9 B5'
        '5B 9B 7B 7F 55 55 D4 AB DF EB AE B7 52 56 49 2A'
        '4C 92 AB 5A AA AA AA A1 F5 DF EB 77 55 55 89 44'
        '9B 24 A4 C9 24 95 56 A6 B5 76 B7 F6 BA AA 13 5F'
        'BB 5F 75 EA AD A8 92 40 91 24 54 A5 55 55 55 5E'
        '5F FF 5E A8 AD 6A 22 5A 20 49 89 12 49 24 AA D9'
        '4A DD FE EF E6 D5 6C AB 7F F6 DF 55 5A 55 24 95'
        '24 49 4B 5A AA AA A5 A1 AB BA F2 D7 55 AA 48 81'
        '4A 92 34 A4 92 49 55 2E F5 B7 6F DF D9 AA 93 3F'
        'F5 5D B6 EB 55 D4 49 24 49 55 54 A5 55 55 5A 5E'
        '7F 77 DF 29 5A 55 11 2A 52 24 82 49 24 92 AA D1'
        '97 6D DD FE B7 55 24 C7 6F FB 6C 96 AA 29 A2 49'
        '92 84 95 4A AA AA A5 A1 D6 EF 7A F6 A5 AA A6 44'
        '84 A9 28 92 49 25 55 2F 6C DB 7B AF EA AA AB 3E'
        'FF D6 DB ED 55 C4 14 94 24 29 55 55 55 2B 5B 5F'
        '7F FD F5 95 5A B5 08 99 2A 42 4B 24 92 49 2A D9'
        '57 B6 DF 7E DD 55 54 4B DA BD B6 AA B2 29 41 22'
        '89 4A AA AA AA D4 AA A2 D5 DB EF 6A B5 4A 52 22'
        '49 16 90 49 24 92 55 36 DC ED BB FD B2 B5 52 B7'
        'FF AB 6D 5B 44 8A 2B 48 B2 55 55 55 55 2B 55 5D'
        'BF BF BA AA A5 B5 85 54 92 50 2A 92 49 24 8A D5'
        'AB 96 F6 D7 EE A6 94 8B B5 76 B5 A4 A9 50 C8 12'
        '84 AA AA AA AA D6 AA A5 7B 77 76 D6 DB 4A 28 49'
        '24 A5 52 48 92 49 29 2A 55 7B AF FF B9 59 62 27'
        '7F DD DD 5B 51 05 12 A4 A9 53 55 55 55 2C B5 5B'
        'F7 FE DD AD 2A B5 42 92 49 09 24 93 24 92 52 EB'
        'AD AD 7D BF 76 B6 9D 4A ED 77 76 B5 56 48 45 29'
        '22 AC AA A5 5A D3 4A B6 EE D7 FB 5A D5 4A 2D 24'
        '92 52 49 24 69 45 25 2C B7 6B D7 F7 E9 D5 62 BB'
        'DF ED A9 AA A0 92 98 4A 55 53 55 5A A5 2C B5 AB'
        'DB FE B6 D5 5A B5 40 49 24 94 A2 49 02 2A 5A DB'
        '6C DD 7F 6E DF 2A 9D 45 FD 5B 77 55 55 24 A2 94'
        'AA 96 B6 A5 5A D3 56 AF 7F B7 FD 35 65 4B 95 92'
        '49 21 0C 92 AC C0 42 A5 AB B7 DD FF FA DD 61 2B'
        'BB F6 4C AA A4 49 14 A5 55 6D 49 55 55 2D 69 5A'
        'F6 FE FB EA 9A B6 24 24 92 4A 51 24 21 15 95 5D'
        '5E ED 7B BF B7 32 8A 4B 77 EB FB 5A A9 22 49 1A'
        '25 AA B6 AA AA DA 96 B7 EF B7 D6 95 65 69 49 49'
        '22 42 19 25 59 80 85 4B 57 6F BB FF F5 BA C2 57'
        '77 EC 99 55 48 92 29 4A AA DA 92 AA AA 5A D2 B5'
        'ED FD F7 D5 35 6C 92 92 4C 94 A2 48 42 2B 2A BA'
        'BD DA F7 7F 6E 65 14 96 EF D7 F6 B5 52 44 92 34'
        '4B 55 6D 55 55 B5 2D 6F DF 6F AD 2A CA D3 24 49'
        '21 25 88 92 94 88 45 56 D3 37 AF ED D9 DA 65 2D'
        'BE BD 4A AA A5 29 44 AA B4 AA A9 55 6A AA D5 BD'
        'BB FB 7A D5 B5 AE 49 12 4A 48 33 44 A1 32 AA A9'
        '5E ED 7E DF F6 AA 88 57 7D D2 B5 55 48 42 29 48'
        '4B 55 56 AA 95 55 55 5B F6 DF F7 AB 4B 51 92 A4'
        '94 92 84 15 16 45 0A B7 B5 BB DD FF 6B 55 25 4D'
        'DB FF D6 EA 92 98 8A 35 B6 AA A9 55 6A AA AB 77'
        'BF F6 ED 56 B6 AE 24 49 21 24 52 A8 48 88 4A AA'
        '6B 57 7B BE DD B5 52 97 36 AA 29 15 24 A2 11 6A'
        '55 55 56 AA AA AA D6 DF 6D BF DA A9 55 55 49 12'
        '4A 49 88 92 A2 32 95 6D D6 BE D7 7D F6 CA 88 2A'
        'DF FD D6 EA 51 09 2E D5 AA AA A9 55 55 55 2D BE'
        'FB EE F3 56 AA A9 92 54 90 92 33 24 94 C4 A5 4A'
        'AD ED BF F7 AD BE B3 4B BB F7 4D 14 A6 54 52 AA'
        '55 55 56 AA AA AA D5 75 DF 7D DE AD 6A B6 24 C2'
        '23 24 84 49 25 11 0A BB 5B 5B 76 EF FB 51 44 55'
        '6E AC BA F5 08 91 0D 55 AA AA A9 55 55 55 AB EF'
        'B7 DF B5 6A DB 49 49 19 6C 49 29 12 48 56 6A D5'
        '76 D7 ED BE AD EE A9 0A BF FB 55 0A 52 24 AA AB'
        '55 55 56 AA AA AD 5D 5E FE FA F6 D5 24 B7 92 42'
        '01 12 52 64 92 80 85 AA CD BE 5F FF FB 55 52 AB'
        '5B F5 AA F4 A4 D1 35 56 AA AA A9 45 53 5A AB FB'
        'ED B7 ED AA DB 6A 34 94 D2 66 A4 89 24 B5 2A AD'
        'BB 6D FB 6D D6 DD A8 24 B7 6E 55 09 09 0A 4A B5'
        '55 55 57 5A AC 55 55 B7 BF FF DA 55 55 55 41 29'
        '14 88 49 52 49 04 4B 5B 56 DB 56 FF BD B2 43 4B'
        '6E F9 AA F4 52 A0 B5 6A AA AA A8 A5 53 A9 6F 6F'
        '7B 6E B5 D6 AA AB 2B 52 45 22 92 24 92 49 54 B5'
        '6D B5 FD DB 6B 6D B4 2A AB EE B5 09 94 2A 5B 55'
        '55 55 57 4A AC 56 DA FD F7 FD E6 99 55 54 44 24'
        'A8 4D 24 8A 44 B2 8B 6A BB 5F 57 BF FE DB 4A D5'
        '57 F9 4A F2 21 44 B6 AB 6A AA A9 55 53 AA 97 DF'
        'EF 6F BD 66 AA B7 99 49 12 D0 49 50 99 04 2A AB'
        '56 EA FE FE A9 76 A9 2A AD D6 B5 04 96 91 49 5A'
        '95 55 56 AA A4 55 7D BB 5E FD EA 9A D5 68 A2 92'
        '42 05 92 25 22 49 55 56 F5 BF AD F5 FF AD 5A 95'
        '53 79 55 69 48 24 BF 65 6A AA A9 25 4B 2A AB F7'
        'FB D7 9A B5 2D 4F 4C 24 AC AC 24 8A 48 B2 4B 6D'
        '2F 55 7B DF AA F9 A5 6A 6E F6 D5 8A 22 89 4A DA'
        'AA AA 96 C8 98 55 6E BE DF 7F 75 6A D2 B1 91 49'
        '11 21 49 50 92 84 96 AA EA FF AE BA FE B7 5A 95'
        '93 E9 2A 30 94 B2 B6 AB 55 55 69 13 65 AA DB ED'
        'F5 FD DA D5 5D 6E 2A 22 42 4A 92 26 A5 29 29 5B'
        '5D AA FB F7 AB ED B5 6A 6D 36 D1 45 49 05 4D D6'
        'AA AA 95 74 94 15 6F FF DF D7 B5 AA A2 D2 A8 CC'
        'AC 94 24 88 08 42 56 AA B7 7F AE BD 7E DB 6A AA'
        'D6 E9 2A 91 22 52 BB 6D 55 54 AA 81 21 4A BF 5B'
        'B7 BF 6B 56 DD AD 55 11 09 21 49 25 52 95 4A BB'
        '6D DB 7D FB AD B6 DB 55 9D 55 55 26 4C 95 56 BA'
        'BA AB 54 AA 4A 5A EA FF 7E FA DC A9 25 55 2A 4A'
        '52 4A 24 48 94 A2 5D 65 5B 76 AB 76 FB 5D B4 AA'
        '6A 94 AA A8 91 22 AC D5 65 54 A9 48 92 A5 BF FB'
        'ED EF A3 56 DB 5B 54 A4 A4 98 C9 B3 21 14 AA DA'
        'F6 ED FD ED 96 FB 6B 55 DA 23 2A 45 24 55 53 B6'
        'DA A9 56 93 24 4D 77 D7 5F DF BE B5 55 64 AA 91'
        '09 23 12 04 5A 49 52 AB 4D 97 57 7B 7D B6 DE AA'
        '54 89 55 12 49 85 5D 6D AB 55 29 48 51 5A EE BE'
        'FD BA 65 4A AA 9B 49 4A 52 48 44 AA 80 A2 5D 56'
        'BB 7D FD F6 D7 6D B5 55 95 22 14 A8 92 2A E7 5B'
        '6C AA 55 25 26 85 DD FB AB F7 DA B5 55 76 92 24'
        '92 92 99 49 2B 49 A2 DA D6 D7 56 ED BD D7 6D AA'
        '74 45 CA 93 25 57 1A EE AB 55 42 4A 48 3A BF D7'
        'FF BE B5 55 69 A5 24 91 24 25 23 32 48 12 5D AB'
        '5D BD FB D9 6A BE DB 55 89 08 15 44 48 28 EF 59'
        '5A A8 AC 94 D2 CB FB BE AF 75 EA AA 97 5A 49 24'
        '49 4C 94 84 92 E5 A5 5A B7 57 FF FF DF FF FE FF'
        'FE 52 FE BD 12 D7 FF D7 B5 55 D1 21 E5 35 77 FF'
        'FA EF 55 55 6D 53 12 49 B2 51 29 29 64 FA 5A B7'
        'EC FD 7F FF EF FF FD FF FF 87 FF 9A 65 5F FF FA'
        '6A AB E4 4A F2 CB FF FF DF BA EA AA A9 6E 64 92'
        '4C 84 A2 52 09 E1 66 C9 FB 97 EE B5 4E A6 CA C4'
        '55 5F EA FC 0A BF ED 7D D5 55 A1 92 E1 36 EF 6B'
        'F6 EF AA AA D6 D2 09 26 91 2A 89 04 D4 EA 99 37'
        'D6 FD 5B D6 A5 DD B6 19 AA 3F 41 5A 95 7F 5A D7'
        '6A 8B 82 25 D8 CB F5 D5 6D BA 55 55 2A AD 52 48'
        '22 49 36 69 2B F9 66 CF A9 AB F6 FB 42 B7 6C 22'
        '28 F8 14 98 95 7A B7 5A 95 33 D0 89 E0 35 FA BE'
        'DF FF EA AA D5 55 88 92 AC 92 40 92 C5 C4 59 BB'
        'B9 7F 6D D6 01 DA D0 08 90 FA A0 23 25 F5 60 35'
        '6A 47 A1 53 98 CB 6F 01 F9 6A B6 AD 5A AA 32 A5'
        '21 24 95 44 19 BA 27 57 54 D6 DB 2C 03 37 A0 3B'
        '48 E0 00 18 52 F6 C0 2A D4 AF 08 87 E4 35 FC 00'
        'D8 FF E9 52 A6 B5 44 8C 4A 4D 24 29 A3 C4 58 AF'
        '78 BD 6F F8 16 FD 40 4C 11 CA 80 BE A1 ED 00 D7'
        '45 57 50 2B 98 57 F6 0F BC ED 56 AD 59 6B 91 32'
        'A4 90 89 4A 17 94 27 57 A4 55 BB A4 2D B3 40 9E'
        'D1 D0 01 59 59 DA 85 BC C4 86 94 4B 74 2B 6C 3B'
        'FA 5B E9 5A B6 D6 26 84 92 25 32 A0 A7 6A 18 DE'
        'DC 3A EF FC 3B 7E C5 2D 21 C2 0A 1E E5 B5 0B 7B'
        '92 2F 20 97 4A 56 F8 37 D6 7E B6 D5 65 6A 48 29'
        '21 4A 44 15 2F 95 27 BF 36 6F B7 68 6A F5 40 4E'
        'D3 A4 00 BD 1B CB 06 9D 60 DE 48 2F B4 2F EC 6F'
        'FE 2B EA AA DA 96 95 62 4A 59 11 45 57 AA 1A 2E'
        'EC 1A DF 54 4F BE 82 9D 23 88 12 3A E3 B6 14 FE'
        '81 0C 92 27 5B 15 D8 7B AA 3E D5 55 26 F5 21 0C'
        '91 02 66 AA 27 55 95 DF 5B 37 77 F4 7A 75 84 AE'
        'D3 50 04 5D 43 EC 17 AD 50 5D 24 4F 66 2F BC 5E'
        'DE 1D AA AA DA 8D 4A 51 22 68 88 48 9F 2A 0A 5E'
        'B6 3D DF EC 2D F2 45 1D 23 42 28 BA A3 4A 2A 6E'
        'A0 9C 4A 1E 9D 1B F6 FF F6 37 F5 55 55 7A 99 24'
        '94 8B 25 93 4E D5 85 BD 6D 0F 77 B4 57 72 80 AE'
        'D3 94 01 3A C3 BC 2D DD 28 3A 99 0D 6D 0F 5F FA'
        'AC 3D 4A AA AB A5 22 49 21 20 52 24 5D 2F 4B 5D'
        '5F 1E DF EC 7D 7D 05 5D 23 40 2A 5D A3 A2 16 AD'
        '40 7C AC 1E D6 96 FD F7 FC 37 F5 6A AC 5B D4 92'
        '4A 4D 09 52 9E 52 8D 7B B5 9D F7 58 2A F2 42 AE'
        'D3 94 00 BB 43 DE 1B 5C 90 B9 09 1D 25 8D F7 DD'
        '58 6D 4A 95 7B EA 09 24 94 91 6A A5 3D B3 42 BE'
        '67 0B DF 74 6D BC 85 5D B3 20 12 5E A3 34 34 BF'
        '20 3A 4E 1A E7 4B DF FB 70 7B F5 6A C5 2B A2 49'
        '21 24 11 2C 9A 63 45 7D C6 87 B7 A8 5B 71 04 DD'
        '23 84 05 5A C3 EA 0B 6C 48 72 85 3D 43 4F BF 5F'
        'A0 EF 4A 95 BA D6 2C 92 4C 8D A6 A2 3D 91 A2 F5'
        '23 CF 7F EC 36 B4 43 3E D3 28 10 5A A3 96 36 DE'
        '90 F4 46 BA A2 83 7B EA 81 DA F5 6B 4B 6D 41 24'
        '92 50 10 49 7A 61 62 FA E3 46 EF 58 6D 7A 84 CD'
        '53 80 22 BF 43 6A 0C AC 40 6A 87 76 C3 66 F7 5C'
        '03 BF D2 AC B6 92 14 49 21 25 65 52 B5 81 C1 7B'
        '43 C5 BF 34 5A B0 83 3E A1 2A 04 BA C3 DA 3B 5E'
        '88 F1 02 7B 43 C5 FD F0 0D 76 AD 5B AD 7D A5 92'
        '4C 89 0A 45 72 61 B3 E6 83 A7 FF EC 35 35 04 6E'
        'D1 40 29 7D 23 94 14 DD 10 E4 87 B4 85 A3 6E A0'
        '3B ED F2 A4 6A C2 28 24 91 32 52 AA 7D 81 C0 FD'
        '45 C3 7F 58 5F FA 43 DD 21 88 02 DE E1 F6 2B BC'
        '20 D5 0B 5B 03 A1 FB 80 7F BF 45 5B DB 3F 45 49'
        '22 44 A4 45 72 42 F1 F2 83 F1 FF 94 77 F0 84 2E'
        'C1 92 15 B9 82 D5 2D 7A 41 D2 05 AA 85 F3 77 03'
        'FE FD F9 65 14 D2 A9 2A 4C 91 0A 94 F5 81 51 ED'
        '05 B3 6D 7C 2F 25 23 DD 50 A0 13 5F 61 AD 1A BC'
        '91 ED 0B 55 07 D1 FA 0E BC EB 42 9E FB AD 12 40'
        '91 2A A9 53 F2 46 D1 D5 86 E1 FD D0 52 4A 54 3D'
        'A1 4A 04 BC 82 DA 13 79 21 92 15 B6 0A D1 EF 0D'
        'FA 3F F5 69 45 36 44 95 A2 A4 92 04 C5 85 ED AB'
        '0B D8 DA DC 54 98 8B FD 40 00 4B FB 61 35 CD F4'
        '43 AC 0B CD 07 F9 7B 9B EE 3D 49 56 BA E9 D9 24'
        '16 49 24 B3 DD 01 7B DA 0E F9 FF B4 21 22 44 FA'
        '90 AA BF D4 A2 EB 3F E1 3F D3 3F B9 8F D6 F7 7F'
        'DC 2B F2 DA D7 56 02 49 40 92 49 45 E2 87 73 D3'
        '19 F8 B4 6C 4A 44 83 A5 A0 00 2F AB C1 56 FF 94'
        '3F AD 1D 56 9F FE BE DE B6 3F D5 55 AA AD 54 92'
        '5D 24 92 AB AD 0C BD AE 17 74 7F D8 52 89 44 5A'
        '41 49 55 2C A1 6C 8A A2 39 52 9B 65 5E DB AD B5'
        'EA 2E AA B6 B5 52 92 44 81 49 29 27 D2 0B 5B B4'
        '1D EC EE B4 24 32 83 B5 82 12 56 DB A2 DB 75 88'
        '04 AD 45 9D 63 76 9B 7E BC 3D F5 4A D6 ED 24 92'
        '52 52 45 4B A6 0A B5 54 2B 7C 7D AC 49 44 84 AA'
        '00 80 2D 1D 21 A4 14 00 13 5A 82 AA C1 DD 8E EB'
        '8A 2F CA B6 AA 95 49 24 95 08 94 A7 94 15 7A A8'
        '16 FA 5B F8 52 50 83 40 00 2B 40 1A E1 5B 80 00'
        '00 00 04 00 02 00 0B 80 00 3D B5 55 55 6A 92 49'
        '20 B3 2A AF 4A 1B 5D 54 3B D6 7F 54 24 97 85 58'
        '11 40 A8 1B 42 AD 50 01 58 00 02 00 01 00 06 A0'
        '0E 3B 55 6A AB AB 24 92 4D 44 55 57 54 0A BD B4'
        '6E BE 37 F5 49 50 2A B3 22 17 52 BE A1 D2 A4 92'
        '44 B5 56 D5 DB 77 5D F7 5D EF EA 95 74 54 89 24'
        '90 91 2A A7 4C 36 CF 50 5B FE 1F EA AA 25 52 AD'
        '44 41 6E FD 62 2D AA 28 9B 4A AD AB 76 DD F7 BE'
        'FB BA B5 6A AB AB 32 49 23 2A 95 4E A0 0A BE A8'
        '36 BD 3F B5 50 CA AA B2 10 8E 91 9A C1 D5 50 83'
        '2A B5 59 56 AB BB AE F5 B7 EF EA D6 D4 6C 44 93'
        '48 44 6A AF 5C 3D 5D 50 6D DB 17 EC A5 12 4A AD'
        '45 11 6F FD A2 55 AA 58 55 55 A7 54 EE F7 7B EF'
        'EF 7D 95 A9 35 93 91 48 15 29 95 1D 40 52 FD 60'
        'DB 7E 9F B2 59 4C AA B2 10 2E D2 FD 41 B5 41 02'
        'AA AA 5A 6F BB AA D7 5B 5E DB 7B 56 DA 6D AA 92'
        'B2 4A 52 BE 58 2D 9D 90 B6 DD 97 EC 22 31 45 68'
        '82 55 AD D3 A3 4B 54 55 55 55 AD D5 6D 7F BE F6'
        'FB F6 D4 AA A4 AA 52 A4 80 B2 AD 7D A0 53 7B 61'
        '6D BF 0E 9A 09 46 AA 82 24 AA 56 EE 42 B6 81 12'
        'AA AA B2 A5 D7 D6 ED DF AF BD AB 55 59 55 A4 89'
        '2D 45 52 BA 50 AE BC 90 B6 FD CB EC 14 A9 4A A5'
        '48 55 A9 79 A1 55 2A 45 55 55 4D 5E BD 7D DF 7D'
        'FD 67 35 5A A5 55 89 32 49 15 95 FD AC 77 F3 6F'
        'DB FF 77 40 25 24 95 48 01 B6 B6 B6 A2 AA 40 9A'
        'AB 55 BB AB EB D7 7B F7 57 DC EE A5 5A 56 B2 44'
        '92 6A 2B FA 5C CF FD 5F 6F FE D5 D0 0C 92 46 91'
        '52 54 D5 69 41 55 15 25 54 AA 55 56 DF 7D D6 AD'
        'FD 77 51 5A A5 29 45 11 24 95 55 D5 A2 2E DA AA'
        'B7 ED B5 22 52 49 19 22 05 AB 2A 96 A2 A8 40 4A'
        'AB 55 AA AD B6 CA BD FB D7 AD AE B5 5A 56 B4 B5'
        '4A 22 AA AA 5D 0B 55 5D DC BB 6C DC 89 24 66 88'
        '51 54 D5 69 A2 A5 14 95 54 AA 55 5B 6D BF F7 AF'
        'BE FA B2 AA AA AA 49 02 11 4C 49 24 A5 16 AA EB'
        '0B D6 D8 21 B4 92 8A 50 85 55 AA 96 41 48 41 2A'
        'AB 55 B5 56 DB 55 5D FF 7B AB 6E D5 76 95 B2 58'
        'AC 51 12 40 00 0A 80 00 0E 80 00 6A 01 24 54 82'
        '2B 6B 55 69 A2 92 8A 55 55 5A 6D BD B6 FF F7 BA'
        'EF 76 D5 2A 8A AA 04 A5 21 8A A4 90 00 15 00 00'
        '05 E0 00 14 AA 4A 96 B4 0A 96 AA 96 42 A4 10 AA'
        'AA A5 D3 6B 5D D5 BE F7 DE DD 2A D5 75 45 69 09'
        '4A 24 2D 65 AB 6E D5 AF AF 5E D4 69 48 AA A9 80'
        '55 6D 55 6D A2 A9 25 56 AD 5A AE DA F7 BF 7B DF'
        'FD B2 F5 2A 96 AB 92 56 11 49 D2 14 55 49 2B 7D'
        '7A E9 A9 54 95 55 56 68 96 D2 AA AA 52 42 49 29'
        '52 AB 35 B7 AD 6D F7 7D 5B 6D 96 D5 6A D4 24 90'
        'A2 5A 15 C5 AA B6 EC DB EF BF 2A 2B 22 AA AD 81'
        '2D 2D 55 55 AD 28 92 56 AD 54 EB 6D 7B DB EF FB'
        'F5 B5 69 2A D5 93 49 25 2C 81 64 2A AA B5 53 BE'
        'BD 6A D8 AC AC 55 4A 2A 5A EA AA AA 52 42 24 A9'
        'D2 AB AE DB AE BF BE EF DF 6B 56 D6 96 6C 24 4A'
        '41 2A 95 45 55 BA AE F7 FB DB 65 13 51 AA BA 80'
        '25 55 55 55 AC 94 89 56 2E AD 35 B6 FB F5 6D DE'
        'BA D6 AA AD 69 DB 49 98 92 52 2A 95 56 C5 55 BE'
        'F6 B6 94 2C AA 6B 52 28 DA AA B2 AA 51 21 24 A9'
        'D1 5A ED 6D B6 AF FF BB F7 9A D5 2A 96 52 92 23'
        '24 84 C0 35 6D 3A EB 6D AD ED 61 5B 55 AC AD 41'
        '2A D5 4D 55 A4 94 49 56 AE EB 5B DB 6D FD DA FE'
        'AD 75 36 D5 6D EE 34 88 49 2A 2B 42 92 C5 96 FF'
        'FB 5A 8A 14 AA 53 54 0A 55 AA B1 56 4A 42 92 D5'
        '51 9A B6 B6 DB BB 7F D7 FB 4A C9 5A A9 55 41 35'
        '13 48 94 95 6E BB 6D DA B6 B6 B5 2B 55 AC B5 50'
        'AB 55 46 AC 91 28 25 2A AF 66 ED ED 77 77 D7 7D'
        'AE B5 B6 A5 57 DA 96 41 60 15 52 25 51 56 9B BF'
        'ED ED 44 14 EA 53 54 04 5A AA A9 59 24 82 92 D5'
        '52 5D 5B 5B DE EE FE FF 79 6B 4D 5A AA B3 50 AA'
        '0D 69 24 94 AE A5 76 FB BB 5A 39 57 95 AC AA A8'
        'ED 55 4A A2 4A 24 45 2D 2D A9 D6 D6 BB DD DD EB'
        'D7 56 B2 A5 55 AE A5 09 51 02 49 63 D2 DA AD EF'
        '6A D5 82 09 6A 53 58 01 93 6A 92 A8 91 49 1A DA'
        'F5 57 3D BD F7 7F B7 DF 74 AD 4D 5A D7 75 54 52'
        '42 55 2A 08 2D 35 5B BE DF BA 34 9E 95 AC D1 29'
        '6D 52 A4 93 4A 22 A5 55 2A BA E7 6B 6E F5 FF BE'
        'CB 72 B5 65 2D DB 69 A4 94 92 48 D5 D2 CA B6 FB'
        'B5 65 4A 23 7A B3 2A 42 9A A5 0A A4 24 8A 4A AA'
        'D3 55 BE DE DD EF DD 7B B6 CD 4A 8A DB 2E 94 09'
        '29 24 93 22 2D B5 6B F7 6B 5A A8 8C A5 4C E0 89'
        '6A AA B2 12 D1 24 95 55 6E D7 6D B5 BB DF BB F6'
        'CD 32 B5 6B 56 F5 6A B2 42 49 24 4A D5 4A DF AE'
        'DE E5 55 13 5A B3 0A 12 D5 A4 84 A4 04 51 2D 56'
        '95 3A DB 6E EF BD 77 EF BA ED 4A 94 AD AD 55 44'
        '90 92 4A 91 2A B5 B7 7D B5 9B 28 2A EB 4D 60 4D'
        'AA 29 29 29 AA 8A 52 D9 6A D7 56 DB BB 7B EF 5B'
        '55 53 5A AB 57 5B AA 91 2D 44 92 56 D5 4D 2E FB'
        '6F 75 55 45 54 B5 04 91 55 D2 52 42 20 22 AD 26'
        'D5 6C FD B6 EE F7 FE FE AA AC A5 56 BC F6 AA A6'
        '41 29 4A A1 2A B2 F5 EF 5A AA 2A 12 AB 6A 49 2E'
        'AA 24 84 94 8A 95 52 DA AD 9B 97 6D BB EF 5D EB'
        '55 D3 52 55 6B AD 55 48 92 4A 24 4A AA AD 9F DA'
        'F5 D4 D4 A5 D6 94 90 51 55 49 29 25 21 2A AD B5'
        '53 76 FA D7 6F DE FB BE AB 2C 95 AA AD 6B BB 55'
        '24 90 C9 52 55 73 7B BF 5F 2B 2A 0A 2D 75 22 AE'
        'A4 92 4A 48 4C 55 55 26 AE AD AF BD DE BD EF 6D'
        '56 D3 2B 56 DB 5D 64 B2 49 25 12 45 AA 8E B7 7A'
        'EA D8 A8 A1 DA 94 84 51 49 24 90 92 A2 AA DA DA'
        'B5 5B 75 6B 7D FB BD FA AD 2C AA AD B6 EB DB 4D'
        '52 49 65 2A 55 68 EF F7 BB 52 2A 0A B5 6A 49 AA'
        '95 49 25 24 09 55 25 B5 6A F6 AE DD D7 F7 F7 D5'
        '5A D2 55 55 6D B6 A6 B5 40 92 08 49 AA B7 5D 6D'
        '6E A4 D4 91 4A A9 10 55 21 24 49 49 56 AA DA 4A'
        'AB 4D 7B B7 7F 5F 5F BA B5 55 AD 6D B7 6D 5D 4A'
        'AD 24 A3 4A 95 59 6B FF DA A9 29 24 B5 54 41 15'
        '4A 49 92 22 4D 55 15 B5 5D 7B D6 ED FE FA FA E5'
        '55 94 52 9B 6C CB B2 BD 4A 49 4C 15 2A A6 BF ED'
        '6D 92 55 49 55 52 92 69 14 92 24 88 BA AA EA AB'
        '6A AD 7D BB ED EF EF D5 6A 2B AD F6 DB BE 6D 52'
        'B0 D2 11 69 55 59 EF 5F DA 24 A8 12 AA D4 40 96'
        'B1 24 89 22 A5 55 15 54 D5 EB D7 57 5B BF BF AA'
        '95 54 6A 9D B6 D5 D5 AD 4E 08 A5 04 AA B6 9A FD'
        '74 C9 5A A4 57 55 12 2A 46 49 34 89 5A AA AA AB'
        'AB 3E BA FE FF FD 7A A5 6A AB D5 73 6D 6A 56 B3'
        'B0 A5 88 51 55 45 77 FB A9 12 A4 91 2C A8 40 54'
        '90 92 42 23 6B 55 55 55 36 E5 EF AD F7 6B F7 AA'
        'D5 54 95 AE B5 DD AA AE 4D 52 35 A6 AA BA DF D6'
        'F2 44 B9 24 AB 52 88 95 25 24 94 8A 54 AD 35 6A'
        'EB 5F 55 7B AE FF DF 55 AA 5B 6E B5 DB 2A 5D 69'
        'B2 08 82 09 45 4A AA BF A4 99 44 A9 15 54 11 55'
        '4C 49 29 25 AB 52 CA 97 56 EA FF D7 7F EE BC AB'
        '55 A5 55 6F 6D F5 6A D6 6D 55 28 B5 2A B5 BF FE'
        'D1 22 B9 42 4E A1 20 08 91 92 42 4A 76 AD 35 6A'
        'AD BF 55 BE DD DD FB AA AA 5A AD DA B7 4A D5 AD'
        'D2 A1 4A 82 55 4B 57 F5 64 49 52 94 95 5A 42 53'
        '24 24 94 95 C9 55 4A DA D7 6D FF 6D BB BF EE B5'
        '55 2A DA B6 EC B5 5B 5A AA 8A 11 2C AA B4 BE AF'
        'A8 92 A9 29 2A A0 84 94 49 49 2A 2A B6 AA B6 A3'
        '5C DB 55 DA FF 7B BD 4A AA 56 B5 AD AB D6 AA 55'
        '55 54 AA 41 55 4B 6D FE C1 25 72 52 65 4A 28 21'
        '12 22 61 5B 4D 55 49 5E B3 B5 FE B7 DB F7 7A B5'
        '54 A9 4B 76 DD 54 B5 B5 DB 51 25 1A AA 96 DB F5'
        '92 4A AA A4 8A D0 80 8A 66 CD 0A 26 BA AA 36 A9'
        '6E DF 5B ED B6 EE D5 4A A9 56 B6 CD B6 A9 CA 66'
        '24 A6 48 A1 55 65 37 AF 24 12 D2 99 55 45 11 12'
        '88 10 54 DA D5 6A C9 56 D5 72 F6 BB 6F DF F5 B6'
        'AA 35 6D BB 69 AA 35 DD DB 50 92 16 A4 9A EF 7A'
        '88 A5 29 22 15 10 22 24 52 A5 A1 2A AA A5 2A AB'
        '5B DF AD D6 BD 7A AE A9 54 CA DB 6E DF 54 D6 AA'
        'AD 55 25 69 5B 65 5A EF 21 0A F2 48 AA 45 40 49'
        '24 94 0A DB 55 4D 55 54 B6 B5 7B 6B EB F7 D5 56'
        'B1 35 B6 D5 B4 A9 6D 55 52 AA 48 02 44 9A B7 DA'
        '4A 25 44 93 2A 88 05 12 89 21 55 B5 5B 5A AA AB'
        '6D EF AE BE BF EF 7A E9 46 4E ED BD 6B 52 AA DA'
        'BB 54 92 D4 95 45 6D B6 A0 4A B1 24 56 11 10 24'
        '52 4A 49 56 E4 B5 55 AD DB BA FD D3 EA DE CB 16'
        'B8 B5 9B 6B D5 54 55 35 D6 BB 25 2A AA B5 5B 6C'
        '89 11 46 4A EC A2 24 AA 94 94 96 A9 1B AA AA 5A'
        'B7 6F AB 7E BF BD B6 E9 42 4B 76 D6 AE A1 6A E6'
        'AD 64 CA D5 55 35 77 DB 22 45 A8 B5 15 04 41 00'
        '42 21 29 B7 F5 55 55 D5 AE D5 7E AB F6 EB 6D 56'
        '94 BE DB 7D B5 4A 55 9D 52 DB 35 2A AA AA AD 74'
        '88 0A D5 4A EC 50 88 2A 98 CA 57 6A 46 AA AA 57'
        '7D BF D5 F6 AD 7E D2 A9 A5 55 B6 CA 6A A2 D5 69'
        'BD A6 D6 D5 55 55 7F DA 21 51 42 B5 1A 02 11 42'
        '23 12 AA AD BD 5B 55 AA DB 55 7F 5D DB EB AF 56'
        '48 AB 6D BB D5 2C 2B 57 57 5D A8 95 4A A5 AB 74'
        '8A 05 D5 4A F4 A4 42 14 C8 45 55 52 C9 A4 B5 5E'
        'B6 FF D5 F7 76 BE B5 69 92 BE DB 56 AA C2 D6 DA'
        'B4 6A 37 6A B5 5A 5F A9 20 AA A2 B5 28 08 84 22'
        '15 9A B6 EF 36 5B 4A A9 ED 55 BE AA DD EB 6A 96'
        '25 6B B6 F5 55 15 6D 55 63 D5 E9 55 4A A5 B6 F4'
        '4A 01 C9 56 D2 A1 10 48 A4 25 4D 54 D5 B6 BB 57'
        '5B FF 75 EF B7 BE CD 69 4A DA 6D AD AA AA 92 AA'
        'DD 2B 56 AA B5 55 4F D1 10 AB B4 A9 54 04 24 8B'
        '49 5A BA AB 6D 65 44 AA EE AA EF 5A ED 75 B5 96'
        '15 B7 DB 55 55 55 6D 5D A2 D6 AA D5 4A AA B6 A4'
        '4A 01 41 56 A9 48 81 10 13 25 55 DD 92 9A BB 6F'
        'BB FF DA EF B7 E6 56 68 AB 6D 76 5A AA 85 D5 63'
        '5D 6D 55 5A B6 A5 2D EA A0 AA D5 29 42 11 14 25'
        '54 5A AA AA 6D 6A CA A9 6E B5 B5 BB 5D 5D D9 95'
        '12 DB 4D EB 55 5A AA DE 6D A9 BA A5 6A D2 CB 58'
        '0A 01 AB 56 99 42 21 49 2A A6 B3 55 D5 AB 35 5F'
        'DD EF 5F 6E F7 EA 97 6A 2D B5 FA 54 AA A5 56 A9'
        'D3 57 55 DA D5 2D 35 E2 A0 AA C4 A9 64 08 44 12'
        '52 59 4E D6 9B 4C D6 B2 BA BA F5 DD 6E B5 74 A8'
        '53 6F 2B AA AA 95 AD 56 95 6C B6 AA AA D2 D7 54'
        '0A 01 AB 64 D1 51 09 45 14 A6 B5 2D 6A BB A9 6F'
        'F7 D7 AF 7B DD 55 AB 22 AE DA EC D5 55 AA B2 D9'
        '7A D3 65 55 56 AD 2A D1 50 96 CA 49 8A 02 50 08'
        'A5 59 6A D9 55 54 56 DB AD 7A FA D5 7B EE 56 D4'
        '55 B5 AB 29 6A 56 4D 37 A5 AD 5D 5B A9 4A D5 AA'
        '02 21 95 92 20 54 02 B2 2A A7 55 56 D5 AB AA B7'
        '7B EF AF BF EE B5 D5 21 2B 6F 55 D2 95 AD B2 C9'
        '5A 56 D2 EA 76 B5 56 58 54 85 6A 49 44 81 54 84'
        'AA 58 AA B5 AA B5 6D DE FF DD 7B 6A DD AA 2A 4A'
        '56 DA AE 29 6A A9 6D B7 6D E9 6D 55 8D CA A9 A2'
        '80 09 97 22 29 2A 00 29 55 A7 56 CA 57 4A 9B 6D'
        'EE BB D6 BF BB 6D DA 91 5B AD 59 D3 5B 56 93 5A'
        '52 96 9B DB 79 3D 56 A8 29 52 E8 56 82 40 A9 55'
        '2A 5A B5 35 AC BB 76 BB DD EF 7E F5 76 AA 35 24'
        'B6 FB B6 04 A4 AA 6C A5 DF 6D 6A 2A A6 D2 AD 52'
        '82 05 AA 80 28 A9 02 28 55 A4 AA EA DB 56 AD D7'
        'BB BE AD AF ED 5B EA 4D 2D 95 54 AB 5B 55 53 5A'
        '95 6D DB 4D 5B 57 9A AA 22 0A D2 24 A0 81 48 57'
        '95 2D 4A D6 9B 57 76 DF F7 BB 5F 7F B6 EA 55 24'
        '15 A9 32 65 35 5A AE B7 76 D6 AD B9 6A A8 65 51'
        '44 51 54 89 0A 14 12 AC 32 AA B5 A9 75 6C AD BB'
        '6F 7F FA D5 6D 55 B4 49 FF 76 C4 8A C9 A5 51 64'
        'AA A9 53 66 D6 D7 DE A4 08 84 E5 20 21 21 44 5B'
        '4A 52 AB 56 AA AB DB 57 FE EB 6F BF DA AB 4A AA'
        '2A AD 29 55 37 5A AE 9B 55 56 AE 99 95 2A 29 4A'
        'A1 11 C8 05 44 4A 11 6E A5 AD 4A AD 52 DA 36 FE'
        'ED DF FA EC B5 D6 B5 11 D6 EA E2 4A EA AB D1 6A'
        'AD AA D9 77 7A F5 D6 91 04 22 B5 50 2A 90 A4 DA'
        '9A 12 B5 59 6F A7 ED B7 DF BF 57 5B DB 2D 48 44'
        '3D 95 0C 95 15 54 2F 56 DA 56 A6 AA A7 46 3A A4'
        '48 85 C0 04 80 25 09 B5 42 ED 4B 56 D4 5D 5B 6D'
        'BA FA FD FE B6 DA B5 A9 EB 6A A1 2A EA AB D2 D5'
        '55 AD 5D D5 5A BD E5 49 11 10 AA A1 52 88 53 6B'
        'A9 12 B5 69 AB B6 B2 DF FF F7 DF 55 ED 35 64 0A'
        'B6 AD 14 95 55 56 AC 9A AA 5A AA AB 6A CA 5A 92'
        '42 23 C0 04 04 22 84 D6 44 AD 4B 57 5D 6B AF 7B'
        '77 AF 7A FD 5A EA 89 51 6D 59 65 2A 95 54 53 65'
        '55 F5 55 5C D6 B5 AE A4 94 44 95 09 51 48 2B AD'
        'AA 92 B6 AA 6B 4D 75 B7 EE FE F7 57 B3 55 72 4A'
        'CA B2 08 55 6A EB AE DA DB 0A BB 6B AD D6 D1 49'
        '40 89 C0 22 02 22 84 B5 49 2D 55 55 D4 76 AE EE'
        'DD BD ED FA EE AA 84 91 BB 64 A2 AA AD 16 51 25'
        'A4 F5 64 D5 59 2D 3E 93 15 11 0A 48 A4 84 1B DB'
        '52 52 AA AE 97 DD D9 BF FF EB BF 6F 54 D4 AA 4B'
        '54 C9 4C 95 52 ED 6E DB 5B 2A DB AA B6 DA E2 A4'
        '40 22 D0 02 09 29 26 2A A4 8D 56 D9 6C B3 6F 7D'
        'BB 7F 75 DA DB 55 A1 2A AB 92 11 35 6D 12 92 AA'
        'A6 D5 95 56 A9 B5 9D 49 2A 85 02 50 52 42 49 D6'
        'A9 32 55 56 DB 6E B5 EB F7 DB EF 77 AA AA 0A 4A'
        'AD 24 A4 C2 92 ED 6D 55 5A AB 6A B9 D7 56 6A 92'
        '80 10 A4 02 85 14 96 BA D2 4D AA A9 A5 55 DB 5F'
        'BE FF 7A DD 55 49 52 9D 5A 49 4A 15 6D 12 55 AA'
        'B5 5A AD 67 3A AD D5 54 54 45 08 A4 10 22 2D 55'
        'A8 B2 5B 57 5E EE AE FF 77 AA EF B6 AA B2 54 35'
        '54 92 24 AA 92 AD AA 56 A5 55 52 DA D5 6A 9A A2'
        '80 90 52 00 A5 48 91 AA A5 8D A4 AD 69 5B 7B B5'
        'ED FF DA ED D5 44 81 6A A9 24 89 55 6D 5A D5 A9'
        '5A AA AD 55 B5 95 75 49 29 02 80 02 08 15 2F 6A'
        'A8 22 5B 5A 96 AC D2 EF BF AD B7 BA 8A A9 2A AD'
        '52 49 52 95 55 53 2A 56 A5 75 55 B6 AB 7D A5 54'
        '42 28 14 54 51 20 52 95 B5 5D B6 B5 7B 77 AF BF'
        '7B 7B 6D 6B 55 22 49 5A AC 92 14 2B AA AC D5 A9'
        '5A 8A AA 55 6A A3 5A 92 88 41 20 80 82 4A AD 6B'
        '61 25 25 65 94 AD 5B 7A F7 EF FF DE AA 89 12 B5'
        '51 24 A2 D4 55 53 55 57 6B 75 55 EA D7 5E A6 A4'
        '52 92 40 01 14 92 55 56 BA 5A DA 9B 6B DB B6 F7'
        'EF 7A BA B5 55 24 69 55 24 49 49 2B AA A6 AA A8'
        '94 AA AD 17 AC B5 59 49 80 00 85 14 21 24 AA AD'
        '6A AA AB 76 AD 36 6D EF DE EF F7 ED 52 49 82 BB'
        '59 93 12 54 AA AD 55 57 6B 55 5A EC 5B 6A B7 54'
        '55 55 08 20 8A 49 55 69 54 55 56 A5 5A ED DB DE'
        'BB DE AE DA AC 94 2A A4 42 24 66 AB 55 5A AB 59'
        '54 A5 55 5B B4 DD 69 51 00 00 10 81 10 92 AA D6'
        'ED 6A AD 5D 75 9B 6F BD FF 75 FD AA A1 21 49 7A'
        '95 49 09 6A AD 55 54 A6 AB 5A AA A5 6B AA D6 AA'
        '52 52 21 04 25 25 55 A9 99 15 B2 EA C6 76 DB 7B'
        'EA FF 5B 5A AA 8A 92 A5 28 12 AA 95 52 AA D7 5A'
        'D4 B5 55 5E B5 55 A9 54 C4 84 84 09 49 4A AB 57'
        '6E 6A 6D 95 BD DD B6 EF 5F ED F6 F5 58 22 25 5A'
        '42 B5 55 76 AD 55 A8 B5 2B 6A AA E9 EE B5 57 55'
        '11 20 20 10 12 15 56 AA BA 95 D6 6B 52 53 6B FB'
        'FD DB 5D AA C2 8C 8A EA 99 4A A5 89 55 5A 57 6A'
        'D5 55 55 57 5A AB 59 54 44 45 01 25 44 AA AD 6D'
        '55 76 99 DE AD BE DD DF 6B 7F F7 6D 14 51 35 50'
        '42 B5 5A 76 AA A5 A9 55 36 AA AA AA D5 D6 B6 D5'
        '91 08 44 00 11 25 5A 95 AE 89 77 28 B6 6B B7 B7'
        'FF D6 DC D2 D1 04 45 55 15 4A A5 95 55 5B 56 AA'
        'E9 55 56 DD BB 2D 6B 2A 24 51 08 2A A4 4A B5 6A'
        'B5 76 CA D7 69 DA 6D 7E AE FD AB AD 04 52 D5 69'
        '6A B5 5B 6A B6 AA AA D5 56 D6 AA A2 D6 FA D4 D4'
        '89 04 00 80 09 95 2A AB 65 8D B5 5A D6 A7 DB ED'
        'FD 57 7E D5 51 04 0A C2 15 4A A4 95 55 55 55 2A'
        'AA 99 55 5F AD 8B 5B 55 22 10 21 2A A2 2A D5 56'
        '9E 77 56 B5 2D 5D 76 FF FB FD D5 2A 82 29 AA 95'
        '6A B5 5B 6A AA B5 AA D5 55 66 AA A5 5B 7A AA AA'
        '48 40 44 00 09 55 56 ED 71 DD 6D 6A F5 AA AD DB'
        'AE AA BA D4 24 4A 2A A4 95 4A AA 96 D5 4A 55 AA'
        'AA 9A B5 5A B6 A6 D5 54 92 84 80 55 52 55 B9 2A'
        'AF 57 5A D5 8A B5 EB BF 7D FF EF 55 4A 91 4A 89'
        '6A B5 55 6D 2D B5 56 55 6A B5 4A A5 CD 5D 56 AB'
        '44 08 04 80 04 AB 46 D5 52 BA F5 AB 7B 4B 5F 7B'
        'DA AB 5A AA 10 24 2A B2 95 4A B7 5A DA 4B A9 AA'
        'D5 6A B5 5B 7B B9 AD 52 11 20 89 15 29 5A BD AA'
        'ED 6F AB 54 A6 B6 B6 F7 7F FE F5 55 45 49 55 04'
        '6A B5 A8 A5 55 B6 56 AD AA D5 6A AA 95 67 5A AD'
        'A4 09 10 20 42 A5 51 56 95 59 7E AF 59 55 6D EE'
        'FB AB A6 A8 28 12 55 52 95 4B 57 5A AA AD'
END


OBJECT BITMAP 
BEGIN
        '42 4D 26 05 00 00 00 00 00 00 76 00 00 00 28 00'
        '00 00 28 00 00 00 3C 00 00 00 01 00 04 00 00 00'
        '00 00 B0 04 00 00 00 00 00 00 00 00 00 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 00 00 BF 00 00 BF'
        '00 00 00 BF BF 00 BF 00 00 00 BF 00 BF 00 BF BF'
        '00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF'
        '00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF'
        '00 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB 00 00 BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB B0 00 00 0B BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB 00 00'
        '00 00 BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB B0 00 00 00 00 0B BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB B0 00 00 00 00 0B BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB B0 00 00 00 00 0B BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB B0 00 00'
        '00 00 0B BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB 00 00 00 00 BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB B0 00 00 0B BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB 00 00 BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB 00 00 BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB B0 00 00 0B BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB 00 00 00 00 BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB B0 00 00'
        '00 00 0B BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB B0 00 00 00 00 0B BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB B0 00 00 00 00 0B BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB B0 00 00 00 00 0B BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB 00 00'
        '00 00 BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB B0 00 00 0B BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB 00 00 BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB 00'
        '00 BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB B0 00 00 0B BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB 00 00 00 00 BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB B0 00 00 00 00 0B BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB B0 00 00'
        '00 00 0B BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB B0 00 00 00 00 0B BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB B0 00 00 00 00 0B BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB 00 00 00 00 BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB B0 00'
        '00 0B BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB 00 00 BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 0B BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB B0 0B BB BB BB BB BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB B0 0B BB BB BB BB BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB B0 0B BB'
        'BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB BB'
        'BB B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
        '00 00 00 00 00 00'
END


MAIN MENU 
BEGIN
        MENUITEM "&About...", 102
        MENUITEM "Draw Image", 101
END


ABOUT DIALOG 41, 33, 146, 132
STYLE DS_LOCALEDIT | DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU
CAPTION "About"
FONT 8, "Helv"
BEGIN
        CONTROL "Bitmap Dragging Sample", -1, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE, 0, 6, 144, 8
        CONTROL "Purpose: Demonstrates smooth bitmap dragging.  Select ""Draw Image"" to draw the domino, then drag it around using the mouse.", 103, "STATIC", SS_LEFT | WS_CHILD | WS_VISIBLE | WS_GROUP, 6, 19, 136, 42
        CONTROL "Written by: Michael Vincze", 101, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE | WS_GROUP, 0, 65, 146, 9
        CONTROL "Adapted from: Patrick Schreier of", -1, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE, 2, 75, 144, 8
        CONTROL "Microsoft Windows Developer Support", -1, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE, 2, 85, 144, 8
        CONTROL "Copyright \251 1993 Vincze International", 102, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE | WS_GROUP, 0, 95, 146, 8
        CONTROL "Portions Copyright \251 1992 Microsoft Corp.", 102, "STATIC", SS_CENTER | WS_CHILD | WS_VISIBLE | WS_GROUP, 0, 105, 146, 8
        CONTROL "OK", 1, "BUTTON", BS_DEFPUSHBUTTON | WS_CHILD | WS_VISIBLE | WS_GROUP | WS_TABSTOP, 57, 115, 32, 14
END


APPLICATION ICON 
BEGIN
        '00 00 01 00 01 00 20 20 10 00 00 00 00 00 E8 02'
        '00 00 16 00 00 00 28 00 00 00 20 00 00 00 40 00'
        '00 00 01 00 04 00 00 00 00 00 00 02 00 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
        '00 00 00 00 BF 00 00 BF 00 00 00 BF BF 00 BF 00'
        '00 00 BF 00 BF 00 BF BF 00 00 C0 C0 C0 00 80 80'
        '80 00 00 00 FF 00 00 FF 00 00 00 FF FF 00 FF 00'
        '00 00 FF 00 FF 00 FF FF 00 00 FF FF FF 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
        'BB BB BB BB BB BB BB BB BB BB 00 00 00 00 00 00'
        'BB 30 00 0B BB BB BB BB BB BB 03 00 00 00 00 00'
        'B3 00 00 00 BB BB BB BB BB BB 03 30 00 00 00 00'
        'B3 00 00 00 BB BB BB BB BB BB 03 33 00 00 00 00'
        'B3 00 00 00 BB BB BB BB BB BB 03 33 00 00 00 00'
        'B3 00 00 00 BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB 30 00 03 BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB B3 33 3B BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB B3 00 00 BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB 30 00 00 0B BB BB BB 03 33 00 00 00 00'
        'BB BB BB 30 00 00 0B BB BB BB 03 33 00 00 00 00'
        'BB BB BB 30 00 00 0B BB BB BB 03 33 00 00 00 00'
        'BB BB BB 30 00 00 0B BB BB BB 03 33 00 00 00 00'
        'BB BB BB B3 00 00 3B BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB 33 33 BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB BB BB BB BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB 30 00 0B BB 03 33 00 00 00 00'
        'BB BB BB BB BB B3 00 00 00 BB 03 33 00 00 00 00'
        'BB BB BB BB BB B3 00 00 00 BB 03 33 00 00 00 00'
        'BB BB BB BB BB B3 00 00 00 BB 03 33 00 00 00 00'
        'BB BB BB BB BB B3 00 00 00 BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB 30 00 03 BB 03 33 00 00 00 00'
        'BB BB BB BB BB BB B3 33 3B BB 03 33 00 00 00 00'
        '00 00 00 00 00 00 00 00 00 00 03 33 00 00 00 00'
        '0B BB BB BB BB 