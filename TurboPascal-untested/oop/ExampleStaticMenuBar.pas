(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0052.PAS
  Description: Example Static Menu Bar
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  09:47
*)

{

This program is an example that will display static text
in a static menubar above the active menubar.

}
program ExtraMenuBar;

uses Objects, Drivers, Views, Menus, App;

const
  cmFileOpen = 100;
  cmNewWin   = 101;

type
  PExtraMenuBar = ^TExtraMenuBar;
  TExtraMenuBar = object(TMenuBar)
   procedure Draw;virtual;
  end;

  TMyApp = object(TApplication)
    ExtraMenuBar : PExtraMenuBar;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
  end;


procedure TExtraMenuBar.Draw;
const
 ProgName : String = '                                    Program Name'+
                     '                                 ';
begin
TMenuBar.Draw;
WriteStr(0,0,ProgName,$06);
end;

{ TMyApp }
procedure TMyApp.InitMenuBar;
var R: TRect;
begin
  GetExtent(R);
  ExtraMenuBar := New(PExtraMenuBar,Init(R,nil));
  Insert(ExtraMenuBar);
  R.B.Y := R.A.Y + 2;
  R.A.Y := 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
      NewItem('~O~pen', 'F3', kbF3, cmFileOpen, hcNoContext,
      NewItem('~N~ew', 'F4', kbF4, cmNewWin, hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil))))),
      nil))));
end;

procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
      NewStatusKey('~F4~ New', kbF4, cmNewWin,
      NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
      nil)))),
    nil)
  ));
end;

var
  MyApp: TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.

