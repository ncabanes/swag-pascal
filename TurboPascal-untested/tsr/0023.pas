
{
Hmm ... My initial attempt was to disable the Int 19h handler, which is
called when you hit ctrl-alt-del; but it didn't work.  So here's a TSR
that "cheats": if you hit "ctrl" and "alt" and then "del", it flags
"ctrl" and "alt" as "not down" and so your system never sees the reboot
condition. }

{$M $0400, $0000, $0000}
{$F+}

program noreboot;
uses dos;

const ctrlbyte = $04;  { Memory location $0040:$0017 governs the statuses of }
      altbyte  = $08;  { the Ctrl key, Alt, Shifts, etc.  the "$04" bit }
                       { handles "Ctrl"; "$08" handles "Alt". }

var old09h: procedure;                          { original keyboard handler }
    ctrldown, altdown, deldown: boolean;
    keyboardstat: byte absolute $0040:$0017;    { the aforementioned location }

{-----------------------------------------------------------------------------}

procedure new09h; interrupt;  { new keyboard handler: it checks if you've
                                pressed "Ctrl", "Alt" and "Delete"; if you
                                have, it changes "Ctrl" and "Alt" to
                                "undepressed".  Then it calls the
                                "old" keyboard handler. }
begin
  if port[$60] and $1d = $1d then ctrldown := (port[$60] < 128);
  if port[$60] and $38 = $38 then altdown  := (port[$60] < 128);
  if port[$60] and $53 = $53 then deldown  := (port[$60] < 128);
  if ctrldown and altdown and deldown then begin
     keyboardstat := keyboardstat and not ctrlbyte;  { By killing the "Ctrl" }
     keyboardstat := keyboardstat and not altbyte;   { and "Alt" bits, the   }
     end;                                            { "reboot" never runs   }
  asm
    pushf
    end;
  old09h;
  end;

{-----------------------------------------------------------------------------}

begin
  getintvec($09, @old09h);
  setintvec($09, @new09h);  { set up new keyboard handler }
  ctrldown := false;
  altdown := false;         { Set "Ctrl", "Alt", "Delete" to "False" }
  deldown := false;
  keep(0);
  end.
