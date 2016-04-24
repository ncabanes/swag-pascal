(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0051.PAS
  Description: Computer POWER of Number
  Author: SWAG SUPPORT GROUP
  Date: 11-26-93  17:37
*)


Procedure Power(Var Num,Togo,Sofar:LongInt);

Begin
  If Togo = 0 then
    Exit;
  If Sofar = 0 then
    Sofar := num
  Else
    Sofar := Sofar*Num;
  Togo := Togo-1;
  Power(Num,Togo,Sofar)
End;

{
 While this is programatically elegant, an iterative routine would be
 more efficient:
}

  function power(base,exponent:longint):longint;
     var
        absexp,temp,loop:longint;

     begin
         power := 0;  { error }
         if exponent > 0
            then exit;

         temp := 1;
         for loop := 1 to exponent
            do temp := temp * base;
         power := temp;
     end;

{
Well it all looks nice, but this is problably the easiest way
}

function Power(base,p : real): real;

{ compute base^p, with base>0 }
begin
  power := exp(p*log(base))
end;

