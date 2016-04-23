(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Averange of two turtle traectoris          │
   └───────────────────────────────────────────────────────────┘ *)

{
      This is very nice effekt. Two hidden turtles are in traectory
    (circle and squard) and one turtle draw pictures where k3 is
    averange of turtles k1,k2 coordinates. This effekt draw very
    interesting picture.
    If you want to see the traectoris then write k1.ukaz; and k2.ukaz;
    If you don't want waiting delete cakaj(1);

    If are there some anomals of lines, it is nathig if the lines is a
    lot. (for example if this program go 1 minute then you can not see
    some anomals.
}

uses okor,crt;
   var k1,k2,k3:kor;
            i,j:Integer;

 begin
 k1.init(-100,100,0);
 k2.init(120,-100,0);
 k3.init(  0,   0,0);

 k1.ph;  {Squard traectory}
 k2.ph;  {Circle traectory}

 i := 1;

 while true  do begin
     k1.Dopredu(1);
     k1.Vlavo(1);
     k2.dopredu(1);
     if i > 240 then Begin
                     inc(j);
                     k3.zmenfp(j);
                     k2.Vlavo(90);
                     i:=0;
                     End;
     Inc(i);
     k3.ZmenXY((k1.XSur+k2.XSur)/2,(k1.YSur+k2.YSur)/2);
     Cakaj(0);
    End;

   k1.koniec;

End.
