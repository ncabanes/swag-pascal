(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0008.PAS
  Description: COUNT2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
>I'm in need of a FAST way of finding the largest and the smallest
>30 numbers out of about 1000 different numbers.
> ...Assuming that the 1000 numbers are in random-order, I imagine
> that the simplest (perhaps fastest too) method would be to:
>    1- Read the numbers in an Array.
>    2- QuickSort the Array.
>    3- First 30 and last 30 of Array are the numbers you want.
>  ...Here's a QuickSort demo Program that should help you With the
>  sort: ...

 Stop the presses, stop the presses!

 Remember the recent Integer sort contest, on the Intelec Programming
 conference?  The fastest method was a "counting" sort technique, which
 used the Integers (to be sorted) as indexes of an Array.

 You asked John Kuhn how it worked, as his example code was in messy
 C.  I sent you an explanation, along With example TP source.  Around
 that time my link to Intelec was intermittently broken; I didn't
 hear back from you - so you may not have received my message (dated
 Jan.02.1993).  I hope you won't mind if I re-post it here and now...

 In a message With John Kuhn...
> Simply toggle the sign bit of the values beFore sorting. Everything
> falls into place appropriately from there.
>  ...OK, but how about toggling them back to their original
>  state AFTER sorting? (I want to maintain negative numbers)
>  How can you tell which data elements are negative numbers???

 Hi Guy,

 if you've got all of this under your belt, then please disregard
 the following explanation ...

 By toggling the high bit, the Integers are changed in a way that,
 conveniently, allows sorting by magnitude: from the "most negative"
 to "most positive," left to right, using an Array With unsigned
 indexes numbering 0...FFFFh.  The Array size represents the number
 of all possible (16-bit) Integers... -32768 to 32767.

 The "Count Sort" involves taking an Integer, toggling its high bit
 (whether the Integer is originally positive or negative), then
 using this tweaked value as an index into the Array.  The tweaked
 value is used only as an Array index (it becomes an unsigned
 index somewhere within 0..FFFFh, inclusive).

 The Array elements, which are initialized to zero, are simply the
 counts of the _occurrences_ of each Integer.  The original Integers,
 With proper sign, are _derived_ from the indexes which point to
 non-zero elements (after the "sort")... ie. an original Integer is
 derived by toggling the high bit of a non-zero element's index.

 Array elements of zero indicate that no Integer of the corresponding
 (derived) value was encountered, and can be ignored.  if any element
 is non-zero, its index is used to derive the original Integer.  if
 an Array element is greater than one (1), then the corresponding
 Integer occurred more than once.

 A picture is worth 1000 Words:  The following simplified example
 sorts some negative Integers.  The entire Count Sort is done by
 a Single For-do-inC() loop - hence its speed.  The xors do the
 required high-bit toggling ...
}


Program DemoCountSort; { Turbo Pascal Count Sort.  G.Vigneault }

{ some negative Integers to sort ... }
Const
  SomeNegs        : Array [0..20] of Integer =
                       (-2,-18,-18,-20000,-100,-10,-8,-11,-5,
                        -1300,-17,-1,-16000,-4,-12,-15,-19,-1,
                        -31234,-6,-7000 );

{ pick an Array to acComplish Count Sort ... }
Var
  NegNumArray     : Array [$0000..$7FFF] of Byte;
{ PosNumArray     : Array [$8000..$FFFF] of Byte;            }
{ AllNumArray     : Array [$0000..$FFFF] of Byte;  use heap  }
  Index           : Word;
  IntCount        : Byte;

begin
  { Initialize }
  FillChar( NegNumArray, Sizeof(NegNumArray), 0 );

  { Count Sort (the inC does this) ... }

  For Index := 0 to 20 do
    { Just 21 negative Integers to sort }
    inC( NegNumArray[ Word(SomeNegs[Index] xor $8000) ]);

  { then display the sorted Integers ... }
  For Index := 0 to $7FFF do
    { Check each Array element }
    For IntCount:= 1 to NegNumArray[Index] do
      { For multiples }
      WriteLn( Integer(Index xor $8000) ); { derive value }

end { DemoCountSort }.
