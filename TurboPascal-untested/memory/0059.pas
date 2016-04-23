{
 CF> Ok I know in pascal you can basiclly us up t0 64k for varibles.... But how
 CF> can I set it up to use... lets say 256k for varibles.  I mean, -XMS-
 CF> memeory?                                 =- Chris Forbis

First, you may allocate 256k without XMS. Just using the following routines:


function DosMaxAvail : longint;
function MemAlloc(Size : longint) : pointer;
function MemFree(P : pointer) : integer;
function MemRealloc(P : pointer; NewSize : longint) : integer;
}

Function DosMaxAvail : longint; assembler;
{ Returns the size of the largest contiguous free memory block
  This function should be called ONLY when both HeapMin/HeapMax
  memory allocation parameters set to zero }
Asm
  MOV BX,0FFFFh
  MOV AH,48h
  INT 21h
  MOV AX,BX
  MOV BX,16
  MUL BX
End; { DosMaxAvail }

Function MemAlloc(Size : longint) : pointer; assembler;
{ Creates a dynamic variable of the specified size and returns the pointer
  to it. This function should be called ONLY when both HeapMin/HeapMax
  memory allocation parameters set to zero }
Asm
@@1:
  MOV AX,WORD PTR [Size]
  MOV DX,WORD PTR [Size+2]
  MOV CX,16
  DIV CX
  INC AX
  MOV BX,AX
  MOV AH,48h
  INT 21h
  JNC @@2
  XOR AX,AX
@@2:
  MOV DX,AX
  XOR AX,AX
End; { MemAlloc }

Procedure MemFree(P : pointer); assembler;
{ Disposes of a given dynamic variable. This function should be called ONLY
  when both HeapMin/HeapMax memory allocation parameters set to zero }
Asm
  MOV ES,WORD PTR [P+2]
  MOV AH,49h
  INT 21h
End; { MemFree }

Function MemRealloc(P : pointer; NewSize : longint) : pointer; assembler;
{ Changes the size of en existed memory block. This function should be called
  ONLY when both HeapMin/HeapMax memory allocation parameters set to zero }
Asm
@@1:
  MOV AX,WORD PTR [NewSize]
  PUSH AX
  MOV DX,WORD PTR [NewSize+2]
  PUSH DX
  MOV CX,16
  DIV CX
  INC AX
  MOV BX,AX
  MOV AH,4Ah
  INT 21h
  POP DX
  POP AX
  JNC @@2
  XOR DX,DX
  XOR AX,AX
@@2:
End; { MemRealloc }

{ Okey, the main program: }

{$M 4096,0,0}

const MemToAlloc = 256 * 1024; { 256k }
var MemoryBlock : pointer;
Begin
  if DosMaxAvail >= MemToAlloc then
  begin
    WriteLn('Dos free memory before allocating ',
      MemToAlloc shr 10, 'kb: ', DosMaxAvail shr 10, 'kb.');
    MemoryBlock := MemAlloc(MemToAlloc);
    WriteLn('Dos free memory after allocating ',
      MemToAlloc shr 10, 'kb: ', DosMaxAvail shr 10, 'kb.');
    { if MemoryBlock = nil then report an error... }
    MemFree(MemoryBlock)
  end else WriteLn('Not enough memory. ',
    (MemToAlloc - DosMaxAvail) shr 10, 'kb more needed.')
End.

