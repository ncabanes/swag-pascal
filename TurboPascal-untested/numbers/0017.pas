{
  I recently came across the need For a way to dynamically Format
  Real Variables For output - I came out With the following. (You
  people following the Compiler thread may want this to make your
  Compiler output pretty)

  The routine checks to see how big the exponent is; if it's bigger
  than 1E7 or smaller than 1E-7, an unFormatted conversion is made.
  if the number is less than 1E7 and greater than 1E-7, then a
  Formatted String is created. to make the output prettier, trailing
  zeros, periods and leading spaces are deleted.
}

Function FormatReal(r:Real):String;
Var
  s :String;

begin
  if ((r>1E-7) and (r<1E7))then
    Str(r:12:12, s)
  else
    Str(r, s);

  While s[ord(s[0])]='0' do
    Delete(s, ord(s[0]), 1);
  While (s[1]=' ') do
    Delete(s, 1, 1);
  if s[ord(s[0])]='.' then
    Delete(s, ord(s[0]), 1);

  FormatReal := s;
end;
