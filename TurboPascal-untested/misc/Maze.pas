(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0009.PAS
  Description: MAZE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{
SEAN PALMER

> Hello there.. I was just wondering.. Since I am completely 'C'
> illiterate, could someone please make an effort and convert the
> following code in Pascal For me? (Its supposedly makes a solveable
> maze every time, Cool)

{originally by jallen@ic.sunysb.edu}
{Turbo Pascal conversion by Sean Palmer from original C}

Const
  h = 23; {height}
  w = 79; {width}

Const
  b : Array [0..3] of Integer = (-w, w, 1, -1);
  { incs For up, down, right, left }

Var
  a : Array [0..w * h - 1] of Boolean;  { the maze (False = wall) }

Procedure m(p : Integer);
Var
  i, d : Byte;
begin
  a[p] := True;           {make a path}
  Repeat
    d := 0;               {check For allowable directions}
    if (p > 2 * w) and not (a[p - w - w]) then
      inc(d, 1);          {up}
    if (p < w * (h - 2)) and not (a[p + w + w]) then
      inc(d, 2);          {down}
    if (p mod w <> w - 2) and not (a[p + 2]) then
      inc(d, 4);          {right}
    if (p mod w <> 1) and not (a[p - 2]) then
      inc(d, 8);          {left}
    if d <> 0 then
    begin
      Repeat              {choose a direction that's legal}
        i := random(4);
      Until Boolean(d and(1 shl i));

     a[p + b[i]] := True; {make a path}
     m(p + 2 * b[i]);     {recurse}
    end;
  Until d = 0;            {Until stuck}
end;

Var
  i : Integer;

begin
  randomize;
  fillChar(a, sizeof(a), False);
  m(succ(w));  {start at upper left}
  For i := 0 to pred(w * h) do
  begin {draw}
    if i mod w = 0 then
      Writeln;
    if a[i] then
      Write(' ')
    else
      Write('█');
  end;
end.

