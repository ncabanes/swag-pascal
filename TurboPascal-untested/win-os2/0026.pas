Unit Center;
{**************************************************************************}
{*    Center   by Daniel Thomas  CIS 72301,2164                           *}
{*                                                                        *}
{*  This code is hereby donated to the public domain.  Enjoy.             *}
{*                                                                        *}
{*  This unit contains a procedure, CenterPopup, which will center a      *}
{*  Popup window (i.e. a dialog) in it's parent's window.  If it won't    *}
{*  fit inside the parent's window, then it will be centered on top of    *}
{*  the parent.                                                           *}
{*                                                                        *}
{*  Also, if the dialog would be positioned off the screen, it is forced  *}
{*  within the visible screen.                                            *}
{*                                                                        *}
{*  There are a few descendant objects - tCenteredDialog and              *}
{*  tCenteredInputDialog - that make using it a snap.  Just replace an    *}
{*  occurrance of pDialog with pCenteredDialog, and you've got a centered *}
{*  dialog!                                                               *}
{**************************************************************************}

Interface

USES WinTypes,WinProcs,WObjects,StdDlgs;

Type
  pInteger=^integer;

  pCenteredDialog=^tCenteredDialog;
  tCenteredDialog=object(tDialog)
      Procedure SetupWindow; virtual;
    end;

  pCenteredInputDialog=^tCenteredInputDialog;
  tCenteredInputDialog=object(tInputDialog)
      Procedure SetupWindow; virtual;
    end;

Procedure CenterPopup(aPopup,aParent: hWnd);

Implementation

Procedure CenterPopup(aPopup,aParent: hWnd);

var
  PopupR,ParentR  : tRect;
  ScreenW,ScreenH : integer;
  x,y,
  PopupW,PopupH,
  ParentW,ParentH : word;

  procedure SetupValues(Wnd: hWnd; var R: tRect; var W,H : word);
    begin
      GetWindowRect(Wnd,R);
      W := R.Right-R.Left;
      H := R.Bottom-R.Top;
    end; {SetupValues}

  procedure SetupLocation(PopupSize,ScreenSize,ParentSize,ParentStart : word;
                          var PopupStart: word);
    begin
      if PopupSize > ScreenSize then
        PopupStart := 0
      else
        begin
          if PopupSize <= ParentSize then
            PopupStart := ParentStart+((ParentSize-PopupSize) div 2)
          else
            PopupStart := ParentStart-((PopupSize-ParentSize) div 2);
          if PopupStart > ScreenSize then
            PopupStart := 0
          else
          if PopupStart+PopupSize > ScreenSize then
            PopupStart := ScreenSize-PopupSize;
        end;
    end; {SetupLocation}

begin {CenterPopup}
  ScreenW := GetSystemMetrics(sm_CXScreen);
  ScreenH := GetSystemMetrics(sm_CYScreen);
  SetupValues(aPopup,PopupR,PopupW,PopupH);
  SetupValues(aParent,ParentR,ParentW,ParentH);
  SetupLocation(PopupW,ScreenW,ParentW,ParentR.Left,x);
  SetupLocation(PopupH,ScreenH,ParentH,ParentR.Top,y);
  MoveWindow(aPopup,x,y,PopupW,PopupH,false);
end; {CenterPopup}

Procedure tCenteredDialog.SetupWindow;

begin
  tDialog.SetupWindow;
  CenterPopup(HWindow, Parent^.HWindow);
end; {tAniOptionsDialog.SetupWindow}

Procedure tCenteredInputDialog.SetupWindow;

begin
  tInputDialog.SetupWindow;
  CenterPopup(HWindow, Parent^.HWindow);
end; {tAniOptionsDialog.SetupWindow}



end.
