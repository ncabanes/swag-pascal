{$F+,O+,N+}
UNIT Dates;

  { Version 1R0 - 1991 03 25                                               }
  {         1R1 - 1991 04 09 - corrected several bugs, and                 }
  {                          - deleted <JulianDa2>, <Da2OfWeek> and        }
  {                            <JulianDa2ToDate> - all found to be not     }
  {                            completely reliable.                        }

INTERFACE

  { These routines all assume that the year (y, y1) value is supplied in a }
  { form that includes the century (i.e., in YYYY form).  No checking is   }
  { performed to ensure that a month (m, m1) value is in the range 1..12   }
  { or that a day (d, d1) value is in the range 1..28,29,30,31.  The       }
  { FUNCTION ValidDate may be used to check for valid month and day        }
  { parameters. FUNCTION DayOfYearToDate returns month and day (m, d) both }
  { = 0 if the day-of-the-year (nd) is > 366 for a leap-year or > 365 for  }
  { other years.                                                           }

  { NOTE: As written, FUNCTION Secs100 requires the presence of a 80x87    }
  { co-processor.  Its declaration and implementation may be altered to    }
  { REAL to make use of the floating-point emulation.                      }

  { Because the Gregorian calendar was not implemented in all countries at }
  { the same time, these routines are not guaranteed to be valid for all   }
  { dates. The real utility of these routines is that they will not fail   }
  { on December 31, 1999 - as will many algorithms used in MIS programs    }
  { implemented on mainframes.                                             }   

  { The routines are NOT highly optimized - I have tried to maintain the   }
  { style of the algorithms presented in the sources I indicate. Any       }
  { suggestions for algorithmic or code improvements will be gratefully    }
  { accepted.  This implementation is in the public domain - no copyright  }
  { is claimed.  No warranty either express or implied is given as to the  }
  { correctness of the algorithms or their implementation.                 }

  { Author: Charles B. Chapman, London, Ontario, Canada [74370,516]        }
  { Thanks to Leonard Erickson who supplied a test suite of values.        }

  FUNCTION IsLeap (y : WORD) : BOOLEAN;

  FUNCTION ValidDate (y, m, d : WORD) : BOOLEAN;
  FUNCTION ValidDate_Str (Str         : string;                     {DWH}
                          VAR Y, M, D : word;
                          VAR Err_Str : string) : boolean;
  FUNCTION ValidTime_Str (Str         : string;                     {DWH}
                          VAR H, M, S : word;
                          VAR Err_Str : string) : boolean;

  FUNCTION DayOfYear (y, m, d : WORD) : WORD;
  FUNCTION JulianDay (y, m, d : WORD) : LONGINT;
  FUNCTION JJ_JulianDay (y, m, d : word) : LONGINT;                 {DWH}

  FUNCTION DayOfWeek (y, m, d : WORD) : WORD;
  FUNCTION DayOfWeek_Str (y, m, d : WORD) : String;                 {DWH}

  FUNCTION TimeStr   (h, m, s, c : WORD) : STRING;
  FUNCTION TimeStr2  (h, m, s : WORD) : STRING;
  FUNCTION SIDateStr (y, m, d : WORD; SLen : BYTE; FillCh : CHAR) : STRING;
  FUNCTION MDYR_Str  (y, m, d : WORD): STRING;                      {DWH}

  FUNCTION Secs100 (h, m, s, c : WORD) : DOUBLE;
  PROCEDURE DayOfYearToDate (nd, y : WORD; VAR m, d : WORD);

  PROCEDURE JulianDayToDate (nd : LONGINT; VAR y, m, d : WORD);
  PROCEDURE JJ_JulianDayToDate (nd : LONGINT; VAR y, m, d : WORD);  {DWH}

  PROCEDURE DateOfEaster (Yr : WORD; VAR Mo, Da : WORD);
  PROCEDURE AddDays (y, m, d : WORD; plus : LONGINT; VAR y1, m1, d1 : WORD);

  FUNCTION Lotus_Date_Str (nd : LONGINT) : string;                  {DWH}
  FUNCTION Str_Date_to_Lotus_Date_Format
                     (Date       : String;
                      VAR Err_Msg : String): LongInt;  {OLC}
{==========================================================================}

