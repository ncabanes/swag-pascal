(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0134.PAS
  Description: Calculate definite integral using Romber
  Author: ROBY JOHANES
  Date: 01-02-98  07:35
*)

{  Calculate definite integral using Romberg method
   ------------------------------------------------
   Features:
     You can calculate *ANY* functions with any range (except infinites)
     with a *PRECISE* calculation
   Drawbacks:
     May have errors if the real result is 0. But the error is not
     significant. It may display something like 6.1200032e-18 or any
     small insignificant numbers.

   Program made by: Roby Johanes
   http://www.geocities.com/SiliconValley/Park/3230
   Finished in September 1997

   Latest update : December 1997 for submission to SWAG

   Note from author:
*  Your computer should have a numeric coprocessor intact otherwise this
   program would execute very slowly since it consumes lots of CPU power
*  If you want to have more precise calculation, make the mj (integration
   improvement) and mk (integration order) bigger.

   A little intro...
   -----------------------------
   What is Romberg integration?

   It is a method of massive recursive calculations to calculate the value
   of an integral. As many methods are being developed, this method seems
   to generalize them all. I don't want to explain it in-depth mathematic,
   but this is the general idea:

   Integral is actually the area below the function. The first idea to
   calculate definite integral without even integrating the function
   itself is using trapezium formulae. It is:

       (b - a)
   A = -------  *  [ f(b) + f(a) ]
          2

   This method is then developed into Simpson integral, which is a slight
   improvement of calculation. The first Simpson is the well-known 1/3
   Simpson's rule. Later on that rule is improved into 3/8 Simpson's rule
   which offers more precise calculations.

   The last improvement made was Boyle's rule. It is a very good
   approximation in calculating integrals. If you are interested in this
   area, I suggest you to refer to any Numerical Methods books.

   Other approach is, beside improving methods, by doing iteration using
   existing method. So, the integrating area is then divided (usually
   vertically, and I did here in my program) into n equal parts so that
   each part is small enough in order to minimize the calculation error.
   The result of each individual parts are accumulated into the final
   result. However, the drawback is that the error is also accumulated.
   But, iteration is widely used throughout the world because this
   method is the easiest way to accomplish the calculation. Also, if each
   part is small enough, the error is negligible.

   Then, there come recursive method. This method emerges after computer
   become ready to assist scientists in calculations (silly). Iterations
   can be done in the computer but costs a lot of computing resources.
   The main goal of recursive method is to reduce the calculating time.
   (oh really? By the way, this is the theorem...)
   -----------------
   Recursive trapezium approximation formulae:
                          2^(J-1)
     T(J) = T(J-1)/2 + h *   Σ   f(X    )       for j > 0
                            k=1     2k-1

     Where h = (b-a) / 2^J  and Xi = a + ih

     If J = 0, then T(0) = h/2 * ( f(a) + f(b) )
   -----------------
   As we may see that the trapezium method is calculated recursively as
   above. The J here is called the order. The higher the order, the more
   precise the calculation.

   1/3 Simpson's rule, 3/8 Simpson's Rule, and Boyle's Rule are also
   implemented into recursive. However, Romberg sees more. He then gene-
   ralize them all into one formulae:
   -----------------
   Romberg formulae:

               4^k * R(J, K-1) - R(J-1, K-1)
   R (J, K) = -------------------------------   with 1 <= K <= J
                         4^k - 1

   When K = 0, R(J, 0) = Trapezium(J)
   -----------------
   Actually, R(J,0) is Trapezium Jth order
             R(J,1) is 1/3 Simpson's Rule Jth order
             R(J,2) is 3/8 Simpson's Rule Jth order
             R(J,3) is Boyle's Rule Jth order
   So, you can derive any better improvement methods. If Boyle's Rule is
   the third improvement method, then R(J,4) is the fourth, R(J,5) is the
   fifth and so on.

   I won't give the mathematical prove here, but read Numerical Methods
   books instead. I also don't remember the mathematical prove of the
   order of error, but I can tell you this: The order of error is
   O(n ^ 2k). So, the higher the K (improvement number), the error is
   much less (squared).

   Therefore, Romberg integration is a very powerful method in calculating
   integrals. You can give any number to J and K (in program mj and mk)
   but remember that your computer has a limited calculating power. Beside,
   you need a tremendous stack since the calculations involve massive
   recursive calls.

------------------------
 * USING THE PROGRAM *
------------------------

You can modify the constants mj, mk, a, and b and try it yourself!
Also, you can modify the evaluated function. The default is 1/sqrt(x).
You can say any functions as you wish as long as your Pascal provides
a mean to express it.

The program itself is explanatory. All implementations refer to the
theorem above.

}
{$N+,E-,X+}
{$M 65520,0,655360}
uses crt;
const
  mj : integer = 10;       { Integration order }
  mk : integer = 4;        { Integration improvement }
  a  : real    = 0.25;     { Lower bound }
  b  : real    = 4.0;      { Upper bound }

function f(x : real):real;
begin
  f:= 1/sqrt(x);
end;

{
  Recursive trapezium approximation formulae:
                          2^(J-1)
     T(J) = T(J-1)/2 + h *   Σ   f(X    )       for j > 0
                            k=1     2k-1

     Where h = (b-a) / 2^J  and Xi = a + ih

     If J = 0, then T(0) = h/2 * ( f(a) + f(b) )
}
function trapeze(j: integer): real;
var k, n   : integer;
    h, sum : real;
begin
  n := 1 shl j;     { n = 2^J }
  h := (b-a)/n;
  if j>0 then
  begin
    sum:=0.0;
    for k:=1 to (n shr 1) do sum:=sum+f(a + (2*k-1)*h);
    trapeze:=trapeze(j-1)/2.0 + h*sum;
  end
  else trapeze:= (h/2.0) * (f(a)+f(b));
end;

{
  Romberg formulae:

              4^k * R(J, K-1) - R(J-1, K-1)
  R (J, K) = -------------------------------   with 1 <= K <= J
                        4^k - 1

  When K = 0, R(J, 0) = Trapezium(J)
}
function romberg(j, k: integer): real;
var n : real;
begin
  n := exp(k*ln(4.0));  { n = 4^k }
  if k>0 then
     romberg:=(n*romberg(j,k-1)-romberg(j-1,k-1)) / (n-1.0)
  else
     romberg:=trapeze(j);
end;

begin
  clrscr;
  writeln(romberg(mj, mk):4:8);
  readkey;
end.

