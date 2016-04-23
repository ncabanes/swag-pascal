{
SEAN PALMER

> Yeah, I almost think I learned assembly just to reProgram the Crt
> Unit! (except I can't seem to find out how to get to 50-line mode With
> assembly)
}

Procedure set50LineMode; Assembler;
Asm
  mov ax, $1202
  mov bl, $30
  int $10     {set 400 scan lines}
  mov ax, 3
  int $10     {set Text mode}
  mov ax, $1112
  mov bl, 0
  int $10     {load 8x8 font to page 0 block}
end;

