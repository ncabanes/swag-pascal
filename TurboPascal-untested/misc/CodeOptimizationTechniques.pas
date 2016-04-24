(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0150.PAS
  Description: Code Optimization Techniques
  Author: ERIK TURNER
  Date: 05-26-95  23:23
*)

{
   The following text was written by Erik Turner (eturner@ccd.harris.com)

"Here are some suggestions for reducing the size of your code.  I needed to
do this because I was trying to reduce the size of a TSR to bare minimum.

A) Remove all Write,Writeln,Read,Readln statements.  Replace with assembler
   procedures to call DOS (saves about 3K).

B) Inspect your code for any string variables.  Try to use as few as possible
   and make them only as long as needed.

C) Turn off range checking.  This adds code overhead to every array reference.

D) Turn off stack checking.  This adds code overhead to each procedure call.

E) Insure that your heap is as small as possible (preferably zero).

F) Insure that your stack is as small as possible (do not use large procedure
   local variables).  It is possible for carefully written BP programs to
   use only 1024 bytes (or less) of stack space.

G) Do not use real numbers unless your program requires a math coprocessor.
   Insure that the Real and 8087 emulation libraries are not being linked in.

H) If you have any large data structures, consider encoding the data so that
   it takes less space (possibly at the expense of execution speed).  
   For example, instead of 
     Array[0..31] of Boolean    (32 bytes)
   use
     Longint                    (4 bytes)

I) Do not use CRT unit.  Replace with calls to DOS routines (see A).

J) Avoid objects with virtual methods.  Really avoid objects from any of 
   Borland supplied units.  These objects come with lots of baggage in the
   form of extra code and data fields.

K) Combine all units into main program and enable near calls.  This will
   reduce overhead by shorter calls and the 8(?) bytes of overhead per unit."
}


