(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0095.PAS
  Description: Multiple Keys as in Games
  Author: MIKE SZCZUR
  Date: 05-26-95  23:10
*)

(*
»Does anyone know how Pascal could recognize two keys pressed at once,
»like what might happenhen two players on a game, one using the keypad,
»and one the keyboard might do??

Check out this text file and the code will follow.

-!- text begins ---

How to use GAMES.TPU -- overview -- by Lou DuChez, Pascal-kind-of-guy

GAMES.TPU is a Turbo Pascal unit designed to rework the keyboard and timer
interrupts to better function in game writing.  The keyboard is the biggest
problem in a lot of games: the keyboard buffer reads keys sequentially, but you
want simultaneous reads for action games.  Now scan codes for key presses and
releases are transmitted through port 60h, so it seems like it should be
possible just to keep an eye on that memory location.  Unfortunately, interrupt
09h (the keyboard interrupt) ends up resetting the port to 0 before you can
rwad the contents.  So I wrote a new interrupt handler that does these steps:

1)  reads port 60h and records presses / releases;
2)  calls the regular keyboard interrupt;
3)  clears the keyboard buffer.

All key presses are stored in an array of 128 boolean values.  I've found that
you can keep track of about six keys simultaneously -- more than enough for
most games.

I've also found it useful to nullify the "Ctrl-Break" interrupt.  Basically,
you don't want to "Ctrl-Break" out of a Pascal program before resetting the
keyboard interrupt, so I made a "Ctrl-Break" interrupt that does absolutely
nothing.

Finally, when you write an action game, you want it to run at the same speed on
all computers, be they original PC's or 486's.  The best way to do that is to
monitor the computer's timer; I wrote an interrupt that will pause until a
fixed number of "ticks" (18.2 per second) go by.

                      GAMES.TPU -- the Keyboard interrupt

You install the new keyboard interrupt by invoking procedure INITNEWKEYINT (and
reset to the old one by invoking SETOLDKEYINT).  As mentioned before, the
status of the keys is recorded in a boolean array (from 0 to 127) called
KEYDOWN.  A "True" indicates the key is down; a "False" indicates it is not.
So your program just has to check this array periodically to see what keys are
down.

Now as for figuring out which array elements correspond to which keys: I
provide two ways.  First of all, there is a function "SCANOF": it takes a
character argument, and returns (as a byte) what scan code corresponds to the
character (more accurately, the key that makes the character).  If, for
example, you need to know the scan code of the "1" key, you'd want the value
returned by SCANOF('1') (or SCANOF('!'), since you're trying to see if the
"1"/"!" key is down, and the "Shift" keys aren't an issue).  In particular,
you'd know that the "1" key is down if KEYDOWN[SCANOF('1')] was "True".

The SCANOF function works for all the alphanumeric and punctuation keys; it
doesn't work for the arrows, "NumLock", function keys, etc. because there's no
particular characters to associate with them.  So here are some constants that
you can use instead:

CONSTANT  VAL  DESCRIPTION              CONSTANT  VAL  DESCRIPTION

escscan   $01  "Esc"                    entscan   $1c  "Enter"
backscan  $0e  Backspace                rshscan   $36  Right Shift
ctrlscan  $1d  "Ctrl"                   prtscan   $37  "PrntScrn"
lshscan   $2a  Left Shift               altscan   $38  "Alt"
capscan   $3a  "CapLock"                homescan  $47  "Home"
f1scan    $3b  F1                       upscan    $48  Up Arrow
f2scan    $3c  F2                       pgupscan  $49  "Pg Up"
f3scan    $3d  F3                       minscan   $4a  "-" on keypad
f4scan    $3e  F4                       leftscan  $4b  Left Arrow
f5scan    $3f  F5                       midscan   $4c  "5" on keypad
f6scan    $40  F6                       rightscan $4d  Right Arrow
f7scan    $41  F7                       plusscan  $4e  "+" on keypad
f8scan    $42  F8                       endscan   $4f  "End"
f9scan    $43  F9                       downscan  $50  Down Arrow
f10scan   $44  F10                      pgdnscan  $51  "Pg Down"
f11scan   $d9  F11                      insscan   $52  "Ins"
f12scan   $da  F12                      delscan   $53  "Del"
scrlscan  $46  "ScrollLock"             numscan   $45  "Num Lock"
tabscan   $0f  Tab

Is the left arrow down?  It is, if KEYDOWN[LEFTSCAN] is "True".

There is a second array of booleans (0 to 127), called WASDOWN: it records
whether or not a key has been depressed in a period of time.  This is more
useful for keys that get tapped instead of continuously held down: for example,
a movement key is held, but a fire button is tapped.  Has the Space Bar been
pressed?  Only if WASDOWN[SCANOF(' ')] is "True".  A procedure to use with the
WASDOWN array is CLEARWASDOWNARRAY:  resets all the elements of WASDOWN to
"False".  ("FOR COUNTER := 0 TO 127 DO WASDOWN[COUNTER] := FALSE")  So you
reset the array with CLEARWASDOWNARRAY, and WASDOWN will record all the keys
that have been pressed until you call CLEARWASDOWNARRAY again.

                     GAMES.TPU -- the "Ctrl-Brk" interrupt

This one takes little to no explanation.  Call INITNEWBRKINT to call the new
interrupt (essentially, to disable it); call SETOLDBRKINT to reset it.

                       GAMES.TPU -- the Timer interrupt

18.2 times per second, the computer generates a "tick", calls hardware
interrupt 08h, updates its clock/calendar, does various house-cleaning
functions, and then calls interrupt 1Bh.  1Bh is an interrupt for programmers
to hook their programs onto for timing purposes; that's exactly what GAMES.TPU
does.  Invoke the new timer handler with INITNEWTIMINT (and disable it with
SETOLDTIMINT); it first calls whatever TSR's might be using that interrupt
already, then it increments a counter.  You indirectly access that counter by
the procedure TICKWAIT: the computer waits until the counter gets to the number
of ticks specified before doing anything else (byte values only).  Once that
number has been reached, the counter resets to 0.

I think an example is in order: let's say you have an action game where each
round should take one-half second on any machine.  So at the beginning of the
first round, call TICKWAIT(0) (to set the tick counter to 0).  At the end of
each round, call TICKWAIT(9) (to wait out the half second).  Now between those
steps, while the computer has been drawing things on the screen, updating enemy
positions, etc., the tick counter has been automatically incrementing every
.055 seconds.  On a 4.77Mhz XT, the counter may have gotten to 6 by the time
the program gets to the TICKWAIT(9) statement, which waits three more ticks
before proceeding to the next step.  On a 486, the tick counter might get only
to 1 before encountering the TICKWAIT(9); in which case, the computer will wait
eight ticks before proceeding.  So you can make programs that run at the same
speed on any computer via the timer interrupt and TICKWAIT.

Some sample pseudocode:

program gamething;
uses games;

procedure movefoes;
     begin
       .
       .
     end;

procedure firephasers;
     begin
       .
       .
     end;

procedure updatescore;
     begin
       .
       .
     end;

procedure playgame;
     begin
     repeat begin
          movefoes;
          firephasers;
          updatescore;
          tickwait(2);
          end until igotblownup;
     end;

begin {main program}
initnewtimint;
tickwait(0);
playgame;
setoldtimint;
end.
*)
{
Included are GAMES.PAS (compile it yourself -- I wrote it via Turbo Pascal 6.0,
but it ought to work on 4 and 5 too), and RAIDERS.EXE, a game I wrote using all
those interrupts.  Enjoy!

-!- text ends ---

-!- code begins ---
}
{$F+}
unit games;

