{>I noticed that Pascal has Functions called unpacktime() and packtime().
>Does anyone know how these two Functions work?  I need either a source
>code example of the equiValent or just a plain algorithm to tell me how
>these two Functions encode or Decode and date/time into a LongInt.

  The packed time Format is a 32 bit LongInt as follows:

   bits     field
   ----     -----
   0-5   =  seconds
   6-11  =  minutes
   12-16 =  hours
   17-21 =  days
   22-25 =  months
   26-31 =  years

  DateTime is a Record structure defined Within the Dos Unit With the
  following structure:

   DateTime = Record
     year,month,day,hour,min,sec : Word
     end;

  The GetFtime Procedure loads the date/time stamp of an opened File
  into a LongInt.  UnPackTime extracts the Various bit patterns into the
  DateTime Record structure.  PackTime will take the Values you Assign
  to the DateTime Record structure and pack them into a LongInt - you
  could then use SetFTime to update the File date stamp.  A small sample
  Program follows.
}
Program prg30320;

Uses
  Dos;

Var
  TextFile : Text;
  Filetime : LongInt;
  dt : DateTime;

begin
  Assign(TextFile,'TextFile.txt');
  ReWrite(TextFile);
  WriteLn(TextFile,'Hi, I''m a Text File');
  GetFtime(TextFile,Filetime);
  Close(TextFile);
  UnPackTime(Filetime,dt);
  WriteLn('File was written: ',dt.month,'/',dt.day,'/',dt.year,
                        ' at ',dt.hour,':',dt.min,':',dt.sec);
  ReadLn;
end.

{
The following example shows how to pick apart the packed date/time.
}

Program PKTIME;
Uses
  Dos;

Var
  dt : DateTime;
  pt : LongInt;
  Year  : 0..127;    { Years sInce 1980 }
  Month : 1..12;     { Month number }
  Day   : 1..31;     { Day of month }
  Hour  : 0..23;     { Hour of day }
  Min   : 0..59;     { Minute of hour }
  Sec2  : 0..29;     { Seconds divided by 2 }

Procedure GetDateTime(Var dt : DateTime);
{ Get current date and time. Allow For crossing midnight during execution. }
Var
  y, m, d, dow : Word;
  Sec100       : Word;
begin
  GetDate(y, m, d, dow);
  GetTime(dt.Hour, dt.Min, dt.Sec, Sec100);
  GetDate(dt.Year, dt.Month, dt.Day, dow);
  if dt.Day <> d then
    GetTime(dt.Hour, dt.Min, dt.Sec, Sec100);
end;

begin
  GetDateTime(dt);
  PackTime(dt, pt);
  Year  := (pt shr 25) and $7F;
  Month := (pt shr 21) and $0F;
  Day   := (pt shr 16) and $1F;
  Hour  := (pt shr 11) and $1F;
  Min   := (pt shr  5) and $3F;
  Sec2  := pt and $1F;
  WriteLn(Month, '/', Day, '/', Year+1980);
  WriteLn(Hour,  ':', Min, ':', Sec2*2);
end.
