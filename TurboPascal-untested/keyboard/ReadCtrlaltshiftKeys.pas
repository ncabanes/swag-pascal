(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0012.PAS
  Description: Read CTRL/ALT/SHIFT Keys
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{
> I was sitting here thinking about how usefull it would be to be able
> to check the status of the different Locks (eg. scroll lock, num lock
> or how to do it.  I think it is some sort of Bios or Dos service??
> Any help would be greatly appreciated.

The easiest way is to access BIOS memory at address 40h:17h

}
Procedure TestKeys;

Var
  Scroll_Lock,
  Caps_Lock,
  Num_Lock,
  Ins,
  Alt,
  Ctrl,
  Left_Shift,
  Right_Shift : Boolean;
  Bios_Keys   : Byte Absolute $40:$17;

begin
  Ins           := ((Bios_Keys And $80) = $80);
  Caps_Lock     := ((Bios_Keys And $40) = $40);
  Num_Lock      := ((Bios_Keys And $20) = $20);
  Scroll_Lock   := ((Bios_Keys And $10) = $10);
  Alt           := ((Bios_Keys And $8)  = $8);
  Ctrl          := ((Bios_Keys And $4)  = $4);
  Left_Shift    := ((Bios_Keys And $2)  = $2);
  Right_Shift   := ((Bios_Keys And $1)  = $1);

  Writeln('Insert      : ', Ins);
  Writeln('CapsLock    : ', Caps_Lock);
  Writeln('NumLock     : ', Num_Lock);
  Writeln('ScrollLock  : ', Scroll_Lock);
  Writeln('Alt         : ', Alt);
  Writeln('Control     : ', Ctrl);
  Writeln('Left Shift  : ', Left_Shift);
  Writeln('Right Shift : ', Right_Shift);
end;

begin
  TestKeys;
  Readln;
end.
