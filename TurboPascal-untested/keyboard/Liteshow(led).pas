(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0083.PAS
  Description: LiteShow (LED)
  Author: DAVID DUNSON
  Date: 08-24-94  13:45
*)

{
 ER> Anyway, Does anyone knows who to make the num/caps/scroll
 ER> leds on the keyboard 'flicker' or just light up? (You could
 ER> create pretty cool effects like a 'walking light' on ones
 ER> keyboard..:) I checked the SWAGfiles but was not able to
 ER> find anything there..
}
Program LiteShow;
Uses Crt;

Var
   i : Byte;

Procedure SetLED(LED: Byte); Assembler;
ASM
     MOV  AL, $ED
     OUT  $60, AL
     MOV  CX, $200
@@1:
     LOOP @@1
     MOV  AL, LED
     OUT  $60, AL
End;

Begin
   i := 1;
   While not KeyPressed do
   Begin
      SetLED(i);
      i := i SHL 1;
      If i = 8 then i := 1;
      Delay(200);
   End;
   While KeyPressed do ReadKey;
End.