interface

{ constants for scan codes of various keys }

const escscan: byte = $01;
      backscan: byte = $0e;
      ctrlscan: byte = $1d;
      lshscan: byte = $2a;
      capscan: byte = $3a;
      f1scan: byte = $3b;
      f2scan: byte = $3c;
      f3scan: byte = $3d;
      f4scan: byte = $3e;
      f5scan: byte = $3f;
      f6scan: byte = $40;
      f7scan: byte = $41;
      f8scan: byte = $42;
      f9scan: byte = $43;
      f10scan: byte = $44;
      f11scan: byte = $d9;
      f12scan: byte = $da;
      scrlscan: byte = $46;
      tabscan: byte = $0f;
      entscan: byte = $1c;
      rshscan: byte = $36;
      prtscan: byte = $37;
      altscan: byte = $38;
      homescan: byte = $47;
      upscan: byte = $48;
      pgupscan: byte = $49;
      minscan: byte = $4a;
      leftscan: byte = $4b;
      midscan: byte = $4c;
      rightscan: byte = $4d;
      plusscan: byte = $4e;
      endscan: byte = $4f;
      downscan: byte = $50;
      pgdnscan: byte = $51;
      insscan: byte = $52;
      delscan: byte = $53;
      numscan: byte = $45;

{ arrays that record keyboard status }

var keydown, wasdown: array[0..127] of boolean;

{ procedures/functions you may call }

procedure initnewkeyint;
procedure setoldkeyint;
procedure clearwasdownarray;
procedure initnewtimint;
procedure setoldtimint;
procedure initnewbrkint;
procedure setoldbrkint;
function scanof(chartoscan: char): byte;
procedure tickwait(time2wait: byte);


implementation
uses dos;

{ pointers to old interrupt routines }

var oldkbdint, oldtimint, oldbrkint: pointer;
    cloktick: byte; { counter to count clock "ticks" }

procedure sti;
inline($fb);    { STI: set interrupt flag }

procedure cli;
inline($fa);    { CLI: clear interrupt flag -- not used }

procedure calloldint(sub: pointer);

