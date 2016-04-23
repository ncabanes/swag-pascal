(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Where is turtle and mouse turn             │
   └───────────────────────────────────────────────────────────┘ *)

{
    Well, this program modify myspic05.pas. Well, this program use
  Dynkor and Dynvelakor. This program use dynamical date structures
  and polymorphism.
    Well, this program update virtual metod Obrys. If you turn button
    in position where is turtle then traw circle. (other version is if
    you use poly)
    This effekt you can to arrange if you delete ukazmys and skrymys, but
    then you will be hava some problems.
}

uses DynKor, DynVelaKor, Mys;

type PMyKor=^MyKor;
      MyKor=Object(Kor)
            Procedure Obrys; virtual;
            End;

procedure MyKor.Obrys;
var i:integer;
begin
 krok(-135,10);
 for i:=1 to 3 do krok(-90,10)
end;


const n=20;

var v:VelaKor;
    i,j:integer;
begin
  randomize;
  with v do
    begin
      init;
      for i:=1 to n do
        PridajKor(new(PMyKor,
                  Init(random(640)-320.0,random(480)-240.0,random(360))));
      Ukaz;
      UkazMys;
      repeat
        while StavMysi=0 do test;
        while StavMysi<>0 do test;
        i:=Blizko(MysX-X0,Y0-MysY);
        if i<>0 then
          begin
            SkryMys;
            with k[i]^ do
              for j:=1 to 120 do
                begin Dopredu(1); Vlavo(3) end;
            UkazMys;
          end;
      until false;
    end;
end.
