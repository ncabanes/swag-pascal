(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Draw point if you turn mouse               │
   └───────────────────────────────────────────────────────────┘ *)

{
     This program modify graph02.pas. In this version are points drawing to
  coordinate system if you turn the mouse. All metods are how in graph02.pas.
  Program make reaction if you have not initialized mouse driver.
}

Uses Okor,mys;

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
     i:integer;
     MouseHere:Boolean;

Begin
MouseHere:=InicMys;
If not MouseHere Then Begin
                      P.init(0,0,'A');
                      P.pis('Problem with mouse driver.');
                      Writeln(^g);
                      CakajKlaves;
                      Halt;
                      End
                 Else Begin
                      Randomize;
                      With Mg do Begin
                                 Init;
                                 Coordinate_system;
                                 End;

       UkazMys;
       With p do Begin
       While Stavmysi<>2 do
          If (stavmysi=1) Then
            If i<26 then Begin
                         SkryMys;
                         Init(MysX-320,240-MysY,chr(65+i));
                         ZmenFp(1+i mod 14);
                         Draw_lines;
                         UkazMys;
                         Inc(i);
                         While stavmysi=1 do;
                         End
                          Else Write(#7);
                 Koniec;
                    End;
                      End;

End.
