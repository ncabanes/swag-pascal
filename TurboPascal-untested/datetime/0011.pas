{
SEAN PALMER

> This is kinda primative, but it will work, and hopefully if
> someone else has a more elegant way of testing a set, they
> will jump in
}

Uses
  Crt;
Type
  days = (Sun, Mon, Tue, Wed, Thu, Fri, Sat);

Var
  d : days;

Const
  fullWeek  : set of days = [Sun..Sat];
  weekend   : set of days = [Sun, Sat];
  weekDays  : set of days = [Mon..Fri];
  weekChars : Array[days] of Char = ('S','M','T','W','T','F','S');

begin
  Writeln;
  For d := Sun to Sat do
  begin
    if d in weekDays then
      TextAttr := 14
    else
      TextAttr := 7;
    Write(weekChars[d]);
  end;
  Writeln;
  TextAttr := 7;
end.
