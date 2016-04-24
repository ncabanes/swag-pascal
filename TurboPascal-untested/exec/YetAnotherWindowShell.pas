(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0017.PAS
  Description: Yet Another Window Shell
  Author: TOM CARROLL
  Date: 01-27-94  12:24
*)

{
-> I seen some code posted here a few weeks ago. I meant to save it,
-> but didn't.  The code creates a windowed DOS shell.  I would like
-> to simply run a .BAT installation file in a window from my pascal
-> program.

Here's some code that I posted.  Maybe this is what you were talking
about:
}

(* Written by Tom Carroll, Nov 24, 1993.

   Adapted from the example code posted by Kelly Small in the FidoNet
   Pascal echo 11/19/93.

   Released to the Public Domain 11/24/93.

   Please give credit where credit is due

   This unit will execute a program within a text window
   and all program scrolling will be maintained within
   the window.

   11-24-93 - Initial release /twc/
   11-29-93 - Added code to allow for multiple border styles,
              color usage, window titles, and screen save/restore
              under the window. /twc/

   FUTURE PLANS:  To add a check for the video mode and adjust the
                  window boundary checking accordingly.
*)

UNIT ExecTWin;

INTERFACE

FUNCTION ExecWin(ProgName, Params, Title : STRING;
                 LeftCol, TopLine, RightCol, BottomLine,
                 ForeColor, BackColor, ForeBorder, BackBorder,
                 Border, ForeTitle, BackTitle : WORD) : WORD;

IMPLEMENTATION

USES
   Dos,
   Crt,
   ScrnCopy;

VAR
   OldIntVect : POINTER;

{$F+}
PROCEDURE Int29Handler(AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD); INTERRUPT;

VAR
   Dummy : BYTE;

BEGIN
   Write(Chr(Lo(AX)));         {write each character to screen}
   Asm Sti; END;
END;
{$F-}

PROCEDURE HookInt29;

BEGIN
   GetIntVec($29, OldIntVect);               { Save the old vector }
   SetIntVec($29, @Int29Handler);            { Install interrupt handler }
END;

FUNCTION ExecWin(ProgName, Params, Title : STRING;
                 LeftCol, TopLine, RightCol, BottomLine,
                 ForeColor, BackColor, ForeBorder, BackBorder,
                 Border, ForeTitle, BackTitle : WORD) : WORD;

{
  ProgName   = Program name to execute (must includes the full path)
  Params     = Program parameters passed to child process
  Title      = Title assigned to the text window (unused if blank)
  LeftCol    = Left column of the window border
  TopLine    = Top line of the window border
  RightCol   = Right column of the window border
  BottomLine = Bottom line of the window border
  ForeColor  = Foreground color of the window
  BackColor  = Background color of the window
  ForeBorder = Foreground color of the window border
  BackBorder = Background color of the window border
  Border     = Border type to use.  Where type is:
                0 - None used
                1 - '+'
                2 - '+'
                3 - '#'
                4 - '+'
  ForeTitle  = Foreground color of the window title
  BackTitle  = Background color of the window title

  If an error is encountered, the program will return the following
  error codes in the ExecWin variable.

      97 - Title wider than the window
      98 - The left or right screen margins have been exceeded
      99 - The top or bottom screen margins have been exceeded
}

LABEL
   ExitExec;

VAR
   A : WORD;

