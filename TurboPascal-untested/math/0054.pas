(*
>Does anyone have any equations for gravity??

It's not as tough as you probably think it is.  The way I work motion in
my programs is, I keep track of the acceleration, velocity, and position
of an object in both the x and y directions.  In other words, I have these
variables:

  var ax, ay, vx, vy, px, py: integer;

When you have a force -- like gravity, or wind resistance, or whatever --
you need to recalculate the accelerations every game round.  Then you
alter the velocities accordingly, and after that you change the positions.
For example, each round you execute code like this:

  ax := {formula for force in the "x" direction};
  ay := {formula for force in the "y" direction};

  vx := vx + ax;
  vy := vy + ay;

  px := px + vx;
  py := py + vy;

Notice how simple it is to keep track of motion: all you need to do is
supply a formula for acceleration, and the program runs "blind" after
that point.

So gravity is just a matter of supplying the right "acceleration" formulas.
If you are talking gravity near the surface of the earth, gravity provides
very nearly a constant acceleration.  In which case:

  ax := 0;  {no "horizontal" gravity}
  ay := g;  {a constant -- assign whatever value you like}

For objects to fall "down" the screen, "g" should be positive.  Motion
towards the top of the screen would mean a negative velocity.  That's
because "y" coordinates increase from top to bottom, and frankly that
confuses me and it confuses the numbers.  You might do well to do this:
have your calculations assume that "y" coordinates increase from bottom
to top, and then draw at position (px, GetMaxY + 1 - py).  With coordinates
increasing from bottom to top, "g" should be negative and upward motion
means positive "vy".

If you want gravity as applies to celestial objects in orbit, the formulas
for acceleration would be:

  x := px - sx;  { new variables: sx and sy are the locations of the sun or }
  y := py - sy;  { whatever, and x and y are thus the distances from it }

  ax := g*x / exp(3*ln(x*x + y*y)/2);
  ay := g*y / exp(3*ln(x*x + y*y)/2);

Again, I recommend plotting at (px, GetMaxY + 1 - py); and again, "g"
should be negative.

Be advised that there is a singularity at the location of the sun or
whatever: the "ln" calculations will fail.  Another gravity formula I've
seen used is "bowl" gravity, like a marble rolling around in a bowl.  It's
unrealistic, but it "feels" good and doesn't have a singularity.  In which
case:

  ax := g*x;  { negative "g" again }
  ay := g*y;

*)