(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0089.PAS
  Description: Reading F11 & F12
  Author: ANDREW EIGUS
  Date: 11-26-94  05:08
*)

{ > how do I get the f11 and f12 keys? }

Program ReadF11F12Keys;
{ Written by Andrew Eigus of 2:5100/33@fidonet.org }
{ SWAG donation... }

const
  F11 = #$85;
  F12 = #$86;

Function ReadKey : char; assembler;
Asm
  mov ah,08h
  int 21h
End; { ReadKey }

var
  Ch : char;
  Extended : boolean;

Begin
  Write('Press F11 or F12 to quit... ');
  repeat
    Ch := ReadKey;
    if Ch = #0 then
    begin
      Extended := True;
      Ch := ReadKey
    end else Extended := False;
  until (Ch in [F11,F12]) and Extended;
  WriteLn('Done.')
End.
{
> ALSO!  What is bit 8 in that address?

Two bytes at address 0:0417 and 0:0418 identify the status of the keyboard
shift keys and keyboard toggles.  INT 16H returns the first byte in AL.

╓─7┬─6┬─5┬─4┬─3┬─2┬─1┬─0╖     Perform INT 16H Fn 02H
║I │C │N │S │a │c │sL│sR║     or fetch AL=byte at 0:0417
╙─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥╜ bit
  ║  ║  ║  ║  ║  ║  ║  ╚═ 0: alpha-shift (right side) DOWN (AL & 01H)
  ║  ║  ║  ║  ║  ║  ╚════ 1: alpha-shift (left side) DOWN  (AL & 02H)
  ║  ║  ║  ║  ║  ╚═══════ 2: Ctrl-shift (either side) DOWN (AL & 04H)
  ║  ║  ║  ║  ╚══════════ 3: Alt-shift  (either side) DOWN (AL & 08H)
  ║  ║  ║  ╚═════════════ 4: ScrollLock state              (AL & 10H)
  ║  ║  ╚════════════════ 5: NumLock state                 (AL & 20H)
  ║  ╚═══════════════════ 6: CapsLock state                (AL & 40H)
  ╚══════════════════════ 7: Insert state                  (AL & 80H)

╓─7┬─6┬─5┬─4┬─3┬─2┬─1┬─0╖
║i │c │n │s │  │sy│aL│cL║    fetch AL=byte at 0:0418
╙─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥╜ bit
  ║  ║  ║  ║  ║  ║  ║  ╚═ 0: Ctrl-shift (left side) DOWN (AL & 01H)
  ║  ║  ║  ║  ║  ║  ╚════ 1: Alt-shift (left side) DOWN  (AL & 02H)
  ║  ║  ║  ║  ║  ╚═══════ 2: SysReq DOWN                 (AL & 04H)
  ║  ║  ║  ║  ╚══════════ 3: hold/pause state            (AL & 08H)
  ║  ║  ║  ╚═════════════ 4: ScrollLock DOWN             (AL & 10H)
  ║  ║  ╚════════════════ 5: NumLock DOWN                (AL & 20H)
  ║  ╚═══════════════════ 6: CapsLock DOWN               (AL & 40H)
  ╚══════════════════════ 7: Insert DOWN                 (AL & 80H)

Notes: Bits 0-2 of 0:0418 are defined only for the 101-key enhanced keyboard.

       The 101-key BIOS INT 16H Fn 12H returns AL as with Fn 02, but AH is
       returned with the following bit-flag layout:

       ╓─7┬─6┬─5┬─4┬─3┬─2┬─1┬─0╖
       ║sy│c │n │s │aR│cR│aL│cL║    Perform INT 16H Fn 12H (101-key BIOS only)
       ╙─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥┴─╥╜ bit
         ║  ║  ║  ║  ║  ║  ║  ╚═ 0: Ctrl-shift (left side) DOWN  (AH & 01H)
         ║  ║  ║  ║  ║  ║  ╚════ 1: Alt-shift (left side) DOWN   (AH & 02H)
         ║  ║  ║  ║  ║  ╚═══════ 2: Ctrl-shift (right side) DOWN (AH & 04H)
         ║  ║  ║  ║  ╚══════════ 3: Alt-shift (right side) DOWN  (AH & 08H)
         ║  ║  ║  ╚═════════════ 4: ScrollLock DOWN              (AH & 10H)
         ║  ║  ╚════════════════ 5: NumLock DOWN                 (AH & 20H)
         ║  ╚═══════════════════ 6: CapsLock DOWN                (AH & 40H)
         ╚══════════════════════ 7: SysReq DOWN                  (AH & 80H)

       Some older programs change the values of NumLock and CapsLock state
       bits (at 0:0417) to force a known status.  This is unwise because
       modern keyboards have indicator lights which will get out of sync with
       the status. See AT Keyboard for more information on the lock-key LEDs.

       PCjr status bytes at 0:0488 are omitted for lack of interest [mine─DR].
}

