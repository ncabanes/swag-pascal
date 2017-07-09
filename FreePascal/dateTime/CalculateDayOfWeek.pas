(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0027.PAS
  Description: Calculate Day Of Week
  Author: EARL DUNOVANT
  Date: 11-02-93  05:33
*)

{
EARL DUNOVANT

> Which date is what day For a particular month.

Zeller's Congruence is an algorithm that calculates a day of the week given
a year, month and day. Created in 1887(!). Jeff Duntemann of PC Techniques
fame implemented it in TP in the 11/90 issue of Dr Dobbs Journal, With a
(115 min left), (H)elp, More? major kludge because TP's MOD operator returns a remainder instead of a
True mathematical modulus. I added the Kludge Alert banner that I use in my
own code.
}

Function CalcDayOfWeek(Year, Month, Day : Integer) : Integer;
Var
  Century,
  Holder  : Integer;
begin
  { First test For error conditions on input values: }
  if (Year < 0) or (Month < 1) or (Month > 12) or (Day < 1) or (Day > 31) then
    CalcDayOfWeek := -1  { Return -1 to indicate an error }
  else
  { Do the Zeller's Congruence calculation as Zeller himself }
  { described it in "Acta Mathematica" #7, Stockhold, 1887.  }
  begin
    { First we separate out the year and the century figures: }
    Century := Year div 100;
    Year    := Year MOD 100;
    { Next we adjust the month such that March remains month #3, }
    { but that January and February are months #13 and #14,     }
    { *but of the previous year*: }
    if Month < 3 then
    begin
      Inc(Month, 12);
      if Year > 0 then
        Dec(Year, 1)      { The year before 2000 is }
      else              { 1999, not 20-1...       }
      begin
        Year := 99;
        Dec(Century);
      end;
    end;

    { Here's Zeller's seminal black magic: }
    Holder := Day;                        { Start With the day of month }
    Holder := Holder + (((Month + 1) * 26) div 10); { Calc the increment }
    Holder := Holder + Year;              { Add in the year }
    Holder := Holder + (Year div 4);      { Correct For leap years  }
    Holder := Holder + (Century div 4);   { Correct For century years }
    Holder := Holder - Century - Century; { DON'T KNOW WHY HE DID THIS! }
    {***********************KLUDGE ALERT!***************************}
    While Holder < 0 do                   { Get negative values up into }
      Inc(Holder, 7);                     { positive territory before   }
                                          { taking the MOD...         }
    Holder := Holder MOD 7;               { Divide by 7 but keep the  }
                                          { remainder rather than the }
                                          { quotient }
    {***********************KLUDGE ALERT!***************************}
    { Here we "wrap" Saturday around to be the last day: }
    if Holder = 0 then
      Holder := 7;

    { Zeller kept the Sunday = 1 origin; computer weenies prefer to }
    { start everything With 0, so here's a 20th century kludge:     }
    Dec(Holder);

    CalcDayOfWeek := Holder;  { Return the end product! }
  end;
end;

{ Test program added by Nacho, 2017 }
begin
    Write('Day of week for 2017-07-08 is... ');
    WriteLn (CalcDayOfWeek(2017, 07, 08));
end.
