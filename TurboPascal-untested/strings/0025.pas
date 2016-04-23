{
SEAN PALMER

these routines change formats 'in place' without changing the number of
bytes, ever, so you can safely use $V-
}

unit asciiz;  {routines for converting strings to asciiz and back}

interface

procedure asciiz2string(var a : string);
procedure string2asciiz(var s : string);

implementation

{note: any asciiz must be length 255 or less}

procedure asciiz2string(var a : string); assembler;
asm
  push ds
  cld
  lds  si, a
  mov  cx, 0
 @L:
  xchg al, byte ptr[si]
  inc  si
  or   al, al
  jnz  @L
  mov  ax, si
  mov  si, word ptr a
  sub  ax, si   {calc length}
  dec  ax
  mov  [si], al
  pop  ds
end;

procedure string2asciiz(var s : string); assembler;
asm
  push  ds
  lds   si, s
  les   di, s
  lodsb
  mov   cl, al
  xor   ch, ch
  cld
  rep   movsb
  xor   al, al
  stosb
  pop   ds
end;

end.

