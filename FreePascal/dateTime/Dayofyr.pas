(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0010.PAS
  Description: DAYOF-YR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{ RN> Does someone have a Procedure I can use to give me a String
 RN> containing the "day number" ? ie: if today is day number
 RN> 323, the Function/Procedure would contain that.
}
 Uses Crt;

 Var today,
     year, month, day : Word;

 Const
  TDays       : Array[Boolean,0..12] of Word =
                ((0,31,59,90,120,151,181,212,243,273,304,334,365),
                (0,31,60,91,121,152,182,213,244,274,305,335,366));

Function DayofTheYear(yr,mth,d : Word): Word;
  { valid For all years 1901 to 2078                                  }
  Var
    temp  : Word;
    lyr   : Boolean;
  begin
    lyr   := (yr mod 4 = 0); 
    temp  := TDays[lyr][mth-1];
    inc(temp,d);
    DayofTheYear := temp;
  end;  { PackedDate }

begin
  ClrScr;
  year := 2016;
  month := 12;
  day := 31;
  today := DayofTheYear(year,month,day);
  Writeln(today);
  readln;
end.
