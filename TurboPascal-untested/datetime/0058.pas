
======================================
Datumsarithmetik mit den PC und Pascal
======================================

Dieser Informationstext soll allen Programmierern helfen, die mit
der Berechnung von Tagesdaten oder der Logik der kirchlichen Feier-
tage kaempfen. Diese Text kann frei verteilt werden, solange die
folgenden Informationen nicht daraus entfernt werden.

Copyright (c) 1992 fuer diese Zusammenstellung und den erlaeuternden
Text sowie evtl. erfolgte Korrekturen by Armin Hanisch (2:246/41)
Ich moechte allen danken, die durch ihre e-Mails und sonstige Bei-
traege, insbesondere der Veroeffentlichung von Sources diese Zu-
sammenstellung erst moeglich gemacht haben. Nach Informationsstand
des Autors haben alle Autoren diese Routinen als Public Domain frei-
gegeben. Ich uebernehme allerdings weder dafuer noch fuer die korekte
Berechnung irgendwelcher Daten eine Garantie. Ich habe allerdings
einige Stunden an Testarbeit investiert, die Daten stimmen!

Sources und Alogrithmen von folgenden Personen wurden ausgewertet,
zur Verfuegung gestellt und teilweise korrigert oder an einen fuer
diesen Text einheitlichen Stil bzw. Datentyp angepasst:

Armin Hanisch - Feiertagsberechnungen
Bernd Strehuber - Feiertagsberechnungen
Carley Phillips - Jul. Berechnungen
Jeff Duntemann - Wochentagsberechnung
Judson McClendon - Osterberechnung
Martin Austermeier - Tagesberechnungen
Paul Schlyter - Osterberechnung
Pit Biernath - Jul. Berechnungen
Scott Bussinger - Jul. Berechnungen


OSTERBERECHNUNGEN:
==================

Dieser Algorithmus basiert nicht auf der Berechnung von Gauss und
kommt ohne Ausnahmen aus (lt. Paul Schlyter). Werte ueber 31 be-
zeichnen den Tag im April-31, Werte darunter bezeichnen den Tag
im Maerz.

FUNCTION Easter(year : INTEGER) : INTEGER;
VAR  a, b, c, d, e, f, g, h, i, k, l, m : INTEGER;
BEGIN
   a  :=  year MOD 19;
   b  :=  year DIV 100;
   c  :=  year MOD 100;
   d  :=  b DIV 4;
   e  :=  b MOD 4;
   f  :=  ( b + 8 ) DIV 25;
   g  :=  ( b - f + 1 ) DIV 3;
   h  :=  ( 19 * a + b - d - g + 15 ) MOD 30;
   i  :=  c DIV 4;
   k  :=  c MOD 4;
   l  :=  ( 32 + 2 * e + 2 * i - h - k ) MOD 7;
   m  :=  ( a + 11 * h + 22 * l ) DIV 451;
   Easter :=  h + l - 7 * m + 22;
END{FUNC};


Eine weitere Moeglichkeit, Ostern sehr schnell zu berechnen, besteht
darin, den auf das juedische Passahfest folgenden Sonntag zu berechnen.


Der sog. Passah-Vollmond wird berechnet, in dem das Jahr durch 19 ge-
teilt wird und der Rest mit der folgenden Tabelle verglichen wird:

    0: Apr 14       5: Apr 18      10: Mrz 25      15: Mrz 30
    1: Apr 03       6: Apr 08      11: Apr 13      16: Apr 17
    2: Mrz 23       7: Mrz 28      12: Apr 02      17: Apr 07
    3: Apr 11       8: Apr 16      13: Mrz 22      18: Mrz 27
    4: Mrz 31       9: Apr 05      14: Apr 10

Faellt dieses Datum auf einen Sonntag, ist Ostern der naechste Sonntag!

Beispiel: 1992 MOD 19 = 16, daraus folgt 17.04., der naechste Sonntag
          ist dann der 19. April (Ostersonntag)


FEIERTAGE:
==========

Massgebend fuer die kirchlichen Feiertage ist sowohl das Osterdatum
als auch der 1. Advent, der Beginn des Krichenjahres. Wie man Ostern
berechnet, wurde oben erlaeutert. Hier nun also die Berechnungen der
restlichen Feiertage.

Aschermittwoch:      40 Tage vor dem Ostersonntag,
                     dann zurⁿckgehen bis zum Mittwoch
                     Bsp.:  result := GetOstern;
                            Dec(result,40);
                            WHILE DayOfWeek(result) <> 3 DO
                               Dec(result);

Palmsonntag:         Der Sonntag vor dem Ostersonntag, die Berechnung
                     ist damit trivial.

Weisser Sonntag:     Der Sonnrtag nach Ostern, ebenfalls simpel.

Christi Himmelfahrt: 39 Tage nach dem Ostersonntag oder anders gesagt,
                     der zweite Donnerstag vor Pfingsten.

Pfingsten:           49 Tage nach dem Ostersonntag.

