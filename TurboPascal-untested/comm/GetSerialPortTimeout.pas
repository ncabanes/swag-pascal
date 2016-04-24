(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0020.PAS
  Description: Get Serial Port Timeout
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:30
*)

FUNCTION Serial_Time_Out(COM : byte) : byte;
{ DESCRIPTION:
    Time-Out values for RS232 communications lines.
  SAMPLE CALL:
    NB := Serial_Time_Out(1);
  NOTES:
    The allowed values for COM are: 1,2,3 or 4. }

BEGIN { Serial_Time_Out }
  Serial_Time_Out := Mem[$0000:$047C + Pred(COM)];
END; { Serial_Time_Out }

