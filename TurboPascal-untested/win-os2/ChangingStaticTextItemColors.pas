(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0057.PAS
  Description: Changing Static Text Item Colors
  Author: A.A. OLOWOFOYEKU
  Date: 05-26-95  23:00
*)

(*
> I am trying to change the color of a static text item in a dialog
> with no luck.  I tried to redefine the wmPaint method of the TStatic
> control in the following manner:
> ~~~~~~~~~~
> procedure TUnits.wmPaint (var Msg : TMessage);
> var
>    DC : hDC;
> begin
>    DC := GetDC(hWindow);
>    if not Updated  { <-- Updated is a boolean field in TUnits }
>      then SetTextColor(DC,GetSysColor(COLOR_GRAYTEXT))
>      else SetTextColor(DC,GetSysColor(COLOR_WINDOWTEXT));
>    ReleaseDC(hWindow,DC);
>    DefWndProc(Msg);
> end;
> It didn't work.  Any help would be greatly appreciated.

You need to override the wmCtlColor method. You might also need to paint the
background yourself. I have a unit which I use for these purposes. It can be
used for any type of dialog object.

From: "A.A. Olowofoyeku" <laa12@cc.keele.ac.uk>
*)
Unit CTL;

Interface
{$F+}

uses
Wintypes, WinProcs,OWindows;
{//////////////////////////////////////////////////////////}
{// generic wrapper procedure for wm_EraseBkGnd methods ///}
{//////////////////////////////////////////////////////////}
Procedure DoEraseBackGround
          (Var Message : TMessage; Wnd : HWnd; TheBrush : THandle);
{
Message  = the TMessage passed to the calling object method
Wnd      = the window to paint (generally the object's hWindow)
TheBrush = the brush to use to paint the background
           should be one of the xxxxxBrush constants
              WHITE_BRUSH
              LTGRAY_BRUSH
              GRAY_BRUSH
              DKGRAY_BRUSH
              BLACK_BRUSH
           Ideally, should be the same as the one passed in the
           wmCtlColor method
}

{//////////////////////////////////////////////////////////}
{// generic wrapper procedure for wmCtlColor methods  /////}
{//////////////////////////////////////////////////////////}
Procedure DoCtlColor
         (Var Message : TMessage; Const Caller : PWindowsObject;
          TheBrush : THandle; BackColor : TColorRef);
{
Message  = the TMessage passed to the calling object method
Caller   = a pointer to the calling Object
TheBrush = the brush to use to paint the background
           could be any of the colorxxxxxBrush constants
           Ideally, should be the same as that used in the
           wm_eraseBkGnd method
Color    = the color to use to paint child controls
           should be an RGB value
            e.g., RGB(255,255,255) = for white
                  RGB(128,128,128) = for a shade of gray
}

Implementation

{//////////////////////////////////////////////////////////}
{// generic wrapper procedure for wm_EraseBkGnd methods ///}
{//////////////////////////////////////////////////////////}
Procedure DoEraseBackGround
          (Var Message : TMessage; Wnd : HWnd; TheBrush : THandle);
Var
  aBrush,
  OldBrush : hBrush;
  DC       : HDC;
  tR       : tRect;

Begin
  DC := hdc(Message.wParam);
  aBrush := GetStockObject(TheBrush);
  UnrealizeObject(aBrush);
  OldBrush := SelectObject(DC, aBrush);
  GetClientRect(Wnd, tR);
  With tR Do PatBlt(DC, left, top, right-left, bottom-top, PatCopy);
  DeleteObject(SelectObject(DC, OldBrush));
  SelectObject(DC, OldBrush);
End;

{//////////////////////////////////////////////////////////}
{// generic wrapper procedure for wmCtlColor methods  /////}
{//////////////////////////////////////////////////////////}
Procedure DoCtlColor
         (Var Message : TMessage; Const Caller : PWindowsObject;
          TheBrush : THandle; BackColor : TColorRef);
Begin
  Caller^.DefWndProc(Message);
  Case HiWord(Message.lParam) of
    CtlColor_Dlg,
    CtlColor_Edit,
    CtlColor_MsgBox,
    CtlColor_STATIC,
    CtlColor_ListBox,
    CtlColor_BTN : Begin
                     Message.Result := GetStockObject(TheBrush);
                     SetBkColor(Message.wParam, BackColor);
                   End;
    CtlColor_LISTBOX : Message.Result := GetStockObject(TheBrush);
  End;
End;
{/////////////////////////////////////////////////////////////////}
END.
{/////////////////////////////////////////////////////////////////}
{/////////////////////////////////////////////////////////////////}
{////  TEST DIALOG   ////////}
  Type
  PTestDialog = ^TestDialog;
  TestDialog  = Object(TDialog)
     Procedure wm_eraseBkGnd(Var Message : TMessage);
               Virtual wm_First+wm_eraseBkGnd;
     Procedure WmCtlColor(Var Message : TMessage);
               Virtual wm_first+wm_CtlColor;
  End;

{///////////////////////////////////////}
Procedure  TestDialog.wm_eraseBkGnd(Var Message : TMessage);
Begin
   DoEraseBackGround(Message, HWindow, LTGRAY_BRUSH);
End;
{///////////////////////////////////////}
Procedure  TestDialog.WmCtlColor(Var Message : TMessage);
Begin
   DoCtlColor(Message, @Self, LTGRAY_BRUSH, RGB(192,192,192));
End;

