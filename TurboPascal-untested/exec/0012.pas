(*
   Written by Tom Carroll, Nova 24, 1993 for TP 7.0.

   Adapted from the example code posted by Kelly Small in the FidoNet
   Pascal echo 11/19/93.

   Released to the Public Domain 11/24/93.

   Please give credit where credit is due

   This Program will execute a program within a text window
   and all program scrolling will be maintained within
   the window.

   This would be better to put inside a unit, but I couldn't get the
   interrupt to work within the unit.  If you're able to get it to work
   inside a unit, I would appreciate you posting the unit so I can see
   how it was done.
*)

Program ExecInATextWindow;

USES
   Dos,  { Used for the Exec call }
   Crt;  { For the GotoXY calls }

VAR
   ExitVal    : WORD;
   MyProg     : STRING;
   MyParams   : STRING;
   OldIntVect : POINTER;

{$F+}
PROCEDURE Int29Handler(AX, BX, CX, DX, SI, DI, DS, ES, BP : WORD);

INTERRUPT;

VAR
   Dummy : BYTE;

BEGIN
   Write(Chr(Lo(AX)));   { Writes each output character to the screen }
   Asm Sti; END;
END;
{$F-}

PROCEDURE HookInt29;

BEGIN
   GetIntVec($29, OldIntVect);      { Save the old vector }
   SetIntVec($29, @Int29Handler);   { Install interrupt handler }
END;

FUNCTION ExecWin(ProgName, Params : STRING; LeftCol, TopLine,
                 RightCol, BottomLine : WORD) : WORD;

VAR
   A : WORD;

BEGIN
   GotoXY(LeftCol, TopLine);               { Puts cursor at the top left }
   Write(Chr(201));                        { hand corner of the window   }

{ I use three FOR loops to write the actual window borders to the screen.

  NOTE: The window size for the executed program will actually be two
        rows and two columns smaller that what you call.  This is because
        there is no error checking to see if the call will place the
        window borders outside the maximum row column range for the
        video.                                                           }

   FOR A := 1 TO (RightCol-LeftCol) - 1 DO
      Write(Chr(205));
   Write(Chr(187));
   FOR A := 1 TO (BottomLine-TopLine) - 1 DO
      BEGIN
         GotoXY(LeftCol, TopLine + A);
         Write(Chr(186));
         GotoXY(RightCol,TopLine + A);
         Write(Chr(186));
      END;
   GotoXY(LeftCol, BottomLine);
   Write(Chr(200));
   FOR A := 1 TO (RightCol-LeftCol) - 1 DO
      Write(Chr(205));
   Write(Chr(188));

{ Now set the text window so the program will not scroll the outline of
  the window off the screen.                                            }

   Window(LeftCol + 1, TopLine + 1, RightCol - 1, BottomLine - 1);
   GotoXY(1, 1);     { Jumps to the upper left hand corner of the window }
   HookInt29;        { Hooks Interrupt 29 for video output }
   {$M 10000, 0, 0}  { This works good for Archive utilities }
   SwapVectors;
   Exec(ProgName, Params);
   ExecWin := DOSExitCode; { Return the exit code for error trapping }
   SwapVectors;
   SetIntVec($29,OldIntVect); { Restore the interrupt }
   Window(LeftCol, TopLine, RightCol, BottomLine); { Set the window to the }
   ClrScr;                                         { actual size of the    }
   Window(1, 1, 80, 25);                           { border so it can be   }
END;                                               { cleared properly.     }

BEGIN

ClrScr;

{ Modify these two lines to suit your system }

MyProg := 'C:\UTIL\PKUNZIP.EXE';
MyParams := '-t C:\QMPRO\DL\STORE\WAV\SEINWAV1.ZIP';

ExitVal := ExecWin(MyProg, MyParams, 5, 6, 75, 16);

WriteLn('DOS exit code = ', ExitVal);

ReadLn;

END.

{ I would like to modify this code to allow for a screen save feature that
  will restore the previous screen for the coordinates passed to the ExecWin
  function.
  Other nice features would be to add a sideways scrolling effect,
  exploding windows for the text window and then make it implode when
  the previous video is restored. }

