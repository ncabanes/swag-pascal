{

Various Date and Time Procedures

Rev. 1.06

(c) Copyright 1994, Michael Gallias

Target: Real, Protected, Windows

}

{$V-} {$B-}

Unit Calendar;

Interface

{$IFDEF WINDOWS}

Uses WinDos, PasStr;

{$ELSE}

Uses Dos, PasStr;

{$ENDIF}

Const
  dts_DDMYYYY       =  1;
  dts_DDMMYYYY      =  2;
  dts_DDMMMYYYY     =  3;

Type
  TimeDate = Record
               Year,
               Month,
               Day,
               WeekDay,
               Hour,
               Min,
               Sec,
               ms         :Word;
             End;

  DayNameString   = String[9];
  DayNameArray    = Array [0..6] of DayNameString;
  MonthNameString = String[10];
  MonthNameArray  = Array [1..12] of MonthNameString;
  MonthAbrString  = String[3];
  MonthAbrArray   = Array [1..12] of MonthAbrString;

Const
  DayName     : DayNameArray =
                  ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
                   'Thursday', 'Friday', 'Saturday');

  MonthName   : MonthNameArray =
                  ('January', 'February', 'March', 'April', 'May',
                   'June', 'July', 'August', 'September',
                   'October', 'November', 'December');

  MonthAbr    : MonthNameArray =
                  ('Jan', 'Feb', 'Mar', 'Apr', 'May',
                   'Jun', 'Jul', 'Aug', 'Sep',
                   'Oct', 'Nov', 'Dec');

Procedure StringToDate      (Strg:String; Var Date:TimeDate;
                             Const Style:Byte; Var Code:Integer);
Procedure DateToString      (Date:TimeDate; Var Strg:String; Const Style:Byte);
Procedure StringToTime      (Strg:String; Var Time:TimeDate; Var Code:Integer);
Procedure TimeToString      (Time:TimeDate; Var Strg:String);
Procedure MMDDToDDMM        (DateIn:String; Var DateOut:String);
Procedure GetTimeDate       (Var Time:TimeDate);
Procedure PredMin           (Const TimeIn:TimeDate; Var TimeOut:TimeDate);
Procedure PredHour          (Const TimeIn:TimeDate; Var TimeOut:TimeDate);
Procedure UntotalDays       (Total:LongInt; Var Date:TimeDate);
Procedure DayOfWeek         (Var   Date:TimeDate);
Function  DayOfYear         (Const Date:TimeDate):Word;
Function  TotalMonths       (Const Date:TimeDate):LongInt;
Function  TotalDays         (Const Date:TimeDate):LongInt;
Function  TotalHalfHrs      (Const Time:TimeDate):Byte;
Function  TotalMinutes      (Const Time:TimeDate):Word;
Function  TotalSeconds      (Const Time:TimeDate):LongInt;
Function  Totalms           (Const Time:TimeDate):LongInt;
Function  ChangedTime       (Const Time1, Time2:TimeDate):Boolean;
Function  ChangedTimeDate   (Const Time1, Time2:TimeDate):Boolean;
Function  ChangedDate       (Const Date1, Date2:TimeDate):Boolean;
Function  DaysInMonth       (Month:Byte;Year:Word):Byte;
Function  DaysInYear        (Year:Word):Word;

Implementation

Procedure StringToDate(Strg:String;Var Date:TimeDate;
                       Const Style:Byte; Var Code:Integer);

Var
  SY,SM,SD,ST :String;
  AY,AM,AD,AT :LongInt;

