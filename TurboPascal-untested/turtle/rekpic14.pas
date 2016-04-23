(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Squard in circle - rekusion version        │
   └───────────────────────────────────────────────────────────┘ *)

{ This program modify rekpic12.pas and rekpic13.pas. This program
  draw squard in circle ... . It is easy to undestand if you know
  rekpic12.pas and rekpic13.pas. The principe is :

  Move the init position
  Alfa math mod 8 !!!
  The circle in penetrate of rekusion draw 7/8 of circle.
  Here is sinus sentence too.

  Please, study rekpic12.pas and rekpic13.pas !
}

Uses okor;

Const  Alfa=120;

type
  Mykor=object(kor)
    procedure poly(n:integer;s,u:real);
    procedure Draw(s:real;p:integer);
  end;

Var k:Mykor;
    poc:integer;

procedure Mykor.poly(n:integer;s,u:real);
Begin

  while n>0 do Begin
               Dopredu(s);
               Vpravo(u);
               Dec(n);
               End;

End;

Procedure Mykor.draw(s:real;p:integer);
Begin
if p=0 then
       else Begin
            Inc(poc);
            Zmenfp(poc);
            Dopredu(s/2);
            Vpravo(45+180/alfa);
            Poly(round((1-1/8)*alfa),s*sin(pi/alfa)/cos(pi/4),360/Alfa);
            Vlavo(180/Alfa);
            Draw(s/cos(pi/4),p-1);
            Inc(poc);
            Zmenfp(poc);
            Vpravo(180/alfa);
            Poly(round(1/8*alfa),s*sin(pi/alfa)/cos(pi/4),360/alfa);
            Vpravo(45-180/alfa);
            Poly(3,s,90);
            Dopredu(s/2);
            End;
End;

begin
poc:=0;

With k do Begin
          init(0,0,0);
          presunxy(0,-100/2);
          Zmensmer(-90);
          draw(100,4);
          CakajKlaves;
          Koniec;
          End;
End.
