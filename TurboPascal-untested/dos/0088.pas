{ Boot system
 If warm is true a warm boot is performed, else a cold boot }
Procedure Boot (Warm:Boolean);
Begin
Asm
  sti
  cmp Warm, 0
  je  @cold
  mov AX, 0
  jmp @boot
 @cold:
  mov AX, 1
 @boot:
  mov DS, AX
  mov AX, 1234h
  mov [0472h], AX
 End;
Inline ($EA/$00/$00/$FF/$FF);
End;