Fronleichnam:        60 Tage nach dem Ostersonntag.

Maria Himmelfahrt:   Fest am 15. August (nicht ueberall Feiertag!)

1. Advent:           Vom 24.12. zurⁿck bis zum nΣchsten Sonntag,
                     dann noch drei Wochen zurⁿck.
                     Bsp.:  result := MakeDate(24,12,year);
                            WHILE DayOfWeek(result) <> 0 DO
                               Dec(result);
                            Dec(result,21);

Buss- und Bettag:    Der vorvorige Mittwoch vor dem 1. Advent, also
                     vom 1. Advent aus den Mittwoch suchen, dann noch
                     eine Woche zurⁿck.
                     Bsp:  <adventberechnung>   <-- wie oben
                           WHILE DayOfWeek(result) <> 3 DO
                              Dec(result);
                           Dec(result,7);


Hl. drei K÷inige:    Fest am 06.01.

Allerheiligen:       Fest am 01.11.

Tag der Arbeit:      Fest am 01.05.

Tag der dt. Einheit: Fest am 03.10. Hier wird im Zuge von Sparmassnahmen
                     fⁿr die einzufⁿhrende Pflegeversicherung allerdings
                     ⁿberlegt, diesen Feiertag immer auf den ersten Sonn-
                     tag im Oktober zu legen, man sollte hier also die
                     politischen Nachrichten verfolgen!


DATUMSARITHMETIK:
=================

Berechnung eines Schaltjahres
-----------------------------

FUNCTION LeapYear(year : WORD) : BOOLEAN;
BEGIN
   LeapYear := ((year MOD 4 = 0) AND (year MOD 100 <> 0))
               OR (year MOD 400 = 0);
END;


Berechnung des Wochentages
--------------------------

FUNCTION DayOfWeek(Day,Month,Year: Integer): INTEGER;
VAR century,yr,dw: Integer;
BEGIN
  IF Month < 3 THEN BEGIN
    Inc(Month,10);
    Dec(Year);
  END{IF} ELSE
    Dec(Month,2);
  century := Year div 100;
  yr := year mod 100;
  dw := (((26*month-2) div 10)+day+yr+(yr div 4)
        +(century div 4)-(2*century)) mod 7;
  IF dw < 1 THEN Inc(dw,7);
  DayOfWeek:=dw;
END{FUNC};

Als Ergebnis erhaelt man den Wochentag in folgender Reiehenfolge:
0=Sonntag, 1=Montag ..... 6=Samstag


Berechnung der Kalenderwoche
----------------------------

Die Woche 1 ist die Woche, die den ersten Donnerstag des Jahres
enthaelt, also mehr als die Haelfte diesem Jahr angehoert.
Ist der 01.01. ein Mo-Mi, dann liegt der 01.01. in der letzten
Woche des vergangenen Jahres. (DIN 1355)

FUNCTION WeekOfYear (Day,Month,Year:WORD) : WORD;
CONST
  table1 : ARRAY [0..6] OF ShortInt = ( -1,  0,  1,  2,  3, -3, -2);
  table2 : ARRAY [0..6] OF ShortInt = ( -4,  2,  1,  0, -1, -2, -3);
VAR
  doy1 ,
  doy2 : INTEGER;
BEGIN
  doy1 := DayofYear (Day,Month,Year) + table1[DayOfWeek (1,1,Year)];
  doy2 := DayofYear (Day,Month,Year) + table2[DayOfWeek(Day,Month,Year)];
  IF doy1 <= 0 THEN WeekOfYear := WeekOfYear(31,12,Year-1)
   ELSE IF doy2 >= DayofYear(31,12,Year) THEN WeekOfYear:=1
     ELSE WeekOfYear := (doy1-1) DIV 7 + 1;
END;


Berechnung der Tage im Monat
----------------------------

FUNCTION DaysInMonth(month,year : WORD) : INTEGER;
VAR ly : BOOLEAN;  { leap year? }
BEGIN
   ly := ((year MOD 4 = 0) AND (year MOD 100 <> 0)) OR (year MOD 400 = 0);
   IF (month IN [04,06,09,11]) THEN  { even month }
     DaysInMonth := 30
   ELSE
     IF month <> 2 THEN  { rest except february }
       DaysInMonth := 31
     ELSE
       IF ly THEN  { leap year? }
         DaysInMonth := 29
       ELSE
         DaysInMonth := 28;
END{FUNC};


Berechnung des Tages im Jahr
----------------------------

Diese Methode gilt fuer alle Jahre ab 1582, der Einfⁿhrung des
gregorianischen Kalenders.

FUNCTION DayOfYear (day,month,year : WORD) : INTEGER;
VAR
  i, tage : Integer;
BEGIN
  tage := 0;
  FOR i := 1 TO Pred(month) DO Inc (tage, DaysInMonth(i,year));
     Inc (tage,day);
  DayOfYear := tage;
END;

