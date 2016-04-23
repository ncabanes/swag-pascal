
{

This program will place a new foreground and background color and
pattern on the desktop.  It will also set the character that is
displayed for the pattern.

This example: the $05 defines the 0 for black foreground and
the 5 for purple background.

}

program ColorManipulation;

uses
    Dos, Objects, Drivers, Memory, Views,
    Menus, Dialogs, App;
type
  PMyBack = ^TMyBack;
  TMyBack = object(TBackground)
    constructor Init(var Bounds: TRect);
  end;

  PMyApp = ^TMyApp;
  TMyApp = object(TApplication)
    MyBack: PMyBack;
    constructor Init;
    function GetPalette:PPalette; virtual;
  end;

function TMyApp.GetPalette: PPalette;
const
  MyBackColor : TPalette = CColor;  { sets palette to CColor }
                                    { items }
begin
  MyBackColor[1]:=#$05;   { TBackGround Color Constant's first }
                          { number is background and second is }
                          { foreground }
  GetPalette := @MyBackColor;
end;

constructor TMyBack.Init(var Bounds: TRect);
begin
  TBackground.Init(Bounds, '▓');{ places ASCII 178 char as    }
                                { pattern for text on desktop }
end;

constructor TMyApp.Init;
var
  R:TRect;
begin
  TApplication.Init;
  GetExtent(R);
  MyBack:= New(PMyBack, init(R));
  Desktop^.Background:= MyBack;
  Desktop^.Insert(Desktop^.Background);
end;

var
  TheApp: TMyApp;
begin
  TheApp.Init;
  TheApp.Run;
  TheApp.Done;
end.
