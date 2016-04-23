(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Raptile, turtles !!!                       │
   └───────────────────────────────────────────────────────────┘ *)

{
      This is small raptile. He just rotate. But there are turtles.
  It is easy to undestand, if you know dynVelakor. All turtles have
  defined just coefficient and in 3 for cycles is this effekt.
}

Uses dynvelakor,dynkor;

Const
  n=60;
  nn=640/n;
  r=8;
  nr=200 div r;

Var
  v:velakor;
  i:integer;

Type
  PMyTur=^MyTur;
   MyTur=Object(kor)
         k:real;
         Constructor init(x,y,u:real);
         Procedure koef(kk:real);
         Procedure dopredu(d:real); virtual;
         End;

Constructor MyTur.init;
Begin
Kor.init(x,y,u);
K:=1;
End;

Procedure MyTur.koef(kk:real);
Begin
k:=kk;
End;

Procedure MyTur.dopredu(d:real);
Begin
vpravo(180/nr);
kor.dopredu(d*k);
End;

Begin
With v do Begin
          init;
          For i:=1 to n do Begin
                           Pridajkor(new(PMyTur,init(nn*i-320,0,0)));
                           PMyTur(k[pk])^.koef(sin(nn*rad*i));
                           End;

    Ph;
    Ukaz;

    Repeat
    For I:=1 to nr do   Dopredu(r);
    For i:=1 to 2*nr do Dopredu(r);
    For i:=1 to nr do   Dopredu(r);
    Until false;

  Koniec;
  End;

End.
