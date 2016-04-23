(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Line in general direction version          │
   └───────────────────────────────────────────────────────────┘ *)

{
    In january this year one programer who work with my turtles (have
 own graphical unit) and write me a suggestion to make graph04.pas in
 version with relation : (a=k)  k=tg(alfa) (alfa is line-agle with
 x-coordinate) Alfa=arctg(k) It is good to use this relation because
 we muth to work with one extreme point. [x,-240]

  If sometimes is message Division by zero - it is problem with relation :
             -50+random(100)
             ---------------
             -50+random(100)

 If random=50 in denominator then -50+50=0 and this make this message.
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

Type Analytical_line=Object(kor)
                     a,b:real;
                     Procedure Init(a1,b1:real);
                     Procedure Draw_line;
                     End;

Procedure Analytical_line.Init;
Begin
a:=a1;
b:=b1;
If a<>0 Then kor.Init( (-240-b1)/a,-240,90-arctan(a)*180/Pi)
        Else kor.Init(-320,b1,0);
End;

Procedure Analytical_line.Draw_line;
Begin
If a<>0 Then Kor.Dopredu(480/(sin(arctan(a))))
        Else ZmenXY(320,b);
End;

Var Mg:MyGraph;
    Al:Analytical_line;
    I:integer;
Begin

With Mg do Begin
           Init;
           Coordinate_system;
           End;
Randomize;

With Al Do
           For i:=1 to 10 do Begin
                             init((-50+random(100))/(-50+random(100)),
                                   -100+random(200));
                             ZmenFp(1+ i mod 14);
                             Draw_line;

           CakajKlaves;
           Koniec;
           End;

End.
