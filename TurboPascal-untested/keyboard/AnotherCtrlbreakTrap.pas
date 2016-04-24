(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0026.PAS
  Description: Another Ctrl-Break Trap
  Author: SWAG SUPPORT TEAM
  Date: 06-22-93  09:10
*)

UNIT Break;
{This unit traps the Ctrl-Break sequence}

INTERFACE
USES
  DOS;
CONST
  BrkTrapped : Boolean = FALSE;
PROCEDURE TrapCtrlBrkOn;
PROCEDURE TrapCtrlBrkOff;

IMPLEMENTATION
CONST
  CtrlBrkInterrupt     = $1B;
  BrkTrapSet : Boolean = FALSE;
VAR
  OldBrkVector : Pointer;
{ The following procedure is the new Ctrl-Break
  Interrupt handler. It traps the Ctrl-Break key
  sequence and setsa flag for the currently
  running program to check.  You should do any
  special processing based on this flag's value}
{$F+}
PROCEDURE NewCtrlBrkVector; INTERRUPT;
{$F-}
BEGIN
  INLINE($FA); {Clear interrupts instruction -CLI}
  {Reset bit 7 low}
  Mem[$0040:$0071] := Mem[$0040:$0071] AND $E;
  BrkTrapped := TRUE;
  INLINE($FB) {Set interrupts instruction - STI}
END;

PROCEDURE TrapCtrlBrkOn;
BEGIN
  {Make sure no stacked calls are possible}
  IF NOT BrkTrapSet THEN
   BEGIN
    BrkTrapSet := TRUE;
    GetIntVec(CtrlBrkInterrupt, OldBrkVector);
    SetIntVec(CtrlBrkInterrupt, @NewCtrlBrkVector)
   END
END;

PROCEDURE TrapCtrlBrkOff;
BEGIN {Check if there is an old vector to restore}
  IF BrkTrapSet THEN
    BEGIN
      BrkTrapSet := FALSE;
      SetIntVec(CtrlBrkInterrupt, OldBrkVector)
    END
END;

END.

