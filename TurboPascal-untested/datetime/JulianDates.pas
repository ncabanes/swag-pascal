(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0028.PAS
  Description: Julian Dates
  Author: VINCE LAURENT
  Date: 11-02-93  05:57
*)

{
VINCE LAURENT

> Does anyone have a fast function for sorting two dates?
> Something like function SortDate(Date1, Date2 : string): integer;
> Strings would be in the format of '1/1/94' etc.

Convert the dates to Julian Dates first...then you can do with them
what you want.  Here is a unit I got a long time ago...
}

UNIT Julian;
{
////////////////////////////////////////// DEMO Routines
/Begin
/  ClrScr;
/  GetDate(Year,Month,Day,Dow);

/  WriteLn('Year  : ',Year);
/  WriteLn('Month : ',Month);
/  WriteLn('Day   : ',Day);
/  WriteLn('DOW   : ',Dow);
/  WriteLn(MachineDate);
/  JulianDate := DateToJulian(MachineDate);
/  WriteLn('Julian Date = ',JulianDate);
/  WriteLn('Jul To Date = ',JulianToDate(JulianDate));
/  WriteLn('Day Of Week = ',DayOfWeek(JulianDate));
/  WriteLn('Time        = ',MachineTime(4));
/End.
///////////////////////////////////////////////////////////////
}
INTERFACE

Uses
  Crt, Dos;

Type
  Str3  = String[3];
  Str8  = String[8];
  Str9  = String[9];
  Str11 = String[11];

Var
  Hour,
  Minute,
  Second,
  S100,
  Year,
  Month,
  Day,
  Dow        : Word;
  Syear,
  Smonth,
  Sday,
  Sdow       : String;
  JulianDate : Integer;

Function  MachineTime(Len : Byte) : Str11;
Function  MachineDate : Str8;
Function  DateFactor(MonthNum, DayNum, YearNum : Real) : Real;
Function  DateToJulian(DateLine : Str8) : Integer;
Function  JulianToDate(DateInt : Integer): Str11;
Function  JulianToStr8(DateInt : Integer): Str8;
Function  DayofWeek(Jdate : Integer) : Str3;
Procedure DateDiff(Date1,Date2 : Integer; VAR Date_Difference : Str9);

IMPLEMENTATION

Function MachineTime(Len : Byte) : Str11;
Var
  I       : Byte;
  TempStr : String;
  TimeStr : Array[1..4] Of String;

Begin
  TempStr := '';
  FillChar(TimeStr, SizeOf(TimeStr),0);
  GetTime(Hour, Minute, Second, S100);
  Str(Hour, TimeStr[1]);
  Str(Minute, TimeStr[2]);
  Str(Second, TimeStr[3]);
  Str(S100, TimeStr[4]);
  TempStr := TimeStr[1];
  For I := 2 To Len Do
    TempStr := TempStr + ':' + TimeStr[I];
  MachineTime := TempStr;
End;

Function MachineDate : Str8;
Begin
  GetDate(Year, Month, Day, Dow);
  Str(Year, Syear);
  Str(Month, Smonth);
  If Month < 10 Then
    Smonth := '0' + Smonth;
  Str(Day,Sday);
  If Day < 10 Then
    Sday := '0' + Sday;
  MachineDate := smonth + sday + syear;
End;

Function DateFactor(MonthNum, DayNum, YearNum : Real) : Real;
Var
  Factor : Real;
Begin
  Factor := (365 * YearNum) + DayNum + (31 * (MonthNum - 1));
  If MonthNum < 3 Then
    Factor :=  Factor + Int((YearNum-1) / 4) -
               Int(0.75 * (Int((YearNum-1) / 100) + 1))
  Else
    Factor :=  Factor - Int(0.4 * MonthNum + 2.3) + Int(YearNum / 4) -
               Int(0.75 * (Int(YearNum / 100) + 1));
  DateFactor := Factor;
End;

Function DateToJulian(DateLine : Str8) : Integer;
Var
  Factor,
  MonthNum,
  DayNum,
  YearNum : Real;
  Ti      : Integer;
Begin
  If Length(DateLine) = 7 Then
    DateLine := '0' + DateLine;
  MonthNum := 0.0;
  For Ti := 1 to 2 Do
    MonthNum := (10 * MonthNum) + (Ord(DateLine[Ti])-Ord('0'));
  DayNum := 0.0;
  For Ti := 3 to 4 Do
    DayNum := (10 * DayNum) + (Ord(DateLine[Ti])-Ord('0'));
  YearNum := 0.0;
  For Ti := 5 to 8 Do
    YearNum := (10 * YearNum) + (Ord(DateLine[Ti])-Ord('0'));
  Factor := DateFactor(MonthNum, DayNum, YearNum);
  DateToJulian := Trunc((Factor - 679351.0) - 32767.0);
End;

Function JulianToDate(DateInt : Integer): Str11;
Var
  holdstr,
  strDay   : string[2];
  anystr   : string[11];
  StrMonth : string[3];
  stryear  :  string[4];
  test,
  error,
  Year,
  Dummy, I : Integer;
  Save,
  Temp     : Real;
  JulianToanystring : Str11;
