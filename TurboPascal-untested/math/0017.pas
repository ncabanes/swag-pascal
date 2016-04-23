{
SAM HASINOFF

LoopNum forget who first asked this question, but here is some code to help
you find your prime numbers in its entirety (tested):
}

Uses
  Crt;

Label
  get_out;
Var
  LoopNum,
  Count,
  MinPrime,
  MaxPrime,
  PrimeCount : Integer;
  Prime      : Boolean;
  max        : String[20];
  ECode      : Integer;
begin
  minprime := 0;
  maxprime := 0;

  ClrScr;
  Write('Lower limit For prime number search [1]: ');
  readln(max);
  val(max, minprime, ECode);

  if (minprime < 1) then
    minprime := 1;
  Repeat
    GotoXY(1, 2);
    ClrEol;
    Write('Upper limit: ');
    readln(max);
    val(max, maxprime, ECode);
  Until (maxprime > minprime);

  WriteLn;
  PrimeCount := 0;

  For LoopNum := minprime to maxprime do
  begin
    prime := True;
    Count := 2;

    While (Count <= (LoopNum div 2)) and (Prime) do
    begin
      if (LoopNum mod Count = 0) then
        prime := False;
      Inc(Count);
    end;

    if (Prime) then
    begin
      Write('[');
      TextColor(white);
      Write(LoopNum);
      TextColor(lightgray);
      Write('] ');
      Inc(PrimeCount);
      if WhereX > 75 then
        Write(#13#10);
    end;
    if WhereY = 24 then
    begin
      Write('-- More --');
      ReadKey;
      ClrScr;
    end;
    prime := False;
  end;
  Write(#13#10#10);
  Writeln(PrimeCount, ' primes found.', #13#10);
end.
