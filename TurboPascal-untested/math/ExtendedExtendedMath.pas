(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0129.PAS
  Description: EXTENDED Extended MATH
  Author: PASWIZ
  Date: 08-30-97  10:09
*)


{   +----------------------------------------------------------------------+
    |                                                                      |
    |   PasWiz  (C) Copyright 1996 Charon Software, All Rights Reserved    |
    |                                                                      |
    +----------------------------------------------------------------------+



Extended math:

   This unit contains procedures and functions that implement extensions to
   Pascal's built-in math (new trig functions, et al) and an arithmetic
   expression evaluator.  The latter is loosely based on EXPR.C from Dr.
   Dobb's Journal, Sept 1985, p.25.

}

UNIT ExtMath;

INTERFACE

FUNCTION ArcCos (Number: Real): Real;
FUNCTION ArcCosH (Number: Real): Real;
FUNCTION ArcCot (Number: Real): Real;
FUNCTION ArcCotH (Number: Real): Real;
FUNCTION ArcCsc (Number: Real): Real;
FUNCTION ArcCscH (Number: Real): Real;
FUNCTION ArcSec (Number: Real): Real;
FUNCTION ArcSecH (Number: Real): Real;
FUNCTION ArcSin (Number: Real): Real;
FUNCTION ArcSinH (Number: Real): Real;
FUNCTION ArcTanH (Number: Real): Real;
FUNCTION Ceil (Number: Real): Real;
FUNCTION CosH (Number: Real): Real;
FUNCTION Cot (Number: Real): Real;
FUNCTION CotH (Number: Real): Real;
FUNCTION Csc (Number: Real): Real;
FUNCTION CscH (Number: Real): Real;
FUNCTION Deg2Rad (Number: Real): Real;
FUNCTION e: Real;
FUNCTION Erf (Number: Real): Real;
FUNCTION Fact (Number: Integer): Real;
FUNCTION Floor (Number: Real): Real;
FUNCTION Log (Number: Real): Real;
FUNCTION Rad2Deg (Number: Real): Real;
FUNCTION Raise (Number: Real; Power: Integer): Real;
FUNCTION Sec (Number: Real): Real;
FUNCTION SecH (Number: Real): Real;
FUNCTION SgnI (Number: Integer): Integer;
FUNCTION SgnR (Number: Real): Integer;
FUNCTION SinH (Number: Real): Real;
FUNCTION Tan (Number: Real): Real;
FUNCTION TanH (Number: Real): Real;

PROCEDURE Evaluate (Expr: String; VAR Result: Real; VAR ErrCode: Integer);



{ --------------------------------------------------------------------------- }



IMPLEMENTATION

{ forward declarations for the Evaluate procedure }
FUNCTION Eval (VAR Expr: String; VAR ErrCode: Integer): Real; FORWARD;
FUNCTION Factor (VAR Expr: String; VAR ErrCode: Integer): Real; FORWARD;
FUNCTION IsDigit (Expr: String): Boolean; FORWARD;
FUNCTION Locase (Ch: Char): Char; FORWARD;
FUNCTION ParensOk (Expr: String): Boolean; FORWARD;
FUNCTION Term (VAR Expr: String; VAR ErrCode: Integer): Real; FORWARD;
PROCEDURE AddParen (VAR Expr: String; Posn, WhichWay: Integer); FORWARD;
PROCEDURE FixPrecedence (VAR Expr: String); FORWARD;



{ ----- Ceiling ----- }
FUNCTION Ceil (Number: Real): Real;
BEGIN
   IF Number = INT(Number) THEN
      Ceil := Number
   ELSE
      Ceil := INT(Number) + 1.0;
END;



{ ----- Floor ----- }
FUNCTION Floor (Number: Real): Real;
BEGIN
   IF Number = INT(Number) THEN
      Floor := Number
   ELSE
      Floor := INT(Number) - 1.0;
END;



