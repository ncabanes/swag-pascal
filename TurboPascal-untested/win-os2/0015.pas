{
I saw a postihg yesterday requesting source code for the Tower of Hanoi
problem. This proplem is an old chestnut which we drag out to demonstrate
recursion after we realize that factorial is really iteration.

Here is source code done in TPW1.5.
}

program TowersofHanoi;

uses
  CRT; { Not needed unless using Windows version }
       { copyright 1993 E. Kurt TeKolste }
       { no rights reserved }

const
  Max = 20;  { Use all of this at your peril }
  A   = 'A';  { Names of the three towers }
  B   = 'B';
  C   = 'C';

type
  Stack = 1..Max;
  Disk  = 0..Max;

  Tower = object
    Depth : integer;  { the current number of disks on the tower }
    V : array[Stack] of Disk; { the sizes of the disks on the tower }

    constructor Init(N : integer); {creates a tower with disks 1..N }
    procedure Add(D : Disk);     { Adds a disk of size D on top }
    function  Remove : Disk;     { Removes the top disk and returns its size }
    procedure Print;   { Prints a tower }
  end;

constructor Tower.Init(N : integer);
var
  I : Disk;
begin
  Depth := N;
  for I := 1 to N  do V[I] := I;
  for I := succ(N) to Max do V[I] := 0;
end;

procedure Tower.Add(D : Disk);
begin
  Depth    := succ(Depth);
  V[Depth] := D;
end;

function Tower.Remove : Disk;
begin
  Remove := V[Depth];
  Depth  := pred(Depth);
end;

procedure Tower.Print;
var
  I : Stack;
begin
  clreol;
  for I := 1 to Depth do write(V[I]:3);
end;

type
  Hanoi = object
    Display : boolean;  { If true, each move is displayed. }
    Pause   : boolean;  { If true, waits for keypress to continue after
                          each move. }
    S       : Stack;    { The number of disks on the towers.}
    H       : array[A..C] of Tower;

    constructor Init(I : Stack; On : boolean; Wait : boolean);
                { Creates a tower of Hanoi with I disks, the display
                  determined by On and the pause determined by Wait. }
    procedure Move( N : integer; var Source, Sink, Using : Tower);
                    { Moves the top N disks from Source to Sink using Using. }
    procedure Transfer;
                       { Moves all of the disks from A to C. }
    procedure Print;
                        { Prints the Towers of Hanoi }
  end;

constructor Hanoi.Init(I : Stack; On : boolean; Wait : boolean);
begin
  if I < Max then S := I else S := Max;
  Display := On;
  Pause   := Wait;
  H[A].Init(S);
  H[B].Init(0);
  H[C].Init(0);
end;

procedure Hanoi.Move(N : integer; var Source, Sink, Using : Tower);
var
  F : char;
begin
  if N > 0 then
  begin
    Move(N-1, Source, Using, Sink);
    Sink.Add(Source.Remove);
    if Display then
    begin
      Print;
      if Pause   then
      begin
        repeat until keypressed;
        F := readkey;
      end;
    end;
    Move(N-1, Using, Sink, Source);
  end;
end;

procedure Hanoi.Print;
var
  X : A..C;
begin
  for X := A to C do
  begin
    gotoxy(1,ord(X) - Ord(A) + 1);
    H[X].Print;
  end;
end;

procedure Hanoi.Transfer;
begin
  Move(S, H[A], H[B], H[C]);
end;

var
  T : Hanoi;
begin
  with T do
  begin
    Init(6,true,true);
    Transfer;
  end;
end.
