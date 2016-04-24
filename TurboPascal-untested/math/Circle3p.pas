(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0002.PAS
  Description: CIRCLE3P.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

Program ThreePoints_TwoPoints;
{

   I Really appreciate ya helping me With this 3 points on a
circle problem. The only thing is that I still can't get it
to work. I've tried the Program you gave me and it spits out
the wrong answers. I don't know if there are parentheses in the
wrong place or what. Maybe you can find the error.
 
   You'll see that I've inserted True coordinates For this test.
 
Thank you once again...and please, when you get any more information
on this problem...call me collect person to person or leave it on my
BBS. I get the turbo pascal echo from a California BBS and that sure
is long distance. Getting a good pascal Procedure For this is
important to me because I am using it in a soon to be released math
Program called Mr. Machinist! I've been racking my brain about this
for 2 weeks now and I've even been dream'in about it!
 
Your help is appreciated!!!
 
 +
+AL+
 
(716) 434-7823 Voice
(716) 434-1448 BBS ... if none of these, then leave Program on TP echo.
 
}
 
Uses
  Crt;
Const
  x1 =  4.0642982;
  y1 =  0.9080732;
  x2 =  1.6679862;
  y2 =  2.8485684;
  x3 =  4.0996421;
  y3 =  0.4589868;

Var
  Selection : Integer;
Procedure ThreePoints;
Var
  Slope1,
  Slope2,
  Mid1x,
  Mid1y,
  Mid2x,
  Mid2y,
  Cx,
  Cy,
  Radius : Real;
begin
  ClrScr;
  Writeln('3 points on a circle');
  Writeln('====================');
  Writeln;
  Writeln('X1 ->  4.0642982');
  Writeln('Y1 ->  0.9080732');
  Writeln;
  Writeln('X2 ->  1.6679862');
  Writeln('Y2 ->  2.8485684');
  Writeln('X3 ->  4.0996421');
  Writeln('Y3 ->  0.4589868');
  Writeln;
  Slope1 := (y2 - y1) / (x2 - x1);
  Slope2 := (y3 - y2) / (x3 - x2);
  Mid1x  := (x1 + x2) / 2;
  Mid1y  := (y1 + y2) / 2;
  Mid2x  := (x2 + x3) / 2;
  Mid2y  := (y2 + y3) / 2;
  Slope1 := -1 * (1 / Slope1);
  Slope2 := -1 * (1 / Slope2);
  Cx     := (Slope2 * x2 - y2 - Slope1 * x1 + y1) / (Slope1 - Slope2);
  Cy     := Slope1 * (Cx + x1) - y1;

  {
  I believe you missed out on using Cx and Cy in next line,
  Radius := sqrt(((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)));
  I think it should be . . .
  }

  Radius := Sqrt(Sqr((x1 - Cx) + (y1 - Cy)));
  Writeln;
  Writeln('X center line (Program answer) is ', Cx : 4 : 4);
  Writeln('Y center line (Program answer) is ', Cy : 4 : 4);
  Writeln('The radius    (Program answer) is ', Radius : 4 : 4);
  Writeln;
  Writeln('True X center = 1.7500');
  Writeln('True Y center = 0.5000');
  Writeln('True Radius   = 2.3500');
  Writeln('Strike any key to continue . . .');
  ReadKey;
end;

Procedure Distance2Points;
Var
  x1, y1,
  x2, y2,
  Distance : Real;
begin
  ClrScr;
  Writeln('Distance between 2 points');
  Writeln('=========================');
  Writeln;
  Write('X1 -> ');
  Readln(x1);
  Write('Y1 -> ');
  Readln(y1);
  Writeln;
  Write('X2 -> ');
  Readln(x2);
  Write('Y2 -> ');
  Readln(y2);
  Writeln;
  Writeln;
  Distance := Sqrt((Sqr(x2 - x1)) + (Sqr(y2 - y1)));
  Writeln('Distance between point 1 and point 2 = ', Distance : 4 : 4);
  Writeln;
  Writeln('Strike any key to continue . . .');

  ReadKey;
end;

begin
  ClrScr;
  Writeln;
  Writeln;
  Writeln('1) Distance between 2 points');
  Writeln('2) 3 points on a circle test Program');
  Writeln('0) Quit');
  Writeln;
  Write('Choose a menu number: ');
  Readln(Selection);
    Case Selection of
      1 : Distance2Points;
      2 : ThreePoints;
    end;
  ClrScr;
end.

