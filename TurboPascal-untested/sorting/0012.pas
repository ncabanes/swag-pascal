{
Ok, here is your "fastest sort routine." I spent a couple hours just tweaking
and testing to make sure that it was performing 100%.

Adding $G+ only yielded a very slight speed increase but a noticeable one. (The
speed results below are based on $G-.) Using anything other than Integer for
Variables caused a slight degredation in performance. I would guess that
Integer arithmetic is where Borland focused its optimizations on. Word and
LongInt all caused performance degredation.

AND, it used to be that previous to v6 or v5.5 that multiplication was a bottle
neck too, as in J := I * 3; The faster method was to say J := I+I+I; since
addition is faster than multiplication. I didn't see any appreciable difference
with respect to multiplication over addition here.

The following algorithm is a modified Fibonacci Heap sort With the addition of
a mid-sort bounce technique. It runs almost twice the speed of the Quick Sort
algorithm as posted in my last message.

It Uses considerably less stack then Quick Sort since it is non-recursive. And,
for those of you who hate GOTO's, there's three in this code. Any other way I
could think of would increase data and reduce performance. But you're certainly
welcome to jump in and knock 'em outa there if you can!

Here are the speed results as tested on 386-40mhz:

     500 Elements - (Less than 1/10 second)
    1000 Elements - 0.1 Seconds
    1500 Elements - 0.2 Seconds
    2000 Elements - 0.3 Seconds
    5000 Elements - 1.0 Seconds
    7500 Elements - 1.7 Seconds
   10000 Elements - 2.3 Seconds

I modified the skeleton Program slightly to increase the number of 10 Character
Strings to 10,000 so that I could test that far.

Here is the source code For the algorithm. Just "Plug" it into the skeleton
Program I posted a day or so ago.

{------------------------------------------------------------------------}
Procedure ModHeapSort( Total : Integer );
Var
  I,J,K,L : Integer;
  X, Temp : Pointer;
  M,M1,M2 : Integer;

  Label JumpOut;
  Label Terminate;
  Label SmallSort;

begin
  if Total <= 4 Then
    Goto SmallSort; { Too small For Split sorting }

  M  := Pred(Total) div 3;
  M1 := ( M * 3 ) + 2;

  if M1 <= Total Then
  begin
    if M1 < Total Then
      if SortArray[M1]^ < SortArray[Total]^ Then
        M2 := Total
      ELSE
        M2 := M1
    ELSE
      M2 := M1;

    if SortArray[1]^ < SortArray[M2]^ Then
    begin   { Swap first element to M2 }
      Temp          := SortArray[1];
      SortArray[1]  := SortArray[M2];
      SortArray[M2] := Temp;
    end;

  end; {IF M1 <= Total}

  For L := M DownTo 1 DO
  begin
    X := SortArray[L];
    I := L;
    J := I * 3;

    Repeat

      K := Pred(J);

      if SortArray[K]^ < SortArray[J]^ Then
        K := J;
      if SortArray[K]^ < SortArray[Succ(J)]^ Then
        K := Succ(J);

      SortArray[I] := SortArray[K];
      I := K;
      J := I * 3;

    Until J > M1;

    J := Succ(I) div 3;

    Repeat

      if SortArray[J]^ >= SmallArrPtr(X)^ Then
        Goto JumpOut;

      SortArray[I] := SortArray[J];
      I := J;
      J := Succ(J) div 3;

    Until J < L;

    JumpOut:
      SortArray[I] := X;

  end;

  For L := M1 To Total DO
  begin
    X := SortArray[L];
    I := L;
    J := Succ(I) div 3;

    if SortArray[J]^ < SmallArrPtr(X)^ Then
    begin

      Repeat
        SortArray[I] := SortArray[J];
        I := J;
        J := Succ(J) div 3;
      Until SortArray[J]^ >= SmallArrPtr(X)^;

      SortArray[I] := X;

    end; {IF}
  end; {For}

  L := Total;

  While L > 4 DO
  begin
    X := SortArray[L];
    SortArray[L] := SortArray[1];
    Dec(L,1);
    I := 1;
    J := 3;

    Repeat
      K := Pred(J);

      if SortArray[K]^ < SortArray[J]^ Then
        K := J;
      if SortArray[K]^ < SortArray[Succ(J)]^ Then
        K := Succ(J);

      SortArray[I] := SortArray[K];
      I := K;
      J := I * 3;
    Until J >= L;

    Dec(J,1);

    if J <= L Then
    begin
      if J < L Then
        if SortArray[J]^ < SortArray[L]^ Then
          J := L;
      SortArray[I] := SortArray[J];
      I := J;
    end; {IF}

    J := Succ(I) div 3;

    if SortArray[J]^ < SmallArrPtr(X)^ Then
    Repeat
      SortArray[I] := SortArray[J];
      I := J;
      J := Succ(J) div 3;
    Until SortArray[J]^ >= SmallArrPtr(X)^;

    SortArray[I] := X;
  end;

  { Process last four remaining elements, or less than 4 to sort }
  { Use "Insertion sort" method For best linear time performance }

  SmallSort :
    if Total <= 4 Then
      L := Total
    ELSE
      L := 4;

  For I := 2 To L DO
  begin
    X := SortArray[I];
    For J := Pred(I) DownTo 1 DO
      if SortArray[J]^ > SmallArrPtr(X)^ Then
        SortArray[Succ(J)] := SortArray[J]
      ELSE
        Goto Terminate;
    J := 0;

    Terminate : SortArray[Succ(J)] := X;

  end; {For I}
end;
