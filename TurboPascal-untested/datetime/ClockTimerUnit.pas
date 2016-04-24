(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0034.PAS
  Description: Clock & Timer Unit
  Author: EARL F. GLYNN
  Date: 02-03-94  09:24
*)

UNIT Clocks;

 {This UNIT provides a CLOCK OBJECT for use in Turbo Pascal 5.5.

  (C) Copyright 1989, Earl F. Glynn, Overland Park, KS.  Compuserve 73257,3527.
  All Rights Reserved.  This Turbo Pascal 5.5 UNIT may be freely distributed
  for non-commerical use.

  Clock objects can be used as individual timers, using either the CMOS
  real-time clock, or the DOS real-time clock.  As shown in the ClkDemo
  PROGRAM, the DOS clock can be shut off when interrupts are disabled.
  The resolution of the CMOS clock is only 1 second, while the DOS clock
  has 0.0549 second resolution (18.203 ticks per second).  In addition
  to real-time clocks, static time stamps can be manipulated and
  formatted.  The range for all clocks and time stamps is Jan 1, 1900
  through Jun 5, 2079.  (Sep 18, 1989 is the midpoint of this range).

  Several REXX-like FUNCTIONs provide Date/Time formatting.  [REXX,
  the Restructured Extended Executor, or sometimes called the System Product
  Interpreter, is IBM's SAA command language (now primarily for VM/CMS).
  That is, REXX EXECs are CMS's equivalent of PC .BAT files but REXX
  provides much more functionality than the PC 'BAT' language.]

  REXX-like FUNCTIONS in Pascal could be considered an oxymoron since
  REXX doesn't have any concept of TYPEd variables and obviously Pascal does.
  The Pascal functions in most cases were written to return STRINGs,
  which is similar to REXX.  In some cases, where a number was returned
  that could be used in calculations, a separate function was used.  For
  example, the REXX TIME('Elapsed') function was implemented as an object
  'Elapsed' method that returns a REAL value to be used in calculations.
  A function 'hhmmss' can be used to format elapsed seconds in a
  character string, if desired.

  See the CLKDEMO.PAS, FLOPS.PAS and TIMER.PAS programs for sample usage
  of clock objects and this UNIT.}

INTERFACE

  TYPE
    ClockValue    =
      RECORD
        year      :  1900..2079;
        month     :  1..12;
        day       :  1..31;
        hour      :  0..23;
        minute    :  0..59;
        second    :  0..59;
        hundredth :  0..99;
      END;
    ClockType     =  (CMOSClock,DOSClock);
    Clock         =
      OBJECT
        mode      :  ClockType;
        StartValue:  ClockValue;
        FUNCTION  Date(s:  STRING):  STRING;
        FUNCTION  Elapsed:  REAL;   {elapsed timer (seconds)}
        PROCEDURE Start (ct:  ClockType);
        FUNCTION  Time(s:  STRING):  STRING;
      END;

  FUNCTION  DateFormat(s:  STRING; clk:  ClockValue):  STRING;
  FUNCTION  DaysThisCentury(y, m, d:  WORD):  WORD;
  FUNCTION  hhmmss(seconds:  REAL):  STRING;
  FUNCTION  JulianDate(y{1900..}, m{1..12}, d{1..31}:  WORD):  WORD;
  PROCEDURE SetClock (yr,mo,d,h,m,s,hth:  WORD; VAR t:  ClockValue);
  FUNCTION  TimeDiff(t2,t1:  ClockValue):  REAL;  {t2 - t1 seconds}
  FUNCTION  TimeFormat(s:  STRING; clk:  ClockValue):  STRING;
  PROCEDURE UnPackTime (TurboTime:  LongInt; VAR Clk:  ClockValue);

