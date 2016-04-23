function addString(st1,st2 : string):string;assembler;

 asm
  push DS
  cld
  lds SI,st1
  les DI,@result
  mov BX,DI
  lodsb
  mov DL,255
  sub DL,AL
  xor AH,AH
  mov CX,AX
  stosb
  repz
  movsb
  lds SI,st2
  lodsb
  cmp AL,DL
  jna @nooverflow
  mov AL,DL
  @nooverflow:
  mov CX,AX
  repz
  movsb
  add ES:[BX],AL
  pop DS
 end;
