
(*
  The intent of this program is to provide the ability to add additional functionality
  to WinCRT.  Like the ablity to add and use a menubar and to be able to respond to
  mouse clicks.      WinCRT does NOT need to be modified to run this app.

  This program is Public Domain by Cedar Island Software. Use it as you see fit.
  All the usual disclaimers apply.

  Thanks to Neil Rubenking and his book 'Turbo Pascal for Windows Techniques and Utilities'.
  Thanks to Kurt Barthlemess of BPASCAL (TeamB).
  Thanks also to Paul A. LeBlanc of BCPPWIN (TeamB).


  Good Luck and Have Fun.
  Mike Caughran
  Cedar Island Software
  [71034,2371]
*)

program HookCRT;
uses WinCRT, WinTypes, WinProcs;
var
  OldCRTProc : TFarProc;
  NewCRTProc : TFarProc;
  ps         :  TPaintStruct;
  appIcon    :  hIcon;
const
  hHookedWnd : HWND = 0;
  cm_Exit    = 100;
  cm_About   = 101;

function ShellAbout(hwnd:HWND; Title,Text:PChar; icon:HICON):integer; external 'SHELL' index 22;
procedure MyDoneWinCRT; forward;

function NewMsgHandler(Window : HWnd; Message : Word;
                       wParam : Word; lParam : LongInt) : LongInt; export;
begin
  case Message of
    wm_char        : MessageBeep(0);
    wm_LButtonDown : MessageBox(0,'Left button','Mouse',MB_OK);
    wm_Command     : begin
      case WParam of
	cm_About:   ShellAbout(0,'Hooked CRT#Public Domain by Cedar Island Software','', appIcon);
	cm_Exit:    MyDoneWinCRT;
      end;
    end;
  end;
  NewMsgHandler := CallWindowProc(OldCRTProc, Window, Message, wParam, lParam);
end;

procedure FindWindowHandle;
begin
  ClrScr;   {force active window}
  hHookedWnd := GetActiveWindow;
end;

procedure myInitWinCRT;
var
  Menu      : HMenu;
  FileMenu  : HMenu;
begin
  cmdShow := sw_ShowNormal;
  InitWinCrt;
  FindWindowHandle;
  OldCRTProc := TFarProc(GetWindowLong(hHookedWnd, gwl_WndProc));
  NewCrtProc := MakeProcInstance(@NewMsgHandler, hInstance);
  SetWindowLong(hHookedWnd, gwl_WndProc, LongInt(NewCrtProc));
  Menu := CreateMenu;
  FileMenu := CreateMenu;
  AppendMenu(Menu, mf_PopUp or mf_Enabled, FileMenu, 'File');
  AppendMenu(FileMenu, mf_Enabled, cm_Exit, 'Exit');
  AppendMenu(Menu, mf_Enabled, cm_About, 'About');
  SetMenu(hHookedWnd,Menu);
  SetWindowText(hHookedWnd,'Test Sub-Classed WinCRT');
  appIcon:=LoadIcon(0,IDI_Exclamation);
  SetClassWord(hHookedWnd,gcw_hIcon, appIcon);
end;

procedure myDoneWinCrt;
begin
  DoneWinCrt;
  FreeProcInstance(NewCrtProc);
end;

procedure DoTest;
var
  Name    : String;
begin
  LoadString(GetModuleHandle('USER'),514,@Name[1],79);
  Name[0]:=Char(LStrLen(@Name[1]));
  Writeln('Hello ',Name);
  Writeln('Welcome to Subclassed WinCRT World!');
  readln;
end;

begin
  myInitWinCrt;
  DoTest;
  myDoneWinCrt;
end.