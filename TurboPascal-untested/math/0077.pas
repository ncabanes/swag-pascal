{
From: Martin Preishuber <martin_p@efn.efn.org>

mycalc.pas that is a unit with mathematical function. the numbers
  are based on 65536, so you can calculate with really
  huge numbers.
rabin.pas it's a demo program for mycalc. you can test large
  number,s whether it is a prime or not

both programs are documented in german, so i guess that documentation
won't help much :-(
}

(* ----------------------------------------------------------------------- *)
(* RabinTest prüft, ob eine Zahl eine Primzahl ist                         *)
(* ----------------------------------------------------------------------- *)

{$M 65000, 0, 655360}                          (* Stack auf maximale Größe *)

PROGRAM RabinTest;

USES Crt,                                         (* Ein/Ausgabefunktionen *)
     Extend,                                (* erweiterte I/O - Funktionen *)
     MyCalc;               (* Funktionen für das Rechnen mit großen Zahlen *)

(* ----------------------------------------------------------------------- *)

FUNCTION Expt(zahl : Real; hoch : INTEGER) : Real;
    (* Berechnung des Exponenten einer Realzahl (einfach, weil nur für die *)
                                       (* Berechnung von AnzahlTests nötig *)
VAR i     : INTEGER;                                       (* Zählvariable *)
    hilfe : Real;                        (* Hilfsvariable für das Ergebnis *)
BEGIN
  IF hoch = 0 THEN                                         (* Hochzahl = 0 *)
    Expt := 1                                           (* => Ergebnis = 1 *)
  ELSE
    BEGIN
      hilfe := 1;                         (* Ergebnis mit 1 initialisieren *)
      FOR i := 1 TO hoch DO hilfe := hilfe * zahl;
                           (* Zahl hoch mal mit sich selbst multiplizieren *)
      Expt := hilfe;                             (* Ergebnis zurückliefern *)
    END;
END;

(* ----------------------------------------------------------------------- *)

FUNCTION AnzahlTests(wahrscheinlichkeit : Real) : INTEGER;
        (* ermittelt die Anzahl Tests, welche nötig sind um die gewünschte *)
                                        (* Wahrscheinlichkeit zu erreichen *)
VAR anzahl : INTEGER;                          (* Anzahl der nötigen Tests *)
BEGIN
  anzahl := 0;                              (* Anzahl mit 0 initialisieren *)
  REPEAT
    INC(anzahl);                                    (* Anzahl um 1 erhöhen *)
  UNTIL ((1/(Expt(4,anzahl))) < wahrscheinlichkeit);
                                   (* solange wiederholen, bis W > (1/4)^x *)
  AnzahlTests := anzahl;                       (* Anzahl Tests zurückgeben *)
END;

(* ----------------------------------------------------------------------- *)

FUNCTION EvenString(zahl : STRING) : BOOLEAN;
                                        (* prüft, on ein String gerade ist *)
BEGIN
  EvenString := NOT Odd(Ord(zahl[Length(zahl)]) - 48);
END;                 (* prüft, ob die letzte Stelle des Strings gerade ist *)

(* ----------------------------------------------------------------------- *)

FUNCTION Div5(zahl : STRING) : BOOLEAN;
                           (* prüft, ob ein String durch 5 dividierbar ist *)
VAR last : BYTE;                                 (* letzte Stelle von zahl *)
BEGIN
  last := Ord(zahl[Length(zahl)]) - 48;         (* letzte Stelle ermitteln *)
  IF (last = 0) OR (last = 5) THEN     (* Falls letzte Stelle 0 oder 5 ist *)
    Div5 := TRUE                       (* ist die Zahl durch 5 dividierbar *)
  ELSE
    Div5 := FALSE;                                          (* sonst nicht *)
END;                 (* prüft, ob die letzte Stelle des Strings gerade ist *)

(* ----------------------------------------------------------------------- *)

FUNCTION Div3(zahl : STRING) : BOOLEAN;
                           (* prüft, ob ein String durch 5 dividierbar ist *)
VAR ziffernSumme : WORD;                       (* Ziffernsumme des Strings *)
    laenge       : BYTE;                             (* Laenge des Strings *)
    i            : BYTE;                                   (* Zählvariable *)
BEGIN
  ziffernSumme := 0;                        (* Ziffernsumme initialisieren *)
  laenge := Length(zahl);                   (* Länge des Strings ermitteln *)
  FOR i := 1 TO laenge DO                        (* ZiffernSumme ermitteln *)
    BEGIN
      ziffernSumme := ziffernSumme + (Ord(zahl[i]) - 48);
                                (* aktuelle Zahl zur Ziffernsumme addieren *)
    END;
  IF (ZiffernSumme MOD 3) = 0 THEN         (* Ziffernsumme durch 3 teilbar *)
    Div3 := TRUE                                (* => Zahl durch 3 teilbar *)
  ELSE
    Div3 := FALSE;                 (* sonst ist Zahl nicht durch 3 teilbar *)
END;

(* ----------------------------------------------------------------------- *)
(* Bedingung 1 beim Rabintest: b^v≡1 mod p                                 *)

FUNCTION Bedingung1(b, v, p, pMinus1, EINS : CalcStr) : BOOLEAN;
VAR hilfe : CalcStr;                                    (* HilfsCalcString *)
BEGIN
  ExptModCalcStr(b, v, p, hilfe);                   (* b^v mod p berechnen *)

  Write('b^v mod p = '); PrintCalcStr(hilfe);

  IF EqualCalcStr(hilfe, EINS) THEN                  (* Falls Ergebnis = 1 *)
    Bedingung1 := TRUE                              (* Bedingung 1 erfüllt *)
  ELSE
    IF EqualCalcStr(hilfe, pMinus1) THEN
      Bedingung1 := TRUE                    (* Bedingung 2 mit r=0 erfüllt *)
    ELSE
      Bedingung1 := FALSE;          (* sonst ist Bedingung 1 nicht erfüllt *)
END;

(* ----------------------------------------------------------------------- *)
(* Bedingung 2 beim Rabintest: b^(v^(2r)) ≡ -1 mod p                       *)

FUNCTION Bedingung2(VAR b, v, u, p, pMinus1, EINS : CalcStr) : BOOLEAN;
VAR r      : CalcStr;                       (* zu durchlaufende Hochzahlen *)
    ZWEI   : CalcStr;            (* konstante CalcString-Darstellung für 2 *)
    hilfe1 : CalcStr;                                   (* HilfsCalcString *)
    hilfe2 : CalcStr;                                   (* HilfsCalcString *)
BEGIN
  InitCalcStr(r);                                      (* r initialisieren *)
  r.stellen := 1;                 (* r hat 1 Stelle, diese ist zu Beginn 0 *)
  r.zahl[1] := 1;    (* r läuft von 1 weg, weil Bedingung mit r=0 schon in *)
                                               (* Bedingung 1 geprüft wird *)
  WordToCalcStr(2, ZWEI);             (* Zahl zwei in CalcString ermitteln *)
  WHILE LessCalcStr(r, u) DO                              (* solange r < u *)
    BEGIN

      Write('r = '); PrintCalcStr(r);

      ExptCalcStr(ZWEI, r, hilfe1);                       (* 2^r ermitteln *)
      MulCalcStr(hilfe1, v, hilfe2);           (* 2^r mit v multiplizieren *)
      ExptModCalcStr(b, hilfe2, p, hilfe1);    (* b^(v2^r) MOD p berechnen *)

      Write('b^(v2^r) mod p = '); PrintCalcStr(hilfe1);

      IF EqualCalcStr(hilfe1, pMinus1) THEN         (* Falls Ergebnis = -1 *)
        BEGIN
          Bedingung2 := TRUE;                       (* Bedingung 2 erfüllt *)
          EXIT;
        END;
      AddCalcStr(r, EINS, hilfe2);                       (* r um 1 erhöhen *)
      r := hilfe2;                                    (* r wieder zuweisen *)
    END;
  Bedingung2 := FALSE;                       (* 2. Bedingung nicht erfüllt *)
END;

(* ----------------------------------------------------------------------- *)
(* Rabin prüft eine Zahl mit Hilfe des RabinTests                          *)

FUNCTION Rabin(primzahl : STRING; anzahl : INTEGER) : BOOLEAN;
VAR p       : CalcStr;                        (* zu untersuchende Primzahl *)
    pMinus1 : CalcStr;                                     (* Primzahl - 1 *)
    EINS    : CalcStr;                            (* konstanter Wert für 1 *)
    u       : CalcStr;                         (* p-1 = 2^u*v (v ungerade) *)
    v       : CalcStr;                         (* p-1 = 2^u*v (v ungerade) *)
    b       : CalcStr;                           (* Basis bei Primzahltest *)
    hilfe   : CalcStr;                                  (* HilfsCalcString *)
    i       : BYTE;                                        (* Zählvariable *)
BEGIN
  StrToCalcStr(primzahl, p);        (* Primzahl ins 65536-System umwandeln *)
  WordToCalcStr(1, EINS);                   (* CalcStringdarstellung von 1 *)
  SubCalcStr(p, EINS, pMinus1);                     (* vom pMinus1 = p - 1 *)
  InitCalcStr(u);                                      (* u initialisieren *)
  u.stellen := 1;                      (* u besitzt 1 Stellen, diese ist 0 *)
  v := pMinus1;                                     (* v ist zu Beginn p-1 *)
  REPEAT
    AddCalcStr(u, EINS, hilfe);                (* 2^u, Potenz um 1 erhöhen *)
    u := hilfe;                                   (* und wieder u zuweisen *)
    Div2CalcStr(v);                                (* v durch 2 dividieren *)
  UNTIL OddCalcStr(v);                      (* solange, bis v ungerade ist *)

  Write('p = '); PrintCalcStr(p);
  Write('u = '); PrintCalcStr(u);
  Write('v = '); PrintCalcStr(v);

  FOR i := 1 TO anzahl DO                      (* Anzahl Tests durchführen *)
    BEGIN
      RandomCalcStr(p, b);                    (* zufällige Basis ermitteln *)

      Write('b = '); PrintCalcStr(b);

      IF (Bedingung1(b, v, p, pMinus1, EINS) = FALSE) THEN
                                                    (* 1. Bedingung prüfen *)
        IF (Bedingung2(b, v, u, p, pMinus1, EINS) = FALSE) THEN
          BEGIN                                     (* 2. Bedingung prüfen *)
            Rabin := FALSE;
            EXIT;     (* beide Bedingungen nicht erfüllt => keine Primzahl *)
          END;
    END;
  Rabin := TRUE;                                    (* Rabintest bestanden *)
END;

(* ----------------------------------------------------------------------- *)
(* PrimeTest prüft, ob Zahl eine Primzahl ist                              *)

FUNCTION PrimeTest(zahl : STRING; anzahlTests : INTEGER; VAR meldung : STRING)
: BOOLEAN;
BEGIN
  IF EvenString(zahl) THEN                 (* Zahl ist durch 2 dividierbar *)
    BEGIN
      PrimeTest := FALSE;                             (* => keine Primzahl *)
      meldung := 'gerade Zahl';                     (* Meldung zurückgeben *)
    END
  ELSE
    IF Div5(zahl) THEN               (* Falls Zahl durch 5 dividierbar ist *)
      BEGIN
        PrimeTest := FALSE;                              (* => keine Primzahl
*)
        meldung := 'Zahl durch 5 dividierbar';      (* Meldung zurückgeben *)
      END
    ELSE
      IF Div3(zahl) THEN                       (* Zahl durch 3 dividierbar *)
        BEGIN
          PrimeTest := FALSE;                         (* => keine Primzahl *)
          meldung := 'Zahl durch 3 dividierbar';    (* Meldung zurückgeben *)
        END
      ELSE
        BEGIN
          IF NOT Rabin(zahl, anzahlTests) THEN  (* Falls Rabintest negativ *)
            BEGIN
              PrimeTest := FALSE;                        (* keine Primzahl *)
              meldung := 'Rabintest';               (* Meldung zurückgeben *)
            END
          ELSE
            PrimeTest := TRUE;                  (* sonst ist Zahl Primzahl *)
        END;
END;

(* ----------------------------------------------------------------------- *)
(* Hauptprogramm erledigt die Ein/Ausgabe                                  *)

PROCEDURE Hauptprogramm;                (* Hauptprogramm des Primzahltests *)
VAR anzahl             : INTEGER;              (* Anzahl notwendiger Tests *)
    wahrscheinlichkeit : Real;                 (* Fehlerwahrscheinlichkeit *)
    primzahl           : STRING;                  (* zu untersuchende Zahl *)
    meldung            : STRING;          (* Meldung, warum keine Primzahl *)
    prim               : BOOLEAN;           (* ist sie Primzahl oder nicht *)
BEGIN
  ClrScr;                                            (* Bildschirm löschen *)
  Frame(27, 1, 53, 3, 1, '', TRUE);                     (* Rahmen ausgeben *)
  WriteXY(29, 2, 'Primzahltest nach Rabin');
  GotoXY(1, 6);
  WriteLn('1. Test: gerade Zahl');                       (* Tests anzeigen *)
  WriteLn('2. Test: Zahl durch 5 dividierbar');
  WriteLn('3. Test: Ziffernsumme durch 3 dividerbar');
  WriteLn('4. Test: RabinTest');
  WriteLn;
  Write('Primzahl (p): '); ReadLn(primzahl);          (* Primzahl eingeben *)
  Write('Fehlerwahrscheinlichkeit: '); ReadLn(wahrscheinlichkeit);
                                      (* Fehlerwahrscheinlichkeit eingeben *)
  anzahl := AnzahlTests(wahrscheinlichkeit);       (* Testanzahl ermitteln *)
  WriteLn;
  WriteLn('Anzahl Tests: ', anzahl);
  WriteLn;
  prim := PrimeTest(primzahl, anzahl, meldung);     (* auf Primzahl testen *)
  Write(primzahl, ' ist ');
  IF NOT prim THEN
    WriteLn('keine Primzahl (',meldung,')')            (* Meldung ausgeben *)
  ELSE
    WriteLn('Primzahl');
END;

(* ----------------------------------------------------------------------- *)

BEGIN
  Hauptprogramm;                                 (* Hauptprogramm aufrufen *)
END.

(* ----------------------------------------------------------------------- *)

(* ----------------------------------------------------------------------- *)
(* MyCalc stellt eine LongInteger-Arithmetik zur Verfuegung                *)
(* ----------------------------------------------------------------------- *)

{$M 65000, 0, 655360}                          (* Stack auf maximale Groesse *)

UNIT MyCalc;

INTERFACE

CONST MAXCALCSTR = 500;                         (* maximal 500 Word-Zahlen *)

TYPE CalcStr = RECORD
                 stellen    : WORD;         (* Anzahl der belegten Stellen *)
                 zahl       : ARRAY[1..MAXCALCSTR] OF WORD;  (* große Zahl *)
               END;

PROCEDURE InitCalcStr(VAR calcZahl : CalcStr);
PROCEDURE ReverseCalcStr(VAR ergebnis : CalcStr);
PROCEDURE SwapCalcStr(VAR zahl1, zahl2 : CalcStr);
PROCEDURE PrintCalcStr(VAR calcZahl : CalcStr);
PROCEDURE StrToCalcStr(zeichenkette : STRING; VAR ergebnis : CalcStr);
PROCEDURE WordToCalcStr(zahl : WORD; VAR ergebnis : CalcStr);
PROCEDURE AddCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
PROCEDURE SubCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
PROCEDURE Mul2CalcStr(VAR calcZahl : CalcStr);
PROCEDURE Div2CalcStr(VAR calcZahl : CalcStr);
PROCEDURE MulCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
PROCEDURE ExptCalcStr(VAR basis, exponent: CalcStr; VAR ergebnis : CalcStr);
PROCEDURE RandomCalcStr(VAR calcZahl: CalcStr; VAR ergebnis : CalcStr);
PROCEDURE MulModCalcStr(VAR zahl1, zahl2, modul : CalcStr; VAR ergebnis :
CalcStr);
PROCEDURE ExptModCalcStr(VAR basis, exponent, modul : CalcStr; VAR ergebnis :
CalcStr);

FUNCTION CalcStrLength(VAR calcZahl : CalcStr) : WORD;
FUNCTION CalcStrToStr(VAR calcZahl : CalcStr; VAR ergebnis : STRING) : BOOLEAN;
FUNCTION CalcStrToWord(VAR calcZahl : CalcStr; VAR ergebnis : WORD) : BOOLEAN;
FUNCTION EqualCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
FUNCTION GreaterCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
FUNCTION GreaterEqual(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
FUNCTION LessCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
FUNCTION LessEqual(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
FUNCTION EvenCalcStr(VAR calcZahl : CalcStr) : BOOLEAN;
FUNCTION OddCalcStr(VAR calcZahl : CalcStr) : BOOLEAN;
FUNCTION DivCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr) :
BOOLEAN;
FUNCTION ModCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr) :
BOOLEAN;

IMPLEMENTATION

USES Crt;                                         (* Ein/Ausgabefunktionen *)

VAR EMPTYCALCSTR : CalcStr;                           (* leerer CalcString *)
    i            : WORD;
                      (* Zählvariable zur Initialisierung von EMPTYCALCSTR *)

(* ======================================================================= *)
(* Bitmanipulationen                                                       *)

(* ----------------------------------------------------------------------- *)
(* SetBit setzt das BitNr.te Bit in Zahl                                   *)

FUNCTION SetBit(zahl : WORD; bitNr : BYTE): WORD;
BEGIN
  SetBit := zahl OR (1 SHL bitNr)
               (* BitNr Stellen nach links shiften und mit oder verknüpfen *)
END;

(* ----------------------------------------------------------------------- *)
(* TestBit prüft, ob das BitNr.te Bit in Zahl gesetzt ist                  *)

FUNCTION TestBit(zahl : WORD; bitNr: BYTE): BOOLEAN;
BEGIN
  TestBit := (((zahl SHR bitNr) AND 1) = 1)
             (* Bit ist dann gesetzt, falls an der BitNr. Stelle bei einer *)
                              (* Und-Verknüpfung wieder 1 das Ergebnis ist *)
END;

(* ======================================================================= *)
(* Hilfsfunktionen für Strings                                             *)

(* ----------------------------------------------------------------------- *)
(* TestString prüft, ob im String eine gültige Zahl enthalten ist          *)

FUNCTION TestString(zeichenkette : STRING) : BOOLEAN;
VAR laenge : BYTE;                               (* Länge der Zeichenkette *)
    i      : BYTE;                                         (* Zählvariable *)
BEGIN
  laenge := Length(zeichenkette);      (* Länge der Zeichenkette ermitteln *)
  FOR i := 1 TO laenge DO
    IF (NOT (zeichenkette[i] IN ['0'..'9'])) THEN            (* keine Zahl *)
      BEGIN
        TestString := FALSE;                        (* String ist ungültig *)
        EXIT;                                        (* Funktion verlassen *)
      END;
  TestString := TRUE;
END;

(* ----------------------------------------------------------------------- *)
(* OddString prüft, ob ein String ungerade ist                             *)

FUNCTION OddString(zeichenkette : STRING) : BOOLEAN;
VAR zahl   : BYTE;                          (* Bytedarstellung von Zeichen *)
    dummy  : INTEGER;  (* dient zur Überprüfung von zeichen bei Umwandlung *)
    last   : CHAR;                      (* letztes Zeichen in zeichenkette *)
    laenge : BYTE;                               (* Länge der Zeichenkette *)
BEGIN
  laenge := Length(zeichenkette);        (* Länge muß neu ermittelt werden *)
  last := zeichenkette[laenge];                         (* letztes Zeichen *)
  Val(last, zahl, dummy);             (* letztes Zeichen in zahl umwandeln *)
  oddString := Odd(zahl);                  (* prüfen, ob zahl ungerade ist *)
END;

(* ----------------------------------------------------------------------- *)
(* StrDiv2 dividiert einen String durch 2                                  *)

FUNCTION StrDiv2(zeichenkette : STRING) : STRING;
VAR hilfe      : STRING;                   (* Hilfsstring für das Ergebnis *)
    index      : BYTE;               (* Index für Position in zeichenkette *)
    laenge     : BYTE;                           (* Länge der Zeichenkette *)
    zahl       : BYTE;                          (* zu dividierender Faktor *)
    zeichen    : CHAR;                      (* Zeichendarstellung von Zahl *)
    dummy      : INTEGER;
                       (* dient zur Überprüfung von zeichen bei Umwandlung *)
    uebertrag  : BOOLEAN;                  (* ist ein Übertrag aufgetreten *)
BEGIN
  hilfe := '';                                     (* hilfe initialisieren *)
  laenge := Length(zeichenkette);                (* Länge der zeichenkette *)
  IF oddString(zeichenkette) THEN           (* falls die Zahl ungerade ist *)
    DEC(zeichenkette[laenge]);                 (* Zahl um 1 dekrementieren *)
  uebertrag := FALSE;                                     (* kein Übertrag *)
  IF zeichenkette[1] = '1' THEN               (* falls an 1.Stelle ein 1er *)
    BEGIN
      index := 2;                              (* an 2.Stelle weitermachen *)
      zahl := 10;                     (* Übertrag an 1.Stelle => zahl = 10 *)
    END
  ELSE
    BEGIN
      index := 1;                                  (* beginne bei 1.Stelle *)
      zahl := 0;                                            (* => zahl = 0 *)
    END;
  REPEAT
    zahl := zahl + Ord(zeichenkette[index]) - 48;        (* Zahl ermitteln *)
    IF (zahl AND 1) = 1 THEN uebertrag := TRUE;
                                              (* ungerade zahl => Übertrag *)
    zahl := zahl SHR 1;                         (* zahl durch 2 dividieren *)
    zeichen := Chr(zahl + 48);   (* Zahl wieder in ASCII-Zeichen umwandeln *)
    hilfe := hilfe + zeichen;                     (* und an hilfe anhängen *)
    INC(index);                                      (* Index um 1 erhöhen *)
    IF uebertrag THEN                                          (* Übertrag *)
      zahl := 10                               (* Übertrag in zahl sichern *)
    ELSE
      zahl := 0;                                         (* sonst zahl = 0 *)
    uebertrag := FALSE;                          (* Annahme: kein Übertrag *)
  UNTIL index > laenge;               (* keine Zeichen mehr zum dividieren *)
  StrDiv2 := hilfe;                             (* Ergebnis steht in Hilfe *)
END;

(* ----------------------------------------------------------------------- *)
(* StrMul2 multipliziert einen String mit 2                                *)

FUNCTION StrMul2(zeichenkette : STRING) : STRING;
VAR laenge     : BYTE;                          (* Laenge der zeichenkette *)
    i          : BYTE;                                     (* Zählvariable *)
    hilfe      : STRING;                       (* Hilfsstring für Ergebnis *)
    dummyStr   : STRING;           (* dient zur Umwandlung Zahl -> Zeichen *)
    uebertrag  : BOOLEAN;                              (* Übertrag ja/nein *)
    zeichen    : CHAR;                                (* aktuelles Zeichen *)
    zahl       : BYTE;                     (* Byte-Darstellung von zeichen *)
    dummy      : INTEGER;  (* dient zur Prüfung von zeichen bei Umwandlung *)
BEGIN
  laenge := Length(zeichenkette);                       (* Länge ermitteln *)
  uebertrag := FALSE;                            (* Annahme: kein Übertrag *)
  hilfe := '';                               (* Hilfsstring initialisieren *)
  FOR i := laenge DOWNTO 1 DO        (* zeichenkette rückwärts durchlaufen *)
    BEGIN
      zeichen := zeichenkette[i];           (* aktuelles Zeichen ermitteln *)
      zahl := Ord(zeichen) - 48;                 (* in eine Zahl umwandeln *)
      zahl := zahl SHL 1;                     (* Zahl mit 2 multiplizieren *)
      IF uebertrag THEN INC(zahl);              (* bei Übertrag 1 addieren *)
      IF (zahl >= 10) THEN                             (* falls Zahl >= 10 *)
        BEGIN
          uebertrag := TRUE;                       (* Übertrag aufgetreten *)
          zahl := zahl - 10;                      (* Übertrag wegschneiden *)
        END
      ELSE
        uebertrag := FALSE;                         (* sonst kein Übertrag *)
      zeichen := Chr(zahl + 48);              (* zahl in Zeichen umwandeln *)
      hilfe := zeichen + hilfe;                   (* und an Hilfe anhängen *)
    END;
  IF uebertrag THEN hilfe := '1' + hilfe;
                               (* restlichen Übertrag noch berücksichtigen *)
  StrMul2 := hilfe;                                   (* Ergebnis zuweisen *)
END;

(* ======================================================================= *)
(* Operationen auf den Datentyp CalcString                                 *)

(* ----------------------------------------------------------------------- *)
(* InitCalcStr initialisiert einen CalcString:                             *)

PROCEDURE InitCalcStr(VAR calcZahl : CalcStr);
BEGIN
  calcZahl := EMPTYCALCSTR;                     (* leeren CalcStr zuweisen *)
END;

(* ----------------------------------------------------------------------- *)
(* CalcStrLength liefert die Länge des CalcStrings zurück                  *)

FUNCTION CalcStrLength(VAR calcZahl : CalcStr) : WORD;
BEGIN
  CalcStrLength := calcZahl.stellen;   (* Länge ist in stellen gespeichert *)
END;

(* ----------------------------------------------------------------------- *)
(* ReverseCalcStr dreht einen CalcString um                                *)

PROCEDURE ReverseCalcStr(VAR ergebnis : CalcStr);
VAR laenge : WORD;                         (* Anzahl Stellen im CalcString *)
    i      : WORD;                                         (* Zählvariable *)
    anzahl : WORD;                                (* benötigte Schrittzahl *)
    hilfe  : WORD;                                     (* Zwischenspeicher *)
BEGIN
  laenge := CalcStrLength(ergebnis);    (* Länge des CalcStrings ermitteln *)
  anzahl := laenge DIV 2;            (* man benötigt nur laenge/2 Schritte *)
  WITH ergebnis DO                                    (* Record abarbeiten *)
    BEGIN
      FOR i := 1 TO anzahl DO
        BEGIN
          hilfe := zahl[i];                              (* i. Zahl merken *)
          zahl[i] := zahl[laenge - (i - 1)];
                        (* i. Zahl wird zur entsprechenden Zahl von hinten *)
          zahl[laenge - (i - 1)] := hilfe;  (* hintere Zahl wird i.te Zahl *)
        END;
    END;
END;

(* ----------------------------------------------------------------------- *)
(* SwapCalcStr vertauscht zwei CalcStrings                                 *)

PROCEDURE SwapCalcStr(VAR zahl1, zahl2 : CalcStr);
VAR hilfe : CalcStr;                       (* HilfsString für Vertauschung *)
BEGIN
  hilfe := zahl1;                                (* Hilfe auf Zahl1 setzen *)
  zahl1 := zahl2;                                (* Zahl1 auf Zahl2 setzen *)
  zahl2 := hilfe;                                (* Zahl2 auf Hilfe setzen *)
END;

(* ----------------------------------------------------------------------- *)
(* PrintCalcStr gibt einen CalcString als Vektor auf dem Bildschirm aus    *)

PROCEDURE PrintCalcStr(VAR calcZahl : CalcStr);
VAR i : WORD;                                              (* Zählvariable *)
BEGIN
  ReverseCalcStr(calcZahl);               (* calcZahl muß umgedreht werden *)
  WITH calcZahl DO                              (* Recordtyp als Grundlage *)
    BEGIN
      IF stellen > 0 THEN                        (* Zahl darf nicht 0 sein *)
        BEGIN
          Write('(');                              (* positives Vorzeichen *)
          FOR i := 1 TO (stellen - 1) DO        (* alle Stellen abarbeiten *)
            BEGIN
              Write(zahl[i]);                             (* Zahl ausgeben *)
              Write(',');                       (* durch Beistrich trennen *)
            END;
          Write(zahl[stellen]);                    (* letzte Zahl ausgeben *)
          WriteLn(')');                   (* Klammer des Vektors schließen *)
        END
      ELSE
        WriteLn('(0)');                                (* sonst 0 ausgeben *)
    END;
  ReverseCalcStr(calcZahl);        (* calcZahl muß wieder umgedreht werden *)
END;

(* ----------------------------------------------------------------------- *)
(* StrToCalcStr wandelt einen String in einen CalcString um                *)

PROCEDURE StrToCalcStr(zeichenkette : STRING; VAR ergebnis : CalcStr);
VAR index  : WORD;                          (* Index im ErgebnisCalcString *)
    bitnr  : BYTE;                        (* Nummer des zu setzenden Bit's *)
    laenge : BYTE;                               (* Länge der Zeichenkette *)
BEGIN
  ergebnis := EMPTYCALCSTR;               (* ErgebnisString initialisieren *)
  index := 1;                              (* erstes Element im CalcString *)
  ergebnis.stellen := 1;       (* Länge des CalcStrings wird auf 1 gesetzt *)
  bitnr := 0;                (* zu Beginn wird Bit 0 gesetzt/nicht gesetzt *)
  laenge := Length(zeichenkette);      (* Länge der Zeichenkette ermitteln *)
  IF TestString(zeichenkette) THEN   (* ist zeichenkette eine gültige Zahl *)
    WITH ergebnis DO                               (* Record als Grundlage *)
      BEGIN
        REPEAT
          IF oddString(zeichenkette) THEN   (* ist zeichenkette ungerade ? *)
            zahl[index] := SetBit(zahl[index], bitnr);       (* Bit setzen *)
          zeichenkette := StrDiv2(zeichenkette);       (* Zeichenkette / 2 *)
          IF zeichenkette <> '0' THEN           (* falls noch nicht fertig *)
            BEGIN
              INC(bitnr);                            (* BitNr um 1 erhöhen *)
              IF bitnr >= 16 THEN                 (* falls 1 Word voll ist *)
                BEGIN
                  bitnr := 0;                       (* BitNr wird wieder 0 *)
                  INC(index);          (* ein Element im CalcString weiter *)
                  INC(stellen);  (* Länge des CalcStrings wird um 1 erhöht *)
                END;
            END;
        UNTIL zeichenkette = '0';      (* bis zeichenkette auf 0 reduziert *)
      END;
END;

(* ----------------------------------------------------------------------- *)
(* CalcStrToStr wandelt eine CalcString um, falls er sich als String       *)
(* darstellen läßt                                                         *)

FUNCTION CalcStrToStr(VAR calcZahl : CalcStr; VAR ergebnis : STRING) : BOOLEAN;
VAR i      : WORD;                                         (* Zählvariable *)
    BitNr  : BYTE;                            (* Nummer des aktuellen Bits *)
    anzahl : WORD;                         (* Anzahl Stellen im CalcString *)
    laenge : BYTE;                            (* Länge des Ergebnisstrings *)
BEGIN
  IF calcZahl.Stellen > 50 THEN         (* Stringlänge würde überschritten *)
    CalcStrToStr := FALSE                                (* Stringüberlauf *)
  ELSE
    BEGIN                                     (* Zahl paßt in einen String *)
      ergebnis := '0';                   (* Ergebnisstring ist zu Beginn 0 *)
      anzahl := CalcStrLength(calcZahl);          (* Länge des CalcStrings *)
      FOR i := anzahl DOWNTO 1 DO
                               (* alle Element des CalcStrings durchlaufen *)
        FOR BitNr := 15 DOWNTO 0 DO                    (* alle Bits prüfen *)
          BEGIN
            ergebnis := StrMul2(ergebnis);   (* ErgebnisString mit 2 mult. *)
            IF TestBit(calcZahl.zahl[i], BitNr) THEN
                                                  (* Ist das Bit gesetzt ? *)
              BEGIN
                laenge := Length(ergebnis);             (* Länge ermitteln *)
                INC(ergebnis[laenge]);     (* letztes Zeichen um 1 erhöhen *)
              END;
          END;
      CalcStrToStr := TRUE;                         (* Umwandlung geglückt *)
    END;
END;

(* ----------------------------------------------------------------------- *)
(* WordToCalcStr wandelt eine Wordzahl in einen CalcString um              *)

PROCEDURE WordToCalcStr(zahl : WORD; VAR ergebnis : CalcStr);
BEGIN
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  ergebnis.stellen := 1;                           (* 1 Stelle wird belegt *)
  ergebnis.zahl[1] := zahl;                    (* Zahl in CalcZahl sichern *)
END;

(* ----------------------------------------------------------------------- *)
(* CalcStrToWord wandelt einen CalcString in eine Wordzahl um              *)

FUNCTION CalcStrToWord(VAR calcZahl : CalcStr; VAR ergebnis : WORD) : BOOLEAN;
BEGIN
  IF (calcZahl.Stellen > 1) THEN
            (* Zahl mit mehr als 1 Stelle können nicht  umgewandelt werden *)
    CalcStrToWord := FALSE                             (* keine Umwandlung *)
  ELSE
    BEGIN
      ergebnis := calcZahl.zahl[1];                (* Ergebnis zurückgeben *)
      CalcStrToWord := TRUE;                        (* Umwandlung geglückt *)
    END;
END;

(* ----------------------------------------------------------------------- *)
(* EqualCalcStr prüft, ob ein CalcStr1 = CalcStr2                          *)

FUNCTION EqualCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
VAR i : WORD;                                              (* Zählvariable *)
BEGIN
  IF (zahl1.stellen <> zahl2.stellen) THEN
    EqualCalcStr := FALSE               (* unterschiedliche Anzahl Stellen *)
  ELSE                                               (* Stellenzahl gleich *)
    BEGIN
      FOR i := 1 TO zahl1.stellen DO            (* alle Stellen abarbeiten *)
        IF zahl1.zahl[i] <> zahl2.zahl[i] THEN       (* Zahlen verschieden *)
          BEGIN
            EqualCalcStr := FALSE;              (* Zahlen sind verschieden *)
            EXIT;                                    (* Schleife verlassen *)
          END;
      EqualCalcStr := TRUE;                          (* Zahlen sind gleich *)
    END;
END;

(* ----------------------------------------------------------------------- *)
(* GreaterCalcStr prüft, ob ein CalcStr1 > CalcStr2                        *)

FUNCTION GreaterCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
VAR i     : WORD;                                          (* Zählvariable *)
    hilfe : BOOLEAN;                                      (* Hilfsvariable *)
BEGIN
  IF (zahl1.stellen > zahl2.stellen) THEN    (* Zahl1 besitzt mehr Stellen *)
    GreaterCalcStr := TRUE                             (* => Zahl1 > Zahl2 *)
  ELSE
    IF (zahl1.stellen < zahl2.stellen) THEN
                                          (* Zahl1 besitzt weniger Stellen *)
      GreaterCalcStr := FALSE                    (* => Zahl1 nicht > Zahl2 *)
    ELSE                                             (* Stellenzahl gleich *)
      BEGIN
        FOR i := zahl1.stellen DOWNTO 1 DO      (* alle Stellen abarbeiten *)
          IF zahl1.zahl[i] > zahl2.zahl[i] THEN
                             (* i.Stelle von Zahl1 > i.te Stelle von Zahl2 *)
            BEGIN
              GreaterCalcStr := TRUE;                     (* Zahl1 > Zahl2 *)
              EXIT;                                  (* Schleife verlassen *)
            END
          ELSE
            IF zahl1.zahl[i] < zahl2.zahl[i] THEN
                             (* i.Stelle von Zahl1 < i.te Stelle von Zahl2 *)
              BEGIN
                GreaterCalcStr := FALSE;            (* Zahl1 nicht > Zahl2 *)
                EXIT;                                (* Schleife verlassen *)
              END;
        GreaterCalcStr := FALSE;               (* alle Stellen sind gleich *)
      END;
END;

(* ----------------------------------------------------------------------- *)
(* GreaterEqual prüft, ob Zahl1 >= Zahl2                                   *)

FUNCTION GreaterEqual(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
BEGIN
  GreaterEqual := NOT LessCalcStr(zahl1, zahl2);
                 (* Zahl1 >= Zahl2, wenn Zahl1 nicht kleiner als Zahl2 ist *)
END;

(* ----------------------------------------------------------------------- *)
(* LessCalcStr prüft, on Zahl1 < Zahl2                                     *)

FUNCTION LessCalcStr(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
VAR i     : WORD;                                          (* Zählvariable *)
    hilfe : BOOLEAN;                                      (* Hilfsvariable *)
BEGIN
  IF (zahl1.stellen < zahl2.stellen) THEN (* Zahl1 besitzt weniger Stellen *)
    LessCalcStr := TRUE                                (* => Zahl1 < Zahl2 *)
  ELSE
    IF (zahl1.stellen > zahl2.stellen) THEN  (* Zahl1 besitzt mehr Stellen *)
      LessCalcStr := FALSE                       (* => Zahl1 nicht < Zahl2 *)
    ELSE                                             (* Stellenzahl gleich *)
      BEGIN
        FOR i := zahl1.stellen DOWNTO 1 DO      (* alle Stellen abarbeiten *)
          IF zahl1.zahl[i] < zahl2.zahl[i] THEN
                             (* i.Stelle von Zahl1 < i.te Stelle von Zahl2 *)
            BEGIN
              LessCalcStr := TRUE;                        (* Zahl1 < Zahl2 *)
              EXIT;                                  (* Schleife verlassen *)
            END
          ELSE
            IF zahl1.zahl[i] > zahl2.zahl[i] THEN
                             (* i.Stelle von Zahl1 > i.te Stelle von Zahl2 *)
              BEGIN
                LessCalcStr := FALSE;               (* Zahl1 nicht < Zahl2 *)
                EXIT;                                (* Schleife verlassen *)
              END;
        LessCalcStr := FALSE;                  (* alle Stellen sind gleich *)
      END;
END;

(* ----------------------------------------------------------------------- *)
(* LessEqual prüft, ob Zahl1 <= Zahl2                                      *)

FUNCTION LessEqual(VAR zahl1, zahl2 : CalcStr) : BOOLEAN;
BEGIN
  LessEqual := NOT GreaterCalcStr(zahl1, zahl2);
                  (* Zahl1 <= Zahl2, wenn Zahl1 nicht größer als Zahl2 ist *)
END;

(* ----------------------------------------------------------------------- *)
(* EvenCalcStr prüft, ob ein CalcString gerade ist                         *)

FUNCTION EvenCalcStr(VAR calcZahl : CalcStr) : BOOLEAN;
BEGIN
  EvenCalcStr := NOT Odd(calcZahl.zahl[1]);
        (* CalcZahl ist gerade, falls die letzte Stelle nicht ungerade ist *)
END;

(* ----------------------------------------------------------------------- *)
(* OddCalcStr prüft, ob ein CalcString ungerade ist                        *)

FUNCTION OddCalcStr(VAR calcZahl : CalcStr) : BOOLEAN;
BEGIN
  OddCalcStr := Odd(calcZahl.zahl[1]);
            (* CalcZahl ist ungerade, falls die letzte Stelle ungerade ist *)
END;

(* ----------------------------------------------------------------------- *)
(* AddCalcStr addiert zwei CalcStrings                                     *)

PROCEDURE AddCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
VAR anzahl    : WORD;                       (* Anzahl Stellen für Addition *)
    i         : WORD;                                      (* Zählvariable *)
    summe     : LongInt;      (* Hilfsvariable zur Prüfung eines Übertrags *)
    ueberlauf : BYTE;                   (* Überlauf = 1, kein Überlauf = 0 *)
    addition  : BOOLEAN;        (* können Zahlen addiert werden oder nicht *)
BEGIN
  {$Q-}                                     (* Überlaufprüfung ausschalten *)
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  anzahl := zahl1.stellen;                   (* Annahme: Zahl 1 ist größer *)
  IF zahl2.stellen > anzahl THEN          (* Falls doch 2. Zahl größer ist *)
    anzahl := zahl2.stellen;     (* so viele Stellen müssen addiert werden *)
  ueberlauf := 0;                               (* zu Beginn kein Überlauf *)
  FOR i := 1 TO anzahl DO                     (* anzahl Stellen abarbeiten *)
    BEGIN
      ergebnis.zahl[i] := zahl1.zahl[i] + zahl2.zahl[i] + ueberlauf;
                 (* ergebnis ist die Summe der beiden Zahlen (kann einfach *)
                 (* addiert werden, weil Überlaufprüfung ausgeschaltet ist *)
      summe := LongInt(zahl1.zahl[i]) + LongInt(zahl2.zahl[i]) + ueberlauf;
                                                    (* Summe ohne Überlauf *)
      IF (summe > ergebnis.zahl[i]) THEN   (* ist ein Überlauf aufgetreten *)
        ueberlauf := 1                      (* ja -> Überlauf auf 1 setzen *)
      ELSE
        ueberlauf := 0;                          (* nein -> Überlauf ist 0 *)
    END;
  IF (ueberlauf = 1) THEN           (* letzter Überlauf muß geprüft werden *)
    BEGIN
      ergebnis.stellen := anzahl + 1;    (* letzter Überlauf belegt 1 Feld *)
      ergebnis.zahl[anzahl + 1] := 1;      (* Zahl 1 steht im letzten Feld *)
    END
  ELSE
    ergebnis.stellen := anzahl;
                              (* gleich viele Stellen wie die längere Zahl *)
  {$Q+}                              (* Überlaufprüfung wieder einschalten *)
END;

(* ----------------------------------------------------------------------- *)
(* SubCalcStr subtrahiert zahl2 von zahl1                                  *)

PROCEDURE SubCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
VAR swapped   : BOOLEAN;            (* wurden Zahl1 und Zahl2 vertauscht ? *)
    i         : WORD;                                      (* Zählvariable *)
    uebertrag : BYTE;                     (* Übertrag: 1, kein Übertrag: 0 *)
BEGIN
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  swapped := FALSE;                      (* Zahlen wurden nicht vertauscht *)
  uebertrag := 0;                                         (* kein Übertrag *)
  IF GreaterCalcStr(zahl2, zahl1) THEN EXIT;              (* Zahl2 > Zahl1 *)
  FOR i := 1 TO zahl1.stellen DO                (* alle Stellen abarbeiten *)
    BEGIN
      IF (zahl1.zahl[i] >= (zahl2.zahl[i] + uebertrag)) THEN
                (* Zahl1[i] >= Zahl2[i] mit Berücksichtigung des Übertrags *)
        BEGIN
          ergebnis.zahl[i] := zahl1.zahl[i] - (zahl2.zahl[i] + uebertrag);
                                         (* Differenz der Zahlen ermitteln *)
          uebertrag := 0;                                 (* kein Übertrag *)
        END
      ELSE
        BEGIN
          ergebnis.zahl[i] := LongInt(zahl1.zahl[i] + 65536) - (zahl2.zahl[i] +
uebertrag);
          uebertrag := 1;
        END;
     END;
  ergebnis.stellen := zahl1.stellen;
                                 (* Annahme: gleich viel Stellen wie Zahl1 *)
  WHILE (ergebnis.zahl[ergebnis.stellen] = 0) AND (ergebnis.stellen > 0) DO
    DEC(ergebnis.stellen);               (* richtige Stellenzahl ermitteln *)
END;

(* ----------------------------------------------------------------------- *)
(* Mul2CalcStr multipliziert einen CalcString mit 2                        *)

PROCEDURE Mul2CalcStr(VAR calcZahl : CalcStr);
VAR i : WORD;                                              (* Zählvariable *)
BEGIN
  WITH calcZahl DO                                 (* Record als Grundlage *)
    IF ((stellen = 1) AND (zahl[1] = 0)) OR (stellen = 0) THEN
    ELSE                               (* CalcZahl ist 0 => Ergebnis ist 0 *)
      BEGIN                                     (* Sonst ist Ergebnis <> 0 *)
        IF (zahl[stellen] AND 32768) > 0 THEN
          BEGIN                 (* Ist 16.Bit der letzten Stelle gesetzt ? *)
            INC(stellen);                      (* Stellenzahl um 1 erhöhen *)
            zahl[stellen] := 0;                (* und mit 0 initialisieren *)
          END;
        FOR i := (stellen - 1) DOWNTO 1 DO              (* Zahl abarbeiten *)
          BEGIN
            zahl[i + 1] := zahl[i + 1] SHL 1;           (* Zahl[i + 1] * 2 *)
            IF (zahl[i] AND 32768) > 0 THEN INC(zahl[i + 1]);
          END;          (* Bei Überlauf bei Zahl[i] => Zahl[i + 1] erhöhen *)
        zahl[1] := zahl[1] SHL 1;          (* 1. Zahl mit 2 multiplizieren *)
      END;
END;

(* ----------------------------------------------------------------------- *)
(* Div2CalcStr dividiert einen CalcString durch 2                          *)

PROCEDURE Div2CalcStr(VAR calcZahl : CalcStr);
VAR i : WORD;                                              (* Zählvariable *)
BEGIN
  WITH calcZahl DO
    IF ((stellen = 1) AND (zahl[1] = 0)) OR (stellen = 0) THEN
    ELSE                               (* calcZahl = 0 => calcZahl * 2 = 0 *)
      BEGIN
        FOR i := 1 TO (stellen - 1) DO                  (* Zahl abarbeiten *)
          BEGIN
            zahl[i] := zahl[i] SHR 1;                     (* Zahl[i] DIV 2 *)
            IF (zahl[i + 1] AND 1) > 0 THEN
                           (* Falls bei Zahl[i + 1] ein Unterlauf auftritt *)
              zahl[i] := zahl[i] OR 32768;    (* Bit 16 bei Zahl[i] setzen *)
          END;
        zahl[stellen] := zahl[stellen] SHR 1;       (* letzte Stelle DIV 2 *)
        IF (zahl[stellen] = 0) THEN DEC(stellen);
                  (* Falls letzte Stelle 0 ist => Stellen um 1 erniedrigen *)
      END;
END;

(* ----------------------------------------------------------------------- *)
(* MulCalcStr multiplizier2 zahl1 mit zahl2                                *)

PROCEDURE MulCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr);
VAR hilfe       : CalcStr;                              (* HilfsCalcString *)
    hilfe1      : CalcStr;                              (* HilfsCalcString *)
    hilfe2      : CalcStr;                              (* HilfsCalcString *)
    i, j        : WORD;                                   (* Zählvariablen *)
    wert        : WORD;               (* Wert von Zahl an der i.ten Stelle *)
BEGIN
  IF LessCalcStr(zahl1, zahl2) THEN                 (* Falls zahl1 < zahl2 *)
    BEGIN
      hilfe1 := zahl1;                     (* Hilfe1 wird Zahl1 zugewiesen *)
      hilfe2 := zahl2;                     (* Hilfe2 wird Zahl2 zugewiesen *)
    END
  ELSE
    BEGIN
      hilfe2 := zahl1;                     (* Hilfe2 wird Zahl1 zugewiesen *)
      hilfe1 := zahl2;                     (* Hilfe1 wird Zahl2 zugewiesen *)
    END;
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  IF ((hilfe1.stellen = 1) AND (hilfe1.zahl[1] = 0)) OR (hilfe1.stellen = 0)
THEN
  ELSE                                       (* Ergebnis=0, weil X * 0 = 0 *)
    BEGIN
      i := 1;                                    (* i mit 1 initialisieren *)
      WHILE (i <= (hilfe1.stellen - 1)) DO           (* Hilfe 1 abarbeiten *)
        BEGIN
          wert := hilfe1.zahl[i];                         (* Wert = i.Zahl *)
          j := 1;                                (* j mit 1 initialisieren *)
          WHILE (j <= 16) DO                       (* alle Bits abarbeiten *)
            BEGIN
              IF (wert AND 1) > 0 THEN              (* Falls 1.Bit gesetzt *)
                BEGIN
                  AddCalcStr(ergebnis, hilfe2, hilfe);
                                           (* Ergebnis und Hilfe2 addieren *)
                  ergebnis := hilfe;              (* Ergebnis aus Addition *)
                END;
              wert := wert SHR 1;                            (* Wert DIV 2 *)
              Mul2CalcStr(hilfe2);                           (* Hilfe2 * 2 *)
              INC(j);                                    (* j um 1 erhöhen *)
            END;
          INC(i);                                        (* i um 1 erhöhen *)
        END;
      wert := hilfe1.zahl[hilfe1.stellen];      (* letzte Stelle behandeln *)
      WHILE wert > 0 DO                  (* Solange noch 1 Bit gesetzt ist *)
        BEGIN
          IF (wert AND 1) > 0 THEN              (* Falls Bit 1 gesetzt ist *)
            BEGIN
              AddCalcStr(ergebnis, hilfe2, hilfe);
                                           (* Ergebnis und Hilfe2 addieren *)
              ergebnis := hilfe;                  (* Ergebnis aus Addition *)
            END;
          wert := wert SHR 1;                                (* Wert DIV 2 *)
          Mul2CalcStr(hilfe2);                               (* Hilfe2 * 2 *)
        END;
    END;
END;

(* ----------------------------------------------------------------------- *)
(* DivCalcStr dividiert einen CalcString durch einen anderen               *)

FUNCTION DivCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr) :
BOOLEAN;
VAR hilfe       : CalcStr;                              (* HilfsCalcString *)

    hilfe1      : CalcStr;                              (* HilfsCalcString *)
    hilfe2      : CalcStr;                              (* HilfsCalcString *)
    EINS        : CalcStr;                 (* konstanter HilfsString für 1 *)
BEGIN
  IF ((zahl2.stellen = 1) AND (zahl2.zahl[1] = 0)) OR (zahl2.stellen = 0) THEN
    DivCalcStr := FALSE                  (* Division durch 0 nicht möglich *)
  ELSE
    BEGIN
      EINS := EMPTYCALCSTR;                         (* Eins initialisieren *)
      EINS.stellen := 1;                          (* Eins besitzt 1 Stelle *)
      EINS.zahl[1] := 1;                        (* diese wird mit 1 belegt *)
      ergebnis := EMPTYCALCSTR;                 (* Ergebnis initialisieren *)
      hilfe1 := zahl1;                     (* Hilfe1 wird Zahl1 zugewiesen *)
      hilfe2 := zahl2;                     (* Hilfe2 wird Zahl2 zugewiesen *)
      WHILE NOT (GreaterCalcStr(hilfe2, hilfe1)) DO
        Mul2CalcStr(hilfe2);
           (* schiebe hilfe2 solange nach links, bis dividiert werden kann *)
      WHILE NOT (EqualCalcStr(hilfe2, zahl2)) DO       (* Abbruchbedingung *)
        BEGIN
          Mul2CalcStr(ergebnis);          (* Ergebnis mit 2 multiplizieren *)
          Div2CalcStr(hilfe2);                (* Hilfe2 durch 2 dividieren *)
          IF NOT (GreaterCalcStr(hilfe2, hilfe1)) THEN
                                            (* falls hilfe2 nicht > hilfe1 *)
            BEGIN
              SubCalcStr(hilfe1, hilfe2, hilfe);        (* Hilfe1 - Hilfe2 *)
              hilfe1 := hilfe;             (* Hilfe1 wird Hilfe zugewiesen *)
              AddCalcStr(ergebnis, EINS, hilfe);(* zum Ergebnis 1 addieren *)
              ergebnis := hilfe;         (* Ergebnis wird hilfe zugewiesen *)
            END;
        END;
      DivCalcStr := TRUE;                          (* Division erfolgreich *)
    END;
END;

(* ----------------------------------------------------------------------- *)
(* ModCalcStr berechnet den Rest bei Division von Zahl1 durch Zahl2        *)

FUNCTION ModCalcStr(VAR zahl1, zahl2 : CalcStr; VAR ergebnis : CalcStr) :
BOOLEAN;
VAR hilfe       : CalcStr;                              (* HilfsCalcString *)
    hilfe1      : CalcStr;                              (* HilfsCalcString *)
    hilfe2      : CalcStr;                              (* HilfsCalcString *)
    EINS        : CalcStr;                 (* konstanter HilfsString für 1 *)
BEGIN
  IF ((zahl2.stellen = 1) AND (zahl2.zahl[1] = 0)) OR (zahl2.stellen = 0) THEN
    ModCalcStr := FALSE                  (* Division durch 0 nicht möglich *)
  ELSE
    BEGIN
      EINS := EMPTYCALCSTR;                         (* Eins initialisieren *)
      EINS.stellen := 1;                          (* Eins besitzt 1 Stelle *)
      EINS.zahl[1] := 1;                        (* diese wird mit 1 belegt *)
      ergebnis := EMPTYCALCSTR;                 (* Ergebnis initialisieren *)
      IF GreaterCalcStr(zahl2, zahl1) THEN          (* falls Zahl2 > Zahl1 *)
        ergebnis := zahl1                            (* Ergebnis ist Zahl1 *)
      ELSE
        BEGIN
          hilfe1 := zahl1;                 (* Hilfe1 wird Zahl1 zugewiesen *)
          hilfe2 := zahl2;                 (* Hilfe2 wird Zahl2 zugewiesen *)
          WHILE NOT (GreaterCalcStr(hilfe2, hilfe1)) DO
            Mul2CalcStr(hilfe2);
           (* schiebe hilfe2 solange nach links, bis dividiert werden kann *)
          WHILE NOT (EqualCalcStr(hilfe2, zahl2)) DO   (* Abbruchbedingung *)
            BEGIN
              Mul2CalcStr(ergebnis);      (* Ergebnis mit 2 multiplizieren *)
              Div2CalcStr(hilfe2);            (* Hilfe2 durch 2 dividieren *)
              IF NOT (GreaterCalcStr(hilfe2, hilfe1)) THEN
                                            (* falls hilfe2 nicht > hilfe1 *)
                BEGIN
                  SubCalcStr(hilfe1, hilfe2, hilfe);    (* Hilfe1 - Hilfe2 *)
                  hilfe1 := hilfe;         (* Hilfe1 wird Hilfe zugewiesen *)
                  AddCalcStr(ergebnis, EINS, hilfe);
                                                (* zum Ergebnis 1 addieren *)
                  ergebnis := hilfe;     (* Ergebnis wird hilfe zugewiesen *)
                END;
            END;
          ModCalcStr := TRUE;                      (* Division erfolgreich *)
        END;
    END;
END;

(* ----------------------------------------------------------------------- *)
(* ExptCalcStr berechnet Basis^Exponent                                    *)

PROCEDURE ExptCalcStr(VAR basis, exponent: CalcStr; VAR ergebnis : CalcStr);
VAR hilfe  : CalcStr;                                   (* HilfsCalcString *)
    hilfe1 : CalcStr;                                   (* HilfsCalcString *)
    i, j   : WORD;                                        (* Zählvariablen *)
    wert   : WORD;              (* Wert des Exponenten an der i.ten Stelle *)
BEGIN
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  ergebnis.stellen := 1;                     (* Ergebnis hat min. 1 Stelle *)
  ergebnis.zahl[1] := 1;                                  (* Ergebnis >= 1 *)
  IF ((exponent.stellen = 1) AND (exponent.zahl[1] = 0)) OR (exponent.stellen =
0) THEN
  ELSE                                     (* Exponent = 0 => Ergebnis = 1 *)
    BEGIN
      hilfe1 := basis;                     (* Hilfe1 wird Basis zugewiesen *)
      i := 1;                                (* i wird mit 1 initialisiert *)
      WHILE (i <= (exponent.stellen - 1)) DO      (* Exponenten abarbeiten *)
        BEGIN
          wert := exponent.zahl[i];          (* i.te Stelle des Exponenten *)
          INC(i);                                        (* i um 1 erhöhen *)
          j := 1;                            (* j wird mit 1 initialisiert *)
          WHILE (j <= 16) DO                       (* alle Bits abarbeiten *)
            BEGIN
              IF (wert AND 1) = 1 THEN         (* falls 1. Bit gesetzt ist *)
                MulCalcStr(ergebnis, hilfe1, ergebnis);
                                     (* Ergebnis mit Hilfe1 multiplizieren *)
              MulCalcStr(hilfe1, hilfe1, hilfe1);     (* Hilfe1 quadrieren *)
              wert := wert SHR 1;                            (* Wert DIV 2 *)
              INC(j);                                 (* 1 Bit weitergehen *)
            END;
        END;
      wert := exponent.zahl[exponent.stellen];  (* letzte Stelle behandeln *)
      WHILE (wert <> 0) DO                   (* solange noch 1 Bit gesetzt *)
        BEGIN
          IF (wert AND 1) = 1 THEN             (* falls 1. Bit gesetzt ist *)
            MulCalcStr(ergebnis, hilfe1, ergebnis);
                                     (* Ergebnis mit Hilfe1 multiplizieren *)
          MulCalcStr(hilfe1, hilfe1, hilfe1);         (* Hilfe1 quadrieren *)
          wert := wert SHR 1;                                (* Wert DIV 2 *)
        END;
    END;
END;

(* ----------------------------------------------------------------------- *)
(* RandomCalcStr liefert eine Zufallszahl < calcZahl                       *)

PROCEDURE RandomCalcStr(VAR calcZahl: CalcStr; VAR ergebnis : CalcStr);
VAR i : WORD;                                              (* Zählvariable *)
BEGIN
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  ergebnis.stellen := calcZahl.stellen; (* Annahme: Stellenzahl ist gleich *)
  FOR i := 1 TO (calcZahl.stellen - 1) DO
    ergebnis.zahl[i] := Random(65535);           (* zufällige Zahl < 65535 *)
  ergebnis.zahl[ergebnis.stellen] := Random(calcZahl.zahl[calcZahl.stellen]);
                              (* letzte Zahl muß kleiner Ausgangszahl sein *)
  WHILE (ergebnis.zahl[ergebnis.stellen] = 0) AND (ergebnis.stellen > 1) DO
    DEC(ergebnis.stellen);                  (* führende Nullen abschneiden *)
  IF ((ergebnis.stellen = 1) AND (ergebnis.zahl[1] = 0)) OR (ergebnis.stellen =
0) THEN
    BEGIN                                    (* Ergebnis darf nicht 0 sein *)
      ergebnis.stellen := 1;                              (* min. 1 Stelle *)
      ergebnis.zahl[1] := 1;                       (* diese mit 1 besetzen *)
    END;
END;

(* ----------------------------------------------------------------------- *)
(* MulModCalcStr multipliziert ein Zahl modulo modul                       *)

PROCEDURE MulModCalcStr(VAR zahl1, zahl2, modul : CalcStr; VAR ergebnis :
CalcStr);
VAR i, j   : WORD;                                        (* Zählvariablen *)
    wert   : WORD;                        (* Wert von Zahl an i.ter Stelle *)
    hilfe  : CalcStr;                                   (* HilfsCalcString *)
    hilfe1 : CalcStr;                                   (* HilfsCalcString *)
    hilfe2 : CalcStr;                                   (* HilfsCalcString *)
BEGIN
  IF LessCalcStr(zahl1, zahl2) THEN                 (* Falls Zahl1 < Zahl2 *)
    BEGIN
      ModCalcStr(zahl1, modul, hilfe1);       (* Divisionsrest Zahl1/Modul *)
      ModCalcStr(zahl2, modul, hilfe2);       (* Divisionsrest Zahl2/Modul *)
    END
  ELSE
    BEGIN
      ModCalcStr(zahl1, modul, hilfe2);       (* Divisionsrest Zahl1/Modul *)
      ModCalcStr(zahl2, modul, hilfe1);       (* Divisionsrest Zahl2/Modul *)
    END;
  ergebnis := EMPTYCALCSTR;           (* ErgebnisCalcString initialisieren *)
  IF ((hilfe1.stellen = 1) AND (hilfe1.zahl[1] = 0)) OR (hilfe1.stellen = 0)
THEN
                                             (* Hilfe1 muß ungleich 0 sein *)
  ELSE
    BEGIN
      i := 1;                                    (* i mit 1 initialisieren *)
      WHILE (i <= (hilfe1.stellen - 1)) DO
                                     (* alle Stellen von Hilfe1 abarbeiten *)
        BEGIN
          wert := hilfe1.zahl[i];              (* aktuellen Wert ermitteln *)
          j := 1;                                (* j mit 1 initialisieren *)
          WHILE (j <= 16) DO                       (* alle Bits abarbeiten *)
            BEGIN
              IF (wert AND 1) > 0 THEN          (* Falls Bit 1 gesetzt ist *)
                BEGIN
                  AddCalcStr(ergebnis, hilfe2, hilfe);
                                           (* Hilfe2 zum Ergebnis addieren *)
                  ergebnis := hilfe;          (* und dem Ergebnis zuweisen *)
                END;
              wert := wert SHR 1;               (* Wert durch 2 dividieren *)
              Mul2CalcStr(hilfe2);          (* Hilfe2 mit 2 multiplizieren *)
              INC(j);                                    (* j um 1 erhöhen *)
            END;
          INC(i);                                        (* i um 1 erhöhen *)
        END;
      wert := hilfe1.zahl[hilfe1.stellen];
                                        (* letzte Zahl gesondert behandeln *)
      WHILE (wert > 0) DO                  (* solange noch ein Bit gesetzt *)
        BEGIN
          IF (wert AND 1) > 0 THEN             (* Falls 1. Bit gesetzt ist *)
            BEGIN
              AddCalcStr(ergebnis, hilfe2, hilfe);
                                           (* Hilfe2 zum Ergebnis addieren *)
              ergebnis := hilfe;              (* und dem Ergebnis zuweisen *)
            END;
          wert := wert SHR 1;                   (* Wert durch 2 dividieren *)
          Mul2CalcStr(hilfe2);              (* Hilfe2 mit 2 multiplizieren *)
        END;
    END;
  hilfe1 := ergebnis;                   (* Hilfe1 wird Ergebnis zugewiesen *)
  ModCalcStr(hilfe1, modul, ergebnis);       (* Divisionsrest hilfe1/Modul *)
END;

(* ----------------------------------------------------------------------- *)
(* ExptModCalcStr berechnet basis^exponent MOD modul                       *)

PROCEDURE ExptModCalcStr(VAR basis, exponent, modul : CalcStr; VAR ergebnis :
CalcStr);
VAR i, j   : WORD;                                        (* Zählvariablen *)
    wert   : WORD;                        (* Wert von Zahl an i.ter Stelle *)
    hilfe  : CalcStr;                                   (* HilfsCalcString *)
    hilfe1 : CalcStr;                                   (* HilfsCalcString *)
BEGIN
  ergebnis := EMPTYCALCSTR;                     (* Ergebnis initialisieren *)
  ergebnis.stellen := 1;                 (* Ergebnis besitzt min. 1 Stelle *)
  ergebnis.zahl[1] := 1;                      (* Ergebnis hat mind. Wert 1 *)
  IF ((exponent.stellen = 1) AND (exponent.zahl[1] = 0)) OR (exponent.stellen =
0) THEN
                                            (* Exponent = 0 => Ergebnis = 1*)
  ELSE
    BEGIN
      ModCalcStr(basis, modul, hilfe1);       (* Divisionsrest Basis/Modul *)
      i := 1;                                    (* i mit 1 initialisieren *)
      WHILE (i <= (exponent.stellen - 1)) DO
        BEGIN
          wert := exponent.zahl[i];     (* Wert = i.te Stelle von Exponent *)
          j := 1;                                (* j mit 1 initialisieren *)
          WHILE (j <= 16) DO                       (* alle Bits abarbeiten *)
            BEGIN
              IF (wert AND 1) > 0 THEN          (* Falls Bit 1 gesetzt ist *)
                BEGIN
                  MulModCalcStr(ergebnis, hilfe1, modul, hilfe);
                                            (* Ergebnis * Hilfe1 MOD Modul *)
                  ergebnis := hilfe;          (* und dem Ergebnis zuweisen *)
                END;
              wert := wert SHR 1;               (* Wert durch 2 dividieren *)
              MulModCalcStr(hilfe1, hilfe1, modul, hilfe);
                                                (* Hilfe1*Hilfe1 MOD Modul *)
              hilfe1 := hilfe;               (* und wieder Hilfe1 zuweisen *)
              INC(j);                                    (* j um 1 erhöhen *)
            END;
          INC(i);                                        (* 1 um 1 erhöhen *)
        END;
      wert := exponent.zahl[exponent.stellen];
                                        (* letzte Zahl gesondert behandeln *)
      WHILE (wert > 0) DO                  (* solange noch ein Bit gesetzt *)
        BEGIN
          IF (wert AND 1) > 0 THEN             (* Falls 1. Bit gesetzt ist *)
            BEGIN
              MulModCalcStr(ergebnis, hilfe1, modul, hilfe);
                                              (* Hilfe1*Ergebnis MOD Modul *)
              ergebnis := hilfe;              (* und dem Ergebnis zuweisen *)
            END;
          wert := wert SHR 1;                   (* Wert durch 2 dividieren *)
          MulModCalcStr(hilfe1, hilfe1, modul, hilfe);
                                                (* Hilfe1*Hilfe1 MOD Modul *)
          hilfe1 := hilfe;                   (* und wieder hilfe1 zuweisen *)
        END;
    END;
END;

(* ----------------------------------------------------------------------- *)

BEGIN

  Randomize;                               (* Zufallsgenerator einschalten *)

  (* Initialiseren eines globalen Leerstrings *)
  WITH EMPTYCALCSTR DO                             (* Recordtyp abarbeiten *)
    BEGIN
      stellen := 0;                                         (* Länge ist 0 *)
      FOR i := 1 TO MAXCALCSTR DO zahl[i] := 0;     (* zahl initialisieren *)
    END;
  (* Ende der Initialisierung *)

END.
