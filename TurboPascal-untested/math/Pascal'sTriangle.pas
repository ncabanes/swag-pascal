(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0111.PAS
  Description: Re: Pascal's triangle
  Author: CRAIG JACKSON
  Date: 05-31-96  09:17
*)

(*
 procedure triangle(x1,x2,y1,y2,z1,z2 : integer);
   begin
     line(x1,x2,y1,y2);
     line(y1,y2,z1,z2);
     line(z1,z2,x1,x2);
   end;

 Then just put some coordinates in and .......

 use:
 -----

 program test;

  uses
    crt, graph;

  var
    gd, gm : integer;

  {the procedure has to be here}

 begin
   gd:=detect;
   initgraph(gd,gm,'');
   if graphresult <> grok then halt(1);

   triangle(100,200,300,400,50,50);

   readln;
   closegraph;
 end.

 -------

I think the original post was asking for a program to generate Pascal's Triangle.
Pascal's Triangle is a classic example of a recurrence relation that arranges
the binomial coefficients into the shape of a triangle.  The binomial coefficients
are a set of ordered coefficients of the terms in an expansion of a power of a
binomial.  For example:

  Binomial     Expanded                              Coefficients
-----------------------------------------------------------------
  (a+b)^0       1                                    1
  (a+b)^1       a + b                                1,1
  (a+b)^2       a^2 + 2ab + b^2                      1,2,1
  (a+b)^3       a^3 + 3(a^2)b + 3a(b^2) + b^3        1,3,3,1


Here is the top of Pascal's Triangle:

           1
          1 1
         1 2 1
        1 3 3 1
       1 4 6 4 1
     1 5 10 10 5 1
           .
           .
           .

Note that each position of the triangle holds the sum of the two elements
diagonally above it.  If the positions of each row of the triangle are
0..n (from left to right) where n is the number of the current row, then
the coefficient values C(row,position) in each position are calculated as
follows:

	C(n,0) = 1  and  C(n,n) = 1     For n >= 0
	C(n,k) = C(n-1,k) + C(n-1,k-1)  For n > k > 0


Since each row of the triangle is dependent on the row immediately above it,
this lends itself nicely to a recursive algorithm:

*)

FUNCTION CalcCoefficient(CONST n : Integer; CONST k : integer ) : Integer;
  BEGIN
    IF (k=0) or (k=n)
    THEN
      result := 1
    ELSE
      result := CalcCoefficient( n-1, k )  + CalcCoefficient( n-1, k-1 );
  END;


PROCEDURE GenerateTriangle( CONST maxOrder : INTEGER );
  VAR
    currentCoefficient : Integer;
    order              : integer;
    term               : integer;
  BEGIN
    FOR order := 0 TO maxOrder DO
      FOR term := 0 TO order DO
        BEGIN
          currentCoefficient := CalcCoefficient( order, term );
          { now store, or print the current coefficient - whatever you want }
        END;
  END;


Note, recursion, as is often he case, is not the most efficient way to generate
Pascal's Triangle.  In this case, each row of the triangle is calculated repeatedl
for every higher order row.  This wastes a trememdous amount of processing.


