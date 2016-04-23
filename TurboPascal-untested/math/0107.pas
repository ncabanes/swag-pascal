> Could someone post a program to calculate the linear prediction
> coefficients for a discrete sequence using the
> levinson-durbin algorithnm?

{ Input:  Array R - Samples of an autocorrelation function, Rx(k)
          MM - Dimension of the predictor.

  Output: Array a - Predictor coefficients.
          Alfa - error variance.
}

CONST
  MaxDim = 128;                 { max size of the predictor }

TYPE
  AMatrix = ARRAY [0..MaxDim] OF REAL;

PROCEDURE LevinsonDurbin(     R    : AMatrix;  {Autocorrelation martix}
                              MM   : INTEGER;  {Predictor order}
                          VAR a    : AMatrix;  {Predictor coefficients}
                          VAR Alfa : REAL;     {Error variance}

VAR { for LevinsonDurbin}
  m            : INTEGER;
  b            : ARRAY [0..Max_dim] OF REAL;
  km, Alfam, t : REAL;

BEGIN {LevinsonDurbin}
  a[0] := 1;            { initialise }
  Alfam := R[0];
  FOR m := 1 TO MM DO BEGIN
    t := R[m];
    FOR k := 1 TO m-1 DO
      t := t + R[m-k]*a[k];
    km := -t/Alfam;
    FOR k := 1 TO m-1 DO
      b[k] := a[m-k];
    FOR k := 1 TO m-1 DO
      a[k] := a[k] + km*b[k];
    a[m] := km;
    Alfam := Alfam*(1 - a[m]*a[m]);
  END; { FOR m... }
  Alfa := Alfam;

END; { LevinsonDurbin }
