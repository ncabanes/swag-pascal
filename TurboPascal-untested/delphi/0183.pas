{
I have just extended some PD sources (in this month's SWAG - HOOKCRT.PAS) to
convert it to a unit, with supporting Pascal Object and Delphi Class. This
hooks into the WinCRT unit (BPW and Delphi 1.x) to add menus, etc. A sample
program is included. You might wish to add this to the SWAG archives.
Thanks.

------------------------------ cut ------------------------------ }
Unit HookCrt2;

{ ----- ORIGINAL MESSAGE ---
  The intent of this program is to provide the ability to add additional functionality
  to WinCRT.  Like the ablity to add and use a menubar and to be able to respond to
  mouse clicks.

  WinCRT does NOT need to be modified to run this app.

  This program is Public Domain by Cedar Island Software. Use it as you see fit.
  All the usual disclaimers apply.

  Thanks to Neil Rubenking and his book 'Turbo Pascal for Windows Techniques and Utilities'.
  Thanks to Kurt Barthlemess of BPASCAL (TeamB).
  Thanks also to Paul A. LeBlanc of BCPPWIN (TeamB).


  Good Luck and Have Fun.
  Mike Caughran
  Cedar Island Software
  [71034,2371]

  ---- ADDED MESSAGE by Dr A Olowofoyeku ------
  September 1996
  Amended and Extended by Dr A Olowofoyeku (The African Chief);
   [a] converted to a unit
   [b] a Pascal object (and Delphi Class) to encapsulate the
       unit's functionality.
   [c] some default procedural types and functions
   [d] MyInitWinCRT changed to: HookedInitWinCRT - and now
       takes some parameters
   [e] MyDoneWinCRT changed to: HookedDoneWinCrt;
   [f] supports Delphi 1.x

  Enjoy!

  THIS UNIT IS PUBLIC DOMAIN -
  NOTHING IS WARRANTEED. USE AT YOUR OWN RISK!

  Dr A. Olowofoyeku (The African Chief)
  Email: laa12@cc.keele.ac.uk
  http://ourworld.compuserve.com/homepages/African_Chief/
}

Interface
{$ifdef Ver80}     {Delphi 1.x}
   {$Define Delphi}
{$endif Ver80}

uses {$ifndef Delphi}Objects {$else}Messages{$endif},WinCRT, WinTypes, WinProcs;

{/////////////////////////////////////////////////////////////}
{////////////// exported data and functions //////////////////}
{/////////////////////////////////////////////////////////////}
{custom icon for CRT window}
  Var
  CrtappIcon : hIcon;

{  User menu command tags (identifiers)
   start from 1 to 64 for CRT menu tags
}
  Const
  cm_User1   = 1;
  cm_UserMax = 64;

{Crt Window function type}
Type
aWindowFunc = Function(Window : HWnd; Message : Word;
                       wParam : Word; lParam : LongInt) : LongInt;

{menu command procedural type}
aMenuFunc   = Procedure(Const aTag:integer);


{create a CRT window}
Function  HookedInitWinCRT(
Const
Left,                 {left side of the window}
Top,                  {top of the window}
width,                {width of the window}
height:integer;       {height of the window}
Title :pChar ;        {window title}
aWinProc:aWindowFunc; {new window function, or Nil for default}
MenuFunc:aMenuFunc    {new window procedure, or Nil for default}
):HWnd;                 {returns the handle to the CRT window}

{destroy a CRT window}
Function HookedDoneWinCRT : Boolean;

{/////////////////////////////////////////////////////////////}
{///////////////////// CRT object ////////////////////////////}
{// This object encapsulates the functionality of this unit //}
{/////////////////////////////////////////////////////////////}
{/////////////////////////////////////////////////////////////}
Type
TNewCrtClass = {$ifdef Delphi}Class{$else}Object(TObject){$endif}
   HWindow : HWnd; {handle of the CRT window}

   Constructor {$ifdef Delphi}Create{$else}Init{$endif}
   {init constructor - calls HookedInitWinCRT with all these
   parameters, to create the CRT window}
   (Const
   Left,                 {left side of the window}
   Top,                  {top of the window}
   width,                {width of the window}
   height:integer;       {height of the window}
   Title :pChar ;        {window title}
   aWinProc:aWindowFunc; {new window function, or Nil for default}
   MenuFunc:aMenuFunc    {new window procedure, or Nil for default}
   );

   Destructor {$ifDef Delphi}Destroy;override{$else}Done; virtual{$endif};

   Procedure   MakeMainMenu(Caption:pChar;Tag:integer);virtual;
   {create a main menu item = e.g., File Menu, Edit, etc.
   Caption = the title of the menu
   Tag     = the command tag
   }

   Procedure   MakeSubMenu(ParentNum:Byte;Caption:pChar;Tag:integer);virtual;
   {create a submenu under the main menu "parentnum"
   ParentNum = the numeric ID of the parent main menu
   Caption = the title of the menu
   Tag     = the command tag
   }
   Procedure   MakeSeparator(ParentNum:Byte);virtual;
   {create a menu separator under the main menu "parentnum"
   ParentNum = the numeric ID of the parent main menu
   }

   Procedure   AssignCRTMenu;virtual;
   {assign the menu to the CRT window and repaint the menu;
   MUST be called at some stage - normall AFTER all the menu
   items have been create.}

   Private
     MainMenus : Array[0..32] of HMenu; {max 32 main MainMenus}
     MenuCount : Word; {number of main MainMenus created}
end;{end of CRT object}
{////////////////////////////////////////////////}
Var
  OldCRTProc   : TFarProc;{pointer to old window function}
  NewCRTHandle : HWND;  {handle to CRT window}

implementation

var
  NewCRTProc : TFarProc; {pointer to new window function}

Var
DefMenuFunc:aMenuFunc;{menu command function}

{////////////////////////////////////////////////}
function NewDefaultMsgHandler(Window : HWnd; Message : Word;
{default message handler - if none is specified in call to
HookedInitWinCRT}
wParam : Word; lParam : LongInt) : LongInt; export;
begin
  case Message of
    wm_Command  : begin
      case WParam of
        cm_User1 .. cm_UserMax:
        If @DefMenuFunc<> Nil then DefMenuFunc(WParam);
      end;
    end;
  end;
  NewDefaultMsgHandler := CallWindowProc(OldCRTProc, Window, Message, wParam, lParam);
end;
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
Constructor TNewCrtClass.{$ifdef Delphi}Create{$else}Init{$endif};
Begin
   Inherited {$ifdef Delphi}Create;{$else}Init;{$endif}
   HWindow := HookedInitWinCrt
   (Left,Top,width,height,Title,aWinProc,MenuFunc);

   FillChar(MainMenus, Sizeof(MainMenus), #0);
   MainMenus[0] := CreateMenu;
   MenuCount := 0;
End;
{////////////////////////////////////////////////}
Destructor TNewCrtClass.{$ifDef Delphi}Destroy{$else}Done{$endif};
Begin
    FillChar(MainMenus, Sizeof(MainMenus), #0);
    MenuCount := 0;
    HWindow   := 0;
    HookedDoneWinCRT;
   {$ifdef Delphi}
    Inherited Destroy;
   {$else}
    Inherited Done;
   {$endif}
End;
{////////////////////////////////////////////////}
Procedure TNewCrtClass.MakeMainMenu;
Begin
   If MenuCount>=32 then Exit;
   If Tag > 0 then AppendMenu(MainMenus[0], mf_Enabled, Tag, Caption)
   else begin
     Inc(MenuCount);
     MainMenus[MenuCount] := CreateMenu;
     AppendMenu(MainMenus[0], mf_PopUp or mf_Enabled, MainMenus[MenuCount], Caption);
   end;
End;
{////////////////////////////////////////////////}
Procedure TNewCrtClass.MakeSubMenu;
Begin
  If (ParentNum<1) or (ParentNum>32) then exit;
  AppendMenu(MainMenus[ParentNum], mf_Enabled, Tag, Caption);
End;
{////////////////////////////////////////////////}
Procedure TNewCrtClass.MakeSeparator;
Begin
  If (ParentNum<1) or (ParentNum>32) then exit;
  AppendMenu(MainMenus[ParentNum], mf_Separator,0, '');
End;
{////////////////////////////////////////////////}
Procedure TNewCrtClass.AssignCRTMenu;
Begin
  SetMenu(HWindow,MainMenus[0]);
End;
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
function  GetCRTWindowHandle: HWnd;
{return handle to the CRT window}
begin
  ClrScr;   {force active window}
  GetCRTWindowHandle := GetActiveWindow;
end;
{////////////////////////////////////////////////}
Procedure GetScreenResolution(Var aTPoint : TPoint);
{get the current screen resolution and return it in "T"}
Var
HD : HDC;
Wn : HWnd;
Begin
   Wn := GetDesktopWindow;
   Hd := GetDC(Wn);
   With aTPoint do begin
     X := GetDeviceCaps(Hd, HorzRes);
     Y := GetDeviceCaps(Hd, VertRes);
   End;
   ReleaseDC(Wn, Hd);
End;
{////////////////////////////////////////////////}
Procedure SetWindowCoordinates;
{set up CRT window for possible scrolling}
Var
aPoint : tpoint;
aReal  : real;
anInt  : integer;

Begin
   GetScreenResolution(aPoint);

   With aPoint do
   begin
      aReal := Y /25;
      If y >  768 then aReal := (aReal*13.2) else
      If Y >= 600 then aReal := (aReal*15.8) else
      aReal := (aReal*18.4);

      anInt := round(aReal + 25);
      WindowSize.Y := anInt;

      If X > 800 then anInt := 11 else anInt := 10;
      WindowSize.X := (ScreenSize.X * anInt);
   end;
End;
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}

Function  HookedInitWinCRT;
{initialise the new crt stuff}
Begin
  {window location coordinates}
  With WindowOrg do begin
     x := Left;
     y := Top;
  end;

 {the size of the CRT window buffer}
  With ScreenSize do begin
     x := Width;
     y := Height;
  end;

  {setup the window properly}
  SetWindowCoordinates;

  {set window title}
  lStrCpy(WindowTitle, Title);

  {call WinCRT.InitWinCRT}
  InitWinCrt;

 {get the CRT window handle}
  NewCRTHandle := GetCRTWindowHandle;
  {SetWindowText(NewCRTHandle, Title);}

  {save old window proc}
  OldCRTProc := TFarProc(GetWindowLong(NewCRTHandle, gwl_WndProc));

  {assign new window proc}
  If @aWinProc<>Nil then
  NewCrtProc := MakeProcInstance(@aWinProc, hInstance)
  else
  NewCrtProc := MakeProcInstance(@NewDefaultMsgHandler, hInstance);

  {make it happen!}
  SetWindowLong(NewCRTHandle, gwl_WndProc, LongInt(NewCrtProc));

  {assign CRT menu proc}
  If @MenuFunc <> Nil then DefMenuFunc := MenuFunc;

  {if custom icon used, assign it}
  If CrtappIcon<>0 then
  SetClassWord(NewCRTHandle, gcw_hIcon, CrtappIcon);

 {return handle of CRT window}
  HookedInitWinCRT := NewCRTHandle;
End;
{////////////////////////////////////////////////}
Function  HookedDoneWinCRT;
{dispose of the new crt window}
begin
  DoneWinCrt; {call WinCRT.DoneWinCrt}
  HookedDoneWinCRT:=True;

  {do other stuff}
  CrtappIcon := 0;
  NewCRTHandle:=0;
  FreeProcInstance(NewCrtProc);
  DefMenuFunc := Nil;
end;
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{///////// initialisation block /////////////////}
{////////////////////////////////////////////////}
begin
   CrtappIcon   := 0;
   NewCRTHandle := 0;
   DefMenuFunc  := Nil;
end.
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{// TEST PROGRAM: shows usage of HOOKCRT2.PAS ///}
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
Program TestCRT;
{$ifdef Ver80}
   {$Define Delphi}
{$endif Ver80}

uses {$ifdef Delphi}Messages,{$endif}WinTypes,
WinProcs, HookCrt2, WinCrt;

  {menu constants: start from 1 - to infinity}
  Const
  cm_Exit    = 1;
  cm_About   = 2;
  cm_Clear   = 3;

Var
TestCrtObj : TNewCrtClass;

{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
Procedure ExecMenus(Const Tag:Integer);forward;
{a sample procedure to process menu choices}

function  ShellAbout(hwnd:HWND; Title,Text:PChar; icon:HICON):integer; external 'SHELL' index 22;
{an "About" function}
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
function TestProc(Window : HWnd; Message : Word;
wParam : Word; lParam : LongInt) : LongInt; export;
{sample new menu handler}
begin
  case Message of
    wm_char        : begin {MessageBeep(0);} end;
    wm_LButtonDown : MessageBox(NewCrtHandle,'Left button','Mouse',MB_OK);
    wm_Command     : begin
      case WParam of
        cm_User1 .. cm_UserMax: ExecMenus(WParam);
      end;
    end;
  end;

  {call the old window proc = essential!}
  TestProc := CallWindowProc(OldCRTProc, Window, Message, wParam, lParam);
end;
{////////////////////////////////////////////////}
Procedure ExecMenus(Const Tag:Integer);
Begin
  Case Tag of
     cm_About:
     ShellAbout(NewCrtHandle,'Hooked CRT#Cedar Island Software & The Chief','Hello World, from the Chief!',
                  CrtappIcon);
     cm_Exit:
           TestCrtObj.{$ifDef Delphi}Free{$else}Done{$endif};
     {HookedDoneWinCRT;}
     cm_Clear: begin clrscr; gotoxy(1,1); end;
  End;
End;
{////////////////////////////////////////////////}
procedure DoTest;
var
  Name    : String;
begin
  LoadString(GetModuleHandle('USER'),514,@Name[1],79);
  Name[0]:=Char(LStrLen(@Name[1]));
  Writeln('Hello ',Name);
  Writeln('Welcome to a Subclassed WinCRT World!');
  readln;
end;
{////////////////////////////////////////////////}
{////////////////////////////////////////////////}
{//////////// program block  ////////////////////}
begin
   TestCrtObj{$ifdef Delphi}:= TNewCrtClass.Create{$else}.Init{$endif}
   (1,1,80,25,'Chief''s Hooked CRT Window',TestProc,ExecMenus);

    With TestCrtObj do begin
     MakeMainMenu('&File ', 0);
       MakeSubMenu(1, '&New', 0);
       MakeSubMenu(1, '&Open...', 0);
       MakeSubMenu(1, '&Save', 0);
       MakeSubMenu(1, 'Save &As ...', 0);
       MakeSeparator(1);
       MakeSubMenu(1,'E&xit', cm_Exit);

     MakeMainMenu('&Edit ', 0);
       MakeSubMenu(2,'Cu&t    Shift+Del', 0);
       MakeSubMenu(2,'&Copy   Ctrl+Ins', 0);
       MakeSubMenu(2, '&Paste Shift+Ins', 0);
       MakeSubMenu(2, 'C&lear Ctrl+Del', cm_Clear);
       MakeSeparator(2);
       MakeSubMenu(2,'E&xit', cm_Exit);

     MakeMainMenu('&Help ', 0);
       MakeSubMenu(3,'&Contents  Shift+F1', 0);
       MakeSubMenu(3,'&Topic Search', 0);
       MakeSubMenu(3,'&Using Help', 0);
       MakeSeparator(3);
       MakeSubMenu(3,'&About ...', cm_About);
       MakeSeparator(3);
       MakeSubMenu(3,'E&xit', cm_Exit);

       AssignCrtMenu; {this MUST be called after creating all menus!!}

       DoTest;  {call a test procedure}

       {dispose of object and CRT window}
       {$ifDef Delphi}Free{$else}Done{$endif};
   end;
end.


[----------------------- end cut ------------------------]
Warmest regards,
The Chief
---------
Dr. Abimbola A. Olowofoyeku  (The African Chief)
Keele University, England    (and, The Great Elephant)
Email: laa12@keele.ac.uk      or,  chief@mep.com
http://ourworld.compuserve.com/homepages/African_Chief/chief.htm
