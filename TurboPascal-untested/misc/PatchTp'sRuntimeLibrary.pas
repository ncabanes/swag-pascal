(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0112.PAS
  Description: Patch TP's Runtime Library
  Author: GEORGE KALEMANIS
  Date: 11-26-94  05:07
*)

{
George Kalemanis <usr5086a@tso.uc.edu>
PATCH.PAS - Patching Turbo's Runtime Library On The Fly
}

Unit patch;

Interface

{$R-,S-,I- }

Function CPUOk : Boolean;

InLine(
           { Sort out 8086/8088 from 80286/i386/i486 }
  $31/$C0/               {      XOR   AX, AX     }
  $50/                   {      PUSH  AX         }
  $9D/                   {      POPF             }
  $9C/                   {      PUSHF            }
  $58/                   {      POP   AX         }
           { If the flag register holds $F000, then it is a 8086/8088 }
  $25/$00/$F0/           {      AND   AX, $F000  }
  $3D/$00/$F0/           {      CMP   AX, $F000  }
  $74/$10/               {      JE    @@1        }
           { Sort out 80286 from 80386/80486 }
  $B8/$00/$F0/           {      MOV   AX, $F000  }
  $50/                   {      PUSH  AX         }
  $9D/                   {      POPF             }
  $9C/                   {      PUSHF            }
  $58/                   {      POP   AX         }
           { If the flag register <> 2, then it is a 80286 }
  $25/$00/$F0/           {      AND   AX, $F000  }
  $74/$04/               {      JZ    @@1        }
  $B0/$01/               {      MOV   AL, True   }
  $EB/$02/               {      JMP   Short @@2  }
  $B0/$00);              { @@1: MOV   AL, False  }
                         { @@2: }
Implementation

Const
  dummy        : LongInt = 1;

Type
  SystemProc   = Procedure;
  SystemCall   = ^SystemProc;      { Pointer to the caller's address }

Var
  CallAddr     : ^SystemCall;      { Pointer to the procedure to be patched }

{ Copy instruction pointer of caller from the stack }

Function IPtr : Word;

InLine(
  $8B/$46/$02);          {      MOV   AX, [BP+2] }

{ This patch speeds up 4-byte signed integer division by 600% }

Procedure DivisionPatch;

Const
  PatchCode    : Array[0..21] of Byte = (
           { Push dividend on the stack, pop it in a 32-bits register
             To avoid division by zero errors, extend it to a quadword }
                   $52,            {  PUSH  DX        }
                   $50,            {  PUSH  AX        }
                   $66, $58,       {  POP   EAX       }
                   $66, $99,       {  CDQ             }
           { Push divisor on the stack, pop it in a 32-bit register.
             Perform the division }
                   $53,            {  PUSH  BX        }
                   $51,            {  PUSH  CX        }
                   $66, $5E,       {  POP   ESI       }
                   $66, $F7, $FE,  {  IDIV  ESI       }
           { Push remainder on the stack, pop it in 16-bits registers }
                   $66, $52,       {  PUSH  EDX       }
                   $59,            {  POP   CX        }
                   $5B,            {  POP   BX        }
           { Push quotient on the stack, pop it in 16-bits registers }
                   $66, $50,       {  PUSH  EAX       }
                   $58,            {  POP   AX        }
                   $5A,            {  POP   DX        }
                   $CB);           {  RETF            }
Begin
  CallAddr := Ptr(CSeg, IPtr-14);
  Move(PatchCode, CallAddr^^, SizeOf(PatchCode));
end;  { LongIntDivisionPatch }

{ Provided the product > 2^16, this patch speeds up 4-byte signed integer
   multiplication by 5%  }

Procedure MultiplyPatch;

Const
  PatchCode    : Array[0..15] of Byte = (
           { Push first operand on the stack, pop it in a 32-bits register }
                   $52,            {  PUSH  DX        }
                   $50,            {  PUSH  AX        }
                   $66, $58,       {  POP   EAX       }
           { Push second operand on the stack, pop it in a 32-bits register
             Perform the multiplication }
                   $53,            {  PUSH  BX        }
                   $51,            {  PUSH  CX        }
                   $66, $5A,       {  POP   EDX       }
                   $66, $F7, $EA,  {  IMUL  EDX       }
           { Push product on the stack, pop it in 16-bits registers }
                   $66, $50,       {  PUSH  EAX       }
                   $58,            {  POP   AX        }
                   $5A,            {  POP   DX        }
                   $CB);           {  RETF            }
Begin
  CallAddr := Ptr(CSeg, IPtr-14);
  Move(PatchCode, CallAddr^^, SizeOf(PatchCode));
end;  { MultiplyPatch }

{ Shift directly across multiple words, rather than in a loop }

Procedure ShiftLeftPatch;

Const
  PatchCode    : Array[0..3] of Byte = (
                   $0F, $A5, $C2,  {  SHLD DX, AX, CL }
                   $CB);           {  RETF            }
Begin
  CallAddr := Ptr(CSeg, IPtr-14);
  Move(PatchCode, CallAddr^^, SizeOf(PatchCode));
end;  { ShiftLeftPatch }

{ Shift directly across multiple words, rather than in a loop }

Procedure ShiftRightPatch;

Const
  PatchCode    : Array[0..3] of Byte = (
                   $0F, $AD, $C2,  {  SHRD DX, AX, CL }
                   $CB);           {  RETF            }
Begin
  CallAddr := Ptr(CSeg, IPtr-14);
  Move(PatchCode, CallAddr^^, SizeOf(PatchCode));
end;  { ShiftRightPatch }

Begin  { Patch }
  If CPUOk Then                        { It's a 32-bitter }
    Begin
      dummy := dummy div dummy;
      DivisionPatch;
      dummy := dummy*dummy;
      MultiplyPatch;
      dummy := dummy shl 1;
      ShiftLeftPatch;
      dummy := dummy shr 1;
      ShiftRightPatch;
    end;
end.  { Patch }


