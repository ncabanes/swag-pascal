(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General version 1 for drawing graphs       │
   └───────────────────────────────────────────────────────────┘ *)

{
       This is the general version for drawing the graphs. This program
work with minimum and maximum and with interval a,b. This is the scale
for owr graph. If we have this parameters, then it is easy to draw.
This program draw it with turtles. All points we muth to transformate
to owr scale. This metod draw all graphs, where is the function in
interval inclusive D(f(x)) defined. If is the point, where x is undefined
and the point was share, then this program can not draw it. It is easy
to handle, just if is the critical moment, then not write the point in
array of x coordinates. The problem is, when a=b or we have constant
function. This program not handle it. If you want to have handled version,
see graphp21.pas. This program don't use coordinate system object.
}

Uses Okor;

Type Coord=Array[0..640] of real;
Type Graph=Object(kor)
           a,b:real;
           x,y:Coord;
           Procedure  Inits(a1,b1:real);
           Function   Trx(x1:real):integer;
           Function   Try(y1:real):integer;
           Function   f(x1:real):real;
           Procedure  Relation(Var x1,y1:Coord);
           Procedure  MaxMin(y1:coord;Var c1,d1:real);
           Procedure  Show;
           Procedure  Elaboration;
           Private
           c,d:real;
           End;

Procedure Graph.Inits(a1,b1:real);
Begin
a:=a1;
b:=b1;
End;

Procedure Graph.relation(Var x1,y1:Coord);
Var k:real;
    i:integer;
Begin
k:=(b-a)/640;

For i:=0 to 640 do Begin
                   x1[i]:=a+i*k;
                   y1[i]:=f(x1[i]);
                   End;

End;

Function Graph.Trx(x1:real):integer;
Begin
trx:=round((x1-a)/(b-a)*639)-319;
End;

Function Graph.Try(y1:real):integer;
Begin
try:=round((y1-c)/(d-c)*479)-239;
End;

Function Graph.f(x1:real):real;
Begin
f:=sin((x1*x1+1)/(x1*x1+x1+1));
End;

Procedure Graph.MaxMin(y1:coord;Var c1,d1:real);
Var       i:integer;
    max,min:integer;
Begin

Max:=1;
For i:=1 to 640 do If y1[max]<y1[i] then max:=i;
d1:=y1[max];

Min:=1;
For i:=1 to 640 do If y1[min]>y1[i] then min:=i;
c1:=y1[min];
End;

Procedure  Graph.Show;
Var i:integer;
Begin
Init(trx(x[0]),try(y[0]),0);
Zmenfp(15);
PresunXY(trx(a),try(0));
ZmenXY(trx(b),try(0));

PresunXY(trx(0),try(c));
ZmenXY(trx(0),try(d));
PresunXY(trx(x[0]),try(y[0]));
For i:=0 to 640 do Begin
                   ZmenXY(trx(x[i]),try(y[i]));
                   End;
End;

Procedure  graph.Elaboration;
Begin
Relation(x,y);
MaxMin(y,c,d);
End;

Var g:graph;
Begin

With g do Begin
          Inits(-2*pi,2*pi);
          Elaboration;
          Init(trx(x[0]),try(y[0]),0);
          Show;
          CakajKlaves;
          Koniec;
          End;

End.