Begin
  Code:=0;
  Case Style Of
    dts_DDMMYYYY:
      Begin
        Strg:=Strg+'/';
        SY:='';
        SM:='';
        SD:='';

        SD:=Copy(Strg,1,Pos('/',Strg)-1);
        Delete(Strg,1,Pos('/',Strg));

        If Pos('/',Strg)>0 Then
        Begin
          SM:=Copy(Strg,1,Pos('/',Strg)-1);
          Delete(Strg,1,Pos('/',Strg));
        End;

        If Pos('/',Strg)>0 Then
        Begin
          SY:=Copy(Strg,1,Pos('/',Strg)-1);
          Delete(Strg,1,Pos('/',Strg));
        End;

        If SY<>'' Then
        Begin
          If Length(SY)<3 Then SY:='19'+SY;
          Val(SY,AY,Code);
          If (AY<1991) Or (AY>1999) Then Code:=6;
        End
        Else
          Code:=6;

        If SM<>'' Then
        Begin
          Val(SM,AM,Code);
          If (AM<1) Or (AM>12) Then Code:=3;
        End
        Else
          Code:=3;

        If SD<>'' Then
        Begin
          Val(SD,AD,Code);
          If (AD<1) Or (AD>DaysInMonth(AM,AY)) Then Code:=1;
        End
        Else
          Code:=1;
      End;
    dts_DDMMMYYYY,
    dts_DDMYYYY:
      Begin
        Strg:=Strg+'   ';
        SD:=Copy(Strg,1,Pos(' ',Strg)-1);
        Delete(Strg,1,Pos(' ',Strg));
        SM:=Copy(Strg,1,Pos(' ',Strg)-1);
        Delete(Strg,1,Pos(' ',Strg));
        SY:=Copy(Strg,1,Pos(' ',Strg)-1);
        If (SD='') Or (SM='') Or (SY='') Then
          Code:=99
        Else
        Begin
          UpperCase(SM,SM);
          AT:=0;
          Repeat
            Inc(AT);
            UpperCase(MonthName[AT],ST);
          Until (AT=12) Or (ST=SM);
          If ST<>SM Then
          Begin
            AT:=0;
            Repeat
              Inc(AT);
              UpperCase(MonthAbr[AT],ST);
            Until (AT=12) Or (ST=SM);
          End;
          If ST=SM Then AM:=AT Else Code:=3;
          If Code=0 Then
          Begin
            If Length(SY)<3 Then SY:='19'+SY;
            Val(SY,AY,Code);
            If (AY<1991) Or (AY>1999) Then Code:=6;
          End;
          If Code=0 Then
          Begin
            Val(SD,AD,Code);
            If (AD<1) Or (AD>DaysInMonth(AM,AY)) Then Code:=1;
          End;
        End;
      End;
  End;
  If Code=0 Then
  Begin
    Date.Day   :=AD;
    Date.Month :=AM;
    Date.Year  :=AY;
  End;
End;

Procedure DateToString(Date:TimeDate;Var Strg:String;Const Style:Byte);

Var
  Temp:String[20];

Begin
  Case Style Of
    dts_DDMYYYY:
      Begin
        Str(Date.Day:2,Strg);
        SpacesToZeros(Strg,Strg);
        Temp:=MonthName[Date.Month];
        Strg:=Strg+' '+Temp+' ';
        Str(Date.Year:4,Temp);
        Strg:=Strg+Temp;
      End;
    dts_DDMMYYYY:
      Begin
        Str(Date.Day:2,Strg);
        Str(Date.Month:2,Temp);
        Strg:=Strg+'/'+Temp+'/';
        Str(Date.Year:4,Temp);
        Strg:=Strg+Temp;
        SpacesToZeros(Strg,Strg);
      End;
    dts_DDMMMYYYY:
      Begin
        Str(Date.Day:2,Strg);
        SpacesToZeros(Strg,Strg);
        Temp:=MonthAbr[Date.Month];
        Strg:=Strg+' '+Temp+' ';
        Str(Date.Year:4,Temp);
        Strg:=Strg+Temp;
      End;
  End;
End;

Procedure StringToTime(Strg:String;Var Time:TimeDate;Var Code:Integer);

Var
  SH,SM,SS:String[10];
  AH,AM,AS:LongInt;

Begin
  Strg:=Strg+':';
  SH:='';
  SM:='';
  SS:='';

  SH:=Copy(Strg,1,Pos(':',Strg)-1);
  Delete(Strg,1,Pos(':',Strg));

  If Pos(':',Strg)>0 Then
  Begin
    SM:=Copy(Strg,1,Pos(':',Strg)-1);
    Delete(Strg,1,Pos(':',Strg));
  End;

  If Pos(':',Strg)>0 Then
  Begin
    SS:=Copy(Strg,1,Pos(':',Strg)-1);
    Delete(Strg,1,Pos(':',Strg));
  End;

  If SH<>'' Then
  Begin
    Val(SH,AH,Code);
    If (Code>0) Or (AH<0) Or (AH>23) Then Exit;
  End
  Else
    AH:=Time.Hour;

  If SM<>'' Then
  Begin
    Val(SM,AM,Code);
    If (Code>0) Or (AM<0) Or (AM>59) Then Exit;
  End
  Else
    AM:=Time.Min;

  If SS<>'' Then
  Begin
    Val(SS,AS,Code);
    If (Code>0) Or (AS<0) Or (AS>59) Then Exit;
  End
  Else
    AS:=Time.Sec;

  Time.Hour  :=AH;
  Time.Min   :=AM;
  Time.Sec   :=AS;
End;

