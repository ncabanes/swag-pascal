(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0001.PAS
  Description: DETCNETX.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
▒i'm trying to find a method by which i can, from within a TP Program,
▒detect whether or not the NetWare shell has been loaded (Net3, NetX, or
▒whatever); i've figured out how to determine if IPX is running, but
▒can't seem to nail down the shell; the general idea is to detect IPX,
▒detect the shell, determine whether or not the user is logged in, and if
▒not, give them the oppurtUnity to do so; i've got most of the rest
▒figured out, but can't find the shell; any help would be greatly
▒appreciated

Try Interrupt 21h, Function EAh, GetShellVersion;
}

Uses
  {$IFDEF DPMI}
  WinDos;
  {$ELSE}
  Dos;
  {$endIF}
Var
  vOS,
  vHardwareType,
  vShellMajorVer,
  vShellMinorVer,
  vShellType,
  vShellRevision  : Byte;
  {$IFDEF DPMI}
  vRegs : tRegisters;
  {$ELSE}
  vRegs : Registers;
  {$endIF}

Procedure GetShellVersion;
begin
  vOS            := 0;
  vHardwareType  := 0;
  vShellMajorVer := 0;
  vShellMinorVer := 0;
  vShellType     := 0;
  vShellRevision := 0;
  FillChar(vRegs, SizeOf(vRegs), 0);
  With vRegs DO
  begin
    AH := $EA;
    Intr($21, vRegs);
    vOS := AH;              (* $00 = MS-Dos *)
    vHardwareType := AL;    (* $00 = PC, $01 = Victor 9000 *)
    vShellMajorVer := BH;
    vShellMinorVer := BL;
    vShellType := CH;       (* $00 = conventional memory *)
                            (* $01 = expanded memory     *)
                            (* $02 = extended memory     *)
    vShellRevision := CL;
  end;
end;

begin
  GetShellVersion;
  Writeln(vOS);
  Readln;
end.
