(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0024.PAS
  Description: Another ANSI Driver
  Author: STEFAN XENOS
  Date: 11-21-93  09:24
*)

{
From: STEFAN XENOS
Subj: ANSI.PAS

Those routines have been posted several times, so here's some different code
which serves a similar purpose. I got it from the 1992 ZipNav CD, and
have done some slight debugging. Here it is: }

USES crt;
CONST
  FF = #12;
  ESC = #27;
VAR Ch : CHAR;
 C : CHAR;
 i , FGcolor, BGcolor, CursorX, CursorY : INTEGER;
        escape_mode, lightcolor : BOOLEAN;
        escape_number : BYTE;
        escape_register : ARRAY [1..50] OF BYTE;
        escape_str : STRING [80];

AnsiFile : TEXT;

(****************************************************************************)
(*                             PROCESS ESCAPE                               *)
(****************************************************************************)
PROCEDURE
      wrt ( c : CHAR );
   BEGIN

      CASE c OF
           FF :  CLRSCR;
          ELSE   WRITE (c);
      END;
   END;

 PROCEDURE
      set_graphics;
   VAR
      i     : INTEGER;
      FG, BG : INTEGER;
   BEGIN
      FG := FGcolor;
      BG := BGcolor;
      FOR i := 1 TO escape_number DO BEGIN
         CASE escape_register [i] OF
            0 : lightcolor := FALSE;
            1 : lightcolor := TRUE;
            5 : FG := FG + blink;
            7 : BEGIN
                   FG := BG;
                   BG := FG;
                END;
           30 : FG := black;
           31 : FG := red;
           32 : FG := green;
           33 : FG := brown;
           34 : FG := blue;
           35 : FG := magenta;
           36 : FG := cyan;
           37 : FG := white;
           40 : BG := black;
           41 : BG := red;
           42 : BG := green;
           43 : BG := yellow;
           44 : BG := blue;
           45 : BG := magenta;
           46 : BG := cyan;
           47 : BG := white;
         ELSE
            ;
         END;
      END;
      IF (lightcolor) AND (fg < 8) THEN
         fg := fg + 8;
      IF (lightcolor = FALSE) AND (fg > 7) THEN
         fg := fg - 8;
      TEXTCOLOR ( FG );
      TEXTBACKGROUND ( BG );
      escape_mode := FALSE;
   END;

   PROCEDURE MoveUp;
   BEGIN
     IF escape_register [1] < 1 THEN
        escape_register [1] := 1;
     GOTOXY (WHEREX, WHEREY - (Escape_Register [1]) );
   END;

   PROCEDURE MoveDown;
   BEGIN
     IF escape_register [1] < 1 THEN
        escape_register [1] := 1;
     GOTOXY (WHEREX, WHEREY + (Escape_Register [1]) );
   END;

   PROCEDURE MoveForeward;
   BEGIN
     IF escape_register [1] < 1 THEN
        escape_register [1] := 1;
     GOTOXY (WHEREX + (Escape_Register [1]), WHEREY);
   END;

   PROCEDURE MoveBackward;
   BEGIN
     IF escape_register [1] < 1 THEN
        escape_register [1] := 1;
     GOTOXY (WHEREX - (Escape_Register [1]), WHEREY);
   END;

   PROCEDURE SaveCursorPos;
   BEGIN
      CursorX := WHEREX;
      CursorY := WHEREY;
   END;

   PROCEDURE RestoreCursorPos;
   BEGIN
      GOTOXY (CursorX, CursorY);
   END;

   PROCEDURE addr_cursor;
   BEGIN
      CASE escape_number OF
         0 : BEGIN
                escape_register [1] := 1;
                escape_register [2] := 1;
             END;
         1 : escape_register [2] := 1;
      ELSE
         ;
      END;
      IF escape_register [1] = 25 THEN
         GOTOXY (escape_register [2], 24)
      ELSE
         GOTOXY (escape_register [2], escape_register [1]);
      escape_mode := FALSE;
   END;

   PROCEDURE clear_scr;
   BEGIN
      IF ( escape_number = 1 )  AND  ( escape_register [1] = 2 ) THEN
         CLRSCR;
      escape_mode := FALSE;
   END;

   PROCEDURE clear_line;
   BEGIN
      IF ( escape_number = 1 )  AND  ( escape_register [1] = 0 ) THEN
         CLREOL;
      escape_mode := FALSE;
   END;

   PROCEDURE process_escape ( c : CHAR );
   VAR
      i    : INTEGER;
      ch   : CHAR;
   BEGIN
      c := UPCASE (c);
      CASE c OF
          '['
             : EXIT;
         'F', 'H'
             : BEGIN
                  addr_cursor;
                  Escape_mode := FALSE;
                  EXIT;
               END;
         'J' : BEGIN
                  clear_scr;
                  Escape_mode := FALSE;
                  EXIT;
               END;

         'K' : BEGIN
                  clear_line;
                  Escape_mode := FALSE;
                  EXIT;
               END;
         'M' : BEGIN
                  set_graphics;
                  Escape_mode := FALSE;
                  EXIT;

               END;
         'S' : BEGIN
                 SaveCursorPos;
                  Escape_mode := FALSE;
                 EXIT;
               END;
         'U' : BEGIN
                 RestoreCursorPos;
                 Escape_Mode := FALSE;
                 EXIT;
               END;
         'A' : BEGIN
                 MoveUp;
                 Escape_mode := FALSE;
                 EXIT;
               END;
         'B' : BEGIN
                 MoveDown;
                 Escape_mode := FALSE;
                 EXIT;
               END;
         'C' : BEGIN
                MoveForeward;
                 Escape_mode := FALSE;
                EXIT;
               END;
         'D' : BEGIN
                MoveBackward;
                 Escape_mode := FALSE;
                EXIT;
               END;
      END;
      ch := UPCASE ( c );
      escape_str := escape_str + ch;
      IF ch IN [ 'A'..'G', 'L'..'P' ] THEN EXIT;
      IF ch IN [ '0'..'9' ] THEN BEGIN
         escape_register [escape_number] := (escape_register [escape_number] * 10) + ORD ( ch ) - ORD ( '0' );
         EXIT;
      END;
      CASE ch OF
         ';', ',' : BEGIN
                       escape_number := escape_number + 1;
                       escape_register [escape_number] := 0;
                    END;
         'T',  '#', '+', '-', '>', '<', '.'
                  : ;
      ELSE
         escape_mode := FALSE;
         FOR i := 1 TO LENGTH ( escape_str ) DO
            wrt ( escape_str [i] );
      END;
   END;
(**************************************************************************)
(*                             SCREEN HANDLER                             *)
(**************************************************************************)
   PROCEDURE scrwrite ( c : CHAR );
   VAR
      i  : INTEGER;
   BEGIN
      IF c = ESC THEN BEGIN
         IF escape_mode THEN BEGIN
            FOR i := 1 TO LENGTH ( escape_str ) DO
               wrt ( escape_str [i] );
         END;
         escape_str := '';
         escape_number := 1;
         escape_register [escape_number] := 0;
         escape_mode := TRUE;
      END
      ELSE
         IF escape_mode THEN
            process_escape (c)
         ELSE
            wrt ( c );
   END;
BEGIN
Escape_Str := '';
FGColor := White;BGColor := BLACK;
Escape_Mode := TRUE;
CLRSCR;
ASSIGN (AnsiFile, '\modem\host.ans');
RESET (AnsiFile);
WHILE NOT EOF (AnsiFile) DO BEGIN
  READ (AnsiFile, ch);
  DELAY (1);
  ScrWrite (Ch);
END;

END.

