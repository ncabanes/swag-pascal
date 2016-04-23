(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Squard effekt with rekusion inside         │
   └───────────────────────────────────────────────────────────┘ *)

{ This program draw squard effekt how rekpic04.pas, but this program
  draw squards inside. This program just modify vlavo(90) in
  MyKor.Squard , but the symetry is how in rekcip04.pas. This program
  have symetry of diagonals. This make other easy to undestand, but
  nice effekt.
}


uses oKor,crt;

type MyKor=Object(Kor)
           Procedure Squard  (n:integer; s:real);
           Procedure Squard1 (n:integer; s:real);
           End;

Procedure MyKor.Squard(n:integer; s:real);
Var i:integer;
Begin
For i:=1 to 4 do Begin
                 ZmenFP(i);   {If you don't wand colors Clr this line}
                 Squard1(n,s);
                 Vlavo(90);
                 End;
End;

Procedure MyKor.Squard1(n:integer; s:real);
Begin
  if n=1 then Dopredu(s)
  Else
    Begin
      Squard1(n-1,s/3);
      Vlavo(90);
      Squard1(n-1,s/3);
      Vpravo(90);
      Squard1(n-1,s/3);
      Vpravo(90);
      Squard1(n-1,s/3);
      Vlavo(90);
      Squard1(n-1,s/3);
    End
End;

Var k:MyKor;
    i:integer;

Begin
  With k do Begin
    For i:=1 to 9 do
      Begin
        Init(0,0,0);
        Squard(i,150);
        PresunXY(-300,230); Pis('Squard effekt inside level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      End;
            Koniec;
            End;
End.
