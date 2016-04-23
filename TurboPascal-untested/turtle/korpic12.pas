(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : The turtle's sun                           │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program is easy to undestand. Just draw sun. One turtle draw
  circle and one object (ovelakor) draw sumbeam. All sumbeams are only
  one turtle. IF all turtles born in correkt position and angle then
  you muth just dopredu all turtles and you have sumbeams. This is
  program for beginers and present algorithmical think.
}

uses okor, crt,ovelakor;

 Const Dir     =5;
       MuchDir =120;

  var    k1:kor;
         k2:velakor;
         i:integer;

  begin
    k1.init(100,0,0);
    k2.init;

    For i:=1 to MuchDir do Begin
                           k1.Dopredu(Dir);
                              k2.urobkor(k1.xsur,k1.ysur,k1.smer+90);
                              k2.pd;
                           k1.Vlavo (360/MuchDir);
                           k1.pd;
                           Cakaj(8);
                           End;

 For i:=1 to 10 do k2.dopredu(10);

 CakajKlaves;
 K2.Koniec;

End.
