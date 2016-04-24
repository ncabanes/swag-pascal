(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0045.PAS
  Description: Heap Management Tools
  Author: DAVID DANIEL ANDERSON
  Date: 05-31-96  09:17
*)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
           ╔═══════════════════════════════════════════════╗
           ║ Heap management procedures, by Keld R. Hansen ║
           ║       From SWAG, in the "EXEC" section.       ║
           ╚═══════════════════════════════════════════════╝

EXECUTE shrinks your program's memory allocation to the smallest possible
value, runs the specified program, and then expands the memory allocation
again.  Tested with Turbo Pascal 6.0 and 7.0, and Borland Pascal 7.0.

Usage: Put HeapMan in your USES clause, and call Execute instead of Exec.

Notice: Do NOT SwapVectors, since HeapMan.Execute does it for you.

WARNING: DOS.DosExitCode will no longer be valid.
Instead, query Heapman.DosExitCode after calling HeapMan.Execute.
________________________________________________________________________*)

{$N-,E- no math support needed}
{$X- function calls may not be discarded}
{$I- disable I/O checking (trap errors by checking IOResult)}
{$S- no stack checking code [routine will fail without this directive!]}

Unit HeapMan;

Interface

USES
  DOS;

VAR
  DosExitCode: WORD;

PROCEDURE SetHeapManDosExitCode;
PROCEDURE ReallocateMemory(P : POINTER);
FUNCTION EXECUTE(Name : PathStr ; Tail : STRING) : WORD;

Implementation

PROCEDURE SetHeapManDosExitCode;
BEGIN
  HeapMan.DosExitCode := DOS.DosExitCode;
END;

PROCEDURE ReSetHeapManDosExitCode;
BEGIN
  HeapMan.DosExitCode := 0;
END;

PROCEDURE ReallocateMemory(P : POINTER); ASSEMBLER;
ASM
  MOV  AX, PrefixSeg
  MOV  ES, AX
  MOV  BX, WORD PTR P+2
  CMP  WORD PTR P,0
  JE   @OK
  INC  BX

 @OK:
  SUB  BX, AX
  MOV  AH, 4Ah
  INT  21h
  JC   @X
  LES  DI, P
  MOV  WORD PTR HeapEnd,DI
  MOV  WORD PTR HeapEnd+2,ES

 @X:
END;

FUNCTION EXECUTE(Name : PathStr ; Tail : STRING) : WORD; ASSEMBLER;
ASM
{$IFDEF CPU386}
  DB      66h
  PUSH    WORD PTR HeapEnd
  DB      66h
  PUSH    WORD PTR Name
  DB      66h
  PUSH    WORD PTR Tail
  DB      66h
  PUSH    WORD PTR HeapPtr
{$ELSE}
  PUSH    WORD PTR HeapEnd+2
  PUSH    WORD PTR HeapEnd
  PUSH    WORD PTR Name+2
  PUSH    WORD PTR Name
  PUSH    WORD PTR Tail+2
  PUSH    WORD PTR Tail
  PUSH    WORD PTR HeapPtr+2
  PUSH    WORD PTR HeapPtr
{$ENDIF}
  CALL ResetHeapManDosExitCode;
  CALL ReallocateMemory
  CALL SwapVectors
  CALL DOS.EXEC
  CALL SwapVectors
  CALL ReallocateMemory
  CALL SetHeapManDosExitCode
  MOV  AX, DosError
  OR   AX, AX
  JNZ  @OUT
  MOV  AH, 4Dh
  INT  21h

 @OUT:
END;

END.

