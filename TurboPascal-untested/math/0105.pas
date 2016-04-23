{ This simple Pascal program computes a definite integral using Simpson's
  approximation.  Efficiency has been sacrificed for clarity, so it should
  be easy to follow the logic of the program.                        - DJP }

Var                     { Declare variables   }
  a : Integer;          {   Left point        }
  b : Integer;          {   Right point       }
  d : Real;             {   Delta x           }
  i : Integer;          {   Iteration         }
  n : Integer;          {   No. of intervals  }

  SubTotal : Real;

Function y(x:real):Real;   { Define your function here }
  Begin
  y:=1/x
  End;

Function Coefficient(i:Integer):Integer;
  Begin
  If (i=0) or (i=n) Then
    Coefficient:=1
  Else
    Coefficient:=(i Mod 2)*2+2

  { Notes:

    The MOD operater returns the remainder of a division.  This allows
    us to determine if the partition is odd or even.

      <even> MOD 2 = 0
      <odd>  MOD 2 = 1

    An examination of the coefficients of a typical approximation sum shows
    an interesting pattern: Odd partitions have 4 as a coefficient and even
    partitions have 2 as a coefficient.  The first and last partitions are
    exceptions to this rule.  This pattern is used as a basis for
    calculating the coefficient of a given partition.  }

  End;

Function xi(i:Integer):Real;
  Begin
  xi:=a+i*d
  End;

Begin

a:=1;
b:=2;

Repeat
  Write('Subintervals? ');
  ReadLn(n);
Until (n Mod 2)=0; { Even number required }

d:=(b-1)/n;

WriteLn;
WriteLn('  n      xi   f(xi)   c  cf(xi)');
WriteLn('-------------------------------');

For i:=0 to n Do
  Begin
  WriteLn(i:3, xi(i):8:3, y(xi(i)):8:3, Coefficient(i):4,
          Coefficient(i)*y(xi(i)):8:3);
  SubTotal:=SubTotal+Coefficient(i)*y(xi(i))
  End;

WriteLn;
WriteLn('SubTotal',SubTotal:23:3);
WriteLn('Result = ', (d/3)*SubTotal:0:50)

End.

{ Quick Optimizations:

  a. Remove the WriteLn statement in the For loop.
  b. Turn on 80x87 support.
  c. Consolidate some of the procedures.

  peace/dp }

