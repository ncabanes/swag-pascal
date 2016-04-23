(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General shnee flake version                │
   └───────────────────────────────────────────────────────────┘ *)

{    This program modify snee flake (rekpic01.pas). Draw  it in higher
  inside level then 3. (draw too for 1,2) Principe is Inside_level mal
  do cyklus and rotate turtle (when finish part 1) 360/inside_level
  degrees right. This program draw /\ it outside.
}


uses oKor,crt;
Const inside_level=4;

type MyKor=Object(Kor)
           Procedure Flake(n:integer; s:real);
           Procedure Flake_pom(n:integer; s:real);
           End;

Procedure MyKor.Flake(n:integer; s:real);
var i:integer;
begin
  for i:=1 to inside_level do
                         Begin
                         ZmenFP(i);   {If you don't wand colors Clr this line}
                         Flake_pom(n,s);
                         Vpravo(360/inside_level);
                         End;
end;

Procedure MyKor.Flake_pom(n:integer; s:real);
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