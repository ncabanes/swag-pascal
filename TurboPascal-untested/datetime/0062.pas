
unit dates;
{$O+}

{      EXDATE.PAS  -- Turbo Pascal Extended Date Subroutines

 This is a collection of useful calendar date subroutines which are
 valid from October 15, 1582 until such time as the Gregorian calendar
 is replaced.  Note that Great Britain did not change to the Gregorian
 calendar until 1752, Russia until 1918, and Turkey until 1928.  (These
 routines will work until the year 32767; after that, you will need
 to replace ints with longints.)

 The day of the week algorithm derivation is described very well in
 Rosen's "Elementary Number Theory and Its Applications" (Addison-Wesley,
 1984, pp 134-137).  The ordinal day algorithms are derived using
 reasoning similar to that of Rosen's derivation.  The serial day
 algorithms are based upon Julian day algorithms in Algorithm 199
 by Robert G. Tantzen in Communications of the ACM  6, 8 (Aug 1963),
 page 444.}

{==================================================================}

                         INTERFACE

const
   days : array [0..6] of String[9] =
      ('Sunday','Monday','Tuesday',
       'Wednesday','Thursday','Friday',
       'Saturday');

   months: array [0..11] of string[15] =
       ('January','February','March','April','May','June','July',
        'August','September','October','November','December');

function  today_day_of_week: integer;
function  today_day: integer;
function  today_month: integer;
function  today_year: integer;

function  day_of_week (day, month, year: integer) : integer;
function  ordinal_day (day, month, year: integer) : integer;

function today_serial_day: longint;

procedure from_ordinal_day(ordinal_day, year: integer;var day, month: integer);
function  valid_date(day, month, year: integer) : boolean;
function  day_diff(day_1, month_1, year_1, day_2, month_2, year_2: integer) : longint;
    {Returns the number of days between two dates, the first date being denoted
     by day_1, month_1, year_1, and the second by day_2, month_2, year_2.
     A negative value means that the second date is earlier than the first date.}

procedure days_from(day, month, year, days: integer; var new_day, new_month, new_year: integer);
   {Returns a date (new_day, new_month, new_year) which is a specified number
    of days (days) from a given date (day, month, year).   The number of days
    may be positive or negative.}

  {The following auxiliary procedures are in the interface just in case
   they may be useful for other purposes.}

function leap_year(year: integer) : integer;
   { Returns 1 for a leap year and 0 for others }

function serial_day(day, month, year: integer) : longint;
   {Converts a date to a "serial day" for performing calendar arithmetic.
    The serial day is the classic Julian date less 1721119.}

procedure from_serial_day (serial_day: longint; var day, month, year:integer);
    {Returns the day, month, year corresponding to a "serial day".}

{==================================================================}

                        IMPLEMENTATION

uses dos;

function today_serial_day: longint;
 begin
 today_serial_day:=serial_day(today_day,today_month,today_year);
 end;


function today_day_of_week: integer;
 var m,d,y,dw: word;
 begin
 getdate(y,m,d,dw);
 today_day_of_week := dw;
 end;

function today_month: integer;
 var m,d,y,dw: word;
 begin
 getdate(y,m,d,dw);
 today_month := m;
 end;

function today_day: integer;
 var m,d,y,dw: word;
 begin
 getdate(y,m,d,dw);
 today_day := d;
 end;

function Today_year: integer;
 var m,d,y,dw: word;
 begin
 getdate(y,m,d,dw);
 today_year := y;
 end;

function day_of_week (day, month, year: integer) : integer;
{Returns integer day of week for date.  0 = Sunday, 6 = Saturday
 Uses Zeller's congruence.}
   var century, yr, dw: integer;
   begin
      if month < 3 then begin
         month := month + 10;
         year := year -1
         end
      else
         month := month - 2;
      century := year div 100;
      yr := year mod 100;
      dw := (((26*month - 2) div 10)+day+yr+(yr div 4)+
         (century div 4) - (2*century)) mod 7;
      if dw < 0 then day_of_week := dw + 7 else day_of_week := dw;
   end;



function leap_year(year: integer) : integer;
   { Returns 1 for a leap year and 0 for others }
   begin
   if year and 3 <> 0 then leap_year := 0
   else if year mod 100 <> 0 then leap_year := 1
   else if year mod 400 <> 0 then leap_year := 0
   else leap_year := 1;
   end;

function ordinal_day (day, month, year: integer) : integer;
{Returns ordinal day of year (1-366) for date}
   var od: integer;
   begin
   if month < 3 then
      month := month + 10
   else
      month := month - 2;
   od := (306 * month - 2) div 10 - 30;
   if od < 306 then
      ordinal_day := od + 59 + leap_year(year) + day
   else
      ordinal_day := od - 306 + day;
   end;

procedure from_ordinal_day (ordinal_day, year: integer;
    var day, month: integer);
{Returns day and month for ordinal day of a year}
   var lyf, adj_mo: integer;
   begin
   lyf := leap_year(year) + 60;
   if ordinal_day < lyf then
      ordinal_day := ordinal_day + 305
   else
      ordinal_day := ordinal_day - lyf;
   adj_mo := (ordinal_day * 10 + 4) div 306 + 1;
   day := ordinal_day - ((adj_mo * 306 - 2) div 10 - 30) + 1;
   if adj_mo < 11 then
      month := adj_mo + 2
   else
      month := adj_mo - 10;
   end;

function valid_date(day, month, year: integer) : boolean;
{Determines whether a date is valid by transforming to an ordinal and
 trying to transform it back again.}
   var od, m, d: integer;
   begin
   od := ordinal_day(day, month, year);
   if (od > 366) or (od < 1) then
      valid_date := false
   else begin
      from_ordinal_day(od, year, d, m);
      if (d = day) and (m = month) then valid_date := true
      else valid_date := false
   end;
   end;

function serial_day(day, month, year: integer) : longint;
{Converts a date to a "serial day" for performing calendar arithmetic.
 The serial day is the classic Julian date less 1721119.}
var  m, y : longint;
   begin
      if month > 2 then begin
         m := month - 3;
         y := year;
      end
      else begin
         m := month + 9;
         y := year - 1;
      end;

      serial_day :=
         ((y div 100) * 146097) div 4 +
         ((y mod 100) * 1461) div 4 +
         (153 * m + 2) div 5 + day;
   end;

function day_diff(day_1, month_1, year_1, day_2, month_2, year_2: integer)
   : longint;
{Returns the number of days between two dates. A negative value means that the
 second date is earlier than the first date.}
   begin
   day_diff := serial_day(day_2, month_2, year_2) -
      serial_day(day_1, month_1, year_1);
   end;

procedure from_serial_day (serial_day: longint;
    var day, month, year:integer);
{Returns the date corresponding to a "serial day".}
   var j, d : longint;
   begin
      j := serial_day * 4 - 1;
      d := ((j mod 146097) div 4) * 4 + 3;
      year := (j div 146097) * 100 + (d div 1461);
      d := (((d mod 1461) + 4) div 4) * 5 - 3;
      month := d div 153;
      day := ((d mod 153) + 5) div 5;

      if month < 10 then
         month := month + 3
      else begin
         month := month - 9;
         year := year + 1;
      end;
   end;

procedure days_from(day, month, year, days: integer; var new_day,
      new_month, new_year: integer);
{Returns a date which is a specified number of days from a given date.
 The number of days may be positive or negative.}
   begin
   from_serial_day(serial_day(day, month, year) + days,
      new_day, new_month, new_year);
   end;

begin
end.
