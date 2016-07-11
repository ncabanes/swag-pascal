(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0004.PAS
  Description: BUBBLE1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> Does anyone know of a routine or code that would allow For a
> alphabetical sort?

Depends on what Type of sorting you want to do- For a very small list, a
simple BubbleSort will suffice.
}
Const
  max = 50;
Var
  i,j:Integer;
  a : Array[1..max] of String;
  temp : String;
begin
  For i := 1 to 50 do
    For j := 1 to 50 do
      if a[i] < a[j] then
      begin
        temp := a[i];
        a[i] := a[j];
        a[j] := temp;
      end;  { if }
end.

{
If it's a bigger list than, say 100 or so elements, or it needs to be
sorted often, you'll probably need a better algorithm, like a shell sort
or a quicksort.
}