IMPLEMENTATION
  USES
    Dos;

{==========================================================================}

  FUNCTION IsLeap (y : WORD) : BOOLEAN;

  { Returns TRUE if <y> is a leap-year                                     }

  BEGIN
    IF y MOD 4 <> 0 THEN
      IsLeap := FALSE
    ELSE
      IF y MOD 100 = 0 THEN
        IF y MOD 400 = 0 THEN
          IsLeap := TRUE
        ELSE
          IsLeap := FALSE
      ELSE
        IsLeap := TRUE
  END;  { IsLeap }

{==========================================================================}

  FUNCTION DayOfYear (y, m, d : WORD) : WORD;

  { function IDAY from remark on CACM Algorithm 398                        }
  { Computes day of the year for a given calendar date                     }
  { GIVEN:   y - year                                                      }
  {          m - month                                                     }
  {          d - day                                                       }
  { RETURNS: day-of-the-year (1..366, given valid input)                   }

  VAR
    yy, mm, dd, Tmp1 : LONGINT;
  BEGIN
    yy := y;
    mm := m;
    dd := d;
    Tmp1 := (mm + 10) DIV 13;
    DayOfYear :=  3055 * (mm + 2) DIV 100 - Tmp1 * 2 - 91 +
                  (1 - (yy - yy DIV 4 * 4 + 3) DIV 4 +
                  (yy - yy DIV 100 * 100 + 99) DIV 100 -
                  (yy - yy DIV 400 * 400 + 399) DIV 400) * Tmp1 + dd
  END;  { DayOfYear }

{==========================================================================}

  FUNCTION JulianDay (y, m, d : WORD) : LONGINT;

  { procedure JDAY from CACM Alorithm 199                                  }
  { Computes Julian day number for any Gregorian Calendar date             }
  { GIVEN:   y - year                                                      }
  {          m - month                                                     }
  {          d - day                                                       }
  { RETURNS: Julian day number (astronomically, for the day                }
  {          beginning at noon) on the given date.                         }

  VAR
    Tmp1, Tmp2, Tmp3, Tmp4, Tmp5 : LONGINT;
  BEGIN
    IF m > 2 THEN
      BEGIN
        Tmp1 := m - 3;
        Tmp2 := y
      END
    ELSE
      BEGIN
        Tmp1 := m + 9;
        Tmp2 := y - 1
      END;
    Tmp3 := Tmp2 DIV 100;
    Tmp4 := Tmp2 MOD 100;
    Tmp5 := d;
    JulianDay := (146097 * Tmp3) DIV 4 + (1461 * Tmp4) DIV 4 +
                 (153 * Tmp1 + 2) DIV 5 + Tmp5 + 1721119
  END;  { JulianDay }

{==========================================================================}
  
  PROCEDURE DayOfYearToDate (nd, y : WORD; VAR m, d : WORD);
                                                         
  { procedure CALENDAR from CACM Algorithm 398                             }
  { Computes month and day from given year and day of the year             }
  { GIVEN:   nd - day-of-the-year (1..366)                                 }
  {          y - year                                                      }
  { RETURNS: m - month                                                     }
  {          d - day                                                       }

  VAR
    Tmp1, Tmp2, Tmp3, Tmp4, DaYr : LONGINT; 
  BEGIN
    DaYr := nd;
    IF (DaYr = 366) AND (DayOfYear (y, 12, 31) <> 366) THEN
      DaYr := 999;
    IF DaYr <= 366 THEN
      BEGIN
        IF y MOD 4 = 0 THEN
          Tmp1 := 1
        ELSE
          Tmp1 := 0;
        IF (y MOD 400 = 0) OR (y MOD 100 <> 0) THEN
          Tmp2 := Tmp1
        ELSE
          Tmp2 := 0;
        Tmp1 := 0;
        IF DaYr > Tmp2 + 59 THEN
          Tmp1 := 2 - Tmp2;
        Tmp3 := DaYr + Tmp1;
        Tmp4 := ((Tmp3 + 91) * 100) DIV 3055;
        d := ((Tmp3 + 91) - (Tmp4 * 3055) DIV 100);
        m := (Tmp4 - 2)
      END
    ELSE
      BEGIN
        d := 0;
        m := 0
      END
  END;  { DayOfYearToDate }