{ calls old interrupt routine so that your programs don't deprive the computer
  of any vital functions -- kudos to Stephen O'Brien and "Turbo Pascal 6.0:
  The Complete Reference" for including this inline code on page 407 }

begin
  inline($9c/           { PUSHF }
         $ff/$5e/$06)   { CALL DWORD PTR [BP+6] }
end;

procedure newkbdint; interrupt;   { new keyboard handler }
begin
  keydown[port[$60] mod 128] := (port[$60] < 128);  { key is down if value of
                                                      60h is less than 128 --
                                                      record current status }
  if port[$60] < 128 then wasdown[port[$60]] := true; { update WASDOWN if the
                                                        key is currently
                                                        depressed }
  calloldint(oldkbdint);                              { call old interrupt }
  mem[$0040:$001a] := mem[$0040:$001c];   { Clear keyboard buffer: the buffer
                                            is a ring buffer, where the com-
                                            puter keeps track of the location
                                            of the next character in the buffer
                                            end the final character in the
                                            buffer.  To clear the buffer, set
                                            the two equal to each other. }
  sti
end;

procedure initnewkeyint;      { set new keyboard interrupt }
var keycnt: byte;
begin
  for keycnt := 0 to 127 do begin   { reset arrays to all "False" }
    keydown[keycnt] := false;
    wasdown[keycnt] := false
    end;
  getintvec($09, oldkbdint);        { record location of old keyboard int }
  setintvec($09, addr(newkbdint));  { this line installs the new interrupt }
  sti
end;

procedure setoldkeyint;           { reset old interrupt }
begin
  setintvec($09, oldkbdint);
  sti
end;

procedure clearwasdownarray;      { set all values in WASDOWN to "False" }
var cnter: byte;
begin
  for cnter := 0 to 127 do wasdown[cnter] := false
end;

function scanof(chartoscan: char): byte;  { return scan code corresponding
                                            to a character }
var tempbyte: byte;
begin
  tempbyte := 0;
  case upcase(chartoscan) of
    '!', '1': tempbyte := $02;
    '@', '2': tempbyte := $03;
    '#', '3': tempbyte := $04;
    '$', '4': tempbyte := $05;
    '%', '5': tempbyte := $06;
    '^', '6': tempbyte := $07;
    '&', '7': tempbyte := $08;
    '*', '8': tempbyte := $09;
    '(', '9': tempbyte := $0a;
    ')', '0': tempbyte := $0b;
    '_', '-': tempbyte := $0c;
    '+', '=': tempbyte := $0d;
    'A': tempbyte := $1e;
    'S': tempbyte := $1f;
    'D': tempbyte := $20;
    'F': tempbyte := $21;
    'G': tempbyte := $22;
    'H': tempbyte := $23;
    'J': tempbyte := $24;
    'K': tempbyte := $25;
    'L': tempbyte := $26;
    ':', ';': tempbyte := $27;
    '"', '''': tempbyte := $28;
    '~', '`': tempbyte := $29;
    ' ': tempbyte := $39;
    'Q': tempbyte := $10;
    'W': tempbyte := $11;
    'E': tempbyte := $12;
    'R': tempbyte := $13;
    'T': tempbyte := $14;
    'Y': tempbyte := $15;
    'U': tempbyte := $16;
    'I': tempbyte := $17;
    'O': tempbyte := $18;
    'P': tempbyte := $19;
    '{', '[': tempbyte := $1a;
    '}', ']': tempbyte := $1b;
    '|', '\': tempbyte := $2b;
    'Z': tempbyte := $2c;
    'X': tempbyte := $2d;
    'C': tempbyte := $2e;
    'V': tempbyte := $2f;
    'B': tempbyte := $30;
    'N': tempbyte := $31;
    'M': tempbyte := $32;
    '<', ',': tempbyte := $33;
    '>', '.': tempbyte := $34;
    '?', '/': tempbyte := $35
    end;
  scanof := tempbyte
end;

procedure newtimint; interrupt;   { new timer interrupt }
begin
  calloldint(oldtimint);          { call old timer interrupt }
  cloktick := cloktick + 1        { update "tick" counter }
end;

procedure initnewtimint;              { set up new timer interrupt }
begin
  getintvec($1c, oldtimint);          { record location of old interrupt }
  setintvec($1c, addr(newtimint));    { install new interrupt procedure }
  cloktick := 0;                      { set counter to 0 }
  sti
end;

procedure setoldtimint;               { reset old timer }
begin
  setintvec($1c, oldtimint);
  sti
end;

procedure tickwait(time2wait: byte);    { do nothing until counter reaches
                                          certain value }
begin
  repeat until cloktick >= time2wait;
  cloktick := 0                         { reset counter }
end;

procedure newbrkint; interrupt;   { new "Ctrl-Break" interrupt: does nothing }
begin
  sti
end;

procedure setoldbrkint;           { reset old "Ctrl-Break" interrupt }
begin
  setintvec($1b, oldbrkint);
  sti
end;

procedure initnewbrkint;              { install new "Ctrl-Break" interrupt }
begin
  getintvec($1b, oldbrkint);          { get old interrupt location }
  setintvec($1b, addr(newbrkint));    { set up new interrupt procedure }
  sti
end;

end.

