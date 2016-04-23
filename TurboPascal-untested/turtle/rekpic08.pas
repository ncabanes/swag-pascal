(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Spirals                                    │
   └───────────────────────────────────────────────────────────┘ *)

{ This program draw spirals. One Nerekusive version and two rekusive
  version. In this program have one Constant Distance. This is Distance
  between two spiral levels. /-/  (- this is distance) First rekusion
  draw spirale from trm the centre.
  First rekusion : 1 part - primitive part - Nathing
                   2 part - Vlavo(60); Dopredu(s); Spirala(s+distance);
                   60 degrees = 360/6 (Level 6 of spiral)
                   Dopredu(s); Draw the line.
                   Rekusive command : Increment s with distance

  Secend rekusion : draw rekusion from end to start.
                   1 part - primitive part - Nathing
                   2 part - Dopredu(s); Vlavo(60); Spirala_rek1(s-Distance);
                   60 degrees = 360/6 (Level 6 of spiral)
                   Dopredu(s); Draw the line.
                   Rekusive command : Decrement s with distance
                   This algorithm must before rekusion rotate turtle
                   about 120 degress left. (I to / position)

  Nerekusive version : Just with cycle with repeat until. It is easy to
                       work this with Ostack.pas. }

Uses Okor,Ostack;

Const Distance=3;

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
Vlavo(60);
s:=s+distance;
Until s>247;
End;

Procedure Mykor.Spirala_rek(s:Real);
Var i:integer;
Begin
If s>247 Then
         Else Begin
              ZmenFp(random(7)+9);
              Vlavo(60);
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
                   Vlavo(60);
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
          PresunXY(0,240);
          Vlavo(120);
          Spirala_rek1(240);
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