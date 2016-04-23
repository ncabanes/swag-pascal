{
>Also, how would I simply read each bit?
}
{ Test if a bit is set. }
Function IsBitSet(Var INByte : Byte; Bit2Test : Byte) : Boolean;
begin
  if (Bit2Test in [0..7]) then
    IsBitSet := ((INByte and (1 shl Bit2Test)) <> 0)
  else
    Writeln('ERROR! Bit to check is out of range!');
end; { IsBitSet. }

{
>How on earth can I manipulate an individual bit?

...One method is to use the bit-operators:  AND, OR, XOR, NOT
}

{ Manipulate an individual BIT within a single Byte. }
Procedure SetBit(Bit2Change : Byte; TurnOn : Boolean; Var INByte : Byte);
begin
  if Bit2Change in [0..7] then
  begin
    if TurnOn then
      INByte := INByte or (1 shl Bit2Change)
    else
      INByte := INByte and NOT(1 shl Bit2Change);
  end;
end; { SetBit. }

{
>...but I'm not sure exactly what the shifting is doing.
}

    { Check if the bit is to be turned on or off. }
    If TurnOn then

    {
      SHL 1 (which has a bit map of 0000 0001) to the bit
      position we want to turn-on.

        ie: 1 SHL 4 = bit-map of 0001 0000

      ...Then use a "logical OR" to set this bit.

      ie: Decimal:     2      or      16     =    18
          Binary : 0000 0010  or  0001 0000  = 0001 0010
    }

      INByte := INByte or (1 shl Bit2Change)
    else

    {
      Else turn-off bit.

      SHL 1 (which has a bit map of 0000 0001) to the bit
      position we want to turn-off.

         ie: 1 SHL 4 = bit-map of 0001 0000

       ...Then use a "logical NOT" to flip all the bits.

       ie: Decimal:  not (   16    ) =      239
           Binary :  not (0001 0000) =  (1110 1111)

       ...Than use a "logical AND" to turn-off the bit.

       ie: Decimal:     255     and     239    = 239
           Binary :  1111 1111  and  1110 1111 = 1110 1111
    }

     INByte := INByte and NOT(1 shl Bit2Change);

