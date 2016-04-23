{$N+,E+} {Use math coprocessor, if any, emulate otherwise.}
UNIT ComplexOps;  { see demo at end }

 {This UNIT provides complex arithmetic and transcendental functions.

  (C) Copyright 1990, 1992, Earl F. Glynn, Overland Park, KS.  Compuserve 73257,3527.
  All rights reserved.  This program may be freely distributed only for
  non-commercial use.

  Some ideas in this UNIT were borrowed from "A Pascal Tool for Complex
  Numbers", Journal of Pascal, Ada, & Modula-2, May/June 1985, pp. 23-29.
  Many complex formulas were taken from Chapter 4, "Handbook of Mathematical
  Functions" (Ninth Printing), Abramowitz and Stegun (editors), Dover, 1972.}

INTERFACE

  TYPE
    RealType    = DOUBLE;
    ComplexForm = (polar,rectangular);
    Complex =
      RECORD
        CASE form:  ComplexForm OF
          rectangular:  (x,y    :  RealType);  {z = x + y*i}
          polar      :  (r,theta:  RealType);  {z = r*CIS(theta)}
      END;                 {where CIS(theta) = COS(theta) + SIN(theta)*i}
                           {      theta = -PI..PI (in canonical form)}

  CONST
    MaxTerm    : BYTE     = 35;
    EpsilonSqr : RealType = 1.0E-20;
    Infinity   : RealType = 1.0E25;    {virtual infinity}

                             {complex number definition/conversion/output}
  PROCEDURE CConvert (VAR z:  Complex; f:  ComplexForm);
  PROCEDURE CSet (VAR z:  Complex; a,b:  RealType; f:  ComplexForm);
  FUNCTION  CStr (z:  Complex; w,d:  BYTE; f:  ComplexForm):  STRING;

                             {complex arithmetic}
  PROCEDURE CAdd  (VAR z:  Complex; a,b:  Complex);    {z = a + b}
  PROCEDURE CDiv  (VAR z:  Complex; a,b:  Complex);    {z = a / b}
  PROCEDURE CMult (VAR z:  Complex; a,b:  Complex);    {z = a * b}
  PROCEDURE CSub  (VAR z:  Complex; a,b:  Complex);    {z = a - b}
  PROCEDURE CNeg  (VAR z:  Complex; a  :  Complex);    {z = -a   }

                             {complex natural log, exponential}
  PROCEDURE CLn   (VAR fn :  Complex; z:  Complex);   {fn  = ln(z) }
  PROCEDURE CExp  (VAR z  :  Complex; a:  Complex);   {z   = exp(a)}
  PROCEDURE CPwr  (VAR z  :  Complex; a,b:  Complex); {z   = a^b   }

                             {complex trig functions}
  PROCEDURE CCos  (VAR z:  Complex; a:  Complex);     {z   = cos(a)}
  PROCEDURE CSin  (VAR z:  Complex; a:  Complex);     {z   = sin(a)}
  PROCEDURE CTan  (VAR z:  Complex; a:  Complex);     {z   = tan(a)}

  PROCEDURE CSec  (VAR z:  Complex; a:  Complex);     {z   = sec(a)}
  PROCEDURE CCsc  (VAR z:  Complex; a:  Complex);     {z   = csc(a)}
  PROCEDURE CCot  (VAR z:  Complex; a:  Complex);     {z   = cot(a)}

                             {complex hyperbolic functions}
  PROCEDURE CCosh (VAR z:  Complex; a:  Complex);     {z   = cosh(a)}
  PROCEDURE CSinh (VAR z:  Complex; a:  Complex);     {z   = sinh(a)}
  PROCEDURE CTanh (VAR z:  Complex; a:  Complex);     {z   = tanh(a)}

  PROCEDURE CSech (VAR z:  Complex; a:  Complex);     {z   = sech(a)}
  PROCEDURE CCsch (VAR z:  Complex; a:  Complex);     {z   = csch(a)}
  PROCEDURE CCoth (VAR z:  Complex; a:  Complex);     {z   = coth(a)}

                             {miscellaneous complex functions}
  FUNCTION  CAbs (z:  Complex):  RealType;                 {CAbs = |z|}
  FUNCTION  CAbsSqr (z:  Complex):  RealType;           {CAbsSqr = |z|^2}
  PROCEDURE CIntPwr (VAR z:  Complex; a:  Complex; n:  INTEGER); {z = a^n}
  PROCEDURE CRealPwr (VAR z:  Complex; a:  Complex; x:  RealType); {z = a^x}
  PROCEDURE CConjugate (VAR z:  Complex; a:  Complex);        {z = a*}
  PROCEDURE CSqrt (VAR z:  Complex; a:  Complex);      {z = SQRT(a)}
  PROCEDURE CRoot (VAR z:  Complex; a:  Complex; k,n:  WORD); {z = a^(1/n)}

                             {complex Bessel functions of order zero}
  PROCEDURE CI0   (VAR sum:  Complex; z:  Complex);  {sum = I0(z)}
  PROCEDURE CJ0   (VAR sum:  Complex; z:  Complex);  {sum = J0(z)}

  PROCEDURE CLnGamma (VAR z:  Complex; a:  Complex);
  PROCEDURE CGamma   (VAR z:  Complex; a:  Complex);

                                  {treat "fuzz" of real numbers}
  PROCEDURE CDeFuzz (VAR z:  Complex);
  FUNCTION  DeFuzz (x:  RealType):  RealType;
  PROCEDURE SetFuzz (value:  RealType);

                                  {miscellaneous}
  FUNCTION FixAngle (theta:  RealType):  RealType;    {-PI < theta <= PI}
  FUNCTION Pwr (x,y:  RealType):  RealType;    {Pwr = x^y}
  FUNCTION Log10 (x:  RealType):  RealType;
  FUNCTION LongMod (l1,l2:  LongInt):  LongInt;
  FUNCTION Cosh (x:  RealType):  RealType;
  FUNCTION Sinh (x:  RealType):  RealType;

IMPLEMENTATION

  VAR
    fuzz     :  RealType;
    Cone     :  Complex;
    Cinfinity:  Complex;
    Czero    :  Complex;
    hLnPI    :  RealType;
    hLn2PI   :  RealType;
    ln2      :  RealType;

                             {complex number definition/conversion/output}
  PROCEDURE CConvert (VAR z:  Complex; f:  ComplexForm);
    VAR a:  Complex;
  BEGIN
    IF   z.form = f
    THEN CDeFuzz (z)
    ELSE BEGIN
      CASE z.form OF
        polar:            {polar-to-rectangular conversion}
          BEGIN
            a.form := rectangular;
            a.x := z.r * COS(z.theta);
            a.y := z.r * SIN(z.theta)
          END;
        rectangular:      {rectangular-to-polar conversion}
          BEGIN
            a.form := polar;
            IF   DeFuzz(z.x) = 0.0
            THEN BEGIN
              IF   DeFuzz(z.y) = 0.0
              THEN BEGIN
                a.r     := 0.0;
                a.theta := 0.0
              END
              ELSE
                IF   z.y > 0.0
                THEN BEGIN
                  a.r := z.y;
                  a.theta := 0.5*PI
                END
                ELSE BEGIN
                  a.r := -z.y;
                  a.theta := -0.5*PI
                END
            END
            ELSE BEGIN
              a.r := CAbs(z);
              a.theta := ARCTAN(z.y/z.x);   {4th/1st quadrant -PI/2..PI/2}
              IF   z.x < 0.0                {2nd/3rd quadrants}
              THEN
                IF   z.y >= 0.0
                THEN a.theta :=  PI + a.theta {2nd quadrant:  PI/2..PI}
                ELSE a.theta := -PI + a.theta {3rd quadrant: -PI..-PI/2}
            END
          END;
      END;
      CDeFuzz (a);
      z := a
    END
  END {CConvert};

  PROCEDURE CSet (VAR z:  Complex; a,b:  RealType; f:  ComplexForm);
  BEGIN
    z.form := f;
    CASE f OF
      polar:
        BEGIN
          z.r := a;
          z.theta := b
        END;
      rectangular:
        BEGIN
          z.x := a;
          z.y := b
        END;
    END
  END {CSet};

  FUNCTION  CStr (z:  Complex; w,d:  BYTE; f:  ComplexForm):  STRING;
    VAR s1,s2:  STRING;
  BEGIN
    CConvert (z,f);
    CASE f OF
      polar:
        BEGIN
          Str (z.r:w:d, s1);
          Str (z.theta:w:d, s2);
          CStr := s1+'*CIS('+s2+')'
        END;
      rectangular:
        BEGIN
          Str (z.x:w:d, s1);
          Str (ABS(z.y):w:d, s2);
          IF   z.y >= 0
          THEN CStr := s1+' +'+s2+'i'
          ELSE CStr := s1+' -'+s2+'i'
        END
    END
  END {CStr};

                                  {complex arithmetic}
  PROCEDURE CAdd  (VAR z:  Complex; a,b:  Complex);    {z = a + b}
  BEGIN                                               {complex addition}
    CConvert (a,rectangular);
    CConvert (b,rectangular);
    z.form := rectangular;
    z.x := a.x + b.x;   {real part}
    z.y := a.y + b.y;   {imaginary part}
  END {CAdd};

  PROCEDURE CDiv  (VAR z:  Complex; a,b:  Complex);    {z = a / b}
    VAR temp:  RealType;
  BEGIN
    CConvert (b,a.form);    {arbitrarily convert one to type of other}
    z.form := a.form;
    CASE a.form OF
      polar:
        BEGIN
          z.r := a.r / b.r;
          z.theta := FixAngle(a.theta - b.theta)
        END;
      rectangular:
        BEGIN
          temp := SQR(b.x) + SQR(b.y);
          z.x := (a.x*b.x + a.y*b.y) / temp;
          z.y := (a.y*b.x - a.x*b.y) / temp
        END
    END
  END {CDiv};

  PROCEDURE CMult (VAR z:  Complex; a,b:  Complex);    {z = a * b}
  BEGIN
    CConvert (b,a.form);    {arbitrarily convert one to type of other}
    z.form := a.form;
    CASE a.form OF
      polar:
        BEGIN
          z.r := a.r * b.r;
          z.theta := FixAngle(a.theta + b.theta)
        END;
      rectangular:
        BEGIN
          z.x := a.x*b.x - a.y*b.y;
          z.y := a.x*b.y + a.y*b.x
        END
    END
  END {CMult};

  PROCEDURE CSub  (VAR z:  Complex; a,b:  Complex);    {z = a - b}
  BEGIN                                               {complex subtraction}
    CConvert (a,rectangular);
    CConvert (b,rectangular);
    z.form := rectangular;
    z.x := a.x - b.x;   {real part}
    z.y := a.y - b.y;   {imaginary part}
  END {CSub};

  PROCEDURE CNeg  (VAR z:  Complex; a  :  Complex);    {z = -a   }
  BEGIN
    z.form := a.form;
    CASE a.form OF
      polar:
        BEGIN
          z.r := a.r;
          z.theta := FixAngle(a.theta + PI)
        END;
      rectangular:
        BEGIN
          z.x := -a.x;
          z.y := -a.y
        END
    END
  END {CNeg};
                                  {complex natural log, exponential}
  PROCEDURE CLn (VAR fn:  Complex; z:  Complex);  {fn  = ln(z)}
  BEGIN  {Abramowitz formula 4.1.2 on p. 67}
    CConvert (z,polar);
    fn.form := rectangular;
    fn.x := LN(z.r);
    fn.y := FixAngle(z.theta)
  END {CLn};  {principal value only}

  PROCEDURE CExp  (VAR z  :  Complex; a:  Complex);   {z   = exp(a)}
    VAR
      temp:  RealType;
  BEGIN  {Euler's Formula:  Abramowitz formula 4.3.47 on p. 74}
    CConvert (a,rectangular);
    temp := EXP(a.x);
    CSet (z, temp*COS(a.y),temp*SIN(a.y), rectangular)
  END {CExp};

  PROCEDURE CPwr  (VAR z  :  Complex; a,b:  Complex); {z   = a^b   }
    VAR
      blna,lna:  Complex;
  BEGIN  {Abramowitz formula 4.2.7 on p. 69}
    CDeFuzz (a);
    CDeFuzz (b);
    IF   CAbsSqr(a) = 0.0
    THEN
      IF    (CAbsSqr(b) = 0.0)
      THEN  z := Cone                   {lim a^a = 1 as a -> 0}
      ELSE  z := Czero                  {0^b = 0, b <> 0}
    ELSE BEGIN
      CLn (lna,a);
      CMult (blna,b,lna);
      CExp (z, blna)
    END
  END {CPwr};
                                  {complex trig functions}
  PROCEDURE CCos  (VAR z:  Complex; a:  Complex);     {z   = cos(a)}
  BEGIN  {Abramowitz formula 4.3.56 on p. 74}
    CConvert (a,rectangular);
    CSet (z, COS(a.x)*COSH(a.y), -SIN(a.x)*SINH(a.y), rectangular)
  END {CCos};

  PROCEDURE CSin  (VAR z:  Complex; a:  Complex);     {z   = sin(a)}
  BEGIN  {Abramowitz formula 4.3.55 on p. 74}
    CConvert (a,rectangular);
    CSet (z, SIN(a.x)*COSH(a.y), COS(a.x)*SINH(a.y), rectangular)
  END {CSin};

  PROCEDURE CTan  (VAR z:  Complex; a:  Complex);     {z   = tan(a)}
    VAR
      temp:  RealType;
  BEGIN  {Abramowitz formula 4.3.57 on p. 74}
    CConvert (a,rectangular);
    temp := COS(2.0*a.x) + COSH(2.0*a.y);
    IF   DeFuzz(temp) <> 0.0
    THEN BEGIN
      CSet (z,SIN(2.0*a.x)/temp,SINH(2.0*a.y)/temp,rectangular)
    END
    ELSE z := Cinfinity
  END {CTan};

  PROCEDURE CSec  (VAR z:  Complex; a:  Complex);     {z   = sec(a)}
    VAR
      temp:  Complex;
  BEGIN  {Abramowitz formula 4.3.5 on p. 72}
    CCos (temp, a);
    IF   DeFuzz( Cabs(temp) ) <> 0.0
    THEN CDiv (z, Cone,temp)
    ELSE z := Cinfinity
  END {CSec};

  PROCEDURE CCsc  (VAR z:  Complex; a:  Complex);     {z   = csc(a)}
    VAR
      temp:  Complex;
  BEGIN  {Abramowitz formula 4.3.4 on p. 72}
    CSin (temp, a);
    IF   DeFuzz( Cabs(temp) ) <> 0.0
    THEN CDiv (z, Cone,temp)
    ELSE z := Cinfinity
  END {CCsc};

  PROCEDURE CCot  (VAR z:  Complex; a:  Complex);     {z   = cot(a)}
    VAR
      temp:  RealType;
  BEGIN  {Abramowitz formula 4.3.58 on p. 74}
    CConvert (a,rectangular);
    temp := COSH(2.0*a.y) - COS(2.0*a.x);
    IF   DeFuzz(temp) <> 0.0
    THEN BEGIN
      CSet (z,SIN(2.0*a.x)/temp,-SINH(2.0*a.y)/temp,rectangular)
    END
    ELSE z := Cinfinity
  END {CCot};

                                  {complex hyperbolic functions}
  PROCEDURE CCosh (VAR z:  Complex; a:  Complex);     {z   = cosh(a)}
  BEGIN  {Abramowitz formula 4.5.50 on p. 84}
    CConvert (a,rectangular);
    CSet (z, COSH(a.x)*COS(a.y), SINH(a.x)*SIN(a.y), rectangular)
  END {CCosh};

  PROCEDURE CSinh (VAR z:  Complex; a:  Complex);     {z   = sinh(a)}
  BEGIN  {Abramowitz formula 4.5.49 on p.84}
    CConvert (a,rectangular);
    CSet (z, SINH(a.x)*COS(a.y), COSH(a.x)*SIN(a.y), rectangular)
  END {CSinh};

  PROCEDURE CTanh (VAR z:  Complex; a:  Complex);     {z   = tanh(a)}
    VAR
      temp:  RealType;
  BEGIN  {Abramowitz formula 4.5.51 on p. 84}
    CConvert (a,rectangular);
    temp := COSH(2.0*a.x) + COS(2.0*a.y);
    IF   DeFuzz(temp) <> 0.0
    THEN BEGIN
      CSet (z,SINH(2.0*a.x)/temp,SIN(2.0*a.y)/temp,rectangular)
    END
    ELSE z := Cinfinity
  END {CTanh};

  PROCEDURE CSech (VAR z:  Complex; a:  Complex);     {z   = sech(a)}
    VAR
      temp:  Complex;
  BEGIN  {Abramowitz formula 4.5.5 on p. 83}
    CCosh (temp, a);
    IF   DeFuzz( Cabs(temp) ) <> 0.0
    THEN CDiv (z, Cone,temp)
    ELSE z := Cinfinity
  END {CSec};

  PROCEDURE CCsch (VAR z:  Complex; a:  Complex);     {z   = csch(a)}
    VAR
      temp:  Complex;
  BEGIN  {Abramowitz formula 4.5.4 on p. 83}
    CSinh (temp, a);
    IF   DeFuzz( Cabs(temp) ) <> 0.0
    THEN CDiv (z, Cone,temp)
    ELSE z := Cinfinity
  END {CCsch};

  PROCEDURE CCoth (VAR z:  Complex; a:  Complex);     {z   = coth(a)}
    VAR
      temp:  RealType;
  BEGIN  {Abramowitz formula 4.5.52 on p. 84}
    CConvert (a,rectangular);
    temp := COSH(2.0*a.x) - COS(2.0*a.y);
    IF   DeFuzz(temp) <> 0.0
    THEN BEGIN
      CSet (z,SINH(2.0*a.x)/temp,-SIN(2.0*a.y)/temp,rectangular)
    END
    ELSE z := Cinfinity
  END {CCoth};

                                  {miscellaneous complex functions}
  FUNCTION CAbs (z:  Complex):  RealType;                  {CAbs = |z|}
  BEGIN
    CASE z.form OF
      rectangular:  CAbs := SQRT( SQR(z.x) + SQR(z.y) );
      polar:        CAbs := z.r
    END
  END {CAbs};

  FUNCTION CAbsSqr (z:  Complex):  RealType;            {CAbsSqr = |z|^2}
  BEGIN
    CASE z.form OF
      rectangular:  CAbsSqr := SQR(z.x) + SQR(z.y);
      polar:        CAbsSqr := SQR(z.r)
    END
  END {CAbsSqr};

  PROCEDURE CIntPwr (VAR z:  Complex; a:  Complex; n:  INTEGER); {z = a^n}
    {CIntPwr directly applies DeMoivre's theorem to calculate
     an integer power of a complex number.  The formula holds
     for both positive and negative values of 'n'.}
  BEGIN
    IF   CAbsSqr(a) = 0.0
    THEN
      IF    n = 0
      THEN  z := Cone                   {lim a^a = 1 as a -> 0}
      ELSE  z := Czero                  {0^n = 0, except for 0^0=1}
    ELSE BEGIN
      CConvert (a,polar);
      z.form := polar;
      z.r := Pwr(a.r,n);
      z.theta := FixAngle(n*a.theta)
    END
  END {CIntPwr};

  PROCEDURE CRealPwr (VAR z:  Complex; a:  Complex; x:  RealType); {z = a^x}
  BEGIN
    IF   CAbsSqr(a) = 0.0
    THEN
      IF    Defuzz(x) = 0.0
      THEN  z := Cone                   {lim a^a = 1 as a -> 0}
      ELSE  z := Czero                  {0^n = 0, except for 0^0=1}
    ELSE BEGIN
      CConvert (a,polar);
      z.form := polar;
      z.r := Pwr(a.r,x);
      z.theta := FixAngle(x*a.theta)
    END
  END {CRealPwr};

  PROCEDURE CConjugate (VAR z:  Complex; a:  Complex);      {z = a*}
  BEGIN
    z.form := a.form;
    CASE a.form OF
      polar:
        BEGIN
          z.r := a.r;
          z.theta := FixAngle(-a.theta)
        END;
      rectangular:
        BEGIN
          z.x := a.x;
          z.y := -a.y
        END
    END
  END {CConjugate};

  PROCEDURE CSqrt (VAR z:  Complex; a:  Complex);      {z = SQRT(a)}
  BEGIN
    CRoot (z, a, 0,2)  {return only one of the two values}
  END {CSqrt};
                                           {z = a^(1/n), n > 0}
  PROCEDURE CRoot (VAR z:  Complex; a:  Complex; k,n:  WORD);
    {CRoot can calculate all 'n' roots of 'a' by varying 'k' from 0..n-1.}
    {This is another application of DeMoivre's theorem.  See CIntPwr.}
  BEGIN
    IF   CAbs(a) = 0.0
    THEN z := Czero                   {0^z = 0, except 0^0 is undefined}
    ELSE BEGIN
      CConvert (a,polar);
      z.form := polar;
      z.r := Pwr(a.r,1.0/n);
      z.theta := FixAngle((a.theta + k*2.0*PI)/n)
    END
  END {CRoot};

                             {complex Bessel functions of order zero}
  PROCEDURE CI0   (VAR sum:  Complex; z:  Complex);  {sum = I0(z)}
    {I0(z) = Σ ( (¼z^2)^k / (k!)^2 ), k=0,1,2,...,∞}
    VAR
      i      :  BYTE;
      SizeSqr:  RealType;
      term   :  Complex;
      zSQR25 :  Complex;
  BEGIN
    CConvert (z,rectangular);
    sum := Cone;                       {term 0}
    Cmult (zSQR25, z,z);
    zSQR25.x := 0.25 * zSQR25.x;
    zSQR25.y := 0.25 * zSQR25.y;       {¼z^2}
    term := zSQR25;
    CAdd (sum, sum,zSQR25);            {term 1}
    i := 1;
    REPEAT
      CMult (term,zSQR25,term);
      INC (i);
      term.x := term.x / SQR(i);
      term.y := term.y / SQR(i);
      CAdd (sum, sum,term);       {sum := sum + term}
      SizeSqr := SQR(term.x) + SQR(term.y)
    UNTIL (i > MaxTerm) OR (SizeSqr < EpsilonSqr)
  END {CI0};

  PROCEDURE CJ0   (VAR sum:  Complex; z:  Complex);  {sum = J0(z)}
    {J0(z) = Σ ( (-1)^k * (¼z^2)^k / (k!)^2 ), k=0,1,2,...,∞}
    VAR
      addflag:  BOOLEAN;
      i      :  BYTE;
      SizeSqr:  RealType;
      term   :  Complex;
      zSQR25 :  Complex;
  BEGIN
    CConvert (z,rectangular);
    sum := Cone;                       {term 0}
    Cmult (zSQR25, z,z);
    zSQR25.x := 0.25 * zSQR25.x;
    zSQR25.y := 0.25 * zSQR25.y;       {¼z^2}
    term := zSQR25;
    CSub (sum, sum,zSQR25);            {term 1}
    addflag := FALSE;
    i := 1;
    REPEAT
      CMult (term,zSQR25,term);
      INC (i);
      addflag := NOT addflag;
      term.x := term.x / SQR(i);
      term.y := term.y / SQR(i);
      IF   addflag
      THEN CAdd (sum, sum,term)        {sum := sum + term}
      ELSE CSub (sum, sum,term);       {sum := sum - term}
      SizeSqr := SQR(term.x) + SQR(term.y)
    UNTIL (i > MaxTerm) OR (SizeSqr < EpsilonSqr)
  END {CJ0};

  PROCEDURE CApproxLnGamma (VAR sum:  Complex; z:  Complex);
    {This is the approximation used in the National Bureau of
     Standards "Table of the Gamma Function for Complex Arguments,"
     Applied Mathematics Series 34, 1954.  The NBS table was created
     using this approximation over the area  9 ≤ Re(z) ≤ 10 and
     0 ≤ Im(z) ≤ 10.  Other table values were computed using the
     relationship ln Γ(z+1) = ln z + ln Γ(z).}
    CONST
      c:  ARRAY[1..8] OF RealType
       =  (1/12, -1/360, 1/1260, -1/1680, 1/1188, -691/360360,
           1/156, -3617/122400);
    VAR
      i     :  WORD;
      powers:  ARRAY[1..8] OF Complex;
      temp1 :  Complex;
      temp2 :  Complex;
  BEGIN
    CConvert (z,rectangular);
    CLn  (temp1,z);                              {ln(z}
    CSet (temp2, z.x-0.5, z.y, rectangular);     {z - 0.5}
    CMult (sum, temp1,temp2);                    {(z - 0.5)*ln(z)}
    CSub (sum, sum,z);                           {(z - 0.5)*ln(z) - z}
    sum.x := sum.x + hLn2PI;

    temp1 := Cone;
    CDiv (powers[1], temp1, z);                  {z^-1}
    CMult (temp2, powers[1],powers[1]);          {z^-2}
    FOR i := 2 TO 8 DO
      CMult (powers[i], powers[i-1],temp2);
    FOR i := 8 DOWNTO 1 DO BEGIN
      CSet (temp1, c[i]*powers[i].x, c[i]*powers[i].y, rectangular);
      CAdd (sum, sum,temp1);
    END
  END {CApproxLnGamma};

  PROCEDURE CLnGamma (VAR z:  Complex; a:  Complex);
    VAR
      lna :  Complex;
      temp:  Complex;
  BEGIN
    CConvert (a, rectangular);

    IF   (a.x <= 0.0) AND (DeFuzz(a.y) = 0.0)
    THEN
      IF   DeFuzz(INT(a.x-1E-8) - a.x) = 0.0     {negative integer?}
      THEN BEGIN
        z := Cinfinity;
        EXIT
      END;

    IF   a.y < 0.0                     {3rd or 4th quadrant?}
    THEN BEGIN
      CConjugate (a, a);
      CLnGamma (z, a);                 {try again in 1st or 2nd quadrant}
      CConjugate (z, z)                {left this out!  1/3/91}
    END
    ELSE BEGIN
      IF   a.x < 9.0                   {"left" of NBS table range}
      THEN BEGIN
        CLn (lna, a);
        CSet (a, a.x+1.0, a.y, rectangular);
        CLnGamma (temp,a);
        CSub (z, temp,lna)
      END
      ELSE CApproxLnGamma (z,a)  {NBS table range:  9 ≤ Re(z) ≤ 10}
    END
  END {CLnGamma};

  PROCEDURE CGamma (VAR z:  Complex; a:  Complex);
    VAR
      lnz:  Complex;
  BEGIN
    CLnGamma (lnz,a);
    IF   lnz.x >= 75.0       {arbitrary cutoff for infinity}
    THEN z := Cinfinity
    ELSE
      IF   lnz.x < -200.0
      THEN z := Czero        {avoid underflow}
      ELSE CExp (z, lnz);
  END {CGamma};

                                  {treat "fuzz" of real numbers}
  PROCEDURE CDeFuzz (VAR z:  Complex);
  BEGIN
    CASE z.form OF
      rectangular:
        BEGIN
          z.x := DeFuzz(z.x);
          z.y := DeFuzz(z.y);
        END;
      polar:
        BEGIN
          z.r := DeFuzz(z.r);
          IF   z.r = 0.0
          THEN z.theta := 0.0     {canonical form when radius is zero}
          ELSE z.theta := DeFuzz(z.theta)
        END
    END
  END {CDeFuzz};

  FUNCTION  DeFuzz (x:  RealType):  RealType;
  BEGIN
    IF   ABS(x) < fuzz
    THEN Defuzz := 0
    ELSE Defuzz := x
  END {Defuzz};

  PROCEDURE SetFuzz (value:  RealType);
  BEGIN
    fuzz := value
  END {SetFuzz};

                                  {miscellaneous}
  FUNCTION FixAngle (theta:  RealType):  RealType;    {-PI < theta <= PI}
  BEGIN
    WHILE theta > PI DO
      theta := theta - 2.0*PI;
    WHILE theta <= -PI DO
      theta := theta + 2.0*PI;
    FixAngle := DeFuzz(theta)
  END {FixAngle};

  FUNCTION Pwr (x,y:  RealType):  RealType;        {Pwr = x^y}
  BEGIN
    IF   DeFuzz(x) = 0.0
    THEN
      IF   DeFuzz(y) = 0.0
      THEN Pwr := 1.0    {0^0 = 1 (i.e., lim x^x = 1 as x -> 0)}
      ELSE Pwr := 0.0
    ELSE Pwr := EXP( LN(x)*y )
  END {Pwr};

  FUNCTION Log10 (x:  RealType):  RealType;
  BEGIN
    Log10 := LN(x) / LN(10)
  END {Log10};

  FUNCTION LongMod (l1,l2:  LongInt):  LongInt;
  BEGIN
    LongMod := l1 - l2*(l1 DIV l2)
  END {LongMod};

  FUNCTION Cosh (x:  RealType):  RealType;
  BEGIN
    Cosh := 0.5*( EXP(x) + EXP(-x) )
  END {Cosh};

  FUNCTION Sinh (x:  RealType):  RealType;
  BEGIN
    Sinh := 0.5*( EXP(x) - EXP(-x) )
  END {Sinh};

BEGIN
  SetFuzz (1.0E-12);
  CSet ( Cone, 1.0, 0.0, rectangular);
  CSet (Czero, 0.0, 0.0, rectangular);
  CSet (Cinfinity, Infinity, Infinity, rectangular);
  hLnPI := 0.5*(LN(PI));
  hLn2PI := 0.5*(LN(2.0*PI));
  ln2 := LN(2.0)
END.

{-------------  DEMO ----  CUT HERE ------ }
{$N+,E+}
PROGRAM cdemo;

 {This PROGRAM demonstrates the use of the ComplexOps UNIT.

  (C) Copyright 1990, 1992, Earl F. Glynn, Overland Park, KS.  Compuserve 73257,3527.
  All rights reserved.  This program may be freely distributed only for
  non-commercial use.}


  USES ComplexOps;

  VAR
    a      :  ARRAY[1..22] OF Complex;
    csave  :  ARRAY[1..22] OF Complex;
    k,m    :  WORD;
    n      :  INTEGER;
    x,y    :  RealType;
    z,z1,z2:  Complex;

BEGIN

  WRITELN ('Demo ComplexOPs PROCEDUREs and FUNCTIONs');
  WRITELN;
  WRITELN ('  Notes:  1.  CIS(w) = COS(w) + i*SIN(w), w = -PI..PI');
  WRITELN ('          2.  z = x + i*y');
  WRITELN;
  WRITELN;

  CSet (a[ 1],  0.0,  0.0, rectangular);
  CSet (a[ 2],  0.5,  0.5, rectangular);
  CSet (a[ 3], -0.5,  0.5, rectangular);
  CSet (a[ 4], -0.5, -0.5, rectangular);
  CSet (a[ 5],  0.5, -0.5, rectangular);
  CSet (a[ 6],  1.0,  0.0, rectangular);
  CSet (a[ 7],  1.0,  1.0, rectangular);
  CSet (a[ 8],  0.0,  1.0, rectangular);
  CSet (a[ 9], -1.0,  1.0, rectangular);
  CSet (a[10], -1.0,  0.0, rectangular);
  CSet (a[11], -1.0, -1.0, rectangular);
  CSet (a[12],  0.0, -1.0, rectangular);
  CSet (a[13],  1.0, -1.0, rectangular);
  CSet (a[14],   5.,   0., rectangular);
  CSet (a[15],   5.,   3., rectangular);
  CSet (a[16],   0.,   3., rectangular);
  CSet (a[17],  -5.,   3., rectangular);
  CSet (a[18],  -5.,   0., rectangular);
  CSet (a[19],  -5.,  -3., rectangular);
  CSet (a[20],   0.,  -3., rectangular);
  CSet (a[21],  -5.,  -3., rectangular);
  CSet (a[22], -20.,  20., rectangular);

  WRITELN ('Complex number definition/conversion/output:  CSet/CConvert/CStr');
  WRITELN;
  WRITELN ('   z rectangular':25,'z polar':28);
  WRITELN ('     ---------------------------   ',
    '-----------------------------');
  FOR k := 1 TO 21 DO
    WRITELN (k:3,'  ',CStr(a[k],12,8,rectangular),'  ',
                     CStr(a[k],12,8,polar));
  WRITELN;
  WRITELN;

  WRITELN ('Complex arithmetic:  CAdd, CSub, CMult, CDiv');
  WRITELN;

  CSet (z1,  1, 1, rectangular);
  WRITELN ('Let z1 = ':12,CStr(z1,8,3,rectangular):20,' or ',
                      CStr(z1,8,3,polar));
  CSet (z2, SQRT(3), -1, rectangular);
  WRITELN ('z2 = ':12,CStr(z2,8,3,rectangular):20,' or ',
                      CStr(z2,8,3,polar));
  WRITELN;

  CAdd  (z,z1,z2);
  WRITELN ('z1 + z2 = ':12,CStr(z,8,3,rectangular):20,' or ',
                           CStr(z,8,3,polar));

  CSub  (z,z1,z2);
  WRITELN ('z1 - z2 = ':12,CStr(z,8,3,rectangular):20,' or ',
                           CStr(z,8,3,polar));

  CMult (z,z1,z2);
  WRITELN ('z1 * z2 = ':12,CStr(z,8,3,rectangular):20,' or ',
                           CStr(z,8,3,polar));

  CDiv  (z,z1,z2);
  WRITELN ('z1 / z2 = ':12,CStr(z,8,3,rectangular):20,' or ',
                           CStr(z,8,3,polar));
  WRITELN;
  WRITELN;

  WRITELN ('Complex natural logarithm:  CLn = LN(z)');
  WRITELN;
  WRITELN ('  Notes:  1.  LN(z) is multivalued.');
  WRITELN (' ':9,' 2.  Any multiple of 2*PI*i could be added to/',
    'subtracted from LN(z).');
  WRITELN (' ':9,' 3.  LN(1)=0; LN(-1)=PI*i; LN(+/-i)=+/-0.5*PI*i.');
  WRITELN;
  WRITELN ('LN(z)':35);
  WRITELN ('z':11,'rectangular':27,'EXP( LN(z) ) = z':32);
  WRITELN ('     ------------  ---------------------------  ',
    '---------------------------');
  FOR k := 1 TO 22 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    IF   CAbs(a[k]) = 0.0
    THEN WRITELN ('undefined':18)
    ELSE BEGIN
      CLn (z,a[k]);
      CExp (z1,z);
      WRITELN (CStr(z,12,9,rectangular),'  ',CStr(z1,12,9,rectangular))
    END
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex exponential:  CExp = EXP(z)');
  WRITELN;
  WRITELN ('EXP(z)':35);
  WRITELN ('z':11,'rectangular':27,'LN( EXP(z) ) = z':32);
  WRITELN ('     ------------  ---------------------------  ',
    '---------------------------');
  FOR k := 1 TO 22 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CExp (z,a[k]);
    CLn (z1,z);
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),'  ',CStr(z1,12,m,rectangular))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex power:  CPwr = z1^z2');
  WRITELN;
  WRITELN ('z^(-1+i)':36,'z^(-1+i)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  CSet (z1, -1,1, rectangular);
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    IF   CAbs(a[k]) = 0.0
    THEN WRITELN ('undefined':18)
    ELSE BEGIN
      CPwr (z,a[k],z1);
      WRITELN (CStr(z,12,9,rectangular),' ',CStr(z,12,9,polar))
    END
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex cosine:  CCos = COS(z)');
  WRITELN;
  WRITELN ('COS(z)':35,'COS(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CCos (z,a[k]);
    CIntPwr (csave[k], z,2);  {save COS^2}
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex sine:  CSin = SIN(z)');
  WRITELN;
  WRITELN ('SIN(z)':35);
  WRITELN ('z':11,'rectangular':27,'SIN^2(z)+COS^2(z)=1':32);
  WRITELN ('     ------------  ---------------------------  ',
    '---------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CSin (z,a[k]);
    CIntPwr (z1, z,2);      {SIN^2}
    CAdd (z1, z1,csave[k]); {SIN^2 + COS^2}
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),'  ',CStr(z1,12,9,rectangular))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex tangent:  CTan = TAN(z)');
  WRITELN;
  WRITELN ('TAN(z)':35,'TAN(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CTan (z,a[k]);
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex hyperbolic cosine:  CCosh = COSH(z)');
  WRITELN;
  WRITELN ('COSH(z)':36,'COSH(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CCosh (z,a[k]);
    CIntPwr (csave[k], z,2);  {save COSH^2}
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex hyperbolic sine:  CSinh = SINH(z)');
  WRITELN;
  WRITELN ('SINH(z)':36);
  WRITELN ('z':11,'rectangular':27,'COSH^2(z)-SINH^2(z)=1':34);
  WRITELN ('     ------------  ---------------------------  ',
    '---------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CSinh (z,a[k]);
    CIntPwr (z1, z,2);      {SINH^2}
    CSub (z1, csave[k],z1); {COSH^2 - SINH^2}
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),'  ',CStr(z1,12,9,rectangular))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex hyperbolic tangent:  CTanh = TANH(z)');
  WRITELN;
  WRITELN ('TANH(z)':36,'TANH(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CTanh (z,a[k]);
    IF   CAbs(z) > 10.0
    THEN m := 4
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Absolute value of complex number:  CAbs = ABS(z)');
  WRITELN;
  WRITELN ('z':11,'ABS(z)':17);
  WRITELN ('     ------------  ------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITELN (k:3,' ',CStr(a[k],5,1,rectangular),'  ',CAbs(a[k]):12:9)
  END;
  WRITELN;

  WRITELN ('Complex integer power:  CIntPwr = z^n  ',
    '(using DeMoivre''s Theorem)');
  WRITELN;
  WRITELN ('z^3':34,'z^3':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    IF   CAbs(a[k]) = 0.0
    THEN WRITELN ('undefined':18)
    ELSE BEGIN
      CIntPwr (z,a[k],3);
      IF   CAbs(z) > 10.0
      THEN m := 7
      ELSE m := 9;
      WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
    END
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex conjugate:  CConjugate = z*');
  WRITELN;
  WRITELN ('z*':35,'z*':29);
  WRITELN ('z':11,'rectangular':28,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CConjugate (z,a[k]);
    WRITELN (CStr(z,12,8,rectangular),' ',CStr(z,12,8,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex square root:  CSqrt = SQRT(z)');
  WRITELN;
  WRITELN ('SQRT(z)':36,'SQRT(z)':28);
  WRITELN ('z':11,'root 1':25,'root 2':28);
  WRITELN ('     ------------  ---------------------------  ',
    '---------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CSqrt (z,a[k]);       {same as CRoot (z,a[k],0,2)}
    CRoot (z1,a[k],1,2);
    WRITELN (CStr(z,12,9,rectangular),'  ',CStr(z1,12,9,rectangular))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('The three cube roots of -1+i:  (-1+i)^(1/3)');
  WRITELN ('(See Schaum''s Outline Series "Complex Variables", 1964, ',
    'p. 18, problem 29.)');
  WRITELN;
  WRITELN ('z^(1/3)':35,'z^(1/3)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  CSet (z1, -1,1, rectangular);
  FOR k := 0 TO 2 DO BEGIN
    WRITE (k:3,' ',CStr(z1,5,1,rectangular),'  ');
    CRoot (z,z1,k,3);
    WRITELN (CStr(z,12,9,rectangular),' ',CStr(z,12,9,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex Bessel function:  CI0 = I0(z)');
  WRITELN;
  WRITELN ('I0(z)':36,'I0(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CI0 (z,a[k]);
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Complex Bessel function:  CJ0 = J0(z)');
  WRITELN;
  WRITELN ('J0(z)':36,'J0(z)':29);
  WRITELN ('z':11,'rectangular':27,'polar':26);
  WRITELN ('     ------------  ---------------------------  ',
    '-----------------------------');
  FOR k := 1 TO 21 DO BEGIN
    WRITE (k:3,' ',CStr(a[k],5,1,rectangular),'  ');
    CJ0 (z,a[k]);
    IF   CAbs(z) > 10.0
    THEN m := 7
    ELSE m := 9;
    WRITELN (CStr(z,12,m,rectangular),' ',CStr(z,12,m,polar))
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Removing "Fuzz" from real numbers for zero test:');
  WRITELN;  {Note:  CStr calls CConvert that calls CDefuzz}
  CSet (z, -3.21E-14,7.65E-14, rectangular);
  WRITELN ('  Before:  ',z.x:18:15,' +',z.y:18:15,'i');
  CDeFuzz (z);
  WRITELN ('   After:  ',CStr(z,18,15,rectangular));
  WRITELN;
  CSet (z, -3.21E-14,PI, polar);
  WRITELN ('  Before:  ',z.r:18:15,'*CIS(',z.theta:18:15,')');
  CDeFuzz (z);
  WRITELN ('   After:  ',CStr(z,18,15,polar));
  WRITELN;
  WRITELN;

  WRITELN ('Miscellaneous:  FixAngle -- keep angle in interval (-PI..PI)');
  WRITELN;

  WRITELN ('     radians FixAngle');
  WRITELN ('    -------- --------');
  FOR n := -4 TO 8 DO BEGIN
    x := n*PI/2.0;
    y := FixAngle(x);
    WRITELN (n:3,' ',x:8:5,' ',y:8:5)
  END;
  WRITELN;
  WRITELN;

  WRITELN ('Real power function:  Pwr = x^y');
  WRITELN;
  WRITELN ('        x        y         x^y');
  WRITELN ('    -------- -------- ------------');
  WRITELN (' ':4,2.1:8:5,' ',-2.5:8:5,Pwr(2.1,-2.5):12:9);
  WRITELN (' ':4,2.1:8:5,' ', 2.5:8:5,Pwr(2.1, 2.5):12:9);
  WRITELN (' ':4,1.4:8:5,' ', 8.9:8:5,Pwr(1.2, 8.9):12:9);
  WRITELN (' ':4,0.0:8:5,' ', 2.0:8:5,Pwr(0.0, 2.0):12:9);
  WRITELN (' ':4,4.2:8:5,' ', 0.0:8:5,Pwr(4.2, 0.0):12:9);
  WRITELN;

END {cdemo}.
