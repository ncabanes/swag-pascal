(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0074.PAS
  Description: Multiple Key Input
  Author: LOU DUCHEZ
  Date: 02-03-94  16:44
*)

(*
>Can someone help me out?  I need to able to read keyboard input like
>having the spacebar helddown then having the Right arrow used?

HOW TO ENABLE YOUR KEYBOARD TO READ MULTIPLE KEYS SIMULTANEOUSLY

- by Lou DuChez

Manuals will tell you that you can read port 60h to determine if a
key is being pressed/released.  What they don't tell you is, the
keyboard interrupt (09h) will instantly process the port and reset
it to zero as soon as any keyboard activity occurs; so by the time you
get to look at it, port 60h invariably contains no data for you to use.
To use port 60h, then, you'll need to alter the keyboard interrupt so
that the port's data gets stored to variables you can use.

The routine in this post will let you read multiple keys simultaneously.
I will do this by making an array [0..127] of boolean called KeyDown:
it records the status of each key on your keyboard with "true" meaning
"down."  The lower seven bits of port 60h tell you which key is being
reported on (i.e., the "scan code" of the key); the high bit indicates a
"press" if it's 0 and a "release" it it's 1.  So when you press or
release a key, my new keyboard interrupt routine will determine which key
is being altered, and set the proper element of KeyDown to the right value.

You will probably want to compile your program as "far" ({$F+}), or make
a unit out of these routines.  You will need these global variable
declarations:
______

*)
var keydown: array[0..127] of boolean;   { see the above }
    oldkbdint: procedure;       { points to the "normal" keyboard handler }
(*
______

Next, put these lines of code in your program, maybe in the "main" part:
______

*)
getintvec($09, @oldkbdint);        { record location of old keyboard int }
setintvec($09, @newkbdint);        { this line installs the new interrupt }
(*
______

We need to recall the location of the "normal" keyboard handler for two
reasons: because we'll need to restore it when the program terminates, and
because the "new" handler will need to call it.  (The "old" handler performs
certain housekeeping duties that we still need.)  This is the new keyboard
interrupt handler:
______
*)

procedure newkbdint; interrupt;
begin
  keydown[port[$60] mod 128] := (port[$60] < 128);  { record current status }
  asm pushf; end;                             { must precede call to old int }
  oldkbdint;                                  { call old interrupt }
  asm cli; end;                               { disable hardware interrupts }
  memw[$0040:$001a] := memw[$0040:$001c];     { clear the keyboard buffer }
  asm sti; end;                               { enable hardware interrupts }
  end;
(*
______

Explanations:

The "KeyDown" line checks the indicated key for a press or release.  If
the port is returning something less than 128 (i.e., high bit of "0"),
the key is not down.  The "ASM PUSHF; END" line "pushes" all the
"flags" onto the stack and is necessary before calling the original
interrupt routine on the next line.  The "ASM CLI; END" line performs
an assembler instruction to prevent hardware interrupts just long
enough for the next line to clear the keyboard buffer; then the "ASM
STI; END" line re-enables hardware interrupts.  (About the keyboard
buffer: it's a ring buffer, where a block of usually 32 bytes is used
to store unprocessed keystrokes.  It's a "ring" because there are
pointers to the "first unread" character and the "last unread"
character.  The "Memw" line sets the pointers equal to each other, thus
"clearing" the buffer.)

Finally, when you're done with your new keyboard interrupt, restore the
"normal" keyboard handler with this line:
*)
setintvec($09, @oldkbdint);
(*
And that should do it.  See the next message for the complete program ...

HOW TO ENABLE YOUR KEYBOARD TO READ MULTIPLE KEYS SIMULTANEOUSLY

From the top, your program should look like:
______
*)

{$F+}
Program KeyboardThingie;
Uses Dos;                 { needed for all the interrupt stuff }

var keydown: array[0..127] of boolean;
    oldkbdint: procedure;

procedure newkbdint; interrupt;
begin
  keydown[port[$60] mod 128] := (port[$60] < 128);  { record current status }
  asm pushf; end;                             { must precede call to old int }
  oldkbdint;                                  { call old interrupt }
  asm cli; end;                               { disable hardware interrupts }
  memw[$0040:$001a] := memw[$0040:$001c];     { clear the keyboard buffer }
  asm sti; end;                               { enable hardware interrupts }
  end;

begin { the main program }
  fillchar(keydown, 128, #0);    { sets array to all "false" }
  getintvec($09, @oldkbdint);
  setintvec($09, @newkbdint);
  {
    Put your own code here to actually do something.  The following line of
    code will report all keys that are currently "down"; to use it you'll need
    to declare "i" as a byte variable:

    while not keydown[68] do
          for i := 0 to 127 do if keydown[i] then write(i:4);
  }
  setintvec($09, @oldkbdint);
  end.
(*
______

Something to watch out for: this routine does nothing about "Ctrl-Break."
If someone hits "Ctrl-Break" while the alternate keyboard handler is
working, the program will terminate.  Which means that the block of memory
holding the "new" handler will be open to reuse by other programs.  Which
means that your system will crash.  So to prevent this, you should also
make a new "Ctrl-Break" handler.  The approach is much like the above,
but with two differences: the "Ctrl-Break" interrupt is interrupt 1Bh,
and you'll want your new handler to do absolutely nothing.  NOTHING.
As in, no lines of code between "begin" and "end."

Finally, to use all this, you'll need to know the "scan codes".  Notice
that a typical key can generate two different characters (like "1" and
"!"); the two characters have the same scan code because the same key
produces both.  Here are the scan codes:
______

"1" - "=" : $02 - $0D
"Q" - "}" : $10 - $1B
"A" - '"' (the "quote" key) : $1E - $28
"Z" - "?" : $2C - $35
F1 - F10  : $3B - $44

"space" :      $39    "~" :         $29     "|" :           $2b
"escape" :     $01    "backspace" : $0E     "control" :     $1D
"left shift" : $2A    "caps lock" : $3A     "scroll lock" : $46
"tab" :        $0F    "enter" :     $1C     "right shift" : $36
"printscreen": $37    "alt" :       $38     "home" :        $47
"up" :         $48    "page up" :   $49     "minus" (pad) : $4A
"left arrow" : $4B    "middle" key: $4C     "rightarrow":   $4D
"plus" (pad) : $4E    "end":        $4F     "down":         $50
"page down" :  $51    "insert" :    $52     "delete" :      $53
"num lock" :   $45    F11 :         $D9     F12 :           $DA
______

Use them however you want.  I tend to set up the non-character codes
(like the arrows and "enter" key) as constants.  For the "character"
codes (like '1' and 'K'), I set up an array called ScanOf: it's an
array[' '..'~'] of byte that I use to get the scan codes of characters
with.  For example, at the start of my unit that contains all this, I
load in ScanOf['3'] with $04, meaning that character '3' corresponds
to scan code $04.  Then, if I need to see if the '3' key is down,
I check:

KeyDown[ScanOf['3']]
^^^^^^^ ^^^^^
   |    converts character to scan code (i.e., which "key")
   +--- checks the specified key

"True" means "it's down."  But do what you want.
---
*)
