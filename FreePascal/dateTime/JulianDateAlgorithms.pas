(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0035.PAS
  Description: Julian Date Algorithms
  Author: ROBERT WOOSTER
  Date: 02-03-94  16:07
*)

(*     JULIAN.PAS - test Julian algorithms

     test values: 1/1/79 = 2443875
                1/1/1900 = 2415021
                  1/1/70 = 2440588
                 8/28/40 = 2429870

                              Robert B. Wooster [72415,1602]
                              March 1985

     Note: because of the magnitude of the numbers involved
     here this probably requires an 8x87 and hence is limited
     to MS or PC/DOS machines.  However, it may work with the
     forthcoming BCD routines.
*)

program JULIAN;

var
     JNUM     : real;
     month,
     day,
     year     : integer;

{----------------------------------------------}
function Jul( mo, da, yr: integer): real;
{ this is an implementation of the FORTRAN one-liner:
     JD(I, J, K) = K - 32075 + 1461 * (I + 4800 + (J-14) / 12) / 4
     + 367 * (j - 2 - ((J - 14) / 12) * 12) / 12
     - 3 * (( I + 4900 + (J - 14) / 12) / 100 / 4; where I,J,K are
     year, month, and day.  The original version takes advantage of
     FORTRAN's automatic truncation of integers but requires support
     of integers somewhat larger than Turbo's Maxint, hence all of the
     Int()'s .  The variable returned is an integer day count using
     1 January 1980 as 0. }

var     i, j, k, j2, ju: real;
begin
     i := yr;     j := mo;     k := da;
     j2 := int( (j - 14)/12 );
     ju := k - 32075 + int(1461 * ( i + 4800 + j2 ) / 4 );
     ju := ju + int( 367 * (j - 2 - j2 * 12) / 12);
     ju := ju - int(3 * int( (i + 4900 + j2) / 100) / 4);
     Jul := ju;
end;  { Jul }


{----------------------------------------------}
procedure JtoD(pj: real; var mo, da, yr: integer);
{ this reverses the calculation in Jul, returning the
     result in a Date_Rec }
var     ju, i, j, k, l, n: real;
begin
     ju := pj;
     l := ju + 68569.0;
     n := int( 4 * l / 146097.0);
     l := l - int( (146097.0 * n + 3)/ 4 );
     i := int( 4000.0 * (l+1)/1461001.0);
     l := l - int(1461.0*i/4.0) + 31.0;
     j := int( 80 * l/2447.0);
     k := l - int( 2447.0 * j / 80.0);
     l := int(j/11);
     j := j+2-12*l;
     i := 100*(n - 49) + i + l;
     yr := trunc(i);
     mo := trunc(j);
     da := trunc(k);
end;  { JtoD }



{-----------------MAIN-----------------------------}
begin
     writeln('This program tests the Julian date algorithms.');
     writeln('Enter a calendar date in the form MM DD YYYY <return>');
     writeln('Enter a date of 00 00 00 to end the program.');

     day := 1;
     while day<>0 do begin

          writeln;
          write('Enter MM DD YY '); readln( month, day, year);
          if day<>0 then begin
               JNUM  :=  Jul( month, day, year);
               writeln('The Julian # of ',month,'/',day,'/',year,
                    ' is ', JNUM:10:0);
               JtoD( JNUM, month, day, year);
               Writeln('The date corresponding to ', JNUM:10:0, ' is ',
                         month,'/',day,'/',year);
               end;
          end;
     writeln('That''s all folks.....');
end.

(* end of file JULIAN.PAS *)

