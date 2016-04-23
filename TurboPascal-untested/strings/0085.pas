{
  Thanks but I already wrote a string flipping function, I asked for a
  BASM or Assembler function for optimized speed.
}

function FlipStr(S:string):string; ASSEMBLER;
ASM
        les     di,@Result
        mov     dx,ds
        lds     si,S
        xor     ax,ax
        cld
        lodsb
        mov     [di],al
        add     di,ax
        mov     cx,ax
        jcxz    @Done
@@1:    cld
        lodsb
        std
        stosb
        loop    @@1
        mov     ds,dx
END;


