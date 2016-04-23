{
> I am trying to learn Turbo Pascal 7.0 and I was hoping someone might
> post the code to some simple fractals or anything else that you think
> might be educating...

Note that my code will not work unless you've got my VGAUnit.  It doesn't
look very easy to convert it to use Borland's Graphics unit, either.
}
USES Crt, VGAUnit;
 
CONST 
  DStep  = 0.2; 
  Detail = 100; 
 
TYPE 
  Complex = RECORD 
              a, b : REAL; 
            End; 
 
VAR 
  Lambda, Z_Prime, Z : Complex; 

FUNCTION Rnd : REAL; 
Begin 
  Rnd := Random( 65001 ) / 65000; 
End; 
 
PROCEDURE Fractal( Lambda, Z_Prime : Complex; Count : INTEGER ); 
VAR 
  k            : INTEGER; 
  LambdaMag    : REAL; 
  FourOverLamb : Complex; 
 
  PROCEDURE CalcPoint( Z_Prime : Complex; VAR Z : Complex ); 
  VAR 
    SaveB : REAL; 
 
    PROCEDURE ComplexMult( C1, C2 : Complex; VAR Result : Complex ); 
    Begin 
      Result.A := C1.A * C2.A - C1.B * C2.B; 
      Result.B := C1.A + C2.B + C1.B * C2.A; 
    End;  { ComplexMult } 
 
    PROCEDURE ComplexSqrt( C : Complex; VAR Result : Complex ); 
    VAR 
      CMag : REAL; 
 
    Begin 
      CMag := Sqrt( C.A * C.A + C.B * C.B ); 
 
      IF (CMag + C.A) < 0 THEN 
        Result.A := 0 
      ELSE 
        Result.A := Sqrt( ( CMag + C.A ) / 2 );
      IF (CMag - C.A) < 0 THEN 
        Result.B := 0 
      ELSE 
        Result.B := Sqrt( ( CMag - C.A ) / 2 ); 
    End;  { ComplexSqrt } 
 
  { CalcPoint } 
  Begin 
    ComplexMult( Z_Prime, FourOverLamb, Z ); 
 
    Z.A   := 1 - Z.A; 
    SaveB := Z.B; 

    ComplexSqrt( Z, Z ); 
 
    IF SaveB < 0 THEN 
      Z.A := -Z.A; 
 
    IF Rnd < 0.5 THEN 
    Begin 
      Z.A := -Z.A; 
      Z.B := -Z.B; 
    End; 
 
    Z.A := 1 - Z.A; 
    Z.A := Z.A / 2; 
    Z.B := Z.B / 2; 
  End;  { CalcPoint } 
 
Begin  { Fractal } 
  LambdaMag := Lambda.A * Lambda.A + Lambda.B * Lambda.B; 
  FourOverLamb.A := 4 * Lambda.A / LambdaMag; 
  FourOverLamb.B := -4 * Lambda.B / LambdaMag; 
 
  FOR K := 1 TO 10 DO 
  Begin 
    CalcPoint( Z_Prime, Z ); 
    Z_Prime := Z; 
  End; 
 
  FOR K := 1 TO Count DO 
  Begin 
    CalcPoint( Z_Prime, Z ); 
 
    IF WinGetPix( Z.A, Z.B ) = BLACK THEN
      WinPutPix( Z.A, Z.B, 
        (Abs(Round({Z.A * Z.B *} Lambda.A * Lambda.B * 256)) MOD 254) + 1 ); 
 
    Z_Prime := Z; 
  End; 
End; 
 
VAR 
  Ch      : CHAR; 
  R1, G1, 
  B1, R2, 
  G2, B2  : BYTE; 
  Lim1,
  Lim2    : LONGINT; 
 
Begin 
  Randomize; 
 
  VGA; 
  BlendColours( 1, 255, RGBToLong( 60, 60, 60 ), RGBToLong( 0, 0, 63 ), 0 ); 
 
  Window( -1, 1, 1, -1 ); 
 
  Lambda.A  := 13; 
  Lambda.B  := -0.7; 
  Z_Prime.A := 0.1; 
  Z_Prime.B := -0.1; 
  Ch        := #0; 
 
  Repeat 
    Fractal( Lambda, Z_Prime, Detail ); 
    Lambda.A := Lambda.A + DStep; 
  Until (Lambda.A >= 100) OR (KeyPressed AND (ReadKey = #27)); 
 
  R1 := Random( 64 ); 
  G1 := Random( 64 ); 
  B1 := Random( 64 ); 
 
  Repeat 
    R2 := Random( 64 ); 
    G2 := Random( 64 ); 
    B2 := Random( 64 ); 
 
    Lim1 := RGBToLong( R1, G1, B1 ); 
    Lim2 := RGBToLong( R2, G2, B2 );

    BlendColours( 1, 255, Lim1, Lim2, 10 );

    R1 := R2;
    G1 := G2;
    B1 := B2;
  Until KeyPressed AND (ReadKey = #27);

  IF ReadKey = #27 THEN;

  TextMode;
End.
