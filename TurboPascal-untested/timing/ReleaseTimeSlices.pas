(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0008.PAS
  Description: Release Time Slices
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{
Some months ago we discussed the problem With Dos Programs
that eats CPU time in multitask environments (as OS/2),
when they're idle.  I have successfully used an Inline
statement in my Pascal Programs that calls intr $28, which
is the Keyboard Busy Flag, For this purpose.  I found that
Inline statement in a TurboPower Program, which they use
to signalize to TSRs that it's OK to interrupt processing.

Here's the Inline statement I use in keyboard loops:

    Inline($CD/$28);

But...  This statement doesn't work in the Idle method of
Turbo Vision Programs...  In our previous discussion on
this subject, somebody here looked up another intr in
Ralph Brown's excellent Compilation list of interrupts.
This intr, $2F, works in another way by releasing the
reminder of unused time-slice to the operating system.
Called in a tight Program loop, this means that the
Program will free up it's idle time to the OS.

Here's a Function I made that I now use in TV's Idle method:
}

Uses
  Dos;

Function  ReleaseTimeSlice: Boolean;
Var
  Regs: Registers;

begin
  With Regs do
  begin
    AX := $1680;
    Intr($2F, Regs);
    ReleaseTimeSlice := (AL = $00);  { AL=$80 if not supported by OS }
  end;
end;

{
 ...and here's how the Idle loop Uses it in a TV Program:
}

Procedure TMyProgram.Idle;
begin
  TApplication.Idle;

  { more idle calls go here ... }
  {  :                          }

  { Inline($CD/$28); }  { this has no effect on PULSE.EXE by itself }
  ReleaseTimeSlice;     { remember to use $X+ when Compiling the Program }
end;

{
...This works fine, judging by PULSE.EXE in OS/2.
Ralph Brown also says this works in Windows, tho Windows
native Programs may not use it.
Maybe someone can comment on if it's necesarry to also
put in the Inline statement above For servicing TSRs.
I can't see any reason For not doing it, but I might've
overlooked something here...  :-)

Borland doesn't do this in their Idle method For TP/BP.
It should be quite easy to patch this in the RTL code,
For those of you that have it, and reCompile BP.
}


