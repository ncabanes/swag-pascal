{ Reads a key from the keyboard buffer, WITHOUT removing it.
  Part of the Heartware Toolkit v2.00 (HTkey1.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Read_Key : word;
{ DESCRIPTION:
    Reads a key from the keyboard buffer, WITHOUT removing it.
  SAMPLE CALL:
    NW := Read_Key;
  RETURNS:
    The scan code of the key that is ready to be readen from the buffer, or,
      if there is no key in the buffer, returns $FFFF value.
  NOTES:
    This is a special function. It's only to be called in very special
      situations. It checks if a key is ready in the keyboard
      buffer. If there is a key, then the key is readed but NOT removed
      from the buffer. The key will remain in the buffer. }

var
  HTregs : registers;

BEGIN { Read_Key }
  HTregs.AH := $01;
  Intr($16,HTregs);
  if not (HTregs.Flags and FZero <> 0) then
    Read_Key := HTregs.AX
  else
    Read_Key := $FFFF;
END; { Read_Key }