{==========================================================================}

  PROCEDURE JulianDayToDate (nd : LONGINT; VAR y, m, d : WORD);

  { procedure JDATE from CACM Algorithm 199                                }
  { Computes calendar date from a given Julian day number for any          }
  { valid Gregorian calendar date                                          }
  { GIVEN:   nd - Julian day number (2440000 --> 1968 5 23)                }
  { RETURNS: y - year                                                      }
  {          m - month                                                     }
  {          d - day                                                       }

  VAR
    Tmp1, Tmp2, Tmp3 : LONGINT;
  BEGIN
    Tmp1 := nd - 1721119;
    Tmp3 := (4 * Tmp1 - 1) DIV 146097;
    Tmp1 := (4 * Tmp1 - 1) MOD 146097;
    Tmp2 := Tmp1 DIV 4;
    Tmp1 := (4 * Tmp2 + 3) DIV 1461;
    Tmp2 := (4 * Tmp2 + 3) MOD 1461;
    Tmp2 := (Tmp2 + 4) DIV 4;
    m := ((5 * Tmp2 - 3) DIV 153);
    Tmp2 := (5 * Tmp2 - 3) MOD 153;
    d := ((Tmp2 + 5) DIV 5);
    y := (100 * Tmp3 + Tmp1);
    IF m < 10 THEN
      m := m + 3
    ELSE
      BEGIN
        m := m - 9;
        y := y + 1
      END
  END;  { JulianDayToDate }

