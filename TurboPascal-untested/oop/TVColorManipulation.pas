(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0073.PAS
  Description: T.V. Color Manipulation
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:55
*)

{
This program will place a new forground and background color
on the desktop.  It will also set the character that is displayed
for the pattern.  Please note that the $05 is where the 0 is for
black foreground and the 5 is for purple background.

}


program ColorManipulation;

uses
    Dos, Objects, Drivers, Memory, Views, 
    Menus, Dialogs, App;
type
  PMyBack = ^TMyBack;
  TMyBack = object(TBackground)
    constructor init(var Bounds: Trect);
  end;

  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    MyBack: PMyBack;
    constructor Init;
    procedure Initstatusline; virtual;
    procedure Initmenubar; virtual;
    function GetPalette:PPalette; virtual;
  end;

function TMyApp.GetPalette: PPalette;
const
  MyBackColor : TPalette = CColor;  { sets palette to CColor items, }
begin
  MyBackColor[1]:=#$05;   {TBackGround Color Constants first number is
                           background and second is foreground}
  GetPalette := @MyBackColor;
end;

constructor TMyBack.Init(var Bounds: TRect);
begin
  TBackground.Init(Bounds, '▓');{ places ASCII 178 char as pattern }
end;                            { for text on desktop.             }

constructor TMyApp.Init;
var
  R:Trect;
begin
  TApplication.Init;
  GetExtent(R);
  MyBack:= New(PMyBack, init(R));
  Desktop^.Background:= MyBack;
  Desktop^.Insert(Desktop^.Background);
end;

procedure TMyApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      nil),
    nil)
  ));
end;

procedure TMyApp.InitMenuBar;
begin
TApplication.InitMenubar;
end;

var
  TheApp: TMyApp;
begin
  TheApp.Init;
  TheApp.Run;
  TheApp.Done;
end.

