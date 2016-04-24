(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0082.PAS
  Description: Triangular Fractal
  Author: SCOTT EARNEST
  Date: 11-26-94  05:00
*)

program Chaos;

{Triangular fractal generator

 Based on program "Chaos" published in Nibble, June 1989 (Vol. 10, No. 6)
 One-Liner winner written by Max Raymond of Huston, TX.  Program inspired
 by a PBS broadcast of Nova, called "Chaos".

 Adapted for Turbo Pascal by Scott Earnest, 1994.
 scott@whiplash.pc.cc.cmu.edu

 About the program:

 When the program is run, it will ask for 4 sets of coordinates.  The first
 three are the vertices of the triangle, and the fourth is the location of
 the "traveler", the point that moves around the screen leaving its path.
 The traveler may start at any position either inside or outside the tri-
 angle.  Press any key to exit the program.

 The original author's comment about the program:

   "A three-sided die is simulated, and its roll corresponds to one of
    the three vertices of the triangle.  The traveler will move halfway
    from its current point toward the vertex selected by the die roll.
    A copy of the traveler is left behind at its old position, while
    the traveler is redrawn at its new position.  The process is then
    repeated.  The pattern that emerges is a record of the traveler's
    journey, as it jumps from point to point."

}

uses graph, crt;

const BGIPath : string[80] = 'E:\BP\BGI';

type
  TPoint = record
    x, y : integer;
  end;

var
  grDriver,
  grMode,
  grError : integer;

  MaxX, MaxY : word;

  TriExt : array [1 .. 4] of TPoint;

procedure StartGraph;

begin
  grDriver := Detect;
  initgraph (grDriver, grMode, BGIPath);
  grError := GraphResult;
  if grError <> grOk then
  begin
    writeln ('Graphics error:  ', GraphErrorMsg(grError));
    halt (1);
  end;
  MaxX := getmaxx;
  MaxY := getmaxy;
end;

procedure InputPoints;

var
  pnum : byte;
  tx, ty : word;

  function inputnum (idx : byte; max : word; ch : char) : word;

  var
    inval, err : word;
    instr : string;

  begin
    repeat
      if idx < 4 then
        write ('Enter ',ch,' vertex #',idx,':  ')
      else
        write ('Enter "traveler" start ',ch,':  ');
      readln (instr);
      val (instr, inval, err);
      if (err > 0) or (inval > max) then
        writeln ('Invalid entry.  Please re-enter.');
    until (inval <= Max);
    inputnum := inval;
  end;

begin
  writeln ('Screen range = X:(0-',MaxX,'); Y:(0-',MaxY,').');
  for pnum := 1 to 4 do
    begin
      TriExt[pnum].x := inputnum (pnum, MaxX, 'X');
      TriExt[pnum].y := inputnum (pnum, MaxY, 'Y');
    end;
end;

procedure DrawChaos;

var
  select : byte;

begin
  while keypressed do readkey;
  repeat
    select := random(3) + 1;
    TriExt[4].x := TriExt[4].x + (TriExt[select].x - TriExt[4].x) div 2;
    TriExt[4].y := TriExt[4].y + (TriExt[select].y - TriExt[4].y) div 2;
    putpixel (TriExt[4].x, TriExt[4].y, 15);
  until keypressed;
  while keypressed do readkey;
end;

begin
  Randomize;
  StartGraph;
  RestoreCRTMode;
  clrscr;
  InputPoints;
  SetGraphMode (GetGraphMode);
  DrawChaos;
  CloseGraph;
  RestoreCRTMode;
  clrscr;
end.

