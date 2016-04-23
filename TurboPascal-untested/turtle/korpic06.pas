(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Tenis ball                                 │
   └───────────────────────────────────────────────────────────┘ *)

{
  This program draw interesting picture (tenis ball), with poly.
  The principe is very easy. Draw circle and then draw intro.
  Part one - draw smal introcircle. (rs)
  Part two - draw large introcircle (r - rs)
  Rs define averange of circle div p.
  The rotation of small circle is angle (+), but large circle
  have apposide angle (-).

  This program draw correkt. N is relation for s. (metod ball)
  (2*n is for drawing only one half of circle.
  S for circle (largest) is maximal intro +2 = outside ciecle.
  (This circle is drawing once.

}

uses okor;

type
  mkor=object(kor)
    Procedure poly(n:integer;s,u:real);
    Procedure Ball(n:integer;s:real;p:integer);
  end;

var
  k:mkor;
  Color,i:integer;

  Procedure mkor.poly(n:integer;s,u:real);
  Begin
    While n>0 do
    Begin
      dopredu(s);
      vpravo(u);
      dec(n);
    End;
  End;

  Procedure mkor.Ball(n:integer;s:real;p:integer);
  Begin
    poly(2*n,s/p*(p+1),180/N);
    for i:=1 to p do
    Begin
      inc(Color);
      Zmenfp(Color);
      ph; domov; pd;
      poly(n,s/p*i,180/n);
      poly(n,s/p*(p-i+1),-180/n);
    End;
  End;

Begin
  Color:=1;
  k.init(-150,0,0);
  k.Ball(320,2,10);
  Cakajklaves;
  k.Koniec;
End.
