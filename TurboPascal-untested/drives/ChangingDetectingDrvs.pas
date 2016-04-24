(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0006.PAS
  Description: Changing & Detecting Drvs
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{
Here are some routines For Changing and detecting drives.
}

Uses Crt, Dos;
Var
        Regs     :Registers;

Function GetDrive :Byte;
begin
  Regs.AX := $1900;
  Intr($21,Regs);
  GetDrive := (Regs.AL + 1);
  (* Returns  1 = A:,   2 = B:,   3 = C:,  Etc  *)
end;

Procedure ChangeDrive(Drive :Byte);
begin
  Regs.AH := $0E;
  Regs.DL := Drive;  (*  Drive   1 = A:, 2 = B:, 3 = C:  *)
  Intr($21,Regs);
end;

begin
  ClrScr;
  Writeln(' Current Drive : ',CHR( GetDrive+64 ));
end.

