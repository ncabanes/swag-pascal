(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0043.PAS
  Description: Generic QSort
  Author: BJORN FELTEN
  Date: 01-27-94  12:19
*)

{
> Could someone please post some code on using a quick
> sort to sort an array of strings?

   I can do even better than that. I can give you some code on a general qsort
routine that works like in C (if you're familiar with that). I. e. you can sort
any type of arrays, if only you supply the correct compare function. Here
goes...
}

unit QSort;
{*********************************************************
 *                     QSORT.PAS                         *
 *           C-like QuickSort implementation             *
 *     Written 931118 by Björn Felten @ 2:203/208        *
 *           After an idea by Pontus Rydin               *
 *********************************************************}
interface
type CompFunc = function(Item1, Item2 : word) : integer;

procedure QuickSort(
    var Data;
{An array. Must be [0..Count-1] and not [1..Count] or anything else! }
    Count,
{Number of elements in the array}
    Size    : word;
{Size in bytes of a single element -- e.g. 2 for integers or words,
4 for longints, 256 for strings and so on }
    Compare : CompFunc);
{The function that decides which element is "greater" or "less". Must
return an integer that's < 0 if the first element is less, 0 if they're
equal and > 0 if the first element is greater. A simple Compare for
words can look like this:

 function WordCompare(Item1, Item2: word): integer;
 begin
     WordCompare := MyArray[Item1] - MyArray[Item2]
 end;

NB. It's not the =indices= that shall be compared, it's the elements that
the supplied indices points to! Very important to remember!
Also note that the array may be sorted in descending order just by
means of a simple swap of Item1 and Item2 in the example.}

implementation
procedure QuickSort;

  procedure Swap(Item1, Item2 : word);
  var  P1, P2 : ^byte; I : word;
  begin
     if Item1 <> Item2 then
     begin
          I  := Size;
          P1 := @Data; inc(P1, Item1 * Size);
          P2 := @Data; inc(P2, Item2 * Size);
          asm
            mov  cx,I      { Size }
            les  di,P1
            push ds
            lds  si,P2
          @L:
            mov  ah,es:[di]
            lodsb
            mov  [si-1],ah
            stosb
            loop @L
            pop  ds
          end
      end
  end;

  procedure Sort(Left, Right: integer);
  var  i, j, x, y : integer;
  begin
     i := Left; j := Right; x := (Left+Right) div 2;
     repeat
        while compare(i, x) < 0 do inc(i);
        while compare(x, j) < 0 do dec(j);
        if i <= j then
        begin
           swap(i, j); inc(i); dec(j)
        end
     until i > j;
     if Left < j then Sort(Left, j);
     if i < Right then Sort(i, Right)
  end;

begin Sort(0, Count) end;

end. { of unit }

{ A simple testprogram can look like this: }

program QS_Test; {Test QuickSort á la C}
uses qsort;
var v: array[0..9999] of word;
    i: word;

{$F+} {Must be compiled as FAR calls!}
function cmpr(a, b: word): integer;
begin cmpr := v[a] - v[b] end;

function cmpr2(a, b: word): integer;
begin cmpr2 := v[b] - v[a] end;
{$F-}

begin
 randomize;
 for i := 0 to 9999 do v[i] := random(20000);
 quicksort(v, 10000, 2, cmpr);  {in order lo to hi}
 quicksort(v, 10000, 2, cmpr2); {we now have a sorted list, sort it in
                                {reverse -- nasty for qsort!}
 quicksort(v, 10000, 2, cmpr);  {and reverse again}
 quicksort(v, 10000, 2, cmpr);  {sort a sorted list -- also not very popular}
end.


