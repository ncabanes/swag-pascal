(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0141.PAS
  Description: Finding Pentium FDiv Error
  Author: WILLIAM G. S. BROWN
  Date: 05-26-95  23:07
*)

{
From: brownwm@aplcenmp.apl.jhu.edu (William G. S. Brown)

Here is a short Pentium test program that will uncover the FDIV
error. Note: Sometimes just setting X&Y then then printing
X-(X/Y)*Y will not show the error because the optimization is
smart enough to form the answer at compile time.
}

{$N+}
Program Pentium;
{ test a Pentium for FDIV error }
{ computes X-(X/Y)*Y which should be 0.000000}
{     Good Pentium should return 0.000000000E+0000}
{     Bad Pentium will return    2.560000000E+0002}

   var
      X,Y: double;

{ the procedure is to make sure optimization won't hide error }
procedure Test( A,B,C,D : double);
begin { Test }
    writeln(A-(B/C)*D);
end; { Test }

begin { Pentium }
    X := 4195835;
    Y := 3145727;
    Test(X, X, Y, Y); { same as X-(X/Y)*Y e.g. 0.0000}
end. { Pentium }


