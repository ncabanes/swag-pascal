PROGRAM ListDlg;
{ This code demonstrates how to display different dialogs in one dialog. You can also use
  this code to build a dialog with register cards.
  (c) 1997 U. Conrad, uconrad1@gwdg.de }

{$R MULTIDLG.RES }  { located at the end .. use XX34 to decode }
USES OWindows,ODialogs,Strings,Objects,WinProcs,WinTypes;

CONST idd_ListBox         = 301;
      idd_Anchor          = 302;

CONST wm_MyFocus          = wm_User + 1000;

TYPE PHwnd = ^HWnd;
     PAtom = ^TAtom;

TYPE TDemoApp=OBJECT(TApplication)
       PROCEDURE InitMainWindow; virtual;
     END;

TYPE DlgInfoStruct = RECORD                 { contains informations about a sub dialog }
       szListText  : array[0..50] of char;  { title which should be displayed in the list box }
       ResName     : array[0..50] of char;  { ID of the sub dialog }
       fPresent    : boolean;               { loaded or not, that's the question }
       pCtrlHndls  : THandle;               { handle for hwnd of controls }
       pCtrlTexts  : THandle;               { handle for atoms of controls }
       CntCntrls   : byte;                  { number of control elements in this dialog }
     END;

TYPE PDemoDlg = ^TDemoDlg;
     TDemoDlg = OBJECT(TDialog)
       diDlgs         : array[0..2] of DlgInfoStruct;
       iCurDlg        : integer;
       CONSTRUCTOR Init(AParent : PWindowsObject;AName : PChar);
       PROCEDURE SetupWindow; virtual;
       PROCEDURE MyFocus(var Msg : TMessage); virtual wm_First + wm_MyFocus;
       PROCEDURE ListBox(var Msg : TMessage); virtual id_First + idd_ListBox;
       PROCEDURE ChildDialogVisible(iDialog : integer;State : boolean);
       PROCEDURE LoadAndCreateControls(iDialog : integer);
       PROCEDURE WMDestroy(var Msg : TMessage); virtual wm_First + wm_Destroy;
       PROCEDURE Ok(var Msg : TMessage); virtual id_First + id_ok;
       DESTRUCTOR Done; virtual;
     END;

{ ================== Methods of the program dialog object ===================== }
CONSTRUCTOR TDemoDlg.Init(AParent : PWindowsObject;AName : PChar);
VAR b          : byte;
BEGIN
  inherited Init(AParent,AName);
  { Initializing sub dialog informations }
  FillChar(diDlgs[0],SizeOf(diDlgs[0]),#0);
  StrCopy(diDlgs[0].szListText,'Identification');
  StrCopy(diDlgs[0].ResName,'DLG_IDEN');
  FillChar(diDlgs[1],SizeOf(diDlgs[1]),#0);
  StrCopy(diDlgs[1].szListText,'Preferences');
  StrCopy(diDlgs[1].ResName,'DLG_PREF');
  FillChar(diDlgs[2],SizeOf(diDlgs[2]),#0);
  StrCopy(diDlgs[2].szListText,'Wishes');
  StrCopy(diDlgs[2].ResName,'DLG_WISH');
  iCurDlg:=-1;
  { no dialog displayed 'til yet }
END;

PROCEDURE TDemoDlg.SetupWindow;
VAR i            : integer;
BEGIN
  inherited SetupWindow;
  FOR i:=0 TO 2 DO BEGIN
    LoadAndCreateControls(i);     { load control elements of one child dialog }
    ChildDialogVisible(i,false);  { and hide them, they will be visible after selecting one from the listbox }
    SendDlgItemMessage(HWindow,idd_ListBox,lb_AddString,0,LongInt(@diDlgs[i].szListText));
  END;
  { If you want to init the control elements do it here }
  SetDlgItemText(HWindow,1000,'My');
  SetDlgItemText(HWindow,1001,'Name');
  { fill list box with dialog titles }
  SendDlgItemMessage(HWindow,idd_ListBox,lb_SetCurSel,0,0);
  { select first dialog and make it visible }
  PostMessage(HWindow,wm_command,idd_ListBox,MakeLong(GetDlgItem(HWindow,idd_ListBox),lbn_SelChange));
  { pretend a user's selection in the list box }
  PostMessage(HWindow,wm_MyFocus,0,0);
END;

PROCEDURE TDemoDlg.ListBox(var Msg : TMessage);
VAR lCurSel        : integer;
BEGIN
  IF Msg.lParamHi=lbn_SelChange THEN BEGIN    { new child dialog selected }
    lCurSel:=SendDlgItemMessage(HWindow,idd_ListBox,lb_GetCurSel,0,0);
    IF lCurSel=-1 THEN Exit;
    IF lCurSel<>iCurDlg THEN BEGIN            { a different child dialog was selected }
      ChildDialogVisible(iCurDlg,false);      { hide actual child dialog }
      iCurDlg:=lCurSel;                       { new actual child dialog }
      ChildDialogVisible(iCurDlg,true);       { show new actual child dialog }
    END;
  END;
  Msg.Receiver:=0;
END;

PROCEDURE TDemoDlg.MyFocus(var Msg : TMessage);
BEGIN
  SetFocus(GetDlgItem(HWindow,idd_ListBox));
  { will give the focus back to the list box }
  Msg.Receiver:=0;
END;

PROCEDURE TDemoDlg.LoadAndCreateControls(iDialog : integer);
{ This function will load the resource of a child dialog and put its control elements
  to the dialog }
VAR hDlgFont          : HFont;
    hDlgRes           : THandle;
    hDlgResMem        : THandle;
    lpDlgRes          : PChar;
    style             : longint;
    bNumOfCtrls       : byte;
    bCurCtrl          : byte;
    xOffset, yOffset  : integer;
    hAnchor           : HWnd;
    rc, trc           : TRect;
    pt                : TPoint;
    wID               : word;
    classname         : PChar;
    phw               : PHWnd;
    PTmp              : PAtom;
BEGIN
  hDlgFont:=SendMessage(HWindow,wm_GetFont,0,0);
  { First we need to know which font is used in the dialog so we can set the font of
    the child controls. }
  hDlgRes:=FindResource(hInstance,diDlgs[iDialog].ResName,rt_dialog);
  hDlgResMem:=LoadResource(hInstance,hDlgRes);
  { load the resource }
  lpDlgRes:=LockResource(hDlgResMem);
  { get a pointer to the resource }
  style:=PLongint(lpDlgRes)^;
  { get the dialog's style. This and the following operations get their information from
    the dialog header. It's structur is described in the help under the topic " dialog box header" }
  lpDlgRes:=lpDlgRes+SizeOf(Style);    { increment pointer }
  bNumOfCtrls:=PByte(lpDlgRes)^;       { get number of controls }
  diDlgs[iDialog].CntCntrls:=bNumOfCtrls;
  lpDlgRes:=lpDlgRes+SizeOf(byte);     { increment pointer }
  lpDlgRes:=lpDlgRes+(4*SizeOf(word)); { ingnore  x, y, cx, and cy of dialog }
  IF PByte(lpDlgRes)^=$FF THEN  lpDlgRes:=lpDlgRes+3
    ELSE WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;                { ignore menu }
  lpDlgRes:=lpDlgRes+1;
  WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;
  lpDlgRes:=lpDlgRes+1;                { pass the class name }
  WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;
  lpDlgRes:=lpDlgRes+1;                { pass the caption }
  IF style and ds_SetFont<>0 THEN BEGIN { if ds_SetFont is set we have to skip font information }
    lpDlgRes:=lpDlgRes+SizeOf(word);   { pass point size }
    WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;
    lpDlgRes:=lpDlgRes+1;              { pass the font name }
  END;
  diDlgs[iDialog].pCtrlHndls:=LocalAlloc(lptr,SizeOf(HWnd)+SizeOf(HWnd)*bNumOfCtrls);
  { get memory for control's window handles }
  diDlgs[iDialog].pCtrlTexts:=LocalAlloc(lptr,SizeOf(TAtom)*bNumOfCtrls);
  { get memory for control's atom handles }
  pTmp:=PAtom(LocalLock(diDlgs[iDialog].pCtrlTexts));
  FOR bCurCtrl:=1 TO bNumOfCtrls DO BEGIN       { initialize atoms }
    pTmp^:=AddAtom('');
    pTmp:=PAtom(Pchar(PTmp)+SizeOf(TAtom));
  END;
  LocalUnlock(diDlgs[iDialog].pCtrlTexts);
  hAnchor:=GetDlgItem(HWindow,idd_Anchor);
  GetWindowRect (hAnchor,rc);
  { get position of anchor }
  pt.x:=rc.left;
  pt.y:=rc.top;
  ScreenToClient(HWindow,pt);
  rc.left:=pt.x;
  rc.top:=pt.y;
  pt.x:=rc.right;
  pt.y:=rc.bottom;
  ScreenToClient(HWindow,pt);
  rc.right:=pt.x;
  rc.bottom:=pt.y;
  xOffset:=rc.right;
  yOffset:=rc.top;
  { get offset for control elements in client coordinates }
  phw:=PHwnd(LocalLock(diDlgs[iDialog].pCtrlHndls));
  FOR bCurCtrl:=1 TO bNumOfCtrls DO BEGIN    { start creating controls }
    WITH trc DO BEGIN
      left:=PInteger(lpDlgRes)^;
      lpDlgRes:=lpDlgRes+SizeOf(integer);        { increment pointer }
      top:=PInteger(lpDlgRes)^;
      lpDlgRes:=lpDlgRes+SizeOf(integer);        { increment pointer }
      right:=PInteger(lpDlgRes)^;
      lpDlgRes:=lpDlgRes+SizeOf(integer);        { increment pointer }
      bottom:=PInteger(lpDlgRes)^;
      lpDlgRes:=lpDlgRes+SizeOf(integer);        { increment pointer }
    END;
    CopyRect(rc,trc);                        { get the control's coordinates }
    MapDialogRect(HWindow,rc);               { convert to pixels }
    rc.left:=rc.left+xOffset;                { add offset }
    rc.top:=rc.top+yOffset;
    wID:=PWord(lpDlgRes)^;                   { get the control's ID }
    lpDlgRes:=lpDlgRes+SizeOf(word);         { increment pointer }
    style:=PLongint(lpDlgRes)^;              { get the control's styles }
    lpDlgRes:=lpDlgRes+SizeOf(longint);      { increment pointer }
    CASE PByte(lpDlgRes)^ OF
      $80   : classname:='button';
      $81   : classname:='edit';
      $82   : classname:='static';
      $83   : classname:='listbox';
      $84   : classname:='scrollbar';
      $85   : classname:='combobox';
      ELSE BEGIN { get the special class name }
        classname:=lpDlgRes;
        WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;
      END;
    END;
    lpDlgRes:=lpDlgRes+1;
    phw^:=CreateWindow(Classname,lpDlgRes,style,rc.left,rc.top,rc.right,rc.bottom,HWindow,wID,hInstance,nil);
    { create the control element }
    IF hDlgFont<>0 THEN SendMessage(pHW^,wm_SetFont,hDlgFont,0); { give the control the right font }
    WHILE lpDlgRes^<>#0 DO lpDlgRes:=lpDlgRes+1;                 { skip window text }
    lpDlgRes:=lpDlgRes+1;                                        { skip null terminator }
    lpDlgRes:=lpDlgRes+1;                                        { skip second null terminator }
    phw:=PHWnd(PChar(phw)+SizeOf(HWnd));
  END;
  LocalUnlock(diDlgs[iDialog].pCtrlHndls);
  UnlockResource(hDlgResMem);
  FreeResource(hDlgResMem);
  { the resource isn't needed any more, so free it }
  diDlgs[iDialog].fPresent:=true;
END;

PROCEDURE TDemoDlg.ChildDialogVisible(iDialog : integer;State : boolean);
VAR hCtl         : PHwnd;
    i            : integer;
    pa           : PAtom;
    buf          : array[0..80] of char;
    dwCtlCode    : longint;
    IgnoreText   : boolean;
    lStyle       : longint;
BEGIN
  IF iDialog<0 THEN Exit;
  hCtl:=PHwnd(LocalLock(diDlgs[iDialog].pCtrlHndls));
  pa:=PAtom(LocalLock(diDlgs[iDialog].pCtrlTexts));
  IF State THEN BEGIN      { show the dialog }
    FOR i:=1 TO diDlgs[iDialog].CntCntrls DO BEGIN
      IF pa^<>0 THEN BEGIN
        GetAtomName(pa^,buf,SizeOf(buf));
        SetWindowText(hCtl^,buf);
        DeleteAtom(pa^);
      END;
      ShowWindow(hCtl^,sw_Show);
      pa:=PAtom(PChar(pa)+SizeOf(TAtom));
      hCtl:=PHWnd(Pchar(hCtl)+SizeOf(HWnd));
    END;
  END
  ELSE BEGIN               { hide the dialog }
    FOR i:=1 TO diDlgs[iDialog].CntCntrls DO BEGIN
      ShowWindow(hCtl^,sw_Hide);
      dwCtlCode:=SendMessage(hCtl^,wm_GetDlgCode,0,0);
      ignoreText:=false;
      IF dwCtlCode and dlgc_WantChars<>0 THEN BEGIN
        pa^:=0;
        IgnoreText:=true;
      END;
      IF dwCtlCode and dlgc_Static<>0 THEN BEGIN
        lStyle:=GetWindowLong(hCtl^,gwl_Style);
        IF lStyle and ss_NoPrefix<>0 THEN BEGIN
          pa^:=0;
          IgnoreText:=true;
        END;
      END;
      IF not IgnoreText THEN BEGIN
        GetWindowText(hCtl^,buf,SizeOf(buf));
        pa^:=AddAtom(buf);
        SetWindowText(hCtl^,'');
      END;
      pa:=PAtom(PChar(pa)+SizeOf(TAtom));
      hCtl:=PHWnd(Pchar(hCtl)+SizeOf(HWnd));
    END;
  END;
  LocalUnlock(diDlgs[iDialog].pCtrlTexts);
  LocalUnlock(diDlgs[iDialog].pCtrlHndls);
END;

PROCEDURE TDemoDlg.Ok(var Msg : TMessage);
VAR buf          : array[0..255] of char;
BEGIN
  GetDlgItemText(HWindow,1000,buf,SizeOf(buf)-1);
  { here you can receive the state of all dialog control elements, for example the "First" edit }
  EndDlg(id_ok);       { finally close this dialog }
END;

PROCEDURE TDemoDlg.WMDestroy(var Msg : TMessage);
VAR i        : integer;
BEGIN
  FOR i:=0 TO 2 DO IF diDlgs[i].fPresent THEN BEGIN { free handles of controls }
    LocalFree(diDlgs[i].pCtrlHndls);
    LocalFree(diDlgs[i].pCtrlTexts);
  END;
  inherited WMDestroy(Msg);
END;

DESTRUCTOR TDemoDlg.Done;
BEGIN
  inherited done;
END;

{ ================== Methods of the application ===================== }
PROCEDURE TDemoApp.InitMainWindow;
BEGIN
  MainWindow:=New(PDemoDlg,Init(nil,'DLG_Main'));
  { will create a window from dialog template DLG_Main }
END;

{ *****************   Program ******************* }

VAR DemoApp  : TDemoApp;

BEGIN
  DemoApp.Init('DemoApp');
  DemoApp.Run;
  DemoApp.Done;
END.

END.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000956-290697--72--85-61452----MULTIDLG.RES--1-OF--1
zkI+F2l5LoZ2FIs+A-0w++++E+0+U+V4++Y+YU-N++++++U+HJAUIq3iQm-HNL7dNU+3++2+
5U+8+Cs1+++0I66aFaZmQrE+++I+1++d++w+u+C++63EUE++BE+-+-s+0k1j+k+++Z007YlV
QrE++1I+1+-I++w+uEC++63EUE++-E+S+-s+0E1k+k+++Z007Y3YN57ZQrAu+++3+0U+V++D
+Cc1U+0-I62+++I+C+02++w+v+C++63EUE++-E-6+6E+1k1h+s++UJ0-++1z-E-2H2RTHI37
HU+k26o+++1++AWE-46+9+1Z+4w+++-BRKloOG-YOK3gPqQUN4JhPqtnR57VR4ZjPU+6+2pH
63BVPbAUIqJmOKM+0k-7+16+1U+-++2++J0+Hog+++g+KU+m++s++U++++3EU2BVPaBZP+++
0k+7+1Y+0++i+E+++Z007YFdMKljNk++0k+J+16+9++h+E2-cJ01++1z-E-2H2RTI373FU+k
2+w-++-++60+0YM+0E0G+3U+++++0+-BIm-HMKtn63BZQaZa++A+-+-2+2E+oEQ5++3EU2Jb
NrA+++Y+2U+t++g+oUQ7++7EU0NHMr7VPK7gNKE+++Y+5k+t++g+okQ7++-EU0NDRaJm9KJV
QrY+++Y+9++n++g+p+Q7++-EU0N6ML7Y627jOKlZN+++0E+t+0s+0k1J-kY++30+7Z7VRk++
H++2+2++Ak1E-kQ++p0+Ea3b++-F+-++BE+9+BM50E+0I6+aI43kNL6++32+5++r++g+pkQ7
++-EU3+aP43nR4ZX++-F+0U+Bk+9+BU50E++I6+aEqljR4U++2k+DU-+++s+qEQ+++BEU0N2
OKtbQk++zkI+F2l5LpR7IoU+A-1+++++E+0+U+N4++Y+YU-M++++++U+HJAUIq3iQm-HNL7d
NU+5++E+6U+C+9c9+k+-I6+aH4xqNE++-k+H+2w+1U0s0kA++J0+IqJiQqIUPqMU7Z-pQb-j
QqI+++Q+6U+x++s+ikg1++3EU0N4RKlaOKlgPKJiR+++-k+l+2o+1U0t0kA++J0+FaJZP4Zi
Nm-jNW+aJqxmR4U+++Q+FU+W++g+j+g1++3EU0NDR4VZQXc++0c+F+-a+-2+jEi++63EUE++
zkw+zk2+A-lE++++2++3++4++2FAFpx7F2JC+-++-E+0U+-2H2RTHI37HU+E++I++s++F2l5
Lp-GFIM+2++3++G++2FAFpxLGJB6++++++++++++++++++++++++
***** END OF BLOCK 1 *****

