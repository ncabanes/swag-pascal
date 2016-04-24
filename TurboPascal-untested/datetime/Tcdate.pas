(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0015.PAS
  Description: TCDATE.PAS
  Author: TREVOR J. CARLSEN
  Date: 05-28-93  13:37
*)

Unit TCDate;

  { Author: Trevor J Carlsen  Released into the public domain }
  {         PO Box 568                                        }
  {         Port Hedland                                      }
  {         Western Australia 6721                            }
  {         Voice +61 91 732 026                              }

Interface

Uses Dos;

Type
  Date          = Word;
  UnixTimeStamp = LongInt;

Const
  WeekDays   : Array[0..6] of String[9] =
               ('Sunday','Monday','Tuesday','Wednesday','Thursday',
                'Friday','Saturday');
  months     : Array[1..12] of String[9] =
               ('January','February','March','April','May','June','July',
                'August','September','October','November','December');

Function DayofTheWeek(pd : date): Byte;
 { Returns the day of the week For any date  Sunday = 0 .. Sat = 6    }
 { pd = a packed date as returned by the Function PackedDate          }
 { eg...  Writeln('today is ',WeekDays[DayofTheWeek(today))];         }

Function PackedDate(yr,mth,d: Word): date;
 { Packs a date into a Word which represents the number of days since }
 { Dec 31,1899   01-01-1900 = 1                                       }

Function UnixTime(yr,mth,d,hr,min,sec: Word): UnixTimeStamp;
 { Packs a date and time into a four Byte unix style Variable which   }
 { represents the number of seconds that have elapsed since midnight  }
 { on Jan 1st 1970.                                                   }

Procedure UnPackDate(Var yr,mth,d: Word; pd : date);
 { Unpacks a Word returned by the Function PackedDate into its        }
 { respective parts of year, month and day                            }

Procedure UnPackUnix(Var yr,mth,d,hr,min,sec: Word; uts: UnixTimeStamp);
 { Unpacks a UnixTimeStamp Variable into its Component parts.         }

