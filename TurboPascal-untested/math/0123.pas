
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