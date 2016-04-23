
{Here is a Delphi unit to detect the CPU type, modified from Intel's
code. Use should be fairly obvious.  If not, send me email, and I can
send you an example program.  Because Delphi's assembler is 16-bit,
the code looks a little wierd.  Try using a 32-bit disassembler to see
the 32-bit instructions (or read the comments). }

unit CpuId;

{ This code comes from Intel, and has been modified for Delphi's
  inline assembler.  Since Intel made the original code freely
  available, I am making my changes freely available.

  Share and enjoy!

  Ray Lischner
  Tempest Software
  6/18/95
}

interface

type
  { All the types currently known.  As new types are created,
    add suitable names, and extend the case statement in
    CpuTypeString.
  }
  TCpuType = (cpu8086, cpu80286, cpu386, cpu486, cpuPentium);

{ Return the type of the current CPU }
function CpuType: TCpuType;

{ Return the type as a short string }
function CpuTypeString: String;

implementation

uses SysUtils;

function CpuType: TCpuType; assembler;
asm
  push DS

{ First check for an 8086 CPU }
{ Bits 12-15 of the FLAGS register are always set on the }
{ 8086 processor. }
  pushf				       { save EFLAGS }
  pop		bx		          { store EFLAGS in BX }
  mov		ax,0fffh		    { clear bits 12-15 }
  and		ax,bx		       { in EFLAGS }
  push	ax			       { store new EFLAGS value on stack }
  popf	 			       { replace current EFLAGS value }
  pushf				       { set new EFLAGS }
  pop		ax		          { store new EFLAGS in AX }
  and		ax,0f000h	    { if bits 12-15 are set, then CPU }
  cmp		ax,0f000h	    { is an 8086/8088 }
  mov 	ax, cpu8086     { turn on 8086/8088 flag }
  je		@@End_CpuType

  { 80286 CPU check }
  { Bits 12-15 of the FLAGS register are always clear on the }
  { 80286 processor. }
  or		bx,0f000h	    { try to set bits 12-15 }
  push 	bx
  popf
  pushf
  pop		ax
  and		ax,0f000h	      { if bits 12-15 are cleared, CPU=80286 }
  mov 	ax, cpu80286      { turn on 80286 flag }
  jz		@@End_CpuType

  { To test for 386 or better, we need to use 32 bit instructions,
    but the 16-bit Delphi assembler does not recognize the 32 bit
opcodes
    or operands.  Instead, use the 66H operand size prefix to change
    each instruction to its 32-bit equivalent. For 32-bit immediate
    operands, we also need to store the high word of the operand
immediately
    following the instruction.  The 32-bit instruction is shown in a
comment
    after the 66H instruction.
  }

  { i386 CPU check }
  { The AC bit, bit #18, is a new bit introduced in the EFLAGS }
  { register on the i486 DX CPU to generate alignment faults. }
  { This bit can not be set on the i386 CPU. }

  db 66h                    { pushfd }
  pushf
  db 66h                    { pop eax }
  pop	ax		                { get original EFLAGS }
  db 66h                    { mov ecx, eax }
  mov	cx,ax		             { save original EFLAGS }
  db 66h                    { xor eax,40000h }
  xor	ax,0h	                { flip AC bit in EFLAGS }
  dw 0004h
  db 66h                    { push eax }
  push ax			          { save for EFLAGS }
  db 66h                    { popfd }
  popf				          { copy to EFLAGS }
  db 66h                    { pushfd }
  pushf				          { push EFLAGS }
  db 66h                    { pop eax }
  pop	ax		                { get new EFLAGS value }
  db 66h                    { xor eax,ecx }
  xor	ax,cx		             { can't toggle AC bit, CPU=Intel386 }
  mov ax, cpu386            { turn on 386 flag }
  je @@End_CpuType

{ i486 DX CPU / i487 SX MCP and i486 SX CPU checking }
{ Checking for ability to set/clear ID flag (Bit 21) in EFLAGS }
{ which indicates the presence of a processor }
{ with the ability to use the CPUID instruction. }
  db 66h                    { pushfd }
  pushf				          { push original EFLAGS }
  db 66h                    { pop eax }
  pop	ax		                { get original EFLAGS in eax }
  db 66h                    { mov ecx, eax }
  mov	cx,ax		             { save original EFLAGS in ecx }
  db 66h                    { xor eax,200000h }
  xor	ax,0h	                { flip ID bit in EFLAGS }
  dw 0020h
  db 66h                    { push eax }
  push ax			          { save for EFLAGS }
  db 66h                    { popfd }
  popf				          { copy to EFLAGS }
  db 66h                    { pushfd }
  pushf                     { push EFLAGS }
  db 66h                    { pop eax }
  pop	ax		                { get new EFLAGS value }
  db 66h                    { xor eax, ecx }
  xor ax, cx
  mov ax, cpu486            { turn on i486 flag }
  je @@End_CpuType	       { if ID bit cannot be changed, CPU=486
}
					             { without CPUID instruction functionality }

{ Execute CPUID instruction to determine vendor, family, }
{ model and stepping.  The use of the CPUID instruction used }
{ in this program can be used for B0 and later steppings }
{ of the P5 processor. }
   db 66h                  { mov eax, 1 }
	mov ax, 1			      { set up for CPUID instruction }
   dw 0
   db 66h                  { cpuid }
	db	0Fh	               { Hardcoded opcode for CPUID
instruction }
	db	0a2h
   db 66h                  { and eax, 0F00H }
	and ax, 0F00H	         { mask everything but family }
   dw 0
   db 66h                  { shr eax, 8 }
	shr ax, 8               { shift the cpu type down to the low byte }
   sub ax, 1               { subtract 1 to map to TCpuType }

@@End_CpuType:
   pop ds
end;

function CpuTypeString: String;
var
  kind: TCpuType;
begin
  kind := CpuType;
  case kind of
  cpu8086:
    Result := '8086';
  cpu80286:
    Result := '80286';
  cpu386:
    Result := '386';
  cpu486:
    Result := '486';
  cpuPentium:
    Result := 'Pentium';
  else
    { Try to be flexible for future cpu types, e.g., P6. }
    Result := Format('P%d', [Ord(kind)]);
  end;
end;

end.
