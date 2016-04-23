UNIT CalUnit;
{ Object oriented calander unit }

INTERFACE

USES CRT,DOS;

TYPE
  Calendar = OBJECT
    ThisMonth, ThisYear : Word;
    CONSTRUCTOR Init(Month, Year: Integer);
    PROCEDURE        DrawCalendar;
    PROCEDURE        SetMonth(Month: Integer);
    PROCEDURE        SetYear(Year: Integer);
    FUNCTION        GetMonth: Integer;
    FUNCTION        GetYear: Integer;
    DESTRUCTOR        Done;
  END;

IMPLEMENTATION

CONSTRUCTOR Calendar.Init(Month, Year: Integer);
BEGIN
   SetYear(Year);
   SetMonth(Month);
   DrawCalendar;
END;

PROCEDURE Calendar.DrawCalendar;

VAR
  CurYear,CurMonth,CurDay,CurDow,
  ThisDay,ThisDOW    : Word;
  I,DayPos,NbrDays   : Byte;

CONST
  DOM: ARRAY[1..12] OF Byte =
       (31,28,31,30,31,30,31,31,30,31,30,31);
  MonthName: ARRAY[1..12] OF String[3] =
       ('Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec');

BEGIN

  GetDate(CurYear,CurMonth,CurDay,CurDow);

  {Set to day 1 so we can use GetDate function}
  ThisDay := 1;

  SetDate(ThisYear,ThisMonth,ThisDay);

  {ThisDOW stands for This day of the week}

  GetDate(ThisYear,ThisMonth,ThisDay,ThisDOW);

  SetDate(CurYear,CurMonth,CurDay);

  WriteLn('           ',MonthName[ThisMonth],
          ' ',ThisYear);
  WriteLn;
  WriteLn('   S   M   T   W   R   F   S');

  NbrDays := DOM[ThisMonth];

  {Check for leap year, which occurs when the
   year is evenly divisible by 4 and not evenly
   divisable by 100 or if the year is evenly
   divisable by 400}

  IF ((ThisMonth = 2) AND
     ((ThisYear MOD 4 = 0) AND
      (ThisYear MOD 100 <> 0))
     OR (ThisYear MOD 400 = 0))
   THEN NbrDays := 29;

  FOR I:= 1 TO NbrDays DO
    BEGIN
      DayPos := ThisDOW * 4 + 2;  {Position day #}
      GotoXY(DayPos,WhereY);
      Inc(ThisDOW);
      Write(I:3);
      IF ThisDOW > 6 THEN
        BEGIN
          ThisDOW := 0;
          WriteLn
        END
    END;
    WriteLn
END;

PROCEDURE Calendar.SetMonth(Month: Integer);
BEGIN
   ThisMonth := Month;
   WHILE ThisMonth < 1 DO
   BEGIN
      Dec(ThisYear);
      Inc(ThisMonth, 12);
   END;
   WHILE ThisMonth > 12 DO
   BEGIN
      Inc(ThisYear);
      Dec(ThisMonth, 12);
   END;
END;

PROCEDURE Calendar.SetYear(Year: Integer);
BEGIN
   ThisYear := Year;
END;

FUNCTION Calendar.GetMonth: Integer;
BEGIN
   GetMonth := ThisMonth;
END;

FUNCTION Calendar.GetYear: Integer;
BEGIN
   GetYear := ThisYear;
END;

DESTRUCTOR Calendar.Done;
BEGIN
   {for dynamic object instances,
     the Done method still works even
     though it contains nothing except
     the destructor declaration              }
END;

END.

{ ---------------------------    TEST PROGRAM ---------------------}
PROGRAM CalTest;

USES DOS,CRT,CalUnit;

VAR
   MyCalendar: Calendar;
   TYear,TMonth,Tday,TDOW: Word;

BEGIN
   ClrScr;
   GetDate(TYear,TMonth,Tday,TDOW);
   WITH MyCalendar DO
   BEGIN
      WriteLn('    Current Month''s Calendar');
      WriteLn;
      Init(TMonth, TYear);
      WHILE (TMonth <> 0) DO
        BEGIN
          WriteLn;
          WriteLn('   Enter a Month and Year');
          WriteLn('(Separate values by a space)');
          WriteLn;
          WriteLn('      exm.      3 1990');
          WriteLn;
          Write         ('   or 0 0 to quit: ');
          ReadLn(TMonth, TYear);
          IF TMonth <> 0 THEN
             BEGIN
               ClrScr;
               SetYear(TYear);
               SetMonth(TMonth);
               DrawCalendar
             END
        END
   END;
   ClrScr
END.

