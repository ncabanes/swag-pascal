(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0107.PAS
  Description: Re: CapsLock
  Author: ALEXANDER BEEFTINK
  Date: 02-21-96  21:03
*)

{
 JR>> Does anyone have the code (probably ASM) to turn the
 JR>> CapsLock key of _and_ on as well?  Thanks in advance if you
 JR>> can help.
 SS> Procedure TogLed (Lock: Integer);

That was a bit long for what you needed to do.  Here's what I got:

program capslock;
{This program is design to test the procedure capslock_on.}

procedure capslock_on(caps:boolean);
Assembler;
 ASM
 push ds                ; Save the data segment
 mov al, caps           ; Load in the boolean value of caps
 mov bx, 0040h          ; These two lines adjust the data segment
 mov ds, bx             ; to 40h
 mov bx, 17h            ; Point to address 17h
 mov ch, [bx]           ; Get the byte located there
 mov cl, 6h             ; Move 6 into cl
 shl al, cl             ; Shift the bit in al 6 bits to the left
 and ch, 10111111b      ; Reset the 6th bit at our memory location
 or al, ch              ; Stick in the caps bit
 mov [bx], al           ; Put the new byte back
 pop ds                 ; Restore the data segment
end;

begin
 capslock_on(true);
 capslock_on(false);
end.

You see, there are a host of byte that contain information like whether or not
the capslock is on.  This program edits that information directly, and is
hence a lot smaller and easier to use.  Hope this helps.


