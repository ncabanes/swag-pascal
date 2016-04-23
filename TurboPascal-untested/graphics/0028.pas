{ BRendEN BEAMAN }

Program starfield;
Uses
  Crt, Graph;

Var
  l, l2,
  gd, gm,
  x, y   : Integer;
  rad    : Array [1..20] of Integer;
  p      : Array [1..20, 1..5] of Integer;

Procedure put(p, rad : Integer; col : Word);
begin
  setcolor(col);  {1 pixel arc instead of putpixel}
  arc(x, y, p, p + 1, rad);
end;

Procedure putstar;
begin
  For l := 1 to 20 do      {putting stars. #15 below is color of stars}
    For l2 := 1 to 5 do put(p[l, l2], rad[l], 15);
end;

Procedure delstar;
begin
  For l := 1 to 20 do  {erasing stars}
    For l2 := 1 to 5 do put(p[l, l2], rad[l], 0);
end;

begin
  randomize;
  gd := detect;
  initGraph(gd, gm, 'd:\bp\bgi');
  x := 320;
  y := 240;

  For l := 1 to 20 do
    rad[l] := l * 10;
  For l := 1 to 20 do
    For l2 := 1 to 5 do
      p[l, l2] := random(360);

  While not KeyPressed do
  begin
    delstar;
    For l := 1 to 20 do
    begin                {moving stars towards 'camera'}
      rad[l] := rad[l] + round(rad[l] / 20 + 1); { (20)=starspeed.  }
      if rad[l] > 400 then
        rad[l] := l * 10;                 { starspeed must be equal }
    end;                                   { to or less than 20     }
    putstar;
  end;
  readln;
end.

   The concept is fairly simple, but most people underestimate arcs...
 you can set where on the circle, (0-360 degres) the arc starts, and
 stops... if you set a one pixel arc at 100, and increase the radius of
 the circle in a loop, it will apear to come towards you in three
 dimentions... any other questions, or problems running it, contact
 me... ttyl
