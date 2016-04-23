{
MA>generate an interrupt (int $70?) 1000 times a second.

To speed up the system timer by a factor of 2, call "goosetimer(2)":
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
var goosefactor, ticklooper, cloktick: byte;
    oldtimint: procedure;

{ GOOSEFACTOR: the multiplication factor for the system speed
  TICKLOOPER:  loops from 0 to GOOSEFACTOR - 1, resetting itself to 0
               when it gets to GOOSEFACTOR -- used internally to determine
               which "ticks" get passed along
  CLOKTICK:    counts "ticks"; used in standardizing program timing
  OLDTIMINT:   points to "original" Int 08h ISR }
{--------------------------------------------------------------------------}
procedure tickwait(time2wait: byte);    { delay until counter reaches }
begin                                   { certain value }
  repeat until cloktick >= time2wait;
  cloktick := 0;                        { reset counter }
  end;
{--------------------------------------------------------------------------}
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
{--------------------------------------------------------------------------}
procedure initnewtimint(goose: byte); { set up new timer interrupt }
var gooseword: word;
begin
  goosetimer(goose);                  { speed up timer }
  goosefactor := goose;               { record speed increase }
  getintvec($08, @oldtimint);         { record location of old interrupt }
  setintvec($08, @newtimint);         { install new interrupt procedure }
  cloktick := 0;                      { set counter to 0 }
  ticklooper := 0;                    { set "extra tick" determiner to 0 }
  end;
{--------------------------------------------------------------------------}
procedure setoldtimint;               { reset old timer }
begin
  setintvec($08, @oldtimint);         { original interrupt }
  goosetimer(1);                      { original system speed }
  end;
{--------------------------------------------------------------------------}
{
To start new system timing, it's "initnewtimint"; to turn it off, it's
"setoldtimint".  Most of the rest of that code is "internal": you don't need
to worry about it.  The one procedure I haven't explained is "tickwait": it
is used to standardize timing in programs from machine to machine by waiting
for a given number of "ticks" to have gone by before continuing.  (Unlike
"Delay", "tickwait" monitors an interrupt-driven counter, meaning the number
of "ticks" is advanced even while other routines are executing.)  For
example, this loop will print a new line every 18 "ticks", which are coming
at twice the normal speed:
}
initnewtimint(2);
cloktick := 0;
while not keypressed do begin
  writeln('18 more ticks have gone by');
  tickwait(18);
  end;
setoldtimint;
