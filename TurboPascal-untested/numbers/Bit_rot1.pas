(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0004.PAS
  Description: BIT_ROT1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

The commands you need to rotate a Byte/Word are:

ROR, ROL, RCR, RCL.
ROR ==> Rotates the bits the number of times specified, so that the
        rightmost bits are rotated into the leftmost bits.  NO BITS
        ARE LOST.  ROL is the same thing in the opposite direction.

RCR ==> Practically the same as the ROR/ROL instruction, but it rotates
        the bit into the carry, and the carry bit is rotated into the
        leftmost bit of the Byte/Word.  {Rotate right through carry}
        RCL is the same in the other direction.

The format For each of ROR,ROL,RCR,RCL,SHR,SHL is

  [Instruction]  <Destination>  <Shift Count>

To reWrite your original code:

Asm
  Mov  AL, ByteVar
  Ror  AL, 1
  Mov  ByteVar, AL
end

The above would rotate the bits in the Variable ByteVar by one to the right.

