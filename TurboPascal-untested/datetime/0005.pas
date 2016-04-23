{
 I need an accurate method of converting back and
 Forth between Gregorian and Julian dates.  if anyone
}

Procedure GregoriantoJulianDN;

Var
  Century,
  XYear    : LongInt;

begin {GregoriantoJulianDN}
  if Month <= 2 then begin
    Year := pred(Year);
    Month := Month + 12;
    end;
  Month := Month - 3;
  Century := Year div 100;
  XYear := Year mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  JulianDN := ((((Month * 153) + 2) div 5) + Day) + D2 + XYear + Century;
end; {GregoriantoJulianDN}

{**************************************************************}

Procedure JulianDNtoGregorian;

Var
  Temp,
  XYear   : LongInt;
  YYear,
  YMonth,
  YDay    : Integer;

begin {JulianDNtoGregorian}
  Temp := (((JulianDN - D2) shl 2) - 1);
  XYear := (Temp mod D1) or 3;
  JulianDN := Temp div D1;
  YYear := (XYear div D0);
  Temp := ((((XYear mod D0) + 4) shr 2) * 5) - 3;
  YMonth := Temp div 153;
  if YMonth >= 10 then begin
    YYear := YYear + 1;
    YMonth := YMonth - 12;
    end;
  YMonth := YMonth + 3;
  YDay := Temp mod 153;
  YDay := (YDay + 5) div 5;
  Year := YYear + (JulianDN * 100);
  Month := YMonth;
  Day := YDay;
end; {JulianDNtoGregorian}


{**************************************************************}

Procedure GregoriantoJulianDate;

Var
  Jan1,
  today : LongInt;

begin {GregoriantoJulianDate}
  GregoriantoJulianDN(Year, 1, 1, Jan1);
  GregoriantoJulianDN(Year, Month, Day, today);
  JulianDate := (today - Jan1 + 1);
end; {GregoriantoJulianDate}

{**************************************************************}

Procedure JuliantoGregorianDate;

Var
  Jan1  : LongInt;

begin
  GregoriantoJulianDN(Year, 1, 1, Jan1);
  JulianDNtoGregorian((Jan1 + JulianDate - 1), Year, Month, Day);
end; {JuliantoGregorianDate}

