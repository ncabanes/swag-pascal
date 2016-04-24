(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0009.PAS
  Description: OOP-HTKY.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
> Yes, event oriented Programming is very easy using OOP, but as it
> comes to TVision, if you need to add your own events, you're stuck. I
> just wanted to implement the Windows-style ALT-Press-ALT-Release
> event, that activates the Window menu, and I'd had to modify the
> Drivers.pas sourceFile to implement it, so I have to find other keys
> to activate the menu bar :-(

this Really stimulated me so I sat down and implemented the following *without*
messing around in DRIVERS.PAS in -believe it or not- 15 minutes!  :-)))
}
Program tryalt;

Uses drivers,Objects,views,menus,app,Crt;

Const altmask = $8;
Var   k4017 : Byte Absolute $40:$17;

Type  tmyapp = Object (TApplication)
        AltPressed,
        IgnoreAlt: Boolean;
        Constructor Init;
        Procedure InitMenuBar; Virtual;
        Procedure GetEvent (Var Event: TEvent); Virtual;
        Procedure Idle; Virtual;
      end;

{ low-level Function; returns True when <Alt> is being pressed }
Function AltDown: Boolean;
begin
  AltDown := (k4017 and altmask) = altmask
end;

Constructor tmyapp.Init;
begin
  inherited init;
  AltPressed := False;
  IgnoreAlt := False
end;

Procedure Tmyapp.InitMenuBar;
Var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New (PMenuBar, Init(R, NewMenu (
    NewSubMenu ('~≡~', hcNoConText, NewMenu (
      NewItem ('~A~bout LA-Copy...', '', kbNoKey, cmQuit, hcNoConText,
      NewLine (
      NewItem ('~D~OS Shell', '', kbNoKey, cmQuit, hcNoConText,
      NewItem ('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoConText,
      nil))))),
    NewSubMenu ('~R~ead', hcNoConText, NewMenu (
      NewItem ('~D~isk...', 'F5', kbF5, cmQuit, hcNoConText,
      NewItem ('~I~mage File...', 'F6', kbF6, cmQuit, hcNoConText,
      NewItem ('~S~ector...', 'F7', kbF7, cmQuit, hcNoConText,
      NewLine (
      NewItem ('~F~ree up used memory', 'F4', kbF4, cmQuit, hcNoConText,
      nil)))))),
    (* more menus in the original :-) *)
    nil)))));
end;

{ modified GetEvent to allow direct usage of Alt-Hotkey }
Procedure tmyapp.GetEvent (Var Event: TEvent);
begin
  inherited GetEvent (Event);
  if (Event.What and (evKeyboard or evMessage)) <> evnothing then
    IgnoreAlt := True               { in Case of keypress or command ignore }
end;                                { Until <Alt> next time released }

Procedure tmyapp.Idle;
Var Event: TEvent;
begin
  inherited Idle;
  if AltDown then                      { <Alt> key is down }
    AltPressed := True                   { remember this }
  else begin                           { <Alt> is released (again?) }
    if AltPressed then begin             { yes, again. }
      if not IgnoreAlt then begin        { but: did they use Alt-Hotkey? }
        Event.What := evCommand;           { no, let's activate the menu! }
        Event.Command := cmMenu;
        PutEvent (Event)
      end;
    end;
    AltPressed := False;                 { however, <Alt> is up again }
    IgnoreAlt := False                   { so we don't need to ignore it }
  end;                                   { the next time <Alt> is released }
end;

Var myapp: tmyapp;     { create an Object of class 'tmyapp' }

begin
  myapp.init;     { you know these three lines, don't you? <g> }
  myapp.run;
  myapp.done;
end.

{
For convenience I copied the first three menus from my diskcopy clone so don't
get confused about the items :-).  This Program does not emulate Completely
Windows' behaviour, however, it's a good start. Tell me if this is what you
wanted! I didn't test it excessively but it does work in this fairly simple
Program For activating menus by <Alt>. The only thing not implemented is
'closing' the menu bar by a second <Alt> stroke.
}
