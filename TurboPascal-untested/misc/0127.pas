PROGRAM Knight;

{Knight's tour calcualtor. 

This program will compute a knight's tour of a chess board. A knight's tour
is a knight visiting each square of the chessboard only once by making his
normal move.

The main logic of this program is a recursive routine that keeps trying every
possible move from every possible position until a full tour is completed.

If a successful completion is realized, the board will display the sequence
of moves that must be made to complete the tour. If a successful completion
is not possible from the chosed starteing place, the board will be blank.

If the DEBUG variable is defined, the starting place will always be row one, 
column one, which is the upper left corner of the board. Otherwise a random
starting place is selected.

On a full size 8 x 8 square chessboard, this program runs about forever. To
limit the size of the board, change the BoardSize constant and recompile the 
program. To halt the execution of the program, press "Q".

This program uses Object Professional's FastWrite procedure to greatly speed
up its screen writing. To compile without Object Professional, delete the }

                             {$DEFINE USEOPRO}

{definition above. The executable program included here was compiled using
Turbo Pascal version 6.0, but the program should compile with 5.x. It was 
compiled using the Object Professional routines, but without the DEBUG
variable set. 



Written by:

            J Russell Jones
            4440 Gunnison 
            Wichita KS 67220

            GEnie: JJONES20

This program is hereby placed in the public domain.}



{$A-,B-,F-,G-,O+,V-,X-,N-,E-}

{$IFDEF DEBUG}
{$D+,I+,L+,R+,S+}
{$ELSE}
{$D-,I-,L-,R-,S-}
{$ENDIF}



USES
  {$IFDEF USEOPRO}
  OpCrt;
  {$ELSE}
  Crt;
  {$ENDIF}


CONST
  BoardSize     = 8;  {Limits the size of the chess board}
  DoneCount     = BoardSize * BoardSize;


TYPE
  BoardTyp  = ARRAY[1..BoardSize,1..BoardSize] OF BYTE;


VAR
  Board         : BoardTyp;
  Row,
  Col,
  FilledSpaces  : INTEGER;
  LongCount     : LONGINT;


PROCEDURE InitBoard(VAR Board : BoardTyp; VAR FilledSpaces : INTEGER);

  {Set the game board to all zeros}

  VAR
    i,j   : INTEGER;

  BEGIN {InitBoard}
    FilledSpaces := 0; 
    FOR i := 1 TO BoardSize DO
      FOR j := 1 TO BoardSize DO
        Board[i,j] := 0;
  END; {InitBoard}


FUNCTION AdjustKnight (Row,Col,Which : INTEGER;
                       VAR NewRow,NewCol : INTEGER) : BOOLEAN;

  {Adjust knight's position - return false if new position is off the 
  board or has already been occupied}


  BEGIN {AdjustKnight}

    CASE Which OF 
      1,2 : NewRow := Row - 2;
      8,3 : NewRow := Row - 1;
      7,4 : NewRow := Row + 1;
      6,5 : NewRow := Row + 2;
    END; {case}

    CASE Which OF 
      8,7 : NewCol := Col - 2;
      1,6 : NewCol := Col - 1;
      2,5 : NewCol := Col + 1;
      3,4 : NewCol := Col + 2;
    END;

    AdjustKnight := FALSE;

    IF (NewRow >= 1) AND (NewRow <= BoardSize) AND 
       (NewCol >= 1) AND (NewCol <= BoardSize) THEN
      IF Board[NewRow,NewCol] = 0 THEN
        AdjustKnight := TRUE;


  END; {AdjustKnight}


