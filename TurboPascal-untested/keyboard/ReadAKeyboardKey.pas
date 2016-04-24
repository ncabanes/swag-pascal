(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0034.PAS
  Description: Read a keyboard Key
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:27
*)

{ Reads a key from the keyboard buffer, removing it.
  Part of the Heartware Toolkit v2.00 (HTkey1.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Get_Scan_Code : word;
{ DESCRIPTION:
    Reads a key from the keyboard buffer, removing it.
  SAMPLE CALL:
    NW := Get_Scan_Code;
  RETURNS:
    The next character in the keyboard buffer.
  NOTES:
    If no character is availlable, the service performed by this function
      waits until one is availlable. }

var
  HTregs : registers;

BEGIN { Get_Scan_Code }
  HTregs.AH := $00;
  Intr($16,HTregs);
  Get_Scan_Code := HTregs.AX;
END; { Get_Scan_Code }

