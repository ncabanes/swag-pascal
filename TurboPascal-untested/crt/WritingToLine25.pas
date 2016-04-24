(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0019.PAS
  Description: Writing to Line 25
  Author: TOM CARROLL
  Date: 02-05-94  07:56
*)

{
SB> Hi, i got a LITTLE problem, i want to make a window that takes all 2
SB> lines of my screen.  There is a little piece of code that do this
SB> window, but when it is executed, i lost the first line, could someon
SB> help me?

Here's something that I have in my tool box that may help you out. }

PROCEDURE WriteC80_25(S, Fore, Back, Blink : Byte);
{ This procedure will write a single character to the 80th column,
  25th row of the screen without scrolling it on a color monitor }

BEGIN
   Mem[$B800:3998] := S;
   Mem[$B800:3999] := Blink + (Back SHL 4) + Fore;
END; { WriteC80_25 }

PROCEDURE WriteM80_25(S, Fore, Back, Blink : Byte);
{ This procedure will write a single character to the 80th column,
  25th row of the screen without scrolling it on a Mono monitor }

BEGIN
   Mem[$B000:3998] := Ord(S);
   Mem[$B000:3999] := Blink + (Back SHL 4) + Fore;
END; { WriteM80_25 }

What I would do in your case is I would call the appropriate procedure
for the last character that you write to the screen in your Draw_Window
routine.

Hope that helps you!

Tom Carroll

