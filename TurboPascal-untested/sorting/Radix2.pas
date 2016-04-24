(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0021.PAS
  Description: RADIX2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{>...Assuming that the 1000 numbers are in random-order, I imagine
> that the simplest (perhaps fastest too) method would be to:
>    1- Read the numbers in an Array.
>    2- QuickSort the Array.
>    3- First 30 and last 30 of Array are the numbers you want.

>Stop the presses, stop the presses!

  <grin>

>Remember the recent Integer sort contest, on the Intelec
>Programming conference?

  ...Ah, yes... I always tend to Forget about that method.
  Yes, a "count" sort would definitely be the fastest method
  of sorting random numerical data.
  ...What I had a few troubles figuring out from that post
  in the Intelec confrence, wasn't the "count sort" method,
  but rather the "radix sort" or "digital sort" method,
  where specific bits within each data element are used
  to sort the data.

  ...Here's the algorithm listed in Robert Sedgewick's
  "Algorithms" book, published by Addison-Wesley Publishing
  Company, ISBN 0-201-06673-4 :
}

Procedure RadixExchange(l, r, b:Integer);
Var
  t, i, j : Integer;
begin
  if (r > l) and (b >= 0) then
  begin
    i := l;
    j := r;
    Repeat
      While (bits(a[i], b, 1) = 0) and (i < j) do
        i := I + 1;
      While (bits(a[j], b, 1) = 1) and (i < j) do
        j := j - j;
      t := a[i];
      a[i] := a;
      a[j] := t;
    Until (j = i);
    if bits(a[r], b, 1) = 0 then
      j := j + 1;
    RadixExchange(l, (j - 1), b - 1);
    RadixExchange(j, r, (b - 1));
  end;
end;

{
>By toggling the high bit, the Integers are changed in a way that,
>conveniently, allows sorting by magnitude: from the "most negative"
>to "most positive," left to right, using an Array With unsigned
>indexes numbering 0...FFFFh.

  ...Why bother With the bit toggling at all? Why not just define
  the Array's range as being:  Array[-32768..32767] of Byte;
}


