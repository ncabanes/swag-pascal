(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Turtle runing the mouse version 2          │
   └───────────────────────────────────────────────────────────┘ *)

{
   This version is good, but the line is not line when the turtle
   is in mouse position. This version is not difficult to update.
   Just show mouse when MysX<>Xsur (turtle coordinates) and when
   we nove the mouse.
}

uses oKor, Mys;

var k:Kor;
      x1,y1:real;
begin
  InicMys; ZmenKurzorMysi(Disque);
  with k do Begin
      Init(0,-200,0); UkazMys;
      repeat
        StavMysi;
        ZmenSmer(Smerom(MysX-x0,y0-MysY));
        Dopredu(0.025);
      until false;
            Koniec;
            End;

end.
