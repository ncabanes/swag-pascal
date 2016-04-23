(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Oscilate the turtles !!!                   │
   └───────────────────────────────────────────────────────────┘ *)

{
      This is the modification of lotturp03.pas. Here are all
  turtles oscilate. (draw sinus) They are defined in line and
  all turtles have good coefficient. This program modify
  obrys (OutLine) and Dopredu. Dopredu is virtual metod. We
  muth to modify it, because we want to do with coefficient.
}

Uses DynKor, DynVelaKor;

Type PMyTur=^MyTur;
      MyTur=object(Kor)
               k:real;
               Constructor Init(x,y,u:real);
               Procedure Obrys; virtual;
               Procedure Koef(kk:real);
               Procedure Dopredu(d:real); virtual;
             End;

Constructor MyTur.Init(x,y,u:real);
Begin
Kor.init(x,y,u); k:=1;
End;

Procedure MyTur.Koef(kk:real);
Begin
  k:=kk;
End;

Procedure MyTur.Dopredu(d:real);
Begin
kor.Dopredu(d*k);
End;

Procedure MyTur.Obrys;
Const dt=10; ut=40; ut0=112;
Var i:integer;
Begin
Krok(180-ut0/2,0);

For i:=1 to 5 do Begin
                 Krok(180-ut0,dt);
                 Krok(180+ut,dt);
                 End;

End;

Const n=60;         {how meny turtles}
      nn=640/n;
      r=20;         {speed of effekt}
      nr=200 div r;

var v:VelaKor;
    i:integer;

Begin

  With v do Begin
            init;
            For i:=1 to n do Begin
                             PridajKor(new(PMyTur,init(nn*i-320,0,0)));
                             PMyTur(k[pk])^.Koef(sin(nn*rad*i));
                             End;

    PH;
    Ukaz;

    Repeat
    For i:=1 to nr do Dopredu(r);
    For i:=1 to 2*nr do Dopredu(-r);
    For i:=1 to nr do Dopredu(r);
    Until false;

    Koniec;
    End;

End.
