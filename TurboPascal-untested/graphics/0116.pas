{
 CF> I am working with VGA 320x200x256.  Can anyone please help
 CF> me with a good line routine and the PCX format?  I have
 CF> tryed both and things go bad.. If you have code laying
 CF> around it would help me a lot...  Thanks

}

PROCEDURE load_pcx(dx, dy : WORD; name : STRING);
VAR q                          : FILE;        { Quellendatei-Handle         }
    b                          : ARRAY[0..2047] OF BYTE;  { Puffer          }
    anz, pos, c, w, h, e, pack : WORD;        { diverse benötigte Variablen }
    x, y                       : WORD;        { für die PCX-Laderoutine     }

LABEL ende_background;                        { Sprungmarken definieren     }

BEGIN
  x := dx; y := dy;                           { Nullpunkt festsetzen        }

  ASSIGN(q, name); {$I-} RESET(q, 1); {$I+}   { Quellendatei öffnen         }
  IF IORESULT <> 0 THEN                       { Fehler beim Öffnen?         }
    GOTO ende_background;                     { Ja: zum Ende springen       }

  BLOCKREAD(q, b, 128, anz);                  { Header einlesen             }

  IF (b[0] <> 10) OR (b[3] <> 8) THEN         { wirklich ein PCX-File?      }
  BEGIN
    CLOSE(q);                                 { Nein: Datei schließen und   }
    GOTO ende_background;                     {       zum Ende springen     }
  END;

  w := SUCC((b[9] - b[5]) SHL 8 + b[8] - b[4]);  { Breite auslesen          }
  h := SUCC((b[11] - b[7]) SHL 8 + b[10] - b[6]);  { Höhe auslesen          }

  pack := 0; c := 0; e := y + h;
  REPEAT
    BLOCKREAD(q, b, 2048, anz);

    pos := 0;
    WHILE (pos < anz) AND (y < e) DO
    BEGIN
      IF pack <> 0 THEN
      BEGIN
        FOR c := c TO c + pack DO
          MEM[SEGA000:y*320+(x+c)] := b[pos];
        pack := 0;
      END
      ELSE
        IF (b[pos] AND $C0) = $C0 THEN
          pack := b[pos] AND $3F
        ELSE
        BEGIN
          MEM[SEGA000:y*320+(x+c)] := b[pos];
          INC(c);
        END;

      INC(pos);
      IF c = w THEN                           { letzte Spalte erreicht?     }
      BEGIN
        c := 0;                               { Ja: Spalte auf 0 setzen und }
        INC(y);                               {     in die nächste Zeile    }
      END;
    END;
  UNTIL (anz = 0) OR (y = e);

  SEEK(q, FILESIZE(q) - 3 SHL 8 - 1);
  BLOCKREAD(q, b, 3 SHL 8 + 1);

  IF b[0] = 12 THEN
    FOR x := 1 TO 3 SHL 8 + 1 DO
      b[x] := b[x] SHR 2;

  PORT[$3C8] := 0;

  FOR x := 0 TO 255 DO
  BEGIN
    PORT[$3C9] := b[x*3+1];
    PORT[$3C9] := b[x*3+2];
    PORT[$3C9] := b[x*3+3];
  END;

  CLOSE(q);

ende_background:
END;

BEGIN
    Load_Pcx(1,1,'c:\lpexface.pcx');
END.