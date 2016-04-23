{
I posted some routines on doing calendar math using Integers quite
a While back. That gives you a relative date of about 89 years. Use
LongInt For more. Avoids pulling in the Real lib that julian requires.
Just making them up again as I Type them in the reader. There may be a
typo or two.
}

Function leapyear (c, y : Byte) : Boolean;
begin
  if (y and 3) <> 0 then
          leapyear := False
  else
        if y <> 0 then
          leapyear := True
  else
        if (c and 3) = 0 then
          leapyear := True
  else
          leapyear := False;
end;

Function DaysInMonth (c, y, m : Byte) : Integer;
begin
  if m = 2 then
          if leapyear then
                  DaysInMonth := 29
    else
                  DaysInMonth := 28
  else
          DaysInMonth := 30 + (($0AB5 shr m) and 1);
end;

Function DaysInYear (c, y : Byte) : Integer;
begin
  DaysInYear := DaysInMonth(c, y, 2) + 337;
end;

Function DayOfYear (c, y, m, d :Byte) : Integer;
Var i, j : Integer;
begin
  j := d;
    For i := 1 to pred(m) do
                  j := j + DaysInMonth(c,y,i);
  DayOfYear := j;
end;