PROCEDURE ClearScreen;

  {Clear the screen and display a blank chess board}

  BEGIN {ClearScreen}
    ClrScr;

    {$IFDEF USEOPRO}

    FastText('Moves attempted:',1,5);
    FastText('┌────┬────┬────┬────┬────┬────┬────┬────┐',3,5);
    FastText('│    │    │    │    │    │    │    │    │',4,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',5,5);
    FastText('│    │    │    │    │    │    │    │    │',6,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',7,5);
    FastText('│    │    │    │    │    │    │    │    │',8,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',9,5);
    FastText('│    │    │    │    │    │    │    │    │',10,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',11,5);
    FastText('│    │    │    │    │    │    │    │    │',12,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',13,5);
    FastText('│    │    │    │    │    │    │    │    │',14,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',15,5);
    FastText('│    │    │    │    │    │    │    │    │',16,5);
    FastText('├────┼────┼────┼────┼────┼────┼────┼────┤',17,5);
    FastText('│    │    │    │    │    │    │    │    │',18,5);
    FastText('└────┴────┴────┴────┴────┴────┴────┴────┘',19,5);

    {$ELSE}

    GotoXY(5,1);
    WriteLn('Moves attempted:');
    WriteLn;
    WriteLn('    ┌────┬────┬────┬────┬────┬────┬────┬────┐');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    ├────┼────┼────┼────┼────┼────┼────┼────┤');
    WriteLn('    │    │    │    │    │    │    │    │    │');
    WriteLn('    └────┴────┴────┴────┴────┴────┴────┴────┘');

    {$ENDIF}

  END; {ClearScreen} 


PROCEDURE PlotPosition(Row,Col,FilledSpaces : INTEGER; Show : BOOLEAN);

  {Show or clear the specified position on the chess board}

  VAR
    s : STRING[4];

  BEGIN

    {$IFDEF USEOPRO}

    IF Show THEN
      Str(FilledSpaces:3,s)
    ELSE
      s := '   ';
    FastText(s,Row * 2 + 2,Col * 5 + 1);

    {$ELSE}

    GotoXY(Col * 5 + 1,Row * 2 + 2);
    IF Show THEN
      Write(FilledSpaces:3)
    ELSE
      Write('   ');

    {$ENDIF}

  END; {PlotPosition}


PROCEDURE KnightsTour (Row,Col : INTEGER; VAR Board : BoardTyp;
                       VAR FilledSpaces : INTEGER);

  VAR
    s             : STRING[32];
    Which,
    NewRow,
    NewCol        : INTEGER;
    ch            : CHAR;
  
  BEGIN

    IF KeyPressed THEN
      BEGIN
        ch := ReadKey;
        IF (ch = 'Q') OR (ch = 'q') THEN
          BEGIN
            GotoXY(1,22);
            {$IFDEF USEOPRO}
            NormalCursor;
            {$ENDIF}
            Halt;
          END
      END;

    Inc(LongCount);

    {$IFDEF USEOPRO}

    Str(LongCount,s);
    FastText(s,1,22);

    {$ELSE}

    GotoXY(22,1);
    Write(LongCount);

    {$ENDIF}


    Inc(FilledSpaces);
    Board[Row,Col] := FilledSpaces;
    PlotPosition(Row,Col,FilledSpaces,TRUE);

    Which := 0;
      
    WHILE ((FilledSpaces < DoneCount) AND (Which < 8)) DO
      BEGIN

        Inc(Which);

        IF AdjustKnight(Row,Col,Which,NewRow,NewCol) THEN
          KnightsTour(NewRow,NewCol,Board,FilledSpaces);

      END; {while}

    IF (Which = 8) THEN
      BEGIN
        Dec(FilledSpaces);
        PlotPosition(Row,Col,FilledSpaces,FALSE);
        Board[Row,Col] := 0;
      END; {if}

  END; {KnightTour}


BEGIN {Main Program}

  Randomize;

  {$IFDEF USEOPRO}
  HiddenCursor;
  {$ENDIF}

  InitBoard(Board,FilledSpaces);
  ClearScreen;

  Row := Random(BoardSize - 1) + 1;
  Col := Random(BoardSize - 1) + 1;

  {$IFDEF DEBUG}
  Row := 1;
  Col := 1;
  {$ENDIF}

  LongCount := 0;
  KnightsTour(Row,Col,Board,FilledSpaces);

  GotoXY(1,22);

  {$IFDEF USEOPRO}
  NormalCursor;
  {$ENDIF}


END.
