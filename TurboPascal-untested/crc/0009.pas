{
GUY MCLOUGHLIN

>I wanted to ask you... would you happen to know how a CRC Check-sum
>works? Everytime I go to look this up in a book I see a bunch of
>stuff about X^7 + X^12 + X^17..... (and on and on) but nothing that
>actually says "Here's what the code looks like" ... just a bunch of
>non-sensical bull...Would you happen to know the algorithm that is
>used?

  ...Greg Vigneault is much better at this stuff than I am. I
  usually know "why" something works, but not always "how". <g>
  The basic idea is that the data is treated as input to a specific
  polynomial equation (ie: X^32 + X^26 + X^23 + X^22 + X^16 + X^12),
  the result of this is then divided by a specific prime number, and
  the remainder left over is the CRC value. I know that this is
  easier said than understood, but that's the gist of it.

  ...if a single bit of a chunk of data is changed, the chances
  are very good that a CRC check number would catch this change.
  It's not 100 percent guaranteed, but something more like 99.97
  percent, so CRCs are not an entirely bulletproof check. Here's
  a standard Pascal Implementation of a CRC-16 routine:
}

Function CRC16(InString: String) : Word;
Var
  CRC     : Word;
  Index1,
  Index2  : Byte;
begin
  CRC := 0;
  For Index1 := 1 to length(S) do
  begin
    CRC := (CRC xor (ord(InString[Index1]) SHL 8));
    For Index2 := 1 to 8 do
      if ((CRC and $8000) <> 0) then
        CRC := ((CRC SHL 1) xor $1021)
      else
        CRC := (CRC SHL 1)
  end;
  CRC16 := (CRC and $FFFF)
end;

