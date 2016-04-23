unit Dates;

{Gives time and date passed in DateTime format (defined by the DOS unit)
 as a fully formatted string.  DFormat is a word type variable that tells
 the code how to handle the time and date:


 Bit  Function:             If 0:                 If 1:
 ---  --------------------  --------------------  --------------------
  15  ShowDOW               Don't show day name   Show day name
  14  Century               Show year as XX       Show year as XXXX
  13  SpaceDate             No spaces in date     Space between fields
  12  CommaSep              Use comma in date     don't use comma
  11  MonthType             Numerical             English name
  10  > DateOrder | 00 -- DDMMYY | 10 -- YYMMDD
   9  >           | 01 -- MMDDYY | 11 -- YYDDMM
   8  MonthName             3 letters only        Full name of month
   7  DateSep               Space date with " "   Space date with "-"
   6  DTOrder               time then date        date then time
   5  > TDSpace 00 - 11 : 1 - 4 spaces, respectively
   4  >
   3  HourPad               Use needed spaces     Always uses 2 spaces
   2  HPadMeth              Pad hour with " "     Pad hour with "0"
   1  MSPadMeth             Pad min/sec with " "  Pad min/sec with "0"
   0  Show12_24             Use 12 hr. & am/pm    24-hour (military)

 Some fields require others to be set/clear to have any affect.  I never
 got around to defining any constants for the fields, but that's easy
 enough to take care of in the interface section, if needed.

 Use freely in any venture, private or public, but if you use it in anything
 that makes money, please at the very least, let me the author of this unit,
 know about it!  :-)

 Standard disclaimers apply.

 Written (and Submitted) by Scott Earnest, some time in 1994
 e-mail (Internet): scott@whiplash.pc.cc.cmu.edu
}

interface

uses DOS;

var
  lastdate : string;

function DateTimeString (Chron : DateTime; DFormat : word) : string;

implementation

const
  Month3 : array [1 .. 12] of string[3] =
    ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
  MonthF : array [1 .. 12] of string [6] =
    ('uary',   'ruary',  'ch',     'il',     '',       'e',
     'y',      'ust',    'tember', 'ober',   'ember',  'ember');
  DayName : array [0 .. 6] of string[9] =
    ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
     'Thursday', 'Friday', 'Saturday');
  PadSpace = ' ';
  PadDash = '-';
  PadZero = '0';

type
  TDateTimeFormat = record
                      ShowDOW,
                      Century,
                      SpaceDate,
                      CommaSep,
                      MonthType,
                      MonthName,
                      DateSep,
                      DTOrder,
                      HourPad,
                      HPadMeth,
                      MSPadMeth,
                      Show12_24 : boolean;
                      DateOrder,
                      TDSpace : byte;
                    end;

var
  df : TDateTimeFormat;

procedure SetFlags_df (fvar : word);

  procedure shiftr;

  begin
    fvar := fvar shr 1;
  end;

begin
  df.DateOrder := (fvar and $0600) shr 9;
  df.TDSpace := (fvar and $0030) shr 4;
  df.Show12_24 := odd (fvar); shiftr;
  df.MSPadMeth := odd (fvar); shiftr;
  df.HPadMeth := odd (fvar); shiftr;
  df.HourPad := odd (fvar); shiftr;
  shiftr; shiftr;
  df.DTOrder := odd (fvar); shiftr;
  df.DateSep := odd (fvar); shiftr;
  df.MonthName := odd (fvar); shiftr;
  shiftr; shiftr;
  df.MonthType := odd (fvar); shiftr;
  df.CommaSep := odd (fvar); shiftr;
  df.SpaceDate := odd (fvar); shiftr;
  df.Century := odd (fvar); shiftr;
  df.ShowDow := odd (fvar); shiftr;
end;

function CalcDOW (d, m, y : word) : byte;

var
  t1, t2, t3, t4, t5, t6, t7 : integer;

begin
  t1 := m + 12 * trunc (0.6 + 1 / m);
  t2 := y - trunc (0.6 + 1 / m);
  t3 := trunc (13 * (t1 + 1) / 5);
  t4 := trunc (5 * t2 / 4);
  t5 := trunc (t2 / 100);
  t6 := trunc (t2 / 400);
  t7 := t3 + t4 - t5 + t6 + d - 1;
  CalcDOW := t7 - 7 * trunc (t7 / 7);
