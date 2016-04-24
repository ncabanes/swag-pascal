(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0092.PAS
  Description: MDI Template
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)

program MDITemplate;
{$X+,S+,R+}
{$B-}   {*** This compiler directive should stay ***}
{$R MDIPLATE}

{ the res file contains this :

MDIMENU MENU
BEGIN
	POPUP "MDI Children"
	BEGIN
		MENUITEM "Create", 24339
		MENUITEM "&Cascade", 24337
		MENUITEM "&Tile", 24336
		MENUITEM "Arrange &Icons", 24335
		MENUITEM "C&lose All", 24338
	END

END

}

uses WinTypes, WinProcs, OWindows, ODialogs, Strings;

type
  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    function ProcessAppMsg(var Message: TMsg): Boolean; virtual;
    procedure InitMainWindow;  virtual;
  end;

  PMyMDIWin = ^TMyMDIWin;
  TMyMDIWin = object(TMDIWindow)
    function InitChild: PWindowsObject; virtual;
    procedure InitClientWindow; virtual;
  end;

  PMyMDIChild = ^TMyMDIChild;
  TMyMDIChild = object(TWindow)
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    procedure wmMDIActivate(var Msg: TMessage);
      virtual wm_First + wm_MDIActivate;
    procedure wmSetFocus(var Msg: TMessage);
      virtual wm_First + wm_SetFocus;
  end;

  PMyClient = ^TMyClient;
  TMyClient = object(TMDIClient)
  end;

function TMyApp.ProcessAppMsg(var Message: TMsg): Boolean;
begin
  ProcessAppMsg :=
    ProcessMDIAccels(Message) or
    ProcessAccels(Message) or
    ProcessDlgMsg(Message);
end;

procedure TMyMDIChild.wmMDIActivate(var Msg: TMessage);
begin
  Application^.SetKBHandler(@Self);
  DefWndProc(Msg);
end;

procedure TMyMDIChild.wmSetFocus(var Msg: TMessage);
begin
  Application^.SetKBHandler(@Self);
  DefWndProc(Msg);
end;

constructor TMyMDIChild.Init(AParent: PWindowsObject; ATitle: PChar);
var
  PB: PButton;
begin
  TWindow.Init(AParent, Atitle);
  EnableKBHandler;
  PB :=new(PButton, init(@self, 200, 'OK', 10, 10, 100, 40, false));
  PB :=new(PButton, init(@self, 201, 'Not OK', 10, 60, 100, 40, false));
end;

function TMyMDIWin.InitChild: PWindowsObject;
begin
  InitChild := new(PMyMDIChild, Init(@self, 'Untitled Window'));
end;

procedure TMyMDIWin.InitClientWindow;
begin
  ClientWnd := new(PMyClient, init(@self));
end;

procedure TMyApp.InitMainWindow;
begin
  MainWindow := new(PMyMDIWin, Init('MDI Demo',
                    LoadMenu(HInstance, 'MDIMenu')));
end;

var
  MyApp: TMyApp;

begin
  MyApp.Init('MyApp');
  MyApp.Run;
  MyApp.Done;
end.

