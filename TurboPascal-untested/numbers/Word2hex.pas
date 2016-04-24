(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0024.PAS
  Description: WORD2HEX.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
> How does the following Function make a Word into Hex:

 - Dissection:
}

Type
  Str4 : String[4];

Function WordtoHex(W : Word) : St4
Var
  HexStr : St4;

  Function Translate(B : Byte) : Char;

  { This Function takes a number from 0 to 15 and makes it into a hex digit.}

  begin
    if B < 10 then
    { if it's 0..9 }
      Translate := Chr(B + 48)
  { These statements use math on Characters... ascii 48 is '0'.
    Could have been written: Translate := Chr(B + ord('0')) }
    else
      Translate := Chr(B + 55);
  { This one is For letters A~F. ascii 55 isn't anything, but if you add
    $A (10) to 55 you get 65, which is the ascii code For 'A'
    This could have been written: Translate := Chr(B + ord('A')-$A); }
  end;

begin
  HexStr := ' ';
  HexStr := HexStr + Translate(Hi(W) shr 4);
  { Hi(W) takes the high Byte of Word W.
    shr 4 means the same as divide by 16...
    What they're Really doing here is taking each nibble of the hex Word
    and isolating it, translating it to hex, and adding it to the String. }
  HexStr := HexStr + Translate(Hi(W) and 15);
  HexStr := HexStr + Translate(Lo(W) shr 4);
  HexStr := HexStr + Translate(Lo(W) and 15);
  WordtoHex := HexStr;
end;
{
> I am learning Pascal and don't understand something.  How
> does the following Function make a Word into Hex:

It doesn't, at least not as present! But if you changes two things, maybe
spelling-errors, it will work. This is a bit hard to explain and grasp, because
it involves operations at a less abstract level than the one that you usually
work on in TP. Remember, when a number is stored in memory, it's stored binary,
hexadecimal notion is just For making it easier For man to read. I don't know
if you know how to Write and read binary- and hexadecimal-numbers, in Case you
don't know it's all here...

On PC, a Word, in the range 0 to 65535, has 16 bits. A Word written in binary
notion For this reason contains 16 digits, 0's or 1's! But a Word written in
hexadecimal notion contains 4 digits. Simple math tells us that one digit in
hex-notion is equal to four digits binary. Four digits binary gives 16
combinations (2^4). ThereFore, each hexadecimal digit must be able to contain
values from decimal 0-decimal 15, _in one digit_! Our normal digits, 0-9, isn't
sufficient For this, we must use 6 other digits. The designers of this system
choosed A-F as the extra digits. This means, in hex the digits are 0, 1, 2, 3,
4, 5, 6, 7, 8, 9, A, B, C, D, E and F. Hanging on?

>    Function WordtoHex(W : Word) : St4

Compile-time error: You must have a semicolon after the Function header-line.

>    Var
>        HexStr : St4;

>        Function Translate(B : Byte) : Char;
>        begin
>           if B < 10
>               then
>                   Translate := Chr(B + 48)
>               else
>                   Translate := Chr(B + 55);
>        end;

This is clearer as:

  if b < 10
    then Translate := Chr(b+ord('0'))
    else Translate := Chr(b+ord('A')-10);

Think about the first Case, when b < 10, if b were 0, the expression would be
'0' plus 0, '0'!. if b were 1, it's '0' plus 1, '1'!. This works because in the
ASCII-table the numbers are sequential ordered. But '0' plus 10 would be ':',
because it happens to be after the numbers.

then, when we want 'A'-'F, we would need to start from 'A'. But we can't add 10
to 'A' For getting 'A' and 11 For getting 'B' and that like. First we must make
the value relative 'A'. Because the values that we're working on here is in the
range 10 to 15, we can decrease it With 10 and get 0 to 5. then is OK to use
them relative 'A'. As beFore, 'A' plus 0 is 'A', 'A' plus 1 is 'B', and so on.

However, this routine has no safety check, it will gladly return 'G' For 16,
because 'A'+6 is 'G'. It doesn't care if the value is within hexadecimal range
or not (numbers bigger than 15 can't be turned into one hex digit, they need
more digits). But here it's OK, because the routine is local to WordtoHex that
will never pass anything else than 0 to 15.

>    begin
>        HexStr := ' ';

Logical error: You must initalize HexStr to an empty String, '', if not it will
consist of a space and three hex digits, not four. A hex-Word String is
Composed of four hexadeciamal-digits. Because you have declared the String as a
Variable of the Type St4 and St4 only allows four Chars, exactly what is needed
For a hexWord-String, the last one added will be discarded if you have a space
at the beginning, filling up one position.

>        HexStr := HexStr + Translate(Hi(W) shr 4);
>        HexStr := HexStr + Translate(Hi(W) and 15);
>        HexStr := HexStr + Translate(Lo(W) shr 4);
>        HexStr := HexStr + Translate(Lo(W) and 15);
>        WordtoHex := HexStr;
>    end;

It would be easier to read if the 'and'-value were in hex-notation, $000F. See
below For explanation why. However, this part requires some understanding of
the bits. It's probably best show With an example. Let's say, our number W is
$1234.

$1234 is written 0001 0010 0011 0100 in binary. Each hex-digit corresponds to a
four-group binary digits.

■) The binary number 0001 is 0*(2^3) + 0*(2^2) + 0*(2^1) + 1*(2^0). It gives
0+0+0+1=1 in decimal.

■) The binary number 0101 is 0*(2^3) + 1*(2^2) + 0*(2^1) + 1*(2^0). It gives
0+4+0+1=5 in decimal.