BEGIN
   IF (LeftCol < 1) OR (RightCol > 80) THEN
      BEGIN
         ExecWin := 98;
         GOTO ExitExec;
      END;
   IF (TopLine < 1) OR (BottomLine > 24) THEN
      BEGIN
         ExecWin := 99;
         GOTO ExitExec;
      END;
   SaveScrn(0);
   TextColor(ForeBorder);
   TextBackground(BackBorder);
   GotoXY(LeftCol, TopLine);
   CASE Border OF
      1 : BEGIN
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             FOR A := 1 TO (BottomLine - TopLine) - 1 DO
                BEGIN
                   GotoXY(LeftCol, TopLine + A);
                   Write('|');
                   GotoXY(RightCol, TopLine + A);
                   Write('|');
                END;
             GotoXY(LeftCol, BottomLine);
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             IF Ord(Title[0]) > 0 THEN
                IF (Ord(Title[0])) <= (RightCol - LeftCol) THEN
                   BEGIN
                      A := Ord(Title[0]);
                      A := RightCol - LeftCol - A;
                      A := A DIV 2;
                      GotoXY(A - 2 + LeftCol, TopLine);
                      Write('+ ');
                      TextColor(ForeTitle);
                      TextBackground(BackTitle);
                      Write(Title);
                      TextColor(ForeBorder);
                      TextBackground(BackBorder);
                      Write(' +');
                   END
                ELSE
                   BEGIN
                      ExecWin := 97;
                      GOTO ExitExec;
                   END;
          END;
      2 : BEGIN
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             FOR A := 1 TO (BottomLine - TopLine) - 1 DO
                BEGIN
                   GotoXY(LeftCol, TopLine + A);
                   Write('|');
                   GotoXY(RightCol, TopLine + A);
                   Write('|');
                END;
             GotoXY(LeftCol, BottomLine);
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             IF Ord(Title[0]) > 0 THEN
                IF (Ord(Title[0])) <= (RightCol - LeftCol) THEN
                   BEGIN
                      A := Ord(Title[0]);
                      A := RightCol - LeftCol - A;
                      A := A DIV 2;
                      GotoXY(A - 2 + LeftCol, TopLine);
                      Write('+ ');
                      TextColor(ForeTitle);
                      TextBackground(BackTitle);
                      Write(Title);
                      TextColor(ForeBorder);
                      TextBackground(BackBorder);
                      Write(' +');
                   END
                ELSE
                   BEGIN
                      ExecWin := 97;
                      GOTO ExitExec;
                   END;
          END;
      3 : BEGIN
             Write('#');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('#');
             Write('#');
             FOR A := 1 TO (BottomLine - TopLine) - 1 DO
                BEGIN
                   GotoXY(LeftCol, TopLine + A);
                   Write('#');
                   GotoXY(RightCol, TopLine + A);
                   Write('#');
                END;
             GotoXY(LeftCol, BottomLine);
             Write('#');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('#');
             Write('#');
             IF Ord(Title[0]) > 0 THEN
                IF (Ord(Title[0])) <= (RightCol - LeftCol) THEN
                   BEGIN
                      A := Ord(Title[0]);
                      A := RightCol - LeftCol - A;
                      A := A DIV 2;
                      GotoXY(A - 2 + LeftCol, TopLine);
                      Write('# ');
                      TextColor(ForeTitle);
                      TextBackground(BackTitle);
                      Write(Title);
                      TextColor(ForeBorder);
                      TextBackground(BackBorder);
                      Write(' #');
                   END
                ELSE
                   BEGIN
                      ExecWin := 97;
                      GOTO ExitExec;
                   END;
          END;
      4 : BEGIN
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             FOR A := 1 TO (BottomLine - TopLine) - 1 DO
                BEGIN
                   GotoXY(LeftCol, TopLine + A);
                   Write('|');
                   GotoXY(RightCol, TopLine + A);
                   Write('|');
                END;
             GotoXY(LeftCol, BottomLine);
             Write('+');
             FOR A := 1 TO (RightCol - LeftCol) - 1 DO
                Write('-');
             Write('+');
             IF Ord(Title[0]) > 0 THEN
                IF (Ord(Title[0])) <= (RightCol - LeftCol) THEN
                   BEGIN
                      A := Ord(Title[0]);
                      A := RightCol - LeftCol - A;
                      A := A DIV 2;
                      GotoXY(A - 2 + LeftCol, TopLine);
                      Write('| ');
                      TextColor(ForeTitle);
                      TextBackground(BackTitle);
                      Write(Title);
                      TextColor(ForeBorder);
                      TextBackground(BackBorder);
                      Write(' |');
                   END
                ELSE
                   BEGIN
                      ExecWin := 97;
                      GOTO ExitExec;
                   END;
          END;
      END;
   TextColor(ForeColor);
   TextBackground(BackColor);
   Window(LeftCol + 1, TopLine + 1, RightCol - 1, BottomLine - 1);
   ClrScr;
   HookInt29;
   SwapVectors;
   Exec(ProgName, Params);
   SwapVectors;
   ExecWin := DOSExitCode;
   SetIntVec($29,OldIntVect); { Restore the interrupt }
   Window(1, 1, 80, 25);
   RestoreScrn(0);

   ExitExec:

END;

END.

{
The ScrnCopy unit may be found within the SWAG files or you can make up
your own.

Tom Carroll
Dataware Software
}

