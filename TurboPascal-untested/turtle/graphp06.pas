(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Line in general equation version           │
   └───────────────────────────────────────────────────────────┘ *)

{
    This is the typical version for presentate the line algorithm.
 All good programers do with general line-eqarial. This is good
 metod, because have all versions for problems.
    The general line-equarial relation is : a*x+b*y+c=0]
  (zero-version) , where a,b,c from R.

  Problems : IF a=0 and b=0 and c=0    then line is plain RxR (kartezian
                                       product) It is c=0 and c=0. It is
                                       infimelot solution
                a=0 and b=0 and c<>)   then line don't exist in uninfine set
                                       (this line exist in infime, because
                                       c=0 and c<>0  There is zero solution
                a=0 and b<>0 and c=0   It is y=0 and x-coordinate
                a=0 and b<>0 and c<>0  It is line paraller with x-coordinate
                                        and y= -c/b
                a<>0 and b=0 and c=0   It is y-coordinate (not function)
                a<>0 and b=0 and c<>0  it is line paraller with y-coordinate
                                        and x= -c/a
                a<>0 and b<>0 and c=0  It is line with point [0,0] and
                                        y= -b/a*x
                a<>0 and b<>0 and c<>0 It is line y= - (c+bx)/a

  In part 1,2 it is extreme case for lines
  In part 3,4 it is one case
  In part 5,6 it is other extreme case for lines (don't exist function
              relation)
  In part 7,8 it is one case typical for lines

   How to undestand my program ? This program draw random lines (random
   are parametres for general equation) If is extrem 1 or 2 then program
   stop work and write the sitution message. If you undestand this then
   it is not difficult to write it in graph05.pas. (general direction
   version)  This program never write Division by zero. Good modification
   is if you know and use Brashen-Halsmanov algorithm.
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
                     a,b,c:real;
                     Procedure Init(a1,b1,c1:real);
                     Procedure Draw_line;
                     End;

Procedure Analytical_line.Init;
Begin
a:=a1;
b:=b1;
c:=c1;

If a=0 Then   If b=0 Then If c=0 Then
                            Begin
                            Zmaz1;
                            Kor.Init(-100,0,0);
                            Kor.Pis('If a=b=c=0 then are infine-lot lines.');
                            Write(#7);
                            CakajKlaves;
                            Halt;
                            End
                                 Else
                            Begin
                            Zmaz1;
                            Kor.init(-100,0,0);
                            Kor.Pis('If a=b=0 and c<>0 then don'+''+
                                    't exist'+'line in uninfime.');
                            Write(#7);
                            CakajKlaves;
                            Halt;
                            End
                     Else Kor.Init(-320,-c/b,0)
                     Else If b=0 Then Kor.Init(-c/a,-240,0)
                                 Else Kor.Init((240*b-c)/a,-240,0);
End;

Procedure Analytical_line.Draw_line;
Begin
If a=0  Then ZmenXY(320,-c/b)
        Else If b=0 Then ZmenXY(-c/a,240)
                    Else ZmenXY(-(240*b+c)/a,240)
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
             Init(-5+random(20),-5+random(20),-100+random(500));
             ZmenFp(1+ i mod 14);
             Draw_line;
             CakajKlaves;
             Koniec;
             End;

End.
