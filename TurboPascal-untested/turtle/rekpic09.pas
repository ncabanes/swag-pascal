(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General version of Spirals                 │
   └───────────────────────────────────────────────────────────┘ *)

{   This program modify rekpic08.pas and draw general sprirale.
    The program have two constants :
  Distance = 3
     Level = 5 {n-angle spirale
  This program just make conversion :
  Vlavo(360/Level); (* regulary n-algle have all angles equal = 360/level *)
  Maximal circuit of spirale is circle = 2*pi*r good r is 230 = 1440
}


Uses Okor;

Const Distance=3;
         Level=5;

Type Mykor=Object(Kor)
           Procedure Spirala_No_rek(s:Real);
           Procedure Spirala_rek(s:Real);
           Procedure Spirala_rek1(s:Real);
           End;

Procedure Mykor.Spirala_No_rek(s:Real);
Var i:integer;
Begin
Repeat
ZmenFp(random(7)+9);
dopredu(s);
Vlavo(360/Level);
s:=s+distance;
Until s>1440/Level;
End;

Procedure Mykor.Spirala_rek(s:Real);
Var i:integer;
Begin
If s>1440/Level Then
         Else Begin
              ZmenFp(random(7)+9);
              Vlavo(360/Level);
              Dopredu(s);
              Spirala_rek(s+Distance);
              End;
End;

Procedure Mykor.Spirala_rek1(s:Real);
Var i:integer;
Begin
If s<Distance Then
              Else Begin
                   ZmenFp(random(7)+9);
                   Dopredu(s);
                   Vlavo(360/Level);
                   Spirala_rek1(s-Distance);
                   End;
End;

Var M:MyKor;
Begin
With M do Begin
          Init(-320,230,0);
          Pis('Rekusion version of spirala 1.');
          PresunXY(0,0);
          Spirala_rek(1);
          CakajKlaves;
          Zmaz1;

          Init(-320,230,0);
          Pis('Rekusion version of spirala 2.');
          PresunXY(-50,240);
          Vlavo(90+360/Level);
          Spirala_rek1(1440/Level);
          CakajKlaves;
          Zmaz1;

          Init(-320,230,0);
          Pis('Norekusion version of spirala.');
          PresunXY(0,0);
          Spirala_No_rek(1);
          CakajKlaves;
          Koniec;
          End;

End.
