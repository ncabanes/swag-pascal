(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0042.PAS
  Description: Windows File Manager Exte
  Author: MICHAEL A VINCZE
  Date: 08-25-94  09:13
*)

{
From: vincze@dseg.ti.com (MICHAEL A VINCZE 0171847)

Well after posting the question about how to create a Windows
File Manager extension and not getting any responses, I figured
that not a lot of people know how to do.  So after several hours,
as typical with translating something from C to Pascal, I finally
got the following example to work.  Note that the example consists
of four files:

  constant.pas
  xtension.pas
  xtension.rc
  icon.zip     <- this is uuencoded here.

Just FYI one of the hardest items to figure out was the parameter info
for the FMExtensionProc function.  The Borland supplied WFEXT.PAS file
is totally bogus.  The key was to pass lParam by reference, and not
by value.  Hence the following:

  function FMExtensionProc (Handle: HWnd; Msg: WORD; var lParam: Longint):
  HMENU; export;                                     ^^^

Evidently, the File Manager allocates space for a TFMS_LOAD structure (record)
and passes the address to this structure via the lParam parameter.  This should
lead you to a rule of thumb for translating Windows C programs to Pascal.
I leave the wording for the rule of thumb up to yourself to figure out.

Best regards,
Michael Vincze
mav@asd470.dseg.ti.com

---------- snip ---------- snip ---------- snip ----------

unit constant;

interface

const

  { menu items (must within the range of 1 to 99
  }
  IDM_STATUSWIN         =  10;
  IDM_GETFILESELLFN     =  15;
  IDM_GETDRIVEINFO      =  20;
  IDM_GETFOCUS          =  25;
  IDM_RELOADEXTENSIONS  =  30;
  IDM_REFRESHWINDOW     =  35;
  IDM_REFRESHALLWINDOWS =  40;
  IDM_ABOUTEXT          =  45;


  { dialog items
  }
  IDD_PATH              =  206;
  IDD_VOLUME            =  207;
  IDD_SHARE             =  208;
  IDD_TOTALSPACE        =  209;
  IDD_FREESPACE         =  210;

  IDD_SELFILECOUNT      =  201;
  IDD_SELFILESIZE       =  202;


  { miscellaneous items
  }
  STATUS_WIDTH          =  400;
  STATUS_HEIGHT         =  100;
  INFO_LINE_WIDTH       =  300;
  INFO_LINE_HEIGHT      =  18;
  INFO_LINE_X           =  10;
  INFO_LINE_Y           =  20;
  ID_STATUSTIMER        =  99;
  INFO_STR_LEN          =  50;
  TIMER_DURATION        =  1500;  { 1.5 seconds }
  PATH_NAME_LEN         =  260;
  VOLUME_NAME_LEN       =  14;
  SHARE_NAME_LEN        =  128;
  SMALL_STR_LEN         =  12;
  LONG_STR_LEN          =  60;

implementation

end.

---------- snip ---------- snip ---------- snip ----------

library XTension;

{ Author:   Michael Vincze  07/30/94                              }
{           vincze@lobby.ti.com                                   }
{           mav@asd470.dseg.ti.com                                }
{                                                                 }
{ The following File Manager extension is a translation from C.   }
{ The C code was taken from the Microsoft Product Support         }
{ Services, and obtained from the anonymous FTP site              }
{ ftp.microsoft.com with a file name of 4-23.zip.  The main       }
{ preamble of the original source has been preserved below.       }

(*
//***************************************************************************
//
//  Library:
//      XTENSION.DLL
//
//
//  Author:
//      Microsoft Product Support Services.
//
//
//  Purpose:
//      XTENSION is a File Manager extension DLL.  An extension DLL adds
//      a menu to File Manager, contains entry point that processes menu
//      commands and notification messages sent by File Manager, and
//      queries data and information about the File Manager windows.  The
//      purpose of an extension DLL is to add administration support
//      features to File Manager, for example, file and disk utilities.
//      Up to five extension DLLs may be instaled at any one time.
//
//      XTENSION adds a menu called "Extension" to File manager and
//      processes all the messages that are sent by File Manager to an
//      extension DLL.  In order to retrieve any information, it sends
//      messages to File Manager.  It also creates a topmost status window
//      using the DLL's instance handle.
//
//
//  Usage:
//      File Manager installs the extensions that have entries in the
//      [AddOns] section of the WINFILE.INI initialization file.  An entry
//      consists of a tag and a value.  To load XTENSION.DLL as a File
//      Manager extension, add the following to WINFILE.INI (assuming the
//      DLL resides in c:\win\system):
//
//      [AddOns]
//      SDK Demo Extension=c:\win\system\xtension.dll
//
//
//  Menu Options:
//      Following menu items belong to the "Extension" menu that is added
//      to File Manager:
//
//      Status Window               - Shows/Hides status window
//      Selected File(s) Size...    - Displays disk space taken by the files
//      Selected Drive Info...      - Displays selected drive information
//      Focused Item Info           - Displays the name of the focused item
//      Reload Extension            - Reloads this extension
//      Refresh Window              - Refreshes File Manager's active window
//      Refresh All Windows         - Refreshes all the File Manager's windows
//      About Extension...          - Displays About dialog
//
//
//  More Info:
//      Query on-line help on: FMExtensionProc, File Manager Extensions
//
//
// COPYRIGHT:
//
//   (C) Copyright Microsoft Corp. 1993.  All rights reserved.
//
//   You have a royalty-free right to use, modify, reproduce and
//   distribute the Sample Files (and/or any modified version) in
//   any way you find useful, provided that you agree that
//   Microsoft has no warranty obligations or liability for any
//   Sample Application Files which are modified.
//
//***************************************************************************
*)



{$D File Manager Extension DLL}

{$R XTENSION}

uses
  WinTypes,
  WinProcs,
  Win31,
  WFExt,
  Constant;

const
  gszDllWndClass    : PChar   = 'ExtenStatusWClass';  { Class name for status
window      }
  ghwndStatus       : HWND    = 0;                    { Status window          
          }
  ghwndInfo         : HWND    = 0;                    { Child window of status
window     }
  ghDllInst         : THANDLE = 0;                    { DLL's instance handle  
          }
  ghMenu            : HMENU   = 0;                    { Extension's menu handle
          }
  gwMenuDelta       : WORD    = 0;                    { Delta for extension's
menu items  }
  gbStatusWinVisible: BOOLEAN = FALSE;                { Flag for status window 
          }
                                                      {   FALSE=Hidden, 
TRUE=Visible     }

{ type to handle passing Longint types to wvsprintf
}
type
  TLongRec = record
    LO: WORD;
    HI: WORD;
    end;

procedure DisplayStatus (Handle: HWND; wEvent: Longint);
var
  wFileCount: Longint;
  szInfo    : array [0..INFO_STR_LEN] of CHAR;
  lFileCount: TLongRec;
begin
if gbStatusWinVisible = TRUE then
  begin
  case wEvent of

    FMEVENT_INITMENU:
      SetWindowText (ghwndInfo, 'Extension menu selected...');

    FMEVENT_SELCHANGE:
      begin
      wFileCount := SendMessage (Handle, FM_GETSELCOUNTLFN, 0, 0);
      lFileCount.LO := LOWORD (wFileCount);
      lFileCount.HI := HIWORD (wFileCount);
      wvsprintf (szInfo, 'File selection changed: %ld item(s) selected...',
lFileCount);
      SetWindowText (ghwndInfo, szInfo);
      end;

    FMEVENT_UNLOAD:
      SetWindowText (ghwndInfo, 'Unloading extension...');

    FMEVENT_USER_REFRESH:
      SetWindowText (ghwndInfo, 'Refreshing window(s)...');

    end;

  { Timer to erase the info after the elapsed time
  }
  SetTimer (ghwndStatus, ID_STATUSTIMER, TIMER_DURATION, nil);
  end;
end;



function StatusWndProc (hWin: HWND; uMessage: WORD; wParam: WORD; lParam:
Longint): Longint; export;
begin
case uMessage of

  WM_TIMER:
    { This timer is used to erase info from the
      status window at the elapsed time
    }
    if wParam = ID_STATUSTIMER then
      begin
      KillTimer (hWin, wParam);
      SetWindowText (ghwndInfo, '');
      end;

  else
    begin
    StatusWndProc := DefWindowProc (hWin, uMessage, wParam, lParam);
    exit;
    end;

  end;

StatusWndProc := 0;
end;







function CreateStatusWindow (hwndExtension: HWND): BOOLEAN;
var
  wc: TWNDCLASS;
begin
wc.style            := 0;
wc.lpfnWndProc      := @StatusWndProc;
wc.cbClsExtra       := 0;
wc.cbWndExtra       := 0;
wc.hInstance        := ghDllInst;
wc.hIcon            := LoadIcon (0, IDI_APPLICATION);
wc.hCursor          := LoadCursor (0, IDC_ARROW);
wc.hbrBackground    := COLOR_WINDOW + 1;
wc.lpszMenuName     := nil;
wc.lpszClassName    := gszDllWndClass;

if not RegisterClass (wc) then
  begin
  CreateStatusWindow := FALSE;
  exit;
  end;

ghwndStatus := CreateWindowEx (WS_EX_TOPMOST or WS_EX_DLGMODALFRAME,
                               gszDllWndClass,
                               'File Manager Extension',
                               WS_POPUP or WS_CAPTION,
                               CW_USEDEFAULT,
                               CW_USEDEFAULT,
                               STATUS_WIDTH,
                               STATUS_HEIGHT,
                               hwndExtension,
                               0,
                               ghDllInst,
                               nil);

ghwndInfo := CreateWindow ('STATIC',
                           nil,
                           WS_CHILD or WS_VISIBLE,
                           INFO_LINE_X,
                           INFO_LINE_Y,
                           INFO_LINE_WIDTH,
                           INFO_LINE_HEIGHT,
                           ghwndStatus,
                           1,
                           ghDllInst,
                           nil);

{ note I changed the logic from the original code below to return TRUE iff both
  windows got created.
}
CreateStatusWindow := (ghwndStatus <> 0) and (ghwndInfo <> 0);
end;




function DriveInfoDlgProc (hDlg: HWND; uMessage: WORD; wParam: WORD; lParam:
Longint): BOOLEAN; export;
var
  fmsDriveInfo: TFMS_GETDRIVEINFO;
  szTempString: array [0..SMALL_STR_LEN] of Char;
  lTotalSpace : TLongRec;
  lFreeSpace  : TLongRec;
begin

·
(continued next message)

─ Area: U-PASCAL      |61 ────────────────────────────────────────────────────
  Msg#: 6684                                         Date: 08-04-94  07:28
  From: Vincze@dseg.ti.com                           Read: Yes    Replied: No 
    To: All                                          Mark:                     
  Subj: [A] Windows File Manager
──────────────────────────────────────────────────────────────────────────────
@SUBJECT:[A] Windows File Manager Extension                           
·(Continued from last message)
case  uMessage of

  WM_INITDIALOG:

    begin
    SendMessage (lParam, FM_GETDRIVEINFO, 0, Longint (PFMS_GETDRIVEINFO
(@fmsDriveInfo)));

    { Convert OEM characters to Windows characters
    }
    OemToAnsi (fmsDriveInfo.szPath, fmsDriveInfo.szPath);
    OemToAnsi (fmsDriveInfo.szVolume, fmsDriveInfo.szVolume);

    if fmsDriveInfo.szShare[0] <> #0 then
      OemToAnsi (fmsDriveInfo.szShare, fmsDriveInfo.szShare)
    else
      lstrcpy (fmsDriveInfo.szShare, '< Not a Share >');

    if fmsDriveInfo.szVolume[0] <> #0 then
      SetDlgItemText (hDlg, IDD_VOLUME, fmsDriveInfo.szVolume)
    else
      SetDlgItemText (hDlg, IDD_VOLUME, '< No volume label >');

    SetDlgItemText (hDlg, IDD_PATH, fmsDriveInfo.szPath);
    SetDlgItemText (hDlg, IDD_SHARE, fmsDriveInfo.szShare);


    { When a -1 is returned for either dwTotalSpace or dwFreeSpace,
      the extension will have compute that number on its own.
    }
    if fmsDriveInfo.dwTotalSpace = -1 then
      SetDlgItemText (hDlg, IDD_TOTALSPACE, '< Info. not available >')
    else
      begin
      lTotalSpace.LO := LOWORD (fmsDriveInfo.dwTotalSpace);
      lTotalSpace.HI := HIWORD (fmsDriveInfo.dwTotalSpace);
      wvsprintf (szTempString, '%ld', lTotalSpace);
      SetDlgItemText (hDlg, IDD_TOTALSPACE, szTempString);
      end;

    if fmsDriveInfo.dwFreeSpace = -1 then
      SetDlgItemText (hDlg, IDD_FREESPACE, '< Info. not available >')
    else
      begin
      lFreeSpace.LO := LOWORD (fmsDriveInfo.dwFreeSpace);
      lFreeSpace.HI := HIWORD (fmsDriveInfo.dwFreeSpace);
      wvsprintf (szTempString, '%ld', lFreeSpace);
      SetDlgItemText (hDlg, IDD_FREESPACE, szTempString);
      end;

    DriveInfoDlgProc := TRUE;
    exit;
    end;

  WM_COMMAND:

    case wParam of

      IDOK,
      IDCANCEL:
        begin
        EndDialog (hDlg, 1);
        DriveInfoDlgProc := TRUE;
        exit;
        end;

      end;

  end;

DriveInfoDlgProc := FALSE;
end;





function SelFileInfoDlgProc (hDlg: HWND; uMessage: WORD; wParam: WORD; lParam:
Longint): BOOLEAN; export;
const
  fmsFileInfo  : TFMS_GETFILESEL = (wTime: 0);
var
  wSelFileCount: WORD;
  lSelFileCount: TLongRec;
  wIndex       : WORD;
  szTempString : array [0..SMALL_STR_LEN] of Char;
  dwTotalSize  : Longint;
  lTotalSize   : TLongRec;
begin
case uMessage of

  WM_INITDIALOG:
    begin
    wSelFileCount := SendMessage (lParam, FM_GETSELCOUNTLFN, 0, 0);
    lSelFileCount.LO := LOWORD (wSelFileCount);
    lSelFileCount.HI := HIWORD (wSelFileCount);
    wvsprintf (szTempString, '%ld', lSelFileCount);
    SetDlgItemText (hDlg, IDD_SELFILECOUNT, szTempString);
    dwTotalSize := 0;
    if wSelFileCount > 0 then
      for wIndex := 0 to wSelFileCount -1 do
        begin
        SendMessage (HWND (lParam), FM_GETFILESELLFN, wIndex, Longint
(PFMS_GETFILESEL (@fmsFileInfo)));
        Inc (dwTotalSize, fmsFileInfo.dwSize);
        end;
    lTotalSize.LO := LOWORD (dwTotalSize);
    lTotalSize.HI := HIWORD (dwTotalSize);
    wvsprintf (szTempString, '%ld bytes', lTotalSize);
    SetDlgItemText (hDlg, IDD_SELFILESIZE, szTempString);
    SelFileInfoDlgProc := TRUE;
    exit;
    end;

  WM_COMMAND:
    case wParam of

      IDOK,
      IDCANCEL:
        begin
        EndDialog (hDlg, 1);
        SelFileInfoDlgProc := TRUE;
        exit;
        end;

      end;

  end;
SelFileInfoDlgProc := FALSE;
end;




function AboutDlgProc (hDlg: HWND; uMessage: WORD; wParam: WORD; lParam:
Longint): BOOLEAN; export;
begin
case uMessage of

  WM_INITDIALOG:
    begin
    AboutDlgProc := TRUE;
    exit;
    end;

  WM_COMMAND:
    case wParam of

      IDOK,
      IDCANCEL:
        begin
        EndDialog (hDlg, 1);
        AboutDlgProc := TRUE;
        exit;
        end;

      end;

  end;
AboutDlgProc := FALSE;
end;



function FMExtensionProc (Handle: HWnd; Msg: WORD; var lParam: Longint): HMENU;
export;
var
  lpload      : PFMS_LOAD;
  lpDialogProc: TFARPROC;
  wFocusedItem: WORD;
begin

case Msg of

  { ****************** File Manager Events
  }

  FMEVENT_INITMENU:
    DisplayStatus (Handle, Msg);

  FMEVENT_LOAD:
    { Create status window
    }
    begin
    if ghwndStatus = 0 then
      begin
      if not CreateStatusWindow (Handle) then
        begin
        MessageBox (Handle,
          'Extension not loaded.  Status window creation error.',
          'File Manager Extension', MB_OK or MB_ICONASTERISK);

        { Unload
        }
        end;
      end;

    lpload := @lParam;

    { Assign the menu handle from the DLL's resource
    }
    ghMenu := LoadMenu (ghDllInst, 'ExtensionMenu');

    lpload^.Menu := ghMenu;

    { This is the delta we are being assigned.
    }
    gwMenuDelta := lpload^.wMenuDelta;

    { Size of the load structure
    }
    lpload^.dwSize := sizeof (TFMS_LOAD);

    { Assign the popup menu name for this extension
    }
    lstrcpy (lpload^.szMenuName, '&Extension');

    MessageBox (Handle, 'File Manager Extension will be loaded.',
      'File Manager Extension', MB_OK);

    { Return that handle
    }

    FMExtensionProc := ghMenu;
    exit;
    end;

  FMEVENT_SELCHANGE:
    DisplayStatus (Handle, Msg);

  FMEVENT_UNLOAD:
    begin
    DisplayStatus (Handle, Msg);
    MessageBox (Handle, 'File Manager Extension will be unloaded.',
      'File Manager Extension', MB_OK);

    { Since the status window was created using DLL's
      instance handle, we will have to destroy it on our own.
    }
    DestroyWindow (ghwndStatus);
    end;

  FMEVENT_USER_REFRESH:
    DisplayStatus (Handle, Msg);


  { ****************** Extension menu commands
  }

  IDM_STATUSWIN:
    begin
    if GetMenuState (ghMenu, gwMenuDelta + Msg, MF_BYCOMMAND) and MF_CHECKED >
0 then
      begin
      gbStatusWinVisible := FALSE;

      { Hide the status window
      }
      ShowWindow (ghwndStatus, SW_HIDE);

      { Remove the checkmark
      }
      CheckMenuItem (ghMenu, gwMenuDelta + IDM_STATUSWIN, MF_UNCHECKED or
MF_BYCOMMAND);

      end
    else
      begin
      gbStatusWinVisible := TRUE;

      { Show the status window
      }
      ShowWindow (ghwndStatus, SW_SHOW);

      { Add the checkmark
      }
      CheckMenuItem (ghMenu, gwMenuDelta + IDM_STATUSWIN, MF_CHECKED or
MF_BYCOMMAND);
      end;
    end;

  IDM_GETDRIVEINFO:
    begin
    lpDialogProc := @DriveInfoDlgProc;
    DialogBoxParam (ghDllInst, 'DriveInfo', Handle, lpDialogProc, Handle);
    end;

  IDM_GETFILESELLFN:
    begin
    lpDialogProc := @SelFileInfoDlgProc;
    DialogBoxParam (ghDllInst, 'FileInfo', Handle, lpDialogProc, Handle);
    end;

  IDM_GETFOCUS:
    begin
    wFocusedItem := SendMessage (Handle, FM_GETFOCUS, 0, 0);

    case wFocusedItem of
      FMFOCUS_DIR:
        MessageBox (Handle, 'Focus is on the DIRECTORY window.',
          'Focus Information', MB_OK);

      FMFOCUS_TREE:
        MessageBox (Handle, 'Focus is on the TREE window.',
          'Focus Information', MB_OK);

      FMFOCUS_DRIVES:
        MessageBox (Handle, 'Focus is on the DRIVE bar.',
          'Focus Information', MB_OK);

      FMFOCUS_SEARCH:

        MessageBox (Handle, 'Focus is on the SEARCH RESULTS window.',
          'Focus Information', MB_OK);

      end;

    end;

  IDM_REFRESHWINDOW,
  IDM_REFRESHALLWINDOWS:
    { Refresh one or all the windows
    }
    begin
    if Msg = IDM_REFRESHALLWINDOWS then
      SendMessage (Handle, FM_REFRESH_WINDOWS, 1, 0)
    else
      SendMessage (Handle, FM_REFRESH_WINDOWS, 0, 0);
    end;

  IDM_RELOADEXTENSIONS:
    PostMessage (Handle, FM_RELOAD_EXTENSIONS, 0, 0);

  IDM_ABOUTEXT:
    begin
    lpDialogProc := @AboutDlgProc;
    DialogBox (ghDllInst, 'AboutExtension', Handle, lpDialogProc);
    end;

  end;

FMExtensionProc := 0;
end;

exports
  FMEXTENSIONPROC;

begin
ghDllInst := hInstance;
end.


·
(continued next message)

─ Area: U-PASCAL      |61 ────────────────────────────────────────────────────
  Msg#: 6685                                         Date: 08-04-94  07:28
  From: Vincze@dseg.ti.com                           Read: Yes    Replied: No 
    To: All                                          Mark:                     
  Subj: [A] Windows File Manager
──────────────────────────────────────────────────────────────────────────────
@SUBJECT:[A] Windows File Manager Extension                           
·(Continued from last message)
---------- snip ---------- snip ---------- snip ----------



#include "constant.pas"

ExtensionIcon   ICON    xtension.ico


ExtensionMenu MENU
BEGIN
  MENUITEM    "&Status Window",           IDM_STATUSWIN
  MENUITEM    SEPARATOR
  MENUITEM    "Selected &File(s) Size...",IDM_GETFILESELLFN
  MENUITEM    "Selected &Drive Info...",  IDM_GETDRIVEINFO
  MENUITEM    "Focused &Item Info...",    IDM_GETFOCUS
  MENUITEM    SEPARATOR
  MENUITEM    "Reload &Extension",        IDM_RELOADEXTENSIONS
  MENUITEM    "&Refresh &Window",          IDM_REFRESHWINDOW
  MENUITEM    "Refresh All &Windows",      IDM_REFRESHALLWINDOWS
  MENUITEM    SEPARATOR
  MENUITEM    "&About Extension...",      IDM_ABOUTEXT
END

FileInfo DIALOG 22, 17, 144, 71
STYLE DS_MODALFRAME | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU
CAPTION "Selected File Information"
FONT 8, "Helv"
BEGIN
  CONTROL "OK", IDOK, "BUTTON", WS_GROUP, 56, 49, 32, 14
  LTEXT "File(s) selected:", -1, 10, 7, 64, 8
  LTEXT "Disk space taken:", -1, 10, 20, 64, 8
  LTEXT " ", IDD_SELFILECOUNT, 77, 7, 56, 8
  LTEXT " ", IDD_SELFILESIZE, 77, 20, 56, 8
END

AboutExtension DIALOG 8, 21, 237, 215
STYLE DS_MODALFRAME | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU
CAPTION "About Extension"
FONT 8, "Helv"
BEGIN
  ICON "ExtensionIcon", -1, 5, 5, 16, 21
  LTEXT "File Manager Extension DLL", -1, 34, 5, 150, 8
  LTEXT "Version 1.0", -1, 34, 15 150, 8
  LTEXT "Copyright \251 Microsoft Corp., 1992", -1, 34, 25, 150, 8
  LTEXT "A File Manager extension is a Windows DLL that adds a menu to", -1, 5,
40, 232, 8
  LTEXT "File Manager, contains entry point that processes menu commands", -1,
5, 50, 232, 8
  LTEXT "and notification messages sent by File Manager, and queries data", -1,
5, 60, 232, 8
  LTEXT "and information about the File Manager windows.", -1, 5, 70, 232, 8
  LTEXT "Menu Options:", -1, 5, 85, 237, 8
  LTEXT "Status Window\t\t- Shows/Hides status window", -1, 5, 98, 230, 8
  LTEXT "Selected File(s) Size...\t- Displays disk space taken by the files",
-1, 5, 108, 230, 8
  LTEXT "Selected Drive Info...\t- Displays selected drive information", -1, 5,
118, 230, 8
  LTEXT "Focused Item Info...\t- Displays the name of the focused item", -1, 5,
128, 230, 8
  LTEXT "Reload Extension\t- Reloads this extension", -1, 5, 138, 230, 8
  LTEXT "Refresh Window\t- Refreshes File Manager's active window", -1, 5, 148,
230, 8
  LTEXT "Refresh All Windows\t- Refreshes all the File Manager's windows", -1,
5, 158, 230, 8
  LTEXT "About Extension...\t- Displays this dialog", -1, 5, 168, 230, 8
  CONTROL "OK", IDOK, "BUTTON", WS_GROUP, 101, 190, 32, 14
END



DriveInfo DIALOG 22, 17, 188, 85
STYLE DS_MODALFRAME | WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU
CAPTION "Selected Drive Information"
FONT 8, "Helv"
BEGIN
  CONTROL "OK", IDOK, "BUTTON", WS_GROUP, 77, 65, 32, 14
  LTEXT "Path:", -1, 7, 6, 46, 8
  LTEXT "Volume:", -1, 7, 16, 46, 8
  LTEXT "Share:", -1, 7, 26, 46, 8
  LTEXT "Total KBs:", -1, 7, 36, 46, 8
  LTEXT "Free KBs:", -1, 7, 46, 46, 8
  LTEXT " ", IDD_PATH, 61, 6, 120, 8
  LTEXT " ", IDD_VOLUME, 61, 16, 120, 8
  LTEXT " ", IDD_SHARE, 61, 26, 120, 8
  LTEXT " ", IDD_TOTALSPACE, 61, 36, 120, 8
  LTEXT " ", IDD_FREESPACE, 61, 46, 120, 8
END

---------- snip ---------- snip ---------- snip ----------



begin 755 icon.zip
M4$L#!!0    ( "IC;!E>O+@&9@$  #X$   ,    6%1%3E-)3TXN24-/K9,]
M;H- $(4'B!4D%\X-0A6E1.( ^!2IJ;B!:V]E(5ERKD))EST*E447I"B1"\>;
M-[,_%I:C1%$>/-8SWWH81D 444Q9%A,KCX@>L&;9G<0#TD_(/7(.7A+OCX3Y
MY5+&F/ [,4=4GU%LWA6LQ?U*QZ\KN_H<S71B/F4-N1_VH@$=F9/&#9>T-NJB
M!W.@"";V&B[A^__V$3[!AJU@I^F\;J0G%5^?%XB<I)1=^. 4+EIK?AHY\5!V
MX<-,Y_R=YELK-;"(4I=O^49-1?/28K4_#/U04UIVK+;=G':JJ2MPW(;YF()7
MX$F1,Q\]1RQ\<!R%)]S5]_^7\8RA?B'*U1Y)YIU5NZGKBKF?D/0O]6U_4N9<
MOTF9?S!'OFN[? <]A_Z:0C:,OO^NR.U\RBVNS&WLZY^Y[3=PUV_@;KZ>+_P+
MX&)R?/OF8O^ +RX.&T;ZBXQ]"1;P+7]NWW^5OU5BKEG!&N[A$?;Z E!+ 0(4
M !0    ( "IC;!E>O+@&9@$  #X$   ,            (         !85$5.
>4TE/3BY)0T]02P4&      $  0 Z    D $     
 
end

---------- END ---------- END ---------- END ---------- END ----------

