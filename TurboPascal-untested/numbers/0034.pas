{
LOU DUCHEZ

>does andbody know an easy way to convert a Byte value from it's Integer
> notation to hex notatation?

Well, thank you For this message.  It finally got me off my keister (sp?) to
Write a "decimal-to-hex" converter -- a project I'd been meaning to do, but
never got around to.  (Technically, since I was in a seated position, I
remained on my keister the whole time, but you know what I mean).  Actually,
the following is not just "decimal-to-hex" -- it's decimal-to-any-base-from-
2-to-36-converter (because base 1 and below doesn't make sense, and after
base 36 I run out of alphabet to represent "digits").  Here is NUBASE:
}


Function nubase(numin : LongInt; base, numplaces : Byte) : String;
Var
  tmpstr    : String;
  remainder : Byte;
  negatize  : Boolean;
begin
  negatize := (numin < 0);              { Record if it's a negative number }
  if negatize then
    numin := abs(numin);                { convert to positive For calcs }
  tmpstr[0] := Char(numplaces);         { set length of the output String }

  While numplaces > 0 do
  begin                                 { Loop: fills each space in String }
    remainder := numin mod base;        { get next "digit" (under new base) }
    if remainder > 9 then
      tmpstr[numplaces] := Char(remainder + 64 - 9)   { convert to letter }
     else
      tmpstr[numplaces] := Char(remainder + 48);      { use number as is }
    numin := numin div base;            { reduce dividend For next "pass" }
    numplaces := numplaces - 1;         { go to "next" position in String }
  end;                                  { end of loop }

  { The following: if we've run out of room on the String, or if it's a
    negative number and there's not enough space For the "minus" sign,
    convert the output String to all asterisks. }

  if (numin <> 0) or (negatize and (tmpstr[1] <> '0')) then
    For numplaces := 1 to Byte(tmpstr[0]) do
      tmpstr[numplaces] := '*';

  { add minus sign }

  if negatize and (tmpstr[1] = '0') then
    tmpstr[1] := '-';

  nubase := tmpstr;
end;


{
Feed it the number to convert, the base to convert into, and the number of
spaces you want For it.  Leading zeros will be provided.  Example: to
convert 111 into hex (base 16)  and give 4 digits of answer, you could say:

Writeln(nubase(111, 16, 4))

and it'd Write out:

006F

This routine does handle negative numbers too.  if you don't give it enough
"space" in the third parameter you pass, it'll return all asterisks.  For
laughs, try converting the number 111 into base 10 and giving it 5 digits
of answer.  You'll get:

00111  (predictably enough)
}