Function DateStr(pd: date; Format: Byte): String;
 { Unpacks a Word returned by the Function PackedDate into its        }
 { respective parts of year, month and day and then returns a String  }
 { Formatted according to the specifications required.                }
 { if the Format is > 9 then the day of the week is prefixed to the   }
 { returned String.                                                   }
 { Formats supported are:                                             }
 {     0:  dd/mm/yy                                                   }
 {     1:  mm/dd/yy                                                   }
 {     2:  dd/mm/yyyy                                                 }
 {     3:  mm/dd/yyyy                                                 }
 {     4:  [d]d xxx yyyy   (xxx is alpha month of 3 Chars)            }
 {     5:  xxx [d]d, yyyy                                             }
 {     6:  [d]d FullAlphaMth yyyy                                     }
 {     7:  FullAlphaMth [d]d, yyyy                                    }
 {     8:  [d]d-xxx-yy                                                }
 {     9:  xxx [d]d, 'yy                                              } 
 
Function ValidDate(yr,mth,d : Word; Var errorcode : Byte): Boolean;
 { Validates the date and time data to ensure no out of range errors  }
 { can occur and returns an error code to the calling Procedure. A    }
 { errorcode of zero is returned if no invalid parameter is detected. }
 { Errorcodes are as follows:                                         }

 {   Year out of range (< 1901 or > 2078) bit 0 of errorcode is set.  }
 {   Month < 1 or > 12                    bit 1 of errorcode is set.  }
 {   Day < 1 or > 31                      bit 2 of errorcode is set.  }
 {   Day out of range For month           bit 2 of errorcode is set.  }

Procedure ParseDateString(Var dstr; Var y,m,d : Word; Format : Byte);
 { Parses a date String in several Formats into its Component parts   }
 { It is the Programmer's responsibility to ensure that the String    }
 { being parsed is a valid date String in the Format expected.        }
 { Formats supported are:                                             }
 {     0:  dd/mm/yy[yy]                                               }
 {     1:  mm/dd/yy[yy]                                               } 

Function NumbofDaysInMth(y,m : Word): Byte;
 { returns the number of days in any month                            }

Function IncrMonth(pd: date; n: Word): date;
 { Increments pd by n months.                                         }

Function today : date;
 { returns the number of days since 01-01-1900                        }

Function ordDate (Y,M,D : Word):LongInt; { returns ordinal Date yyddd }

Function Dateord (S : String) : String;    { returns Date as 'yymmdd' }



{============================================================================= }

Implementation

 Const
  TDays       : Array[Boolean,0..12] of Word =
                ((0,31,59,90,120,151,181,212,243,273,304,334,365),
                (0,31,60,91,121,152,182,213,244,274,305,335,366));
  UnixDatum   = LongInt(25568);
  SecsPerDay  = 86400;
  SecsPerHour = LongInt(3600);
  SecsPerMin  = LongInt(60);
  MinsPerHour = 60;

Function DayofTheWeek(pd : date): Byte;
  begin
    DayofTheWeek := pd mod 7;
  end; { DayofTheWeek }

Function PackedDate(yr,mth,d : Word): date;
  { valid For all years 1901 to 2078                                  }
  Var
    temp  : Word;
    lyr   : Boolean;
  begin
    lyr   := (yr mod 4 = 0);
    if yr >= 1900 then
      dec(yr,1900);
    temp  := yr * Word(365) + (yr div 4) - ord(lyr);
    inc(temp,TDays[lyr][mth-1]);
    inc(temp,d);
    PackedDate := temp;
  end;  { PackedDate }

Function UnixTime(yr,mth,d,hr,min,sec: Word): UnixTimeStamp;
  { Returns the number of seconds since 00:00 01/01/1970 }
  begin
    UnixTime := SecsPerDay * (PackedDate(yr,mth,d) - UnixDatum) +
                SecsPerHour * hr + SecsPerMin * min + sec;
  end;  { UnixTime }

Procedure UnPackDate(Var yr,mth,d: Word; pd : date);
  { valid For all years 1901 to 2078                                  }
  Var
    julian : Word;
    lyr    : Boolean;
  begin
    d      := pd;
    yr     := (LongInt(d) * 4) div 1461;
    julian := d - (yr * 365 + (yr div 4));
    inc(yr,1900);
    lyr    := (yr mod 4 = 0);
    inc(julian,ord(lyr));
    mth    := 0;
    While julian > TDays[lyr][mth] do
      inc(mth);
    d      := julian - TDays[lyr][mth-1];
  end; { UnPackDate }

Procedure UnPackUnix(Var yr,mth,d,hr,min,sec: Word; uts: UnixTimeStamp);
  Var
    temp : UnixTimeStamp;
  begin
    UnPackDate(yr,mth,d,date(uts div SecsPerDay) + UnixDatum);
    temp   := uts mod SecsPerDay;
    hr     := temp div SecsPerHour;
    min    := (temp mod SecsPerHour) div MinsPerHour;
    sec    := temp mod SecsPerMin;
  end;  { UnPackUnix }

Function DateStr(pd: date; Format: Byte): String;

  Var
    y,m,d    : Word;
    YrStr    : String[5];
    MthStr   : String[11];
    DayStr   : String[8];
    TempStr  : String[5];
  begin
    UnpackDate(y,m,d,pd);
    str(y,YrStr);
    str(m,MthStr);
    str(d,DayStr);
    TempStr := '';
    if Format > 9 then 
      TempStr := copy(WeekDays[DayofTheWeek(pd)],1,3) + ' ';
    if (Format mod 10) < 4 then begin
      if m < 10 then 
        MthStr := '0'+MthStr;
      if d < 10 then
        DayStr := '0'+DayStr;
    end;
    Case Format mod 10 of  { Force Format to a valid value }
      0: DateStr := TempStr+DayStr+'/'+MthStr+'/'+copy(YrStr,3,2);
      1: DateStr := TempStr+MthStr+'/'+DayStr+'/'+copy(YrStr,3,2);
      2: DateStr := TempStr+DayStr+'/'+MthStr+'/'+YrStr;
      3: DateStr := TempStr+MthStr+'/'+DayStr+'/'+YrStr;
      4: DateStr := TempStr+DayStr+' '+copy(months[m],1,3)+' '+YrStr;
      5: DateStr := TempStr+copy(months[m],1,3)+' '+DayStr+' '+YrStr;
      6: DateStr := TempStr+DayStr+' '+months[m]+' '+YrStr;
      7: DateStr := TempStr+months[m]+' '+DayStr+' '+YrStr;
      8: DateStr := TempStr+DayStr+'-'+copy(months[m],1,3)+'-'+copy(YrStr,3,2);
      9: DateStr := TempStr+copy(months[m],1,3)+' '+DayStr+', '''+copy(YrStr,3,2);
    end;  { Case }  
  end;  { DateStr }

Function ValidDate(yr,mth,d : Word; Var errorcode : Byte): Boolean;
  begin
    errorcode := 0;
    if (yr < 1901) or (yr > 2078) then
      errorcode := (errorcode or 1);
    if (d < 1) or (d > 31) then
      errorcode := (errorcode or 2);
    if (mth < 1) or (mth > 12) then
      errorcode := (errorcode or 4);
    Case mth of
      4,6,9,11: if d > 30 then errorcode := (errorcode or 2);
             2: if d > (28 + ord((yr mod 4) = 0)) then
                  errorcode := (errorcode or 2);
      end; {Case }
    ValidDate := (errorcode = 0);
    if errorcode <> 0 then Write(#7);
  end; { ValidDate }

Procedure ParseDateString(Var dstr; Var y,m,d : Word; Format : Byte);
  Var
    left,middle       : Word;
    errcode           : Integer;
    st                : String Absolute dstr;
  begin
    val(copy(st,1,2),left,errcode);
    val(copy(st,4,2),middle,errcode);
    val(copy(st,7,4),y,errcode);
    Case Format of
      0: begin
           d := left;
           m := middle;
         end;
      1: begin
           d := middle;
           m := left;
         end;
    end; { Case }
  end; { ParseDateString }
    
Function NumbofDaysInMth(y,m : Word): Byte;
  { valid For the years 1901 - 2078                                   }
  begin
    Case m of
      1,3,5,7,8,10,12: NumbofDaysInMth := 31;
      4,6,9,11       : NumbofDaysInMth := 30;
      2              : NumbofDaysInMth := 28 +
                       ord((y mod 4) = 0);
    end;
  end; { NumbofDaysInMth }

Function IncrMonth(pd: date; n: Word): date;
  Var y,m,d : Word;
  begin
    UnpackDate(y,m,d,pd);
    dec(m);
    inc(m,n);
    inc(y,m div 12); { if necessary increment year }
    m := succ(m mod 12);
    if d > NumbofDaysInMth(y,m) then
      d := NumbofDaysInMth(y,m);
    IncrMonth := PackedDate(y,m,d);
  end;  { IncrMonth }

Function today : date;
  Var y,m,d,dw : Word;
  begin
    GetDate(y,m,d,dw);
    today := PackedDate(y,m,d);
  end;  { today }

Function ordDate (Y,M,D : Word): LongInt;     { returns ordinal Date as yyddd }
Var LYR  : Boolean;
    TEMP : LongInt;
begin
  LYR := (Y mod 4 = 0) and (Y <> 1900);
  Dec (Y,1900);
  TEMP := LongInt(Y) * 1000;
  Inc (TEMP,TDays[LYR][M-1]);    { Compute # days through last month }
  Inc (TEMP,D);                                  { # days this month }
  ordDate := TEMP
end;  { ordDate }

Function Dateord (S : String) : String;    { returns Date as 'yymmdd' }
Var LYR   : Boolean;
    Y,M,D : Word;
    TEMP  : LongInt;
    N     : Integer;
    StoP  : Boolean;
    SW,ST : String[6];
begin
  Val (Copy(S,1,2),Y,N); Val (Copy(S,3,3),TEMP,N);
  Inc (Y,1900); LYR := (Y mod 4 = 0) and (Y <> 1900); Dec (Y,1900);
  N := 0; StoP := False;
  While not StoP and (TDays[LYR][N] < TEMP) do
    Inc (N);
  M := N;                                                     { month }
  D := TEMP-TDays[LYR][M-1];        { subtract # days thru this month }
  Str(Y:2,SW); Str(M:2,ST);
  if ST[1] = ' ' then ST[1] := '0'; SW := SW+ST;
  Str(D:2,ST);
  if ST[1] = ' ' then ST[1] := '0'; SW := SW+ST;
  Dateord := SW
end;  { Dateord }




end.  { Unit TCDate }

