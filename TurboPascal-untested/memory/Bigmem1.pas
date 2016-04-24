(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0001.PAS
  Description: BIGMEM1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

> I have seen posts about using Pointer Arrays instead of the standard fixed
> Arrays.  These posts have been helpful but I think the rewriting of an example
> problem would benefit me the best.  Please take a look at this simple example
> code:
>
> Program LotsofData;
>
> Type LOData = Array [1..10000] of Real;
>
> Var Value : LOData;
>     MaxSizeArray, I, NumElement : Integer;
>     NewValue : Real;
>
> begin
>   Write('Please input the Maximum Size of the Array: ');
>   Readln(MaxSizeArray);
>   For I := 1 to MaxSizeArray Do
>     Value[I] := 0.0;
>   Writeln('Array Initialized');
>   Writeln;
>   Write('Please input the Number of Array Element to Change: ');
>   Readln(NumElement);
>   Write('Please input the New Number For Value[',NumElement,']: ');
>   Readln(NewValue);
>   Value[NumElement] := NewValue;
> end.
>

Response;
1. Declare the Variable Value as LOData -
        e.g. Var Value : LOData;

2. Read MaxSizeArray;

3. Allocate memory For the Array by using NEW() or GETMEM()
         e.g. NEW(Value);
        or   GetMem(Value, Sizeof(Real) * MaxSizeArray);

Getmem() is better because you can allocate just the precise amount of
memory needed.

4. From then on refer to your Array as Value
        e.g. Value[Element] := NewValue;

5. When you finish, deallocate memory by
        [a] Dispose(Value) - if you used NEW() to begin with, or
        [b] FreeMem(Value, Sizeof(Real) * MaxSizeArray) - if you used
        GetMem() to begin with.


