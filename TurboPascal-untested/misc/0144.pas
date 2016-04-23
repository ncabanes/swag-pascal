{
   In the meantime the readers might want to play around with the following
code, that I think I originally picked up in this invaluable conference some
years ago (or it may have been the SWAG -- don't remember really). I've
altered the original code so it can be compiled without any other special
units but my cursorUnit, that comes next.
}

program MazeSolver;

uses Crt, cursorUnit;

{$R-,S-,M 16384, 16384, 16384
  Program draws and solves a 23x78 maze.
  The algorithm used by Maze is adapted from one given in Chapter 4 of
  "The Elements of Programming Style" by B. Kernighan and P.J. Plauger
  (McGraw-Hill, 1978)

  This version for the IBM PC: Wilbert van Leijen
  Written:     16 Sept. 1987
  Revised:     19 March 1989
  Revised:     Jan 15th 1995 by Björn Felten @ 2:203/208
}

const
  Title        : string[6] = ' Maze ';
  Usage        : string[38] = ' F1─Full speed F2─Delay move Esc─Quit ';
  MazeX        = 77;
  MazeY        = 22;

type
  MazeSquare   = (Wall, Path);
  MazeArray    = array[0..MazeX, 0..MazeY] of MazeSquare;
  Direction    = (GoUp, GoDown, GoLeft, GoRight);
  ScrBuffer    = array [0..1999] of word; (* Screen Buffer *)

var
  FullSpeed    : boolean;
  ImageBuffer  : pointer;
  Maze         : MazeArray;
  X, Y         : integer;
  Screen       : array [0..7] of ScrBuffer absolute $B800: 0000;

procedure WriteXY (Page, Attrib, X, Y: word; N: String);

  function x80p(Y, X: word): word; assembler;
  asm
      MOV AX,Y
      MOV BX,AX
      MOV CL,4
      SHL BX,CL
      MOV CL,6
      SHL AX,CL
      ADD AX,BX
      ADD AX,X
  end;

var I: byte;
begin
  if N[0] <> #0 then for I := 1 to length(N) do
     Screen[Page][X80p(Y,X+pred(I))]:=(Attrib shl 8) + ord(N[I]);
end;

{ Set up a frame around the activities }

procedure Frame;

begin
  WriteXY(0, $1F, 37,  0, Title);
  WriteXY(0, $17, 41, 24, Usage);
  WriteXY(0, $31, 42, 24, 'F1');
  WriteXY(0, $31, 56, 24, 'F2');
  WriteXY(0, $31, 70, 24, 'Esc')
end;

procedure ShowMaze(X, Y: integer; Show: char);
begin
  WriteXY(0, $1B, X+2, Y+1, Show)
end;  { ShowMaze }

{ Set up maze }

procedure CreateMaze;

var
  X, Y         : integer;
  MazeAction   : Direction;

  { Set a given maze element to be Path or Wall }

  procedure SetSquare(X, Y: integer; Val: MazeSquare);
  begin
    Maze[X, Y] := Val;
    case Val of
      Path : ShowMaze(X, Y, ' ');
      Wall : WriteXY(0, $0F, X+2, Y+1, '█')
    end
  end;  { SetSquare }

  { Return a random value of direction }

  function RandomDirection : Direction;

  begin
    case Random(4) of
      0 : RandomDirection := GoUp;
      1 : RandomDirection := GoDown;
      2 : RandomDirection := GoLeft;
      3 : RandomDirection := GoRight;
    end;
  end;  { RandomDirection }

  { Return a random element in the maze }

  function RandomDig(max : integer) : integer;

  begin
    RandomDig := 2 * Random(max shr 1-1)+1
  end;  { RandomDig }

  { Check wether a legal path can be built }

  Function LegalPath(x, y : integer;
               MazeAction : Direction) : Boolean;

  begin
    LegalPath := False;
    case MazeAction of
      GoUp    : if y > 2 then
                  LegalPath := (Maze[x, y-2] = Wall);
      GoDown  : if y < MazeY-2 then
                  LegalPath := (Maze[x, y+2] = Wall);
      GoLeft  : if x > 2 then
                  LegalPath := (Maze[x-2, y] = Wall);
      GoRight : if x < MazeX-2 then
                  LegalPath := (Maze[x+2, y] = Wall);
    end;
  end;  { LegalPath }

  { Extend path in given direction }

  Procedure Buildpath(X, Y : integer;
                MazeAction : Direction);
  var
    Unused     : set of Direction;

  begin
    case MazeAction of
      GoUp    : begin
                  SetSquare(X, Y-1, Path);
                  SetSquare(X, Y-2, Path);
                  dec(Y, 2)
                end;
      GoDown  : begin
                  SetSquare(X, Y+1, Path);
                  SetSquare(X, Y+2, Path);
                  inc(Y, 2)
                end;
      GoLeft  : begin
                  SetSquare(X-1, Y, Path);
                  SetSquare(X-2, Y, Path);
                  dec(X, 2)
                end;
      GoRight : begin
                  SetSquare(X+1, Y, Path);
                  SetSquare(X+2, Y, Path);
                  inc(X, 2)
                end
    end;
    Unused := [GoUp..GoRight];
    repeat                             { Check direction for legality }
      MazeAction := RandomDirection;
      if MazeAction in Unused then     { If so, extend in that direction }
        begin
          Unused := Unused-[MazeAction];
          if LegalPath(x, y, MazeAction) then
            BuildPath(x, y, MazeAction)
        end
    until Unused = []                  { All legal moves are exhausted }
 end;  { BuildPath }

  { CreateMaze initially draws a maze that is 'solid rock'.
    Then the maze will be 'excavated' by setting the elements of
    the maze to path. It keeps digging until all legal paths are
    exhausted and, finally, it digs an 'entrance' and 'exit' path
    on the boundaries of the maze }

begin
  for y := 0 to MazeY do               { Setup 'solid rock' }
    for x := 0 to MazeX do
      SetSquare(x, y, Wall);
  y := RandomDig(MazeY);               { Starting point }
  x := RandomDig(MazeX);
  SetSquare(x, y, Path);
  repeat                               { Dig path in maze }
    MazeAction := RandomDirection
  until LegalPath(x, y, MazeAction);
  BuildPath(x, y, MazeAction);
  x := RandomDig(MazeX);
  SetSquare(x, 0, Path);               { Dig entrance }
  ShowMaze(x, 0, #25);
  x := RandomDig(MazeX);
  SetSquare(x, MazeY, Path)            { Dig exit }
end;  { CreateMaze }

{ Solve the maze }

procedure SolveMaze;

var
  Solved       : boolean;
  x, y         : integer;
  Tried        : array[0..MazeX, 0..MazeY] of boolean;

  { Attempt Maze solution from point in given direction }

  function Try(x, y : integer;
         MazeAction : Direction) : boolean;
  var
    Ok         : boolean;

    { Draw attempted move on screen }

    procedure MoveMaze(MazeAction : Direction);

    begin
      if not FullSpeed then
        Delay(80);
      case MazeAction of
        GoUp    : ShowMaze(x, y, #24);
        GoDown  : ShowMaze(x, y, #25);
        GoLeft  : ShowMaze(x, y, #27);
        GoRight : ShowMaze(x, y, #26);
      end
    end;  { MoveMaze }

  { Check whether there is a path to the boundary from a given
    point in a given direction. It returns True if there exists
    a path; otherwise, the Try is False }

  begin
    Ok := (Maze[x, y] = Path);         { If Wall, no solution exist }
    if Ok then begin
        Tried[x, y] := True;           { Set Tried flag }
        case MazeAction of
          GoUp    : Dec(y);
          GoDown  : Inc(y);
          GoLeft  : Dec(x);
          GoRight : Inc(x);
        end;
        Ok := (Maze[x, y] = Path) and not Tried[x, y];
        if Ok then begin               { Consider neighbouring square }
            MoveMaze(MazeAction);
            Ok := (y <= 0) or (y >= MazeY) or (x <= 0) or (x >= MazeX);
            if not Ok then
              Ok := Try(x, y, GoLeft);
            if not Ok then
              Ok := Try(x, y, GoDown);
            if not Ok then
              Ok := Try(x, y, GoRight);
            if not Ok then
              Ok := Try(x, y, GoUp);
            if not Ok then
              ShowMaze(x, y, ' ');
          end;
        end;
        Try := Ok;
    end;  { Try }

{ SolveMaze looks for a continuous sequence of Path squares from one
  point on the boundary of the maze to another }

begin
  FillChar(Tried, SizeOf(Tried), False);
  Solved := False;
  x := 0;
  y := 1;
  while not Solved and (y < MazeY) do begin
    Solved := Try(x, y, GoRight);
    inc(y)
  end;
  x := MazeX;
  y := 1;
  while not Solved and (y < MazeY) do begin
    Solved := Try(x, y, GoLeft);
    inc(y)
  end;
  x := 1;
  y := 0;
  while not Solved and (x < MazeX) do begin
    Solved := Try(x, y, GoDown);
    Inc(x)
  end;
  x := 1;
  y := MazeY;
  while not Solved and (x < MazeX) do begin
    Solved := Try(x, y, GoUp);
    Inc(x)
  end;
  Solved := True;
  repeat until KeyPressed
end;  { SolveMaze }

procedure Mainline;

const
  F1           = #59;
  F2           = #60;

var
  Ch           : char;

begin
  repeat
    Ch := ReadKey;
    if Ch = #0 then Ch := ReadKey;
    case Ch of
      F1 : begin
             CreateMaze;
             FullSpeed := True;
             SolveMaze
           end;
      F2 : begin
             CreateMaze;
             FullSpeed := False;
             SolveMaze
           end;
    end
  until Ch = #27
end;  { Mainline }

begin
  ClrScr;
  Frame;
  cursorOff;
  Randomize;
  Mainline;
  cursorOn
end.  { MazeSolver }


{
  From: Lou Duchez                                   Read: Yes    Replied: No

Very nice!  My algorithm grows walls, but your algorithm digs corridors.
Your algorithm also seems to generate more complicated mazes than mine.
My only concern is that it relies so heavily on recursion; you risk
running out of stack space.  Of course, with my algorithm, you allocate
lots of arrays that take up data segment ...

Thanks for posting it!

As I comprehend it, the maze-generating algorithm is like this:

- Draw a field composed entirely of walls.

- Select a random spot in the field to be your very first corridor spot.

- Here is the maze-digging routine:
  
  - (This routine takes two value parameters: the X and Y coordinates of
    your current location.)

  - If you can randomly select a valid location two units away from those
    X / Y coordinates (where "valid locations" are those that currently
    are walls and not corridors):
  
    - "Dig a corridor" from the X / Y location to that randomly-
      selected location.
    
    - Recursively call this routine; as parameters, pass the X and Y
      coordinates of that randomly-selected location.  (On the first
      pass, use that randomly-selected first corridor spot as the X and
      Y coordinates.)

- When the recursion ends, the maze is done.
}
