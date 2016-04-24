(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0106.PAS
  Description: BCD Add & Subtract functions
  Author: UNKNOWN
  Date: 05-31-96  09:16
*)

{
Depending on the application, BCD may solve your problem.  But if you
really need a _large_ binary integer you are going to have to use
multiple precision arithmetic.  This is relatively easy to do in assembler
and just a little more difficult in a high-level language.

You need to define your _integer_ as an array of 256 bytes, 128 words,
or 64 unsigned long integers.  So we're stuck with words.  So our bigint
is an array[0..127] of word;  We'll do it little-endian 0=least
significant word, 127 = most significant word.  Using words with a longint
intermediate value actually makes our task a little easier.
}

CONST MaxBIG  = 127;
TYPE  tBigInt = Array[0..MaxBIG] of Word;

PROCEDURE BigAdd(VAR Op1, Op2: tBigInt);
{ --------------------------------------------- }
{ Do multiprecision add:  Op1 := Op1 + Op2      }
{ --------------------------------------------- }
VAR i: Integer;
    Temp: Longint;
Begin
    Temp := 0;                       { Clear carry }
    For i := 0 to MaxBIG Do Begin
       Temp   := Longint(Op1[i]) + Op2[i] + Temp;
       Op1[i] := Word(Temp);
       Temp   := Temp shr 16;  { Carry = High word }
    End;
END;

PROCEDURE BigSub(VAR Op1, Op2: tBigInt);
{ --------------------------------------------- }
{ Do multiprecision Substract: Op1 := Op1 - Op2 }
{ --------------------------------------------- }
VAR i: Integer;
    Temp: Longint;
Begin
    Temp := 0;                       { Clear carry }
    For i := 0 to MaxBIG Do Begin
       Temp   := Longint(Op1[i]) - Op2[i] - Temp;
       Op1[i] := Word(Temp);
       Temp   := Temp shr 16;  { Carry = High word }
    End;
END;

I've done the easy part.  It's your turn to put together
the multiprecision multiply and divide.  If Op2 can be
an integer I'll toss together an op1*Op2 and Op1 div Op2.
But for a full version I'd have to crack the books :-)

