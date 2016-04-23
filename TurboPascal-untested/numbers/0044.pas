{
 MT>   Could someone please tell me how to write to/read from a particular
 MT>  bit in a number?  Do you have to break the number down into binary
 MT>  or is there some function somewhere that I haven't found yet?

Here's some procs I wrote that should help you out:
}

Procedure SetBit(Var Number : Byte; Bit : Byte);
 
 Begin
  Number := Number OR (1 SHL Bit);
 End;
 
Procedure ClearBit(Var Number : Byte; Bit : Byte);
 
 Begin
  Number := Number AND NOT (1 SHL Bit);
 End;
 
Function ReadBit(Number, Bit : Byte) : Boolean;
 
 Begin
  ReadBit := (Number AND (1 SHL Bit)) <> 0;
 End;
{
OK, provided you know binary, this should be pretty simple to implement.  The
bits are of course numbered 7-0.  SetBit sets a given bit to 1, ClearBit sets a
given bit to 0, and ReadBit returns TRUE if 1, FALSE if 0.  Anyway, hope that
helps...

                                      PsychoMan.
}
