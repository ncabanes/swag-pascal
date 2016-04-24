(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0212.PAS
  Description: Morphing!
  Author: NIK DRONET
  Date: 05-26-95  23:20
*)

(*
> Could anyone explain how morphing works? I think i don't need
> the source code, but somekind of formula would be nice :)

I just finished writing Morph! (I'm taking a Graphics Class). It's simpler
than I thought (but still complicated)
Morphing = Reverse Warping + Cross Disolve

Cross dissolving: fading an image to another image.

frame1   frame2   frame3  ...  frame10 image1   100%      90%      80%
0% image2     0%      10%      20%        100%

Warping: Distorting an image. To explain: a line exists on a source image, if
that line is pulled, then the pixels around it get pulled also -- like "Silly
Puddy."
Now imagine a source image with lots of lines and a dest with lots of lines.
The lines must gradually move from on position to the other. For example in 8
steps (or frames). A WARP of the source image is performed from the
source_lines to the moved_lines, then a WARP on the destination image is
performed from the destination_lines to the SAME moved_lines. This produces
two distorted images. The source is distorted a lottle, the destination is
distorted a lot. For each frame Warps are calculated. Now the only thing left
is to fade.  Assume these 20 images are saved as source.002 ... source.009
and dest.002 ... dest.009
The source and dest images are named out.000 and out.010

Now each pixel color in source.001 is multplied by 90%, and dest.001 by 10%.
Each pixel of the two images are added tegether to produce out.001 This is
done for each frame (percentages as in above cross dissolve def.)

Now if you display out.000 through out.011 fast enough, it "Morphs"
{----------} The following program Warps an F; However it's SLOW , because it
uses REALs. Floating point math is awfully slow, and I have a lot of procedure
calls in this version.  I suggest a 486. EGA or + suggested.  My Full morph
that Morphs One image into another does it in 10 frames, it took over 48 hours
on a 486sx25.  This Warp example should be abouts 5 minutes on a 486sx25... 1
hour on an 8088.
This example Puts an 'F' on the screen and warps it.  you may change the P & Q
values.  I appologize for tremendous lack of comments. I'll insert A few
before I add it to this message..... There that may help.
*)
program morph_example;
uses graph, crt; const  MAXX       =199;
  MAXY       =199;
  MaxLines   =2;
  Lines      =2;
  little_p   =0.5;
  little_a   =0.001;
  little_b   =2;
type
  vector_type = record  {for this prog a vector is simply an x,y coord}
                  x, y : real;
                end;

  Vector_Array_Type = Array[1..maxlines] of Vector_Type;
  f_type = array[1..10] of PointType;  {THIS IS TO DRAW THE LETTER 'F'} var
  graph_driver, graph_mode, error_code : integer;
  f : f_type;

procedure set_f(var f : f_type); {THIS IS TO DRAW THE LETTER 'F'} var
 i : integer;
begin
  f[1].x := 30;
  f[1].y := 20;
  f[2].x := 30;
  f[2].y := 80;
  f[3].x := 70;
  f[3].y := 80;
  f[4].x := 70;
  f[4].y := 70;
  f[5].x := 40;
  f[5].y := 70;
  f[6].x := 40;
  f[6].y := 60;
  f[7].x := 60;
  f[7].y := 60;
  f[8].x := 60;
  f[8].y := 50;
  f[9].x := 40;
  f[9].y := 50;
  f[10].x := 40;
  f[10].y := 20;
  for i := 1 to 10 do
    begin
      f[i].y := 150 - f[i].y;
      f[i].x := f[i].x + 40;
    end;
end;

procedure initialize;{THIS IS TO DRAW THE LETTER 'F' IN A GRID} var
  x, y : integer;
begin
  x := 0;
  y := 0;
  SetColor(blue);
  while x < MAXX do
    begin
      Line(x, 0, x, MAXY - 10);
      x := x + 10;
    end;
  while y < MAXY do
    begin
      Line(0, y, MAXX - 10, y);
      y := y + 10;
    end;
  SetFillStyle(SolidFill, white);
  FillPoly(10, f);{THIS IS TO DRAW THE LETTER 'F'} end;

{--------------------------------------------------------} Procedure
VectorAdd(A,B:Vector_Type;Var C:Vector_Type); Begin   C.x:=A.x+B.x;
   C.y:=A.y+B.y;
End;
{--------------------------------------------------------} Procedure
VectorSubtract(A,B:Vector_Type; Var C:Vector_Type); Begin   C.x:=A.x-B.x;
   C.y:=A.y-B.y;
End;
{--------------------------------------------------------} Procedure
ScaleMult(A:Vector_Type; S:Real; Var C:Vector_Type); Begin
   C.x:=A.x*s;
   C.y:=A.y*s;
