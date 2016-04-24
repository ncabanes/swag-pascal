(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0005.PAS
  Description: Drawing a Circle
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{ SC> I had some free time the other day so I decided to play around
 SC> With some Graphics.  I am using TRIG Functions to draw a
 SC> circle.  But it's not too fast.  I understand that using
 SC> Shift operators to multiply and divide will be faster.  But
 SC> am not sure how to do numbers which are not powers of 2.
 SC> Here is the code; how else can we make it faster?

Using shifts to multiply things is one way to speed it up but that's difficult
For generic multiplies and only applies to Integer multiplies.  There's an even
faster way to draw a circle if you are interested. <YES he says>  OK, first it
is called the "Bresenham Circle Algorithm" and Uses symmetry about the eight
octants to plot the circle and Uses only Integer arithmetic throughout.  Here
is the code.
}
Uses
  Graph, KASUtils;

Var
  Gd, Gm : Integer;

Procedure DrawCircle(X, Y, Radius:Word; Color:Byte);
Var
   Xs, Ys    : Integer;
   Da, Db, S : Integer;
begin
     if (Radius = 0) then
          Exit;

     if (Radius = 1) then
     begin
          PutPixel(X, Y, Color);
          Exit;
     end;

     Xs := 0;
     Ys := Radius;

     Repeat
           Da := Sqr(Xs+1) + Sqr(Ys) - Sqr(Radius);
           Db := Sqr(Xs+1) + Sqr(Ys - 1) - Sqr(Radius);
           S  := Da + Db;

           Xs := Xs+1;
           if (S > 0) then
                Ys := Ys - 1;

           PutPixel(X+Xs-1, Y-Ys+1, Color);
           PutPixel(X-Xs+1, Y-Ys+1, Color);
           PutPixel(X+Ys-1, Y-Xs+1, Color);
           PutPixel(X-Ys+1, Y-Xs+1, Color);
           PutPixel(X+Xs-1, Y+Ys-1, Color);
           PutPixel(X-Xs+1, Y+Ys-1, Color);
           PutPixel(X+Ys-1, Y+Xs-1, Color);
           PutPixel(X-Ys+1, Y+Xs-1, Color);
     Until (Xs >= Ys);
end;

{It Uses Sqr at the moment, but you could code it to use X * X instead of Sqr(X)
if you like since it will probably speed it up.  I haven't had time to optimise
it yet since it will ultimately be in Assembler.

Hope this comes in handy For what you're doing. :-) Oh BTW it assumes you have
a PlotDot routine which takes the obvious parameters.
}

begin
  EGAVGA_Exe;
  gd := detect;
  InitGraph(gd,gm,'');
  clearviewport;

  drawcircle(100,100,150,yellow);
  readln;
end.
