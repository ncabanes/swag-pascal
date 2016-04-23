Unit Julian;
{DEMO Routines
/begin
/  ClrScr;
/  GetDate(Year,Month,Day,Dow);
/  WriteLn('Year  : ',Year);
/  WriteLn('Month : ',Month);
/  WriteLn('Day   : ',Day);
/  WriteLn('doW   : ',Dow);
/  WriteLn(MachineDate);
/  JulianDate := DatetoJulian(MachineDate);
/  WriteLn('Julian Date = ',JulianDate);
/  WriteLn('Jul to Date = ',JuliantoDate(JulianDate));
/  WriteLn('Day of Week = ',DayofWeek(JulianDate));
/  WriteLn('Time        = ',MachineTime(4));
/end.}
Interface

Uses Crt, Dos;

Type
  Str3  = String[3];
  Str8  = String[8];
  Str9  = String[9];
  Str11 = String[11];

Var
  Hour,Minute,Second,S100,
  Year,Month,Day,Dow     : Word;
  Syear,Smonth,Sday,Sdow : String;
  JulianDate             : Integer;

Function MachineTime(Len : Byte) : Str11;
Function MachineDate : Str8;
Function DateFactor(MonthNum, DayNum, YearNum : Real) : Real;
Function DatetoJulian(DateLine : Str8) : Integer;
Function JuliantoDate(DateInt : Integer): Str11;
Function JuliantoStr8(DateInt : Integer): Str8;
Function DayofWeek(Jdate : Integer) : Str3;
Procedure DateDiff(Date1,Date2 : Integer; Var Date_Difference : Str9);

Implementation
Function MachineTime(Len : Byte) : Str11;
Var
  I       : Byte;
  TempStr : String;
  TimeStr : Array[1..4] of String;
begin
  TempStr := ''; FillChar(TimeStr,Sizeof(TimeStr),0);
  GetTime(Hour,Minute,Second,S100);
  Str(Hour,TimeStr[1]);
  Str(Minute,TimeStr[2]);
  Str(Second,TimeStr[3]);
  Str(S100,TimeStr[4]);
  TempStr := TimeStr[1];
  For I := 2 to Len Do TempStr := TempStr + ':' + TimeStr[I];
  MachineTime := TempStr;
end;

Function MachineDate : Str8;
begin
  GetDate(Year,Month,Day,Dow);
  Str(Year,Syear);
  Str(Month,Smonth);
  if Month < 10 then Smonth := '0' + Smonth;
  Str(Day,Sday);
  if Day < 10 then Sday := '0' + Sday;
  MachineDate := smonth + sday + syear;
end;

Function DateFactor(MonthNum, DayNum, YearNum : Real) : Real;
Var
 Factor : Real;
begin
 Factor :=   (365 * YearNum)
           + DayNum
           + (31 * (MonthNum-1));
 if MonthNum < 3
  then Factor :=  Factor
                + Int((YearNum-1) / 4)
                - Int(0.75 * (Int((YearNum-1) / 100) + 1))
  else Factor :=  Factor
                - Int(0.4 * MonthNum + 2.3)
                + Int(YearNum / 4)
                - Int(0.75 * (Int(YearNum / 100) + 1));
 DateFactor := Factor;
end;

Function DatetoJulian(DateLine : Str8) : Integer;
Var
 Factor, MonthNum, DayNum, YearNum : Real;
 Ti : Integer;
begin
 if Length(DateLine) = 7
  then DateLine := '0'+DateLine;
 MonthNum := 0.0;
 For Ti := 1 to 2 Do
  MonthNum := (10 * MonthNum)
    + (ord(DateLine[Ti])-ord('0'));
 DayNum := 0.0;
 For Ti := 3 to 4 Do
  DayNum := (10 * DayNum)
    + (ord(DateLine[Ti])-ord('0'));
 YearNum := 0.0;
 For Ti := 5 to 8 Do
  YearNum := (10 * YearNum)
    + (ord(DateLine[Ti])-ord('0'));
 Factor := DateFactor(MonthNum, DayNum, YearNum);
 DatetoJulian :=
  Trunc((Factor - 679351.0) - 32767.0);
end;

Function JuliantoDate(DateInt : Integer): Str11;
Var
 holdstr  : String[2];
 anystr  : String[11];
 StrMonth : String[3];
 strDay   : String[2];
 stryear  : String[4];
 test,
 error,
 Year,
 Dummy,
 I       : Integer;
 Save,Temp    : Real;
 JuliantoanyString : Str11;
