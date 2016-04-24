(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0034.PAS
  Description: BASE36 Conversion
  Author: CORY ALBRECHT
  Date: 11-02-93  05:07
*)

{ Updated NUMBERS.SWG on November 2, 1993 }

{
CORY ALBRECHT

> Can someone please show me how I would convert a base 10 number to
> base 36? (The one used by RIP)

I presume you mean turning a Variable of Type Byte, Word, Integer, or
LongInt to a String representation of that number in base 36? Just checking,
since once I had someone who had two Word Variables who asked me how they
could change Word1 to hexadecimal For putting it in Word2. The following
code will turn any number from 0 to 65535 to a String representation of
that number in any base from 2 to 36.
}

Unit Conversion;

Interface

Const
  BaseChars : Array [0..35] Of Char = ('0', '1', '2', '3', '4', '5',
                                       '6', '7', '8', '9', 'A', 'B',
                                       'C', 'D', 'E', 'F', 'G', 'H',
                                       'I', 'J', 'K', 'L', 'M', 'N',
                                       'O', 'P', 'Q', 'R', 'S', 'T',
                                       'U', 'V', 'W', 'X', 'Y', 'Z');

{ n - number to convert
  b - base to convert to
  s - String to store result in }

Procedure NumToStr(n : Word; b : Byte; Var s);

Implementation

Procedure NumToStr(n : Word; b : Byte; Var s);
Var
  i,
  res,
  rem : Word;
begin
  s := '';
  if ((b < 2) or (b > 36)) Then
    Exit;
  res := n;
  i   := 1;
  { Get the digits of number n in base b }
  Repeat
    rem  = res MOD b;
    res  := res div b;
    s[i] := BaseChars[rem - 1];
    Inc(s[0]);
  Until rem = 0;
  { Reverse s since the digits were stored backwards }
  i := 1;
  Repeat
    s[i] := Chr(Ord(s[i]) xor Ord(s[Length(s) - (i - 1)]));
    s[Length(s) - (i - 1)] := Chr(Ord(s[Length(s) - (i - 1)]) xor Ord(s[i]));
    s[i] := Chr(Ord(s[i]) xor Ord(s[Length(s) - (i - 1)]));
    Inc(i);
  Until i >= (Length(s) - (i - 1));
end;

end.

