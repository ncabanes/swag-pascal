 { The below is a function to convert BCD real numbers into "normal"
   Turbo Reals.  It runs under "normal" Turbo or Turbo-87.  Very likely
   the only use for it is to read BCD reals from a FILE and convert them.
                             --  Neil J. Rubenking}

  TYPE
    RealBCD = array[0..9] of byte;

  FUNCTION BCDtoNorm(R : realBCD) : real;
  Var
    I, IntExponent    : Integer;
    N, Tens, Exponent : Real;
    sign              : integer;
  BEGIN
    IF R[0] = 0 THEN BCDtoNORM := 0
    ELSE
      BEGIN
        IntExponent := (R[0] AND $7F) - $3F;
        IF R[0] AND $80 = $80 THEN Sign := -1 ELSE Sign := 1;
        N := 0; Tens := 0.1;
        FOR I := 9 downto 1 DO
          BEGIN
            N := N + Tens*(R[I] SHR 4);
            Tens := Tens * 0.1;
            N := N + Tens*(R[I] AND $F);
            Tens := Tens * 0.1;
          END;
       Exponent := 1.0;
       FOR I := 1 to IntExponent DO Exponent := Exponent * 10.0;
       BCDtoNORM := Exponent * N * Sign;
     END;
  END;
