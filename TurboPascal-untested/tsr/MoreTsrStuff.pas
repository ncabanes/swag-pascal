(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0015.PAS
  Description: More TSR Stuff
  Author: LOU DUCHEZ
  Date: 11-02-93  06:32
*)

{
LOU DUCHEZ

>I recently wrote a short utility in TP.  I want to make it a TSR
>which can be activated by a hotkey (like ALT-R).  Do I need to
>redirect the Keyboard INT to my Program?

Right on the nose.

>if so, then where does my Program direct the INT after that?

To the OLD keyboard interrupt.  You can use the GetIntVec to find
where the interrupt originally pointed; and trust me, it's a royal
pain in the keister to Program your own.  (Note: you'll want to
execute a PUSHF instruction before calling the "old" interrupt;
easily done With the built-in Assembler: Asm PUSHF end.)

Now, For reading the Alt-R: you can get the "Alt" key from
memory location $0040:$0017.  It Records the Alt key, shift keys,
caps lock, etc.  Each bit sets/reports whether the key is active or
inactive ("1" = "active").  Like so:

Const insByte = $80;  capsByte = $40;  numByte   = $20;  scrollByte = $10;
      altByte = $08;  ctrlByte = $04;  lshftByte = $02;  rshftByte  = $01;

Var keyboardstat: Byte Absolute $0040:$0017;

To test if Alt is on, see if this expression evaluates to "True":

      keyboardstat and altByte = altByte

As For the "R", check port $60 (the keyboard port) For scan code $13.
(Maybe ya oughtta find a complete list of the scan codes.)

>Also, I want my Window to disappear when my Program
>is finished (and the previous screen to come back).
>How can I do this?

Store the old screen into memory.  Hint: on Mono systems, it's the
4000 Bytes starting at b000:0000; on color, it's the 4000 starting
at b800:0000.  Use the "Move" Procedure first to move the 4000 Bytes
to an Array of 4000 Characters, then use "Move" to move the 4000 Bytes
back to the video location.

>  (BTW, I could do all this on the Commodore 64 back in the good 'ol
>days when the 64 was king.  Life was much simpler then).

Yeah, I can hear ya now: "Oh you spoiled kids.  When I started in
computers, we had only 64k to work With, and we LIKED it!  And we
didn't waste our money on a separate 'monitor', oh no! we just hooked
our computers up to the TV.  Damn kids these days."
}

