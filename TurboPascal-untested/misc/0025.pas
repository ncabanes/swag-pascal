{ Gets the status of the last or current Print Screen operation.
  Part of the Heartware Toolkit v2.00 (HTparal.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION PrtSc_Status : byte;
{ DESCRIPTION:
    Gets the status of the last or current Print Screen operation.
  SAMPLE CALL:
    NB := PrtSc_Status;
  RETURNS:
    00h : Print Screen complete
    01h : Print Screen currently in progress
    FFh : Error occurred during Print Screen }

BEGIN { PrtSc_Status }
  PrtSc_Status := Mem[$0000:$0500];
END; { PrtSc_Status }
