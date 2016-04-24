(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0023.PAS
  Description: Delete a file QUICK
  Author: JASON GROOMS
  Date: 08-27-93  21:22
*)

{
JASON GROOMS

| Can anyone give me some code for a procedure to delete a file? I
| cannot use the DOS EXEC procedure, due to memory conflicts, but I can
| call on interrupts.

Here is a routine to add to your toolbox which will delete a file
through DOS.
}

function DeleteFile(FN : PathStr) : Boolean;
var
  Regs : Registers;
begin
  FN := FN + #0;          { Add NUL chr for DOS }
  Regs.AH := $41;
  Regs.DX := Ofs(FN) + 1; { Add 1 to bypass length byte }
  Regs.DS := Seg(FN);
  MsDos(Regs);
  DeleteFile := NOT (Regs.Flags AND $0 = $0)
end;

{ Here is another routine to rename a file through DOS. }

function RenameFile(ON, NN : PathStr) : Boolean;
var
  Regs : Registers;
begin
  ON := ON + #0;       { Add NUL chr for DOS }
  NN := NN + #0;       { Add NUL chr for DOS }
  Regs.AH := $56;
  Regs.DX := Ofs(ON) + 1; { Add 1 to bypass length byte }
  Regs.DS := Seg(ON);
  Regs.DI := Ofs(NN) + 1; { Add 1 to bypass length byte }
  Regs.ES := Seg(NN);
  MsDos(Regs);
  RenameFile := NOT (Regs.Flags AND $0 = $0)
end;

{
These two routines require the Dos unit.

  **  Be warned that the delete file routine does not confirm the
      delete, meaning it WILL delete the file if it exists so use
      with care.

}
