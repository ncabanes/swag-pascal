(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0014.PAS
  Description: How Much Memory
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  21:36
*)

> Can anyone help me in determining how much stack, and heap memory
> you need to give a TSR, does it depend on how many variables or how
> long your code is?

Your three requirements are based on the following:

Stack Space
-----------
This is based on how deep your procedure nesting goes, whether your
procedures are recursive and how much they'll recurse, how large the
Parameters to those procedures are, and size of local variables. Keep in
mind that you only have to cover the largest/deepest combo of everything
to be safe, not the total. TO be safe you should leave a little extra
for interrupts and stuff to use ($100 or so)
I use $2000 for most programs, and $400 for my TSR's, which will hardly
ever use that much. $400 is the minimum you can declare.
If you do alot of recursion or put huge things on the stack, use more.
Actually, use the smallest number you can get away with without an error
while stack checking is enabled.

Minimum Heap
------------
This is the LEAST heap space your program can run with. Your program
ABSOLUTELY HAS to have at least this much heap space when it's run.

You use heap space when you declare variables with New or getMem (like
with Turbo Vision or other objects)

So if you don't use any dynamic variables, you can pretty safely set
this to 0. Otherwise, set it to a reasonable number for your
application. (I mean if your database program only has memory for ONE
record, what use is it for it to run?)

Maximum Heap
------------
This is the most heap space your program WILL reserve, even if more is
available. This needs to be large enough to hold all the dynamic
variables you plan on allocating, plus a little...

Problem with reserving it ALL is that you can no longer spawn child
processes with exec. So this needs to be small enough to let other
processes you plan on running (dos shells) run, yet large enough so you
don't run out of memory easily...

This is the toughest one to set.

In programs that don't use the heap, set it to 0.

in programs that will never ever call a child process with Exec, set it
to 655360 ($100000, or all available memory)

otherwise, your guess is as good as mine...

I have my default set at 65536. ($10000)