End;
{--------------------------------------------------------} Procedure
ScaleDiv(A:Vector_Type; S:Real; Var C:Vector_Type); Begin   C.x:=A.x/s;
   C.y:=A.y/s;
End;
{--------------------------------------------------------} Procedure
ScaleAdd(A:Vector_Type; var S:Real; Var C:Vector_Type); Begin
   C.x:=A.x+s;
   C.y:=A.y+s;
End;
{--------------------------------------------------------} Procedure
Perpendicular(A:Vector_Type; Var C:Vector_Type); Begin   C.x:=-A.y;
   C.y:=A.x;
End;
{--------------------------------------------------------} Function
DotProduct(A,B:Vector_Type):Real; Begin   DotProduct:=(A.x*B.x)+(A.y*B.y);
End;
{--------------------------------------------------------} Function
Power(a,b:real):Real; Begin   if a=0 then power:=0
   else Power:=exp(ln(a)*b);
End;
{--------------------------------------------------------} Function
Magnitude(A:Vector_Type):Real; Begin   Magnitude:=Sqrt((A.x*A.x)+(A.y*A.y));
End; {--------------------------------------------------------} Function
LineLength(A,B:Vector_Type):Real; Begin
LineLength:=Sqrt((power(abs(b.x-a.x),2))+(Power(abs(b.y-a.y),2))); End;
{--------------------------------------------------------} Function
MagnitudeSqr(A:Vector_Type):Real; var result:real; Begin
MagnitudeSqr:=(A.x*A.x)+(A.y*A.y);End;
{--------------------------------------------------------} Function
Distance(A,B:Vector_Type):Real; Begin
Distance:=Sqrt((power(abs(b.x-a.x),2))+(Power(abs(b.y-a.y),2))); End;
{--------------------------------------------------------} Function
PointDist(Pixel,P,Q:Vector_Type; u,v:Real):Real; Begin  If (u>0.0) and (u<1.0)
then PointDist:=Abs(v)  else if (u<0.0) then PointDist:=Distance(Pixel,P)
  else PointDist:=Distance(Pixel,Q);
End;
{--------------------------------------------------------} Procedure
InitVectors(Var P,Q,P_prime,Q_prime:Vector_Array_Type); Begin

  {P & Q are vectors on the destination -- thus PQ is a line on the
destination}  {p_prime & q_prime are vectors on the source -- ... a line on the
source}
{ example top horizontal line pulled up on right side} {
  q_prime[1].x := 65;
  q_prime[1].y := 70;
  p_prime[1].x := 65;
  p_prime[1].y := 130;
  q_prime[2].x := 70;
  q_prime[2].y := 65;
  p_prime[2].x := 110;
  p_prime[2].y := 65;
  q[1].x := q_prime[1].x;
  q[1].y := q_prime[1].y;
  p[1].x := p_prime[1].x;
  p[1].y := p_prime[1].y;
  q[2].x := q_prime[2].x;
  q[2].y := q_prime[2].y;
  p[2].x := p_prime[2].x;
  p[2].y := p_prime[2].y-20;
}

{ two verticle lines, then bent open at top}

  q_prime[1].x := 60;
  q_prime[1].y := 70;
  p_prime[1].x := 60;
  p_prime[1].y := 100;
  q_prime[2].x := 120;
  q_prime[2].y := 70;
  p_prime[2].x := 120;
  p_prime[2].y := 100;
  q[1].x := q_prime[1].x-10;
  q[1].y := q_prime[1].y;
  p[1].x := p_prime[1].x+5;
  p[1].y := p_prime[1].y;
  q[2].x := q_prime[2].x+10;
  q[2].y := q_prime[2].y;
  p[2].x := p_prime[2].x-5;
  p[2].y := p_prime[2].y;


{ another example
  q_prime[1].x := 70;
  q_prime[1].y := 20;
  p_prime[1].x := 120;
  p_prime[1].y := 20;
  q_prime[2].x := 70;
  q_prime[2].y := 180;
  p_prime[2].x := 120;
  p_prime[2].y := 180;
  q[1].x := q_prime[1].x+20;
  q[1].y := q_prime[1].y;
  p[1].x := p_prime[1].x-20;
  p[1].y := p_prime[1].y;
  q[2].x := q_prime[2].x;
  q[2].y := q_prime[2].y;
  p[2].x := p_prime[2].x;
  p[2].y := p_prime[2].y;
}
End;

{==================================================================} procedure
WARP;
CONST
  Xoffset=300;
  StrColor=yellow;

