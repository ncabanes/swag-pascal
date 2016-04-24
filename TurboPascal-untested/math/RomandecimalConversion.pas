(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0057.PAS
  Description: Roman-Decimal Conversion
  Author: VARIOUS - SEE BELOW
  Date: 01-27-94  12:20
*)

{
>I would like to know if there is a function to convert a year to Roman
>Numerals (1993 to MCMCMIII).

 Brian Pape, Brian Grammer, Mike Lazar, Christy Reed, Matt Hayes
}

program roman;

const
  num   = 'IVXLCDM';
  value : array [1..7] of integer = (1, 5, 10, 50, 100, 500, 1000);
var
  i   : byte;
  s   : string;
  sum : integer;
begin
  writeln('Enter the Roman Numerals: ');
  readln(s);
  i := length(s);
  while (i >= 1) do
  begin
    if i > 1 then
    begin
      if pos(s[i], num) <= (pos(s[i - 1], num)) then
      begin
        sum := sum + value[pos(s[i], num)];
        dec(i);
      end
      else
      begin
        sum := sum + value[pos(s[i],num)] - value[pos(s[i - 1], num)];
        dec(i, 2);
      end;
    end
    else
    begin
      sum := sum + value[pos(s[1], num)];
      dec(i);
    end;
  end;
  WRITELN;
  writeln('Roman numeral: ', s);
  writeln(' Arabic value: ', sum);
end.


