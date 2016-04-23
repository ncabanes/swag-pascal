(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Line in direction version                  │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program draw the Line in direction version. In this version do not
 exist line, wich can be not writed how function. If a=0 (line direction)
 then it is line paraller with x-coordination. This program can not draw
 (the direction version) the line paraller with y-coordination. This know
 graph05.pas. This version will be if a come to infinity.
     How work this program ? Active coordinate system. Then init the
 parameters for function relation : y=a*x+b (or y=k*x+q)

 If a=0 and b=0  then line = x-coordination
 If a=0 and b<>0 then line is paraller with x-coordination
 If a<>0 and b=0 then point [0,0] is in line
 If a<>0 and b<>0 then line have not [0,0]

 IF b=0 or b<>0 is not a problem and don't make some problems.
 If a=0 then it is so problem, because for extreme points (y=-240, y=240)
 in relation :    240 + b    (and for a=0 it is infinity)
                - -------
                     a

 If a>0 then the line is increasive
 If a<0 then the line is decreasive

 b is just the move of line : b>0 up
                              b<0 down

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
If a<>0 Then kor.Init( (-240-b1)/a1,-240,0)
        Else kor.Init(-320,b1,0);
End;

Procedure Analytical_line.Draw_line;
Begin
If a<>0 Then ZmenXY((240-b)/a,240)
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