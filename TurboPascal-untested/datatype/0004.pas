{
SEAN PALMER

generic compare Function...
make sure to keep garbage out of Strings (by filling With #0
before storing the Strings) and you can compare ANY data With this.
}

Function equal(Var m1, m2; siz : Word) : Boolean; Assembler;
Asm
  push ds
  cld
  les di, m1
  lds si, m2
  mov cx, siz
  xor al, al
  repe cmpsb
  jne @S
  inc al
 @S:
  pop ds
end;
