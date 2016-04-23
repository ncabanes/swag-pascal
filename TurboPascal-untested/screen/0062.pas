{***********************************************************************}
PROGRAM ScreenPortDemo;         { Sept 6/93, Greg Estabrooks.           }
USES CRT;                       { LastMode,Clrscr.                      }
CONST
     Speed = 50;                { Define speed for moving screen portion}
     {******** Change this to make the screen move faster/slower *******}
TYPE
        ScreenPort = RECORD
                        ScreenSt :ARRAY[1..4000] OF BYTE;
                        NumCols,
                        NumRows  :BYTE;
                     END;

        ScreenPtr = ^ScreenSet;
        ScreenSet = ARRAY[1..50,1..80,0..1] OF BYTE;
                        {  1..50 = Row,  0..79 = Col, 0 = Character,
                                                      1 = Color Byte    }
VAR
        TextScreen     :SCREENPTR;
        BaseOfScreen   :WORD;
        BPort,
        SPort          :ScreenPort;
        Row,Colm       :WORD;

PROCEDURE SaveScrPort( Col1, Row1, Col2, Row2 :BYTE; VAR ScrP :SCREENPORT );
VAR
        LLength :BYTE;
        Counter1,Counter2  :WORD;
BEGIN
  Counter2 := 1;
  LLength := (2 * (Col2 - Col1))+2;
  For Counter1 := Row1 To Row2 DO
    BEGIN
      Move(TextScreen^[Counter1,Col1,0],ScrP.ScreenST[Counter2],LLength);
      Inc(Counter2,LLength);
    END;
  ScrP.NumCols := LLength;
  ScrP.NumRows := Row2 - Row1;
END;

PROCEDURE RestoreScrPort( Col,Row :BYTE; VAR ScrP :SCREENPORT );
VAR
   Counter1,Counter2  :WORD;
BEGIN
  Counter2 := 1;
  For Counter1 := Row To (Row + ScrP.NumRows) Do
    BEGIN
      Move(ScrP.ScreenST[Counter2],TextScreen^[Counter1,Col,0],ScrP.NumCols);
      Inc(Counter2,ScrP.NumCols);
    END;
END;

BEGIN
  IF LastMode = 7 THEN          { Check current video mode.             }
    BaseOfScreen := $B000       { If Monochrome load mono segment.      }
  ELSE
    BaseOfScreen := $B800;      { if not load color segment.            }
  TextScreen := Ptr(BaseOfScreen,0); { Now point TextScreen proper area.}

  SaveScrPort(10,5,20,15,BPort);{ Save a cleared part of the screen.    }
  GotoXY(1,1);                  { Move to top corner of screen.         }

  FOR Row := 1 to 20 DO         { Generate screen for demonstration.    }
    FOR Colm := 1 to 80 DO
       Write('A');

  SaveScrPort(10,5,20,15,SPort);{ Save a portion of the screen.         }
  ClrScr;                       { Clear the screen.                     }
  SaveScrPort(10,5,20,15,BPort);{ Redisplay saved portion.              }

  FOR Colm := 10 to 50 DO       { Animate portion right.                }
   BEGIN
     RestoreScrPort(Colm,5,SPort);
     Delay(Speed);
     RestoreScrPort(Colm,5,BPort);
   END;

  FOR Row := 5 to 14 DO         { Animate Portion Down.                 }
   BEGIN
     RestoreScrPort(50,Row,SPort);
     Delay(Speed);
     RestoreScrPort(50,Row,BPort);
   END;

  FOR Colm := 50 DOWNTO 10 DO   { Animate Portion Left.                 }
   BEGIN
     RestoreScrPort(Colm,14,SPort);
     Delay(Speed);
     RestoreScrPort(Colm,14,BPort);
   END;

  FOR Row := 14 DOWNTO 5 DO     { Animate Portion Up.                   }
   BEGIN
     RestoreScrPort(10,Row,SPort);
     Delay(Speed);
     RestoreScrPort(10,Row,BPort);
   END;
   RestoreScrPort(10,5,SPort);
  Readln;
END.
{***********************************************************************}

