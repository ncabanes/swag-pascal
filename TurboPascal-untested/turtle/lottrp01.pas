(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Draw circles !                             │
   └───────────────────────────────────────────────────────────┘ *)

{
      This is first program useing oVelaKor. This program draw the
  circles. All circles have good middle of circle. The relation
  for this is for x-coordinate = 8*i-180. It is linear relation.
  We define the turtles left - right and for rotation we change
  the angle. And we draw the circle and then is this effekt.
      The constants 8,180,60 are defined just for good effekt.
}

Uses oKor, oVelaKor;

Const n=60;
Var All:VelaKor;
    i:integer;
Begin
  Randomize;
  With All do Begin
              Init;

              For i:=1 to n do Begin
                               UrobKor(8*i-180,0,12*i);
                               k[i].ZmenFP(random(15)+1);
                               End;

      With k[1] do Begin
                   PH;
                   PresunXY(-300,200);
                   Pis('Key <space> turn on/off of step mode all turtles.');
                   Domov;
                   PD;
                   End;

      Ukaz;
      CakajKlaves;

      for i:=1 to 360 do Begin
                         Dopredu(1);
                         Vlavo(1);
                         If Klaves=32 Then Begin
                                           If k[1].ukazana Then Skry
                                                           Else Ukaz;
                                           Klaves:=0;
                                           End;
                         End;

    CakajKlaves;
    Koniec;
              End;

End.
