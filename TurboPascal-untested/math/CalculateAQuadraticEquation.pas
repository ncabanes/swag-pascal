(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0120.PAS
  Description: Calculate a quadratic equation
  Author: RODRIGO MOREIRA SILVEIRA
  Date: 03-04-97  13:18
*)

{
  Calculate and make the graphic of an quadratic equation type ax² + bx + c


Written By:
  Rodrigo Moreira Silveira - ZεU$ - BRASIL

You can Find me at:
  InterNet :
    arlindo@solar.com.br

  Adress :
    SQS 113 Bl "G" Apto 102
    Brasília - DF - BRASIL
    Cep : 70.376-070

}
Program Equation;

uses crt,graph;

var
  x1,x2,a,b,c : Real;
  grDriver,grMode: integer;

Procedure Drawon(xt,yt:real);
Begin
  PutPixel(trunc(320-(10*xt)),trunc(240-(10*yt)),Yellow);
end;


Procedure grafico;
var x0,y0,x,y : real;
begin
  x := -100; { Calculates x from -100 to 100 (*) }
  drawon(c,0);
  repeat
    x := x + 0.01; { Precision }
    y := (a*(x*x)) + (b*x) + (c);
    drawon(x,y);
  until x >= 100 { Calculates "x" from -100 to 100 (*) }
end;

Procedure Calc;
var Delta : Real; Tmp : String[10];
Begin
  SetColor(White);
  if a <> 0 then
  begin
    Delta := (b*b) - (4*a*c);
    if Delta >= 0 then
    begin
      OutTextXY(0,0,'Delta () =');
      Tmp:= '';
      str(delta:1:6,Tmp);
      OutTextXY(100,0,tmp);
      X1 := (-b) + Sqrt(Delta);
      X2 := (-b) - Sqrt(Delta);
      Tmp:= '';
      str(x1:1:6,Tmp);
      OutTextXY(0,10,'x'' =');
      OutTextXY(35,10,tmp);
      Tmp:= '';
      str(x2:1:6,Tmp);
      OutTextXY(0,20,'x'''' =');
      OutTextXY(40,20,tmp);
    end
    else OutTextXY(0,0,'Delta () < 0');
    end
  else
  begin
    if b <> 0 then begin
      X1 := (c / b);
      str(x1:1:6,Tmp);
      OutTextXY(0,0,'x =');
      OutTextXY(25,0,tmp); end
    else OutTextXY(0,0,'Constant Function');
  end;
end;

Procedure DrawCartesian;
var i,y : Word;
Begin
  SetColor(LightGray);
  for i := 1 to 96 do
    Line(0,i*10,640,i*10);
  for i := 1 to 129 do
    Line(i*10,0,i*10,480);
  SetColor(White);
  Line(0,240,640,240);
  Line(320,0,320,480);
  OutTextXY(0,230,'x');
  OutTextXY(310,0,'y');
  OutTextXY(310,230,'o');
end;

begin
  TEXTMODE(co80);
  Writeln('This Prorgam will calculate and make a graphic of an equation ax² + bx + c');
  WriteLn;WriteLn;
  Write('Type a Real equivalence to "a" : ');
  readln(a);
  Write('Type a Real equivalence to "b" : ');
  readln(b);
  Write('Type a Real equivalence to "c" : ');
  readln(c);
  grDriver := 9; {VGA}
  grMode := 2; {VGAHi = 650x480}
  initgraph(grDriver,grMode,'..\');
  DrawCartesian;{Draw The Cartesian}
  Calc;{Calculates  and the roots}
  grafico;{Calculates x and make the graphic}
  repeat until keypressed;
  readkey;
  textmode(co80);{Returns to TextMode}
end.




