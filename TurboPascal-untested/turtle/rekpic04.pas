(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Squard effect with rekusion and flake      │
   └───────────────────────────────────────────────────────────┘ *)

{     This program is similar with rekpic01.pas. This program draw
  squards, but inside the squard of circuit. It is nice effect. This
  program is realizated with rekusion. It is not hard to undestand, if
  you remember rekpic01.pas. The principe of this program is symetrical
  drawing with rekusion.
      If you want to rotate picture about 45 degrees, please write :

      If i>2 Then Init(-200,-40,45)
             Else Init(-200,-100,0);
}

uses oKor,crt;

type MyKor=object(Kor)
               procedure Squard  (n:integer; s:real);
               procedure Squard1 (n:integer; s:real);
             end;

procedure MyKor.Squard(n:integer; s:real);
var i:integer;
begin
For i:=1 to 4 do Begin
                 ZmenFP(i);   {If you don't wand colors Clr this line}
                 Squard1(n,s);
                 Vpravo(90);
                 End;
end;

procedure MyKor.Squard1(n:integer; s:real);
begin
  if n=1 then Dopredu(s)
  else
    begin
      Squard1(n-1,s/3);
      Vlavo(90);
      Squard1(n-1,s/3);
      Vpravo(90);
      Squard1(n-1,s/3);
      Vpravo(90);
      Squard1(n-1,s/3);
      Vlavo(90);
      Squard1(n-1,s/3);
    end
end;

var k:MyKor;
    i:integer;

begin
  with k do Begin
    for i:=1 to 9 do
      Begin
        Init(-200,-100,0);
        Squard(i,150);
        PresunXY(-300,230); Pis('Squard effect of level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      End;
            Koniec;
            End;
end.
