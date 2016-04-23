{─ Fido Pascal Conference ────────────────────────────────────────────── PASCAL ─
Msg  : 493 of 505
From : Andres Cvitkovich                   2:310/36.9           28 Apr 93  22:59
To   : Jon Leosson                         2:391/20.0
Subj : Reading the country info
────────────────────────────────────────────────────────────────────────────────
Hi Jon,

Wednesday, April 14 1993, Jon Leosson wrote to All:

 JL> Does anybody know how one can read the country info which is set by
 JL> COUNTRY.SYS in DOS 4.0 and 5.0?  Any help would be appreciated...

or DOS 6.0 or DOS 3.x or ...  ;-)

here we go:

---------------------------------------------------------------}
Unit NLS;

{ NLS.PAS - National Language Support }
{ ─────────────────────────────────── }
{ (W)  Written 1992  by A. Cvitkovich }

INTERFACE

CONST
      DATE_USA    = 0;
      DATE_EUROPE = 1;
      DATE_JAPAN  = 2;
      TIME_12HOUR = 0;
      TIME_24HOUR = 1;

TYPE
      CountryInfo = Record
        ciDateFormat    : Word;
        ciCurrency      : Array [1..5] Of Char;
        ciThousands     : Char;
        ciASCIIZ_1      : Byte;
        ciDecimal       : Char;
        ciASCIIZ_2      : Byte;
        ciDateSep       : Char;
        ciASCIIZ_3      : Byte;
        ciTimeSep       : Char;
        ciASCIIZ_4      : Byte;
        ciBitField      : Byte;
        ciCurrencyPlaces: Byte;
        ciTimeFormat    : Byte;
        ciCaseMap       : Procedure;
        ciDataSep       : Char;
        ciASCIIZ_5      : Byte;
        ciReserved      : Array [1..10] Of Byte
      End;

      DateString = String [10];
      TimeString = String [10];

VAR   Country       : CountryInfo;


FUNCTION GetCountryInfo (Buf: Pointer): Boolean;
FUNCTION DateStr: DateString;
FUNCTION TimeStr: TimeString;


IMPLEMENTATION

USES Dos;

FUNCTION GetCountryInfo (Buf: Pointer): Boolean; Assembler;
Asm
    mov  ax, 3800h
    push ds
    lds  dx, Buf
    int  21h
    mov  al, TRUE
    jnc  @@1
    xor  al, al
@@1:
    pop  ds
End;

FUNCTION DateStr: DateString;
VAR   Year, Month, Day, Weekday  : Word;
      dd, mm                     : String[2];
      yy                         : String[4];
BEGIN
  GetDate (Year, Month, Day, WeekDay);
  Str (Day:2, dd);    If dd[1] = ' ' Then dd[1] := '0';
  Str (Month:2, mm);  If mm[1] = ' ' Then mm[1] := '0';
  Str (Year:4, yy);
  Case Country.ciDateFormat Of
    DATE_USA:    DateStr := mm + Country.ciDateSep + dd +
                            Country.ciDateSep + yy;
    DATE_EUROPE: DateStr := dd + Country.ciDateSep + mm +
                            Country.ciDateSep + yy;
    DATE_JAPAN:  DateStr := yy + Country.ciDateSep + mm +
                            Country.ciDateSep + dd;
    Else         DateStr := ''
  End;
END;


FUNCTION TimeStr: TimeString;
VAR   Hour, Min, Sec, Sec100  : Word;
      hh, mm, ss              : String[2];
      ampm                    : Char;
BEGIN
  GetTime (Hour, Min, Sec, Sec100);
  Str (Min:2, mm);    If mm[1] = ' ' Then mm[1] := '0';
  Str (Sec:2, ss);    If ss[1] = ' ' Then ss[1] := '0';
  Case Country.ciTimeFormat Of
    TIME_12HOUR: Begin
                   If Hour < 12 Then ampm := 'a' Else ampm := 'p';
                   Hour := Hour MOD 12;
                   If Hour = 0 Then Hour := 12;  Str (Hour:2, hh);
                   TimeStr := hh + Country.ciTimeSep + mm +
                              Country.ciTimeSep + ss + ampm + 'm'
                 End;
    TIME_24HOUR: Begin
                   Str (Hour:2, hh);
                   TimeStr := hh + Country.ciTimeSep + mm +
                              Country.ciTimeSep + ss
                 End;
    Else TimeStr := ''
  End;
END;


BEGIN
  If Not GetCountryInfo (@Country) Then Begin
     Country.ciDateFormat := DATE_USA;
     Country.ciDateSep := '-';
     Country.ciTimeFormat := TIME_12HOUR;
     Country.ciTimeSep := ':';
  End;
END.