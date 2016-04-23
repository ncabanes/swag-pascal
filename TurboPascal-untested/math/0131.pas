{ N is for using the numeric coprocessor (speeds up math) and E is
  for software emulation }
{$N+} {$E-}
unit math;

interface

{ Set every "$define" to a *define except for the one that you want }
{ This defines which sort of floating-point you want to use }
{*DEFINE FP_SINGLE}
{*DEFINE FP_DOUBLE}
{*DEFINE FP_REAL}
{$DEFINE FP_EXTENDED}
{*DEFINE FP_COMP}

{ Now, to define FP as the right sort of floating point type }
{$IFDEF FP_SINGLE}
type fp=single;
{$ENDIF}
{$IFDEF FP_DOUBLE}
type fp=double;
{$ENDIF}
{$IFDEF FP_REAL}
type fp=real;
{$ENDIF}
{$IFDEF FP_EXTENDED}
type fp=extended;
{$ENDIF}
{$IFDEF FP_COMP}
type fp=comp;
{$ENDIF}

{ 3D Point. X=point[1], Y=point[2] and Z=point[3] }
type point=array[1..3] of fp;

function ordinal(i:integer):string;
function tan(x:fp):fp;
function arcsin(x:fp):fp;
function arccos(x:fp):fp;
function rad(theta:fp):fp;
procedure RotateX(var p:point; ang:fp);
procedure RotateY(var p:point; ang:fp);
procedure RotateZ(var p:point; ang:fp);

implementation
{ --------------------------------------------------------------------
  ORDINAL
  by Emil Mikulic

  Input:
   i - an integer

  Output:
   string - the ordinal suffix of i
            'st', 'nd', 'rd' or 'th'
  -------------------------------------------------------------------- }
function ordinal(i:integer):string;
var x,y:string;
begin
 { Convert i into string x }
 str(i,x);
 { Special case - 11, 12 and 13 become 11th, 12th and 13th, not
   11st, 12nd and 13rd }
 if (length(x)>1) and (x[length(x)-1]='1') then y:='th' else
 { Depending on what number x ends in...}
 case x[length(x)] of
    '1' : y:='st'; { 1 becomes 1st }
    '2' : y:='nd'; { 2 becomes 2nd }
    '3' : y:='rd'; { 3 becomes 3rd }
    else
     y:='th'; { Anything else becomes <n>th }
    end;
 ordinal:=y; { Pass on the value }
end;

{ --------------------------------------------------------------------
  TAN
  by Emil Mikulic (standard trigonometry function - in the help)

  Input:
   x - a floating point number

  Output:
   a floating point number - the tangent of x
  -------------------------------------------------------------------- }
function tan(x:fp):fp;
begin
 tan:= Sin(x) / Cos(x);
end;

{ --------------------------------------------------------------------
  ARCSIN
  by Emil Mikulic (standard trigonometry function - in the help)

  Input:
   x - a floating point number

  Output:
   a floating point number - the arcsine of x
  -------------------------------------------------------------------- }
function arcsin(x:fp):fp;
begin
 ArcSin:= ArcTan (x/sqrt (1-sqr (x)));
end;

{ --------------------------------------------------------------------
  ARCCOS
  by Emil Mikulic (standard trigonometry function - in the help)

  Input:
   x - a floating point number

  Output:
   a floating point number - the arccosine of x
  -------------------------------------------------------------------- }
function arccos(x:fp):fp;
begin
 ArcCos:= ArcTan (sqrt (1-sqr (x)) /x);
end;

{ --------------------------------------------------------------------
  RAD
  by Emil Mikulic (standard trigonometry function, also 3D math)

  Input:
   theta - a degree angle in the form of a floating point number

  Output:
   a floating point number - the radian of the degree x
  -------------------------------------------------------------------- }
function rad(theta:fp):fp;
begin
 rad := (theta/180) * pi;
end;

{ --------------------------------------------------------------------
  RotateX, RotateY, RotateZ
  by Emil Mikulic (3D math)

  Input:
   p - the point to rotate
   ang - the degree angle to rotate by

  Output:
   alters p
  -------------------------------------------------------------------- }
procedure RotateX(var p:point; ang:fp);
begin
 p[1]:=p[1];
 p[2]:=((p[2]*cos(rad(ang)))+(p[3]*sin(rad(ang))));
 p[3]:=((-p[2]*sin(rad(ang)))+(p[3]*cos(rad(ang))));
end;

procedure RotateY(var p:point; ang:fp);
begin
 p[1]:=((p[1]*cos(rad(ang)))+(p[3]*sin(rad(ang))));
 p[2]:=p[2];
 p[3]:=((-p[1]*sin(rad(ang)))+(p[3]*cos(rad(ang))));
end;

procedure RotateZ(var p:point; ang:fp);
begin
 p[1]:=(((p[1])*cos(rad(ang)))+(p[2]*sin(rad(ang))));
 p[2]:=((-p[1]*sin(rad(ang)))+(p[2]*cos(rad(ang))));
 p[3]:=p[3];
end;

end.

{ ---------------------------------CUT------------------------------- }

MATH
Unit Documentation

by Emil Mikulic

Note: TAN, ARCSIN and ARCCOS were taken from the help. The reason
behind that is that you'll be able to access them more easily
instead of having to cut and paste from the help every time.

  ----------------------------------------------------------------------

  The math unit uses a lot of floating-point math. It defines the type
  FP as EXTENDED by default but by changing the source and
  re-compiling, you can alter this.

  You can do this by changing the bit where it says:
  
  {*DEFINE FP_SINGLE}
  {*DEFINE FP_DOUBLE}
  {*DEFINE FP_REAL}
  {$DEFINE FP_EXTENDED}
  {*DEFINE FP_COMP}

  Only one is allowed to have a $ or else you get a compiler error.

  Also, for the purpose of 3D transforms, a 3D point has been defines as:
    type point=array[1..3] of fp;

  -------------------------------------------------------------------- 
  ORDINAL
  by Emil Mikulic

  Input:
   i - an integer

  Output:
   string - the ordinal suffix of i
            'st', 'nd', 'rd' or 'th'

  Examples:
   writeln(1,ordinal(1));  { Writes '1st' }
   writeln(2,ordinal(2));  { Writes '2nd' }
   writeln(3,ordinal(3));  { Writes '3rd' }
   writeln(12,ordinal(12));{ Writes '12th' }

  -------------------------------------------------------------------- 
  TAN
  by Emil Mikulic (standard trigonometry function)

  Input:
   x - a floating point number

  Output:
   a floating point number - the tangent of x
  
  -------------------------------------------------------------------- 
  ARCSIN
  by Emil Mikulic (standard trigonometry function)

  Input:
   x - a floating point number

  Output:
   a floating point number - the arcsine of x
  
  -------------------------------------------------------------------- 
  ARCCOS
  by Emil Mikulic (standard trigonometry function)

  Input:
   x - a floating point number

  Output:
   a floating point number - the arccosine of x
  
  -------------------------------------------------------------------- 
  RAD
  by Emil Mikulic (standard trigonometry function, also 3D math)

  Input:
   theta - a degree angle in the form of a floating point number

  Output:
   a floating point number - the radian of the degree x
  
  -------------------------------------------------------------------- }
  RotateX, RotateY, RotateZ
  by Emil Mikulic (3D math)

  Input:
   p - the point to rotate
   ang - the degree angle to rotate by

  Output:
   alters the variable p
  -------------------------------------------------------------------- }

