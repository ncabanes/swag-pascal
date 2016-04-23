
{ RIPSEE.PAS version 1.0 views a RIP 1.54 in EGA
Public domain by Jason Dyer, use is free, but it would be nice if you gave
me credit. Netmail at jason.dyer@solitud.fidonet.org on Internet or 1:300/23
on Fidonet. If anyone can tell me the REAL way to scroll the graphic part of
the screen please tell me.
This program assumes you have TP/BP 7.0+ because of the new fonts it adds.
If you are using anything less you will have to add the new fonts manually.
Also, the icon format is different...the "trash byte" isn't used in 6.0.
A few things are missing, like mouse buttons and the text window...expect
them in a later version. }

PROGRAM RipSee;

USES Crt, Dos, Graph;

CONST Place : ARRAY [1..5] OF LONGINT = (1, 36, 1296, 46656, 1679616);
      Seq = ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ');

VAR ErrorCode : INTEGER;
  GrDriver, GrMode : INTEGER;
  f : TEXT;
  SSS : STRING;
  ccol : INTEGER;
  Ch : CHAR;
  Clipboard : POINTER;
  LLL : INTEGER;
  command : STRING;
  RipLine, bslash : BOOLEAN;

FUNCTION FileExists (zzz : STRING) : BOOLEAN;
VAR DoCheck : SearchRec;
BEGIN
  FINDFIRST (zzz, AnyFile, DoCheck);
  IF DosError = 0 THEN FileExists := TRUE ELSE FileExists := FALSE;
END;

PROCEDURE WriteString (SSS : STRING; CP : INTEGER);
VAR Prloop : INTEGER;
    Regs : REGISTERS;
BEGIN
  regs.ah := $0E;
  regs.bh := 0;
  regs.bl := cp;
  FOR PrLoop := 1 TO LENGTH (SSS) DO BEGIN
    Regs.Al := ORD (SSS [PrLoop]);
    INTR ($10, Regs);
  END;
END;

FUNCTION Convert (SS : STRING) : LONGINT;
VAR PrLoop, Counter : INTEGER;
    CA, Tag : LONGINT;
BEGIN
  IF LENGTH (ss) = 1 THEN ss := '0' + ss;
  Counter := 0; CA := 0;
  FOR PrLoop := LENGTH (SS) DOWNTO 1 DO BEGIN
    Counter := Counter + 1;
    Tag := POS (SS [PrLoop], Seq) - 1;
    CA := CA + (Tag * Place [Counter]);
  END;
  Convert := CA;
END;

PROCEDURE DrawBezierCurve (px1, py1, px2, py2, px3, py3, px4, py4, count : INTEGER);
FUNCTION pow (x : REAL; y : WORD) : REAL;
VAR
  nt     : WORD;
  result : REAL;
BEGIN
 result := 1;
 FOR nt := 1 TO y DO
     result := result * x;
 pow := result;
END;

PROCEDURE Bezier (t : REAL; VAR x, y : INTEGER);
BEGIN
 x := TRUNC (pow (1 - t, 3) * px1 + 3 * t * pow (1 - t, 2) * px2 +
                3 * t * t * (1 - t) * px3 + pow (t, 3) * px4);
 y := TRUNC (pow (1 - t, 3) * py1 + 3 * t * pow (1 - t, 2) * py2 +
                3 * t * t * (1 - t) * py3 + pow (t, 3) * py4);
END;
VAR
 resolution, t : REAL;
 xc, yc       : INTEGER;
BEGIN
  IF count = 0 THEN EXIT;
  resolution := 1 / count;
  MOVETO (px1, py1);
  t := 0;
  WHILE t < 1 DO BEGIN
    Bezier (t, xc, yc);
    LINETO (xc, yc);
    t := t + resolution;
  END;
  LINETO (px4, py4);
END;

