(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0006.PAS
  Description: ANSI Ouput w/ INT29
  Author: ROBERT ROTHENBURG
  Date: 05-28-93  13:33
*)

{
ROBERT ROTHENBURG

For those interested in using ANSI in Turbo Pascal (at least Dos v2-5
...I don't know if Dos 6 Uses this routine--Interrupt $29--or not)
here's a tip:  The "undocumented" Fast PutChar interrupt is used by
ANSI.SYS, and thus anything you send to that interrupt will be
ANSI-interpreted (provided ANSI.SYS is loaded :).

Use this routine to output a Character to ANSI:
(you'll have to modify it to output Strings, of course).
}

Uses
  Dos;

Procedure FastPutChar(C : Char);
{ Outputs only to "display", not stdout! Uses Dos v2-5. }
Var
  Reg : Registers;
begin
  Reg.AL := Ord(C);
  Intr($29, Reg)
end;


