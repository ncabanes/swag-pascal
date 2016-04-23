
Procedure PurgeInput; assembler;
{ Purges the input buffer -- Empties it into obilivion! }
asm
  mov AH, $0A
  mov DX, port
  Int $14
End;