Procedure TimeToString(Time:TimeDate;Var Strg:String);

Var
  Temp:String[10];

Begin
  Str(Time.Hour:2,Strg);
  Str(Time.Min:2,Temp);
  Strg:=Strg+':'+Temp+':';
  Str(Time.Sec:2,Temp);
  Strg:=Strg+Temp;
  SpacesToZeros(Strg,Strg);
End;

Procedure MMDDToDDMM(DateIn:String;Var DateOut:String);

Var
  First    :String[12];
  P        :Byte;

Begin
  If DateIn='' Then
  Begin
    DateOut:='';
    Exit;
  End;

  DateOut:='';
  DateIn:=DateIn+' ';
  P:=Max(Pos(' ',DateIn),Pos('/',DateIn));
  First:=Copy(DateIn,1,P);
  Delete(DateIn,1,P);

  Repeat
    P:=Max(Pos(' ',DateIn),Pos('/',DateIn));
    DateOut:=DateOut+Copy(DateIn,1,P);
    Delete(DateIn,1,P);
  Until Length(DateIn)=0;
  P:=Max(Pos(' ',DateOut),Pos('/',DateOut));
  Insert(First,DateOut,P);
End;

Procedure GetTimeDate(Var Time:TimeDate);
Begin
  With Time do
  Begin
    GetTime(Hour,Min,Sec,ms);
    GetDate(Year,Month,Day,WeekDay);
  End;
End;

Procedure PredMin(Const TimeIn:TimeDate; Var TimeOut:TimeDate);
{Decreases the Time by one Minute, does not check the date if TimeOut.Day=0.}
Begin
  TimeOut:=TimeIn;
  With TimeOut do
  Begin
    If Min>0 Then
      Dec(Min)
    Else
    Begin
      Min:=59;
      If Hour>0 Then
        Dec(Hour)
      Else
      Begin
        Hour:=23;
        If Day>0 Then
        Begin
          If Day>1 Then
            Dec(Day)
          Else
          Begin
            If Month>1 Then
              Dec(Month)
            Else
            Begin
              Month:=12;
              If Year>0 Then Dec(Year);
            End;
            Day:=DaysInMonth(Month,Year);
          End;
        End;
      End;
    End;
  End;
End;

Procedure PredHour(Const TimeIn:TimeDate; Var TimeOut:TimeDate);
{Decreases the Time by one Hour, does not check the date if TimeOut.Day=0.}
Begin
  TimeOut:=TimeIn;
  With TimeOut do
  Begin
    If Hour>0 Then
      Dec(Hour)
    Else
    Begin
      Hour:=23;
      If Day>0 Then
      Begin
        If Day>1 Then
          Dec(Day)
        Else
        Begin
          If Month>1 Then
            Dec(Month)
          Else
          Begin
            Month:=12;
            If Year>0 Then Dec(Year);
          End;
          Day:=DaysInMonth(Month,Year);
        End;
      End;
    End;
  End;
End;

Procedure UntotalDays(Total:LongInt; Var Date:TimeDate);

Const
  t_1000    = 366123;   {Number of days from 0 to 1000, inclusive}
  t_1500    = 549002;
  t_1750    = 640441;
  t_1970    = 720908;

Var
  DIY, DIM      :Word;

Begin
  FillChar(Date,SizeOf(Date),0);

  If Total>t_1970 Then
  Begin
    Dec(Total,t_1970);
    Date.Year:=1971;
  End
  Else
  If Total>t_1750 Then
  Begin
    Dec(Total,t_1750);
    Date.Year:=1751;
  End
  Else
  If Total>t_1500 Then
  Begin
    Dec(Total,t_1500);
    Date.Year:=1501;
  End
  Else
  If Total>t_1000 Then
  Begin
    Dec(Total,t_1000);
    Date.Year:=1001;
  End;

  DIY:=DaysInYear(Date.Year);
  While (Total>DIY) do
  Begin
    Dec(Total,DaysInYear(Date.Year));
    Inc(Date.Year);
    DIY:=DaysInYear(Date.Year);
  End;

  Date.Month:=1;
  For DIY:=1 to 12 do
  Begin
    DIM:=DaysInMonth(DIY,Date.Year);
    If Total>DIM Then
    Begin
      Dec(Total,DIM);
      Inc(Date.Month);
    End;
  End;

  Date.Day:=Total;
End;

Procedure DayOfWeek(Var Date:TimeDate);
{Sets 'WeekDay' of Date: 1 for Monday, 0 for Sunday}
Var
  A,B,C    :Word;
  Y,M,D,DOW:Word;