PROCEDURE Scrollgraph (x1, y1, x2, y2, dest : INTEGER);
VAR PP : POINTER;
BEGIN
  IF x1 MOD 8 <> 0 THEN x1 := x1 DIV 8;
  IF x2 MOD 8 <> 0 THEN x2 := (x2 + 8) DIV 8;
  GETMEM (pp, IMAGESIZE (x1, y1, x2, y2) );
  GETIMAGE (x1, y1, x2, y2, pp^);
  PUTIMAGE (x1, dest, pp^, 0);
  DISPOSE (pp);
END;

PROCEDURE ResetWindows;
BEGIN
  SETVIEWPORT (0, 0, GETMAXX, GETMAXY, ClipOn);
  CLEARDEVICE; IF clipboard <> NIL THEN DISPOSE (clipboard);
  clipboard := NIL;
END;

PROCEDURE usersetf;
VAR ii, jj : INTEGER;
    zz : FillPatternType;
BEGIN
  jj := 0;
  FOR ii := 1 TO 8 DO BEGIN
    jj := jj + 2;
    zz [ii] := Convert (COPY (command, jj, 2) );
  END;
  SETFILLPATTERN (zz, Convert (COPY (command, 18, 2) ) );
END;

PROCEDURE DPoly (fillit, ifpoly : BOOLEAN; np : INTEGER);
VAR ii, zz, yy : INTEGER;
    poly : ARRAY [1..200] OF PointType;
BEGIN
  ii := 4;
  FOR zz := 1 TO np DO BEGIN
    poly [zz].x := Convert (COPY (command, ii, 2) );
    poly [zz].y := Convert (COPY (command, ii + 2, 2) );
    ii := ii + 4;
  END; IF ifpoly THEN BEGIN
    poly [np + 1] := poly [1];
    IF NOT fillit THEN DRAWPOLY (np + 1, poly) ELSE FILLPOLY (np + 1, poly);
  END ELSE IF NOT fillit THEN DRAWPOLY (np, poly) ELSE FILLPOLY (np, poly);
END;

PROCEDURE toclip (x1, y1, x2, y2 : INTEGER);
BEGIN
  IF clipboard <> NIL THEN DISPOSE (clipboard);
  GETMEM (clipboard, IMAGESIZE (x1, y1, x2, y2) );
  GETIMAGE (x1, y1, x2, y2, ClipBoard^);
END;

PROCEDURE LoadIcon (x, y, mode, cboard : INTEGER; fname : STRING);
VAR fi : FILE;
    P : POINTER;
    Z : LONGINT;
    tt : TextSettingsType;
    cc : WORD;
BEGIN
  IF NOT fileexists (fname) THEN BEGIN
    IF cboard = 1 THEN clipboard := NIL;
    GETTEXTSETTINGS (tt); cc := GETCOLOR;
    SETTEXTSTYLE (DefaultFont, HorizDir, 1); SETCOLOR (15);
    OUTTEXTXY (x, y, Fname);
    OUTTEXTXY (x, y + TEXTHEIGHT (Fname), 'not found');
    SETCOLOR (cc); SETTEXTSTYLE (tt.font, tt.direction, tt.charsize);
  END ELSE BEGIN
    ASSIGN (fi, fname); NEW (P);
    RESET (fi);
    z := FILESIZE (fi);
    GETMEM (P, FILESIZE (fi) );
    BLOCKREAD (fi, P^, FILESIZE (fi) );
    CLOSE (fi);
    IF cboard = 1 THEN clipboard := p;
    PUTIMAGE (x, y, p^, mode);
    DISPOSE (p);
  END;
END;

PROCEDURE allpalette;
VAR Pal : PaletteType;
    ii, jj : INTEGER;
BEGIN
  Pal.Size := 16;
  jj := 0;
  FOR ii := 1 TO 16 DO BEGIN
    jj := jj + 2;
    Pal.Colors [ii - 1] := Convert (COPY (command, jj, 2) );
  END;
  SETALLPALETTE (Pal);
