{
WILLIAM MCBRINE

> I am looking For a Procedure to clear a screen in mode $13.  Writing
> black pixels to each position isn't quite fast enough!

This assumes that color 0 is black.
}

Procedure clearmode13; Assembler;
Asm
  cld
  mov ax, $A000
  mov es, ax
  xor di, di
  xor ah, ah
  mov cx, 32000
  rep stosw
end;

