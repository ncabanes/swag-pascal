(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General version for flake inside           │
   └───────────────────────────────────────────────────────────┘ *)

{    This program modify snee flake (rekpic02.pas). Draw /\ it in
   inside version. This program just modify vravo to vlava in cycle
   MyKor.flake. It is nice picture, but very easy to undestand.
}

uses oKor,crt;
Const inside_level=4;

type MyKor=object(Kor)
           procedure Flake(n:integer; s:real);
           procedure Flake_pom(n:integer; s:real);
           end;

procedure MyKor.Flake(n:integer; s:real);
var i:integer;
begin
  for i:=1 to inside_level do
                           Begin
                           ZmenFP(i); {If you don't wand colors Clr this line}
                           Flake_pom(n,s);
                           Vlavo(360/inside_level);
                           End;
end;

procedure MyKor.Flake_pom(n:integer; s:real);
begin
  if n=1 then Dopredu(s)
  else
    begin
      Flake_pom(n-1,s/3);
      Vlavo(60);
      Flake_pom(n-1,s/3);
      Vpravo(120);
      Flake_pom(n-1,s/3);
      Vlavo(60);
      Flake_pom(n-1,s/3);
    end
end;

var k:MyKor;
    i:integer;

begin
  with k do Begin
    for i:=1 to 9 do
      begin
        Init(-50,-50,0);
        If ukazana=true then write(#7);
        Flake(i,720/inside_level);
        PresunXY(-300,230); Pis('Snee flake of level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      end;
            Koniec;
            End;
end.