Begin
  GetDate(Y,M,D,DOW);
  SetDate(Date.Year,Date.Month,Date.Day);
  GetDate(A,B,C,Date.WeekDay);
  SetDate(Y,M,D);
End;

Function DayOfYear(Const Date:TimeDate):Word;

Var
  Temp  :Word;
  X     :Byte;

Begin
  Temp:=Date.Day;
  For X:=1 to Date.Month-1 do
    Inc(Temp,DaysInMonth(X,Date.Year));
  DayOfYear:=Temp;
End;

Function TotalMonths(Const Date:TimeDate):LongInt;
Begin
  TotalMonths:=(12 * (Date.Year - 1)) + Date.Month;
End;

Function TotalDays(Const Date:TimeDate):LongInt;

{Returns the total number of days that have elapsed from the year 0, including
 the current day, e.g. 1 Jan 0 = 1}

Const
  t_1_1_1970    = 720543;

Var
  Total:LongInt;
  Year :Integer;
  Month:Byte;
  Start:Integer;

Begin
  If Date.Year>=1970 Then
  Begin
    Total:=t_1_1_1970-1;
    Start:=1970;
  End
  Else
  Begin
    Total:=0;
    Start:=0;
  End;

  For Year:=Start to Integer(Date.Year)-1 do
    Inc(Total,DaysInYear(Year));

  For Month:=1 to Date.Month-1 do
    Inc(Total,DaysInMonth(Month,Date.Year));
  TotalDays:=Total+Date.Day;
End;

Function TotalHalfHrs(Const Time:TimeDate):Byte;
Begin
  TotalHalfHrs:=Time.Hour * 2 + (Time.Min Div 30);
End;

Function TotalMinutes(Const Time:TimeDate):Word;
Begin
  TotalMinutes:=Time.Hour*60+Time.Min;
End;

Function TotalSeconds(Const Time:TimeDate):LongInt;
Begin
  TotalSeconds:=LongInt(Time.Hour)*60*60+LongInt(Time.Min)*60+LongInt(Time.Sec);
End;

Function Totalms(Const Time:TimeDate):LongInt;
Begin
  Totalms:=(LongInt(Time.Hour)*60*60+LongInt(Time.Min)*60+LongInt(Time.Sec))*100+LongInt(Time.ms);
End;

Function ChangedTime(Const Time1, Time2:TimeDate):Boolean;
Begin
  If (Time1.ms  =Time2.ms  ) And
     (Time1.Sec =Time2.Sec ) And
     (Time1.Min =Time2.Min ) And
     (Time1.Hour=Time2.Hour) Then
    ChangedTime:=False
  Else
    ChangedTime:=True;
End;

Function ChangedTimeDate(Const Time1, Time2:TimeDate):Boolean;
Begin
  If (Time1.ms   =Time2.ms   ) And
     (Time1.Sec  =Time2.Sec  ) And
     (Time1.Min  =Time2.Min  ) And
     (Time1.Hour =Time2.Hour ) And
     (Time1.Day  =Time2.Day  ) And
     (Time1.Month=Time2.Month) And
     (Time1.Year =Time2.Year ) Then
    ChangedTimeDate:=False
  Else
    ChangedTimeDate:=True;
End;

Function ChangedDate(Const Date1, Date2:TimeDate):Boolean;
Begin
  If (Date1.Day  =Date2.Day  ) And
     (Date1.Month=Date2.Month) And
     (Date1.Year =Date2.Year ) Then
    ChangedDate:=False
  Else
    ChangedDate:=True;
End;

Function DaysInMonth(Month:Byte;Year:Word):Byte;
Begin
  Case Month Of
     1:DaysInMonth:=31;
     2:Begin
         If (Year Mod 100)=0 Then      {Centuary}
           If (Year Mod 400)=0 Then
             DaysInMonth:=29
           Else
             DaysInMonth:=28
         Else                          {Non Centuary}
           If (Year Mod 4)=0 Then
             DaysInMonth:=29
           Else
             DaysInMonth:=28;
       End;
     3:DaysInMonth:=31;
     4:DaysInMonth:=30;
     5:DaysInMonth:=31;
     6:DaysInMonth:=30;
     7:DaysInMonth:=31;
     8:DaysInMonth:=31;
     9:DaysInMonth:=30;
    10:DaysInMonth:=31;
    11:DaysInMonth:=30;
    12:DaysInMonth:=31;
  End;
End;

Function DaysInYear(Year:Word):Word;
Begin
  If DaysInMonth(2,Year)=29 Then DaysInYear:=366 Else DaysInYear:=365;
End;

End.
