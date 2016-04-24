(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0012.PAS
  Description: EASTER.PAS
  Author: JEAN MEEUS
  Date: 05-28-93  13:37
*)

{    ===============================================================
    From chapter 4 of "Astronomical Formulae for Calculators" 2nd
    edition; by Jean Meeus; publisher: Willmann-Bell Inc.,
    ISBN 0-943396-01-8 ...

                            Date of Easter.

    The method used below has been given by Spencer Jones in his
    book "General Astronomy" (pages 73-74 of the edition of 1922).
    It has been published again in the "Journal of the British
    Astronomical Association", Vol.88, page 91 (December 1977)
    where it is said that it was devised in 1876 and appeared in
    the Butcher's "Ecclesiastical Calendar."

    Unlike the formula given by Guass, this method has no exception
    and is valid for all years in the Gregorian calendar, that is
    from the year 1583 on.

    [...text omitted...]

    The extreme dates of Easter are March 22 (as in 1818 and 2285)
    and April 25 (as in 1886, 1943, 2038).
    ===============================================================

    The following Modula-2 code by Greg Vigneault, April 1993.

    Converted To Pascal by Kerry Sokalsky
}
Procedure FindEaster(Year : Integer);
{ Year MUST be greater than 1583 }
VAR
  a, b, c,
  d, e, f,
  g, h, i,
  k, l, m,
  n, p  : INTEGER;
  Month : String[5];
BEGIN
  If Year < 1583 then
  begin
    Writeln('Year must be 1583 or later.');
    Exit;
  end;

  a := Year MOD 19;
  b := Year DIV 100;
  c := Year MOD 100;
  d := b DIV 4;
  e := b MOD 4;
  f := (b + 8) DIV 25;
  g := (b - f + 1) DIV 3;
  h := (19 * a + b - d - g + 15) MOD 30;
  i := c DIV 4;
  k := c MOD 4;
  l := (32 + 2 * e + 2 * i - h - k) MOD 7;
  m := (a + 11 * h + 22 * l) DIV 451;
  p := (h + l - 7 * m + 114);
  n := p DIV 31;                  (* n = month number 3 or 4  *)
  p := (p MOD 31) + 1;            (* p = day in month         *)

  IF (n = 3) THEN
    Month := 'March'
  ELSE
    Month := 'April';

  WriteLn('The date of Easter for ', Year : 4, ' is: ', Month, p : 3);

END;


begin
  FindEaster(1993);
end.
