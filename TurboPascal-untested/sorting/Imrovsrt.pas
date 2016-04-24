(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0011.PAS
  Description: IMROVSRT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
MARK OUELLET

> I code these things this way:
>
> for I := 1 to MAX-1 do
> for J := I+1 to MAX do
> if A[I] < A[J] then
> begin
> ( swap code )
> end

    this can be improved even more. By limiting the MAX value on each
successive loop by keeping track of the highest swaped pair.

    If on a particular loop, no swap is performed from element MAX-10
onto the end. Then the next loop does not need to go anyhigher than
MAX-11. Remember you are moving the highest value up, if no swap is
performed from MAX-10 on, it means all values above MAX-11 are in order
and all values below MAX-10 are smaller than MAX-10.
}

{$X+}
program MKOSort;

USES
  Crt;

Const
  MAX = 1000;

var
  A : Array[1..MAX] of word;
  Loops : word;

procedure Swap(Var A1, A2 : word);
var
  Temp : word;
begin
  Temp := A1;
  A1   := A2;
  A2   := Temp;
end;

procedure working;
const
  cursor : array[0..3] of char = '\|/-';
  CurrentCursor : byte = 1;
  Update : word = 0;
begin
  update := (update + 1) mod 2500;
  if update = 0 then
  begin
    DirectVideo := False;
    write(Cursor[CurrentCursor], #13);
    CurrentCursor := ((CurrentCursor + 1) mod 4);
    DirectVideo := true;
  end;
end;

procedure Bubble;
var
  Highest,
  Limit, I  : word;
  NotSwaped : boolean;
begin
  Limit := MAX;
  Loops := 0;
  repeat
    I := 1;
    Highest := 2;
    NotSwaped := true;
    repeat
      working;
      if A[I] > A[I + 1] then
      begin
        Highest := I;
        NotSwaped := False;
        Swap(A[I], A[I + 1]);
      end;
      Inc(I);
    until (I = Limit);
    Limit := Highest;
    Inc(Loops);
  until (NotSwaped) or (Limit <= 2);
end;

procedure InitArray;
var
  I, J : word;
  Temp : word;
begin
  randomize;
  for I := 1 to MAX do
    A[I] := I;
  for I := MAX - 1 downto 1 do
  begin
    J := random(I) + 1;
    Swap(A[I + 1], A[J]);
  end;
end;

procedure Pause;
begin
  writeln;
  writeln('Press any key to continue...');
  while keypressed do
    readkey;
  while not keypressed do;
  readkey;
end;

procedure PrintOut;
var
  I : word;
begin
  ClrScr;
  For I := 1 to MAX do
  begin
    if WhereY >= 22 then
    begin
      Pause;
      ClrScr;
    end;
    if (WhereX >= 70) then
      Writeln(A[I] : 5)
    else
      Write(A[I] : 5);
  end;
  writeln;
  Pause;
end;

begin
  ClrScr;
  InitArray;
  PrintOut;
  Bubble;
  PrintOut;
  writeln;
  writeln('Took ', Loops, ' Loops to complete');
end.