IMPLEMENTATION

  USES
    DOS; {INTR}

  VAR
    c  :  CHAR;

  FUNCTION L2C(L:  LONGINT):  STRING;  {LONGINT-to-character}
    {L2C and W2C are intended to be similar to the standard D2C
     (decimal-to-character) REXX function.}
    VAR t:  STRING[11];
  BEGIN
    STR (L,t);
    L2C := t
  END {L2C};

  FUNCTION W2C(w:  WORD):  STRING;     {word-to-character}
    VAR t:  STRING[5];
  BEGIN
    STR (w,t);
    W2C := t
  END {W2C};

  FUNCTION TwoDigits (w:  WORD):  STRING;
    CONST Digit:  ARRAY[0..9] OF CHAR = '0123456789';
  BEGIN
    w := w MOD 100;  {just to be safe}
    TwoDigits := Digit[w DIV 10] + Digit[w MOD 10]
  END {TwoDigits};

  FUNCTION DateFormat(s:  STRING; clk:  ClockValue):  STRING;
    CONST
      days  :  ARRAY[0..6] OF STRING[9]
                         =('Sunday','Monday','Tuesday','Wednesday',
                           'Thursday','Friday','Saturday');
      months:  ARRAY[1..12] OF STRING[9]
                         =('January','February','March',
                           'April',  'May',     'June',
                           'July',   'August',  'September',
                           'October','November','December');
  BEGIN
    IF   LENGTH(s) = 0
    THEN c := 'N' {NORMAL}
    ELSE c := UpCase(s[1]);
    CASE c OF
            {Normal (default):  dd Mmm yyyy -- no leading zero or blank}
      'N':  DateFormat := W2C(clk.day) + ' ' + COPY(months[clk.month],1,3)
                                       + ' ' + W2C(clk.year);

            {Century:  ddddd -- no leading zeros or blanks}
      'C':  DateFormat := W2C( DaysThisCentury(clk.year,clk.month,clk.day) );

            {Julian date:  ddd -- no leading 0s or blanks}
      'D':  DateFormat := W2C(JulianDate(clk.year,clk.month,clk.day));

            {European:  dd/mm/yy}
      'E':  DateFormat := TwoDigits(clk.day  )  + '/' +
              TwoDigits(clk.month)  + '/' + TwoDigits(clk.year MOD 100);

            {Month:  current month name in mixed case}
      'M':  DateFormat := months[clk.month];

            {Ordered:  yy/mm/dd suitable for sorting}
      'O':  DateFormat := TwoDigits(clk.year MOD 100)  + '/' +
              TwoDigits(clk.month)  + '/' + TwoDigits(clk.day);

            {Standard:  yyyymmdd -- suitable for sorting (ISO/R 2014-1971)}
      'S':  DateFormat := W2C(clk.year) + TwoDigits(clk.month) +
              TwoDigits(clk.day);

            {USA:  mm/dd/yy}
      'U':  DateFormat := TwoDigits(clk.month)  + '/' +
              TwoDigits(clk.day  )  + '/' + TwoDigits(clk.year MOD 100);

            {Weekday:  returns day of the week in mixed case}
      'W':  DateFormat :=  {January 1, 1900 was a Monday}
              days[DaysThisCentury(clk.year,clk.month,clk.day) MOD 7 ]

      ELSE DateFormat := ''
    END
  END {DateFormat};

  FUNCTION DaysThisCentury(y, m, d:  WORD):  WORD;

  {This function was written to be equivalent to the REXX language
   DATE('Century') function.  See DateFormat FUNCTION in this UNIT.

   Jan 1, 1900 = 1, Jan 2, 1900 = 2, ..., Jun 5, 2079 = 65535 (largest word).
   Jan 1, 1989 = 32508, Jan 1, 1990 = 32873, Sep 18, 1989 = 32768.

   "The Astronomical Almanac" defines the astronomical julian date
   to be the numbers of mean solar days since 4713 BC.  In this system
   Jan 1, 1900 = 2415020.5, Jan 1, 2000 = 2451544.5,
   Jan 1, 1989 = 2447527.5, Jan 1, 1990 = 2447892.5,
   Jun 5, 2079 = 2480554.5.  This data was used to validate the function.

   (Note:  DaysThisCentry(y,m,d) MOD 7  returns day-of-week index, i.e.,
   0=Sunday, 1=Monday, etc. since January 1, 1900 was a Monday.)}
  BEGIN
    DaysThisCentury := 365*(y-1900) + INTEGER(y-1901) DIV 4 + JulianDate(y,m,d)
  END {DaysThisCentury};

  FUNCTION  hhmmss(seconds:  REAL):  STRING;
    {Convert elapsed times/time differences to [hh:]mm:ss format}
    VAR
      h,h1,h2:  LONGINT;
      s      :  STRING;
      t      :  LONGINT;
  BEGIN
    IF   seconds < 0.0
    THEN BEGIN
      seconds := ABS(seconds);
      s := '-'
    END
    ELSE s:= '';
    h1 := 0;
    WHILE seconds > 2147483647.0 DO BEGIN  {fixup real-to-LONGINT problem}
      seconds := seconds - 1576800000.0;   {subtract about 50 years}
      h1 := h1 + 438000 {hours}            {add about 50 years}
    END;
    t := TRUNC(seconds);
    h2 := t DIV 3600;  {hours}
    h := h1 + h2;
    IF   h > 0
    THEN s := s + L2C(h) + ':';
    t := t - h2*3600;  {minutes and seconds left}
    hhmmss := s + TwoDigits(t DIV 60) + ':' + TwoDigits(t MOD 60)
  END {hhmmss};

  FUNCTION JulianDate(y{1900..}, m{1..12}, d{1..31}:  WORD):  WORD;
    CONST
      julian:  ARRAY[0..12] OF WORD =
               (0,31,59,90,120,151,181,212,243,273,304,334,365);
    VAR
      jd:  WORD;
  BEGIN
    jd := julian[m-1] + d;
    IF   (m > 2) AND (y MOD 4 = 0) AND
         (y <> 1900) {AND (y <> 2100)}
    THEN INC (jd);   {1900 and 2100 are not leap years; 2000 is}
    JulianDate := jd
  END {JulianDate};

  PROCEDURE SetClock (yr,mo,d,h,m,s,hth:  WORD; VAR t:  ClockValue);
  BEGIN
    t.year      := yr;
    t.month     := mo;
    t.day       := d;
    t.hour      := h;
    t.minute    := m;
    t.second    := s;
    t.hundredth := hth
  END {SetClock};

  FUNCTION  TimeDiff(t2,t1:  ClockValue):  REAL;
  BEGIN  {REAL arithmetic is used to avoid INTEGER/LONGINT overflows}
    TimeDiff :=   0.01*INTEGER(t2.hundredth - t1.hundredth) +
                       INTEGER(t2.second - t1.second      ) +
                  60.0*INTEGER(t2.minute - t1.minute      ) +
                3600.0*INTEGER(t2.hour   - t1.hour        ) +
               86400.0*LONGINT(DaysThisCentury(t2.year,t2.month,t2.day) -
                       LONGINT(DaysThisCentury(t1.year,t1.month,t1.day)))
  END {TimeDiff};

  FUNCTION  TimeFormat(s:  STRING; clk:  ClockValue):  STRING;
    VAR
      meridian:  STRING[2];
  BEGIN
    IF   LENGTH(s) = 0
    THEN c := 'N' {NORMAL}
    ELSE c := UpCase(s[1]);
    CASE c OF

            {Normal (default):  hh:mm:ss}
      'N':  TimeFormat := TwoDigits(clk.hour  )  + ':' +
              TwoDigits(clk.minute)  + ':' + TwoDigits(clk.second);

            {Civil:  hh:mxx, for example:  11:59pm}
      'C':  BEGIN
              IF   clk.hour < 12
              THEN BEGIN
                meridian := 'am';  {anti meridiem}
                IF   clk.hour = 0
                THEN clk.hour := 12;  {12:00am is midnight}
              END                     {12:00pm is noon}
              ELSE BEGIN
                meridian := 'pm';  {post meridiem}
                IF   clk.hour > 12
                THEN clk.hour := clk.hour - 12
              END;
              TimeFormat := W2C(clk.hour)  + ':' +
                TwoDigits(clk.minute)  + meridian
            END;

            {Hours:  hh -- number of hours since midnight}
      'H':  TimeFormat := W2C(clk.hour);

            {Long:  hh.mm:ss.xx (real REXX requires microseconds here)}
      'L':  TimeFormat := TwoDigits(clk.hour  )  + ':' +
              TwoDigits(clk.minute)  + ':' + TwoDigits(clk.second)  + '.' +
              TwoDigits(clk.hundredth);

            {Minutes:  mmmm -- number of minutes since midnight}
      'M':  TimeFormat := W2C(60*clk.hour + clk.minute);

            {Seconds:  sssss -- number of seconds since midnight}
      'S':  TimeFormat := L2C( 3600*LONGINT(clk.hour)
               + 60*LONGINT(clk.minute) + LONGINT(clk.second) )

      ELSE TimeFormat := ''
    END
  END {TimeFormat};

  PROCEDURE UnPackTime (TurboTime:  LongInt; VAR Clk:  ClockValue);
    {The DOS.DateTime TYPE does not have hundredths of a second in its
     definition.  Clocks.UnPackTime allows the use of Clocks.DateFormat
     and Clocks.TimeFormat with time stamps, especially with SearchRec
     TYPEed variables defined by FindFirst/FindNext.}
    VAR
      DT:  DateTime;
  BEGIN
    DOS.UnPackTime (TurboTime, DT);
    SetClock (DT.year,DT.month,DT.day,DT.hour,DT.min,DT.sec,0, Clk)
  END {UnPackTime};

  PROCEDURE GetDateTime (VAR c:  ClockValue; ct:  ClockType);
    VAR r1,r2:  Registers;

    FUNCTION BCD (k:  BYTE):  WORD;    {convert binary-coded decimal}
    BEGIN
      BCD := 10*(k DIV 16) + (k MOD 16)
    END {BCD};

  BEGIN
    CASE ct OF
      CMOSClock:
        BEGIN
          r1.AH := $04;
          INTR ($1A,r1);      {BIOS call:  read date from real-time clock}
          r2.AH := $02;
          Intr ($1A,r2);      {BIOS call:  read real-time clock}
          SetClock (100*BCD(r1.CH) + BCD(r1.CL) {yr},
                    BCD(r1.DH) {mo}, BCD(r1.DL) {day},
                    BCD(r2.CH) {h},  BCD(r2.CL) {m}, BCD(r2.DH) {s},
                    0 {.00}, c)
        END;
      DOSClock:
        BEGIN
          r1.AH := $2A;       {could use GetDate and GetTime from DOS UNIT}
          INTR ($21,r1);      {DOS call:  get system date}
          r2.AH := $2C;
          Intr ($21,r2);      {DOS call:  get system time}
          SetClock (r1.CX,r1.DH,r1.DL, r2.CH,r2.CL,r2.DH,r2.DL, c)
        END
    END
  END {GetDateTime};

  FUNCTION Clock.Date(s:  STRING):  STRING;
  BEGIN
    Date := DateFormat(s,StartValue)
  END {Date};

  FUNCTION  Clock.Elapsed:  REAL;
    VAR now:  ClockValue;
  BEGIN
    GetDateTime (now,mode);
    Elapsed := TimeDiff(now,StartValue)
  END {Clock.Elapsed};

  PROCEDURE Clock.Start (ct:  ClockType);
  BEGIN
    mode := ct;
    GetDateTime (StartValue, ct)
  END {Clock.Start};

  FUNCTION Clock.Time(s:  STRING):  STRING;
  BEGIN
    Time := TimeFormat(s,StartValue)
  END {Time};

