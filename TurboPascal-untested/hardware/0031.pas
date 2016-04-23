{
I'm looking for a SMALL piece of code which can be used to replace a DELAY
command that will be cpu-intensive, meaning that it will execute more quick
depending upon the type of cpu and clock speed.  I know that obviously any
code will exhibit this tendency, but I'm looking for something which do so
a most dramatic fashion (as far as speed goes).  It should also be rather
small and not necessarily zeroing in on the presence of an FPU.  Any ideas?
}

Procedure CPUDelay(D: Word); Assembler;
asm
  @@1:
    mov cx,$FFFF
  @@2:
    nop
    loop @@2
    dec[d]
    jnz @@1
end;
