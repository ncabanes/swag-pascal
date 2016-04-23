(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Points in coordinate system                │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program draw points in coordinate system. This program use
  graphp01.pas. (here is graph01.pas, because there is defined just
  coordinate system) This program init the point turtle (not in
  Mygraph, because there we want to have metods for coordinate system)
  and draw the coordinate lines to coordinates. (x,y) This metod is
  very easy to undestand. Draw the parts in 20 point and finish line
  to coordinate. In 20 points part are 15 points in Pd and 5 points in
  Pd. (15 draw, 5 not draw) In math are all coordinate lines drawing to
  coordinates. I draw parts (20 points) to coordinate and if for other
  part is not space then draw the line of points to coordinate. (5 points
  I drawed not in finish part, because they are in last part) Then I
  make presunXY for writeing the name of point. I muth to modify presunXY,
  because other situation is in quadrant 1 or quadrant 4. (this are if
  constructions in draw_lines) In math are names capital letter. The
  capital letter are only 26. This program can draw only 26 points to
  coordinate system.  (in this version are not in letters some index)
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

Type Point=Object(kor)
           x,y:real;
           ch:char;
           Procedure Init(x1,y1:real; ch1:char);
           Procedure Draw_lines;
           End;

Procedure Point.Init(x1,y1:real; ch1:char);
Begin
x:=x1;
y:=y1;
ch:=ch1;
kor.init(x1,y1,0);
End;

Procedure Point.Draw_lines;
Var i:integer;
    xp,yp:real;
Begin
If y>=0 Then Vlavo(180);
For i:=1 to round(abs(y)/20)-1 do Begin
                                 Pd;
                                 Dopredu(15);
                                 Ph;
                                 Dopredu(5);
                                 End;
Pd;
Dopredu(abs(ysur-1));
Ph;
Domov;

If x>0 Then Vlavo(90)
       Else Vpravo(90);

For i:=1 to round(abs(x)/20)-1 do Begin
                                 Pd;
                                 Dopredu(15);
                                 Ph;
                                 Dopredu(5);
                                 End;
Pd;
Dopredu(abs(xsur-1));
Ph;
Domov;

If x>=0 Then if y>=0 Then PresunXY(x+8,y+8)
                     Else PresunXY(x+8,y-8)
        Else if y>=0 Then PresunXY(x-8,y+8)
                     Else PresunXY(x-8,y-8);

Pis(ch);
    End;

Var
    Mg:Mygraph;
     P:Point;
     I:integer;

Begin
Randomize;
With Mg do Begin
           Init;
           Coordinate_system;
           End;

For i:=1 to 10 do
With p do Begin
          Init(-320+random(640),-240+random(480),chr(64+i));
          ZmenFp(1+i mod 14);
          Draw_lines;
          CakajKlaves;
          Koniec;
          End;

End.
