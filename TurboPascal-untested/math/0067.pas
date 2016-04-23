{
MSGID: 2:228/406 68DEA672
Here is the unit of trigonometric and hyperbolic
real functions:
}

UNIT trighyp;
{ Juhani Kaukoranta, Sysop of Pooki MBBS, Finland
  Pooki MBBS 358-82-221 782 }

INTERFACE

FUNCTION TAN(x:Real):Real;
FUNCTION COT(x:Real): Real;
FUNCTION SEC(x:Real): Real;
FUNCTION COSEC(x:Real): Real;
FUNCTION SINH(x:Real): Real;
FUNCTION COSH(x:Real): Real;
FUNCTION TANH(x:Real): Real;
FUNCTION COTH(x:Real): Real;
FUNCTION SECH(x:Real): Real;
FUNCTION COSECH(x:Real): Real;
FUNCTION ARCSIN(x:Real):Real;
FUNCTION ARCCOS(x:Real):Real;
FUNCTION ARCCOT(x:Real): Real;
FUNCTION ARCSEC(x:Real): Real;
FUNCTION ARCCOSEC(x:Real): Real;
FUNCTION ARCSINH(x:Real): Real;
FUNCTION ARCCOSH(x:Real): Real;
FUNCTION ARCTANH(x:Real): Real;
FUNCTION ARCCOTH(x:Real): Real;

IMPLEMENTATION

FUNCTION TAN(x: Real): Real;
{ argument x is in radians }
BEGIN
   TAN := SIN(x)/COS(x);
END;

FUNCTION COT(x:Real): Real;
{ cotangent, x is in radians }
BEGIN
   COT := 1/TAN(x);
END;

FUNCTION SEC(x:Real): Real;
{ secant, x is in radians }
BEGIN
   SEC := 1/COS(x);
END;

FUNCTION COSEC(x:Real): Real;
{ cosecant, x is in radians }
BEGIN
   COSEC := 1/SIN(x);
END;

FUNCTION SINH(x:real):Real;
{ hyperbolic sin }
BEGIN
   SINH := (EXP(x)-EXP(-x))/2;
END;

FUNCTION COSH(x:Real): Real;
{ hyperbolic cos }
BEGIN
   COSH := (EXP(x)+EXP(-x))/2;
END;

FUNCTION TANH(x:Real): REAL;
{ hyperbolic tan }
BEGIN
   TANH := SINH(x)/COSH(x);
END;

FUNCTION COTH(x: Real): Real;
{ hyperbolic cotangent }
BEGIN
   COTH :=SINH(x)/COSH(x);
END;

FUNCTION SECH(x:Real): Real;
{ hyperbolic secant }
BEGIN
   SECH := 1/COSH(x);
END;

FUNCTION COSECH(x:Real): Real;
{ hyperbolic cosecant }
BEGIN
   COSECH := 1/SINH(x);
END;

FUNCTION ARCSIN(x:Real):Real;
{ inverse of sin, return value is in radians }
BEGIN
   IF ABS(x)=1.0  THEN
      ARCSIN := x*Pi/2
   ELSE
      ARCSIN := ARCTAN(x/SQRT(-SQR(x)+1));
END;

FUNCTION ARCCOS(x:Real):Real;
{ inverse of cos, return value is in radians }
BEGIN
   IF x = 1.0 THEN
      ARCCOS := 0
   ELSE IF x = -1.0 THEN
      ARCCOS :=Pi
   ELSE
      ARCCOS := -ARCTAN(x/SQRT(-SQR(x)+1))+Pi/2;
END;

FUNCTION ARCCOT(x:Real): Real;
{ inverse of cot, return value is in radians }
BEGIN
   ARCCOT := ARCTAN(1/x);
END;

FUNCTION ARCSEC(x:Real): Real;
{ inverse of secant, return value is in radians }
BEGIN
   ARCSEC := ARCCOS(1/x);
END;

FUNCTION ARCCOSEC(x:Real): Real;
{ inverse of cosecant, return value is in radians }
BEGIN
   ARCCOSEC := ARCSIN(1/x);
END;

FUNCTION ARCSINH(x:Real): Real;
{ inverse of hyperbolic sin }
BEGIN
   ARCSINH := LN(x + SQRT(x*x+1));
END;

FUNCTION ARCCOSH(x:Real): Real;
{ inverse of hyperbolic cos}
BEGIN
   ARCCOSH := LN(x + SQRT(x*x-1));
END;

FUNCTION ARCTANH(x:Real): Real;
{ inverse of hyperbolic tan }
BEGIN
   ARCTANH := LN((1+x)/(1-x))/2;
END;

FUNCTION ARCCOTH(x:Real): REAL;
{ inverse of hyperbolic cotangent }
BEGIN
   ARCCOTH := LN((x+1)/(x-1))/2;
END;

END. { of unit }
