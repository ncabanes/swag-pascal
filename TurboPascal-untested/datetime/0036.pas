
              (* * * * * * * * * * * * * * * * * * * * * * *)
              (*   UNIT: DTIME - By Alan Graff, Nov. 92    *)
              (*      Compiled from routines found in:     *)
              (*       DATEPAK4: W.G.Madison, Nov. 87      *)
              (*       UNIXDATE: Brian Stark, Jan. 92      *)
              (*   Plus various things of my own creation  *)
              (*   and extracted from Fidonet PASCAL echo  *)
              (*   messages and other sources.             *)
              (*      Contributed to the Public Domain     *)
              (*          Version 1.1 - Nov. 1992          *)
              (* * * * * * * * * * * * * * * * * * * * * * *)

UNIT DTime;
{**************************************************************}
INTERFACE
uses crt,dos;

TYPE DATETYPE = record
     day:WORD;
     MONTH:WORD;
     YEAR:WORD;
     dow:word;
     end;

 (* Sundry determinations of current date/time variables *)
Function  DayOfYear:word;  (* Returns 1 to 365 *)
Function DayOfMonth:word;  (* Returns 1 to 31  *)
Function DayOfWeek:word;   (* Returns 1 to 7   *)
Function MonthOfYear:word; (* Returns 1 to 12  *)
Function ThisYear:word;    (* Returns current year *)
Function ThisHour:word;    (* Returns 1 to 24  *)
Function ThisMinute:word;  (* Returns 0 to 59  *)
  (* Calculate what day of the week a particular date falls on *)
Procedure WkDay(Year,Month,Day:Integer; var WeekDay:Integer);
   (* Full Julian conversions *)
Procedure GregorianToJulianDN(Year,Month,Day:Integer;var JulianDN:LongInt);
Procedure JulianDNToGregorian(JulianDN:LongInt;var Year,Month,Day:Integer);
   (* 365 day Julian conversions *)
Procedure GregorianToJulianDate(Year,Month,Day:Integer;var JulianDate:Integer);
Procedure JulianToGregorianDate(JulianDate,Year:Integer;var Month,Day:Integer);
   (* Sundry string things *)
Function  DateString:String;  (* Returns system date as "mm-dd-yy" string *)
Function  TimeString:String;  (* Returns system time as "00:00:00" string *)
  (* Create current YYMMDD string to use as a file name *)
Function DateAFile(dy,dm,dd:word):string;
  (* Return YY-MM-DD string from filename created by DateAFile func *)
Function Parsefile(s:string):string;
   (* Return values of 1 day ago *)
Procedure Yesterday(Var y,m,d:integer);
   (* Return values of 1 day ahead *)
Procedure Tomorrow(Var y,m,d:integer);
 (* Adjust time based on "TZ" environment *)
Function  GetTimeZone : ShortInt;
Function  IsLeapYear(Source : Word) : Boolean;  (* What it says :-)  *)
  (* Unix date conversions *)
Function Norm2Unix(Y,M,D,H,Min,S:Word):LongInt;
Procedure Unix2Norm(Date:LongInt;Var Y,M,D,H,Min,S:Word);
  (* Determines what day of year Easter falls on *)
Procedure Easter(Year:Word;Var Date:DateType);
  (* Determines what day of year Thanksgiving falls on *)
Procedure Thanksgiving(Year:Word;Var Date:DateType);
  (* Determine what percentage of moon is lit on a particular night *)
Function MoonPhase(Date:Datetype):Real;

IMPLEMENTATION

const
  D0 =    1461;
  D1 =  146097;
  D2 = 1721119;
  DaysPerMonth :  Array[1..12] of ShortInt =
(031,028,031,030,031,030,031,031,030,031,030,031);
  DaysPerYear  :  Array[1..12] of Integer  =
(031,059,090,120,151,181,212,243,273,304,334,365);
  DaysPerLeapYear :    Array[1..12] of Integer  =
(031,060,091,121,152,182,213,244,274,305,335,366);
  SecsPerYear      : LongInt  = 31536000;
  SecsPerLeapYear  : LongInt  = 31622400;
  SecsPerDay       : LongInt  = 86400;
  SecsPerHour      : Integer  = 3600;
  SecsPerMinute    : ShortInt = 60;

Procedure GregorianToJulianDN;
var
  Century,
  XYear    : LongInt;
begin {GregorianToJulianDN}
  If Month <= 2 then begin
    Year := pred(Year);
    Month := Month + 12;
    end;
  Month := Month - 3;
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  JulianDN := ((((Month * 153) + 2) div 5) + Day) + D2 + XYear + Century;
  end; {GregorianToJulianDN}
{**************************************************************}
Procedure JulianDNToGregorian;
var
  Temp,
  XYear   : LongInt;
  YYear,
  YMonth,
  YDay    : Integer;