end;

function PadNum (num : word; padch : char; places : byte) : string;

var
  holdstr,
  padstr : string;

begin
  fillchar (padstr, sizeof(padstr), padch);
  padstr[0] := #16;
  str (num, holdstr);
  padstr := concat (padstr, holdstr);
  delete (padstr, 1, length (padstr) - places);
  PadNum := padstr;
end;

procedure BuildTime (var dt : DateTime; var ts : string);

var
  pad : char;
  tempstr : string;
  hour : byte;

begin
  case df.MSPadMeth of
    true  : pad := PadZero;
    false : pad := PadSpace;
  end;
  ts := concat (':', PadNum (dt.min, pad, 2), ':', PadNum (dt.sec, pad, 2));
  case df.Show12_24 of
    true  : hour := dt.hour;
    false : begin
              hour := dt.hour mod 12;
              if hour = 0 then hour := 12;
              case dt.hour of
                0 .. 11  : ts := concat (ts, 'a');
                12 .. 23 : ts := concat (ts, 'p');
              end;
            end;
  end;
  case df.HourPad of
    true  : begin
              case df.HPadMeth of
                true  : pad := PadZero;
                false : pad := PadSpace;
              end;
              ts := concat (PadNum (hour, pad, 2), ts);
            end;
    false : begin
              str (hour, tempstr);
              ts := concat (tempstr, ts);
            end;
  end;
end;

procedure BuildDate (var dt : DateTime; var ds : string);

var
  DOW : byte;
  tempstr : string;
  pad : string[1];
  ystr, dstr : string[4];
  mstr : string[9];

begin
  if df.ShowDOW then
    DOW := CalcDOW (dt.day, dt.month, dt.year);
  ystr := PadNum (dt.year, ' ', (byte(df.Century) + 1) * 2);
  case df.MonthType of
    false : case df.SpaceDate of
              false : mstr := PadNum (dt.month, '0', 2);
              true  : str (dt.month, mstr);
            end;
    true  : begin
              mstr := Month3[dt.month];
              if df.MonthName then
                mstr := concat (mstr, MonthF[dt.month]);
            end;
  end;
  case df.SpaceDate of
    false : dstr := PadNum (dt.day, '0', 2);
    true  : str (dt.day, dstr);
  end;
  case df.SpaceDate of
    false : begin
              case df.DateOrder of
                0 : ds := concat (dstr, mstr, ystr);
                1 : ds := concat (mstr, dstr, ystr);
                2 : ds := concat (ystr, mstr, dstr);
                3 : ds := concat (ystr, dstr, mstr);
              end;
            end;
    true  : begin
              case df.DateSep of
                false : pad := PadSpace;
                true  : pad := PadDash;
              end;
              case df.DateOrder of
                0 : ds := concat (dstr, pad, mstr, pad, ystr);
                1 : case df.CommaSep of
                      false : ds := concat (mstr, pad, dstr, pad, ystr);
                      true  : ds := concat (mstr, pad, dstr, ',', pad, ystr);
                    end;
                2 : ds := concat (ystr, pad, mstr, pad, dstr);
                3 : ds := concat (ystr, pad, dstr, pad, mstr);
              end;
            end;
  end;
  if df.ShowDOW then
    ds := concat (DayName[DOW], ' ', ds);
end;

function spaces (ns : byte) : string;

var
  holdstr : string;

begin
  fillchar (holdstr, sizeof(holdstr), 32);
  holdstr[0] := chr(ns);
  spaces := holdstr;
end;

function DateTimeString (Chron : DateTime; DFormat : word) : string;

var
  dstr, tstr : string;

begin
  dstr := ''; tstr := '';
  SetFlags_df (DFormat);
  BuildTime (Chron, tstr);
  BuildDate (Chron, dstr);
  case df.DTOrder of
    false : DateTimeString := concat (tstr, spaces(df.TDSpace + 1), dstr);
    true  : DateTimeString := concat (dstr, spaces(df.TDSpace + 1), tstr);
  end;
end;

begin
  lastdate := '';
end.
