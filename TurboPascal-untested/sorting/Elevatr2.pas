(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0010.PAS
  Description: ELEVATR2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
>Why can't Borland come out With a Universal sort since they made the
>Program.. <G>

I guess there's no such thing as a "universal" sort... There are a few very
good sorting algorithms, and depending on some factors, you just have to
choose the one that best fits your needs!

Here's an update to my ELEVAtoR sort, this one's even faster!
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
  dummy,
  low,
  peak,
  temp,
  temp2  : Word;

begin
  peak   := 1;
  low    := 1;
  temp2  := a[low + 1];
  Repeat
    temp  := a[low];
    if temp > temp2 then
    begin
      a[low]     := temp2;
      a[low + 1] := temp;
      if low <> 1 then dec(low);
    end
      else
    begin
      inc(peak);
      low:=peak;
      if low <> hi then temp2:=a[low + 1];
    end;
  Until low = hi;
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