END {Clocks}.

{---------------------------  DEMO --------------------------}

PROGRAM ClkDemo;

 {This PROGRAM demonstates how to use the CLOCKS UNIT, including a
  clock object, its methods, and related FUNCTIONs and PROCEDUREs.
  Differences between CMOS and DOS clocks are shown.

  (C) Copyright 1989, Earl F. Glynn, Overland Park, KS.  Compuserve 73257,3527.
  All Rights Reserved.  This Turbo Pascal 5.5 PROGRAM may be freely distributed
  for non-commerical use.

  Several of the examples were derived from "The REXX Language" by
  M.F. Cowlishaw, Prentice Hall, 1985.}

  USES
    CRT,
    Clocks,
    DOS;    {FindFirst,FindNext,SearchRec,AnyFile,DOSError}

  VAR
    Clk1,Clk2,Clk3:  Clock;       {clock objects -- real time clocks}
    stamp1,stamp2 :  ClockValue;  {static clocks -- time stamps}
    stamp3,stamp4 :  ClockValue;
    stamp5        :  ClockValue;
    DirInfo       :  SearchRec;

  PROCEDURE ShowClocks;
  BEGIN
    Clk2.Start (CMOSClock);
    Clk3.Start (DOSClock);
    WRITELN ('  CMOS Clock:  ',Clk2.date('u'),' ',Clk2.time('N') );
    WRITELN ('   DOS Clock:  ',Clk3.date('u'),' ',Clk3.time('L') );
    WRITELN ('  Difference:  ',TimeDiff(Clk2.StartValue,Clk3.StartValue):8:2,
             ' second(s)');
  END {ShowClocks};

  PROCEDURE DisableInterrupts;
    INLINE ($FA);

  PROCEDURE EnableInterrupts;
    INLINE ($FB);

  PROCEDURE KillTime;
    {The following could be used for a 5-second delay, but it re-enables
     interrupts when they are disabled:

        WHILE clk1.elapsed < 5.0 DO (* nothing *);

     So,time will be wasted with a few calculations.}

    VAR
      i:  WORD;
      x:  REAL;
  BEGIN
    WRITELN ('''Kill'' some time ...');
    FOR i := 1 TO 10000 DO
      x := SQRT(i)
  END;

BEGIN
  Clk1.Start (CMOSClock);
  WRITELN ('CMOS/DOS Clock Differences');
  WRITELN ('--------------------------');
  WRITELN ('Start Clocks');
  ShowClocks;
  KillTime;
  ShowClocks;
  WRITELN ('Disable Interrupts (DOS clock will stop):');
  DisableInterrupts;
  KillTime;
  ShowClocks;
  WRITELN ('Enable Interrupts');
  EnableInterrupts;

  SetClock (1985,8,27, 16,54,22, 12, stamp1);  {These are not real-time clocks.}
  SetClock (1900,1, 1,  0, 0, 0,  0, stamp2);
  SetClock (2079,6, 5, 23,59,59, 99, stamp3);

  WRITELN ('Cowlishaw''s':52);
  WRITELN ('now':39,'REXX Book':13,'First':13,'Last':13);
  WRITELN ('Date/DateFormat Examples');
  WRITELN ('------------------------');
  WRITELN ('day this century - C':26,Clk2.Date('Century'):13,
    DateFormat('C',stamp1):13, DateFormat('C',stamp2):13,
    DateFormat('C',stamp3):13);
  WRITELN ('day this year - D':26,   Clk2.Date('Days'):13,
    DateFormat('D',stamp1):13, DateFormat('D',stamp2):13,
    DateFormat('D',stamp3):13);
  WRITELN ('dd/mm/yy - E':26,        Clk2.Date('European'):13,
    DateFormat('E',stamp1):13, DateFormat('E',stamp2):13,
    DateFormat('E',stamp3):13);
  WRITELN ('month name - M':26,      Clk2.Date('MONTH'):13,
    DateFormat('M',stamp1):13, DateFormat('M',stamp2):13,
    DateFormat('M',stamp3):13);
  WRITELN ('dd Mmm yyyy - N':26,     Clk2.Date('normal'):13,
    DateFormat('N',stamp1):13, DateFormat('N',stamp2):13,
    DateFormat('N',stamp3):13);
  WRITELN ('yy/mm/dd - O':26,        Clk2.Date('Ordered'):13,
     DateFormat('O',stamp1):13,DateFormat('O',stamp2):13,
     DateFormat('O',stamp3):13);
  WRITELN ('yyyymmdd - S':26,        Clk2.Date('standard'):13,
    DateFormat('S',stamp1):13, DateFormat('S',stamp2):13,
    DateFormat('S',stamp3):13);
  WRITELN ('mm/dd/yy - U':26,        Clk2.Date('USA'):13,
    DateFormat('U',stamp1):13, DateFormat('U',stamp2):13,
    DateFormat('U',stamp3):13);
  WRITELN ('day of week - W':26,     Clk2.Date('weekday'):13,
    DateFormat('W',stamp1):13, DateFormat('W',stamp2):13,
    DateFormat('W',stamp3):13);

  WRITELN;
  WRITELN ('Time/TimeFormat Examples');
  WRITELN ('------------------------');
  WRITELN ('hh:mmxm - C':26,             Clk2.Time('Civil'):13,
    TimeFormat('C',stamp1):13, TimeFormat('C',stamp2):13,
    TimeFormat('C',stamp3):13);
  WRITELN ('hours since midnight - H':26,Clk2.Time('Hours'):13,
    TimeFormat('h',stamp1):13, TimeFormat('h',stamp2):13,
    TimeFormat('h',stamp3):13);
  WRITELN ('hh:mm:ss.xx - L':26,         Clk2.Time('long'):13,
    TimeFormat('L',stamp1):13, TimeFormat('L',stamp2):13,
    TimeFormat('L',stamp3):13);
  WRITELN ('minutes since midnight - M', Clk2.Time('minutes'):13,
    TimeFormat('m',stamp1):13, TimeFormat('m',stamp2):13,
    TimeFormat('m',stamp3):13);
  WRITELN ('hh:mm:ss - N':26,            Clk2.Time('normal'):13,
    TimeFormat('n',stamp1):13, TimeFormat('n',stamp2):13,
    TimeFormat('n',stamp3):13);
  WRITELN ('seconds since midnight - S', Clk2.Time('seconds'):13,
    TimeFormat('s',stamp1):13, TimeFormat('s',stamp2):13,
    TimeFormat('s',stamp3):13);

  WRITELN;
  WRITELN ('Time Differences/Elapsed Time');
  WRITELN ('-----------------------------');
  WRITELN (' ':20,'seconds':12,'hh:mm:ss':16);
  WRITELN ('CMOS - DOS Clock:':20,
    TimeDiff(Clk2.StartValue,Clk3.StartValue):12:2,
    hhmmss(TimeDiff(Clk2.StartValue,Clk3.StartValue)):16);
  SetClock (1989,1, 1,  0, 0, 0,  0, stamp4);
  SetClock (1990,1, 1,  0, 0, 0,  0, stamp5);
  WRITELN ('Jan 1-Dec 31 1989:':20,TimeDiff(stamp5,stamp4):12:0,
    hhmmss(TimeDiff(stamp5,stamp4)):16);
  WRITELN ('Dec 31-Jan 1 1989:':20,TimeDiff(stamp4,stamp5):12:0,
    hhmmss(TimeDiff(stamp4,stamp5)):16);
  SetClock (1992,1, 1,  0, 0, 0,  0, stamp4);
  SetClock (1993,1, 1,  0, 0, 0,  0, stamp5);
  WRITELN ('1992 (leap year):':20,TimeDiff(stamp5,stamp4):12:0,
    hhmmss(TimeDiff(stamp5,stamp4)):16);
  SetClock (2000,1, 1,  0, 0, 0,  0, stamp5);
  WRITELN ('20th century:':20,TimeDiff(stamp5,stamp2):12:0,
    hhmmss(TimeDiff(stamp5,stamp2)):16,' (100*365 days + 24 leap days)');
  WRITELN ('Maximum Clock Range:':20,TimeDiff(stamp3,stamp2):12:0,
    hhmmss(TimeDiff(stamp3,stamp2)):16,' (January 1, 1900 midnight -');
  WRITELN ('June 5, 2079 23:59:59.99)':78);
  WRITELN ('Elapsed time:':20,Clk1.Elapsed:12:0,
    hhmmss(Clk1.Elapsed):16);

  Readkey;
  WRITELN;
  WRITELN ('Clocks.UnPackTime');
  WRITELN ('-----------------');
  FindFirst ('*.*',AnyFile,DirInfo);
  WHILE DOSError = 0 DO BEGIN  {Note:  seconds on files are even numbers}
    Clocks.UnPackTime (DirInfo.Time, stamp5);
    WRITELN (DirInfo.Name:12,'  ',DirInfo.size:7,'  ',
      COPY(DateFormat('Weekday',stamp5),1,3),' ',
      DateFormat('USA',stamp5),' ',TimeFormat('Normal',stamp5));
    FindNext (DirInfo)
  END;
  Readkey;
END {ClkDemo}.