begin
 holdstr := '';
 JuliantoanyString := '00000000000';
 Temp  := Int(DateInt) + 32767 + 679351.0;
 Save  := Temp;
 Dummy := Trunc(Temp/365.5);
 While Save >= DateFactor(1.0,1.0,Dummy+0.0)
  Do Dummy := Succ(Dummy);
 Dummy := Pred(Dummy);
 Year  := Dummy;
 (* Determine number of Days into current year *)
 Temp  := 1.0 + Save - DateFactor(1.0,1.0,Year+0.0);
 (* Put the Year into the output String *)
 For I := 8 downto 5 Do
  begin
   JuliantoanyString[I]
    := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
 Dummy := 1 + Trunc(Temp/31.5);
 While Save >= DateFactor(Dummy+0.0,1.0,Year+0.0)
  Do Dummy := Succ(Dummy);
 Dummy := Pred(Dummy);
 Temp  := 1.0 + Save - DateFactor(Dummy+0.0,1.0,Year+0.0);
 For I := 2 Downto 1 Do
  begin
   JuliantoanyString[I]
    := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
 Dummy := Trunc(Temp);
 For I := 4 Downto 3 Do
  begin
   JuliantoanyString[I]
    := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
  holdstr := copy(juliantoanyString,1,2);
  val(holdstr,test,error);
  Case test of
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
  end;
  stryear := copy(juliantoanyString,5,4);
  strDay  := copy(juliantoanyString,3,2);
  anystr := StrDay + '-' + StrMonth + '-' +stryear;
 JuliantoDate := anystr;
end;

Function JuliantoStr8(DateInt : Integer): Str8;
Var
 holdstr  : String[2]; anystr   : String[8]; StrMonth : String[2];
 strDay   : String[2]; stryear  : String[4]; Save, Temp : Real;
 test, error, Year, Dummy, I : Integer; JuliantoanyString : Str8;
begin
 holdstr := ''; JuliantoanyString := '00000000';
 Temp  := Int(DateInt) + 32767 + 679351.0;
 Save  := Temp; Dummy := Trunc(Temp/365.5);
 While Save >= DateFactor(1.0,1.0,Dummy+0.0) Do Dummy := Succ(Dummy);
 Dummy := Pred(Dummy); Year  := Dummy;
 Temp  := 1.0 + Save - DateFactor(1.0,1.0,Year+0.0);
 For I := 8 downto 5 Do
  begin
   JuliantoanyString[I] := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
 Dummy := 1 + Trunc(Temp/31.5);
 While Save >= DateFactor(Dummy+0.0,1.0,Year+0.0) Do Dummy := Succ(Dummy);
 Dummy := Pred(Dummy);
 Temp  := 1.0 + Save - DateFactor(Dummy+0.0,1.0,Year+0.0);
 For I := 2 Downto 1 Do
  begin
   JuliantoanyString[I] := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
 Dummy := Trunc(Temp);
 For I := 4 Downto 3 Do
  begin
   JuliantoanyString[I] := Char((Dummy mod 10)+ord('0'));
   Dummy := Dummy div 10;
  end;
  holdstr := copy(juliantoanyString,1,2); val(holdstr,test,error);
  Case test of
  1 : StrMonth := '01'; 2 : StrMonth := '02'; 3 : StrMonth := '03';
  4 : StrMonth := '04'; 5 : StrMonth := '05'; 6 : StrMonth := '06';
  7 : StrMonth := '07'; 8 : StrMonth := '08'; 9 : StrMonth := '09';
 10 : StrMonth := '10'; 11 : StrMonth := '11'; 12 : StrMonth := '12';
  end;
  StrYear := copy(juliantoanyString,5,4);
  StrDay  := copy(juliantoanyString,3,2);
  AnyStr := StrMonth + StrDay + StrYear; JuliantoStr8 := AnyStr;
end;

Function DayofWeek(Jdate : Integer) : Str3;
begin
  Case jdate MOD 7 of
   0:DayofWeek:='Sun'; 1:DayofWeek:='Mon'; 2:DayofWeek := 'Tue';
   3:DayofWeek:='Wed'; 4:DayofWeek:='Thu'; 5:DayofWeek := 'Fri';
   6:DayofWeek:='Sat';
  end;
end;

Procedure DateDiff(Date1,Date2 : Integer;
           Var Date_Difference : Str9);
Var
 Temp,Rdate1,Rdate2,Diff1 : Real;      Diff : Integer;
 Return                   : String[9]; Hold : String[3];
begin
  Rdate2 := Date2 + 32767.5; Rdate1 := Date1 + 32767.5;
  Diff1  := Rdate1 - Rdate2; Temp   := Diff1;
  if Diff1 < 32 then (* determine number of Days *)
  begin
    Diff := Round(Diff1); Str(Diff,Hold);
    Return := Hold + ' ' + 'Day';
    if Diff > 1 then Return := Return + 's  ';
  end;
  if ((Diff1 > 31) and (Diff1 < 366)) then
  begin
    Diff1 := Diff1 / 30; Diff := Round(Diff1); Str(Diff,Hold);
    Return := Hold + ' ' + 'Month';
    if Diff > 1 then Return := Return + 's';
  end;
  if Diff1 > 365 then
  begin
    Diff1 := Diff1 / 365; Diff := Round(Diff1); Str(Diff,Hold);
    Return := Hold;
  end;
  Date_Difference := Return; Diff := Round(Diff1);
end;
end.
