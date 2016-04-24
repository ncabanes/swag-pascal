(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0105.PAS
  Description: Close a file opened from a Delphi DLL in
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
Q:  How do I close a file that was opened in a DLL (Delphi
made) and called from VB?

A:  This is a known problem. It comes from the fact that VB
closes the 5 DOS standard handles (0..4) at startup. So the
open file routine will reuse one of these handles to open the
first disk file. That is not a problem in using the file, but
the Pascal Close routine has a build-in safety feature: it
refuses to close a file that has one of the standard handles!
That is a Good Thing under DOS but screws up the works in your
situation since the file opened by the DLL is never closed, not
even when the DLL goes down! VC++ is obviously less restricted
and will close a standard handle.

You can fix this problem yourself.  Instead of using the Pascal
Close/CloseFile routine to close the file in the DLL, use one
of these:
}

Procedure ReallyCloseFileVar(Var F); Assembler;
{ F should be a file type }
Asm
  les  bx, F                { store F in es:bx }
  mov  bx, word ptr es:[bx] { store handle in bx }
  mov  ah, $3E              { function 3Eh = close file }
  call Dos3Call             { execute int 21h }
End;

Procedure ReallyCloseFileHandle(FileHandle: word); assembler;
{ FileHandle is the DOS file handle }
asm
  mov  bx, Handle { store handle in bx }
  mov  ah, $3E    { function 3Eh = close file }
  call DOS3Call   { execute int 21h }
end;

