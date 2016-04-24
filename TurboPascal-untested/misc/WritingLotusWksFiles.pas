(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0143.PAS
  Description: Writing Lotus .WKS Files
  Author: HARTKAMP@MAIL.RZ.UNI-DUESSELDORF.DE
  Date: 05-26-95  23:19
*)

{
From: <hartkamp@mail.rz.uni-duesseldorf.de>

Might be someone is interested in the code below for writing
.WKS-files.

This special portion of code works with the TOPAZ-toolbox, but you
could use your own access to your data just the same. (Sorry for the
German Identfiers, hope anyone will grasp the contents, otherwise take
a dictionary!)
}

PROCEDURE LotusExport(DBFFile, OutFName : PathStr);
CONST StartSatz     : ARRAY[1..6] OF BYTE = (0,0,2,0,4,4);
      EndeSatz      : ARRAY[1..5] OF BYTE = (1,0,0,0,26);

TYPE  BereichsType  = RECORD
                         Typ, Laenge,
                         VonSpalte, VonZeile,
                         BisSpalte, BisZeile  : INTEGER;
                      END;

      BreitenType   = RECORD
                         Typ, Laenge, Spalte : INTEGER;
                         Breite              : BYTE;
                      END;

      ZahlenType    = RECORD
                         Typ, Laenge    : INTEGER;
                         Format         : BYTE;
                         Spalte, Zeile  : INTEGER;
                         Wert           : DOUBLE; { ONLY DOUBLE WILL DO!!!!!!!!!}
                      END;

      StringType    = RECORD
                         Typ, Laenge    : INTEGER;
                         Format         : BYTE;
                         Spalte, Zeile  : INTEGER;
                         Position       : CHAR;
                         Inhalt         : ARRAY[1..256] OF CHAR;
                      END;

VAR Bereich      : BereichsType;
    Breite       : BreitenType;
    Zahl         : ZahlenType;
    ZKette       : StringType;
    FBez         : StringType;
    RecordNumber : INTEGER;
    RNum         : REAL;
    INum         : INTEGER;
    L            : BOOLEAN;
    h,i,j        : BYTE;
    Zkt          : STRING;
    FName        : STRING;
    OutFile      : FILE;

BEGIN
  SELECT(0);
  USE(DBFFILE, NIL, 0);
  Bereich.Typ         := 6;
  Bereich.Laenge      := 8;
  Bereich.VonSpalte   := 0;
  Bereich.VonZeile    := 0;

  Breite.Typ          := 8;
  Breite.Laenge       := 3;

  Zahl.Typ            := 14;
  Zahl.Laenge         := 13;

  ZKette.Typ          := 15;
  ZKette.Format       := 255;
  ZKette.Position     := CHR(39);

  FBez.Typ            := 15;
  FBez.Laenge         := 17;
  FBez.Format         := 255;
  FBez.Zeile          := 0;
  FBez.Position       := CHR(39);

  IF RecCount > MaxLongInt THEN EXIT;
  Assign(OutFile,OutFName);
  ReWrite(OutFile,1);
  GoTop;
  RecordNumber := 1;
  BlockWrite(OutFile,StartSatz,6);
  Bereich.BisSpalte := FieldCount;
  Bereich.BisZeile  := RecCount;
  BlockWrite(OutFile,Bereich,12);
  FOR i := 1 TO FieldCount DO
    IF FieldType(i) <> 'M' THEN
    BEGIN
      j := FieldLen(i);
      Breite.Spalte := pred(i);
      IF j < 255 THEN Breite.Breite := succ(j)
                 ELSE Breite.Breite := j;
      BlockWrite(OutFile,Breite,7);
    END;
  FOR i := 1 TO FieldCount DO
    IF FieldType(i) <> 'M' THEN
    BEGIN
      FBez.Spalte := pred(i);
      FName := Field(i)+'               ';
      move(FName[1],FBez.Inhalt[1],10);
      FBez.Inhalt[11] := CHR(0);
      BlockWrite(OutFile,FBez,21);
    END;
  REPEAT
    Go(RecordNumber);
    FOR i := 1 TO FieldCount DO BEGIN
      CASE FieldType(i) OF
        'F','N' : BEGIN
                    Zahl.Format := FieldDec(i);
                    Zahl.Spalte := PRED(i);
                    Zahl.Zeile  := RecordNumber;
                    IF FieldDec(i) > 0
                    THEN BEGIN
                       move(FieldAddress(i)^,RNum,6);
                       Zahl.Wert := RNum;
                    END
                    ELSE BEGIN
                       move(FieldAddress(i)^,INum,4);
                       Zahl.Wert := INum;
                    END;
                    BlockWrite(OutFile,Zahl,17);
                  END;
            'C' : BEGIN
                    move(FieldAddress(i)^,Zkt[0],succ(FieldLen(i)));
                    Zkt := Zkt+#0;
                    ZKette.Laenge := Length(Zkt)+6;
                    ZKette.Spalte := PRED(i);
                    ZKette.Zeile  := RecordNumber;
                    move(Zkt[1],ZKette.Inhalt,Length(Zkt));
                    BlockWrite(OutFile,ZKette,ZKette.Laenge+4);
                  END;
            'D' : BEGIN
                    move(FieldAddress(i)^,Zkt[0],succ(FieldLen(i)));
                    IF Zkt[1] = ' ' THEN Zkt := 'keine Angabe';
                    Zkt := Zkt+#0;
                    ZKette.Laenge := Length(Zkt)+6;
                    ZKette.Spalte := PRED(i);
                    ZKette.Zeile  := RecordNumber;
                    move(Zkt[1],ZKette.Inhalt,Length(Zkt));
                    BlockWrite(OutFile,ZKette,ZKette.Laenge+4);
                  END;
            'L' : BEGIN
                    move(FieldAddress(i)^,L,1);
                    IF L THEN Zkt := 'Ja  ' ELSE Zkt := 'Nein';
                    Zkt := Zkt+#0;
                    ZKette.Laenge := Length(Zkt)+6;
                    ZKette.Spalte := pred(i);
                    ZKette.Zeile  := RecordNumber;
                    move(Zkt[1],ZKette.Inhalt,Length(Zkt));
                    BlockWrite(OutFile,ZKette,ZKette.Laenge+4);
                  END;
            'M' : ;
            ELSE BEGIN END;
      END;
    END;
    At(20, 13, LzS(RecordNumber,0)+' Datensätze kopiert...');
    Inc(RecordNumber);
  UNTIL RecordNumber > RecCount;
  BlockWrite(OutFile,EndeSatz,5);
  Close(OutFile);
  USE('', NIL, 0);
END;

PROCEDURE WKSExport;
VAR  oldSelect  : BYTE;
     DatVar     : PathStr;
     WKSVar     : PathStr;
     d          : DirStr;
     n          : NameStr;
     e          : ExtStr;

BEGIN
  DatVar := '';
  SelectFile('*.DBF','dBase-Datei wählen',true);
  FSplit(DatVar, d, n, e);
  WKSVar := d+n+'.WKS';
  PushWindow(16, 11, 60, 18);
  Box(16, 11, 56, 15, DoubleLine + Shadow, '');
  LotusExport(DatVar, WKSVar);
  PopWindow;
  PopUp('Die Tabellendatei ' + FileBase(DatVar) +
        '.WKS'+#13+'  wurde im aktuellen Verzeichnis  '+#13+
        'angelegt...', 'I n f o');
END;


