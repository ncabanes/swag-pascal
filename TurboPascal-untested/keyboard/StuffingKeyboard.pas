(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0042.PAS
  Description: Stuffing Keyboard
  Author: SEAN PALMER
  Date: 08-27-93  21:31
*)

{
SEAN PALMER

>> I am assuming you already have a buffer-stuffer that takes a char and a
>> scan code as input, so I won't post mine.

>No, I don't have a keyboard buffer-stuffer.

You said you wanted one that DIDN'T need you to tell it what a char's
scancode was. Well, this would basically require a lookup table of
possible scancodes for each ascii char... Plus some that don't have
corresponding scancodes. What you could try is to just send a null (#0)
to the routine as a scan code, I believe that's what happens when you
enter a keystroke using the Alt-Numeric Keypad method... so it'd work as
long as the program you're sending the keys to doesn't need the
scancode.

Here's an untested version of the method that other guy sent to you...:
}

procedure stuffKey(c : char; scan : byte); assembler;
asm
  mov cl, c
  mov ch, scan
  mov ah, 5
  int $16
  {al=0 if success, 1 if failed, but we just ignore that here}
end;

so here's a call that just assumes a 0 scan code

procedure stuffChar(c : char); assembler;
asm
  mov cl,c
  xor ch,ch
  mov ah,5
  int $16
end;

{
If you don't wanna go through the BIOS you can do it directly like this:
(plus this is 'pure' Turbo Pascal code.. 8) }

var
  head     : word absolute $40 : $1A;
  tail     : word absolute $40 : $1C;
  bufStart : word absolute $40 : $80;
  bufEnd   : word absolute $40 : $82;

procedure stuffKey(c : char; scan : byte);
begin
  memW[$40 : tail] := word(scan) shl 8 + byte(c);
  inc(tail, 2);
  if tail = bufEnd then
    tail := bufStart;
end;

procedure clearBuffer;
begin
  tail := head;
end;



