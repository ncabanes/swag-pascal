{
I 've seen a lot of question here arround, how to
display a bitmap befor starting a program in Windows.
Well, this program shows a bitmap without opening a window.
I 'll send you this program for borland pascal.
(Those who use TPW will have to change the USES declaration)

**************************************************************
* Bitmap befor starting the program without opening a window *
**************************************************************
}

PROGRAM Sample;

USES Wintypes, Winprocs, WinCrt, Objects, OWindows, ODialogs;

{$R BITMAP.RES }

TYPE

  PClipWin = ^TClipWin;
  TClipWin = OBJECT (TWindow)
    Constructor Init (AParent : PWindowsObject; ATitle : PChar;
                      AMenu : HMenu);
    Procedure GetWindowClass (VAR AWndClass : TWndClass); VIRTUAL;
    Function  GetClassName : PChar; VIRTUAL;
    Procedure SetupWindow; VIRTUAL;
  END;

  TClipApp = OBJECT (TApplication)
    Procedure InitMainWindow; VIRTUAL;
  END;

{ *** TClipWin *** }

Constructor TClipWin.Init (AParent : PWindowsObject; ATitle : PChar;
                           AMenu : HMenu);
{ ** The main window in this example is a fixed window
     which cannot be resized or moved                   ** }
BEGIN
  Inherited Init (AParent, ATitle);
{ ** The sample main window will be open over the whole screen ** }
  Attr.X := -1;
  Attr.Y := -1;
  Attr.W := GetSystemMetrics (sm_CxScreen) + 3;
  Attr.H := GetSystemMetrics (sm_CyScreen) + 3;
  Attr.Style := WS_SYSMENU OR WS_MINIMIZEBOX OR WS_MAXIMIZE;
{ ** The menu must be defined in the resource ** }
  Attr.Menu := AMenu;
END;

Procedure TClipWin.GetWindowClass (VAR AWndClass : TWndClass);
BEGIN
  Inherited GetWindowClass (AWndClass);
{ ** Also the icon of the program must be defined in the resource ** }
  AWndClass.HIcon := LoadIcon (HInstance, 'MAINICON');
{ ** This gray background is a standard which is not heavy colored ** }
  AWndClass.HBrBackGround := CreateSolidBrush (RGB (128, 128, 128));
END;

Function TClipWin.GetClassName : PChar;
BEGIN
  GetClassName := 'Bitmap Sample';
END;

Procedure TClipWin.SetupWindow;
BEGIN
  Inherited SetupWindow;
{ ** DeleteMenu kills the menu point 'MOVE / RESIZE'. The windows can
     now not be resized or moved. It is fixed                        ** }
  DeleteMenu (GetSystemMenu(HWindow, FALSE), 1, MF_BYPOSITION);
END;

{ *** TClipApp *** }

Procedure TClipApp.InitMainWindow;
BEGIN
  CmdShow := SW_SHOWMAXIMIZED;
  MainWindow := New(PClipWin, Init(NIL, 'Bitmap Sample Window',
                    LoadMenu (HInstance, 'MAINMENU')));
END;

VAR
  ClipApp : TClipApp;
  DC, MemDC : hDC;
  Bitmap, OldBitmap : HBitmap;
  BM : TBitmap;
  Rect : TRect;
  H, W : Integer;
  Ticks : LongInt;
BEGIN
{ ** !! DISPLAY THe BITMAP BEFOR APPLICATION.INIT !! ** }

{ ** Create the display context ** }
  DC := CreateDC('DISPLAY',nil,nil,nil);
{ ** Load the bitmap stored in the resource ** }
  Bitmap := LoadBitmap(HInstance, MakeIntResource('STARTBITMAP'));
{ ** Memory context compatibel to the display context ** }
  MemDC := CreateCompatibleDC(DC);
{ ** Save the actual context ** }
  OldBitmap := SelectObject(MemDC, Bitmap);
{ ** Get the bitmap ** }
  GetObject (Bitmap, SizeOf(BM),@BM);
{ ** Get height and width of the screen ** }
  H := GetSystemMetrics (sm_CyScreen);
  W := GetSystemMetrics (sm_CxScreen);
{ ** Copy the resource bitmap into the memory context and move it
     exactly in the middle of the screen !!                    ** }
  BitBlt (DC,W DIV 2-(BM.bmWidth DIV 2), H DIV 2-(BM.bmHeight DIV 2),
          BM.bmWidth, BM.bmHeight, MemDC, 0, 0, SRCCopy);
{ ** Holds the system for 5 seconds, to study the bitmap.
     5000 = milliseconds ** }
  Ticks := GetTickCount;
  Repeat
  Until ABS (Ticks - GetTickCount) > 5000;
{ ** Remove all bitmaps and contexts ** }
  DeleteObject (SelectObject (MemDC, OldBitmap));
  DeleteDC (MemDC);
  DeleteDC (DC);
{ ** Now start the main window ** }
  ClipApp.Init('Bitmap Sample Window');
  ClipApp.Run;
  ClipApp.Done;
END.

----------------------- CUT IT -- CUT IT -----------------------------

This example will show the resource bitmap befor the main window,
without opening an other window. I made this program as easy as
possible. The palette is not included, but a 256 colored palette will
be added (selectpalette - realizepalette) without difficulties.
Ofcourse a normal bitmap (HDD) could also be used instead of the
resource bitmap
