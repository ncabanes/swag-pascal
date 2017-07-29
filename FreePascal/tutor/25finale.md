## Turbo Pascal for DOS Tutorial
by Glenn Grotzinger
### Part 22: Finale
copyright(c) 1995-96 by Glenn Grotzinger

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0025.PAS
  Description: 25-Finale
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```

Here is a solution of the graphics problem from last time...

```pascal
program part21; uses graph, bgivideo, crt;
{ must be in this order }
var
  graphicsdriver, graphicsmode: integer;
  x1, x2, y1, y2: integer;

procedure errormessage(driver: string);
  begin
    writeln('There was an error: ', grapherrormsg(graphresult), driver);
    halt(1);
  end;

begin
  randomize;

  if (registerbgidriver(@attdriver) < 0) then
    errormessage('ATT');
  if (registerbgidriver(@cgadriver) < 0) then
    errormessage('CGA');
  if (registerbgidriver(@egavgadriver) < 0) then
    errormessage('EGA/VGA');
  if (registerbgidriver(@hercdriver) < 0) then
    errormessage('Herc');
  if (registerbgidriver(@pc3270driver) < 0) then
    errormessage('PC 3270');
  detectgraph(graphicsdriver, graphicsmode);
  graphicsdriver := Detect;
  initgraph(graphicsdriver, graphicsmode, '');
  if GraphResult <> grOk then
    begin
      writeln('Video error.');
      halt(1);
    end;

  repeat
    x1 := getmaxx div 2 - 15; x2 := getmaxx div 2 + 15;
    y1 := getmaxy div 2 - 15; y2 := getmaxy div 2 + 15;
    { center of screen is always (getmaxx div 2, getmaxy div 2) --
      look at geometric properties of a rectangle }
    repeat
      setcolor(random(getmaxcolor));
      rectangle(x1, y1, x2, y2);
      inc(x2, 1);inc(y2, 1);dec(x1, 1); dec(y1, 1);
      delay(50);
    until (keypressed) or (x1 <= 0);
  until keypressed;

  readln;
  closegraph;

end.

As you can see in this example, it's always good to have a good background
in analytical geometry to be able to do graphics well.  It is good for you
to find a mathematical reference and learn a few concepts of it, if you
do not already know something about it.

#### Finale
Ultimately, it was decided that object-oriented programming will not be
covered at this time for the tutorial.  I apologize.

Note
====
Be sure to read license.txt!