END;

PROCEDURE ParseCommand (command : STRING);
BEGIN
  IF command = '*' THEN resetwindows;
  IF command [1] = 'W' THEN SetWriteMode (Convert (COPY (command, 2, 2) ) );
  IF command [1] = 'S' THEN SETFILLSTYLE (Convert (COPY (command, 2, 2) ),
                                      Convert (COPY (command, 4, 2) ) );
  IF command [1] = 'E' THEN CLEARVIEWPORT;
  IF command [1] = 'v' THEN SETVIEWPORT (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ), ClipOn);
  IF command [1] = 'c' THEN IF LENGTH (command) = 2 THEN
    BEGIN ccol := (POS (command [2], Seq) - 1); SETCOLOR (ccol); END
    ELSE BEGIN ccol := (Convert (COPY (command, 2, 2) ) ); SETCOLOR (ccol); END;
  IF command [1] = 'Y' THEN SETTEXTSTYLE (Convert (COPY (command, 2, 2) ),
                                      Convert (COPY (command, 4, 2) ),
                                      Convert (COPY (command, 6, 2) ) );
  IF command [1] = 's' THEN usersetf;
  IF command [1] = 'Q' THEN allpalette;
  IF command [1] = '@' THEN OUTTEXTXY (Convert (COPY (command, 2, 2) ),
                                   Convert (COPY (command, 4, 2) ),
                                   COPY (command, 6, LENGTH (command) - 5) );
  IF command [1] = 'F' THEN FLOODFILL (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ) );
  IF command [1] = 'C' THEN CIRCLE (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ) );
  IF command [1] = 'B' THEN BAR (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ) );
  IF command [1] = 'A' THEN ARC (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ),
                          Convert (COPY (command, 10, 2) ) );
  IF command [1] = 'I' THEN PIESLICE (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ),
                          Convert (COPY (command, 10, 2) ) );
  IF command [1] = 'i' THEN Sector (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ),
                          Convert (COPY (command, 10, 2) ),
                          Convert (COPY (command, 12, 2) ) );
  IF command [1] = 'L' THEN LINE (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ) );
  IF command [1] = 'R' THEN RECTANGLE (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ) );
  IF command [1] = 'o' THEN FillEllipse (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ) );
  IF (command [1] = 'O') OR (command [1] = 'V') THEN
                          ELLIPSE (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ),
                          Convert (COPY (command, 10, 2) ),
                          Convert (COPY (command, 12, 2) ) );
  IF command [1] = 'P' THEN Dpoly (FALSE, TRUE, Convert (COPY (command, 2, 2) ) );
  IF command [1] = 'p' THEN Dpoly (TRUE, TRUE, Convert (COPY (command, 2, 2) ) );
  IF command [1] = 'X' THEN PUTPIXEL (Convert (COPY (command, 2, 2) ),
                                  Convert (COPY (command, 4, 2) ), ccol);
  IF command [1] = 'a' THEN SETPALETTE (Convert (COPY (command, 2, 2) ),
                                    Convert (COPY (command, 4, 2) ) );
  IF command [1] = '=' THEN SETLINESTYLE (Convert (COPY (command, 2, 2) ),
                                      Convert (COPY (command, 4, 4) ),
                                      Convert (COPY (command, 8, 2) ) );
  IF command [1] = 'l' THEN Dpoly (FALSE, FALSE, Convert (COPY (command, 2, 2) ) );
  IF command [1] = 'Z' THEN DrawBezierCurve (Convert (COPY (command, 2, 2) ),
                          Convert (COPY (command, 4, 2) ),
                          Convert (COPY (command, 6, 2) ),
                          Convert (COPY (command, 8, 2) ),
                          Convert (COPY (command, 10, 2) ),
                          Convert (COPY (command, 12, 2) ),
                          Convert (COPY (command, 14, 2) ),
                          Convert (COPY (command, 16, 2) ),
                          Convert (COPY (command, 18, 2) ) );
  IF command [1] = '1' THEN BEGIN {level one commands}
    IF command [2] = 'C' THEN Toclip (Convert (COPY (command, 3, 2) ),
                                  Convert (COPY (command, 5, 2) ),
                                  Convert (COPY (command, 7, 2) ),
                                  Convert (COPY (command, 9, 2) ) );
    IF (command [2] = 'P') AND (Clipboard <> NIL)
                               THEN PUTIMAGE (Convert (COPY (command, 3, 2) ),
                                    Convert (COPY (command, 5, 2) ),
                                    Clipboard^,
                                    Convert (COPY (command, 7, 2) ) );
    IF command [2] = 'I' THEN LoadIcon (Convert (COPY (command, 3, 2) ),
                                    Convert (COPY (command, 5, 2) ),
                                    Convert (COPY (command, 7, 2) ),
                                    Convert (COPY (command, 9, 1) ),
                                    COPY (command, 12, LENGTH (command) - 11) );
    IF command [2] = 'G' THEN Scrollgraph (Convert (COPY (command, 3, 2) ),
                                       Convert (COPY (command, 5, 2) ),
                                       Convert (COPY (command, 7, 2) ),
                                       Convert (COPY (command, 9, 2) ),
                                       Convert (COPY (command, 13, 2) ) );
  END;