{ ----- Inverse cosine ----- }
FUNCTION ArcCos (Number: Real): Real;
BEGIN
   IF (Number < -1.0) OR (Number > 1.0) THEN      { error }
      ArcCos := 99999.0
   ELSE
      ArcCos := PI / 2.0 - ArcSin(Number);
END;



{ ----- Inverse hyperbolic cosine ----- }
FUNCTION ArcCosH (Number: Real): Real;
BEGIN
   ArcCosH := Log(Number + SQRT(SQR(Number) - 1.0));
END;



{ ----- Inverse cotangent ----- }
FUNCTION ArcCot (Number: Real): Real;
BEGIN
   ArcCot := -ARCTAN(Number) + PI / 2.0;
END;



{ ----- Inverse hyperbolic cotangent ----- }
FUNCTION ArcCotH (Number: Real): Real;
BEGIN
   ArcCotH := LN((Number + 1.0) / (Number - 1.0)) / 2.0;
END;



{ ----- Inverse cosecant ----- }
FUNCTION ArcCsc (Number: Real): Real;
BEGIN
   ArcCsc := ARCTAN(1.0 / SQRT(1.0 - SQR(Number)))
      + (SgnR(Number) - 1.0) * (PI / 2.0);
END;



{ ----- Inverse hyperbolic cosecant ----- }
FUNCTION ArcCscH (Number: Real): Real;
BEGIN
   ArcCscH := LN((SgnR(Number) * SQRT(SQR(Number) + 1.0) + 1.0) / Number);
END;



{ ----- Inverse secant ----- }
FUNCTION ArcSec (Number: Real): Real;
BEGIN
   ArcSec := ARCTAN(Number / SQRT(1.0 - SQR(Number)))
      + (SgnR(Number) - 1.0) * (PI / 2.0);
END;



{ ----- Inverse hyperbolic secant ----- }
FUNCTION ArcSecH (Number: Real): Real;
BEGIN
   ArcSecH := LN((SQRT(1.0 - SQR(Number)) + 1.0) / Number);
END;



{ ----- Inverse sine ----- }
FUNCTION ArcSin (Number: Real): Real;
VAR
   Negate: Boolean;
   tmp: Real;
BEGIN
   IF Number < 0.0 THEN BEGIN
      Number := -Number;
      Negate := TRUE;
   END
   ELSE
      Negate := FALSE;
   IF Number > 1.0 THEN BEGIN
      tmp := 99999.0;
      Negate := FALSE;
   END
   ELSE BEGIN
      tmp := SQRT(1.0 - SQR(Number));
      IF Number > 0.7 THEN
         tmp := PI / 2.0 - ARCTAN(tmp / Number)
      ELSE
         tmp := ARCTAN(Number / tmp);
   END;
   IF Negate THEN
      ArcSin := -tmp
   ELSE
      ArcSin := tmp;
END;



{ ----- Inverse hyperbolic sine ----- }
FUNCTION ArcSinH (Number: Real): Real;
BEGIN
   ArcSinH := Log(Number + SQRT(SQR(Number) + 1.0));
END;



{ ----- Inverse hyperbolic tangent ----- }
FUNCTION ArcTanH (Number: Real): Real;
BEGIN
   ArcTanH := Log((1.0 + Number) / (1.0 - Number)) / 2.0;
END;



{ ----- Convert degrees to radians ----- }
FUNCTION Deg2Rad (Number: Real): Real;
BEGIN
   Deg2Rad := Number * PI / 180.0;
END;



{ ----- e (base of the natural logarithms) ----- }
FUNCTION e: Real;
BEGIN
   e := 2.7182818284590452353602874713526624977572470936999595749669676;
END;



{ ----- Hyperbolic cosine ----- }
FUNCTION CosH (Number: Real): Real;
BEGIN
   IF Number < 0.0 THEN
      Number := - Number;
   IF Number > 21.0 THEN
      CosH := Exp(Number) / 2.0
   ELSE
      CosH := (Exp(Number) + Exp(-Number)) / 2.0;
END;



{ ----- Cotangent ----- }
FUNCTION Cot (Number: Real): Real;
BEGIN
   Cot := 1.0 / Tan(Number);
