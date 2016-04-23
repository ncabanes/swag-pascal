
procedure ColdBoot; assembler;
asm
  xor    ax,ax
  mov    ds,ax
  mov    ah,$40
  mov    es,ax
  mov    word ptr es:$72,0
  mov    ax,$FFFF
  mov    es,ax
  xor    si,si
  push   ax
  push   si
  retf
end;

procedure WarmBoot; assembler;
asm
  xor    ax,ax
  mov    ds,ax
  mov    ah,$40
  mov    es,ax
  mov    word ptr es:$72,$1234
  mov    ax,$FFFF
  mov    es,ax
  xor    si,si
  push   ax
  push   si
  retf
end;

