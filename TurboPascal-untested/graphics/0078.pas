{

 SL> Does someone has a pascalsource for showing a PCX file with a resolution
 SL> of 640x400x256 /or a automatic build-in convertor who wil let the drawing

Sure thing, the following code will load PCX files with 256 colors and variable
height and width (it looks into the header):  (Sorry about the german comments,
but I've got no time to erase them right now :-(( ) }

UNIT uVESAPcx;                                { (c) 1993 by NEBULA-Software }
     { PCX-Darstellungsroutinen f. VESA     } { Olaf Bartelt & Oliver Carow }

INTERFACE                                     { Interface-Teil der Unit     }

{ ───────────────────────────────── Typen ───────────────────────────────── }
TYPE  pVESAPcx   = ^tVESAPcx;                 { Zeiger auf Objekt           }
      tVESAPcx   = OBJECT                     { Objekt für PCX-Dateien      }
                     PROCEDURE load(f : STRING; dx, dy : WORD);
                   END;

{ ──────────────────────────────── Variablen ────────────────────────────── }
VAR   vVESAPcx  : pVESAPcx;                   { Instanz des Objekts tPcx    }


IMPLEMENTATION                                { Implementation-Teil d. Unit }

USES uVesa;                                   { Einbinden der Units         }
{ CAN BE FOUND IN SWAG }

{ ──────────────────────────────── tVESAPcx ─────────────────────────────── }
PROCEDURE  tVESAPcx.load(f : STRING; dx, dy : WORD);
VAR q                          : FILE;
    b                          : ARRAY[0..2047] OF BYTE;
    anz, pos, c, w, h, e, pack : WORD;
    x, y                       : WORD;

LABEL ende_background;

BEGIN
  x := 0; y := 0;

  ASSIGN(q, f); {$I-} RESET(q, 1); {$I+}
  IF IORESULT <> 0 THEN
    GOTO ende_background;

  BLOCKREAD(q, b, 128, anz);
  IF (b[0] <> 10) OR (b[3] <> 8) THEN
  BEGIN
    CLOSE(q);
    EXIT;
  END;
  w := SUCC((b[9] - b[5]) SHL 8 + b[8] - b[4]);
  h := SUCC((b[11] - b[7]) SHL 8 + b[10] - b[6]);
  pack := 0; c := 0; e := y + h;
  REPEAT
    BLOCKREAD(q, b, 2048, anz);
    pos := 0;
    WHILE (pos < anz) AND (y < e) DO
    BEGIN
      IF pack <> 0 THEN
      BEGIN
        FOR c := c TO c + pack DO
          vVesa^.putpixel(x + c+dx, y+dy, b[pos]);
        pack := 0;
      END
      ELSE
        IF (b[pos] AND $C0) = $C0 THEN
          pack := b[pos] AND $3F
        ELSE
        BEGIN
          vVesa^.putpixel(x + c+dx, y+dy, b[pos]);
          INC(c);
        END;
      INC(pos);
      IF c = w THEN
      BEGIN
        c := 0;
        INC(y);
      END;
    END;
  UNTIL (anz = 0) OR (y = e);
  SEEK(q, FILESIZE(q) - 3 SHL 8 - 1);
  BLOCKREAD(q, b, 3 SHL 8 + 1);
  IF b[0] = 12 THEN
    FOR x := 1 TO 3 SHL 8 + 1 DO
      b[x] := b[x] SHR 2;
  CLOSE(q);

  ende_background:
END;


{ ────────────────────────────── Hauptprogramm ──────────────────────────── }
BEGIN
  NEW(vVESAPcx);
END.

Remember to put in *your* putpixel routines there!

scroll from top till bottom.(VGA/SVGAcompat./TPASCAL6.0)