Eine andere Methode kommt ohne die Berechnung der Tage im Monat aus
und bezieht ebenfalls Schaltjahre ein. Der Gⁿltigkeitsbereich dieses
Alogorithmus liegt von 1901 bis 2099.

FUNCTION DayNumber(Day,Month,Year : INTEGER ) : INTEGER;
VAR
  term1 ,
  term2 ,
  term3 : INTEGER;
BEGIN
   term1 := ( 275 * month ) div 9;
   term2 := ( month + 9 ) div 12;
   term3 := ( ( year mod 4 ) + 2 ) div 3;
   DayNumber := term1 - term2 * ( 1 +  term3 ) + day - 30;
END;

Um aus dem Tag im jahr wieder das Datum zu erhalten, kann die folgende
Routine verwendet werden:

FUNCTION YearDayToDMY(GYear,DayNumber : INTEGER; VAR Day,Month,Year : WORD);
CONST
  MonthDays : Array [1..12] of integer=
                    (31,28,31,30,31,30,31,31,30,31,30,31);
VAR
  I    : integer;
  done ,
    ly : boolean;
BEGIN
   I := 1;
   done:=false;
   ly := ((Gyear MOD 4 = 0) AND (Gyear MOD 100 <> 0))
         OR (Gyear MOD 400 = 0);
   IF ly THEN MonthDays[2] := 29; { correct for leap year february }
   REPEAT
      If DayNumber > MonthDays[i] THEN BEGIN
        DayNumber := DayNumber - MonthDays[i];
        Inc(i);
      END{IF} ELSE BEGIN
        year  := GYear;
        month := i;
        day   := DayNumber;
        done  := TRUE;
      END{ELSE};
   UNTIL (i > 12) OR done;
   IF i > 12 THEN BEGIN
     year:=GYear;
     month:=12;
     day:=31;
    END{IF};
END;


Berechnung des julianischen Datums
----------------------------------

Diese Routinen dienen der Umwandlung des Datums in eine serielle
julianische Zahl im Bereich von 01.01.1900 bis zum 31.12.2078,
wobei 0 fuer den 01.01.1900 steht (uebringens: 1900 war kein Schalt-
jahr und der 01.01. war ein Montag).

FUNCTION DateOk(day,month,year : WORD) : BOOLEAN;
VAR
   ly,ok : BOOLEAN;
  maxday : WORD;
BEGIN
  ok := (year >= 1900) AND (year <= 2078);
  ly := ((year MOD 4 = 0) AND (year MOD 100 <> 0)) OR (year MOD 400 = 0);
  IF ok THEN
    ok := (month >= 01) AND (month <= 12);
   IF ok THEN BEGIN
     IF month IN [01,03,05,07,08,10,12] THEN
       maxday := 31
     ELSE
       IF month <> 2 THEN
         maxday := 30
       ELSE
         IF ly THEN
           maxday := 29
         ELSE
           maxday := 28;
     ok := (day >= 01) AND (day <= maxday);
   END{IF};
   DateOK := ok;
END{FUNC};

FUNCTION DMYtoDate(day,month,year : WORD) : WORD;
VAR
  jul : Word;
BEGIN
   IF NOT DateOK(day,month,year) THEN BEGIN
     DMYToDate := $FFFF { signal an invalid date }
   END{IF} ELSE BEGIN  { convert back to DMY }
    IF (Year = 1900) AND (Month < 3) THEN
      IF Month = 1 THEN
        jul := Pred(Day)
      ELSE
        jul := Day + 30
    ELSE BEGIN
      IF Month > 2 THEN
        Dec (Month,3)
      ELSE BEGIN
        Inc (Month,9);
        Dec (Year);
      END{ELSE};
      Dec(year,1900);
      jul := ((1461 * LONGINT(Year)) div 4) +
             ((153 * Month+2) div 5) + Day + 58;
    END{ELSE};
  END{ELSE};
  DMYToDate := jul;
END;

PROCEDURE DateToDMY(jul : WORD; VAR day,month,year: WORD);
VAR
  LongTemp ,
  Temp     : LONGINT;
BEGIN
   IF jul <= 58 THEN BEGIN
     year := 1900;
     IF jul <= 31 THEN BEGIN
       month := 1;
       day := Succ(jul);
     END ELSE BEGIN
       month := 2;
       day := jul - 30;
     END{ELSE}
   END{IF} ELSE BEGIN
     IF jul < $FF63 THEN BEGIN
       LongTemp := (4 * LONGINT(jul-58)) - 1;
       year := LongTemp DIV 1461;
       temp := ((LongTemp MOD 1461) DIV 4) * 5 + 2;
       month := temp DIV 153;
       day := ((temp MOD 153) + 5) DIV 5;
       Inc(year,1900);
       IF month < 10 THEN
         Inc(month,3)
       ELSE BEGIN
         Dec(month,9);
         Inc(year);
       END{ELSE};
     END{IF} ELSE BEGIN  { error in date range }
       year := 0;
       month := 0;
       day := 0;
     END{ELSE};
   END{ELSE};
END;
