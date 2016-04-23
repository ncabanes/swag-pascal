{
In answer to a fellow subscriber's request, I recently posted to this list a
Delphi Assembler procedure to reverse ShortStrings. After someone pointed out
to me in a private message that my routine was slower than his all-Pascal
alternative, I tried again, and managed to come up with an asm procedure that
actually has a (modest) speed advantage. It is presented below, in case
anyone else can use it.

--Paul Sobolik
}
procedure RevString3(var s: ShortString); assembler;
asm
  push esi
  push edi

  mov esi,eax
  mov edi,eax
  xor eax,eax
  lodsb
  add edi,eax
  dec edi
  add eax,2
  shr eax,2
  mov ecx,eax
  jecxz @@done
@@loop:
  mov ax,[esi]
  mov dx,[edi]
  xchg al,ah
  mov [edi],ax
  sub edi,2
  xchg dl,dh
  mov [esi],dx
  add esi,2
  dec ecx
  jnz @@loop
@@done:
  pop edi
  pop esi
end;

