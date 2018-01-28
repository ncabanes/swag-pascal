(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0051.PAS
  Description: Compute POWER of Number
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  17:37
*)


Procedure Power1(Var Num,Togo,Sofar:LongInt);

Begin
  If Togo = 0 then
    Exit;
  If Sofar = 0 then
    Sofar := num
  Else
    Sofar := Sofar*Num;
  Togo := Togo-1;
  Power1(Num,Togo,Sofar)
End;

{
 While this is programatically elegant, an iterative routine would be
 more efficient:
}

  function power2(base,exponent:longint):longint;
     var
        absexp,temp,loop:longint;

     begin
         power2 := 0;  { error }
         if exponent < 0
            then exit;

         temp := 1;
         for loop := 1 to exponent
            do temp := temp * base;
         power2 := temp;
     end;

{
Well it all looks nice, but this is problably the easiest way
}

function Power3(base,p : real): real;
{ compute base^p, with base>0 }
begin
  power3 := exp(p*ln(base))
end;

{ Test program}
var
    n1, n2, n3: longint;
begin
    n1 := 2;
    n2 := 3;
    n3 := 2;
    power1(n1,n2,n3);
    WriteLn( n3 );
    WriteLn( power2(2,4) );
    WriteLn( power3(2,4) );
end.
