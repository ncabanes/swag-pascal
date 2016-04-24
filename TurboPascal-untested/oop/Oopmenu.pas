(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0014.PAS
  Description: OOPMENU.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
Menus in TV are instances of class tMenuBar, accessed via Pointer Type
pMenuBar. A Complete menu is a Single-linked list, terminated With a NIL
Pointer. Each item or node is just a Record that holds inFormation on
what the node displays and responds to, and a Pointer to the next menu
node in the list.

I've written out a short bit of TV menu code that you can Compile and
play With, and then you can highlight parts that you don't understand
when you send back your reply.
}

Program TestMenu;

Uses
  Objects, Drivers, Views, Menus, App;

Const
  cmOpen  = 100;  (* Command message Constants *)
  cmClose = 101;

Type
  pTestApp = ^tTestApp;
  tTestApp = Object(tApplication)
    Procedure InitMenuBar; Virtual;    (* Do-nothing inherited method *)
  end;                                 (* which you override          *)

(* Set up the menu by filling in the inherited method *)
Procedure tTestApp.InitMenuBar;
Var
  vRect : tRect;

begin
  GetExtent(vRect);
  vRect.B.Y := vRect.A.Y + 1;
  MenuBar := New(pMenuBar, Init(vRect, NewMenu(
    NewSubMenu('~F~ile', hcNoConText, NewMenu(
      NewItem('~O~pen', 'Alt-O', kbAltO, cmOpen, hcNoConText,
      NewItem('~C~lose', 'Alt-C', kbAltC, cmClose, hcNoConText,
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoConText,
      NIL)))),
    NewSubMenu('~E~dit', hcNoConText, NewMenu(
      NewItem('C~u~t', 'Alt-U', kbAltU, cmCut, hcNoConText,
      NewItem('Cop~y~', 'Alt-Y', kbAltY, cmCopy, hcNoConText,
      NewItem('~P~aste', 'Alt-P', kbAltP, cmPaste, hcNoConText,
      NewItem('C~l~ear', 'Alt-L', kbAltL, cmClear, hcNoConText,
      NIL))))),
    NewSubMenu('~W~indow', hcNoConText, NewMenu(
        NewItem('Ca~s~cade', 'Alt-S', kbAltS, cmCascade, hcNoConText,
      NewItem('~T~ile', 'Alt-T', kbAltT, cmTile, hcNoConText,
      NIL))),
    NIL))))
  ))
end;

Var
  vApp : pTestApp;

begin
  New(vApp, Init);
  if vApp = NIL then
    begin
      WriteLn('Couldn''t instantiate the application');
      Exit;
    end;
  vApp^.Run;
  vApp^.Done;
end.

