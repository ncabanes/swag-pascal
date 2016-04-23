{
TOM MOORE

> In a PASCAL-Program I want to execute a Procedure every time the
> user presses a key... Fairly easy, right ? But here comes the
> problem : I want to Repeat that Procedure Until he RELEASES that
> key...
}

Uses
  Crt;
Const
  Done : Boolean = False;
Var
  Ch : Char;


Procedure MakeSound;
begin
  if Port[$60] < $80 then
  begin
    Sound(220);
    Delay(100);
  end;
  if port[$60] >  $80 then
    NoSound;
end;

begin
  Repeat
    Repeat
    { While waiting For KeyPressed }
    Until KeyPressed;

    ch := ReadKey;
    if ch = #27 then halt;
      makeSound;
  Until Done;
end.
