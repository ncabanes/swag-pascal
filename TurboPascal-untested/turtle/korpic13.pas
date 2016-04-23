(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Honeycomb version 1                        │
   └───────────────────────────────────────────────────────────┘ *)

{      This program is for beginers. You muth draw Honeycomb. It is
   not so easy, but no difficult. You muth draw N 6-angles. You muth
   then move turtle to correkt position and make in Nx.
}

Uses Okor;

Const N=10;

Type MyTurtle=Object(Kor)
              Procedure poly(n:integer;s,u:real);
              Procedure HoneyComb(s:real);
              End;

  Procedure MyTurtle.poly(n:integer;s,u:real);
  Begin
    While n>0 do
    Begin
      dopredu(s);
      vpravo(u);
      dec(n);
    End;
  End;

Procedure MyTurtle.HoneyComb(s:real);
Var i:integer;
Begin
For i:=1 to N do Begin
                 Poly(6,s,60);
                 Ph;
                 Vlavo(90);
                 Dopredu(sqrt(3)*s);
                 Vpravo(90);
                 Pd;
                 End;
End;

Var MT:MyTurtle;
Begin

With MT do Begin
           Init(200,0,0);
           HoneyComb(30);
           CakajKlaves;
           Koniec
           End;

End.
