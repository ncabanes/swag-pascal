(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0017.PAS
  Description: Using Novell?
  Author: PER-ERIC LARSSON
  Date: 01-27-94  12:23
*)

{
> Is there a way to detect if a system is running under Novell Netware?
> There must be an interrupt to do that, but wich one?
}

Uses
  Dos;

Function stationno : byte;
var
  B : byte;
  Regs : Registers;
begin
  With Regs do
  begin
    ah := $DC;
    ds := 0;
    si := 0;
  end;
  MsDos( Regs ); {INT $21,ah=dh}
  b := Regs.al;
  stationno := b;
end;

{ Should return 0 if not attached to a novell server otherwise
  workstation number }

begin
  Writeln(StationNo);
end.

