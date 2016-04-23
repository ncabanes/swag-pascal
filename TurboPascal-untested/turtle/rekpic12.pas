(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Triangle in circle - rekusion version      │
   └───────────────────────────────────────────────────────────┘ *)

{ This program draw triangle in circle in triangle in .... , but
  with rekusion.
  Part one of rekusion : Nathing

  Part two of rekusion (penetrate) : Draw 1/2 of base direction.
                        Then rotate turtle to correkt angle.
                        It is 60 degrees (for elimination the next poly)
                        + angle of Tales circle. (See rekpic11.pas !)
                        Here muth be vpravo. Draw the triangle and
                        then vlavo the Tales angle for next circle.
                        We muth to draw 5/6 of circle. (270 degress sector)
                        s/2 for next triangle is transverse.
                        (see rekpic11.pas !) (n do not increment, because
                        we are working in penetrate part)
                        For this work is axiliary variable l. L is a
                        level of effekt.

  Part tree of rekusion (emerge) : Rotate a Tales circle angle and finish the
                                   circle. (1/6) Rotate 60 - Tales circle
                                   angle and finish the triangle. Here we
                                   muth s/2 because we go outside to
                                   inside.

  This program do not work with alfa. (rekpic11.pas have alfa)
}

Uses okor;

Type
  Mykor=object(kor)
    Procedure poly(n:integer;s,u:real);
    Procedure Draw(n:integer;s:real;p:integer);
  End;

Var k:Mykor;
    poc:integer;

Procedure Mykor.poly(n:integer;s,u:real);
Begin

  While n>0 do Begin
               Dopredu(s);
               Vpravo(u);
               Dec(n);
               End;

End;

Procedure Mykor.draw(n:integer;s:real;p:integer);
Begin
if p=0 then
       else Begin
            Inc(poc);
            Zmenfp(poc);
            Dopredu(s/2);
            Vpravo(60+180/n);
            Poly(round(5*n/6),2*s*sin(pi/n)/sqrt(3),360/n);
            Vlavo(180/n);
            Draw(n,s*2,p-1);
            Inc(poc);
            Zmenfp(poc);
            Vpravo(180/n);
            Poly(round(n/6),2*s*sin(pi/n)/sqrt(3),360/n);
            Vpravo(60-180/n);
            Poly(2,s,360/3);
            Dopredu(s/2);
            End;

End;

begin
poc:=0;

With k do Begin
          init(0,-50/sqrt(3)/2,-90);
          draw(120,50,4);
          Cakajklaves;
          Koniec;
          End;
End.
