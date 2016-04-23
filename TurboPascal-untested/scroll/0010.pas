{
> Last month this routine for scrolling text across the screen was
> posted in this echo.  It's a great routine but would the author of the
> routine please describe how to place the scrolling text on any of the
> 25 vertical lines, how to change the background color...the foreground
> color I found. Also, can this routine place the text between two
> points on the screen without writing over the extreme left and right
> sides?

This should be what you're looking for.  I sort exapnded on the
old code, but instead of using Mem for direct writes I set a
screen structure over the text screen instead...makes it easier
to understand.      }

PROGRAM NewScroll;
Uses Crt;

TYPE
  TCell = RECORD C: Char; A: Byte; END;
  TScreen = array[1..25, 1..80] of TCell;

CONST
  Row: byte = 15;
  Col1: byte = 10;
  Col2: byte = 70;
  Attr: byte = $4F; { bwhite / red }
  Txt: string = 'Hello world....         ';

VAR
  Scr: TScreen ABSOLUTE $B800:0;
  I, J: Byte;
BEGIN
  I := 1;
  REPEAT
    while (port[$3da] and 8) <> 0 do;  { wait retrace }
    while (port[$3da] and 8) = 0 do;
    FOR J := Col1 TO (Col2-1) DO
      Scr[Row, J] := Scr[Row, J+1];  { shift cell left }
    Scr[Row, Col2].C := Txt[I];      { add new cell }
    Scr[Row, Col2].A := Attr;
    I := 1 + (I MOD Length(Txt));
  UNTIL Keypressed;

END.

