(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0052.PAS
  Description: Moving Memory 2 Memory
  Author: JENS LARSSON
  Date: 05-26-94  06:14
*)

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
