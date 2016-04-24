(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0069.PAS
  Description: Do Nothing!
  Author: MARTIN RICHARDSON
  Date: 01-27-94  12:15
*)

{
>Well, Uh, I meant creating pascal compiled files, and basic compiled
>files and putting them in a BAT file so that they will execute in order.

>Oh and, uh , how to do you compile programs in tp 7 so that they are not
> broken (or shut off in the middle if someone pressed control break)?
>I can't stop the control break thing...

A common question.  Here is my solution:

{****************************************************************************
 * Procedure ..... DoNothing
 * Purpose ....... A do-nothing procedure to intercept interrupts and stop
 *                 them from happening.
 * Parameters .... None
 * Returns ....... Nothing
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... February 19, 1993
 ****************************************************************************}

{$F+}
PROCEDURE DoNothing; INTERRUPT;
BEGIN
END;
{$F-}

{****************************************************************************
 * Procedure ..... SetBreak()
 * Purpose ....... To dis-allow CTRL-BREAKING out of a program.
 * Parameters .... SetOn        False to turn CTRL-BREAK off
 *                              True to turn it back on again
 * Returns ....... Nothing
 * Notes ......... Uses the procedure DoNothing above to remap INT 1Bh to.
 * Author ........ Martin Richardson
 * Date .......... February 19, 1993
 ****************************************************************************}
PROCEDURE SetBreak( SetOn: BOOLEAN );
CONST Int1BSave : Pointer = NIL;
BEGIN
  IF NOT SetOn THEN BEGIN
     GetIntVec($1B,Int1BSave);
     SetIntVec($1B,Addr(DoNothing));
  END ELSE
      IF Int1BSave <> NIL THEN SetIntVec($1B,Int1BSave);
END;

{
However, this method will not prevent them from breaking out of the .BAT
file you described above to link the programs together with!  (You will
need a TSR to do that.)
}