END;



{ ----- Hyperbolic cotangent ----- }
FUNCTION CotH (Number: Real): Real;
VAR
   tmp: REAL;
BEGIN
   tmp := EXP(-Number);
   CotH := tmp / (EXP(Number) - tmp) * 2.0 + 1.0;
END;



{ ----- Cosecant ----- }
FUNCTION Csc (Number: Real): Real;
BEGIN
   Csc := 1.0 / Sin(Number);
END;



{ ----- Hyperbolic cosecant ----- }
FUNCTION CscH (Number: Real): Real;
BEGIN
   CscH := 2.0 / (EXP(Number) - EXP(-Number));
END;



{ ----- Error Function ----- }
FUNCTION Erf (Number: Real): Real;
VAR
   J, N: Integer;
   S: Real;
BEGIN
   N := Trunc(14.0 * Number + 3.0);
   S := 1.0 / (2.0 * N - 1.0);
   FOR J := N - 1 DOWNTO 1 DO
      S := 1.0 / (2.0 * J - 1.0) - SQR(Number) / J * S;
   Erf := Number / 0.8862269254527581 * S;
END;



{ ----- Factorial ----- }
FUNCTION Fact (Number: Integer): Real;
VAR
   Result: Real;
   tmp: Integer;
BEGIN
   Result := 1.0;
   FOR tmp := 2 TO Number DO
      Result := Result * tmp;
   Fact := Result;
END;



{ ----- Logarithm (base 10) ----- }
FUNCTION Log (Number: Real): Real;
BEGIN
   Log := Ln(Number) / Ln(10.0);
END;



{ ----- Convert radians to degrees ----- }
FUNCTION Rad2Deg (Number: Real): Real;
BEGIN
   Rad2Deg := Number * 180.0 / PI;
END;



{ ----- Raise a number to a power (a feature oddly lacking in Pascal). }
FUNCTION Raise (Number: Real; Power: Integer): Real;
VAR
   tmp: Integer;
   Result: Real;
BEGIN
   Result := 1.0;
   FOR tmp := 1 TO Power DO
      Result := Result * Number;
   Raise := Result;
END;     { Raise }



{ ----- Secant ----- }
FUNCTION Sec (Number: Real): Real;
BEGIN
   Sec := 1.0 / Cos(Number);
END;



{ ----- Hyperbolic secant ----- }
FUNCTION SecH (Number: Real): Real;
BEGIN
   SecH := 2.0 / (EXP(Number) + EXP(-Number));
END;



{ ----- Signum (integer) ----- }
FUNCTION SgnI (Number: Integer): Integer;
BEGIN
   IF Number < 0 THEN
      SgnI := -1
   ELSE IF Number > 0 THEN
      SgnI := 1
   ELSE
      SgnI := 0;
END;



{ ----- Signum (real) ----- }
FUNCTION SgnR (Number: Real): Integer;
BEGIN
   IF Number < 0.0 THEN
      SgnR := -1
   ELSE IF Number > 0.0 THEN
      SgnR := 1
   ELSE
      SgnR := 0;
END;



{ ----- Hyperbolic sine ----- }
FUNCTION SinH (Number: Real): Real;
VAR
   Negate: Boolean;
   p0, p1, p2, p3, q0, q1, q2, tmp, tmp1, tmp2, tmpsq: Real;
BEGIN
   p0 := -630767.3640497716991184787251;
   p1 := -89912.72022039509355398013511;
   p2 := -2894.211355989563807284660366;
   p3 := -26.30563213397497062819489;
   q0 := -630767.3640497716991212077277;
   q1 := 15215.17378790019070696485176;
   q2 := -173.678953558233699533450911;
   IF Number < 0.0 THEN BEGIN
      Number := -Number;
      Negate := TRUE;
   END
   ELSE
      Negate := FALSE;
   IF Number > 21.0 THEN
      tmp := Exp(Number) / 2.0
   ELSE IF Number > 0.5 THEN
      tmp := (Exp(Number) - Exp(-Number)) / 2.0
   ELSE BEGIN
      tmpsq := SQR(Number);
      tmp1 := (((tmpsq * p3 + p2) * tmpsq + p1) * tmpsq + p0) * Number;
      tmp2 := ((tmpsq + q2) * tmpsq + q1) * tmpsq + q0;
      tmp := tmp1 / tmp2;
   END;
   IF Negate THEN
      SinH := -tmp
   ELSE
      SinH := tmp;
