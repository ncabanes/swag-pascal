(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0020.PAS
  Description: ROMAN2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
>Anyone know of how to make a Program that will convert any
>Integer entered into roman numeral Format?
}

Program Roman_Numeral_Test;

Type
  st_4 = String[4];
  st_15 = String[15];
  star_4 = Array[0..3] of st_4;
  star_10 = Array[0..9] of st_4;

Const
  Wunz : star_10 = ('', 'I', 'II', 'III', 'IV',
                    'V', 'VI', 'VII', 'VIII', 'IX');

  Tenz : star_10 = ('', 'X', 'XX', 'XXX', 'XL',
                    'L', 'LX', 'LXX', 'LXXX', 'XC');

  Hunz : star_10 = ('', 'C', 'CC', 'CCC', 'CD',
                    'D', 'DC', 'DCC', 'DCCC', 'CM');

  Thouz : star_4 = ('', 'M', 'MM', 'MMM');


Function Dec2Roman(wo_in : Word) : st_15;
begin
  Dec2Roman := Thouz[(wo_in div 1000)] +
               Hunz[((wo_in mod 1000) div 100)] +
               Tenz[(((wo_in mod 1000) mod 100) div 10)] +
               Wunz[(((wo_in mod 1000) mod 100) mod 10)]
end;

Var
  wo_Temp : Word;

begin
  Writeln;
  Write(' Enter number to be converted to roman-numeral equivalent: ');
  readln(wo_Temp);
  if (wo_Temp > 3999) then
    wo_Temp := 3999;
  Writeln;
  Writeln(' Roman-numeral equivalent of ', wo_Temp, ' = ', Dec2Roman(wo_Temp))
end.


