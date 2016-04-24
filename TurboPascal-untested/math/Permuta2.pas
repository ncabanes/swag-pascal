(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0011.PAS
  Description: PERMUTA2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

{
I'm working on some statistical process control Charts and am
learning/using Pascal. The current Chart Uses permutations and
I have been successful in determing the number of combinations
possible, but I want to be able to choose a few of those possible
combinations at random For testing purposes.

Through some trial and error, I've written the following Program
which calculates the number of possible combinations of x digits
with a certain number of digits in each combination. For example
a set of 12 numbers With 6 digits in each combination gives an
answer of 924 possible combinations. After all that, here is the
question: Is there a Formula which would calculate what those 924
combinations are? (ie: 1,2,3,4,5,6 then 1,2,3,4,5,7 then 1,2,3,4,5,8
... 1,2,3,4,5,12 and so on? Any help would be appreciated and any
criticism will be accepted.
}

Program permutations;

Uses Crt;

Type hold_em_here = Array[1..15] of Integer;

Var  numbers,combs,bot2a : Integer;
     ans,top,bot1,bot2b : Real;
     hold_Array : hold_em_here;

Function permutate_this(number1 : Integer) : Real;
Var i : Integer;
    a : Real;
begin
 a := number1;
 For i := (number1 - 1) doWNto 1 do a := a  * i;
 permutate_this := a;
end;

Procedure input_numbers(Var hold_Array : hold_em_here; counter : Integer);
Var i,j : Integer;
begin
 For i := 1 to counter do begin
  Write(' Input #',i:2,': ');
  READLN(j);
  hold_Array[i] := j;
 end;
end;

Procedure show_numbers(hold_Array : hold_em_here; counter : Integer);
Var i,j : Integer;
begin
 WriteLN;
 Write('Array looks like this: ');
 For i := 1 to counter do Write(hold_Array[i]:3);
 WriteLN
end;

begin
 ClrScr;
 WriteLN;
 WriteLN('  Permutations');
 WriteLN;
 Write('     Enter number of digits (1-15): ');
 READLN(numbers);
 Write('Enter number in combination (2-10): ');
 READLN(combs);
 top := permutate_this(numbers);
 bot1 := permutate_this(combs);
 bot2a := numbers - combs;
 bot2b := permutate_this(bot2a);
 ans := top/(bot1*bot2b);
 WriteLN('   total permutations For above is: ',ans:3:0);
 WriteLN;
 input_numbers(hold_Array,numbers);
 show_numbers(hold_Array,numbers);
END.
