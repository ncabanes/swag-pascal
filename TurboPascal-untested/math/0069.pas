
Function CheckPrime(a : integer) : boolean;
Var
  x : integer;
  y : integer;
Begin
  y:=0;
  for x:=1 to (a div 2) do  {Only #s up to half of a can be factors}
  begin
    if (a mod x)=0 then y:=(y+1)
  end;
  if y=2 then checkprime:=true else checkprime:=false;
  if a=1 then checkprime:=true;
End;

You see, only prime numbers have exactly two factors, themselves and one.
With the exception of One.  Therefore you have a specific IF for the
number one.  One is prime, yet its only factor is one.  I think - Is one
prime or not?  Anyway, remove that line if it isn't, the function will work.
