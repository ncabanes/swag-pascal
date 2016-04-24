(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0059.PAS
  Description: MDI Apps in Windows
  Author: CRAIG A. JACKSON & RUSS CHINOY
  Date: 05-26-95  23:20
*)

{
From: cajackso@saturn.acs.oakland.edu (Craig A. Jackson)

Any ideas as to what I'm doing wrong in the following code?
I'm trying to learn how MDI applications work and I'm running
into difficulties.

I've overridden the TMDIWindow.InitChild() function, with my own
version, but it still calls the function defined for the ancestor
(i.e., TMDIWindow).  It won't call my function.  These are virtual
functions, so they should bind at run-time - right?  I stepped through
the code in the debugger, so I know it is calling the ancestor's
function rather than mine.  Also, all the child windows have a
caption that reads 'MDI Child' rather than 'Bob'.

}

PROGRAM MyMDI;

{$r mymdi.res}

USES
  WinTypes, WinProcs, OWindows;

CONST
  id_Menu = 'MyMDIMenu';
  posWindowMenu = 2;


TYPE
  MyMDIApplication = OBJECT(TApplication)
    PROCEDURE InitMainWindow; VIRTUAL;
  END;


  MyMDIWindowPtr = ^MyMDIWindow;
  MyMDIWindow = OBJECT(TMDIWindow)
    CONSTRUCTOR Init( aTitle : PChar; aMenu : HMenu );
    FUNCTION InitChild: PWindowsObject; VIRTUAL;
  END;


  PROCEDURE MyMDIApplication.InitMainWindow;
    BEGIN
      MainWindow := New( PMDIWindow, Init(' My MDI App',
        LoadMenu( HInstance, id_Menu ) ) );
    END;


  CONSTRUCTOR MyMDIWindow.Init( aTitle : PChar; aMenu : HMenu );
    BEGIN
      INHERITED Init( aTitle, aMenu );
      ChildMenuPos := posWindowMenu;
    END;

  FUNCTION MyMDIWindow.InitChild: PWindowsObject;
    begin
     messagebeep(0);
     InitChild := New(PWindow, Init(@Self, 'Bob'));
    end;



VAR
  MyMDIApp : MyMDIApplication;

BEGIN
  MyMDIApp.Init( 'MyMDIApp' );
  MyMDIApp.Run;
  MyMDIApp.Done;
END.

{
From: russchinoy@aol.com (RussChinoy)

Your problem lies in MyMDIApplication.InitMainWindow, where you are
creating an instance of type PMDIWindow instead of MyMDIWindowPtr.
}


