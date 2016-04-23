CONST e = 2.7182818;

Function Exponent(Base: Real; Power: Integer): Real;
{Base can be real, power must be an integer}
  VAR
      X: INTEGER;
      E: REAL;

BEGIN;
  E:=1;
  If Power = 0 then E:=1
  Else If Power = 1 then E:=Base
       Else For X:=1 to ABS(Power) do E:=E*Base;
  If Power < 0 then E:=1/E;
  Exponent:=E;
END;

Function Log(Base, Expnt: Real): Real;
{returns common (base 10) logarithm}
Begin;
  Log:=ln(Expnt)/ln(Base);
End;

Function Prime(N: LongInt): Boolean;
{Determines if argument is prime}
  Var C: LongInt;
      S: Real;
      X: Boolean;
Begin;
  N:=ABS(N);
  S:=SQRT(N);
  X:=( (N<=2) OR (ODD(N)) AND (S <> INT(S) ) );
  If X then Begin
    C:=3;
    While (X AND (C < Int(S))) do Begin
      X:=((N Mod C) > 0);
      C:=C+2;
    End; {While}
  End; {If X}
  Prime:=X;
End; {Prime}

Function Whole(X: Real): Boolean;
Begin;
  Whole:=INT(X) = X;
End;

Function Seconds_to_Words(Sec: LongInt): String;
  CONST
       SecDay=86400;
        SecHr=3600;
       SecMin=60;
  VAR
       Days, Hours, Minutes, Seconds: LONGINT;
                                   L: BYTE;
                                T, X: STRING;

BEGIN;

  Days:=Sec DIV SecDay;
  Sec:=Sec-(SecDay*Days);
  Hours:=Sec DIV SecHr;
  Sec:=Sec-(SecHr*Hours);
  Minutes:=Sec DIV SecMin;
  Sec:=Sec-(SecMin*Minutes);
  Seconds:=Sec;

  T:='';

  If Days > 0 then Begin
    Str(Days,T);
    T := T + ' Day';
    If Days > 1 then T := T + 's';
    T := T + ', ';
  End; {If Days}

  If Hours > 0 then Begin
    Str(Hours,X);
    T := T + X + ' Hour';
    If Hours > 1 then T := T + 's';
    T := T + ', ';
  End; {If Hours}

  If Minutes > 0 then Begin
    Str(Minutes,X);
    T := T + X + ' Minute';
    If Minutes > 1 then T := T + 's';
    T := T + ', ';
  End; {If Minutes}

  If Seconds > 0 then Begin
    Str(Seconds,X);
    T := T + X + ' Second';
    If Seconds > 1 then T := T + 's';
  End; {If Seconds}

  L:=Length(T)-1;

  If T[L] = ',' then T:=Copy(T,1,(L-1));

  Seconds_To_Words:=T;

END; {Seconds to Words}

Function DegToRad(D: Real): Real;
Begin;
  DegToRad:=D*Pi/180;
End; {DegToRad}

Function GradToRad(G: Real): Real;
Begin;
  GradToRad:=G*Pi/200;
End; {GradToRad}

Function DegToGrad(D: Real): Real;
Begin;
  DegToGrad:=D/0.9;
End; {DegToGrad}

Function RadToDeg(R: Real): Real;
Begin;
  RadToDeg:=R*180/Pi;
End; {RadToDeg}

Function RadToGrad(R: Real): Real;
Begin;
  RadToGrad:=R*200/Pi;
End;

Function GradToDeg(G: Real): Real;
Begin;
  GradToDeg:=G*0.9;
End; {GradToDeg}

Function Tan(R: Real): Real;
Begin;
  Tan:=Sin(R) / Cos(R);
End; {Tan}

Function Csc(R: Real): Real;
Begin;
  Csc:=1 / Sin(R);
End; {Csc}

Function Sec(R: Real): Real;
Begin;
  Sec:=1 / Cos(R);
End; {Sec}

Function Cot(R: Real): Real;
Begin;
  Cot:=Cos(R) / Sin(R);
End; {Cot}

Function Hypotenuse_Equilateral_Triangle(S: Real): Real;
Begin;
  Hypotenuse_Equilateral_Triangle:=( SQRT(3) * S ) / 2;
End;

Function Pythagoras(A, B: Real): Real;
Begin;
  Pythagoras:=Sqrt((A*A)+(B*B));
End; {Pythagoras}

Function Triangle_Area(B, H: Real): Real;
Begin;
  Triangle_Area:=0.5 * B * H;
End; {Triangle Area}

Function Equilateral_Triangle_Area(S: Real): Real;
Begin;
  Equilateral_Triangle_Area:=( SQRT(3) * (S*S) ) / 4;
