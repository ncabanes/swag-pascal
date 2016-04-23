
Function RandomInteger: Integer; Assembler;
asm
  mov ah,2ch
  int 21h     { Get a random seed from DOS's clock }
  imul 9821
  inc ax
  ror al,1
  rol ah,1    { Randomize the seed }
end;
