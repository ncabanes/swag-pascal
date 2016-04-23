(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Regular n-angle                            │
   └───────────────────────────────────────────────────────────┘ *)

{ This program just draw Regular n-angle. For example n=3 it is
  triangle. For n=4 it is squard. This program draw regular n-angle
  3 to 10. This program is general and know draw for all corekt n.
}

Uses Okor;

Type Mykor=Object(kor)
                 Procedure Nangle(n:integer;s:real);
                 End;

Procedure MyKor.Nangle(n:integer;s:real);
Var pom:real;
Begin
Pom:=360/n;
While n>0 do Begin
             dopredu(s);
             vlavo(pom);
             dec(n);
             End;
end;

Var m:MyKor;
    i:integer;

Begin

With m do Begin
 For i:=3 to 10 do Begin
                   init(0,0,0);
                   Nangle(i,800/i);
                   CakajKlaves;
                   Zmaz1;
                   End;
          Koniec;
          End;

End.
