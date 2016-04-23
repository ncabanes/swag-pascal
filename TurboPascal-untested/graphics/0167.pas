{
FROM:	Paul R. Santa-Maria 71674,422, 71674,422
TO:	Gayle Davis, 72067,2726
DATE:	1/16/95 10:47 PM
Re:	SWAG submission (GRAPHICS)

{The algorithm of this line intersection routine is based on vector
cross products of the line endpoints.  The recursion is only one level 
deep, to handle a specific degenerate case (collinear lines).  If the 
degenerate case is detected, it nudges one end of one line and looks 
to see if the intersection criterion is still fulfilled.  If not, it 
nudges the other end and tries again.--Steve Schafer [CIS 76711,522]}
 
  function INTERSECT(L1X1, L1Y1, L1X2, L1Y2,
                     L2X1, L2Y1, L2X2, L2Y2 : LongInt) : Boolean;
  var
    Z1, Z2, Z3, Z4 : LongInt;
  begin
    Z1 := L1X1*(L2Y2-L2Y1)+L2X2*(L2Y1-L1Y1)+L2X1*(L1Y1-L2Y2);
    Z2 := L2X1*(L1Y1-L1Y2)+L1X1*(L1Y2-L2Y1)+L1X2*(L2Y1-L1Y1);
    Z3 := L1X2*(L2Y1-L2Y2)+L2X1*(L2Y2-L1Y2)+L2X2*(L1Y2-L2Y1);
    Z4 := L2X2*(L1Y2-L1Y1)+L1X2*(L1Y1-L2Y2)+L1X1*(L2Y2-L1Y2);
    if (Z1 = 0) and (Z2 = 0) and (Z3 = 0) and (Z4 = 0) then
      INTERSECT := (INTERSECT(L1X1, L1Y1, L1X2, L1Y2, L2X1, L2Y1, 
                              L2X1+L2Y2-L2Y1, L2Y1+L2X1-L2X2) or 
                    INTERSECT(L1X1, L1Y1, L1X2, L1Y2, L2X2+L2Y2-L2Y1,
                              L2Y2+L2X1-L2X2, L2X2, L2Y2))
    else if (((Z1 >= 0) and (Z2 >= 0) and (Z3 >= 0) and (Z4 >= 0)) or
             ((Z1 <= 0) and (Z2 <= 0) and (Z3 <= 0) and (Z4 <= 0))) then
      INTERSECT := True
    else
      INTERSECT := False;
  end;
 

