> I am learning Pascal and don't understand something.  How does the
> following Function make a Word into Hex:

 It's Really doing two things, it's converting a binary value
 into ascii, and from decimal to hex.  Let's start With the
 calling or main part of the Program.  You're taking a 2 Byte
 Word and breaking it up into 4 nibbles of 4 bits each.  Each of
 these nibbles is displayed as a Single hex Character 0-F.

                                   Hex Representation XXXX
                                                      ||||
HexStr := HexStr + Translate(Hi(W) shr 4); -----------||||
HexStr := HexStr + Translate(Hi(W) and 15);------------|||
HexStr := HexStr + Translate(Lo(W) shr 4); -------------||
HexStr := HexStr + Translate(Lo(W) and 15);--------------|


Now the translate Function simply converts the decimal value of
the 4-bit nibble into an ascii hex value.  if you look at an
ascii Chart you will see how this is done:

'0' = 48   '5' = 53    'A' = 65
'1' = 49   '6' = 54    'B' = 66
'2' = 50   '7' = 55    'C' = 67
'3' = 51   '8' = 56    'D' = 68
'4' = 52   '9' = 57    'E' = 69
                       'F' = 70


As you can see it easy For 0-9, you just add 48 to the value and
it's converted, but when you go to convert 10 to A, you need to
use a different offset, so For values above 9 you add 55.

Function Translate(B : Byte) : Char;
  begin
  if B < 10 then
    Translate := Chr(B + 48)
  else
    Translate := Chr(B + 55);
  end;
