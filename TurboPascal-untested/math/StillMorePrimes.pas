(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0029.PAS
  Description: Still More Primes
  Author: GUY MCLOUGHLIN
  Date: 08-27-93  21:45
*)

{
GUY MCLOUGHLIN

>the way, it took about 20 mins. on my 386/40 to get prime numbers
>through 20000. I tried to come up With code to do the same With
>Turbo but it continues to elude me. Could anybody explain
>how to Write such a routine in Pascal?

  ...The following PRIME routine should prove to be a bit faster:
}

{ Find the square-root of a LongInt. }
Function FindSqrt(lo_IN : LongInt) : LongInt;

  { SUB : Find square-root For numbers less than 65536. }
  Function FS1(wo_IN : Word) : Word;
  Var
    wo_Temp1,
    wo_Temp2 : Word;
    lo_Error : Integer;
  begin
    if (wo_IN > 0) then
    begin
      wo_Temp1 := 1;
      wo_Temp2 := wo_IN;
      While ((wo_Temp1 shl 1) < wo_Temp2) do
      begin
        wo_Temp1 := wo_Temp1 shl 1;
        wo_Temp2 := wo_Temp2 shr 1;
      end;
      Repeat
        wo_Temp1 := (wo_Temp1 + wo_Temp2) div 2;
        wo_Temp2 := wo_IN div wo_Temp1;
        lo_Error := (LongInt(wo_Temp1) - wo_Temp2);
      Until (lo_Error <= 0);
      FS1 := wo_Temp1;
    end
    else
      FS1 := 0;
  end;

  { SUB : Find square-root For numbers greater than 65535. }
  Function FS2(lo_IN : longInt) : longInt;
  Var
    lo_Temp1,
    lo_Temp2,
    lo_Error : longInt;
  begin
    if (lo_IN > 0) then
    begin
      lo_Temp1 := 1;
      lo_Temp2 := lo_IN;
      While ((lo_Temp1 shl 1) < lo_Temp2) do
      begin
        lo_Temp1 := lo_Temp1 shl 1;
        lo_Temp2 := lo_Temp2 shr 1;
      end;

      Repeat
        lo_Temp1 := (lo_Temp1 + lo_Temp2) div 2;
        lo_Temp2 := lo_IN div lo_Temp1;
        lo_Error := (lo_Temp1 - lo_Temp2);
      Until (lo_Error <= 0);
      FS2 := lo_Temp1;
    end
    else
      FS2 := 0;
  end;

begin
  if (lo_IN < 65536) then
    FindSqrt := FS1(lo_IN)
  else
    FindSqrt := FS2(lo_IN);
end;

{ Check if a number is prime. }
Function Prime(lo_IN : LongInt) : Boolean;
Var
  lo_Sqrt,
  lo_Loop : LongInt;
begin
  if not odd(lo_IN) then
  begin
    Prime := (lo_IN = 2);
    Exit;
  end;
  if (lo_IN mod 3 = 0) then
  begin
    Prime := (lo_IN = 3);
    Exit;
  end;
  if (lo_IN mod 5 = 0) then
  begin
    Prime := (lo_IN = 5);
    Exit;
  end;

  lo_Sqrt := FindSqrt(lo_IN);
  lo_Loop := 7;
  While (lo_Loop < lo_Sqrt) do
  begin
    inc(lo_Loop, 2);
    if (lo_IN mod lo_Loop = 0) then
    begin
      Prime := False;
      Exit;
    end;
  end;
  Prime := True;
end;

