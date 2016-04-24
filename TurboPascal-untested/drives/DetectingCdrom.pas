(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0051.PAS
  Description: Detecting CD-ROM
  Author: WIM VAN VOLLENHOVEN
  Date: 11-02-93  05:06
*)

{
WIM VAN VOLLENHOVEN

>No, I'm looking for an generic CD-ROM detection routine.
>Thought it was some subfunction of int 2Fh. Don't know if it detected
>the presence of a CD-Rom, or the presence of MSCDEX.
}
Uses
  Dos;

Var
  Regs : Registers;

Procedure IsCDRom;
begin
   Regs.AX := $1500;
   Regs.BX := $0000;
   Regs.CX := $0000;
   Intr( $2F, Regs);
   writeln('CD Available : ', (Regs.BX > 0));
end;


begin
  IsCDRom;
end.

