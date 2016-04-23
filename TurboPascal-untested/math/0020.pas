(***** Find the square-root of an Integer between 1..2,145,635,041  *)
(*                                                                  *)
Function FindSqrt({input} lo_in : LongInt) : {output} LongInt;

  (***** SUB : Find square-root For numbers less than 65417.        *)
  (*                                                                *)
  Function FS1({input } wo_in : Word) : {output} Word;
  Var
    wo_Temp : Word;
  begin
    wo_Temp := 1;
    While ((wo_Temp * wo_Temp) < wo_in) do
      inc(wo_Temp, 11);
    While((wo_Temp * wo_Temp) > wo_in) do
      dec(wo_Temp);
    FS1 := wo_Temp
  end;      (* SUB : FS1.                                           *)

  (***** SUB : Find square-root For numbers greater than 65416.     *)
  (*                                                                *)
  Function FS2(lo_in : LongInt) : LongInt;
  Var
    lo_Temp : LongInt;
  begin
    lo_Temp := 1;
    While ((lo_Temp * lo_Temp) < lo_in) do
      inc(lo_Temp, 24);
    While((lo_Temp * lo_Temp) > lo_in) do
      dec(lo_Temp);
    FS2 := lo_Temp
  end;      (* SUB : FS2.                                           *)

begin
  if (lo_in < 64517) then
    FindSqrt := FS1(lo_in)
  else
    FindSqrt := FS2(lo_in)
end;        (* FindSqrt.                                            *)

{
  ...I've now re-written the "seive" Program, and it appears to now
  run about twice as fast. I'll post the new improved source-code in
  another message.
}