(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0076.PAS
  Description: Color Bars
  Author: THORSTEN BARTH
  Date: 01-27-94  11:56
*)

{
> im coding a program at the moment that needs to have a scrolly bar
> menu. I have got all the movement's worked out, however! I cannot
> work out how to have some sort of bar (like in PowerMenu)... you press
> enter when the scrolly bar hits your desired selection and it
> executes another procedure or function...

As I understand your problem, you need to know how to display a bar on
the screen where the screen and text have different colors, and then,
after moving away, restore the original colors in that bar. I hope
you have found out how to handle the cursor keys.
... searching for routines ... loading ... clipping
}

Procedure Colorbar(X,Y,Count: Word;Color: Byte); Assembler;
Asm
  MOV AX,80
  MUL Y
  ADD AX,X
  SHL AX,1
  INC AX
  MOV DI,AX
  MOV AX,Vidseg
  MOV ES,AX
  MOV CX,Count
  MOV AL,Color
@@1: STOSB
     INC DI
   LOOP @@1
End;
{

Give that procedure the vidseg ($B000 for Hercules or $B800 for the rest),
then call it. It sets a part of the screen to the color given to it.
The color values are 16*Backgroundcolor + Forgroundcolor, using the
color constants of the unit CRT. Add $80 to get it blink.
To delete the bar, just set the neutral color you have used while drawing
the screen.
BTW, there is no error checking in that routine, so giving bad values will
cause problems. You can use it for painting many lines by giving a larger
"count" parameter to it.
}
