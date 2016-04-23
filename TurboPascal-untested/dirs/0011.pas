{ DR> DEL/ERASE command is able to erase an entire directory by using DEL *.*
 DR> With such speed.  It clearly has a method other than deleting File by
 DR> File.

  Function $41 of Int $21 will do what you want.  You'll need to
make an ASCIIZ Filename of the path and File(s), and set a Pointer
to it in DS:DX.  When it returns, if the carry flag (CF) is set,
then AX holds the Dos error code.
}
Function DosDelete (FileName : PathStr) : Word; {returns error if any}
Var Regs : Registers;
begin
  FileName[65] := 0;             {make asciiz- maybe, not sure}
  Regs.DS := Seg(FileName);      {segment to String}
  Regs.DX := offset(FileName)+1; {add one since f[0] is length}
  Regs.AH := $41;
  Regs.AL := 0;                  {Initialize}
  Intr ($21, Regs);
  if Regs.AL <> 0 {error} then DosDelete := Regs.AX else DosDelete := 0;
end;
