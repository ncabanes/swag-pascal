program ghraph_adder;

{Copyright 1996 by Jack Neely.  All rights reserved.}
{Required BGI drivers.  Specify path in procedure INIT.}
{ make sure you set the path below !!! }

uses
   graph;

const
   Xmax = 20;               {These constants describe the screen area}
   Xmin = -10;
   Ymax = 20;
   Ymin = -10;
   Rx = Xmax - Xmin;
   Ry = Ymax - Ymin;
   Scale = 1;               {How often scaling marks are placed}

function abs(x:real):real;
{Returns the absolute value of X}
begin
   if x < 0 then
      abs:= -x
   else
      abs:= x;
end;

function power(b:real; p:integer):real;
{Returns B to the P power}
begin
   if p = 1 then
      power:= b
   else
      power:= b * power(b, p-1);
end;

{THESE ARE THE FUNCTIONS. ALL OPERATION WILL BE PREFORMED OF F(X) BY G(X).}
{Change these as you like.  These are the functions actualy graphed.}

function f(x:real):real;
begin
   f:= (0.6 * x +0.5) / (x - 2);
end;

function g(x:real):real;
begin
   g:= abs(x)+3;
end;

{**************************************************************************}

procedure init;
{Slaps you in to High-Res (hopefully) graphics mode}
var
   mode:integer;
   driver:integer;
   ErrCode:integer;
begin
   driver:= detect;
   initgraph(driver, mode, '\turbo\tp\');{The path here MUST point to your BGI drivers.}
   ErrCode := GraphResult;
   if ErrCode <> grOk then
      begin
         Writeln('Graphics error:', GraphErrorMsg(ErrCode));
         halt(1);
      end;
end;

procedure coordinates(x, y:real; var sx, sy:integer; var OnScreen:boolean);
{This is the slick procedure that makes it all work.  Pass in your X and Y
   coordinates and these two equations will find the screen position and
   return that in SX and SY.  OnScreen is TRUE if the coordinates passed in
   are on the screen, else FALSE.}
begin
   sx:= round((getmaxx / Rx) * x + ((-getmaxx/Rx) * Xmax + getmaxx));
   sy:= round((-getmaxy / Ry) * y + ((getmaxy/Ry) * Ymin + getmaxy));
   onscreen:= not ((sx < 0) or (sy < 0) or (sx > getmaxx) or (sy > getmaxy));
end;

procedure draw_grid;
{Plots XY axis}
var
   x, y,
   sx, sy:integer;
   success:boolean;
begin
   coordinates(Xmin, 0, x, y, success);
   coordinates(Xmax, 0, sx, sy, success);
   setcolor(15);
   line(x, y, sx, sy);
   coordinates(0, Ymax, x, y, success);
   coordinates(0, Ymin, sx, sy, success);
   line(x, y, sx, sy);
   for x:= trunc(Xmin) to trunc(Xmax) do
      if x / scale = x div scale then
         begin
            coordinates(x, 0, sx, sy, success);
            line(sx, sy-5, sx, sy+5);
         end;
   for y:= trunc(Ymin) to trunc(Ymax) do
      if y / scale = y div scale then
         begin
            coordinates(0, y, sx, sy, success);
            line(sx-5, sy, sx+5, sy);
         end;
end;

procedure drawgraphs;
var
   x, y, c:real;
   sx, sy:integer;
   OnScreen:boolean;
begin
   x:= Xmin;  {Graph of F(X) in blue}
   setcolor(9);
   coordinates(x, f(x), sx, sy, onscreen);
   moveto(sx, sy);
   repeat
      x:= x + (Rx / getmaxx);
      coordinates(x, f(x), sx, sy, onscreen);
      lineto(sx, sy);
   until sx >= getmaxx;

   x:= Xmin;    {Graph of G(X) in red}
   setcolor(12);
   coordinates(x, g(x), sx, sy, onscreen);
   moveto(sx, sy);
   repeat
      x:= x + (Rx / getmaxx);
      coordinates(x, g(x), sx, sy, onscreen);
      lineto(sx, sy);
   until sx >= getmaxx;

   {This next grapher is just to show off.  It graphs then sum of F(X) and
      G(X).}
   x:= Xmin;    {Graph of F(X) + G(X) in yellow}
   setcolor(14);
   coordinates(x, f(x) + g(x), sx, sy, onscreen);
   moveto(sx, sy);
   repeat
      x:= x + (Rx / getmaxx);
      coordinates(x, f(x) + g(x), sx, sy, onscreen);
      lineto(sx, sy);
   until sx >= getmaxx;
end;

begin
   init;
   draw_grid;
   drawgraphs;
   readln;
   closegraph;
end.