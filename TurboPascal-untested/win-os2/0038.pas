{
MM> Thanks alot but I was woundering if you had the complete code USES
MM> and every thing no blanks. Becuase I am not to good at graphics. ---

}
UNIT BMPWin;

INTERFACE

USES
  WinProcs, WinTypes, Objects, OWindows;

{$R MYBMP.RES} (* Change as appropriate *)

TYPE
  pBMPWindow = ^tBMPWindow;
  tBMPWindow = OBJECT(tWindow)
    PRIVATE
      vBitmap : hBitmap;
      vBitSize : tBitmap;
    PUBLIC
      CONSTRUCTOR Init(aParent : pWindowsObject; aBitmapName : pChar);
      DESTRUCTOR Done; VIRTUAL;
      PROCEDURE SetupWindow; VIRTUAL;
      PROCEDURE Paint(vDC : hDC; VAR vPS : tPaintStruct); VIRTUAL;
  END;

IMPLEMENTATION

CONSTRUCTOR tBMPWindow.Init(aParent : pWindowsObject; aBitmapName :
pChar);
  BEGIN
    INHERITED Init(aParent, NIL);
    Attr.Style := ws_Child OR ws_Visible;
    vBitmap := LoadBitmap(hInstance, aBitmapName);
    IF vBitmap = 0 THEN
      BEGIN
        Status := em_InvalidWindow;
        Fail;
      END;
    GetObject(vBitmap, SizeOf(vBitSize), @vBitSize);
  END;

DESTRUCTOR tBMPWindow.Done;
  BEGIN
    DeleteObject(vBitmap);
    INHERITED Done;
  END;

PROCEDURE tBMPWindow.SetupWindow;
  BEGIN
    INHERITED SetupWindow;
    SetWindowPos(hWindow, 0, 0, 0, vBitSize.bmWidth, vBitSize.bmHeight,
                 swp_NoMove OR swp_NoZOrder OR swp_NoActivate OR
                 swp_NoRedraw);
  END;

PROCEDURE tBMPWindow.Paint(vDC : hDC; VAR vPS : tPaintStruct);
  VAR
    vRect : tRect;

  PROCEDURE DrawBitmap;
    VAR
      vMemDC : hDC;
      vOldBMP : hBitmap;

    BEGIN
      vMemDC := CreateCompatibleDC(vDC);
      vOldBMP := SelectObject(vMemDC, vBitmap);
      BitBlt(vDC, 0, 0, Attr.W, Attr.H, vMemDC, 0, 0, srcCopy);
      SelectObject(vMemDC, vOldBMP);
      DeleteDC(vMemDC);
    END;

  BEGIN
    SaveDC(vDC);
    DrawBitmap;
    RestoreDC(vDC, -1);
  END;
END.
