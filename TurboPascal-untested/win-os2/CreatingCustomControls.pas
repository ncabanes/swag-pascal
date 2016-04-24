(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0063.PAS
  Description: Creating Custom Controls
  Author: JAMES B. MILLARD
  Date: 05-26-95  23:28
*)

{
From: jmillard@nmsu.edu (James B. Millard)
: Howdy...yet another wacky question here.  Anyone have any sample code to
: create a custom object? Like a spin button, for example.  Can you create a
: button in resource workshop that's not a borland style button OR a windows
: style button....i.e. A windows style button with a bitmap on it. If you
: can tell me, I'll be your friend forever. :)

Here is an "interface" unit and a "spin" control dll, written in pascal.
I have not included the RW interface functions, because I haven't written
them yet (and I may not).

Let me say a little bit about the control.  It is probably not like the normal
spin control in that it only includes the up and down buttons.  It was written
to provide an addon spin control to an existing edit object I already have.
In the resource workshop, create a window next to the edit you want to have
the spin control for, rename the class to "JBM_SpinButton".  Then have the
edit control send a message to the spin control before the inherited setup
window is called.  This message is the  WM_SPINSETEDIT shown below, the
WPARAM should be the HWindow of the edit control.  This associates the edit
control with the spin control - the spin control will ensure it is properly
aligned.  When the spin button gets a mouse click it sends the edit control
a WM_SPINUP or WM_SPINDOWN message as appropriate, whatever you do with it is
up to you. (It doesn't have to be an edit window for that matter...)

At the very least, it provides a working example of a control created in
TP.  (Note the bitmaps are included after the spin.dll file... as spin.rc)

If you have any questions, just email me.

*******************************************************************************
    File: spinlib.pas
*******************************************************************************
}

Unit SpinLib;

Interface

Uses  WinTypes, WinProcs;

{* messages used by spin control and edit control}
Const WM_SPINSETEDIT       = WM_USER + 500;
      WM_SPINUP            = WM_USER + 501;
      WM_SPINDOWN          = WM_USER + 502;

{* State flags}
      STATE_NOSPIN         = $0000;
      STATE_SPINUP         = $0001;
      STATE_SPINDOWN       = $0002;
      STATE_CAPTURE        = $0010;

{* record used by spin control}
Type  PSpinStruct = ^TSpinStruct;
      TSpinStruct = Record
         hwndNotify : HWnd;
         wState     : Word;
         Count      : Integer;
      End;

Procedure LoadSpinLibrary;

Implementation

Var hSpin       : THandle;
    OldExitProc : Pointer;

{* procedure to load "spin.dll"}
Procedure LoadSpinLibrary;
Begin
   hSpin:=LoadLibrary('spin.dll');
End;

{* new exit procedure to automatically unload "spin.dll"}
Procedure SpinExit; Far;
Begin
   ExitProc:=OldExitProc;
   If (hSpin<>0) Then FreeLibrary(hSpin);
End;

Begin
   OldExitProc:=ExitProc;
   ExitProc:=@SpinExit;
   hSpin:=0;
End.

*******************************************************************************
    File: spin.pas
*******************************************************************************

{
Windows's "spin" control by Brad Millard, JBM, P.O. Box 3648, University Park,
NM 88003

There is no warranty, no license, or restrictions, use at your own risk, feel
free to
distribute...

If you find any bugs, please let me know... jmillard@nmsu.edu
}

Library SpinCtl;

{$R SPIN.RES}

Uses   WinProcs, WinTypes, Win31, SpinLib;

Const  ID_SPINTIMER = 1000;

{***** Spin Button painting procedure *****}
Procedure Paint(AWnd : HWnd; DC : HDC; SS : PSpinStruct);
Var bm, obm : HBitMap;
    mdc     : HDC;
    tbm     : TBitMap;
Begin
   {* Get state and load the correct bitmap}
   Case (SS^.wState AND $000F) Of
      STATE_NOSPIN   : bm:=LoadBitMap(HInstance, 'SPIN_NOSPIN');
      STATE_SPINUP   : bm:=LoadBitMap(HInstance, 'SPIN_UP');
      STATE_SPINDOWN : bm:=LoadBitMap(HInstance, 'SPIN_DOWN');
   End;
   {* If the bitmap is OK, then paint}
   If (bm<>0) Then Begin
      GetObject(bm, SizeOf(TBitMap), @tbm);
      mdc:=CreateCompatibleDC(DC);
      obm:=SelectObject(mdc, bm);
      BitBlt(DC, 0, 0, tbm.bmWidth, tbm.bmHeight, mdc, 0, 0, SRCCOPY);
      SelectObject(mdc, obm);
      DeleteObject(bm);
      DeleteDC(mdc);
   End;
End;

{* function GetState returns the state constant depending on mouse hit
position}
Function GetState(AWnd : HWnd; WParam : Word; LParam : LongInt; SS :
PSpinStruct) : Word;
Var r  : TRect;
Begin
   GetClientRect(AWnd, r);
   If (PtInRect(r, TPoint(LParam))) Then Begin
      If (TPoint(LParam).Y>12) Then GetState:=STATE_SPINDOWN
      Else GetState:=STATE_SPINUP;
   End
   Else GetState:=0;
End;

{* notifies the edit control (hwndNotify) and increments the notification
count}
Function NotifyWnd(AWnd : HWnd; SS : PSpinStruct) : LongInt;
Begin
   NotifyWnd:=0;
   If (SS<>NIL) Then With SS^ Do Begin
      Case (wState AND $000F) Of
         STATE_SPINUP   : NotifyWnd:=SendMessage(hwndNotify, WM_SPINUP, AWnd,
Count);
         STATE_SPINDOWN : NotifyWnd:=SendMessage(hwndNotify, WM_SPINDOWN, AWnd,
Count);
      End;
      Inc(Count);
   End;
End;

{***** Message Specific Procedures *****}

{* paints the button in the current state}
Function wmPaint(AWnd : HWnd; SS : PSpinStruct) : LongInt;
Var PS : TPaintStruct;
Begin
   BeginPaint(AWnd, PS);
   Paint(AWnd, PS.hDC, SS);
   EndPaint(AWnd, PS);
   wmPaint:=0;
End;

{* sets focus to hwndNotify, sets capture, notifies hwndNotify of the first
hit,
   and resets the count, also starts timer for continuous mouse hits, then
paints
   the new state}
Function wmLButtonDown(AWnd : HWnd; WParam : Word; LParam : LongInt) : LongInt;
Var dc : HDC;
    ss : PSpinStruct;
Begin
   ss:=PSpinStruct(GetWindowLong(AWnd, 0));
   If (ss<>NIL) Then With ss^ Do Begin
      SetFocus(hwndNotify);
      SetCapture(AWnd);
      wState:=STATE_CAPTURE OR GetState(AWnd, WParam, LParam, ss);
      NotifyWnd(AWnd, ss);
      Count:=-1;
      SetTimer(AWnd, ID_SPINTIMER, 40, NIL);
      dc:=GetDC(AWnd);
      Paint(AWnd, dc, ss);
      ReleaseDC(AWnd, dc);
   End;
   wmLButtonDown:=0;
End;

{* if the button has set capture, paints the button in the correct state}
Function wmMouseMove(AWnd : HWnd; WParam : Word; LParam : LongInt) : LongInt;
Var dc : HDC;
    ss : PSpinStruct;
    r  : TRect;
    ns : Word;
Begin
   ss:=PSpinStruct(GetWindowLong(AWnd, 0));
   If (ss<>NIL) Then With ss^ Do Begin
      If (wState AND STATE_CAPTURE = STATE_CAPTURE) Then Begin
         ns:=GetState(AWnd, WParam, LParam, ss);
         {* only paint if we have to...}
         If (ns<>wState AND $000F) Then Begin
            wState:=STATE_CAPTURE OR ns;
            dc:=GetDC(AWnd);
            Paint(AWnd, dc, ss);
            ReleaseDC(AWnd, dc);
         End;
      End;
   End;
   wmMouseMove:=0;
End;

{* Cleans up -- releases capture, repaints, and kills the timer}
Function wmLButtonUp(AWnd : HWnd; WParam : Word; LParam : LongInt) : LongInt;
Var dc : HDC;
    ss : PSpinStruct;
Begin
   ss:=PSpinStruct(GetWindowLong(AWnd, 0));
   If (ss<>NIL) Then With ss^ Do Begin
      If (wState AND STATE_CAPTURE = STATE_CAPTURE) Then Begin
         KillTimer(AWnd, ID_SPINTIMER);
         wState:=0;
         dc:=GetDC(AWnd);
         Paint(AWnd, dc, ss);
         ReleaseDC(AWnd, dc);
         ReleaseCapture;
      End;
   End;
   wmLButtonUp:=0;
End;

{* Responds to timer messages when capturing.  Counts negative for 12 counts.
   When the count is negative, the hwndNotify is not "spun" (except for the
   initial hit).  When the count reaches -13, it is reset to 0 and then
   hwndNotify is spun on each timer message.  This provides the delay after
   the first mouse click}
Function wmTimer(AWnd : HWnd; WParam : Word; LParam : LongInt) : LongInt;
Var ss : PSpinStruct;
Begin
   ss:=PSpinStruct(GetWindowLong(AWnd, 0));
   With ss^  Do Begin
      If (wState AND STATE_CAPTURE <> 0) AND (hwndNotify<>0) Then Begin
         If (Count<0) Then Dec(Count);
         If (Count<-12) OR (Count>0) Then Begin
            Count:=0;
            NotifyWnd(AWnd, ss);
         End;
      End;
   End;
   wmTimer:=0;
End;

{* This message is recieved from the edit control before either are shown. The
   spin control calculates it's correct position and moves itself accordingly.}
Function wmSpinSetEdit(AWnd : HWnd; WParam : Word; LParam : LongInt) : LongInt;
Var ss   : PSpinStruct;
    r    : TRect;
    x, y : Integer;
Begin
   ss:=PSpinStruct(GetWindowLong(AWnd, 0));
   If (ss<>NIL) Then With ss^ Do Begin
      hwndNotify:=WParam;
      GetWindowRect(hwndNotify, r);
      MapWindowPoints(0, GetParent(AWnd), r, 2);
      x:=r.Right + 6;
      y:=r.Top + (r.Bottom - r.Top - 23) DIV 2 - 1;
      MoveWindow(AWnd, x, y, 17, 23, False);
   End;
   wmSpinSetEdit:=0;
End;

{***** Spin control Window Procedure *****}
Function SpinWndProc(AWnd : HWnd; Msg, WParam : Word; LParam : LongInt) :
LongInt; Export;
Var SpinStruct : PSpinStruct;
Begin
   SpinWndProc:=0;
   Case Msg Of
      WM_CREATE  : Begin
         {* Create the TSpinStruct and set it at the extra bytes}
         SpinStruct:=PSpinStruct(GetWindowLong(AWnd, 0));
         GetMem(SpinStruct, SizeOf(TSpinStruct));
         If (SpinStruct<>NIL) Then SpinStruct^.wState:=0;
         SetWindowLong(AWnd, 0, LongInt(SpinStruct));
      End;
      WM_DESTROY : Begin
         {* Get rid of TSpinStruct}
         SpinStruct:=PSpinStruct(GetWindowLong(AWnd, 0));
         If (SpinStruct<>NIL) Then FreeMem(SpinStruct, SizeOf(TSpinStruct));
      End;
      WM_PAINT   : Begin
         SpinStruct:=PSpinStruct(GetWindowLong(AWnd, 0));
         If (SpinStruct<>NIL) Then SpinWndProc:=wmPaint(AWnd, SpinStruct);
      End;
      WM_GETDLGCODE   : SpinWndProc:=DLGC_BUTTON;
      WM_SPINSETEDIT  : SpinWndProc:=wmSpinSetEdit(AWnd, WParam, LParam);
      WM_LBUTTONDOWN  : SpinWndProc:=wmLButtonDown(AWnd, WParam, LParam);
      WM_MOUSEMOVE    : SpinWndProc:=wmMouseMove(AWnd, WParam, LParam);
      WM_LBUTTONUP    : SpinWndProc:=wmLButtonUp(AWnd, WParam, LParam);
      WM_TIMER        : SpinWndProc:=wmTimer(AWnd, WParam, LParam);
      Else SpinWndProc:=DefWindowProc(AWnd, Msg, WParam, LParam);
   End;
End;

{***** Class Registration Procedure *****}
Procedure RegisterSpinClass;
Var w : TWndClass;
Begin
   w.cbClsExtra  := 0;
   {* reserve extra space for TSpinStruct}
   w.cbWndExtra  := SizeOf(Pointer);
   {* this is the DLL instance, I guess..., it works...}
   w.hInstance     := System.hInstance;
   w.hIcon        := 0;
   w.hCursor     := LoadCursor(0, idc_Arrow);
   {* Since we use a bitmap that covers the whole window, don't mess with the
background.}
   w.hbrBackground := 0;
   w.lpszMenuName    := NIL;
   w.lpszClassName := 'JBM_SpinButton';
   w.style           := cs_HRedraw or cs_VRedraw or cs_GlobalClass;
   w.lpfnWndProc     := @SpinWndProc;
   RegisterClass(w);
End;


Exports
   SpinWndProc;

Begin
   {* register the class when the library is loaded}
   RegisterSpinClass;
End.

*******************************************************************************
    File: spin.rc
*******************************************************************************


SPIN_DOWN BITMAP 
BEGIN
 '42 4D 8A 01 00 00 00 00 00 00 76 00 00 00 28 00'
 '00 00 11 00 00 00 17 00 00 00 01 00 04 00 00 00'
 '00 00 14 01 00 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 10 00 00 00 00 00 00 00 00 00 BF 00 00 BF'
 '00 00 00 BF BF 00 BF 00 00 00 BF 00 BF 00 BF BF'
 '00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF'
 '00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF'
 '00 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 08 77 77 77 77 77 77 77 00 00 00 00 08 77'
 '77 77 77 77 77 77 0F 00 00 00 08 77 77 77 77 77'
 '77 77 00 00 00 00 08 77 77 77 70 77 77 77 00 00'
 '00 00 08 77 77 77 00 07 77 77 00 00 00 00 08 77'
 '77 70 00 00 77 77 00 00 00 00 08 77 77 00 00 00'
 '07 77 00 00 00 00 08 77 77 77 77 77 77 77 00 00'
 '00 00 08 77 77 77 77 77 77 77 00 00 00 00 08 88'
 '88 88 88 88 88 88 00 00 00 00 07 70 00 00 00 00'
 '00 88 00 00 00 00 0F F7 77 77 77 77 77 88 00 00'
 '00 00 0F F7 77 77 77 77 77 88 00 00 00 00 0F F7'
 '70 00 00 00 77 88 00 00 00 00 0F F7 77 00 00 07'
 '77 88 0F 00 00 00 0F F7 77 70 00 77 77 88 00 00'
 '00 00 0F F7 77 77 07 77 77 88 00 00 00 00 0F F7'
 '77 77 77 77 77 88 00 00 00 00 0F F7 77 77 77 77'
 '77 88 00 00 00 00 0F FF FF FF FF FF FF F8 00 00'
 '00 00 0F FF FF FF FF FF FF FF 00 00 00 00 00 00'
 '00 00 00 00 00 00 00 00 00 00'
END


SPIN_NOSPIN BITMAP 
BEGIN
 '42 4D 8A 01 00 00 00 00 00 00 76 00 00 00 28 00'
 '00 00 11 00 00 00 17 00 00 00 01 00 04 00 00 00'
 '00 00 14 01 00 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 10 00 00 00 00 00 00 00 00 00 BF 00 00 BF'
 '00 00 00 BF BF 00 BF 00 00 00 BF 00 BF 00 BF BF'
 '00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF'
 '00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF'
 '00 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 0F 88 88 88 88 88 88 88 00 00 00 00 0F F8'
 '88 88 88 88 88 88 0F 00 00 00 0F F7 77 77 77 77'
 '77 88 00 00 00 00 0F F7 77 77 77 77 77 88 00 00'
 '00 00 0F F7 77 77 07 77 77 88 00 00 00 00 0F F7'
 '77 70 00 77 77 88 00 00 00 00 0F F7 77 00 00 07'
 '77 88 00 00 00 00 0F F7 70 00 00 00 77 88 00 00'
 '00 00 0F F7 77 77 77 77 77 88 00 00 00 00 0F F7'
 '77 77 77 77 77 88 00 00 00 00 07 70 00 00 00 00'
 '00 88 00 00 00 00 0F F7 77 77 77 77 77 88 00 00'
 '00 00 0F F7 77 77 77 77 77 88 00 00 00 00 0F F7'
 '70 00 00 00 77 88 00 00 00 00 0F F7 77 00 00 07'
 '77 88 0F 00 00 00 0F F7 77 70 00 77 77 88 00 00'
 '00 00 0F F7 77 77 07 77 77 88 00 00 00 00 0F F7'
 '77 77 77 77 77 88 00 00 00 00 0F F7 77 77 77 77'
 '77 88 00 00 00 00 0F FF FF FF FF FF FF F8 00 00'
 '00 00 0F FF FF FF FF FF FF FF 00 00 00 00 00 00'
 '00 00 00 00 00 00 00 00 00 00'
END


SPIN_UP BITMAP 
BEGIN
 '42 4D 8A 01 00 00 00 00 00 00 76 00 00 00 28 00'
 '00 00 11 00 00 00 17 00 00 00 01 00 04 00 00 00'
 '00 00 14 01 00 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 10 00 00 00 00 00 00 00 00 00 BF 00 00 BF'
 '00 00 00 BF BF 00 BF 00 00 00 BF 00 BF 00 BF BF'
 '00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF'
 '00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF'
 '00 00 FF FF FF 00 00 00 00 00 00 00 00 00 00 00'
 '00 00 0F 88 88 88 88 88 88 88 00 00 00 00 0F F8'
 '88 88 88 88 88 88 01 00 00 00 0F F7 77 77 77 77'
 '77 88 00 00 00 00 0F F7 77 77 77 77 77 88 00 00'
 '00 00 0F F7 77 77 07 77 77 88 00 00 00 00 0F F7'
 '77 70 00 77 77 88 00 00 00 00 0F F7 77 00 00 07'
 '77 88 00 00 00 00 0F F7 70 00 00 00 77 88 00 00'
 '00 00 0F F7 77 77 77 77 77 88 00 00 00 00 0F F7'
 '77 77 77 77 77 88 00 00 00 00 08 88 88 88 88 88'
 '88 88 00 00 00 00 08 77 77 77 77 77 77 77 00 00'
 '00 00 08 77 77 00 00 00 07 77 00 00 00 00 08 77'
 '77 70 00 00 77 77 00 00 00 00 08 77 77 77 00 07'
 '77 77 01 00 00 00 08 77 77 77 70 77 77 77 00 00'
 '00 00 08 77 77 77 77 77 77 77 00 00 00 00 08 77'
 '77 77 77 77 77 77 00 00 00 00 08 77 77 77 77 77'
 '77 77 00 00 00 00 08 77 77 77 77 77 77 77 00 00'
 '00 00 08 88 88 88 88 88 88 88 00 00 00 00 00 00'
 '00 00 00 00 00 00 00 00 00 00'
END


