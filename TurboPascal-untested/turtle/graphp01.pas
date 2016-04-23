(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Draw cartezian's coordinate system         │
   └───────────────────────────────────────────────────────────┘ *)

{
      This program just draw cartezian's coordinate system. This metod
  (coordinate system) will require all other turtle graph pictures. It
  is easy to undestand. Here just commands : zmenxy,presunxy. This
  program is easy to write with dopredu and vlavo or pravo. If you want
  to have clear coordinates please delete the cycles.
      The init part is prepare for other programs. IF do not want have
  in this version then modify it, but you muth to init the turtle.
  This unit is descendent of kor and in kor is turtle born. (inicializated)
}

Uses Okor;
Type Mygraph=Object(kor)
             Procedure Init;
             Procedure Coordinate_system;
             End;

Procedure Mygraph.Init;
Begin
kor.init(0,0,0);
End;

Procedure Mygraph.Coordinate_system;
Var i:integer;
Begin
ZmenFp(15);
PresunXY(-320,0);
ZmenXY(320,0);
PresunXY(315,5);
ZmenXY(320,0);
ZmenXY(315,-5);
PresunXY(310,-10);
Pis('x');

PresunXY(0,-240);;
ZmenXY(0,240);
PresunXY(-5,235);
ZmenXY(0,240);
ZmenXY(5,235);
PresunXY(8,230);
Pis('y');

For i:=0 to 32 do Begin
                  PresunXY(-320+20*i,-3);
                  ZmenXY(-320+20*i,3);
                  End;

For i:=0 to 23 do Begin
                  PresunXY(-3,-240+20*i);
                  ZmenXY(3,-240+20*i);
                  End;

End;

Var Mg:MyGraph;
Begin
With Mg do Begin
           Init;
           Coordinate_system;
           CakajKlaves;
           Koniec;
           End;
End.
