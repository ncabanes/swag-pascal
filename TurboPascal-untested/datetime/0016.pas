{Does anyone have any code that takes a minutes figure away from the date
and time ?
The following should do the trick.  note that it Uses a non-TP-standard
date/time Record structure, but you could modify it if you wanted to.

------------------------------------------------------------------------------
}

Unit timeadj;

Interface

Type

timtyp  = Record             {time Record}
            hour  : Byte;
            min   : Byte;
          end;

dattyp  = Record             {date Record}
            year : Integer;
            mon  : Byte;
            day  : Byte;
            dayno: Byte;
          end;

dttyp   = Record             {date time Record}
            time : timtyp;
            date : dattyp;
          end;

Function adjtime(od : dttyp ; nmins : Integer ; Var nd : dttyp) : Boolean;
            {add/subtract nmins to od to give nd}
            {return T if day change}

Implementation

{Date/Julian Day conversion routines
 Valid from 1582 onwards
 from James Miller G3RUH, Cambridge, England}

Const
{days in a month}
monthd  : Array [1..12] of Byte = (31,28,31,30,31,30,31,31,30,31,30,31);

d0 : LongInt = -428; {James defines this as the general day number}

Procedure date2jul(Var dn : LongInt ; dat : dattyp);
{calc julian date DN from date DAT}
Var
m : Byte;

begin
  With dat do
    begin
      m := mon;
      if m <= 2 then
        begin
          m := m + 12;
          dec(year);
        end;
      dn := d0 + day + trunc(30.61 * (m + 1)) + trunc(365.25 * year) +
      {the next line may be omitted if only used from Jan 1900 to Feb 2100}
            trunc(year / 400) - trunc(year / 100) + 15;
    end
end; {date2jul}

Procedure jul2date(dn : LongInt ; Var dat : dattyp);
{calc date DAT from julian date DN}
Var
d : LongInt;

begin
  With dat do
    begin
      d := dn - d0;
      dayno := (d + 5) mod 7;
      {the next line may be omitted if only used from Jan 1900 to Feb 2100}
      d := d + trunc( 0.75 * trunc(1.0 * (d + 36387) / 36524.25)) - 15;
      year := trunc((1.0 * d - 122.1) / 365.25);
      d := d - trunc(365.25 * year);
      mon := trunc(d / 30.61);
      day := d - trunc(30.61 * mon);
      dec(mon);
      if mon > 12 then
        begin
          mon := mon - 12;
          inc(year);
        end;
    end;
end;  {jul2date}

Function juld2date(jul : Word ; Var jd : dattyp) : Boolean;
{convert julian day  to date}
{ret T if no err}

Var
sum : Integer;
j : LongInt;

begin
  if jul > 366 then
    begin
      juld2date := False;
      Exit;
    end
  else
    juld2date := True;
  if (jd.year mod 4) = 0 then
    monthd[2] := 29
  else
    monthd[2] := 28;
  sum := 0;
  jd.mon := 0;
  Repeat
    inc(jd.mon);
    sum := sum + monthd[jd.mon];
  Until sum >= jul;
  sum := sum - monthd[jd.mon];
  jd.day := jul - sum;
  date2jul(j,jd);
  jul2date(j,jd);
end; {juld2date}

Procedure adjdate(od : dattyp ; ndays : Integer ; Var nd : dattyp);
            {add/subtract ndays to od to give nd}

Var
j : LongInt;

begin
  date2jul(j,od);
  j := j + ndays;
  jul2date(j,nd);
end;

Function adjtime(od : dttyp ; nmins : Integer ; Var nd : dttyp) : Boolean;
            {add/subtract nmins to od to give nd}
            {return T if day change}
Var
emins : Integer;
tnd   : dttyp; {needed in Case routine called With od & nd the same}

begin
  adjtime := False;
  tnd := od;
  emins := od.time.hour*60 + od.time.min + nmins;
  if emins > 1439 then
    begin
      adjtime :=  True;
      emins := emins - 1440;
      adjdate(od.date,1,tnd.date);
    end;
  if emins < 0 then
    begin
      adjtime :=  True;
      emins := emins + 1440;
      adjdate(od.date,-1,tnd.date);
    end;
  tnd.time.hour := emins div 60;
  tnd.time.min  := emins mod 60;
  nd := tnd;
end;   {adjtime}

end.
