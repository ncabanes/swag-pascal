(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0094.PAS
  Description: BASM Enhanced Keyboard Detection
  Author: JOHN BALDWIN
  Date: 05-26-95  23:04
*)

{
> I would like to know how to tell whether there is a 101 enhanced keyboard
> attached to a computer or and 84.

This should work:
}

function enhanced_keyboard:boolean; assembler;

asm
   mov ah,09h
   int 16h        {Call Interrupt $16, Function $09}
   shr al,1
   shr al,1
   shr al,1
   shr al,1
   shr al,1       {Shifts the bits in al right 5 times}
   and al,1       {We want to only test the first bit in al}
end;

{
This will return true if the enchanced keyboard functions are supported.  If
you are compiling with the $G+ directive, then change the five 'shr al,1' to
one 'shr al,5'.   Hope this helps.
}

