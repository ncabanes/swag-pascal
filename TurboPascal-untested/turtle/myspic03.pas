(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Turtle runing the mouse line version 1     │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program modify myspic02.pas. In this version is principe :
    1. reakt to turn mouse button
    2. turtle draw line rotated to mouse

  This program clear mousebuffer. (cycle while)
}

uses oKor, Mys;

var i,j:integer;
    k:Kor;

begin
  InicMys; UkazMys;
  with k do
    begin
      init(0,-200,0);
      repeat
        if StavMysi<>0 then
          begin
            while StavMysi<>0 do;
            ZmenSmer(Smerom(MysX-x0,y0-MysY));
          end;
          Dopredu(0.025);
      until false;
  end;
end.
