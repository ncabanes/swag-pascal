(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0029.PAS
  Description: Print Screen
  Author: DAVID HOWORTH
  Date: 01-27-94  12:19
*)

{
> I find myself in need of a keyboard handler that traps and hides
> the Print Screen key.  If this key is hit while in graphics mode
> on a LaserJet it causes a line of garbage to print on a thousand
> sheets of paper.... <more or less>.  I'd like to catch it and maybe
> even point it to my own print procedure if possible.  If you can
> dig something up, I'd be most grateful.  (TP6 if possible)

This is the traditional quick and dirty way to thwart PrintScreen:

mem[$0050:0000] := 1;

$0050:0000 is the PrintScreen status byte.  It is set to 1 while
PrintScreen is in operation.  If the PrintScreen button is hit
while the screen is already being printed, the print screen routine
does nothing.  By setting the status byte to 1 yourself, you fool
the PrintScreen routine into thinking the screen is already being
printed and it will terminate without doing anything until you
jiggle the status byte back to the "correct" setting.

Set the status byte back to 0 (mem[$0050:0000] := 0) at the end of
your program so your users will be able to use PrintScreen after
your program has terminated.

