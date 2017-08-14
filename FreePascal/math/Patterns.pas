(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0044.PAS
  Description: PATTERNS
  Author: WILLIAM SCHROEDER
  Date: 11-02-93  10:30
*)

{
WILLIAM SCHROEDER

I'd like to extend thanks to everyone For helping me set up a PATTERN Program.
Yes, I have done it! Unfortunatley, this Program doesn't have all possible
pattern searches, but I figured out an algorithm For increasing size geometric
patterns such as 2 4 7 11. The formula produced is as follows: N = the Nth
term. So whatever the formula, if you want to find an Nth term, get out some
paper and replace N! :) Well, here's the Program, folks. I hope somebody can
make some improvements on it...
}
Program PatternFinder;

Uses
  Crt;

Var
  ans     : Char;
  PatType : Byte;
  n1, n2,
  n3, n4  : Integer;

Procedure GetInput;
begin
  ClrScr;
  TextColor(lightcyan);
  Writeln('This Program finds patterns For numbers in increasing size.');
  Write('Enter the first four terms in order: ');
  TextColor(yellow);
  readln(n1, n2, n3, n4);
end;

Procedure TestRelations;
begin
  PatType := 0;
  { 1 3 5 }
  if (n3 - n2 = n2 - n1) and ((n4 - n3) = n2 - n1) then
    PatType := 1
  else
  { 1 3 9 }
  if (n3 / n2) = (n4 / n3) then
    PatType := 2
  else
  { 1 1 2 }
  if (n3 = n2 + n1) and (n4 = (n3 + n2)) then
    PatType := 3
  else
  { 1 2 4 7 11 }
  if ((n4 - n3) - (n3 - n2)) = ((n3 - n2) - (n2 - n1)) then
    PatType := 4;
end;

Procedure FindFormula;

  Procedure DoGeoCalc;
  Var
    Factor : Real;
    Dif,
    Shift,
    tempn,
    nx, ny : Integer;
  begin
    Dif := (n3 - n2) - (n2 - n1);
    Factor := Dif * 0.5;
    Shift  := 0;
    ny := n2;
    nx := n1;
    if ny > nx then
    While (ny-nx) <> dif do
    begin
      Inc(Shift);
      tempn := nx;
      nx := nx - ((ny - nx) - dif);
      ny := tempn;
    end;
    if Factor <> 1 then
      Write('(', Factor : 0 : 1, ')');
    if Shift = 0 then
      Write('(N + 0)(N - 1)')
    else
    begin
      if Shift > 0 then
      begin
        Write('(N + ', shift, ')(N');
        if Shift = 1 then
          Write(')')
        else
          Write(' + ', shift - 1, ')');
      end;
    end;
    if nx <> 0 then
      Writeln(' + ', nx)
    else
      Writeln;
  end;

begin
  TextColor(LightGreen);
  Writeln('Formula =');
  TextColor(white);
  Case PatType of
    1 :
    begin
      { Nth term = first term + difference * (N - 1) }
      if n2 - n1 = 0 then
        Writeln(n1)
      else
      if (n2 - n1 = 1) and (n1 - 1 = 0) then
        Writeln('N')
      else
      if n2 - n1 = 1 then
        Writeln('N + ', n1 - 1)
      else
      if (n2 - n1) = n1 then
        Writeln(n1, 'N')
      else
      Writeln(n2 - n1, '(N - 1) + ', n1);
    end;

    2 :
    begin
      { Nth term = first term * ratio^(N - 1) }
      if n1 = 1 then
        Writeln(n2 / n1 : 0 : 0, '^(N - 1)')
      else
        Writeln(n1, ' x ', n2 / n1 : 0 : 0, '^(N - 1)');
    end;

    3 :
    begin
      { Fibonacci Sequence }
      Writeln('No formula: Fibonacci Sequence (Term1 + Term2 = Term3)');
      Writeln('                                ',
              n1 : 5, ' + ', n2 : 5, ' = ', (n1 + n2) : 5);
    end;

    4 :
    begin
      { Geometric Patterns }
      DoGeoCalc;
    end;
  end;
end;

begin
  GetInput;
  TestRelations;
  TextColor(LightRed);
  Writeln;
  if PatType <> 0 then
    FindFormula
  else
    Writeln('No pattern found: This Program may not know how to look '+
    'for that pattern.');
  TextColor(lightred);
  Writeln;
  Write('Press any key...');
  ans := ReadKey;
  ClrScr;
end.

{
That's all folks! if you can find and fix any bugs For me, please send me that
section of the code so I can change it. if anybody cares to ADD to the pattern
check, be my guest! This Program can be altered and used by ANYBODY. I'd just
like to expand it a bit. Have fun!
}
