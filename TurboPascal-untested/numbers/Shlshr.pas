(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0021.PAS
  Description: SHLSHR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{ INFO ON SHR and SHL }

> (5 Shl 2) + 5 which is: (5 x 4) + 5
> So, 10 * 10 would be (10 Shl 3) + (10 Shl 1)

This looks good but, can it be done With Variables (So I can use
numbers other than 5 & 5)?

 Yes, just keep in mind that each shift leftward Doubles the value...

        p SHL 1  =  p * 2
        p SHL 2  =  p * 4
        p SHL 3  =  p * 8
        p SHL 4  =  p * 16
        ...

 (likewise, each shift rightward halves the value).

 Also keep in mind that the maximum amount you can shift is the
 number of bits in the Variable.  Bytes are 8 bits, Words and
 Integers are 16 bits, and LongInts are 32 bits.  if you shift
 a Variable its full bit size, or more, it will be 0 (zero).

 For example: if p is a Byte, then p SHR 8 = 0.

{  Use Shr/Shl to multiply/divide, rather than the operators
  How do you (or anybody) do this?   For example, how would I do 5 * 5?
}
{*******************************************************************}
 Program DemoShifts;
 Var     Number, Result  : Word;
 begin
    {   Calculate 5 * 5, without using multiplication ...           }

    Number := 5;                    { original value                }
    Result := Number SHL 2;         { now Result = 4 * Number       }
    Result := Result + Number;      { 4*Number + Number = 5*Number  }

    WriteLn( '5 * 5 = ', Result );  { because seeing is believing   }

 end {DemoShifts}.
{*******************************************************************}

 But TP seems sometimes to do the 'shift vs. MUL optimization' itself,
 this being bad if Compiling For a 386/486 CPU.
 A "* 2" would always result in a SHL instruction ( unless Real
 arithmetic was used ;-> ).

 Ok, I understand that part.  if x shr 4 = x/4  (and the remainder is
 dropped) then I Really understand it.  Does it? Do I?

No.  x shl 0 = x
     x shl 1 = x/(2^1) = x/2
     x shl 2 = x/(2^2) = x/4
     x shl 3 = x/(2^3) = x/8
     x shl 4 = x/(2^4) = x/16

Just as:
     x shr 0 = x
     x shr 1 = x*(2^1) = 2x
     x shr 2 = x*(2^2) = 4x
     x shr 3 = x*(2^3) = 8x
     x shr 4 = x*(2^4) = 16x

So now you can see how and why the Compiler substitutes a "shr 1" For "* 2".

 > PD> So, 10 * 10 would be: (10 shl 3) + 20
 >
 > MC> not quite:
 > MC> (10 Shl 3)+(10 Shl 1)s, I'm back! (3:634/384.6)
 >
 > Why?  wouldn't the second one take an additional instruction (shl)?

Well yes, but 8086 instructions weren't created equal.  PerForming two
shifts and the add to combine them will (on a 286 or lesser) less time
overall than doing even one MUL.

The 386/486 has streamlined the MUL instruction so that it takes much less
time, and can often Compete With the shift/add approach.  Which to use?
Well, I'd stick With the shift/add approach, since if you're writing one
Program For both XTs and 386s, the XT will be acceptable, and so will the
386.  Using the MUL; True, 386 perFormance will be better, but your XT
perFormance will suffer quite a bit.

