(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Trees with petals                          │
   └───────────────────────────────────────────────────────────┘ *)

{   This program modify rekpic17.pas. It is version tree with petals.
    Part 1: Draw how in rekpic17.pas + petal. Petal are all commands
            - dopredu(s); dopredu(-s);
    Part 2: Variables u1,u2 : this are variables for rotations in tree.
            It make good effekt. Last tree <> next tree. If you do not
            want it, please u1=u2 and u1 have absolute constant.
            Other part is how rekpic17.pas. Please see rekpic17.pas!
}

uses oKor;

type MyKor=object(Kor)
               Procedure Poly(n:integer; s,u:real);
               Procedure Tree(n:integer; s:real);
             End;

Procedure Mykor.poly(n:integer; s,u:real);
begin
  while n>0 do
    begin Dopredu(s); Vpravo(u); dec(n) end
end;

Procedure MyKor.Tree(n:integer; s:real);
Var u1,u2:integer;
    f:byte;
Begin
  if n=1 then
    begin
      Dopredu(s);
      f:=FP; ZmenFP(10);
      Vlavo(45); poly(4,5,90); Vpravo(45);
      ZmenFP(f);
      Vpravo(90); Dopredu(1); Vlavo(90);
      Dopredu(-s);
    End
  Else
    Begin
      u1:=random(40)+20; u2:=random(40)+20;
      Dopredu(s);
      Vlavo(u1);
      Tree(n-1,s*(0.4+random*0.4));
      Vpravo(u1+u2);
      Tree(n-1,s*(0.4+random*0.4));
      Vlavo(u2);
      Dopredu(-s);
    End
End;

Var k:MyKor;

Begin
  Randomize;
  With k do
   Begin
      Repeat
      Init(0,-220,0);
      Tree(5+random(5),170);
      CakajKlaves;
      Zmaz1;
      Until false;
      Koniec;
    End;
End.
