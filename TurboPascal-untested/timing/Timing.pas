(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0027.PAS
  Description: Timing...
  Author: LOU DUCHEZ
  Date: 02-28-95  10:01
*)

{
SPEEDING UP YOUR SYSTEM TIMER ... It's surprisingly easy to speed up the
system timer.  To speed up the system timer by a factor of 2, call
"goosetimer(2)", which looks like this:
}

procedure goosetimer(goose: byte);    { Speed up system timer }
var gooseword: word;
begin
  gooseword := $ffff div goose;       { Number of oscillations between ticks }
  port[$43] := $36;                   { Set timer at new speed }
  port[$40] := lo(gooseword);
  port[$40] := hi(gooseword);
  end;
{
In that procedure, you are telling the timer chip how many chip oscillations
to wait before generating a "tick".  The default is to generate a "tick"
every 65536 cycles, or 18.2 times per second (which also works out to 65536
"ticks" per hour).  The drawback here is that the system clock will speed up
accordingly, as will all functions dependent on the reception of "ticks".
So a useful approach is to reprogram Int $08 such that additional "ticks"
are not passed along to the standard system functions.  The way to
accomplish that is to generate an "End of Interrupt" command on all the
additional "ticks" instead of invoking the "original" Int 08h ISR.  The
"End of Interrupt" command is a command that, much like the STI instruction,
enables subsequent hardware interrupts to be processed.  Code is in order:
}
procedure newtimint; interrupt;   { new timer interrupt }
begin
  if ticklooper > 0 then          { "suppress" this "tick" }
    port[$20] := $20              { "End-of-Interrupt" command }
   else begin
    asm pushf; end;               { call old timer interrupt }
    oldtimint;
    end;
  inc(cloktick);                  { update "tick" counter }
  inc(ticklooper);
  if ticklooper = goosefactor then ticklooper := 0;
  end;

So start the ball rolling like so:

  goosetimer(goose);                  { speed up timer }
  goosefactor := goose;               { record speed increase }
  getintvec($08, @oldtimint);         { record location of old interrupt }
  setintvec($08, @newtimint);         { install new interrupt procedure }
  cloktick := 0;                      { set counter to 0 }
  ticklooper := 0;                    { set "extra tick" determiner to 0 }