begin {JulianDNToGregorian}
  Temp := (((JulianDN - D2) shl 2) - 1);
  XYear := (Temp mod D1) or 3;
  JulianDN := Temp div D1;
  YYear := (XYear div D0);
  Temp := ((((XYear mod D0) + 4) shr 2) * 5) - 3;
  YMonth := Temp div 153;
  If YMonth >= 10 then begin
    YYear := YYear + 1;
    YMonth := YMonth - 12;
    end;
  YMonth := YMonth + 3;
  YDay := Temp mod 153;
  YDay := (YDay + 5) div 5;
  Year := YYear + (JulianDN * 100);
  Month := YMonth;
  Day := YDay;
  end; {JulianDNToGregorian}
{**************************************************************}
Procedure GregorianToJulianDate;
var
  Jan1,
  Today : LongInt;
begin {GregorianToJulianDate}
  GregorianToJulianDN(Year, 1, 1, Jan1);
  GregorianToJulianDN(Year, Month, Day, Today);
  JulianDate := (Today - Jan1 + 1);
  end; {GregorianToJulianDate}
{**************************************************************}
Procedure JulianToGregorianDate;
var
  Jan1  : LongInt;
begin
  GregorianToJulianDN(Year, 1, 1, Jan1);
  JulianDNToGregorian((Jan1 + JulianDate - 1), Year, Month, Day);
  end; {JulianToGregorianDate}
{**************************************************************}
Procedure WkDay;
var
  DayNum : LongInt;
begin
  GregorianToJulianDN(Year, Month, Day, DayNum);
  DayNum := ((DayNum + 1) mod 7);
  WeekDay := (DayNum) + 1;
  end; {DayOfWeek}
{**************************************************************}
Procedure Yesterday(Var Y,M,D:integer);
var jdn:longint;
begin
GregorianToJulianDN(Y,M,D,JDN);
JDN:=JDN-1;
JulianDNToGregorian(JDN,Y,M,D);
end;
{**************************************************************}
Procedure Tomorrow(Var Y,M,D:integer);
var JDN:longint;
begin
GregorianToJulianDN(Y,M,D,JDN);
JDN:=JDN+1;
JulianDNToGregorian(JDN,Y,M,D);
end;
{**************************************************************}
Function TimeString:string;
var hr,mn,sec,hun:word;
s,q:string;
begin
  q:='';
  gettime(hr,mn,sec,hun);
  if hr<10 then q:=q+'0';
  str(hr:1,s);
  q:=q+s+':';
  if mn<10 then q:=q+'0';
  str(mn:1,s);
  q:=q+s;
  TimeString:=q;
end;
{**************************************************************}
Function ThisHour:Word;
var hr,mn,sec,hun:word;
begin
  gettime(hr,mn,sec,hun);
  ThisHour:=hr;
end;
{**************************************************************}
Function ThisMinute:Word;
var hr,mn,sec,hun:word;
begin
  gettime(hr,mn,sec,hun);
  ThisMinute:=mn;
end;
{**************************************************************}
Function DateString:string;
var yr,mo,dy,dow:word;
    s,q:string;
begin
  q:='';
  getdate(yr,mo,dy,dow);
  if mo<10 then q:=q+'0';
  str(mo:1,s);
  q:=q+s+'-';
  if dy<10 then q:=q+'0';
  str(dy:1,s);
  q:=q+s+'-';
  while yr>100 do yr:=yr-100;
  if yr<10 then q:=q+'0';
  str(yr:1,s);
  q:=q+s;
  Datestring:=q;
end;
{**************************************************************}
Function parsefile(s:string):string;  { Return date string from a file name }
var mo,errcode:word;                  { in either YYMMDD.EXT or MMDDYY.EXT  }
    st:string;                        { format.                             }
begin
st:=copy(s,1,2)+'-'+copy(s,3,2)+'-'+copy(s,5,2);
parsefile:=st;
end;
{**************************************************************}
function dateafile(dy,dm,dd:word):string;
var s1,s2:string;
begin
while dy>100 do dy:=dy-100;
str(dy,s1);
while length(s1)<2 do s1:='0'+s1;
s2:=s1;
str(dm,s1);
while length(s1)<2 do s1:='0'+s1;
s2:=s2+s1;
str(dd,s1);
while length(s1)<2 do s1:='0'+s1;
s2:=s2+s1;
dateafile:=s2;
end;
{**************************************************************}
Function DayOfMonth:Word;
var yr,mo,dy,dow:word;
begin
  getdate(yr,mo,dy,dow);
  DayOfMonth:=dy;
end;
{**************************************************************}
Function ThisYear:Word;
var yr,mo,dy,dow:word;
begin
  getdate(yr,mo,dy,dow);
  ThisYear:=yr;
end;