END;



{ ----- Tangent ----- }
FUNCTION Tan (Number: Real): Real;
BEGIN
   Tan := Sin(Number) / Cos(Number);
END;



{ ----- Hyperbolic tangent ----- }
FUNCTION TanH (Number: Real): Real;
VAR
   Negate: Boolean;
   tmp: Real;
BEGIN
   IF Number < 0.0 THEN BEGIN
      Number := -Number;
      Negate := TRUE;
   END
   ELSE
      Negate := FALSE;
   IF Number > 21.0 THEN     { error }
      TanH := 99999
   ELSE BEGIN
      tmp := SinH(Number) / CosH(Number);
      IF Negate THEN
         TanH := -tmp
      ELSE
         TanH := tmp;
   END;
END;



{ =========================================================================== }



{ ----- This is the main evaluation routine ----- }
PROCEDURE Evaluate (Expr: String; VAR Result: Real; VAR ErrCode: Integer);
VAR
   tmp: Integer;
BEGIN
   WHILE (Pos(' ', Expr) > 0) DO
      Delete(Expr, Pos(' ', Expr), 1);
   WHILE (Pos('**', Expr) > 0) DO BEGIN
      tmp := Pos('**', Expr);
      Delete(Expr, tmp, 1);
      Expr[tmp] := '^';
   END;
   IF Length(Expr) > 0 THEN
      IF ParensOk(Expr) THEN BEGIN
         FOR tmp := 1 TO Length(Expr) DO
            Expr[tmp] := Upcase(Expr[tmp]);
         ErrCode := 0;
         FixPrecedence(Expr);
         Result := Eval(Expr, ErrCode);
      END
      ELSE
         ErrCode := 4
   ELSE
      ErrCode := 8;
END;     { Evaluate }



{ ----- This adds parentheses to force evaluation by normal algebraic
        precedence (negation, exponentiation, multiplication and division,
        addition and subtraction) }
PROCEDURE AddParen (VAR Expr: String; Posn, WhichWay: Integer);
VAR
   Done: Boolean;
   ch: Char;
   Depth: Integer;
BEGIN
   Done := FALSE;
   IF WhichWay < 0 THEN BEGIN
      REPEAT
         Dec(Posn);
         IF Posn < 1 THEN BEGIN
            Expr := '(' + Expr;
            Done := TRUE;
         END
         ELSE BEGIN
            ch := Expr[Posn];
            IF Pos(ch, '^*/+-') > 0 THEN BEGIN
               Insert('(', Expr, Posn + 1);
               Done := TRUE;
            END
            ELSE IF ch = ')' THEN BEGIN
               Depth := 1;
               REPEAT
                  Dec(Posn);
                  IF Posn > 0 THEN BEGIN
                     ch := Expr[Posn];
                     IF ch = '(' THEN
                        Dec(Depth)
                     ELSE IF ch = ')' THEN
                        Inc(Depth);
                  END
                  ELSE
                     Depth := 0;
               UNTIL Depth = 0;
               IF Posn < 1 THEN
                  Posn := 1;
               Insert('(', Expr, Posn + 1);
               Done := TRUE;
            END;
         END;
      UNTIL Done;
   END
   ELSE
      REPEAT
         Inc(Posn);
         IF Posn > Length(Expr) THEN BEGIN
            Expr := Expr + ')';
            Done := TRUE;
         END
         ELSE BEGIN
            ch := Expr[Posn];
            IF Pos(ch, '^*/+-') > 0 THEN BEGIN
               Insert(')', Expr, Posn);
               Done := TRUE;
            END
            ELSE IF ch = '(' THEN BEGIN
               Depth := 1;
               REPEAT
                  Inc(Posn);
                  IF Posn <= Length(Expr) THEN BEGIN
                     ch := Expr[Posn];
                     IF ch = ')' THEN
                        Dec(Depth)
                     ELSE IF ch = '(' THEN
                        Inc(Depth);
                  END
                  ELSE
                     Depth := 0;
               UNTIL Depth = 0;
               IF Posn > Length(Expr) THEN
                  Posn := Length(Expr);
               Insert(')', Expr, Posn);
               Done := TRUE;
            END;
         END;
      UNTIL Done;
