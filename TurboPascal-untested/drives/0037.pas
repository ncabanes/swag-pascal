{ Gets disk verify state flag.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Verify_State : boolean;
{ DESCRIPTION:
    Gets disk verify state flag.
  SAMPLE CALL:
    B := Verify_State;
  RETURNS:
    TRUE  = on: verify after write
    FALSE = off: no verify after write }

var
  HTregs : registers;

BEGIN { Verify_State }
  HTregs.AH := $54;
  MsDos(HTregs);
  Verify_State := HTregs.AL = $01;
END; { Verify_State }
