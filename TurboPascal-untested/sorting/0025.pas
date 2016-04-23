{ Author: Brian Pape. }

Const
  maxrange = 5000;

Type
  ListRange = 1..MaxRange;
  list = Array[ListRange] of Integer;

Var
  a,b: list;
  i: Integer;

Procedure BubbleSort(Var B : list; Terms : Integer);
Var
  J, Temp : Integer;
  Changed : Boolean;
  Last,
  LastSwitch : Integer;
begin
  changed := True;
  Last := Terms-1;
  While Changed do
  begin
    changed := False;
    For J := 1 to Last do
      If B[J] > B[J+1] then
      begin
        Temp := B[J];
        B[J] := B[J+1];
        B[J+1] := Temp;
        Changed := True;
        LastSwitch := j;
      end;  { If B[J] }
    Last := LastSwitch -1;
  end  { While Changed }
end;  { BubbleSort }

Procedure Min_MaxSort(Var a : list;  NumberTerms : ListRange);
Var
  temp,
  i,l,r,
  min,max,
  tempMin,
  tempMax,
  indexMin,
  indexMax,
  s1,s2,s3,s4 : Integer;
  changed     : Boolean;
begin
  l := 1;  r := NumberTerms;  max := MaxInt;
  Repeat
    min := max;
    changed := False;
    max := 0;
    For i := l to r do
    begin
      if a[i] > max then
      begin
        changed := True;
        Max := a[i];
        indexMax := i;
      end;  { if }
      if a[i] < min then
      begin
        changed := True;
        Min := a[i];
        indexMin := i;
      end;  { if }
    end;  { For }

    tempMin := a[indexMin];
    tempMax := a[indexMax];
    a[indexMax] := a[l];
    a[l] := tempMin;
    a[indexMin] := a[r];
    a[r] := tempMax;
    inc(l);  dec(r);
  Until (l>=r) or not changed;
end;  { Min_MaxSort }


Procedure ShellSort(Var a : list;  NumberTerms : ListRange);
Const
  start = 1;
  increment = 3;  { division factor of terms }
Var
  i,j   : ListRange;
  t     : Integer;
  found : Boolean;
begin
  i := start + increment;
  While i <= NumberTerms do
  begin
    if a[i] < a[i - increment] then
    begin
      j := 1;
      t := a[i];
      Repeat
        j := j - increment;
        a[j + increment] := a[j];
        if j = 1 then
          found := True
        else
          found := a[j - increment] <= t;
      Until found;
      a[j] := t;
    end;  { if }
    i := i + increment;
  end;  { While }
end;  { ShellSort }
