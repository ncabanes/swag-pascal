(*
> Function SYS_DATE : STR8; { Format System Date as YY/MM/DD }

       No doubt, your Function will work.  But don't you think that nowadays
Programmers, even if they live in the United States, should Write software
which is a little bit more open-minded?  The date Format "YY/MM/DD" is commonly
used in your country, but in the country where I live "DD-MM-YY" is standard,
and in other countries there are other date and time Formats in use.

       Dates expressed in your country Format appear somewhat strange and
bizarre outside the US.  I wonder why most American Programmers don't care
about the country support alReady built-in into Dos.  Is this arrogance or does
this indicate a somewhat narrow-minded American way of thinking?

       Use the following Unit to determine the current country settings Valid
on the Computer your Program is operating on:
*)

Unit country;

Interface

Type
  str4 = String[4];

Function countryCode      : Byte;
Function currencySymbol   : str4;
Function dateFormat       : Word;
Function dateSeparator    : Char;
Function DecimalSeparator : Char;
Function timeSeparator    : Char;


Implementation
Uses
  Dos;

Type
  countryInfoRecord = Record
    dateFormat     : Word;
    currency       : Array[1..5] of Char;
    thouSep,
    DecSep,
    dateSep,
    timeSep        : Array[1..2] of Char;
    currencyFormat,
    significantDec,
    timeFormat     : Byte;
    CaseMapAddress : LongInt;
    dataListSep    : Array[1..2] of Char;
    reserved       : Array[1..5] of Word
  end;

Var
  countryRecord : countryInfoRecord;
  reg           : Registers;


Procedure getCountryInfo; { generic Dos call used by all Functions }

begin

  reg.AH := $38;
  reg.AL := 0;
  reg.DS := seg(countryRecord);
  reg.DX := ofs(countryRecord);
  msDos(reg)

end; { getCountryInfo }


Function countryCode : Byte; { returns country code as set in Config.Sys }

begin

  countryCode := reg.AL

end; { countryCode }

Function currencySymbol : str4; { returns currency symbol }
Var
  temp : str4;
  i    : Byte;

begin

  With countryRecord do
  begin
    temp := '';
    i := 0;
    Repeat
      Inc(i);
      if currency[i] <> #0 then temp := temp + currency
    Until (i = 5) or (currency[i] = #0)
  end;
  currencySymbol := temp

end; { currencySymbol }


Function dateFormat : Word;
{ 0 : USA    standard mm/dd/yy }
{ 1 : Europe standard dd-mm-yy }
{ 2 : Japan  standard yy/mm/dd }
begin

  dateFormat := countryRecord.dateFormat

end; { dateFormat }


Function dateSeparator : Char; { date separator Character }

begin

  dateSeparator := countryRecord.dateSep[1]

end; { dateSeparator }


Function DecimalSeparator : Char; { Decimal separator Character }

begin

  DecimalSeparator := countryRecord.DecSep[1]

end; { DecimalSeparator }


Function timeSeparator : Char; { time separator Character }

begin

  timeSeparator := countryRecord.timeSep[1]

end; { timeSeparator }

begin

  getCountryInfo

end. { Unit country }
