(*
> Does anybody know, how can I free heap for use for Dos? Ex.
> {$M 16384,0,655360}
> .
> Exec('command.com','');
> .   ^------------------ Before this command I would like decrease
> heap-limit to 0 (Even I dispose all variables, exec reports memory error.

Yes.
*)

Procedure ReallocateMemory(P : Pointer); Assembler;
Asm
  Mov  AX, PrefixSeg
  Mov  ES, AX
  Mov  BX, word ptr P+2
  Cmp  Word ptr P,0
  Je   @OK
  Inc  BX
 @OK:
  Sub  BX, AX
  Mov  AH, $4A
  Int  $21
  Jc   @Out
  Les  DI, P
  Mov  Word Ptr HeapEnd,DI
  Mov  Word Ptr HeapEnd+2,ES
 @Out:
End;

Function Execute(Name, tail : pathstr) : Word; Assembler;
Asm
  Push Word Ptr HeapEnd+2
  Push Word Ptr HeapEnd
  Push Word Ptr Name+2
  Push Word Ptr Name
  Push Word Ptr Tail+2
  Push Word Ptr Tail
  Push Word Ptr HeapPtr+2
  Push Word Ptr HeapPtr
  Call ReallocateMemory
  Call SwapVectors
  Call Dos.Exec
  Call SwapVectors
  Call ReallocateMemory
  Mov  AX, DosError
  Or   AX, AX
  Jnz  @Done
  Mov  AH, $4D
  Int  $21 { Return error in will be in AX (if any) }
 @Done:
End;
{
That works great. I even use it before I run Ralf Browns SPAWNO to speed
it up if I have a full heap (the reaccolate memory)..

The execute part in pure pascal is really:
}
Function Execute(Name, tail : pathstr) : Word;
var old: longint;
begin
  old := heapend;
  ReallocateMemory(heapptr);
  Exec(name,tail);
  ReallocateMemory(old);
  execute := doserror;
end;
{
But re-written for optimization.
}
