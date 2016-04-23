(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : N-angle + examples                         │
   └───────────────────────────────────────────────────────────┘ *)

{ This program modify korpic04.pas. (Metod poly) Just make it
  for input u. (angle)
}

Uses Okor,graph,crt;

Type Mykor=Object(kor)
                 Procedure Poly(n:integer;s,u:real);
                 End;

Procedure MyKor.Poly(n:integer;s,u:real);
Begin

While n>0 do Begin
             Dopredu(s);
             Vlavo(u);
             Dec(n);
             End;

End;

Var m:MyKor;
    i:integer;

Begin

With m do Begin
          Init(0,0,0);
          Poly(5,200,144);
          PresunXY(-320,240);
          Pis('Judastar');
          CakajKlaves;
          Zmaz1;

          Init(0,0,0);
          Poly(8,200,135);
          PresunXY(-320,240);
          Pis('Star 1');
          CakajKlaves;
          Zmaz1;

          Init(0,0,0);
          Poly(10,200,108);
          PresunXY(-320,240);
          Pis('Star 2');
          CakajKlaves;
          Zmaz1;
          Koniec;
          End;

End.