End;

Function Circle_Area(R: Real): Real;
Begin;
  Circle_Area:=Pi*(R*R);
End;

Function Ellipse_Area(A, B: Real): Real;
Begin;
  Ellipse_Area:=Pi*A*B;
End;

Function Square_Area(S: Real): Real;
Begin;
  Square_Area:=(S*S);
End;

Function Rectangle_Area(X, Y: Real): Real;
Begin;
  Rectangle_Area:=X*Y;
End;

Function Cube_Surface_Area(S: Real): Real;
Begin;
  Cube_Surface_Area:=6*(S*S);
End;

Function Rectangular_Prism_Surface_Area(H, W, L: Real): Real;
Begin;
  Rectangular_Prism_Surface_Area:=(2*H*W) + (2*H*L) + (2*L*W);
End;

Function Sphere_Surface_Area(R: Real): Real;
Begin;
  Sphere_Surface_Area:=4*Pi*(R*R);
End;

Function Cylinder_Surface_Area(R, H: Real): Real;
Begin;
  Cylinder_Surface_Area:=(2*Pi*R*H) + (2*Pi*(R*R));
End;

Function Cone_Surface_Area_Without_Base(R, H: Real): Real;
Begin;
  Cone_Surface_Area_Without_Base:=Pi*R*SQRT((R*R) + (H*H) );
End;

Function Cone_Surface_Area_With_Base(R, H: Real): Real;
Begin;
  Cone_Surface_Area_With_Base:=(Pi*R*SQRT((R*R) + (H*H)) ) + (Pi*(R*R));
End;

Function Sector_Area(R, A: Real): Real;
Begin;
  Sector_Area:=0.5*(R*R)*A;
End;

Function Trapezoid_Area(A, B, H: Real): Real;
Begin;
  Trapezoid_Area:=(H / 2) * (A + B);
End;

Function Circle_Circumference(R: Real): Real;
Begin;
  Circle_Circumference:=2*Pi*R;
End;

Function Ellipse_Circumference(A, B: Real): Real;
Begin;
  Ellipse_Circumference := (2*Pi) * ( SQRT( ( (A*A) + (B*B) ) / 2 ) );
End;

Function Cube_Volume(S: Real): Real;
Begin;
  Cube_Volume:=S*S*S;
End;

Function Rectangle_Volume(X, Y, Z: Real): Real;
Begin;
  Rectangle_Volume:=X*Y*Z;
End;

Function Sphere_Volume(R: Real): Real;
Begin;
  Sphere_Volume:=(4/3)*Pi*(R*R*R);
End;

Function Cylinder_Volume(R, H: Real): Real;
Begin;
  Cylinder_Volume:=Pi*(R*R)*H;
End; {Cylinder Volume}

Function Cone_Volume(R, H: Real): Real;
Begin;
  Cone_Volume:=(Pi*(R*R)*H)/3;
End;

Function Prism_Volume(B, H: Real): Real;
Begin;
  Prism_Volume:=B*H;
End; {Prism Volume}

Function Distance(X1, X2, Y1, Y2: Real): Real;
Begin;
  Distance:=Sqrt(Sqr(Y2-Y1)+Sqr(X2-X1));
End; {Distance}

Function Factorial(N: LongInt): LongInt;
  Var X, Y: LongInt;
Begin;
  If N <> 0 then Begin
    X:=N;
    For Y:=(N-1) downto 2 do X:=X*Y;
    Factorial:=X;
  End {If}
  Else Factorial:=1;
End; {Factorial}

Function GCF(A, B: LongInt): LongInt;
  {finds the Greatest Common Factor between 2 arguments}
  Var X, High: LongInt;
Begin;
  High:=1;
  For X:=2 to A do If (A MOD X = 0)  AND  (B MOD X = 0) then High:=X;
  GCF:=High;
End; {GCF}

Function LCM(A, B: LongInt): LongInt;
  {finds the Least Common Multiple between 2 arguments}
  Var Inc, Low, High: LongInt;
Begin;
  If A > B then Begin
    High:=A;
    Low:=B;
  End {If}
  Else Begin
    High:=B;
    Low:=A;
  End; {Else}
  Inc:=High;
  While High MOD Low <> 0 do High:=High+Inc;
  LCM:=High;
End; {LCM}

Procedure ISwap(Var X, Y: LongInt);
 {swaps 2 Integer or LongInteger variables}
 Var Z: LongInt;
Begin;
 Z:=X;
 X:=Y;
 Y:=Z;
End;

Procedure RSwap(Var X, Y: Real);
 {swaps 2 REAL variables}
 Var Z: Real;
Begin;
 Z:=X;
 X:=Y;
 Y:=Z;
End;