■ The _decimal_ number 1101 is 1*(10^3) + 1*(10^2) + 0*(10^1) + 1*(10^0). It
gives 1000+100+0+1=1011! As you can see, the only difference between the
decimal and the binary and the hexadecimal system is the base-power. True, the
hex-system Uses strange digits For us used to decimal, but For the ones used to
binary, 2-9 is equally strange...

Like our decimal system, in hex and binary, it's unnescessary to include
leading zeros, i. e. $0001 = $1 (of course you can't remove trailing zeroes,
decimal 1000 certainly isn't equal to decimal 1...). But you will note that I
sometimes include these leading zeroes, just because it looks good (?). and
writing binary number 1000 0000 is like writing 10000 in decimal as 10,000;
it's only For easy reading, but the Compiler won't allow it.

However, I hope you grasp a least something of my extremly bad explanation :-(,
or maybe you know it beFore?! Now, let's look at the things that happens when
the above statements are executed and w = $1234 (0001 0010 0011 0100).

Hi returns the upper 8 bits of the Word, in this Case 0001 0010; Lo returns the
lower bits (!), 0011 0100. The above code Uses 'and' and 'shr', a breif
explanation of them will probably be nescessary (oh no :-)).

■ and, when not used as a Boolean operator, Uses two binary numbers and, For
each bit, tests them. if _both_ bits are set (equal to 1) the resuling bit is
set to 1, if any or both of them is cleared (equal to 0) the result is 0. This
means:


  0001 0010   Hi(w)                     0011 0100   Lo(w)
  0000 1111   and With 15 or $000F      0000 1111   and With 15 or $000F
  ---------                             ---------
  0000 0010   0010 binary = 2 hex       0000 0100   0100 binary = 4 hex

This was the second and first statement, and out you get the second and first
number! When we pass them to Translate, we get back '2' and '4'.

■ shr, only For binary operations, shifts the bits to the right. The bits that
passes over the right side is lost, and the ones that move on left side is
replaced by zeroes. The bits shifts as many times as the value after the
shr-keyWord, here 4 times. Like this:

  00010010   Hi(w)                     00110100   Lo(w)
  --------             shr 4           --------
  00001001        after one shift      00011010
  00000100        after two shifts     00001101
  00000010       after three shifts    00000110
  00000001       after four shifts     00000011

Now we got binary 0001 and binary 0011, in hex $1 and $3. The first and third
statement, and the first and third number! The String to return is digit1 +
digit2 + digit3 + digit4, exactly what we want.

Hmm... Now I haven't told you anything about the binary or, xor, not and
shl-keyWords... But I think this message is quiet long as it is, without that.
But if you want more info or a better explanation, only drop me a msg here.

Happy hacking /Jake 930225 17.35 (started writing last night)
PS. There may be some errors, I haven't proof-read the Text or my math. then,
please correct me, anybody.
}
