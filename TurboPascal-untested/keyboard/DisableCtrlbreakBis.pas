(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0055.PAS
  Description: Disable Ctrl-Break
  Author: LOU DUCHEZ
  Date: 11-02-93  10:27
*)

(*
LOU DUCHEZ

>> How can i disable the Pascal interrupt key Ctrl-Break?

>Try CheckBreak := False;

> Isn't there another way to do this that works better? Just wondering... :)

Well, here's some code I came up With.  What it does is "cheat": it
detects if you're pressing "C" While "Ctrl" is down.  if so, it changes
"Ctrl" to "undepressed".  As For "Ctrl-Break", I just changed the
built-in "Ctrl-Break" interrupt to an "empty" routine (i.e., it does
NOTHING).  And it's a TSR, too; to "un-TSR" the code, remove the
"{$M ...}" at the beginning and the "keep(0)" at the end, then just
incorporate the code into your Programs.  More comments as I go:
*)

{$M $0400, $0000, $0000}
{$F+}

Program nobreak;
Uses
  Dos;

Const
  ctrlByte = $04;  { Memory location $0040:$0017 governs the statUses of
                     the Ctrl key, Alt, Shifts, etc.  the "$04" bit
                     handles "Ctrl". }

Var
  old09h       : Procedure; { original keyboard handler }
  ctrldown,
  cdown        : Boolean;
  keyboardstat : Byte Absolute $0040:$0017;    { the aforementioned location }

Procedure new1bh; interrupt;  { new Ctrl-Break handler: does NOTHING }
begin
end;

Procedure new09h; interrupt;  { new keyboard handler: it checks if you've
                                pressed "C" or "Brk"; if you have, it changes
                                "Ctrl" to "undepressed.  Then it calls the
                                "old" keyboard handler. }
begin
  if port[$60] and $1d = $1d then
    ctrldown := (port[$60] < 128);
  if port[$60] and $2e = $2e then
    cdown := (port[$60] < 128);
  if cdown and ctrldown then
    keyboardstat := keyboardstat and not ctrlByte;
  Asm
    pushf
  end;
  old09h;
end;

begin
  getintvec($09, @old09h);
  setintvec($09, @new09h);  { set up new keyboard handler }
  setintvec($1b, @new1bh);  { set up new "break" handler }
  ctrldown := False;
  cdown    := False;
  keep(0);
end.

