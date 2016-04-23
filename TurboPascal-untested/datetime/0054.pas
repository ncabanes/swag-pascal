{A function and test program for computing the work week under one common
 definition.

 Written 94/10/05, Kim Kokkonen, TurboPower Software
}

uses
  opdate; {tpdate ok too}

function WeekOfYear(Julian : Date) : Integer;
  {-Return the week-of-year from a julian date. As defined here, the week
    always starts on a Sunday. Week 1 starts on the first Sunday of the
    year. Returns 0 for days earlier than that, and -1 for invalid dates.}

var
  Day, Month, Year : Integer;
  FirstJulian : Date;
  FirstDay : DayType;
begin
  {Exit for invalid dates}
  if (Julian < MinDate) or (Julian > MaxDate) then begin
    WeekOfYear := -1;
    exit;
  end;

  {Compute FirstJulian, the julian date for the first Sunday in the year}
  DateToDMY(Julian, Day, Month, Year);
  FirstJulian := DMYToDate(1, 1, Year);
  FirstDay := DayOfWeek(FirstJulian);
  if FirstDay <> Sunday then
    inc(FirstJulian, 7-Ord(FirstDay));

  if Julian < FirstJulian then
    WeekOfYear := 0
  else
    WeekOfYear := (Julian-FirstJulian+7) div 7;
end;

var
  s : string;
  d : date;

begin
  repeat
    Write('Enter date (dd/mm/yy): ');
    ReadLn(s);
    if s = '' then
      halt;
    if (Length(s) = 8) and (s[3] = '/') and (s[6] = '/') then begin
      d := DateStringToDate('dd/mm/yy', s);
      WriteLn('Week: ', WeekOfYear(d));
    end else
      WriteLn('Invalid date format');
  until False;
end.
