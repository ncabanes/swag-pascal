(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0164.PAS
  Description: Dates for Delphi
  Author: DENNIS PASSMORE
  Date: 08-30-96  09:35
*)


unit JDates;

{ A unit providing Julian day numbers and date manipulations.

  NOTE:
   The range of Dates this unit will handle is 1/1/1900 to 1/1/2078

  Version 1.00 - 10/26/1987 - First general release

  Scott Bussinger
  Professional Practice Systems
  110 South 131st Street
  Tacoma, WA  98444
  (206)531-8944
  Compuserve 72247,2671

  Version 1.01 - 10/09/1995 - Updated for use with Delphi v1.0
                   Lets see some other code last this long without change

  Dennis Passmore
  1929 Mango Tree Drive
  Edgewater Fl, 32141

  Compuserve 71240,2464 }

interface
uses
  Sysutils;

const
  BlankDate = $FFFF;                         { Constant for Not-a-real-Date }

type TDate = Word;
     TDay = (Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday);
     TDaySet = set of TDay;

procedure GetDate(var Year,Month,Day,Wday: Word);
  { replacement for old WINDOS proc }

procedure GetTime(var Hour,Min,Sec,MSec: Word);
  { replacement for old WINDOS proc }

function  CurrentJDate: Tdate;

function  ValidDate(Day,Month,Year: Word): boolean;
  { Check if the day,month,year is a real date storable in a Date variable }


procedure DMYtoDate(Day,Month,Year: Word;var Julian: TDate);
  { Convert from day,month,year to a date }

procedure DateToDMY(Julian: TDate;var Day,Month,Year: Word);
  { Convert from a date to day,month,year }

function BumpDate(Julian: TDate;Days,Months,Years: Integer): TDate;
  { Add (or subtract) the number of days, months, and years to a date }

function DayOfWeek(Julian: TDate): TDay;
  { Return the day of the week for the date }

function DayString(WeekDay: TDay): string;
  { Return a string version of a day of the week }

function MonthString(Month: Word): string;
  { Return a string version of a month }

function DateToStr(Julian: TDate): string;
  { Convert a date to a sortable string }

function StrToDate(StrVar: string): TDate;
  { Convert a sortable string form to a date }

implementation

procedure GetDate(var Year,Month,Day,Wday: Word);
var
  td: TDatetime;
begin
  td := Date;

  DeCodeDate(td,Year,Month,Day);
  Wday := sysutils.DayofWeek(td);
end;

procedure GetTime(var Hour,Min,Sec,MSec: Word);
var
  td: TDatetime;
begin
  td := Now;
  DecodeTime(td,Hour,Min,Sec,MSec);
end;

function  CurrentJdate: Tdate;
var
 y,m,d,w: word;
 jd: TDate;
begin
  GetDate(y,m,d,w);
  DMYtoDate(d,m,y,jd);
  CurrentJDate:= jd;
end;

function ValidDate(Day,Month,Year: Word): boolean;
  { Check if the day,month,year is a real date storable in a Date variable }
begin
  if {(Day<1) or }(Year<1900) or (Year>2078) then
    ValidDate := false
  else
    case Month of
      1,3,5,7,8,10,12: ValidDate := Day <= 31;

      4,6,9,11: ValidDate := Day <= 30;
      2: ValidDate := Day <= 28 + ord((Year mod 4)=0)*ord(Year<>1900)
      else ValidDate := false
    end
end;

procedure DMYtoDate(Day,Month,Year: Word;var Julian: TDate);
  { Convert from day,month,year to a date }
  { Stored as number of days since January 1, 1900 }
  { Note that no error checking takes place in this routine -- use ValidDate }
begin
if (Year=1900) and (Month<3) then
  if Month = 1 then
    Julian := pred(Day)
  else
    Julian := Day + 30
else
  begin
    if Month > 2 then
      dec(Month,3)
    else
      begin
        inc(Month,9);
        dec(Year)

      end;
    dec(Year,1900);
    Julian := (1461*longint(Year) div 4) + ((153*Month+2) div 5) + Day + 58;
  end
end;

procedure DateToDMY(Julian: TDate;var Day,Month,Year: Word);
  { Convert from a date to day,month,year }
var
  LongTemp: longint;
      Temp: Word;
begin
  if Julian <= 58 then
    begin
      Year := 1900;
      if Julian <= 30 then
        begin
          Month := 1;
          Day := succ(Julian)
        end
      else
        begin
          Month := 2;
          Day := Julian - 30
        end
    end
  else
    begin
      LongTemp := 4*longint(Julian) - 233;

      Year := LongTemp div 1461;
      Temp := LongTemp mod 1461 div 4 * 5 + 2;
      Month := Temp div 153;
      Day := Temp mod 153 div 5 + 1;
      inc(Year,1900);
      if Month < 10 then
        inc(Month,3)
      else
        begin
          dec(Month,9);
          inc(Year)
        end
    end
end;

function BumpDate(Julian: TDate;Days,Months,Years: Integer): TDate;
  { Add (or subtract) the number of days, months, and years to a date }
  { Note that months and years are added first before days }
  { Note further that there are no overflow/underflow checks }
var Day: Word;
    Month: Word;
    Year: Word;
begin
  DateToDMY(Julian,Day,Month,Year);

  Month := Month + Months - 1;
  Year := Year + Years + (Month div 12) - ord(Month<0);
  Month := (Month + 12000) mod 12 + 1;
  DMYtoDate(Day,Month,Year,Julian);
  BumpDate := Julian + Days
end;

function DayOfWeek(Julian: TDate): TDay;
  { Return the day of the week for the date }
begin
  DayOfWeek := TDay(succ(Julian) mod 7)
end;

function DayString(WeekDay: TDay): string;
  { Return a string version of a day of the week }
const DayStr: array[Sunday..Saturday] of string[9] =
     ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

begin
  DayString := DayStr[WeekDay]
end;

function MonthString(Month: Word): string;
  { Return a string version of a month }
  const MonthStr: array[1..12] of string[9] =
     ('January','February','March','April','May','June','July','August',
                                 'September','October','November','December');
begin
  MonthString := MonthStr[Month]
end;

function DateToStr(Julian: TDate): string;
  { Convert a date to a sortable string - NOT displayable }
const tResult: record
                case integer of
                  0: (Len: byte;  W: word);
                  1: (Str: string[2])

                end = (Str:'  ');
begin
  tResult.W := swap(Julian);
  DateToStr := tResult.Str
end;

function StrToDate(StrVar: string): TDate;
  { Convert a sortable string form to a date }
var Temp: record
            Len: byte;
              W: word
          end absolute StrVar;
begin
  StrToDate := swap(Temp.W)
end;

end.


