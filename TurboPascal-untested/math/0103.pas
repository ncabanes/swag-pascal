
unit Math;

interface

FUNCTION LogTen( X: REAL ) : REAL;
FUNCTION Power( x: REAL; y: REAL ) : REAL;
FUNCTION PowerInt( x: Integer; y: Integer ) : Integer;
FUNCTION PowerI( x: REAL; i: INTEGER ) : REAL;
FUNCTION PowTen( Power : INTEGER ) : REAL;

implementation

FUNCTION LogTen( X: REAL ) : REAL;
BEGIN (* LogTen *)

   IF X <= 0.0 THEN
      LogTen := 0.0
   ELSE
      LogTen := LN( X ) * (1/ln(10));
end;

FUNCTION Power( x: REAL; y: REAL ) : REAL;
BEGIN (* Power *)
   IF x > 0 THEN
       Power := EXP( y * LN( x ) )
   ELSE
      Power := 0.0;
END   (* Power *);

FUNCTION PowerInt( x: Integer; y: Integer ) : Integer;
var
N,i : Integer;
begin
N:=X;
for i:=1 to y-1 do x:=x * n;
PowerInt:=X;
end;

FUNCTION PowerI( x: REAL; i: INTEGER ) : REAL;
VAR
   Temp: REAL;
   AbsI: INTEGER;

BEGIN (* PowerI *)
   IF i < 0 THEN
      BEGIN
         i := -i;
         IF x <> 0.0 THEN x := 1.0 / x;
      END;
Temp := 1.0;
   WHILE( i > 0 ) DO
      BEGIN
         WHILE ( NOT ODD( i ) ) DO
            BEGIN
               i := i DIV 2;
               x := x * x;
            END;
         i    := i - 1;
         Temp := Temp * x;
      END;
   PowerI := Temp;
END   (* PowerI *);

FUNCTION PowTen( Power : INTEGER ) : REAL;
VAR
   Temp   : REAL;
   I      : INTEGER;
   AbsPow : INTEGER;
   X      : REAL;
BEGIN (* PowTen *)
   X     := 10.0;
   IF Power < 0 THEN
      BEGIN
         Power := -Power;
         X     := 0.1;
      END;
   Temp := 1.0;
   WHILE( Power > 0 ) DO
      BEGIN
         WHILE ( NOT ODD( Power ) ) DO
            BEGIN
               Power := Power DIV 2;
               X     := X * X;
            END;
          Power := Power - 1;
         Temp  := Temp  * X;
      END;
   PowTen := Temp;
END   (* PowTen *);

begin
end.