{
>Also, how can you assign a Byte (InByte) a Boolean value (OR/AND/NOT)

  or / xor / and / not are "logical" bit operators, that can be use on
  "scalar" Types. (They also Function in the same manner For "Boolean"
  logic.)

>If I have, say 16 bits in one Byte, the interrupt list says that for
>instance the BIOS calls (INT 11), AX is returned With the values. It
>says that the bits from 9-11 tell how many serial portss there are.
>How do I read 3 bits?

  To modify the two routines I posted wo work With 16 bit Variables,
  you'll need to change:

     INByte : Byte;  --->  INWord : Word;

  ...Also:

     in [0..7]  --->  in [0..15]

  ...If you don't want to use the IsBitSet Function listed above
  (modified to accept 16-bit Word values) you could do the following
  to check if bits  9, 10, 11 are set in a 16-bit value:

  The following is the correct code For reading bits 9, 10, 11
  of the 16-bit Variable "AX_Value" :

      Port_Count :=  ((AX_Value and $E00) SHR 9);

    NOTE: Bit-map For $E00 = 0000 1110 0000 0000

  ...If you've got a copy of Tom Swan's "Mastering Turbo Pascal",
  check the section on "logical operators".


{
>Var Regs : Registers;
>begin
>  Intr($11,Regs);
>  Writeln(Regs.AX);
>end.

>How do I manipulate that to read each bit (or multiple bits like
>the number of serial ports installed (bits 9-11) ?
}

Uses
  Dos;

Var
  Port_Count : Byte;
  Regs       : Registers;

begin
  Intr($11, Regs);
  Port_Count := ((Regs.AX and $E00) SHR 9);
  Writeln('Number of serial-ports = ', Port_Count)
end.
{
NOTE: The hex value of $E00 is equivalent to a 16-bit value with
      only bits 9, 10, 11 set to a binary 1. The SHR 9 shifts the
      top Byte of the 16-bit value, to the lower Byte position.
}
{
>Is $E00 the same as $0E00 (ie, can you just omit leading zeros)?

Yeah, it's up to you if you want to use the leading zeros or not.

The SHR 9 comes in because once the value has been "AND'd" with
$E00, the 3 bits (9, 10, 11) must be placed at bit positions:
0, 1, 2  ...to correctly read their value.

For example, say bits 9 and 11 were set, but not bit 10. If we
"AND" this With $E00, the result is $A00.

1011 1010 0111 1110  and  0000 1110 0000 0000  =  0000 1010 0000 0000
       ^ ^
(bits 9,11 are set)  and  (      $E00       )  =  $A00
...Taking the result of $A00, and shifting it right 9 bit positions

         $A00         SHR 9  =           5

 0000 1010 0000 0000  SHR 9  =  0000 0000 0000 0101

...Which evalutates to 5. (ie: 5 serial ports)
}









{
Get Equipment Bit-Map
---------------------

         AH       AL
      76543210 76543210
AX =  ppxgrrrx ffvvmmci

...
...
rrr = # of RS232 ports installed
...
...

 (* reports the number of RS232 ports installed *)
Function NumRS232 : Byte;
Var Regs : Registers;                 (* Uses Dos *)
begin
  Intr($11,Regs);
  NumRS232 := (AH and $0E) shr 1;
end;


...When you call Int $11, it will return the number of RS232 ports installed
in bits 1-3 in register AH.

For example if AH = 01001110 , you can mask out the bits you *don't* want
by using AND, like this:

              01001110      <---  AH
        and   00001110      <---- mask $0E
        ──────────────
              00001110      <---- after masking


Then shift the bits to the right With SHR,

              00001110      <---- after masking
         SHR         1      <---- shift-right one bit position
         ─────────────
              00000111      <---- result you want
}

{
-> How do I know to use $4 For the third bit?  Suppose I want to read
-> the fifth bit. Do I simply use b := b or $6?

    Binary is a number system just like decimal.  Let me explain.
First, consider the number "123" in decimal.  What this means,
literally, is

1*(10^2) + 2*(10^1) + 3*(10^0), which is 100 + 20 + 3.

    Binary works just the same, however instead of a 10, a 2 is used as
the base.  So the number "1011" means

1*(2^3) + 0*(2^2) + 1*(2^1) + 1*(2^0), or 8+0+2+1, or 11.

     This should make it clear why if you wish to set the nth bit to
True, you simply use a number equal to 2^(n-1).  (The -1 is there
because you probably count from 1, whereas the powers of two, as you may
note, start at 0.)

-> b or (1 SHL 2) Would mean that b := 1 (True) if b is already equal to
-> one (1) and/OR the bit two (2) to the left is one (1) ???

    Aha.  You are not familiar With bitwise or operations.  When one
attempts to or two non-Boolean values (Integers), instead of doing a
logical or as you are familiar with, each individual BIT is or'd.  I.E.
imagine a Variables A and B had the following values:

a := 1100 (binary);
b := 1010 (binary);

then, a or b would be equal to 1110 (binary);  Notice that each bit of a
has been or'd With the corresponding bit of b?  The same goes For and.
Here's an example.

a := 1100 (binary);
b := 1010 (binary);

a and b would be equal to 1000;

I hope this clears up the confusion.  And just to be sure, I'm going to
briefly show a SHL and SHR operation to make sure you know.  Consider
the number

a := 10100 (binary);

This being the number, A SHL 2 would be equal to 1010000 (binary) --
notice that it has been "shifted to the left" by 2 bits.

A SHR 1 would be 1010 (binary), which is a shifted to the right by 2
bits.
}

