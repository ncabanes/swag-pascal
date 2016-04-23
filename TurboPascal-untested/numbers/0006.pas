{
SEAN PALMER
}

Function rolW(b : Word; n : Byte) : Word; Assembler;
Asm
  mov ax, b
  mov cl, n
  rol ax, cl
end;

Function rolB(b, n : Byte) : Byte; Assembler;
Asm
  mov al, b
  mov cl, n
  rol al, cl
end;

Function rolW1(b : Word) : Word; Assembler;
Asm
  mov ax, b
  rol ax, 1
end;

{ These would be better off as Inline Functions, such as... }

Function IrolW1(b : Word) : Word;
Inline(
  $58/          {pop ax}
  $D1/$C0);     {rol ax,1}

{ because no Function call is generated. }

