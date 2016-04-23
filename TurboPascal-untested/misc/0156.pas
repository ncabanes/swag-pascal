
UNIT nlcs;


 (*  DESCRIPTION :
    National language and country support
      - 18 countries with ISO and DOS convention
      - 6 languages  English Français Deutsch Nederland Español Italiano
        for language name, month name, day name,
            yes/no name, true/false name, compare name
      - 18  currencies  with ISO and DOS convention
      - code page
      - local and universal time for every country  in the world
          new type TIMESTAMP
          summer time supported
          time zone indicated by city name e.g. PARIS,LONDON,NEW-YORK
                                 convention     EST,TU
      - local country , local currency and local time zone autodetection

     RELEASE     :  1.0
     DATE        :  30/09/94
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT :  Turbo Pascal 5.0 or later
                    Opdate, Opstring, Opabsfld from Object Professional
     NOT Compatible with Borland Pascal protected mode !!
  *)


INTERFACE
USES opdate, opstring, opabsfld;
TYPE
  Str3 = String[3];
  LanguageType = (nolang, english, francais, deutch,
                  nederland, espanol, italiano);

  Currency_Iso = RECORD
                   code : Str3;
                   mon : Str3;
                   country : Str3;
                   tzname : Char;
                 END;

  World_TimeStr = RECORD
                    abrev : String;
                    tzone : Char;
                    offset : Real;
                  END;
  Timestamp =
    RECORD
      D : Date;
      T : Time;
      Indic : Char;
      MilliTM : LongInt;
      Wday : DayType;
      YDay : LongInt;
      YWeek : Byte;
      IsDST : Boolean;
    END;