END;    { AddParen }



{ ----- This recursive function is the heart of the expression evaluator. }
FUNCTION Eval (VAR Expr: String; VAR ErrCode: Integer): Real;
VAR
   LVal, tmp: Real;
BEGIN
   LVal := Factor(Expr, ErrCode);
   IF ErrCode = 0 THEN
      CASE Expr[1] OF
         '+': BEGIN
                 Delete(Expr, 1, 1);
                 LVal := LVal + Eval(Expr, ErrCode);
              END;
         '-': BEGIN
                 Delete(Expr, 1, 1);
                 LVal := LVal - Eval(Expr, ErrCode);
              END;
         '*': BEGIN
                 Delete(Expr, 1, 1);
                 LVal := LVal * Eval(Expr, ErrCode);
              END;
         '/': BEGIN
                 Delete(Expr, 1, 1);
                 tmp := Eval(Expr, ErrCode);
                 IF ErrCode = 0 THEN
                    IF tmp = 0.0 THEN
                       ErrCode := 9
                    ELSE
                       LVal := LVal / tmp;
              END;
         '^': BEGIN
                 Delete(Expr, 1, 1);
                 LVal := Raise(LVal, Trunc(Eval(Expr, ErrCode)));
              END;
         ')': Delete(Expr, 1, 1);
      END;     { CASE }
   Eval := LVal;
END;     { Eval }



{ ----- A recursive evaluation helper, this function gets the leftmost term
        that can be dealt with at this point in the evaluation. }
FUNCTION Factor (VAR Expr: String; VAR ErrCode: Integer): Real;
VAR
   Negate: Boolean;
   RVal: Real;
BEGIN
   RVal := 0.0;
   IF Expr[1] = '-' THEN BEGIN
      Negate := TRUE;
      Delete(Expr, 1, 1);
   END
   ELSE
      Negate := FALSE;
   IF Expr[1] <> '(' THEN
      RVal := Term(Expr, ErrCode)
   ELSE BEGIN
      Delete(Expr, 1, 1);
      RVal := Eval(Expr, ErrCode);
   END;
   IF Negate THEN
      Factor := -RVal
   ELSE
      Factor := RVal;
END;     { Factor }



{ ----- Since the evaluation function doesn't naturally evaluate expressions
        using algebraic precedence, but does understand parentheses...
        This routine adds parentheses to force the proper precedence. }
PROCEDURE FixPrecedence (VAR Expr: String);
VAR
   Posn, tmp: Integer;
