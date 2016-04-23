>     Hi!  I was wondering.. does anyone have any TP codes to find
 > out what type
 > of machine (ie. XT, 286, 386, 486, Pentium, etc) that the user
 > is running?
 > The type of coding (Inline Assembly or BASM).. I don't care..
 > just make sure
 > that it is usable by Turbo Pascal 6.0 =8)  Thanks!

{
  GetCPU                             Byte
  ───────────────────────────────────────
  Ermittelt den arbeitenden CPU-Typ.  Der
  zurückgelieferte Code entspricht:

     0 - Intel 8088
     1 - Intel 8086
     2 - NEC V20
     3 - NEC V30
     4 - Intel 80188
     5 - Intel 80186
     6 - Intel 80286 (or Harris or... whatever)
     7 - Intel 80386 (or AMD or Cyrix (?) or... whatever)
     8 - Intel 80486 (or AMD or Cyrix (?) or... ;))
     9 - Intel Pentium (still looking forward for clones... ;))
}
Function GetCPU: Byte; Assembler;
Const processor: Byte= $FF;
Asm
    mov  al, processor
    cmp  al, 0FFh
    jne  @get_out
    pushf
    xor  bx,bx
    push bx
    popf
    pushf
    pop  bx
    and  bx,0F000h
    cmp  bx,0F000h
    je   @no286
    mov  bx,07000h
    push bx
    popf
    pushf
    pop  bx
    and  bx,07000h
    jne  @test486
    mov  dl,6
    jmp  @end
@test486:
    mov  dl,7
    xor  si,si
    mov  ax,cs
{$IFDEF DPMI}
    add  ax,SelectorInc
{$ENDIF}
    mov  es,ax
    mov  byte ptr es:[@queue486+11], 46h     { 46h == "INC SI" }
@queue486:
    nop; nop; nop; nop; nop; nop; nop; nop; nop; nop; nop; nop
    or   si,si
    jnz  @end
    inc  dl
    db   66h ; pushf      { pushfd }
    db   66h ; pushf      { pushfd }
    db   66h ; pop  ax    { pop eax }
    db   66h ; mov  cx,ax { mov ecx,eax }
    db   66h,35h
    db   00h,00h,20h,00h  { xor eax,(1 shl 21) (Pentium ID flag) }
    db   66h ; push ax    { push eax }
    db   66h ; popf       { popfd }
    db   66h ; pushf      { pushfd }
    db   66h ; pop  ax    { pop eax }
    db   66h,25h
    db   00h,00h,20h,00h  { and eax,(1 shl 21) }
    db   66h,81h,0E1h
    db   00h,00h,20h,00h  { and ecx,(1 shl 21) }
    db   66h ; cmp ax,cx  { cmp eax,ecx }
    je   @is486
    inc  dl
@is486:
    db   66h ; popf       { popfd }
    jmp  @end
@no286:
    mov  dl,5
    mov  al,0FFh
    mov  cl,21h
    shr  al,cl
    jnz  @testdatabus
    mov  dl,2
    sti
    xor  si,si
    mov  cx,0FFFFh
{$IFDEF DPMI}
    push es
    push ds
    pop  es
{$ENDIF}
    rep  seges lodsb      { == rep lods byte ptr es:[si] }
{$IFDEF DPMI}
    pop  es
{$ENDIF}
    or   cx,cx
    jz   @testdatabus
    mov  dl,1
@testdatabus:
    push cs
{$IFDEF DPMI}
    pop  ax
    add  ax,SelectorInc
    mov  es,ax
{$ELSE}
    pop  es
{$ENDIF}
    xor  bx,bx
    std
    mov  al,90h
    mov  cx,3
    call @ip2di
    cli
    rep  stosb
    cld
    nop; nop; nop
    inc  bx
    nop
    sti
    or   bx,bx
    jz   @end      { v20 or 8086 or 80186 }
    cmp  dl,1
    je   @its8088
    cmp  dl,2
    je   @itsV30
    cmp  dl,5
    jne  @end
    mov  dl,4
    jmp  @end
@its8088:
    xor  dl,dl
    jmp  @end
@itsV30:
    mov  dl,3
    jmp  @end
@ip2di:
    pop  di
    push di
    add  di,9
    retn
@end:
    popf
    mov  al,dl
    mov  processor,al
@get_out:
End;
