(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : general version of squard effect inside    │
   └───────────────────────────────────────────────────────────┘ *)

{ This program is general version of rekpic04.pas. It is easy to udestand}


uses oKor,crt;

Const l=7;

type MyKor=object(Kor)
               procedure Squard (n:integer; s:real);
               procedure Squard1(n:integer; s:real);
             end;

procedure MyKor.Squard(n:integer; s:real);
var i:integer;
begin
For i:=1 to l do Begin
                 ZmenFP(i);   {If you don't wand colors Clr this line}
                 Squard1(n,s);
                 Vlavo(360/l);
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
    For i:=1 to 9 do
      Begin
        Init(0,0,0);
        Squard(i,750/l);
        PresunXY(-300,230); Pis('Snee flake of level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      End;
            Koniec;
            End;
End.
