(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Gen. v. for n-angle in circle no rekusion  │
   └───────────────────────────────────────────────────────────┘ *)

{ This program is general no rekusion version of this effekt.
  Program draw the n-angle in circle ... .

  Part one :     Translations

  This is nice effekt, but not so easy to undestand !
  (Please see rekpic11.pas)

       ┌  s     s              ┐
  Pt = │- ─ , - ─ * cotg(Pi/L) │
       └  2     2              ┘

  (See general pictute in rekpic11.pas)
  Here is rectangular triangle PsPtS.
  In general is angle = 380/(2*L) = 180/L .
  Suma angles inside = (n-2)*180 = n*180 - centre circle (2*180)
  The angle in central triangle is 180/L.
  Well, if you use rectangular triangle, we can define trigoniometry
  functions. (sinus, cosinus ...)
  We muth use here ZmenXY for absolute coordinates.
  We muth use here ZmenSmer in absolute version for nagle :

        L-2          90L - 180L - 360    90*(4-L)
   90 - ---- *180  = ---------------- =  --------
         L                  L               L

   Part two : Draw n-angle. It is just poly. Here is other mathematical
   problem. How s ?  (lenght of triangle and r for circle)
   IF you see general picture in rekpic11.pas then it is just other
   work with rectangular triangle PsPtS.
   S is just prepona. (maximal lenght in rectangular triangle)

   Part tree - Draw circle.

   This is diffycult problem. In muth is approximate relation :

   sin(alfa)<alfo<tg(alfa)         (alfa -> 0)

   Well for us is interesting sin(alfa)=tg(alfa)  (alfa -> 0)
   (Just for eliminate anomals)

   Here is interesting to use sinus sentens.

                  d             s           In program alfa = 60.
              ---------   = --------
              sin(Pi/alfa)   tg(pi/L)
                                            d - lenght of dopredu in
              d = s*sin(Pi/alfa)/tg(pi/L)        circumference.

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

const  L=6;
    Alfa=80;

Type  Mykor=object(kor)
            Procedure Config(s:real);
            Procedure poly(n:integer;s,u:real);
            Procedure triangle(s:real);
            Procedure circle(n:integer;s:real);
            Procedure draw(n:integer;s:real);
            End;

var K:Mykor;
 poc:integer;

Procedure Mykor.Config(s:real);
Begin
ph;
Zmenxy(-s/2,-s/2* (cos(pi/L) / sin(pi/L)) );
ZmenSmer(90*(4-L)/L);
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
poly(L,s,360/L);
End;

Procedure Mykor.circle(n:integer;s:real);
Begin
Vlavo(180/L-180/n);
Poly(n,s,360/n);
End;

Procedure Mykor.draw(n:integer;s:real);
Begin

While n>0 do Begin
             Inc(poc);
             Zmenfp(poc);
             Config(s);
             Triangle(s);
             s:=s/cos(pi/L);
             circle(Alfa,s*sin(pi/Alfa)/(sin(pi/L)/cos(pi/L)));
             dec(n);
             End;
End;

Begin
Poc:=0;

With k do Begin
          Init(0,0,0);
          Draw(8,80);
          CakajKlaves;
          Koniec;
          End;
End.
