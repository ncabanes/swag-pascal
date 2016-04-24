(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0073.PAS
  Description: Checking Keys begin Held
  Author: BERNIE PALLEK
  Date: 02-03-94  16:15
*)


UNIT MultiKey;

INTERFACE

VAR
  KeyStat : Array[1..127] OF ShortInt;
  { 0 (not physically down)
    1 (that sucker's down)
   -1 (it's being held, don't repeat) }

PROCEDURE EnableMultiKey;
PROCEDURE DisableMultiKey;

IMPLEMENTATION

USES Dos;

VAR
  OldKbdInt       : Pointer;
  OldCtrlBreakInt : Pointer;
  OldKeyExitProc  : Pointer;

PROCEDURE ClearKeyValues;
VAR
  keyclearcounter : Byte;
BEGIN
  FOR keyclearcounter := 1 TO 127 DO KeyStat[keyclearcounter] := 0;
END;

PROCEDURE NewKeyExitProc; Far;
BEGIN
  SetIntVec($09, OldKbdInt);
  SetIntVec($1B, OldCtrlBreakInt);
  ExitProc := OldKeyExitProc;
END;

PROCEDURE NewCtrlBreakInt; Interrupt;
{ it is important that the new Ctrl-Break handler does *nothing* }
BEGIN
END;

PROCEDURE NewKbdInt; Interrupt;
VAR
  p60 : Byte;
BEGIN
  p60 := Port[$60];
  Port[$61] := Port[$61] OR 128;         {/ keyboard    \}
  Port[$61] := Port[$61] AND (NOT 128);  {\ acknowledge /}
  IF (p60 > 0) THEN BEGIN
    IF (p60 > 127) THEN
      KeyStat[p60 AND 127] := 0
    ELSE
      IF (KeyStat[p60] = 0) THEN Inc(KeyStat[p60]);
  END;
  ASM CLI; END;                           {disable hardware ints}
  MemW[$0040:$001A] := MemW[$0040:$001C]; {clear buffer}
  ASM STI; END;                           {restore hardware ints}
  Port[$20] := $20;                       { send EOI to PIC }
END;

PROCEDURE EnableMultiKey;
BEGIN
  SetIntVec($09, Addr(NewKbdInt));
END;

PROCEDURE DisableMultiKey;
BEGIN
  SetIntVec($09, OldKbdInt);
END;


BEGIN  { unit initialization }
  GetIntVec($1B, OldCtrlBreakInt);
  SetIntVec($1B, Addr(NewCtrlBreakInt));
  ClearKeyValues;
  OldKeyExitProc := ExitProc;
  ExitProc := Addr(NewKeyExitProc);
  GetIntVec($09, OldKbdInt);
  EnableMultiKey;
END.