Begin
  holdstr := '';
  JulianToanystring := '00000000000';
  Temp  := Int(DateInt) + 32767 + 679351.0;
  Save  := Temp;
  Dummy := Trunc(Temp/365.5);

  While Save >= DateFactor(1.0,1.0,Dummy+0.0) Do
    Dummy := Succ(Dummy);
  Dummy := Pred(Dummy);
  Year  := Dummy;
  (* Determine number Of Days into current year *)
  Temp  := 1.0 + Save - DateFactor(1.0,1.0,Year+0.0);
  (* Put the Year into the output string *)
  For I := 8 downto 5 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10) + Ord('0'));
    Dummy := Dummy div 10;
  End;
  Dummy := 1 + Trunc(Temp/31.5);
  While Save >= DateFactor(Dummy+0.0,1.0,Year+0.0) Do
    Dummy := Succ(Dummy);
  Dummy := Pred(Dummy);
  Temp  := 1.0 + Save - DateFactor(Dummy+0.0,1.0,Year+0.0);
  For I := 2 Downto 1 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10)+Ord('0'));
    Dummy := Dummy div 10;
  End;
  Dummy := Trunc(Temp);

  For I := 4 Downto 3 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10)+Ord('0'));
    Dummy := Dummy div 10;
  End;
  holdstr := copy(juliantoanystring,1,2);
  val(holdstr, test, error);
  Case test Of
    1 : StrMonth := 'Jan';
    2 : StrMonth := 'Feb';
    3 : StrMonth := 'Mar';
    4 : StrMonth := 'Apr';
    5 : StrMonth := 'May';
    6 : StrMonth := 'Jun';
    7 : StrMonth := 'Jul';
    8 : StrMonth := 'Aug';
    9 : StrMonth := 'Sep';
   10 : StrMonth := 'Oct';
   11 : StrMonth := 'Nov';
   12 : StrMonth := 'Dec';
  End;
  stryear := copy(juliantoanystring, 5, 4);
  strDay  := copy(juliantoanystring, 3, 2);
  anystr  := StrDay + '-' + StrMonth + '-' +stryear;
  JulianToDate := anystr;
End;

Function JulianToStr8(DateInt : Integer): Str8;
Var
  holdstr,
  StrMonth,
  strDay   : string[2];
  anystr   : string[8];
  stryear  : string[4];
  test,
  error,
  Year,
  Dummy,
  I       : Integer;
  Save,
  Temp    : Real;
  JulianToanystring : Str8;
Begin
  holdstr := '';
  JulianToanystring := '00000000';
  Temp  := Int(DateInt) + 32767 + 679351.0;
  Save  := Temp;
  Dummy := Trunc(Temp/365.5);
  While Save >= DateFactor(1.0,1.0,Dummy+0.0) Do
    Dummy := Succ(Dummy);
  Dummy := Pred(Dummy);
  Year  := Dummy;
  (* Determine number Of Days into current year *)
  Temp  := 1.0 + Save - DateFactor(1.0,1.0,Year+0.0);
  (* Put the Year into the output string *)
  For I := 8 downto 5 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10)+Ord('0'));
    Dummy := Dummy div 10;
  End;
  Dummy := 1 + Trunc(Temp/31.5);
  While Save >= DateFactor(Dummy+0.0,1.0,Year+0.0) Do
    Dummy := Succ(Dummy);
  Dummy := Pred(Dummy);
  Temp  := 1.0 + Save - DateFactor(Dummy+0.0,1.0,Year+0.0);
  For I := 2 Downto 1 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10)+Ord('0'));
    Dummy := Dummy div 10;
  End;
  Dummy := Trunc(Temp);

  For I := 4 Downto 3 Do
  Begin
    JulianToanystring[I] := Char((Dummy mod 10)+Ord('0'));
    Dummy := Dummy div 10;
  End;

  holdstr := copy(juliantoanystring,1,2);
  val(holdstr, test, error);
  Case test Of
    1 : StrMonth := '01';
    2 : StrMonth := '02';
    3 : StrMonth := '03';
    4 : StrMonth := '04';
    5 : StrMonth := '05';
    6 : StrMonth := '06';
    7 : StrMonth := '07';
    8 : StrMonth := '08';
    9 : StrMonth := '09';
   10 : StrMonth := '10';
   11 : StrMonth := '11';
   12 : StrMonth := '12';
  End;
  StrYear := copy(juliantoanystring, 5, 4);
  StrDay  := copy(juliantoanystring, 3, 2);
  AnyStr  := StrMonth + StrDay + StrYear;
  JulianToStr8 := AnyStr;
End;

Function DayofWeek(Jdate : Integer) : Str3;
Begin
  Case jdate MOD 7 Of
    0 : DayofWeek := 'Sun';
    1 : DayofWeek := 'Mon';
    2 : DayofWeek := 'Tue';
    3 : DayofWeek := 'Wed';
    4 : DayofWeek := 'Thu';
    5 : DayofWeek := 'Fri';
    6 : DayofWeek := 'Sat';
  End;
End;

Procedure DateDiff(Date1, Date2 : Integer; Var Date_Difference : Str9);
VAR
 Temp,
 Rdate1,
 Rdate2,
 Diff1  : Real;
 Diff   : Integer;
 Return : String[9];
 Hold   : String[3];
Begin
  Rdate2 := Date2 + 32767.5;
  Rdate1 := Date1 + 32767.5;
  Diff1  := Rdate1 - Rdate2;
  Temp   := Diff1;
  If Diff1 < 32 Then (* determine number of Days *)
  Begin
    Diff := Round(Diff1);
    Str(Diff,Hold);
    Return := Hold + ' ' + 'Day';
    If Diff > 1 Then
      Return := Return + 's  ';
  End;
  If ((Diff1 > 31) And (Diff1 < 366)) Then
  Begin
    Diff1 := Diff1 / 30;
    Diff  := Round(Diff1);
    Str(Diff,Hold);
    Return := Hold + ' ' + 'Month';
    If Diff > 1 Then
      Return := Return + 's';
  End;
  If Diff1 > 365 Then
  Begin
    Diff1 := Diff1 / 365;
    Diff  := Round(Diff1);

    Str(Diff,Hold);
    Return := Hold;
  End;
  Date_Difference := Return;
  Diff := Round(Diff1);
End;

END.



