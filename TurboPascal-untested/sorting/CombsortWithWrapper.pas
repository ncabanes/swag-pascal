(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0064.PAS
  Description: Combsort with wrapper
  Author: GLENN GROTZINGER
  Date: 11-29-96  08:17
*)

{ Pascal example of COMBSORT with wrapper. }

program combsorttest;
  { Pascal implementation of modified bubble sort or combsort.
    combsort algorithm published 4-91 in Byte by Steven Lacey and
    Richard Box

    Ported from COBOL source by Glenn Grotzinger }

  const
    irgap: real = 1.3;
  var
    a: array[1..20] of integer;
    swapvalue: integer;
    swapnumber: integer;
    i: integer;
    jumpsize, tablesize, upperlimit: integer;
    swap: boolean;

  begin
    randomize;
    for i := 1 to 20 do
      a[i] := random(15);
    for i := 1 to 20 do
      write(a[i], '  ');
    writeln;

    swap := true;
    tablesize := 20;
    jumpsize := tablesize;
    repeat
      jumpsize := trunc(jumpsize/irgap);
      swap := true;
      for i := 1 to (tablesize-jumpsize) do
        begin
          swapnumber := i + jumpsize;
          if a[i] > a[swapnumber] then
            begin
              swapvalue := a[i];
              a[i] := a[swapnumber];
              a[swapnumber] := swapvalue;
              swap := false;
            end;
        end;
    until (swap) and (jumpsize <= 1);

    for i := 1 to 20 do
      write(a[i], '  ');
    writeln;
  end.


