{
RAPHAEL VANNEY

> Can anybody help me out on the Function INT 33 - 9/8. It's the set mouse
> cursor Function. I see that you can draw your own mouse cursor, but I don't
> understand how to move a bitmap into Es:Dx. I don't know the size for
> the bit map to be, or the dimensions. Could anybody help me out?
}

Const Disque : Array [0..31] of Word =
      (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
       0,32766,32766,32760,32760,32766,32382,31806,
       31806,32382,32766,32382,32382,32382,32766,0);

Procedure CurseurSouris(Var Motif; x, y : Word); Assembler;
Asm
  Mov  AX, 9     { set cursor shape }
  Mov  BX, x
  Mov  CX, y
  LES  DX, Motif
  Int  $33
end ;

begin
  { ... }
  CurseurSouris(Disque, 8, 8);
  { ... }
end.
