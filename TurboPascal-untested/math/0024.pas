{LOU DUCHEZ

> Could anybody explain how to Write such a routine in Pascal?

Here's a dorky little "Factoring" Program I wrote to display the factors
of a number:
}

Program factors;
Var
  lin,
  lcnt : LongInt;
begin
  Write('Enter number to factor: ');
  readln(lin);
  lcnt := 2;
  While lcnt * lcnt <= lin do
  begin
    if lin mod lcnt = 0 then
      Writeln('Factors:', lcnt : 9, (lin div lcnt) : 9);
    lcnt := lcnt + 1;
  end;
end.

{
Notice that I only check For factors up to the square root of the number
Typed in.  Also, notice the "mod" operator: gives the remainder of Integer
division ("div" gives the Integer result of division).

Not Really knowing exactly what you want to accomplish, I don't Really know
if the above is of much help.  But what the hey.
}