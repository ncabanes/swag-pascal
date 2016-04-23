(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Triangle, circle Nx no rekuzive version    │
   └───────────────────────────────────────────────────────────┘ *)

{ This program draw circle, in triangle, in circle .... .
  First part : Ph ! You muth move the turtle in correkt position !
  Matematical relation for Pt - Point translated :
  (* L - level of n-angle *)

     A\   | D           /D   Pt[-s/2 ,-s/2*cotg(60)];
       \  |            /
        \ |    | Ps   /      Pt[-s/2 ,-s/(2*sqrt(3))
         \|    |     /
          \----|----/        Angle : 90/3=30
         B=Pt  S    C

 Pt is a point with x = -s/2 and y = -s/(2*sqrt(3)).

 Supposition : Ps is over S, because we want aquilateral triangle.
               We have rectangular triangle PsPtS.
               There Angle(PtPsS) is 360/(2*3)= 180/6 and
               PsS= -s/2*cotg(180/6) = -s/2*cotg(30).
               We muth rotate turtle in abolute angle PsPtS, not vlavo
               or vpravo !!!.

  Secend part : Pt is a centre for all triangles and circles !
  Then draw the triangle. (triangle metod) The lenght of last triangle
  is transverse (moved) for next triangle !  The lenght of s muth be 2*s.
  If is one peak of last triangle in peak of next triangle then s for last
  triangle is transverse for next triangle. The triangle is equilateral!

  Part tree : We muth draw the circle. We have s. This is averange of
              circle. We muth have a lenght for turtle for drawing in
              circumference.

              In muth is approximate relation :

              sin(alfa)<alfo<tg(alfa)         (alfa -> 0)

              Well for us is interesting sin(alfa)=tg(alfa)  (alfa -> 0)
              (Just for eliminate anomals)

              Here is interesting to use sinus sentens.

                  d             s           In program alfa = 60.
              ---------   =  --------
              sin(Pi/alfa)   tg(Pi/60)
                                           d - lenght of dopredu in
              d = s*sin(Pi/alfa)/tg(60)        circumference.

              Before we use it, you muth rotate the turtle left :
              180/L - 180/n   (n is there alfa).
              It is a angle of PtAB - alfa. (This is angle for
              eliminate anomals with tg(alfa) It is not so easy
              to undestand, but make it correkt. The effekt with
              circle is good for alfa >40.

            Then decrement level of drawing and work part 1, wihle
            n>0.

            Well, this is full documentation with math relations for this
            effekt.
}

Uses okor;

Const Alfa=95;

Type  Mykor=object(kor)
            Procedure Config(s:real);               {configuration}
            Procedure poly(n:integer;s,u:real);     {n-angle}
            Procedure triangle(s:real);             {Triangle}
            Procedure circle(n:integer;s:real);     {Circle}
            Procedure draw(n:integer;s:real);       {Draw}
            End;

var K:Mykor;
 poc:integer;

Procedure Mykor.Config(s:real);
Begin
ph;
Zmenxy(-s/2,-s/sqrt(3)/2);
Zmensmer(30);
pd;
End;

Procedure Mykor.poly(n:integer;s,u:real);
Begin
While n>0 do Begin
             Dopredu(s);
             Vpravo(u);
             Dec(n);
             End;
End;

Procedure Mykor.triangle(s:real);
Begin
poly(3,s,360/3);
End;

Procedure Mykor.circle(n:integer;s:real);
Begin
Vlavo(60-180/n);
Poly(n,s,360/n);
End;

Procedure Mykor.draw(n:integer;s:real);
Begin
While n>0 do Begin
             Inc(poc);
             Zmenfp(poc);
             Config(s);
             Triangle(s);
             s:=2*s;
             circle(alfa,s*sin(pi/alfa)/sqrt(3));
             dec(n);
             End;
End;

Begin
Poc:=0;

With k do Begin
          Init(0,0,0);
          Draw(4,50);
          Cakajklaves;
          Koniec;
          End;

End.
