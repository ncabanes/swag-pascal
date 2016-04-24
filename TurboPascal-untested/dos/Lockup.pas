(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0052.PAS
  Description: Lockup!
  Author: DAVID DUNSON
  Date: 05-25-94  08:17
*)

{
Hello All!

Here's a little procedure that just poped into mind.  It's a good way to
prevent unathorized usage of a certain task.

{ ------- CUT HERE ------- }

Program LockItUp;

Const
   Lock = $1234;

Procedure Lockup(Key: Word); Assembler;
ASM
      MOV  CX, Key
      SUB  CX, Lock
@@1:  INC  CX
      LOOP @@1
End;

Begin
   Lockup($1234);
   WriteLn('Key works!');
End.

{ ------- CUT HERE ------- }

You could give someone a registration code who's CRC value will result in the
same value as your Lock and if an incorrect value is entered, their system will
lock up (at least that task will).

Try running the program with Lockup($1235) and see what happens.  (Make sure
you don't have anything important in memory!)

Just an idea..


