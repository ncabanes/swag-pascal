(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0006.PAS
  Description: GCD.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{Greatest common divisor}
Program GCD;

Var
  x, y : Integer;

begin
  read(x);

  While x <> 0 do
  begin
    read(y);

    While x <> y do
      if x > y then
        x := x - y
      else
        y := y - x;

    Write(x);
    read(x);

  end;
end.

