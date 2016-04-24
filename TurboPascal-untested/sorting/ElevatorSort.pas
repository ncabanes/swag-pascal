(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0009.PAS
  Description: Elevator Sort
  Author: PEDRO DUARTE
  Date: 05-28-93  13:57
*)

{
>   Thanks For the code...   It worked great!  BTW, why are there so many
>   different sorting methods?  Quick, bubble, Radix.. etc, etc

Yes, there are lots of sorting algorithms out there! I also found this out
the hard way! :-) A couple of years ago, I only knew the so-called "bubble"
sort, and decided to create my own sorting algorithm. It would have to be
faster than bubble, yet remaining small, simple, and not memory hungry.
and I did it, but only to find out a few weeks later that there were much
better sorts than the one I created... But it sure was great fun beating
bubble! (which is brain-dead anyway! ;-)

So here it is, my two cents to the history of sorting algorithms, the
amazing, blazingly fast (*)... ELEVAtoR SorT!... Why ELEVAtoR??, you ask in
unison! Because it keeps going up & down! :-)
}

Program mysort;

Uses Crt;

Const
  max = 1000;

Type
  list = Array[1..max] of Word;

Var
  data  : list;
  dummy : Word;


Procedure elevatorsort(Var a: list; hi: Word);

Var
  lo,
  peak,
  temp,
  temp2 : Word;

begin
  peak := 1;
  lo   := 1;
  Repeat
    temp  := a[lo];
    temp2 := a[lo + 1];
    if temp > temp2 then
    begin
      a[lo]     := temp2;
      a[lo + 1] := temp;
      if lo <> 1 then dec(lo);
    end
      else
    begin
      inc(peak);
      lo:=peak;
    end;
  Until lo = hi;
end;


begin
  ClrScr;
  Writeln('Generating ', max ,' random numbers...');
  randomize;
  For dummy:=1 to max do data[dummy]:=random(65535);
  Writeln('Sorting random numbers...');
  elevatorsort(data,max);
  For dummy:=1 to max do Write(data[dummy]:5,'   ');
end.

{
(*) it's speed lies somewhere between "BUBBLE" and "inSERT"; it's much
faster than "BUBBLE", and a little slower than "inSERT"... :-)
}