CONST
  Currentcountry : String[3] = ' ';
  Nb_Of_Currency = 18;
  Nb_of_WorldTime = 27;
  MaxLanguage = 6;

  Table_Currency_iso : ARRAY[1..Nb_Of_Currency] OF Currency_Iso =
  ((code : '1'; mon : 'USD'; country : 'US'; tzname : 'R'),
   (code : '2'; mon : 'CAD'; country : 'CA'; tzname : 'R'),
   (code : '31'; mon : 'NLG'; country : 'NL'; tzname : 'A'),
   (code : '32'; mon : 'BEF'; country : 'BE'; tzname : 'A'),
   (code : '33'; mon : 'FRF'; country : 'FR'; tzname : 'A'),
   (code : '34'; mon : 'ESP'; country : 'ES'; tzname : 'A'),
   (code : '39'; mon : 'ITL'; country : 'IT'; tzname : 'A'),
   (code : '41'; mon : 'CHF'; country : 'CH'; tzname : 'A'),
   (code : '44'; mon : 'GBP'; country : 'GB'; tzname : 'Z'),
   (code : '45'; mon : 'DKK'; country : 'DK'; tzname : 'A'),
   (code : '46'; mon : 'SEK'; country : 'SE'; tzname : 'A'),
   (code : '47'; mon : 'NOK'; country : 'NO'; tzname : 'A'),
   (code : '49'; mon : 'DEM'; country : 'DE'; tzname : 'A'),
   (code : '61'; mon : 'AUD'; country : 'AU'; tzname : 'K'),
   (code : '81'; mon : 'JPY'; country : 'JP'; tzname : 'I'),
   (code : '351'; mon : 'PTE'; country : 'PT'; tzname : 'Z'),
   (code : '358'; mon : 'FIM'; country : 'FI'; tzname : 'B'),
   (code : '972'; mon : 'ILS'; country : 'IL'; tzname : 'B')
   );

  Table_WorldTime : ARRAY[1..Nb_of_WorldTime] OF World_TimeStr =
  ((abrev : 'Z/LONDON/UT/GMT'; tzone : 'Z'; offset : 0),
   (abrev : 'A/PARIS/CET'; tzone : 'A'; offset : + 1),
   (abrev : 'B/CAIRO'; tzone : 'B'; offset : + 2),
   (abrev : 'C/MOSCOW/BAGDAD'; tzone : 'C'; offset : + 3),
   (abrev : 'D/DUBAI'; tzone : 'D'; offset : + 4),
   (abrev : 'E/KARACHI'; tzone : 'E'; offset : + 5),
   (abrev : 'F/DACCA'; tzone : 'F'; offset : + 6),
   (abrev : 'G/BANGKOK'; tzone : 'G'; offset : + 7),
   (abrev : 'H/HONG KONG/PERTH'; tzone : 'H'; offset : + 8),
   (abrev : 'I/TOKYO'; tzone : 'I'; offset : + 9),
   (abrev : 'K/SYDNEY'; tzone : 'K'; offset : + 10),
   (abrev : 'L/NOUMEA'; tzone : 'L'; offset : + 11),
   (abrev : 'M/WELLINGTON'; tzone : 'M'; offset : + 12),
   (abrev : 'N/AZORCS'; tzone : 'N'; offset : - 1),
   (abrev : 'O/FERNANDO'; tzone : 'O'; offset : - 2),
   (abrev : 'P/RIO'; tzone : 'P'; offset : - 3),
   (abrev : 'Q/CARACAS/IST'; tzone : 'Q'; offset : - 4),
   (abrev : 'R/NEW YORK/EST'; tzone : 'R'; offset : - 5),
   (abrev : 'S/CHICAGO/CST'; tzone : 'S'; offset : - 6),
   (abrev : 'T/DENVER/MST'; tzone : 'T'; offset : - 7),
   (abrev : 'U/LOS ANGELES/PST'; tzone : 'U'; offset : - 8),
   (abrev : 'V/ANCHORAGE/AST'; tzone : 'V'; offset : - 9),
   (abrev : 'W/HONOLULU'; tzone : 'W'; offset : - 10),
   (abrev : 'X/MIDWAY'; tzone : 'X'; offset : - 11),
   (abrev : 'TERRE NEUVE/NST'; tzone : 'Y'; offset : - 3.30),
   (abrev : 'TEHERAN'; tzone : 'Y'; offset : + 3.30),
   (abrev : 'NEW DELHI'; tzone : 'Y'; offset : + 5.30));

  LanguageNames : ARRAY[LanguageType] OF String[10] =
  ('NoLanguage', 'English', 'Français', 'Deutsch', 'Nederland',
   'Español', 'Italiano');


  InternationalMonthString : ARRAY[1..MaxLanguage]
  OF ARRAY[1..12] OF String[10] =

  (('January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'),
   ('janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet',
    'août', 'septembre', 'octobre', 'novembre', 'décembre'),
   ('Januar', 'Februar', 'Marz', 'April', 'Mai', 'Juni', 'Juli',
    'August', 'September', 'Oktober', 'November', 'Dezember'),
   ('Januari', 'Februari', 'Maart', 'April', 'Mei', 'Juni', 'Juli',
    'Augustus', 'September', 'October', 'November', 'December'),
   ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
    'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'),
   ('Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio',
    'Agusto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'));

  InternationalDayString : ARRAY[1..MaxLanguage, DayType] OF String[10] =

  (('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
   ('dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'),
   ('Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'),
   ('Zondag', 'Maandag', 'Dinsdag', 'Woensdag', 'Donderdag', 'Vrijdag', 'Zaterdag'),
   ('Dominguo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'),
   ('Domenica', 'Lunedi', 'Martedi', 'Mercoledi', 'Giovedi', 'Venerdi', 'Sabato'));

  InternationalTrueFalse : ARRAY[1..MaxLanguage, 1..2] OF Char =
  (('Y', 'N'), ('O', 'N'), ('J', 'N'), ('J', 'N'), ('S', 'N'), ('S', 'N'));

  InternationalYesNo : ARRAY[1..MaxLanguage, 1..2] OF Char =
  (('T', 'F'), ('V', 'F'), ('W', 'F'), ('W', 'V'), ('V', 'F'), ('V', 'F'));

  InternationalCompareString : ARRAY[1..MaxLanguage, 1..3] OF String[8] =
  (('Less', 'Equal', 'Greater'),
   ('Moins', 'Égal', 'Plus'),
   ('Minder', 'Gleich', 'Mehr'),
   ('Minder', 'Gelijk', 'Meer'),
   ('Menos ', 'Igual ', 'Más'),
   ('Meno  ', 'Eguale', 'Più'));

VAR
  Language : LanguageType;

FUNCTION  GetCodePage : Word;
PROCEDURE SetCodePage(valeur : Word);

(* Return number  *)
FUNCTION  GetCountry : Word;
(* Return ISO convention  *)
FUNCTION  GetCountryStr : Str3;

(* value can be ISO convention e.g. BE
                 or number in alphabetic form   e.g. '32'     *)
PROCEDURE SetCountry(value : Str3);

PROCEDURE SetLanguage(Val : LanguageType);
FUNCTION  GetLanguage : String;


(* Give correct alphabetic order with current code page  *)
FUNCTION CompIntString(S1, S2 : String) : CompareType;


(* Value can be ISO convention e.g. BE
                 or number in alphabetic form   e.g. '32'     *)
FUNCTION ConvertToCountry(value : Str3) : Word;
(* Return ISO convention for currency *)
PROCEDURE CurrencyIso(value : Str3);

FUNCTION DayOfYear(Julian : Date) : Word;

  (* Week 1 is the first week that contains a Thursay   *)
FUNCTION WeekOfYear(Julian : Date) : Byte;

PROCEDURE CurrentDateTime(VAR TS : Timestamp);

(* tzname can be a city name or an abbreviation
   daylight must be modified for summer time *)
PROCEDURE SetLocalTime(tzname : String; daylight : Byte;
                       VAR TS : Timestamp);
PROCEDURE SetUniversalTime(VAR TS : Timestamp);

(* To bypass  autodetection  *)
PROCEDURE SetTimeZone(tzname : String; daylight : Byte; VAR tz : Char);


IMPLEMENTATION
USES dos, opdos;
CONST
  Delims : SET OF Char = [',', '/'];
TYPE
  PCollating = ^TCollating;
  TCollating = RECORD
                 len : Word;
                 table : ARRAY[0..255] OF Char;
               END;
VAR
  TimeZone : LongInt;
  CollatingSequence : PCollating;
  TimeZoneName : Char;


  FUNCTION GetCodePage : Word;
  VAR
    reg : registers;

  BEGIN
    WITH reg DO
    BEGIN
      AH := $66;
      AL := $01;
      MsDos(reg);
      GetCodePage := BX;
    END;
  END;

  PROCEDURE SetCodePage(valeur : Word);
  VAR
    reg : registers;

  BEGIN
    WITH reg DO
    BEGIN
      AH := $66;
      AL := $02;
      BX := valeur;
      MsDos(reg);
    END;
  END;
  (*-----------------------------------------------------------------*)


  PROCEDURE InternationalCollating(VAR CollatingSeq : PCollating);
  TYPE
    Tinfo = RECORD
              id : Byte;
              P : Pointer;
            END;
  VAR
    regs : registers;
    info : Tinfo;
    i : Integer;
  BEGIN
    WITH regs DO
    BEGIN
      AH := $65;
      AL := $06;
      BX := GetCodePage;
      CX := $5;
      DX := 1;
      ES := Seg(info);
      DI := Ofs(info);
      MsDos(regs);
    END;
    CollatingSeq := info.P;
  END;
  (*-----------------------------------------------------------------*)

  FUNCTION CompIntString(S1, S2 : String) : CompareType;
  VAR
    i : Byte;

  BEGIN
    FOR i := 0 TO Length(S1) DO
    BEGIN
      S1[i] := (CollatingSequence^.table[Ord(S1[i])]);
    END;

    FOR i := 0 TO Length(S2) DO
    BEGIN
      S2[i] := CollatingSequence^.table[Ord(S2[i])];
    END;

    CompIntString := CompString(S1, S2);
  END;


  (*-----------------------------------------------------------------*)

  FUNCTION DayOfYear(Julian : Date) : Word;
  VAR
    Day, Month, Year : Integer;
    Days : Word;
    FirstDay : Date;
    Secs : LongInt;
    DT1, DT2 : DateTimeRec;

  BEGIN
    DateToDMY(Julian, Day, Month, Year);

    FirstDay := DMYToDate(01, 01, Year);
    DT1.D := Julian;
    DT1.T := CurrentTime;
    DT2.D := FirstDay;
    DT2.T := CurrentTime;
    DateTimeDiff(DT1, DT2, Days, Secs);
    DayOfYear := Days + 1;
  END;

  FUNCTION WeekOfYear(Julian : Date) : Byte;
  VAR
    Day, Month, Year : Integer;
    FirstDay : Date;
    Tmp, tmp2 : Byte;

  BEGIN
    DateToDMY(Julian, Day, Month, Year);
    FirstDay := DMYToDate(01, 01, Year);
    CASE DayOfWeek(FirstDay) OF
      Sunday : Tmp := 5;
      Monday : Tmp := 6;
      Tuesday : Tmp := 7;
      Wednesday : Tmp := 8;
      Thursday : Tmp := 9;
      Friday : Tmp := 3;
      Saturday : Tmp := 4;
    END;
    tmp2 := (DayOfYear(Julian) + Tmp) DIV 7;
    IF (tmp2 = 0) AND ((Tmp = 3) OR (Tmp = 4) OR (Tmp = 5)) THEN
    BEGIN
      FirstDay := DMYToDate(01, 01, (Year - 1));
      CASE DayOfWeek(FirstDay) OF
        Sunday : Tmp := 5;
        Monday : Tmp := 6;
        Tuesday : Tmp := 7;
        Wednesday : Tmp := 8;
        Thursday : Tmp := 9;
        Friday : Tmp := 3;
        Saturday : Tmp := 4;
      END;
      tmp2 := (DayOfYear(DMYToDate(31, 12, Year - 1)) + Tmp) DIV 7;
    END;
    WeekOfYear := tmp2;
  END;

  (* ---------------------------------------------------------------*)

  PROCEDURE SetInternationalMonthDay(Val : LanguageType);
  VAR
    value, i : Byte;
    j : DayType;

  BEGIN
    value := Ord(Val);
    FOR i := 1 TO 12 DO
      MonthString[i] := InternationalMonthString[value, i];
    FOR j := Sunday TO Saturday DO
      DayString[j] := InternationalDayString[value, j];
  END;
  (*---------------------------------------------------------------------*)
  PROCEDURE SetDateTime(VAR TS : Timestamp);

  BEGIN

    TS.Wday := DayOfWeek(TS.D);
    TS.YDay := DayOfYear(TS.D);
    TS.YWeek := WeekOfYear(TS.D);
  END;

  FUNCTION Match(S, P : String) : Boolean;
  VAR
    Ind, j, N, Nprime : Byte;
    Prov : Boolean;

  BEGIN
    Prov := False; j := 1;
    Ind := WordCount(P, Delims);
    WHILE (j <= Ind) AND NOT Prov DO
    BEGIN
      N := WordPosition(j, P, Delims);
      IF j < Ind THEN
      BEGIN
        Nprime := WordPosition(j + 1, P, Delims);
        Prov := S = Copy(P, N, Nprime - N - 1);
      END
      ELSE
        Prov := S = Copy(P, N, (Length(P) - N + 1));
      Inc(j);
    END;
    Match := Prov;
  END;
  (*---------------------------------------------------------------------*)

  PROCEDURE CurrentDateTime(VAR TS : Timestamp);
  BEGIN
    TS.MilliTM := TimeMS;
    TS.IsDST := False;
    TS.T := CurrentTime;
    TS.D := Today;
    SetDateTime(TS);
    TS.Indic := TimeZoneName;
  END;
  (*---------------------------------------------------------------------*)
  PROCEDURE SetLocalTime(tzname : String; daylight : Byte;
                         VAR TS : Timestamp);

  VAR i : Byte;
    off : Real;
    DT : DateTimeRec;
    found : Boolean;

  BEGIN
    SetDateTime(TS);
    TS.IsDST := daylight <> 0;
    IF NOT(TS.Indic = 'Z') THEN
      SetUniversalTime(TS);
    SetTimeZone(tzname, daylight, TS.Indic);
    DT.D := TS.D; DT.T := TS.T;
    IncDateTime(DT, DT, 0, TimeZone);
    TS.D := DT.D; TS.T := DT.T;

  END;

  (*---------------------------------------------------------------------*)
  PROCEDURE SetUniversalTime(VAR TS : Timestamp);
  VAR
    DT : DateTimeRec;

  BEGIN
    SetDateTime(TS);
    DT.D := TS.D; DT.T := TS.T;
    IncDateTime(DT, DT, 0, (TimeZone * - 1));
    TS.D := DT.D; TS.T := DT.T;
    TS.IsDST := False;
    TS.Indic := 'Z';
  END;
  (*---------------------------------------------------------------------*)
  PROCEDURE SetTimeZone(tzname : String; daylight : Byte; VAR tz : Char);

  VAR i : Byte;
    off : Real;
    found : Boolean;
  BEGIN
    found := False; i := 1;
    WHILE (i <= Nb_of_WorldTime) AND (NOT found) DO
    BEGIN
      IF Match(StUpCase(tzname), Table_WorldTime[i].abrev) THEN
      BEGIN
        off := Table_WorldTime[i].offset;
        tz := Table_WorldTime[i].tzone;
        found := True;
      END;
      Inc(i);
    END;
    off := off + daylight;
    TimeZone := Trunc(Int(off) * SecondsInHour
                      + (Frac(off) * 100 * SecondsInMinute));
    
  END;
  (*-----------------------------------------------------------------*)

  PROCEDURE CurrencyTimeZone(value : Str3);
  VAR i : Byte;

  BEGIN
    FOR i := 1 TO Nb_Of_Currency DO

      IF (Table_Currency_iso[i].code = value)
      OR (Table_Currency_iso[i].country = value)

      THEN
      BEGIN
        CurrencyLtStr := Table_Currency_iso[i].mon;
        CurrencyRtStr := Table_Currency_iso[i].mon;
        SetTimeZone(Table_Currency_iso[i].tzname, 0, TimeZoneName);

      END;
  END;
  (*-----------------------------------------------------------------*)
  PROCEDURE SetCountry(value : Str3);
  VAR
    regs : registers;
    i : Byte;
    valeur : Word;

  BEGIN
    FOR i := 1 TO Nb_Of_Currency DO
      IF (Table_Currency_iso[i].code = value)
      OR (Table_Currency_iso[i].country = value)
      THEN
        IF Str2word(Table_Currency_iso[i].code, valeur) THEN
        BEGIN
          WITH regs DO BEGIN
            {get pointer to country information table}
            AX := $3800;
            DX := $0FFFF;
            IF valeur < 255 THEN
              AL := valeur
            ELSE
            BEGIN
              AL := $FF;
              BX := valeur;
            END;
            Intr($21, regs);
          END;
          (*          CurrencyTimeZone(GetCountryStr);*)
          InternationalCollating(CollatingSequence);
        END;
  END;
  (*-----------------------------------------------------------------*)
  FUNCTION GetCountry : Word;
  VAR
    info : CountryInfo;
    regs : registers;
  BEGIN
    WITH regs DO BEGIN
      AX := $3800;
      DS := Seg(info);
      DX := Ofs(info);
      AL := $0;
      Intr($21, regs);
      GetCountry := BX;
    END;
  END;
  (*-----------------------------------------------------------------*)
  FUNCTION GetCountryStr : Str3;
  VAR
    i : Byte;
    value : Str3;
  BEGIN
    value := Long2Str(GetCountry);
    FOR i := 1 TO Nb_Of_Currency DO

      IF (Table_Currency_iso[i].code = value)
      OR (Table_Currency_iso[i].country = value)
      THEN
        GetCountryStr := Table_Currency_iso[i].country;
  END;


  PROCEDURE CurrencyIso(value : Str3);
  VAR i : Byte;
  BEGIN
    FOR i := 1 TO Nb_Of_Currency DO

      IF (Table_Currency_iso[i].code = value)
      OR (Table_Currency_iso[i].country = value)
      THEN
      BEGIN
        CurrencyLtStr := Table_Currency_iso[i].mon;
        CurrencyRtStr := Table_Currency_iso[i].mon;
      END;
  END;

  (* --------------------------------------------------------------*)
  FUNCTION ConvertToCountry(value : Str3) : Word;
  VAR i : Byte;
    wrk : Word;
    error : Integer;

  BEGIN
    wrk := 1;
    FOR i := 1 TO Nb_Of_Currency DO
      IF Table_Currency_iso[i].country = StUpCase(value)
      THEN
        Val(Table_Currency_iso[i].code, wrk, error);
    ConvertToCountry := wrk;
  END;
  (*-----------------------------------------------------------------*)

  PROCEDURE SetInternationalTrueYes(Val : LanguageType);
  VAR
    value : Byte;
  BEGIN

    value := Ord(Val);
    TrueChar := InternationalTrueFalse[value, 1];
    FalseChar := InternationalTrueFalse[value, 2];
    YesChar := InternationalYesNo[value, 1];
    NoChar := InternationalYesNo[value, 2];
    BooleanSet := [InternationalTrueFalse[value, 1],
    LoCase(InternationalTrueFalse[value, 1]),
    InternationalTrueFalse[value, 1],
    LoCase(InternationalTrueFalse[value, 1])];

    YesNoSet := [InternationalTrueFalse[value, 2],
    LoCase(InternationalTrueFalse[value, 2]),
    InternationalTrueFalse[value, 2],
    LoCase(InternationalTrueFalse[value, 2])];

  END;
  (* --------------------------------------------------------------- *)

  PROCEDURE SetLanguage(Val : LanguageType);

  VAR
    i : Word;
  BEGIN

    Language := Val;
    CASE Language OF
      english, nederland, italiano : SetCodePage(437);
      francais, deutch, espanol :
        BEGIN
          SetCodePage(850);
          SetInternationalUpcase;
        END;
    END;

    SetInternationalMonthDay(Val);
    SetInternationalTrueYes(Val);
    New(CollatingSequence);
    InternationalCollating(CollatingSequence);

  END;
  (* --------------------------------------------------------------- *)
  FUNCTION GetLanguage : String;
  BEGIN
    GetLanguage := LanguageNames[LanguageType(Language)];
  END;

BEGIN
  Currentcountry := GetCountryStr;
  CurrencyTimeZone(GetCountryStr);
END.

{ ----------------   DEMO PROGRAM ------------------- }

program demonlcs;
(* Demonstration program for use of nlcs unit *)

uses crt,opdate,nlcs,opabsfld,opstring,
     editform;

var
   TS,r : timestamp;
   S1,S2 : string;
   found: boolean;
   i : word;

   begin
      clrscr;
      writeln ('DEMO NLCS');writeln;
      S1 := 'zone'; S2 := 'été';
      SetLanguage(francais);
      writeln(STUpcase(S1),' ',StUpcase(S2));
      writeln (' Comparaison  correcte avec CompIntString ');

    case CompIntString(S1,S2) of
      less : writeln ('S1 < S2');
      equal : writeln ('S1 = S2');
      greater : writeln ('S1 > S2');
    end;

      writeln( 'Comparaison incorrecte avec CompString');
      case CompString(S1,S2) of
      less : writeln ('S1 < S2');
      equal : writeln ('S1 = S2');
      greater : writeln ('S1 > S2');
    end;


      CurrentDateTime(TS);
      writeln('Heure locale      : ',TimeStampForm('DTWZS',TS));
      SetUniversalTime(TS);
      writeln('Heure universelle : ',TimeStampForm('DTWZS',TS));
      SetLocalTime('EST',0,TS);
      writeln('Heure Los Angeles : ',TimeStampForm('DTWZS',TS));
      delay(3500);
      CurrentDateTime(r);
      Writeln('Temps écoulé en ms: ',
          RealForm('##.#',(R.MilliTm - TS.MilliTM)/1000.0));

      writeln;
      writeln('Langage          : ', GetLanguage);
      writeln('Code Page        : ', GetCodePage);
      writeln('Pays  local      : ', GetCountryStr);
      writeln('Symbole monétaire: ', CurrencyLtStr);
      delay(5500);
   end.