(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0003.PAS
  Description: Cursor Handling #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

MN> Anyone have any code on hiding the cursor and then bringing it back.

MN>                               -+- Mike Normand -+-


I've seen many replies to this but all suffer the same disadvantage: they all
assume you know the size of the cursor. A little bit debugging BASIC reveals
what's up (by the way, you'll find it described in some good books): you have
to set bit 5 For the start line and the cursor will disappear since this value
is not allowed. To get the cursor back again, clear bit 5 again. Use this
solution, if you Really just want to turn on/off the cursor. CursorOn/CursorOff
do *not* change the cursor shape!!! and do *not* need an external Variable to
manage this.

The  PUSH BP / POP BP  is needed For some *very* old BIOS versions using CGA/
monochrome :-( display, that trash BP during an INT 10h. If you just want do
support EGA/VGA :-) and better, just push 'em out.

-----------------------------------------------------
Procedure CursorOff; Assembler;
Asm
    push bp            { For old BIOSs }
    xor  ax, ax
    mov  es, ax
    mov  bh, Byte ptr es:[462h]  { get active page }
    mov  ah, 3
    int  10h           { get cursor Characteristics }
    or   ch, 00100000b
    mov  ah, 1
    int  10h           { set cursor Characteristics }
    pop  bp            { restore bp For old BIOSs }
end;

Procedure CursorOn; Assembler;
Asm
    push bp            { old BIOSs like this... }
    xor  ax, ax
    mov  es, ax
    mov  bh, Byte ptr es:[462h]  { get active page }
    mov  ah, 3
    int  10h           { get cursor Characteristics }
    and  ch, 00011111b
    mov  ah, 1
    int  10h           { set cursor Characteristics }
    pop  bp            { ...and this, too }
end;

