(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : All turtles draw circle once               │
   └───────────────────────────────────────────────────────────┘ *)

{
      This program is easy to undestand. Just draw circles with
  modificated Obrys. (OutLine) This program presents the polymorphism
  and dynamical metods. Here are all turtles drawing at once.
}

uses dynkor,dynvelakor;

type
  PMyTur1=^MyTur1;
   MyTur1=object(kor)
    Procedure obrys; virtual;

  End;
  PMyTur2=^MyTur2;
   MyTur2=object(kor)
    Procedure obrys; virtual;
  End;

Var
  v:velakor;
  i:integer;
  x,y,u:real;

Procedure MyTur2.obrys;
Begin
  krok(-45,0);
  for i:=1 to 4 do krok(-90,10);
End;

Procedure MyTur1.obrys;
Const
  dt=10;
  ut=40;
  ut0=112;
Begin

  krok(ut0/2,0);
  for i:=1 to 5 do Begin
                   Krok(180-ut0,dt);
                   Krok(180+ut,dt);
                   End;

End;

Begin
  randomize;
  With v do Begin
            init;
            For i:=1 to 10 do Begin
                              x:=random(640)-320;
                              y:=random(480)-240;
                              u:=random(360);
                              Case random(3) of
                                0:urobkor(x,y,u);
                                1:Pridajkor(new(PMyTur1,init(x,y,u)));
                                2:Pridajkor(new(PMyTur2,init(x,y,u)));
                              End;

            End;

    Ukaz;

    Repeat
    Dopredu(3);
    Vpravo(3);
    Until false;

            Koniec;
            End;

End.
