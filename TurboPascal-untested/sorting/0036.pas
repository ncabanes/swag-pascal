{
MATT HARGETT

: want to use the normal ole' bubble sorts and the like (on the order of N),
: for the mere fact that it's just plain old slow!  Could anyone please post
: some code, or pseudo-code of a sort that is on the order of NxLog N?  It wo
}

Program ShellSort;

Var
  A      : Array [1..1000] of Word;
  I, J, N,
  K, Tmp : Integer;

Begin
  N := 1000;
  For I := 1 to N Do
  Begin
    A[I] := Random(5000) + 1;
    Write(A[I] : 6);
  End;

  For K := 3 DownTo 1 Do
    For I := 1 to N - 1 Do
      For J := I + 1 to N Do
        If A[J] < A[I]
          then
          Begin
            Tmp  := A[J];
            A[J] := A[I];
            A[I] := Tmp;
          End;

  Writeln;

  For I := 1 To N Do
    Write(A[I] : 6);
End.

