(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0012.PAS
  Description: PERMUTA3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
> I want to create all permutations.

 Okay. I should have first asked if you Really mean permutaions.
 Permutations mean possible orders. I seem to recall your orginal message
 had to do With card hands. They usually involve combinations, not
 permutations. For example, all possible poker hands are the COMBinATIONS
 of 52 cards taken 5 at a time. Bridge hands are the combinations of 52
 cards taken 13 at a time. if you master the following Program, you should
 be able to figure out how to create all combinations instead of
 permutations.

 However, if you mean permutations, here is an example Program to produce
 permutations. (You will have to alter it to your initial conditions.) It
 involves a recursive process (a process which Uses itself). Recursive
 processes are a little dangerous. It is easy to step on your own
 privates writing them. They also can use a lot of stack memory. You
 ought to be able to take the same general methods to produce
 combinations instead of permutations if need be.

 I suggest you Compile and run the Program and see all the permutations
 appear on the screen beFore reading further. (BTW, counts permutations
 as well as producing them and prints out the count at the end.)

 The Procedure Permut below rotates all possible items into the first
 Array position. For each rotation it matches the item With all possible
 permutations of the remaining positions. Permut does this by calling
 Permut For the Array of remaining positions, which is now one item
 smaller. When the remaining Array is down to one position, only one
 permutaion is possible, so the current Array is written out as one of
 the results.

 Once you get such a Program working, it is theoretically possible to
 convert any recursive Program to a non-recursive one. This often runs
 faster. Sometimes the conversion is not easy, however.

 One final caution. The following Program Writes to the screen. You will
 see that as the number of items increases, the amount of output
 increases tremendously. if you were to alter the Program to Write
 results to a File and to allow more than 9 items, you could easily
 create a File as big as your hard drive.
}

Program Permutes;

Uses
  Crt;

Type
  TArry = Array[1..9] of Byte;

Var
  Arry : TArry;
  Size,X : Word;
  NumbofPermutaions : LongInt;

Procedure Permut(Arry : TArry; Position,Size : Word);
Var
  I,J : Word;
  Swap: Byte;
begin
  if Position = Size then
{  begin
    For I := 1 to Size do
      Write(Arry[I]:1);
}    inc(NumbofPermutaions)
{    Writeln
  end
}  else
  begin
    For J := Position to Size do
    begin
      Swap := Arry[J];
      Arry[J] := Arry[Position];
      Arry[Position] := Swap;
      Permut(Arry,Position+1,Size)
    end
  end
end;

begin
  ClrScr;
  Write('How many elements (1 to 9)? ');
  readln(Size);
   ClrScr;
  For X := 1 to Size do
    Arry[X] := X; {put item values in Array}
  NumbofPermutaions := 0;
  Permut(Arry,1,Size);
  Writeln;
  Writeln('Number of permutations = ',NumbofPermutaions);
  Writeln('Press <Enter> to Exit.');
  readln
end.

