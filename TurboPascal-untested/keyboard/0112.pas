Program leds;
Uses Crt;

Var
   l : Byte;

Procedure led(led: Byte); Assembler;
ASM
     mov  AL, $ED
     out  $60, AL
     mov  CX, $200
@@1:
     loop @@1
     mov  AL, led
     out  $60, AL
End;

Begin
   l := 1;
   While not KeyPressed do
   Begin
      led(l);
      l := l SHL 1;
      If l = 8 then l := 1;
      Delay(200);
   End;
   While KeyPressed do ReadKey;
End.