var
  x, y, i, ii : integer;
  u, v : real;

  {P & Q are vectors on the destination -- thus PQ is a line on the
destination}  {p_prime & q_prime are vectors on the source -- ... a line on the
source}  p, p_prime, q, q_prime: Vector_Array_Type;

  X_Prime,
  Pixel,q_minus_p, pixel_minus_p, per_q_minus_p, q_prime_minus_p_prime,
  per_q_prime_minus_p_prime : vector_type;

  D,DSum:Vector_Type;   {This stuff is to weigh the lines}
  SD,SM:Vector_Type;   {temp vars}

  str_out, str_out2 : string;

  mt1,mt2,mt3,mt4:vector_type; {temp vars}
  WeightSum,Weight,Dist,Length:Real;  {to weigh lines}

begin
  InitVectors(P,Q,P_prime,Q_prime);{ init the source & destination "lines"}

  for x := 0 to MAXX do       {for every pixel do}
    begin
    for y := 0 to MAXY do
      begin
        pixel.x := x;
        pixel.y := y;

        {calculate X_PRIME point }
        DSUM.x:=0;
        DSUM.y:=0;
        WeightSum:=0.0;

 {**} For i:=1 to Lines do Begin
        setcolor(StrColor);
        line(round(p_prime[i].x),round(p_prime[i].y),
             round(q_prime[i].x),round(q_prime[i].y));

        line(round(p[i].x+Xoffset),round(p[i].y),
             round(q[i].x+Xoffset),round(q[i].y));

{ FORMULAS: X' is pixel of source.   X is current pixel being calc'd
            P & Q are destination points(current)     P' & Q' are source
points.            remember if P and Q are points, then PQ is a line

         (X-P)(Q-P)                      (X-P)Perpindicular(Q-P)
  u =  ---------------               v =  ------------------------
       (magnitude(Q-P))^2                     magnitude(QP)


                           v  Perpindicular(Q'-P')
  X' = P' + u  (Q'-P') + ---------------------------
                               Magnitude(Q'-P')

}

        VectorSubtract(pixel,P[i],Pixel_minus_P);
        VectorSubtract(Q[i],P[i],Q_minus_P);

        u:=DotProduct(Pixel_minus_P,Q_minus_P)/
           MagnitudeSqr(Q_minus_P);

        Perpendicular(Q_minus_P,Per_Q_minus_P);
        VectorSubtract(Q_prime[i],P_prime[i],Q_prime_minus_P_prime);
        v:=DotProduct(Pixel_minus_P,Per_Q_minus_P)/
           magnitude(Q_minus_P);

        Perpendicular(Q_prime_minus_P_prime,Per_Q_prime_minus_P_prime);
        ScaleMult(Per_Q_prime_minus_P_prime,v,mt1);
        ScaleDiv(mt1,magnitude(Q_prime_minus_P_prime),mt2);
        ScaleMult(Q_prime_minus_P_prime,u,mt3);
        VectorAdd(P_prime[i],mt3,mt4);
        VectorAdd(mt4,mt2,x_prime);

        VectorSubtract(X_Prime,Pixel,D);
        dist:=PointDist(Pixel,P[i],Q[i],u,v);

        Weight:=power(
           power(LineLength(P[i],Q[i]),little_p)/(little_a+dist),
           little_b);

        ScaleMult(D,Weight,SM);
        VectorAdd(DSUM,SM,DSUM);
        WeightSum:=WeightSum+Weight;
 {**} End;
        ScaleDiv(DSUM,WeightSum,SD);
        VectorAdd(Pixel,SD,X_Prime);

        putpixel(x+Xoffset, y, getpixel(round(x_prime.x), round(x_prime.y)));
{        screen[x, y] := getpixel(round(x_prime.x), round(x_prime.y));
        putpixel(x+Xoffset, y, screen[x, y]);
}    end;

{ALL THOSE PROCEDURE CALLS AND TEMP VARs SLOW IT DOWN}

    setcolor(black);
    str(x-1, str_out);
    str_out := 'x= ' + str_out;
    OutTextXY(250, 100, str_out);

    setcolor(StrColor);
    str(x, str_out);
    str_out := 'x= ' + str_out;
    OutTextXY(250, 100, str_out);

end;
end;
{==================================================================} begin
  graph_driver := Detect;
  InitGraph(graph_driver, graph_mode, 'e:\bp\bgi'); {CHANGE TO YOUR DIR}
  error_code := GraphResult;
  if error_code <> GrOK then
    begin
      writeln('Error Graphic Driver not found');
      writeln('Error(', error_code, ')');
      exit;
    end;
  set_f(f);
  initialize;
  WARP;
  readln;
  closegraph;
end.



