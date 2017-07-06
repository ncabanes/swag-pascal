(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0088.PAS
  Description: Staircase Problem
  Author: ROB VAN GEEL
  Date: 11-26-94  05:00
*)

{
>      Can anyone give me a hand with this problem please! I needs to
> write a recursive function that will compute the number of possible
> ways a person can go up a stair of n steps if that person can take 1,
> 2, or 4 steps in one stride. Thanks in advance!
>
From: R.A.M.vGeel@kub.nl  (GEEL R.A.M.VAN)
}
program StairWay;

var
  Total : longint;
  NrOfSteps : integer;

procedure ClimbStairs(Steps: integer);

begin
  if Steps - 1 = 0 then inc(Total)  { last 1-step }
  else
    if Steps > 0 then
      begin
        if (Steps - 2) = 0 then inc(Total)  { last 2-step }
         else
            if (Steps - 2 > 0) then ClimbStairs(Steps - 2);

        if (Steps - 4) = 0 then inc(Total)  { last 4-step }
          else 
            if (Steps - 4) > 0 then ClimbStairs(Steps - 4);  
      end;
end;
 
begin
  Total := 0;
  write('Give number of steps: ');
  readln(NrOfSteps);
  ClimbStairs(NrOfSteps);
  writeln('Total possibilities: ', Total);
end.
