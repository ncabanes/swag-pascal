{
  Sierpinski's Gasket using Pascal's Triangle.
  Written by Russ Cox.  June 10, 1994.

  Sierpinski's Gasket starts with an equilateral triangle.  /\
                                                          / X  \
                                                        /-------\

  This triangle then copies itself and puts a copy to the right and
  at the tip.

                               /\
                             / X  \
                           /\------/\
                         / X  \   /X  \
                       /-------\/-------\

  It keeps repeating this forever and you get this cool shape, just a lot
  bigger.  This was one of the first fractals.

  Blaise Pascal invented what is known as Pascal's Triangle.

                                 1
                                1 1
                               1 2 1
                              1 3 3 1
                             1 4 6 4 1
  etc.
  You start with sides of 1.  As you go down the triangle, to obtain a
  value, you add the numbers above to the left and above to the right.

  It just so happens that if you color the pixel for Pascal's Triangle
  as to whether or not the number is odd or even, you get Sierpinski's
  Gasket on your screen.  Have fun!!!

  (Feel free to include this in SWAG if you feel like it. I would put it
  in MATH. )

     ■ Done! - Kerry ■


  P.S. If you mess with the right value and leave mid alone... (i.e. make
  right 480 or something, the part that would have been cut off is
  instead folded over on top of the triangle.

}

program gasket;
uses graph;
var
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;
const
   right = 640;
   mid = 320;
   bottom = 256;

var
   oddeven : array[1..right] of Boolean;
   c, d, e : integer;
   prevoe  : array[1..right] of Boolean;

begin
grDriver := Detect;
  InitGraph(grDriver,grMode,'e:\bp\bgi');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    WriteLn('Graphics error:',
            GraphErrorMsg(ErrCode));
    halt(1);
  end;

  for c := 1 to right do
      prevoe[ c ] := FALSE;

  prevoe[ mid ] := TRUE;

  putpixel( mid, 1 , WHITE );
  for c := 2 to bottom do
  begin
       for d := 1 to right do
       begin
           if d = 1 then
                 oddeven[ d ] := prevoe[ d + 1 ]
           else if d = right then
oddeven[ d ] := prevoe[ d - 1 ]
           else
                 oddeven[ d ] := prevoe[ d - 1 ] xor prevoe[ d + 1 ];

       if ( d < 640 ) AND ( c < 480 ) then
          if oddeven[ d ] = TRUE then
              putpixel( d, c, WHITE )
          else
              putpixel( d, c, BLACK );

       end;
       move( oddeven, prevoe, right );
  end;


end.

{
If you use as a value any power of 2 in the previous program, you get a
full triangle, without bits and pieces falling off.
}