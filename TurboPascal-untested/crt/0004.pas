{
>> Does anyone know how to clear the screen Really fast ?
>> I'm working in VGA-mode With a resolution of 320*200*256
> You could try a block rewriting of the palettes, but that would probably
> take even longer, since it is usually an interrupt instruction.

Well, use the standard pascal routine called FillChar. ;-)
}

FillChar(Mem[$A000:$0000],320*200,0);

{ You can double speed by using 16 bit wide data transfer: }

Procedure FillChar16(Var X;Count : Word;Value : Byte); Assembler;
Asm
  les   di,X
  mov   cd,Count
  shr   cx,1
  mov   al,Value
  mov   ah,al
  rep   stosw
  test  Count,1
  jz    @end
  stosb
@end:
end;

