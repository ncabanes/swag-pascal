(*
  Category: SWAG Title: SCREEN SAVING ROUTINES
  Original name: 0016.PAS
  Description: Re: Procedures for screens
  Author: GEORGE ROBERTS
  Date: 11-22-95  13:30
*)


{ ScreenStuff : Turbo Pascal unit for saving and restoring portions of the
             screen.

  This source is released into the public domain by Intuitive Vision Software
  on 08/01/95.  This source may be used, modified and distributed with the
  following exceptions:

        * Modified versions of this source code may be distributed PROVIDING
          that the modified version still contains this header at the
          beginning of the file, and that no text has been deleted from the
          header.  Additional comments may be added to the header.

        * This source code may be used in commercial or shareware programs
          providing that mention is made of its use in the documentation for
          said program.  THIS INCLUDES modified versions of this unit.  The
          proper description of this unit is:

                The ScreenStuff Unit from Intuitive Vision Software          }


UNIT ScrStuff;

INTERFACE

USES Dos, Crt;

CONST VideoSegment : WORD = $B800;

TYPE  WindowREC    = ARRAY[0..4003] of BYTE;

PROCEDURE SaveWindow(VAR Wind:WindowREC; X1,Y1,X2,Y2:INTEGER);
PROCEDURE RestoreWindow(Wind:WindowREC);

IMPLEMENTATION

PROCEDURE CheckVideoSegment;
BEGIN
  IF (MEM[$0000:$0449]=7) Then VideoSegment:=$B000 else VideoSegment:=$B800;
END;


{ NOTE: SaveWindow does not clear the area that it saves.  It simply saves
  this data to an array.  Thus, in order to do what was stated above, you
  would simply define two variables of type WindowREC in your program, and
  save the first screen and the second screen into them.  Then whenever you
  needed to put them on the screen, you could use RestoreWindow to do so.
  NOTE: RestoreWindow does not clear the contents of the WindowREC variable
  passed to it, therefore this is possible.                                  }

{ ADDITIONAL NOTE:  SaveWindow and RestoreWindow do NOT save your window size
  or cursor position.  If you wish to modify it to do so, I would suggest
  increasing the WindowREC variable to ARRAY[0..4009] of BYTE, then place
  the window size and cursor position in the last 6 bytes.

  Current Window Size:

  x1:=LO(Windmin)+1;
  y1:=HI(Windmin)+1;
  x2:=LO(Windmax)+1;
  y2:=HI(Windmax)+1;

  Cursor position (window relative);

  x:=wherex;
  y:=wherey;

  }

PROCEDURE SaveWindow(VAR Wind:WindowREC; X1,Y1,X2,Y2:INTEGER);
VAR i,x,y:INTEGER;
BEGIN
  CheckVideoSegment;                    { Find out the video segment         }

  Wind[4000]:=X1; Wind[4001]:=Y1;       { Put the size of the saved screen in}
  Wind[4002]:=X2; Wind[4003]:=Y2;       { the array for use at restore       }

  i:=0;                                 { Fill array with correct values from}
  FOR y:=Y1 TO Y2 DO                    { memory                             }
    FOR x:=X1 to X2 DO BEGIN
      INLINE($FA);
      Wind[i]:=MEM[VideoSegment:(160*(y-1)+2*(x-1))];
      Wind[i+1]:=MEM[VideoSegment:(160*(y-1)+2*(x-1))+1];
      INLINE($FB);
      INC(i,2);
    end;
end;

PROCEDURE RestoreWindow(Wind:WindowREC);
VAR X1,Y1,X2,Y2,x,y,i:INTEGER;
BEGIN
  CheckVideoSegment;                    { Check the video segment            }

  WINDOW(1,1,80,25);                    { Set window to 1,1,80,25 and set    }
  TEXTCOLOR(7);                         { colors to 7,0 so that you have a   }
  TEXTBACKGROUND(0);                    { black background drawn             }

  X1:=Wind[4000]; Y1:=Wind[4001];       { set our mins/max values from the   }
  X2:=Wind[4002]; Y2:=Wind[4003];       { values in array                    }

  i:=0;                                 { move data from array into video    }
  FOR y:=Y1 TO Y2 DO                    { memory                             }
    FOR x:=X1 TO X2 DO BEGIN
      INLINE($FA);
      MEM[VideoSegment:(160*(y-1)+2*(x-1))]:=Wind[i];
      MEM[VideoSegment:(160*(y-1)+2*(x-1))+1]:=Wind[i+1];
      INLINE($FB);
      INC(i,2);
    END;
END;

END.