END;

PROCEDURE Init;
VAR FName : STRING;
BEGIN
  clipboard := NIL;
  DETECTGRAPH (GrDriver, Grmode);
  IF GrDriver < 3 THEN BEGIN
    WRITELN ('EGA not detected!');
    HALT (1);
  END; GrMode := vgahi; Grdriver := vga;
  INITGRAPH (GrDriver, GrMode, '\turbo\tp');  { The address of your BGI files }
  ErrorCode := GRAPHRESULT;
  IF ErrorCode <> grOK THEN
  BEGIN
    WRITELN ('Graphics error:');
    WRITELN (GraphErrorMsg (ErrorCode) );
    WRITELN ('Program aborted...');
    HALT (1);
  END;
  Fname := PARAMSTR (1);
  IF POS ('.', Fname) = 0 THEN Fname := Fname + '.RIP';
  IF (NOT FileExists (Fname) ) OR (Fname = '.RIP') THEN BEGIN
    WRITELN ('File not found!');
    HALT (1);
  END;
  CLEARDEVICE; LLL := 0; command := ''; bslash := FALSE;
  ASSIGN (f, Fname); ripline := FALSE; RESET (f);
END;

BEGIN
  Init;
  REPEAT
    READ (f, Ch);
    IF (ORD (ch) = 13) OR (ORD (ch) = 10) THEN BEGIN
      IF bslash = TRUE THEN BEGIN READ (f, ch); bslash := FALSE;
      END ELSE BEGIN
        LLL := 0; READ (f, ch);
        IF ripline = TRUE THEN ripline := FALSE ELSE
          WriteString (ch, 15);
      END;
    END ELSE BEGIN
      LLL := LLL + 1;
      IF (LLL = 1) AND (Ch = '!') THEN ripline := TRUE ELSE BEGIN
        IF ripline THEN BEGIN
          CASE ch OF
          '|' : BEGIN
            IF bslash THEN BEGIN command := command + ch; bslash := FALSE; END ELSE
              BEGIN
                IF command <> '' THEN ParseCommand (command);
                command := '';
              END;
          END;
          '\' : BEGIN
            IF bslash THEN BEGIN command := command + ch; bslash := FALSE; END ELSE
              bslash := TRUE;
          END;
          ELSE command := command + ch;
          END;
        END ELSE BEGIN
          WriteString (ch, 15);
        END;
      END;
    END;
  UNTIL EOF (f);
  CLOSE (f);
  IF command <> '' THEN ParseCommand (command);
  Ch := READKEY;
  CLOSEGRAPH;
END.
