(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : squard, circle Nx in norekusion version    │
   └───────────────────────────────────────────────────────────┘ *)

{ This program modify rekpic11.pas. This program draw squard in circle ...
  This just modify all parametres :

  Pt [-s/2 ,-s/2]   (cotg(45)=1)
  ZmenSmer=0    (90- 90*1 = 0) (See rekpic15.pas)
  diagonal of squard (use Pytagoras sentence)  s = sqrt(2)*s
  s for circle = s*sin(pi/alfa)
}

uses okor;

Const Alfa=60;

type Mykor=object(kor)
     Procedure Config(s:real);
     Procedure Poly(n:integer;s,u:real);
     Procedure Squard(s:real);
     Procedure Circle(n:integer;s:real);
     Procedure Draw(s:real;p:integer);
     End;

var
  k:Mykor;
 poc:integer;

Procedure Mykor.Config(s:real);
Begin
ph;
zmenxy(-s/2,-s/2);
zmensmer(0);
pd;
End;

Procedure Mykor.poly(n:integer;s,u:real);
Begin
While n>0 do
Begin
dopredu(s);
vpravo(u);
dec(n);
End;
End;

Procedure Mykor.Squard(s:real);
Begin
poly(4,s,360/4);
End;

Procedure Mykor.Circle(n:integer;s:real);
Begin
vlavo(45-180/n);
poly(n,s,360/n);
End;

Procedure Mykor.draw(s:real;p:integer);
Begin
While p>0 do
Begin
inc(poc);
Zmenfp(poc);
Config(s);
Squard(s);
s:=s*sqrt(2);
Circle(Alfa,s*sin(pi/Alfa));
dec(p);
End;
End;

begin
poc:=0;
With k do Begin
          Init(0,0,0);
          Draw(100,4);
          CakajKlaves;
          Koniec;
          End;
End.
