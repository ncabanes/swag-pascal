(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0012.PAS
  Description: Yet Another Reboot
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{ Subject: How to reboot With TP7.0 ??? }
Var
  hook : Word Absolute $0040:$0072;

Procedure Reboot(Cold : Boolean); Far;
begin
  if (Cold = True) then
    hook := $0000
  else
    hook := $1234;

  ExitProc := ptr($FFFF,$0000);
end;


{
P.S.  Note that it does not require any Units to compile.  Though
depending on your Implementation, you may need to call HALT to
trip the Exit code (which caUses a reboot).
}

Program reset;
Uses
  Dos;
Var
  regs : Registers;
begin
  intr(25,regs);
end.

{ Yeah but it is easier to do it in Inline Asm
eg:
}
Program reset;
begin
  Asm
    INT 19h; {19h = 25 decimal}
        end;
end.

{
One Word about this interupt is that it is the fastest reboot
I know of but some memory managers, eg QEMM 6.03 don't like it,
It will seriously hang Windows if called from a Dos Shell,
Microsoft Mouse Driver 8.20 doesn't seem to like being run
after you call int 19h and it was resident.
Other than that it works like a gem!
}