{==========================================================================}

  PROCEDURE DateOfEaster (Yr : WORD; VAR Mo, Da : WORD);

  { Algorithm "E" from Knuth's "Art of Computer Programming", vol. 1       }
  { Computes date of Easter for any year in the Gregorian calendar         }
  { The local variables are the variable names used by Knuth.              }
  { GIVEN:   Yr - year                                                     }
  { RETURNS: Mo - month of Easter (3 or 4)                                 }
  {          Da - day of Easter                                            }

  VAR
    G, C, X, Z, D, E, N : LONGINT;
  BEGIN
  { Golden number of the year in Metonic cycle   }
    G := Yr MOD 19 + 1;
  { Century  }
    C := Yr DIV 100 + 1;
  { Corrections: }
  { <X> is the no. of years in which leap-year was dropped in }
  { order to keep step with the sun   }
  { <Z> is a special correction to synchronize Easter with the }
  { moon's orbit  . }
    X := (3 * C) DIV 4 - 12;
    Z := (8 * C + 5) DIV 25 - 5;
  { <D> Find Sunday   }
    D := (5 * Yr) DIV 4 - X - 10;
  { Set Epact  }
    E := (11 * G + 20 + Z - X) MOD 30;
    IF E < 0 THEN
      E := E + 30;
    IF ((E = 25) AND (G > 11)) OR (E = 24) THEN
      E := E + 1;
  { Find full moon - the Nth of MARCH is a "calendar" full moon }
    N := 44 - E;
    IF N < 21 THEN
      N := N + 30;
  { Advance to Sunday }
    N := N + 7 - ((D + N) MOD 7);
  { Get Month and Day }
    IF N > 31 THEN
      BEGIN
        Mo := 4;
        Da := N - 31
      END
    ELSE
      BEGIN
        Mo := 3;
        Da := N
      END
  END; { DateOfEaster }

{==========================================================================}

  FUNCTION SIDateStr (y, m, d : WORD; SLen : BYTE; FillCh : CHAR) : STRING;

  { Returns date <y>, <m>, <d> converted to a string in SI format.  If     }
  { <Slen> = 10, the string is in form YYYY_MM_DD; If <SLen> = 8, in form  }
  { YY_MM_DD; otherwise a NULL string is returned.  The character between  }
  { values is <FillCh>.                                                    }
  { For correct Systeme-Internationale date format, the call should be:    }
  {   SIDateStr (Year, Month, Day, 10, ' ');                               }
  { IF <y>, <m> & <d> are all = 0, Runtime library PROCEDURE GetDate is    }
  { called to obtain the current date.                                     }

  VAR
    s2 : STRING[2];
    s4 : STRING[4];
    DStr : STRING[10];
    Index : BYTE;
    dw : WORD;
  BEGIN
    IF (SLen <> 10) AND (SLen <> 8) THEN
      DStr[0] := Chr (0)
    ELSE
      BEGIN
        IF (y = 0) AND (m = 0) AND (d = 0) THEN
          GetDate (y, m, d, dw);
        IF SLen = 10 THEN
          BEGIN
            Str (y:4, s4);
            DStr[1] := s4[1];
            DStr[2] := s4[2];
            DStr[3] := s4[3];
            DStr[4] := s4[4];
            Index := 5
          END
        ELSE
          IF SLen = 8 THEN
            BEGIN
              Str (y MOD 100:2, s2);
              DStr[1] := s2[1];
              DStr[2] := s2[2];
              Index := 3
            END;
        DStr[Index] := FillCh;
        Inc (Index);
        Str (m:2, s2);
        IF s2[1] = ' ' THEN
          DStr[Index] := '0'
        ELSE
          DStr[Index] := s2[1];
        DStr[Index+1] := s2[2];
        Index := Index + 2;
        DStr[Index] := FillCh;
        Inc (Index);
        Str (d:2, s2);
        IF s2[1] = ' ' THEN
          DStr[Index] := '0'
        ELSE
          DStr[Index] := s2[1];
        DStr[Index+1] := s2[2];
        DStr[0] := Chr (SLen)
      END;
    SIDateStr := DStr
  END;  { SIDateStr }
 
{==========================================================================}

  FUNCTION TimeStr (h, m, s, c : WORD) : STRING;

  { Returns the time <h>, <m>, <s> and <c> formatted in a string:          }
  { "HH:MM:SS.CC"                                                          }
  { This function does NOT check for valid string length.                  }
  {                                                                        }
  { IF <h>, <m>, <s> & <c> all = 0, the Runtime PROCEDURE GetTime is       }
  { called to get the current time.                                        }

  VAR
    sh, sm, ss, sc : STRING[2];
  BEGIN
    IF h + m + s + c = 0 THEN
      GetTime (h, m, s, c);
    Str (h:2, sh);
    IF sh[1] = ' ' THEN
      sh[1] := '0';
    Str (m:2, sm);
    IF sm[1] = ' ' THEN
      sm[1] := '0';
    Str (s:2, ss);
    IF ss[1] = ' ' THEN
      ss[1] := '0';
    Str (c:2, sc);
    IF sc[1] = ' ' THEN
      sc[1] := '0';
    TimeStr := Concat (sh, ':', sm, ':', ss, '.', sc)
  END;  { TimeStr }

{==========================================================================}
  FUNCTION TimeStr2 (h, m, s : WORD) : STRING;

  { Returns the time <h>, <m>, and <s>  formatted in a string:             }
  { "HH:MM:SS"                                                             }
  { This function does NOT check for valid string length.                  }
  {                                                                        }
  { IF <h>, <m>, & <c> all = 0, the Runtime PROCEDURE GetTime is           }
  { called to get the current time.                                        }

  VAR
    c              : word;
    sh, sm, ss     : STRING[2];
  BEGIN
    IF h + m + s = 0 THEN
      GetTime (h, m, s, c);
    Str (h:2, sh);
    IF sh[1] = ' ' THEN
      sh[1] := '0';
    Str (m:2, sm);
    IF sm[1] = ' ' THEN
      sm[1] := '0';
    Str (s:2, ss);
    IF ss[1] = ' ' THEN
      ss[1] := '0';
    TimeStr2 := Concat (sh, ':', sm, ':', ss)
  END;  { TimeStr2 }

{==========================================================================}
  FUNCTION MDYR_Str (y, m, d : WORD): STRING;     {dwh}

  { Returns the date <y>, <m>, <d> formatted in a string:                  }
  { "MM/DD/YYYY"                                                           }
  { This function does NOT check for valid string length.                  }
  {                                                                        }
  { IF <m>, <d>, & <y> all = 0, the Runtime PROCEDURE GetDate is           }
  { called to get the current date.                                        }

  VAR
    sm, sd     : STRING[2];
    sy         : STRING[4];
    dont_care  : word;
  BEGIN
    IF y + m + d = 0 THEN
      GetDate (y, m, d, dont_care);
    Str (m:2, sm);
    IF sm[1] = ' ' THEN
      sm[1] := '0';
    Str (d:2, sd);
    IF sd[1] = ' ' THEN
      sd[1] := '0';
    Str (y:4, sy);
    MDYR_Str := Concat (sm, '/', sd, '/', sy)
  END;  { MDYR_Str }


{==========================================================================}

  FUNCTION Secs100 (h, m, s, c : WORD) : DOUBLE;

  { Returns the given time <h>, <m>, <s> and <c> as a floating-point       }
  { value in seconds (presumably valid to .01 of a second).                }
  {                                                                        }
  { IF <h>, <m>, <s> & <c> all = 0, the Runtime PROCEDURE GetTime is       }
  { called to get the current time.                                        }

  BEGIN
    IF h + m + s + c = 0 THEN
      GetTime (h, m, s, c);
    Secs100 :=  (h * 60.0 + m) * 60.0 + s + (c * 0.01)
  END;  { Secs100 }


{==========================================================================}

  PROCEDURE AddDays (y, m, d : WORD; plus : LONGINT; VAR y1, m1, d1 : WORD);

  { Computes the date <y1>, <m1>, <d1> resulting from the addition of      }
  { <plus> days to the calendar date <y>, <m>, <d>.                        }

  VAR
    JulDay : LONGINT;
  BEGIN
    JulDay := JulianDay (y, m, d) + plus;
    JulianDayToDate (JulDay, y1, m1, d1)
  END;  { AddDays }

{==========================================================================}

  FUNCTION ValidDate (y, m, d : WORD) : BOOLEAN;

  { Returns TRUE if the date <y> <m> <d> is valid.                         }

  VAR
    JulDay : LONGINT;
    ycal, mcal, dcal : WORD;
  BEGIN
    JulDay := JulianDay (y, m, d);
    JulianDayToDate (JulDay, ycal, mcal, dcal);
    ValidDate := (y = ycal) AND (m = mcal) AND (d = dcal)
  END;  { ValidDate }

{==========================================================================}

  FUNCTION DayOfWeek (y, m, d : WORD) : WORD;

  { Returns the Day-of-the-week (0 = Sunday) (Zeller's congruence) from an }
  { algorithm IZLR given in a remark on CACM Algorithm 398.                }

  VAR
    Tmp1, Tmp2, yy, mm, dd : LONGINT;
  BEGIN
    yy := y;
    mm := m;
    dd := d;
    Tmp1 := mm + 10;
    Tmp2 := yy + (mm - 14) DIV 12;
    DayOfWeek :=  ((13 *  (Tmp1 - Tmp1 DIV 13 * 12) - 1) DIV 5 +
                  dd + 77 + 5 * (Tmp2 - Tmp2 DIV 100 * 100) DIV 4 +
                  Tmp2 DIV 400 - Tmp2 DIV 100 * 2) MOD 7;
  END;  { DayOfWeek }

{==========================================================================}
FUNCTION DayOfWeek_Str (y, m, d : WORD) : String;
begin
  CASE DayOfWeek (y, m, d) of
   0: DayOfWeek_Str := 'SUNDAY';
   1: DayOfWeek_Str := 'MONDAY';
   2: DayOfWeek_Str := 'TUESDAY';
   3: DayOfWeek_Str := 'WEDNESDAY';
   4: DayOfWeek_Str := 'THURSDAY';
   5: DayOfWeek_Str := 'FRIDAY';
   6: DayOfWeek_Str := 'SATURDAY';
  end; {case}
end; {dayofweek_str}


{==========================================================================}
FUNCTION JJ_JulianDay (y, m, d : word) : LONGINT;
  {*  format     5 position = last 2 digits of year+DayOfYear *}
var
  dw : word;
begin
  IF (y+m+d = 0)
    THEN GetDate (Y,M,D, dw);
  JJ_JulianDay:= ((LongInt(y) Mod 100)*1000+ DayOfYear(y,m,d));
end; {jj_julianday}


{==========================================================================}
PROCEDURE JJ_JulianDayToDate (nd : LONGINT; VAR y, m, d : WORD);
  {*  format     nd=5 positions   last 2 digits of year+DayOfYear *}
BEGIN
  y := (nd DIV 1000); {year}
  IF (y < 60)          {will error when 2060}
    THEN y := 2000+y
    ELSE y := 1900+y;
                    {dayofyear}
  DayOfYearToDate ( (nd MOD 1000), y, m, d);
END;  { JulianDayToDate }

{==========================================================================}
FUNCTION Lotus_Date_Str (nd : LONGINT) : string;
   {* lotus is strange the ND is the number of days SINCE 12/31/1899 *}
   {*         which is the JULIAN day 2415020                        *}
   {*   Return format is MM/DD/YYYY                                  *}
var
  y,m,d : word;
begin
  JulianDayToDate (nd+2415020-1, y,m,d);
  Lotus_Date_Str := MDYr_Str (y,m,d);
end; {lotus_date_str}

{==========================================================================}
FUNCTION Str_Date_to_Lotus_Date_Format( Date        : String;
                                        VAR Err_Msg : String): LongInt;{OLC}
VAR
  Y, M, D : word;
  Julian  : LongInt;
BEGIN
  Err_Msg := '';
  IF ValidDate_Str(Date, Y, M, D, Err_Msg ) THEN
    BEGIN
      Julian := JulianDay( Y, M, D );
      Julian := Julian - 2415020 + 1;
      Str_Date_to_Lotus_Date_Format := Julian
    END
  ELSE
    Str_Date_to_Lotus_Date_Format := -1;
END;{Str_Date_to_Lotus_Date_Format}


{==========================================================================}
FUNCTION ValidDate_Str (Str         : string;
                        VAR Y, M, D : word;
                        VAR Err_Str : string) : boolean;
   {* returns TRUE when Str is valid  MM/DD/YYYY  or MM-DD-YYYY      *}
   {*         the values are ranged checked and the date is also     *}
   {*         checked for existance                                  *}
   {*         Y, M, D are filled in with the values.                 *}
var
  Err_Code               : integer;
  Long_Int               : LongInt;
  Slash1, Slash2         : byte;
begin
  Err_Str  := '';
  Err_Code := 0;

  IF (Length (Str) < 8)
    THEN Err_Str := 'Date must be   12/31/1999  format'
  ELSE
    BEGIN
      Slash1 := POS ('/', Str);
      IF (Slash1 > 0)
        THEN Slash2 := POS ('/', COPY (Str, Slash1+1, LENGTH(Str))) + Slash1
      ELSE
        BEGIN
          Slash2 := 0;
          Slash1 := POS ('-', Str);
          IF (Slash1 > 0)
            THEN Slash2 := POS ('-', COPY (Str, Slash1+1,
                                             LENGTH(Str))) + Slash1;
        END;

      IF ((Slash1 =  Slash2) or (Slash2 = 0))
        THEN Err_Str := 'Date String must have either "-" or "/"'+
                        ' such as (12/01/1999)'
      ELSE
        BEGIN
          VAL (COPY(Str, 1,(Slash1-1)), Long_Int, Err_Code);
          IF ((Err_Code <> 0) or (Long_Int < 1) or (Long_Int > 12))
            THEN Err_Str := 'Month must be a number 1..12!'

          ELSE
            BEGIN
              M := Long_Int;
              VAL (COPY(Str, (Slash1+1),(Slash2-Slash1-1)),
                           Long_Int, Err_Code);
              IF ((Err_Code <> 0) or (Long_Int < 1) or (Long_Int > 31))
                THEN Err_Str := 'Day must be a number 1..31!'

              ELSE
                BEGIN
                  D := Long_Int;
                  VAL (COPY(Str, (Slash2+1),LENGTH(Str)), Long_Int, Err_Code);
                  IF ((Err_Code <> 0) or (Long_Int < 1900))
                    THEN Err_Str := 'Year must be a number greater than 1900!'
                    ELSE Y := Long_Int;
                END;
            END;
        END;
    END; {if long enough}

  IF ((LENGTH(Err_Str) = 0) and (NOT DATES.ValidDate (Y, M, D)))
    THEN Err_Str := 'Date does not exist!!!!';

  IF (LENGTH(Err_Str) = 0)
    THEN ValidDate_Str := TRUE
    ELSE ValidDate_Str := FALSE;

END; {validdate_str}

{==========================================================================}
FUNCTION ValidTime_Str (Str         : string;
                        VAR H, M, S : word;
                        VAR Err_Str : string) : boolean;
   {* returns TRUE when Str is valid  HH:MM  or HH:MM:SS             *}
   {*         also H, M, S are filled in with the values.            *}
var
  Err_Code               : integer;
  Long_Int               : LongInt;{use longint with VAL to prevent overflow}
  Sep1, Sep2             : byte;
  Count                  : byte;
begin
  Err_Str  := '';
  Err_Code := 0;

  IF (Length (Str) < 4)
    THEN Err_Str := 'Time must be   HH:MM or HH:MM:SS  format'
  ELSE
    BEGIN
      Sep1 := POS (':', Str);
      IF (Sep1 = 0)
        THEN Err_Str := 'Time String must have either ":" '+
                        ' such as  HH:MM  or  HH:MM:SS'

      ELSE
        BEGIN
          VAL (COPY(Str, 1,(Sep1-1)), Long_Int, Err_Code);
          IF ((Err_Code <> 0) or (Long_Int < 1) or (Long_Int > 24))
            THEN Err_Str := 'Hour must be a number 1..24!'

          ELSE
            BEGIN
              H := Long_Int;
              Sep2 := POS (':', COPY (Str, Sep1+1, LENGTH(Str))) + Sep1;
              IF (Sep2 = Sep1)
                THEN Count := LENGTH(Str)
                ELSE Count := Sep2-Sep1-1;
              VAL (COPY(Str,(Sep1+1),Count), Long_Int, Err_Code);
              IF ((Err_Code <> 0) or (Long_Int < 0) or (Long_Int > 59))
                THEN Err_Str := 'Minute must be a number 0..59!'

              ELSE
                BEGIN
                  M := Long_Int;
                  IF (Sep2 <> Sep1) THEN
                    BEGIN
                      VAL (COPY(Str, (Sep2+1),LENGTH(Str)), Long_Int, Err_Code);
                      IF ((Err_Code <> 0) or (Long_Int < 0) or (Long_Int > 59))
                        THEN Err_Str := 'Second must be a number 0..59!'
                        ELSE S := Long_Int;
                    END
                  ELSE S := 0;
                END;
            END;
        END;
    END; {if long enough}

  IF (LENGTH(Err_Str) = 0)
    THEN ValidTime_Str := TRUE
    ELSE ValidTime_Str := FALSE;

END; {validtime_str}

END. {unit dates}

