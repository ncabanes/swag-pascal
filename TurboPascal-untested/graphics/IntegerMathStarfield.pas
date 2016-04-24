(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0238.PAS
  Description: Integer Math Starfield
  Author: JACK MOTT
  Date: 11-29-96  08:17
*)

{ MAKE SURE TO SET THE BGI PATH BELOW !! }
{ Integer Math Starfield }
{ Jack Mott - (C) 1996 }
{ free to use for noncommercial purposes }
{ Give credit where credit is due }
{ Contact: thecrow@iconn.net }
PROGRAM StarFieldCoolness;

USES
 crt,graph;
CONST
 MAX = 250;
VAR
  xv :array[1..MAX] of integer;
  yv :array[1..MAX] of integer;
  x,y:array[1..MAX] of integer;
  x2,y2:longint;
  xyS:longint;
  c:array[1..MAX] of integer;
  i,count:integer;
  speed:integer;
  k:char;


PROCEDURE Init;
var
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;
begin
  grDriver := Detect;
  InitGraph(grDriver,grMode,'\turbo\tp\');
  ErrCode := GraphResult;
end;


PROCEDURE ResetStar(star:integer);
VAR
  r:integer;
BEGIN
  x[star] := random(640)+1;
  y[star] := random(480)+1;
  x[star] := x[star] - 250;
  y[star] := y[star] - 170;

if speed <> 0 then
  begin
  xv[star] := x[star] div speed;
  yv[star] := y[star] div speed;
  end
else
  begin
  xv[star] := x[star];
  yv[star] := y[star];
  end;



if (xv[star] = 0) and (yv[star] = 0) then
  begin
    xv[star] := 1;
    yv[star] := 1;
  end;




END;

PROCEDURE MoveRight;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do xv[i] := xv[i] - 1;
END;
PROCEDURE MoveLeft;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do xv[i] := xv[i] + 1;
END;

PROCEDURE MoveUp;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do yv[i] := yv[i] + 1;
END;

PROCEDURE MoveDown;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do yv[i] := yv[i] - 1;
END;

PROCEDURE MoveUpLeft;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do
    begin
      yv[i] := yv[i] + 1;
      xv[i] := xv[i] + 1;
    end;
END;

PROCEDURE MoveUpRight;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do
    begin
      yv[i] := yv[i] + 1;
      xv[i] := xv[i] - 1;
    end;
END;

PROCEDURE MoveDownRight;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do
    begin
      yv[i] := yv[i] - 1;
      xv[i] := xv[i] -1;
    end;
END;

PROCEDURE MoveDownLeft;
VAR
  i:integer;

BEGIN
  for i := 1 to MAX do
    begin
      yv[i] := yv[i] - 1;
      xv[i] := xv[i] +1;
    end;
END;




BEGIN

Init;
randomize;
speed := 15;
FOR i := 1 TO MAX DO ResetStar(i);
count := 0;
REPEAT
inc(count);

FOR i := 1 TO MAX DO
  BEGIN

    {Optional, makes stars move faster as they get closer}
    { Havent gotten this to look very good yet }
{
    if count mod 15 = 0 then
      begin
        if xv[i] > 0 then xv[i] := xv[i] + 1
        else if xv[i] < 0 then xv[i] := xv[i] - 1;

        if yv[i] > 0 then yv[i] := yv[i] + 1
        else if yv[i] < 0 then yv[i] := yv[i] - 1;
      end;
 }
    x[i] := x[i] + xv[i];
    y[i] := y[i] + yv[i];
    IF (x[i] > 320) or (x[i] < -320) or (y[i] > 240) or (y[i] < -240) THEN
      ResetStar(i);
    x2 := x[i];
    y2 := y[i];
    xyS := x2*x2+y2*y2;
    { x^2+y^2 = d^2 (distance from origin) would work better but slower}
    if xyS > 40000 then c[i] := 15
    else if xyS > 10000 then c[i] :=7
    else c[i] := 8;

    putpixel(x[i]+320,y[i]+240,c[i]);

  END;

    if keypressed then
      begin
        k := readkey;
        if k = 'q' then halt;
        if k = '6' then MoveRight;
        if k = '4' then MoveLeft;
        if k = '8' then MoveUp;
        if k = '2' then MoveDown;
        if k = '7' then MoveUpLeft;
        if k = '9' then MoveUpRight;
        if k = '1' then MoveDownLeft;
        if k = '3' then MoveDownRight;
        if k = '=' then dec(speed);
        if k = '-' then inc(speed);
      end;

delay(20);
FOR i := 1 TO MAX DO
  putpixel(x[i]+320,y[i]+240,0);

UNTIL 1 = 2;
END.
