(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Parametrical express of line               │
   └───────────────────────────────────────────────────────────┘ *)

{  This is other version for define line. This is parametrical express
  of line. There are two linear equarials system defined :

  x=a1+u1*t
  y=a2+u2*t
  ---------

    [x,y] are coordinations of new point to draw. A1,a2 are coordinations
  of defined point. Point X [x,y] we have from equarials. t is a parameter.
  This is linear equarial system with one parameter t. If we use all t from
  R then we have line. If we take interval then we have halfline or abscissa.
  U1,u2 are coordinates of linevector.

  If u1=0 and u2<>0 then line is paraller with x-coordinate
  If u1<>0 and u2=0 then line is paraller with y-coordinate
  If u1=u2=0 and a1=a2=0 then are infime lines
  If u1=u2=0 and not (a1=a2=0) then don't exist the line
  Other versions : standard lines

  This program work with standard lines. If you want all extremes then
  modify the program how in graph06.pas.

    This program sometimes write message Division by zero, because this
  program work only for standard lines not for extrems.
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

                     a1,a2,u1,u2,x,y:real;
                     Procedure Init(a1i,a2i,u1i,u2i:real);
                     Procedure Draw_line;
                     End;

Procedure Analytical_line.Init;
Begin
a1:=a1i;
a2:=a2i;
u1:=u1i;
u2:=u2i;
Kor.Init(a1-u1/u2*(240+a2),-240,0);
End;


Procedure Analytical_line.Draw_line;
Begin
ZmenXY(a1+u1/u2*(240-a2),240);
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

          For i:=1 to 15 do
             Begin
             Init(-100+random(200),-100+random(200),
                  -10+random(20),-10+random(20));
             ZmenFp(1+ i mod 14);
             Draw_line;
             CakajKlaves;
             Koniec;
             End;

End.
