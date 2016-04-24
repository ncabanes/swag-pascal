(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0056.PAS
  Description: Days since 1/1/1970
  Author: LEE BARKER
  Date: 11-25-95  09:26
*)

{
 "Does anyone have a decent routine for converting a
 date to and from the number of days since 1/1/1970,
 which properly takes into account leap years?"

While you can use Julian math, I use/wrote the following-
(Note: An integer can hold up to a little over 89 years,
or a word can hold upto 65536 days or about 179 years)
}

function leapyear (c,y : byte) : boolean;
  begin
    if (y and 3) <> 0
    then leapyear := false
    else if y=0
         then leapyear := (c and 3)=0
         else leapyear := true;
  end;

function DaysInMonth (c,y,m : byte) : integer;
  begin
    if m=2
    then if leapyear(c,y)
         then DaysInMonth := 29
         else DaysInMonth := 28
    else DaysInMonth := 30 + (($15AA shr m) and 1);
  end;

function DaysInYear (c,y : byte) : integer;
  begin
    DaysInYear := DaysInMonth(c,y,2)+337;
  end;

Function DayOfYear (c,y,m,d :byte) : integer;
  var i,j : integer;
  begin
    j := d;
      for i := 1 to pred(m) do j := j + DaysInMonth(c,y,i);
    DayOfYear := j;
  end;

So for date2-date1
   x := DaysInYear(date1) - DatOfYear(Date1);
   for i := succ(date1) to pred(date2) do
     x := x + DaysInYear(i);
   x := x + DayOfYear(date2);

