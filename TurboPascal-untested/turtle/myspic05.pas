(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Where you turn there turtle draw circle    │
   └───────────────────────────────────────────────────────────┘ *)

{
     This program is easy to undestand.  There you klik the mouse there
  start turtle drawing circle.
    Principe 1 : Define klik. (Clear mouse buffer)
    Principe 2 : Draw circle (Other version draw circle with poly)

    If you want to have faster effekt, please delete ukaz; cakaj(1);
    UkazMys and SkryMys. (If you deleta Ukazmys and Skrymys then you
    will have some problems with circle drawing)
}

uses Mys, oKor, oVelaKor;

function Klik:boolean;
begin
  if StavMysi=0 then Klik:=false
  else
    begin
      while StavMysi<>0 do;
      Klik:=true;
    end;
end;

var a:VelaKor;

begin
  InicMys; UkazMys;
  with a do
    begin
      Init;
      repeat
        SkryMys;
        if Klik then
          begin
            UrobKor(MysX-x0,y0-MysY,random(360));
            k[pk].Ukaz;
          end;
        Dopredu(2); Vlavo(1);
        UkazMys;
        Cakaj(1);
      until false
    end;
end.
