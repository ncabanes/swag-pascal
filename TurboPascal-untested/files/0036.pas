{
ts@uwasa.fi (Timo Salmi)

 Q: How can one hide (or unhide) a directory using a TP Program?

 A: SetFAttr which first comes to mind cannot be used For this.
Instead interrupt Programming is required.  Here is the code.
Incidentally, since MsDos 5.0 the attrib command can be used to hide
and unhide directories.
(* Hide a directory. Before using it would be prudent to check
   that the directory exists, and that it is a directory.
   With a contribution from Jan Nielsen jak@hdc.hha.dk
   Based on information from Duncan (1986), p. 410 *)
}
Procedure HIDE(dirname : String);
Var
  regs : Registers;
begin
  FillChar(regs, SizeOf(regs), 0);    { standard precaution }
  dirname := dirname + #0;           { requires ASCII Strings }
  regs.ah := $43;                    { Function }
  regs.al := $01;                    { subFunction }
  regs.ds := Seg(dirname[1]);        { point to the name }
  regs.dx := Ofs(dirname[1]);
  regs.cx := 2; { set bit 1 on }     { to unhide set regs.cx := 0 }
  Intr ($21, regs);                  { call the interrupt }
  if regs.Flags and FCarry <> 0 then { were we successful }
    Writeln('Failed to hide');
end;
