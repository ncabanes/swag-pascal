{
From: Matthew.Mastracci@matrix.cambo.cuug.ab.ca (Matthew Mastracci)

 l> This is just cool enough that I'm going to post publicly too.

 l> LOU'S MAZE ALGORITHM

    Great algorithm!  I read your posting, pondered it, sat down for an hour
and wrote this:

}
{$r-} { Increases speed a marginal amount }
{
  Maze Generator - PD 1995, by Matthew Mastracci
                   rayban@matrix.cambo.cuug.ab.ca

  This program generates a maze using a plant-like approach.  It starts by
  sowing "seeds" about every four units around the edge, and two in the
  middle.  These then grow out in a random order in three directions.  This
  prevents seeds from sprouting if they would grow into another.

  The original algorithm for generating mazes was written by Lou Duchez and
  posted in comp.lang.pascal.  Here's a small excerpt from the part which
  describes how to work with the seeds:

 ---
Keep executing this loop until you run out of seeds:

  - Randomly select a seed.  Extend the wall in some valid direction from
    this seed point, by turning into walls the grid locations one unit and
    two units away from the seed.  To prevent the maze from closing off at
    any point, DO NOT EXTEND A WALL TO ANY POINT THAT IS ALREADY MARKED AS A
    WALL!  (With this rule, you never close off the maze; you simply
    complicate the path from beginning to end.)

  - Remove this seed.  It's done its job.

  - Add three seed points at this new location.  (The assumption is that the
    wall could grow in three directions from this new point; if you want to
    be more exacting, you can add as many seeds as there are directions that
    the wall could extend from that point.  It really doesn't matter much,
    except for the possibility of running out of seed point array elements if
    you always add 3.)

  - Seed maintenance: go through your list of seeds and eliminate any
    seeds that cannot extend in any valid direction.
 ---

  Feel free to use this source anywhere you want in anyway you want.  I
  recommend you use it to generate mazes for games, however...  :)

}
program
  MazeGenerator;

uses
  Crt;

const
  xMax = 79;
  yMax = 49;
  sMax = (xMax - 3) * (yMax - 3) div 2;

type
  tMap = record
    Data : array[1..xMax, 1..yMax] of Boolean;
    xEntrance, yEntrance : Byte;
    xExit, yExit : Byte;
  end;
  tSeed = record
    x, y, Dir : Byte;
    Valid : Boolean;
  end;

var
  Map : tMap;

{ Draws the map }
procedure DrawMap(Map : tMap);
var
  x, y : Byte;
begin
  for x := 1 to xMax do begin
    for y := 1 to yMax do begin
      if Map.Data[x, y] then Mem[$b800 : y * 160 + x * 2] := 219;
    end;
  end;
end;

{ Generates the map }
procedure GenerateMap(var Map : tMap);
var
  Seeds : array[1..sMax] of tSeed;

{ Reports TRUE if any seeds are "unsprouted" }
function NoSeeds : Boolean;
var
  i : Word;
  FoundSeeds : Boolean;
begin
  FoundSeeds := False;
  for i := 1 to sMax do begin
    if Seeds[i].Valid then FoundSeeds := True;
  end;
  NoSeeds := not FoundSeeds;
end;

{ "Plant" a seed }
procedure AddSeed(x, y, Dir : Byte);
var
  i : Word;
begin
  i := 0;
  repeat
    Inc(i);
  until (i = sMax) or not Seeds[i].Valid;
  if Seeds[i].Valid then begin
    WriteLn('Error: Out of seed space!');
    Halt;
  end else begin
    Seeds[i].x := x;
    Seeds[i].y := y;
    Seeds[i].Dir := Dir;
    Seeds[i].Valid := True;
  end;
end;

{ "Sprout" a seed }
procedure Sprout;
var
  i : Word;
begin
  repeat
    i := Random(sMax) + 1;
  until Seeds[i].Valid;
  with Seeds[i] do begin
    case Dir of
      0: begin { up }
        if not Map.Data[x, y - 2] then begin
          AddSeed(x, y - 2, 1);
          AddSeed(x, y - 2, 2);
          AddSeed(x, y - 2, 3);
          Map.Data[x, y - 1] := True;
          Map.Data[x, y - 2] := True;
        end;
      end;
      1: begin { down }
        if not Map.Data[x, y + 2] then begin
          AddSeed(x, y + 2, 0);
          AddSeed(x, y + 2, 2);
          AddSeed(x, y + 2, 3);
          Map.Data[x, y + 1] := True;
          Map.Data[x, y + 2] := True;
        end;
      end;
      2: begin { left }
        if not Map.Data[x - 2, y] then begin
          AddSeed(x - 2, y, 0);
          AddSeed(x - 2, y, 1);
          AddSeed(x - 2, y, 3);
          Map.Data[x - 1, y] := True;
          Map.Data[x - 2, y] := True;
        end;
      end;
      3: begin { right }
        if not Map.Data[x + 2, y] then begin
          AddSeed(x + 2, y, 0);
          AddSeed(x + 2, y, 1);
          AddSeed(x + 2, y, 2);
          Map.Data[x + 1, y] := True;
          Map.Data[x + 2, y] := True;
        end;
      end;
    end;
  end;
  Seeds[i].Valid := False;
end;

var
  x, y : Byte;
  DrawCount : Byte;

begin
  FillChar(Map, SizeOf(Map), 0); { Zero out map }
  FillChar(Seeds, SizeOf(Seeds), 0); { Erase seeds }
  { Draw border }
  with Map do begin
    for x := 1 to xMax do begin
      Data[x, 1] := True;
      Data[x, yMax] := True;
    end;
    for y := 1 to yMax do begin
      Data[1, y] := True;
      Data[xMax, y] := True;
    end;
    { Map entrance }
    yEntrance := 1;
    xEntrance := (Random(yMax div 2) + 1) * 2;
    Data[xEntrance, yEntrance] := False;
    { Map exit }
    yExit := yMax;
    xExit := (Random(yMax div 2) + 1) * 2;
    Data[xExit, yExit] := False;
    { Add a couple of seeds in the middle (islands) }
    AddSeed((Random(xMax div 2) + 1) * 2 + 1, (Random(yMax div 2) + 1) * 2 + 1,
Random(4));
    AddSeed((Random(xMax div 2) + 1) * 2 + 1, (Random(yMax div 2) + 1) * 2 + 1,
Random(4));
    { Add seeds around the edges, about every 4 units }
    for DrawCount := 1 to (2 * xMax + 2 * yMax) div 4 do begin
      case Random(4) of
        0: AddSeed((Random(xMax div 2) + 1) * 2 + 1, 1, 1); { top, going down }
        1: AddSeed((Random(xMax div 2) + 1) * 2 + 1, yMax, 0); { bottom, going
up }
        2: AddSeed(1, (Random(yMax div 2) + 1) * 2 + 1, 3); { left, going right
}
        3: AddSeed(xMax, (Random(yMax div 2) + 1) * 2 + 1, 2); { right, going
left }
      end;
    end;
  end;
  DrawCount := 0;
  repeat
    Inc(DrawCount);
    if DrawCount = 100 then begin
      DrawCount := 0;
      DrawMap(Map);
    end;
    if KeyPressed then begin
      while KeyPressed do ReadKey;
      DrawMap(Map);
    end;
    Sprout;
  until NoSeeds;
  DrawMap(Map);
end;

begin
  Randomize;
  TextMode(CO80 + Font8x8);
  GenerateMap(Map);
end.
