(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0035.PAS
  Description: Check Char Available
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:27
*)

{ Checks to see it a character is availlable in the DOS keyboard buffer.
  Part of the Heartware Toolkit v2.00 (HTkey1.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Key_Ready : boolean;
{ DESCRIPTION:
    Checks to see it a character is availlable in the DOS keyboard buffer.
  SAMPLE CALL:
    B := Key_Ready;
  RETURNS:
    TRUE  : If there is a key waiting to be readed in the keyboard buffer;
    FALSE : If it is not. }

var
  HTregs : registers;

BEGIN { Key_Ready }
  HTregs.AH := $01;
  Intr($16,HTregs);
  Key_Ready := not (HTregs.Flags and FZero <> 0);
END; { Key_Ready }

