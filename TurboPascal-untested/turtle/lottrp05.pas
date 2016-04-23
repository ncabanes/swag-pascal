(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Move turtles!                              │
   └───────────────────────────────────────────────────────────┘ *)

{       This program is easy to undestand.  Just move all turtles, but
 for all use one command. The lenght of move is a coeficient. This
 program show how to do with dynamical turtles. Just in two cycles
 init (with pridajkor) all turtles. Define scale for turtles and
 make relation for coeficients. Then in two cycles move turtles.
}


Uses DynKor,DynVelaKor;

Const d=40;
      u=pi/4;

Type PMyTur=^MyTur;
      MyTur=Object(kor)
              k:real;
              Constructor init(x,y,u:real);
              Procedure koef(kk:real);
              Procedure dopredu(d:real);virtual;
             End;

Constructor MyTur.init(x,y,u:real);
Begin
Inherited init(x,y,u);
k:=1;
End;

Procedure MyTur.koef(kk:real);
Begin
k:=kk;
End;

Procedure MyTur.dopredu(d:real);
Begin
Inherited dopredu(d*k);
End;

Var v:velakor;
    i,j,px,py:integer;
    y,x,dx:real;

begin
  y:=d/sin(u);
  py:=trunc(480/y);
  x:=d/cos(u);
  px:=trunc(640/x);

  with v do Begin
            Init;
            For i:=1 to py do Begin
                              Pridajkor(new(PMyTur,init(0-320,i*d/sin(u)-240,
                                             u/pi*180)));
                              PMyTur(k[pk])^.koef((480-i*d/sin(u))/cos(u));
                              End;
            For i:=py+1 to py+px do pridajkor(new(PMyTur,init((i-py-1)*d/
                                              cos(u)-320,0-240,u/pi*180)));
            j:=px;
            dx:=480*sin(u)/cos(u);
  While (dx+j*x>640) do dec(j);
  For i:=py+1 to py+j do PMyTur(k[i])^.koef(480/cos(u));
  For i:=py+j+1 to py+px do PMyTur(k[i])^.koef((640-(i-py)*d/cos(u))/cos(u));
    Ukaz;
    Pd;
    CakajKlaves;
    Dopredu(1);
    CakajKlaves;
    Koniec;
            End;

End.