{**************************************************************}
Function DayOfWeek:word;
var yr,mo,dy,dow:word;
begin
  getdate(yr,mo,dy,dow);    (* Turbo Pascal authors never saw a *)
  dow:=dow+1;               (* calendar.  Their first day of    *)
  if dow=8 then dow:=1;     (* week is Monday....               *)
  DayOfWeek:=dow;
end;
{**************************************************************}
Function MonthOfYear:Word;
var yr,mo,dy,dow:word;
begin
  getdate(yr,mo,dy,dow);
  monthofyear:=mo;
end;
{**************************************************************}
Function GetTimeZone : ShortInt;
Var
  Environment : String;
  Index : Integer;
Begin
  GetTimeZone := 0;                            {Assume UTC}
  Environment := GetEnv('TZ');       {Grab TZ string}
  For Index := 1 To Length(Environment) Do
    Environment[Index] := Upcase(Environment[Index]);
  If Environment =  'EST05'    Then GetTimeZone := -05; {USA EASTERN}
  If Environment =  'EST05EDT' Then GetTimeZone := -06;
  If Environment =  'CST06'    Then GetTimeZone := -06; {USA CENTRAL}
  If Environment =  'CST06CDT' Then GetTimeZone := -07;
  If Environment =  'MST07'    Then GetTimeZone := -07; {USA MOUNTAIN}
  If Environment =  'MST07MDT' Then GetTimeZone := -08;
  If Environment =  'PST08'    Then GetTimeZone := -08;
  If Environment =  'PST08PDT' Then GetTimeZone := -09;
  If Environment =  'YST09'    Then GetTimeZone := -09;
  If Environment =  'AST10'    Then GetTimeZone := -10;
  If Environment =  'BST11'    Then GetTimeZone := -11;
  If Environment =  'CET-1'    Then GetTimeZone :=  01;
  If Environment =  'CET-01'   Then GetTimeZone :=  01;
  If Environment =  'EST-10'   Then GetTimeZone :=  10;
  If Environment =  'WST-8'    Then GetTimeZone :=  08; {Perth,W.Austrailia}
  If Environment =  'WST-08'   Then GetTimeZone :=  08;
End;
{**************************************************************}
Function IsLeapYear(Source : Word) : Boolean;
Begin
  If (Source Mod 4 = 0) Then
    IsLeapYear := True
  Else
    IsLeapYear := False;
End;
{**************************************************************}
Function Norm2Unix(Y,M,D,H,Min,S : Word) : LongInt;
Var
  UnixDate : LongInt;
  Index    : Word;
Begin
  UnixDate := 0;                                              {initialize}
  Inc(UnixDate,S);                                           {add seconds}
  Inc(UnixDate,(SecsPerMinute * Min));                       {add minutes}
  Inc(UnixDate,(SecsPerHour * H));                             {add hours}
  UnixDate := UnixDate - (GetTimeZone * SecsPerHour);         {UTC offset}
  If D > 1 Then                              {has one day already passed?}
    Inc(UnixDate,(SecsPerDay * (D-1)));
  If IsLeapYear(Y) Then
    DaysPerMonth[02] := 29
  Else
    DaysPerMonth[02] := 28;                          {Check for Feb. 29th}
  Index := 1;
  If M > 1 Then For Index := 1 To (M-1) Do {has one month already passed?}
    Inc(UnixDate,(DaysPerMonth[Index] * SecsPerDay));
  While Y > 1970 Do
  Begin
    If IsLeapYear((Y-1)) Then
      Inc(UnixDate,SecsPerLeapYear)
    Else
      Inc(UnixDate,SecsPerYear);
    Dec(Y,1);
  End;
  Norm2Unix := UnixDate;
End; Procedure Unix2Norm(Date : LongInt; Var Y, M, D, H, Min, S : Word);
{}
Var
  LocalDate : LongInt; Done : Boolean; X : ShortInt; TotDays : Integer;
