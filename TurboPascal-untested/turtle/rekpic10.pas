(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General version of Spirals colorsorted     │
   └───────────────────────────────────────────────────────────┘ *)

{ This program modify rekpic09.pas and draw general spirals in color
  sorted system. This is very easy to undestand. The color = meter of
  bring intro rekusion mod level of spirale. Easy to undestand and
  very praktical.
}

Uses Okor;

Const Distance=3;
         Level=5;

Var poc:integer;

Type Mykor=Object(Kor)
           Procedure Spirala_No_rek(s:Real);
           Procedure Spirala_rek(s:Real);
           Procedure Spirala_rek1(s:Real);
           End;

Procedure Mykor.Spirala_No_rek(s:Real);
Var i:integer;
Begin
poc:=0;
Repeat
Inc(poc);
ZmenFp(1+poc mod Level);
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
              inc(poc);
              ZmenFp(1+poc mod Level);
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
                   Inc(poc);
                   ZmenFp(1+poc mod Level);
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
          Poc:=0;
          Spirala_rek(1);
          CakajKlaves;
          Zmaz1;

          Init(-320,230,0);
          Pis('Rekusion version of spirala 2.');
          PresunXY(-50,240);
          Vlavo(90+360/Level);
          Poc:=0;
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