BEGIN
   Expr := '(' + Expr + ')';
   Posn := 2;
   REPEAT
      IF Expr[Posn] = '-' THEN
         IF NOT(Expr[Posn - 1] IN ['0'..'9','A'..'Z']) THEN BEGIN
            AddParen(Expr, Posn, 1);
            AddParen(Expr, Posn, -1);
            Inc(Posn, 2);
         END
         ELSE
            Inc(Posn)
      ELSE
         Inc(Posn);
   UNTIL Posn > Length(Expr);
   Posn := 1;
   REPEAT
      IF Expr[Posn] <> Locase(Expr[Posn]) THEN BEGIN
         AddParen(Expr, Posn, 1);
         AddParen(Expr, Posn, -1);
         Inc(Posn, 2);
      END
      ELSE
         Inc(Posn);
   UNTIL Posn > Length(Expr);
   Posn := 1;
   REPEAT
      IF Expr[Posn] = '^' THEN BEGIN
         AddParen(Expr, Posn, 1);
         AddParen(Expr, Posn, -1);
         Inc(Posn, 2);
      END
      ELSE
         Inc(Posn);
   UNTIL Posn > Length(Expr);
   Posn := 1;
   REPEAT
      IF Pos(Expr[Posn], '*/') > 0 THEN BEGIN
         AddParen(Expr, Posn, 1);
         AddParen(Expr, Posn, -1);
         Inc(Posn, 2);
      END
      ELSE
         Inc(Posn);
   UNTIL Posn > Length(Expr);
   Posn := 1;
   REPEAT
      IF Pos(Expr[Posn], '+-') > 0 THEN BEGIN
         AddParen(Expr, Posn, 1);
         AddParen(Expr, Posn, -1);
         Inc(Posn, 2);
      END
      ELSE
         Inc(Posn);
   UNTIL Posn > Length(Expr);
   Delete(Expr, 1, 1);
   Delete(Expr, Length(Expr), 1);
END;     { FixPrecedence }



{ ----- Determine whether a character may be construed as being numeric. }
FUNCTION IsDigit (Expr: String): Boolean;
BEGIN
   IF Length(Expr) > 0 THEN
      IsDigit := (Pos(Expr[1], '0123456789.') > 0)
   ELSE
      IsDigit := FALSE;
END;     { IsDigit }



{ ----- Convert a character to lowercase. }
FUNCTION LoCase (ch: Char): Char;
BEGIN
   IF ch IN ['A'..'Z'] THEN
      LoCase := CHR(ORD(ch) XOR 32)
   ELSE
      LoCase := ch
END;     { LoCase }



{ ----- Check to make sure parentheses are balanced. }
FUNCTION ParensOk (Expr: String): Boolean;
VAR
   Parens, Posn: Integer;
BEGIN
   Parens := 0;
   FOR Posn := 1 TO Length(Expr) DO
      IF Expr[Posn] = '(' THEN
         Inc(Parens)
      ELSE IF Expr[Posn] = ')' THEN
         Dec(Parens);
   ParensOk := (Parens = 0);
END;     { ParensOk }



{ ----- This grabs a number from the expression. }
FUNCTION Term (VAR Expr: String; VAR ErrCode: Integer): Real;
VAR
   junk: Integer;
   RVal: Real;
   ch: char;
   tmp: String;
BEGIN
   RVal := 0.0;
   ch := Upcase(Expr[1]);
   IF ch <> Locase(ch) THEN BEGIN
      tmp := '';
      REPEAT
         tmp := tmp + ch;
         Delete(Expr, 1, 1);
         ch := Upcase(Expr[1]);
      UNTIL (ch = Locase(ch)) OR (Length(Expr) = 0);
      IF tmp = 'ABS' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := ABS(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'ACOS' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := ArcCos(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'ASIN' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := ArcSin(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'ATAN' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := ARCTAN(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'COS' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := COS(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'FRAC' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := Eval(Expr, ErrCode);
            RVal := RVal - INT(RVal);
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'INT' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := INT(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'LOG' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := LOG(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'PI' THEN
         RVal := 3.141593
      ELSE IF tmp = 'SIN' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := SIN(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'SQRT' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := SQRT(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE IF tmp = 'TAN' THEN
         IF ch = '(' THEN BEGIN
            Delete(Expr, 1, 1);
            RVal := TAN(Eval(Expr, ErrCode))
         END
         ELSE
            ErrCode := 1
      ELSE
         ErrCode := 3
   END
   ELSE IF IsDigit(Expr) THEN BEGIN
      tmp := '';
      WHILE IsDigit(Expr) DO BEGIN
         tmp := tmp + Expr[1];
         Delete(Expr, 1, 1);
      END;
      Val(tmp, RVal, junk);
   END
   ELSE
      ErrCode := 2;
   Term := RVal;
END;     { Term }



END.     { ExtMath UNIT }

