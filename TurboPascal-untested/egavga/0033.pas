{
BERNIE PALLEK

> Hmm.. does anyone have an example of a starfield routine in Turbo Pascal..

OK, here's a sample (I don't know what kind of starfield you're looking for):

{EGA/VGA parallax stars}

Uses
  Crt, Graph, KasUtils;

Const
  starCol : Array[0..2] of Byte = (8, 7, 15);

Type
  StarRec = Record
    x : Integer;
    y : Integer;
    d : Integer;  { depth }
  end;

Var
  stars : Array[0..31] of StarRec;
  xinc,
  yinc  : Integer;
  ch    : Char;


Procedure OpenGraph;
Var
  gd, gm : Integer;
begin
  EgaVga_Exe;
  Gd := Detect;
  { this doesn't care if you don't have correct video card or not }
  InitGraph(gd, gm, '');   { put the path to your BGI }
end;

Procedure InitStars;
Var
  i : Integer;
begin
  For i := 0 to 31 do
  With stars[i] do
  begin
    x := Random(GetMaxX);
    y := Random(GetMaxY);
    d := Random(3);
  end;
end;

Procedure MoveStars;
Var
  i : Integer;
begin
  For i := 0 to 31 do
  With stars[i] do
  begin
    PutPixel(x, y, 0);
    x := x + xinc * (d + 1);
    if (x < 0) then
      x := x + GetMaxX;
    if (x > GetMaxX) then
      x := x - GetMaxX;
    y := y + yinc * (d + 1);
    if (y < 0) then
      y := y + GetMaxY;
    if (y > GetMaxY) then
      y := y - GetMaxY;
    PutPixel(x, y, starCol[d]);
  end;
end;

begin
  OpenGraph;  (* enter Graphics mode *)
  InitStars;
  xinc := 1;
  yinc := 0;
  Repeat
    MoveStars;
    Delay(10);
    (* Delay here For faster computers *)
  Until KeyPressed;
  ch := ReadKey;
  if (ch = #0) then
    ch := ReadKey;  (* get rid of extended keycodes *)
  CloseGraph;
end.

{
Whew!  There you have it!  Untested, of course, so you may have to iron out a
few bugs.

**** BIG HINT: You should probably use Real numbers instead of Integer numbers
for x and y positions and increments, and Round them when PutPixel-ing!  This
will allow you to make smoother transitions, as well as bouncing effects, and
other neat stuff. ****

You'll notice (if the thing works) that the stars move horizontally only, and
the dimmer ones move slower than the bright ones (parallax/multi-layered).  You
can add extra layers, but remember to change the StarCol Constant so you have
the right number of colours For the stars.

Sorry, I was too lazy to comment it thoroughly; I'm expecting that you'll be
able to figure it out Without too much trouble.  Sorry if you can't; Write me
for an explanation.  TTYL.
}
