{
Here is the code I use, adapted from the Intel Pentium Processor User's
Manual, Chapter 5.  It sets the Test8086 global variable, making the values
of Test8086:


   0 = 8086
   1 = 80186/80286
   2 = 80386
   3 = 80386   (new)
   4 = 80486   (new)
   5 = Pentium (new)
   6 = ??


Note that for Pentium and higher CPUs, the new CPUID instruction is used to
retrieve the processor family number.  This code should work on post-Pentium
(80686-class) CPUs and Pentium compatibles, and could return numbers > 5.
}

 program CPUTest;
 {$IFDEF WINDOWS}
 uses wincrt;
 {$ELSE}
 uses crt;
 {$ENDIF}

 begin
  if (Test8086 = 2) then         { RTL check stops at 2 = 386}
  asm
             inc    Test8086     { 3 = 386, for consistency }
    { Do we have a 386 or a 486? }
    { Does pushf/popf preserve the Alignment Check bit? (386=no, 486=yes) }
             mov    bx, sp       { save current stack pointer }
             and    sp, not 3    { align stack to avoid AC fault }
    db $66;  pushf
    db $66;  pop    ax
    db $66;  mov    cx, ax
    db $66, $35; dd $40000       { xor AC bit in EFLAGS }
    db $66;  push   ax
    db $66;  popf
    db $66;  pushf
    db $66;  pop    ax
    db $66;  xor    ax, cx       { Is AC bit toggled? }
             je @@1              { if not, we have a 386 }
             and    sp, not 3    { align stack to avoid AC fault }
    db $66;  push   cx
    db $66;  popf                { restore original AC bit }
             mov    sp, bx       { restore original stack pointer }
             mov  Test8086, 4    { we know we have at least a 486 }

    { Do we have a 486 or a Pentium? }
    { Does pushf/popf preserve the CPUID bit? (486=no, P5=yes) }
    db $66;  mov    ax, cx       { get original EFLAGS}
    db $66, $35; dd $200000      { XOR id bit in flags}
    db $66;  push   ax
    db $66;  popf
    db $66;  pushf
    db $66;  pop    ax
    db $66;  xor    ax, cx      { Is CPUID bit toggled? }
             je @@1             { if not, we have a 486 }
    db $66;  xor    ax, ax
    db $f,$a2                   { CPUID, AX = 0 (get CPUID caps) }
    db $66;  cmp    ax, 1
             jl @@1             { if < 1, then exit }
    db $66;  xor    ax, ax
    db $66;  inc    ax
    db $f,$a2                   { CPUID, AX = 1 (get CPU info)   }
             and    ax, $f00    { mask out all but family id }
             shr    ax, 8
             mov    Test8086, al      { Pentium family = 5 }
   @@1:
  end;

  writeln('Test8086: ',Test8086);
 end.

