{
> Does anybody know how to get rid of the menu bar?  I'm using Pascal.

You can make Turbo Vision look however you wish for a text mode interface.  I
posted this code here earlier which is Turbo Vision without a visible menu
bar or status line:
}
program TVDesk;
{ File: TVDESK.PAS
  Author: John Howard  jh
  Origin: (1:280/66)
  Date: August 16, 1994
  Note: Allows a full Turbo Vision desktop with a specific character pattern.
  Version: 1.0
}
uses App, Objects, Menus;
type
   TTutorApp = object(TApplication)
               procedure InitStatusLine; virtual;
               procedure InitMenuBar; virtual;
               procedure InitDesktop; virtual;
   end;

procedure TTutorApp.InitStatusLine;         { draw nothing, allow ALT-X quit }
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y + 1;                       { below screen bottom }
  New(StatusLine, Init(R, NewStatusDef(0, $EFFF, StdStatusKeys(nil), nil)));
end;

procedure TTutorApp.InitMenuBar;            { do nothing }
begin end;

procedure TTutorApp.InitDesktop;
var R: TRect;
begin
  GetExtent(R);                             { get application rectangle }
                                            { Adjust R.A.Y and R.B.Y here! }
  New(Desktop, Init(R));                    { construct custom desktop }
  Desktop^.Background^.Pattern := ' ';      { change pattern character }
end;

var TutorApp : TTutorApp;                   { declare an instance of yours }
begin
  TutorApp.Init;
  TutorApp.Run;
  TutorApp.Done;
end.

