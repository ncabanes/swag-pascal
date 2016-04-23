{
 Well, this was NOT written by me, but the author is darn cool. I have a
 question for you.. I'm trying to make a *simple* SB16 DMA player, using those
 darned end-transfer interrupts. I am pretty good in TP, but all the info I've
 recieved about this has been too varied. People also like to use those crappy
 drivers. Any advice? Anyways, here's a program for ya..
                                -Jason Randall-
}

USES crt,dos;

Label Jm1;

CONST
  FF = #12;
  ESC = #27;

type
    rgbtype = record
              red,green,blue:byte;
    end;
    rgbarray=array [0..255] of rgbtype;

var
   USERFILE:String;
   InFile :File of Char;
   XX:INTEGER;
   rgbpal,fadepal:rgbarray;
   ii:word;
   c:char;
   count: Byte;
   Ch : CHAR;
   i , FGcolor, BGcolor, CursorX, CursorY : INTEGER;
        escape_mode, lightcolor : BOOLEAN;
        escape_number : BYTE;
        escape_register : ARRAY [1..50] OF BYTE;
        escape_str : STRING [80];

AnsiFile : TEXT;

(* FADES ROUTINES *)

procedure setcolor(col,r,g,b:byte);
begin
     port[$3c8]:=col;
     port[$3c9]:=r;
     port[$3c9]:=g;
     port[$3c9]:=b;
end;

procedure getcolor(col:byte;var r,g,b:byte);
begin
     port[$3c7]:=col;
     r:=port[$3c9];
     g:=port[$3c9];
     b:=port[$3c9];
end;

procedure fadein(var fadepal : rgbarray; col1, col2 ,dly: byte);
var
   lcv,
   lcv2 : integer;
   tpal : rgbarray;
begin
     for lcv := col1 to col2 do
     begin
          TPal[lcv].red   := 0;
          TPal[lcv].green := 0;
          TPal[lcv].blue  := 0;
     end;
     for lcv := 0 to 63 do
     begin
          for lcv2:=col1 to col2 do
          begin
               if fadepal[lcv2].red > TPal[lcv2].red then
                  TPal[lcv2].red := TPal[lcv2].red + 1;
               if fadepal[lcv2].green > TPal[lcv2].green then
                  TPal[lcv2].green := TPal[lcv2].green + 1;
               if fadepal[lcv2].blue > TPal[lcv2].blue then
                  TPal[lcv2].blue := TPal[lcv2].blue+1;
               setcolor(lcv2, TPal[lcv2].red, TPal[lcv2].green,
TPal[lcv2].blue);
          end;
          delay(dly);
     end;
end;

procedure fadeout(var fadepal : rgbarray; col1, col2 ,dly: byte);
var
   lcv,
   lcv2 : integer;
   TPal : rgbarray;
begin
     for lcv := col1 to col2 do
     begin
          TPal[lcv].red   := 0;
          TPal[lcv].green := 0;
          TPal[lcv].blue  := 0;
     end;
     for lcv := 0 to 63 do
     begin
          for lcv2 := col1 to col2 do
          begin
               if fadepal[lcv2].red > TPal[lcv2].red then
                  fadepal[lcv2].red := fadepal[lcv2].red - 1;
               if fadepal[lcv2].green > TPal[lcv2].green then
                  fadepal[lcv2].green := fadepal[lcv2].green - 1;
               if fadepal[lcv2].blue > TPal[lcv2].blue then
                  fadepal[lcv2].blue := fadepal[lcv2].blue - 1;
               setcolor(lcv2, fadepal[lcv2].red, fadepal[lcv2].green,
fadepal[lcv2].blue);
          end;
          delay(dly);
     end;
end;



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
         escape_register [escape_number] := (escape_register [escape_number] *
10) + ORD ( ch ) - ORD ( '0' );
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

Procedure Set50Lines;
Begin
Asm
  mov ax, $1202
  mov bl, $30
  int $10     {set 400 scan lines}
  mov ax, 3
  int $10     {set Text mode}
  mov ax, $1112
  mov bl, 0
  int $10     {load 8x8 font to page 0 block}
end;
end;

BEGIN
   for II:=0 to 255 do
   getcolor(II,fadepal[II].red,fadepal[II].green,fadepal[II].blue);
   rgbpal:=fadepal;
   fadeout(fadepal,0,127,0);
   fadepal:=rgbpal;
   ClrScr;
   fadein(fadepal,0,127,10);
Write ('Do you want 50 lines mode?');
ch:=Readkey;
c := UPCASE (ch);
      CASE c OF
         'N'
             : goto JM1;
         'Y'
             : BEGIN
                  asm;  Mov  AH,00;  Mov  AL,$3;  Int  10h;  End;
                  Set50Lines;
                  clrScr;
                  Set50Lines;
               END;
     End;

Jm1:
USERFILE:=PARAMSTR(1); {('Test.Ans');}
Escape_Str := '';
FGColor := White;BGColor := BLACK;
Escape_Mode := TRUE;
CLRSCR;
ASSIGN (AnsiFile, USERFILE);
RESET (AnsiFile);
WHILE NOT EOF (AnsiFile) DO
BEGIN
  READ (AnsiFile, ch);
  DELAY (0);
  ScrWrite (Ch);
END;

END.