Begin
  Y   := 1970; M := 1; D := 1; H := 0; Min := 0; S := 0;
  LocalDate := Date + (GetTimeZone * SecsPerHour);      {Local time date}
  Done := False;
  While Not Done Do
  Begin
    If LocalDate >= SecsPerYear Then
    Begin
      Inc(Y,1);
      Dec(LocalDate,SecsPerYear);
    End
    Else
      Done := True;
    If (IsLeapYear(Y+1)) And (LocalDate >= SecsPerLeapYear) And
       (Not Done) Then
    Begin
      Inc(Y,1);
      Dec(LocalDate,SecsPerLeapYear);
    End;
  End;
  M := 1; D := 1;
  Done := False;
  TotDays := LocalDate Div SecsPerDay;
  If IsLeapYear(Y) Then
  Begin
    DaysPerMonth[02] := 29;
    X := 1;
    Repeat
      If (TotDays <= DaysPerLeapYear[x]) Then
      Begin
        M := X;
        Done := True;
        Dec(LocalDate,(TotDays * SecsPerDay));
        D := DaysPerMonth[M]-(DaysPerLeapYear[M]-TotDays) + 1;
      End
      Else
        Done := False;
      Inc(X);
    Until (Done) or (X > 12);
  End
  Else
  Begin
    DaysPerMonth[02] := 28;
    X := 1;
    Repeat
      If (TotDays <= DaysPerYear[x]) Then
      Begin
        M := X;
        Done := True;
        Dec(LocalDate,(TotDays * SecsPerDay));
        D := DaysPerMonth[M]-(DaysPerYear[M]-TotDays) + 1;
      End
      Else
        Done := False;
      Inc(X);
    Until Done = True or (X > 12);
  End;
  H := LocalDate Div SecsPerHour;
    Dec(LocalDate,(H * SecsPerHour));
  Min := LocalDate Div SecsPerMinute;
    Dec(LocalDate,(Min * SecsPerMinute));
  S := LocalDate;
End;
{**************************************************************}
Function DayOfYear;
var
  HCentury,Century,Xyear,
  Ripoff,HXYear    : LongInt;
  Holdyear,Holdmonth,Holdday:Integer;
  year,month,day,dofwk:word;
begin {DayofYear}
  getdate(year,month,day,dofwk);
  Holdyear:=year-1;
  Holdmonth:=9;
  Holdday:=31;
  HCentury := HoldYear div 100;
  HXYear := HoldYear mod 100;
  HCentury := (HCentury * D1) shr 2;
  HXYear := (HXYear * D0) shr 2;
  Ripoff := ((((HoldMonth * 153) + 2) div 5) + HoldDay) + D2 + HXYear +
HCentury;
  If Month <= 2 then begin
    Year := pred(Year);
    Month := Month + 12;
    end;
  Month := Month - 3;
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  DayofYear := (((((Month * 153) + 2) div 5) + Day) + D2 + XYear + Century)-
ripoff;
  end; {DayOfYear}
Procedure Easter(Year : Word; Var Date : DateType);
   (* Calculates what day Easter falls on in a given year         *)
   (* Set desired Year and result is returned in Date variable    *)
Var
   GoldenNo,
   Sun,
   Century,
   LeapCent,
   LunarCorr,
   Epact,
   FullMoon : Integer;
Begin
   Date.Year := Year;
   GoldenNo := (Year Mod 19) + 1;
   Century := (Year Div 100) + 1;
   LeapCent := (3 * Century Div 4) - 12;
   LunarCorr := ((8 * Century + 5) Div 25) - 5;
   Sun := (5 * Year Div 4) - LeapCent - 10;
   Epact := Abs(11 * GoldenNo + 20 + LunarCorr - LeapCent) Mod 30;
   If ((Epact = 25) And (GoldenNo > 11)) Or (Epact = 24) then
      Inc(Epact);
   FullMoon := 44 - Epact;
   If FullMoon < 21 then
      Inc(FullMoon, 30);
   Date.Day := FullMoon + 7 - ((Sun + FullMoon) Mod 7);
   If Date.Day > 31 then
      Begin
         Dec(Date.Day, 31);
         Date.Month := 4;
      End
   Else
      Date.Month := 3;
   Date.DOW := 0;
End;
{**************************************************************}
Procedure Thanksgiving(Year : Word; Var Date : DateType);
   (* Calculates what day Thanksgiving falls on in a given year   *)
   (* Set desired Year and result is returned in Date variable    *)
Var
  Counter,WeekDay:Word;
  Daynum:longint;
Begin
   Date.Year := Year;
   Date.Month := 11;
   counter:=29;
   repeat
     dec(counter);
     GregorianToJulianDN(Date.Year, Date.Month, Counter, DayNum);
     DayNum := ((DayNum + 1) mod 7);
     WeekDay := (DayNum) + 1;
   Until Weekday = 5;
   Date.Day:=Counter;
End;
{*************************************************************}
Function MoonPhase(Date:Datetype):Real;
  (* Determines APPROXIMATE phase of the moon (percentage lit)   *)
  (* 0.00 = New moon, 1.00 = Full moon                           *)
  (* Due to rounding, full values may possibly never be reached  *)
  (* Valid from Oct. 15, 1582 to Feb. 28, 4000                   *)
  (* Calculations adapted to Turbo Pascal from routines found in *)
  (* "119 Practical Programs For The TRS-80 Pocket Computer"     *)
  (* John Clark Craig, TAB Books, 1982                      (Ag) *)
VAR j:longint; m:real;
Begin
  GregorianToJulianDN(Date.Year,Date.Month,Date.Day,J);
  M:=(J+4.867)/ 29.53058;
  M:=2*(M-Int(m))-1;
  MoonPhase:=Abs(M);
end;

END.
