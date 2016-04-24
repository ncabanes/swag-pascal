(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0123.PAS
  Description: Calculating Interest Rates?
  Author: RICK WHEAT
  Date: 05-30-97  18:17
*)


I use the following function to calculate present value:

function PresentValue(FV, IR, PMT : Real; N : Integer) : Real;
var
   IFactor, IFactor1, R1, R2 : Real;
begin
     {set values of variables}
     IFactor      := (IR / 1200.0);
     IFactor1     := (1.0 + IFactor);
     R1           := Exp(-N * LN(IFactor1));
     R2           := ((FV * IFactor) - (-PMT)) + ((Exp(N * LN(IFactor1))) * (-PMT));
     {calc the result}
     PresentValue := ((R1 * R2) / IFactor);
end;



