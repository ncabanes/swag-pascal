(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0011.PAS
  Description: OOP-WIND.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
     I'm still rather new (hence unexperienced) to this development
environment. Since the number of users of the Pascal For Windows product
is very limited in Belgium, I have little opportUnity to exchange ideas
and talk about problems. ThereFore, I dare to ask the following question
directly on the US-BBS.

     I contacted Borland Belgium With the following question:
Is it possible to create an MDI-Interface, which consists of TDlgWindow's
(Even of different Types of DialogWindows).
The Program printed below was their answer. However, possibly because of
my limited experience in the field, this Program does not seem to work on
my Computer running the Borland Pascal 7.0 .

     Could someone explain why the Program below does not create dialog-
Windows as MDI client Windows of the main MDI Window (when I select the
"create"-menu element), but instead only normal client Windows.
}

{********************************************************}
{   MDI - Programm of TDlgWindow - ChildWindows          }
{                                                        }
{   This is an adapted version of the Borland demo       }
{   Programm  MDIAPP.PAS of Borland Pascal 7.0           }
{********************************************************}
Program MDI;
{$R MDIAPP.RES}
Uses
  WinTypes, WinProcs, Strings, OWindows, ODialogs;

Type
  { Define a TApplication descendant }
  TMDIApp = Object(TApplication)
    Procedure InitMainWindow; Virtual;
  end;

  PMyMDIChild = ^TMyMDIChild;
  TMyMDIChild = Object(TDlgWindow)
    Num : Integer;
    CanCloseCheckBox : PCheckBox;
    Constructor Init(AParent: PWindowsObject; AName: PChar);
    Procedure SetupWindow; Virtual;
    Function CanClose: Boolean; Virtual;
  end;

  PMyMDIWindow = ^TMyMDIWindow;
  TMyMDIWindow = Object(TMDIWindow)
    Procedure SetupWindow; Virtual;
    Function CreateChild: PWindowsObject; Virtual;
  end;

  {**********************  MDI Child  ************************}
  Constructor TMyMDIChild.Init(AParent: PWindowsObject; AName: PChar);
  begin
    inherited Init(AParent, AName);
    New(CanCloseCheckBox, Init(@Self, 102, 'Can Close',
                               10, 10, 200, 20, nil));
  end;

  Procedure TMyMDIChild.SetupWindow;
  begin
    inherited SetupWindow;
    CanCloseCheckBox^.Check;
    ShowWindow(HWindow, CmdShow);
  end;

  Function TMyMDIChild.CanClose;
  begin
    CanClose := CanCloseCheckBox^.GetCheck = bf_Checked;
  end;

  {*****************  MDI Window  ******************}
  Procedure TMyMDIWindow.SetupWindow;
  Var
    NewChild : PMyMDIChild;
  begin
    inherited SetupWindow;
    CreateChild;
  end;

  Function TMyMDIWindow.CreateChild: PWindowsObject;
  begin
    CreateChild := Application^.MakeWindow(New(PMyMDIChild,
                                           Init(@Self, PChar(1))));
  end;

Procedure TMDIApp.InitMainWindow;
begin
  MainWindow := New(PMDIWindow, Init('MDI ConFormist',
                                LoadMenu(HInstance, 'MDIMenu')));
end;

Var
  MDIApp: TMDIApp;

{ Run the MDIApp }
begin
  MDIApp.Init('MDIApp');
  MDIApp.Run;
  MDIApp.Done;
end.

{
***************************************************************************
                 Content of the MDIAPP.RES File
***************************************************************************
}
MDIMENU MENU
begin
        POPUP "&MDI Children"
        begin
                MENUITEM "C&reate", 24339
                MENUITEM "&Cascade", 24337
                MENUITEM "&Tile", 24336
                MENUITEM "Arrange &Icons", 24335
                MENUITEM "C&lose All", 24338
        end
end

1 DIALOG 18, 18, 142, 92
STYLE DS_SYSMODAL | WS_CHILD | WS_VISIBLE | WS_CAPTION |
                    WS_MinIMIZEBOX | WS_MAXIMIZEBOX
CLASS "BorDlg"
CAPTION "TEST"
begin
        CHECKBOX "Text", 101, 26, 25, 28, 12
        LText "Text", -1, 34, 48, 16, 8
        CONTROL "Text", 102, "BorStatic", 0 | WS_CHILD |
                                              WS_VISIBLE, 33, 70, 66, 8
END

