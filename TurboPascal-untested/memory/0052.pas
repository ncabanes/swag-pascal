{This copies NumBytes from SourceOfs to DestOfs:}

Procedure MoveGfxMem(NumBytes, SourceOfs, DestOfs : Word); Assembler;
 Asm
  push  ds
  mov   ax,0a000h
  mov   ds,ax
  mov   es,ax
  mov   si,SourceOfs
  mov   di,DestOfs
  mov   cx,NumBytes
  cld
  rep   movsb
  pop   ds
 End;

