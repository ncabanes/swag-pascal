{ Time-Out values for parallel printers.
  Part of the Heartware Toolkit v2.00 (HTparal.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Parallel_Time_Out(LPT : byte) : byte;
{ DESCRIPTION:
    Time-Out values for parallel printers.
  SAMPLE CALL:
    NB := Parallel_Time_Out(1);
  NOTES:
    The allowed values for LPT are: 1,2,3 or 4. }

BEGIN { Parallel_Time_Out }
  Parallel_Time_Out := Mem[$0000:$0478 + Pred(LPT)];
END; { Parallel_Time_Out }
