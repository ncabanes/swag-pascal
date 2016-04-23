(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Circle anomals                             │
   └───────────────────────────────────────────────────────────┘ *)

{ This program just draw circle anomals. It is nice effekt. This
  effekt medal Circle anomals.
}

Uses Okor;

Type Mykor=Object(kor)
                 Procedure Circle(r:real);
                 End;

Procedure Mykor.Circle(r:real);
Var i:integer;
Begin
For i:=1 to 360 do Begin
                   Vpravo(i);
                   PH;
                   Dopredu(r-1);
                   PD;
                   Dopredu(r);
                   Domov;
                   End;
end;

Var m:MyKor;
    i:integer;

Begin

With m do begin
               init(0,0,0);
               Circle(40);
               CakajKlaves;
               Koniec;
               End;

End.
