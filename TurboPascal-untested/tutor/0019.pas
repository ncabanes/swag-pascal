                       Turbo Pascal for DOS Tutorial
                            by Glenn Grotzinger
                      Part 16: Searching an Array
                copyright(c) 1995-96 by Glenn Grotzinger

There was no defined problem in part 15, so we will start.

Sequential Array Search
=======================
This method for searching arrays for items is much like the bubblesort
is for sorting arrays.  It works well for small arrays, but for larger
arrays, it is very inefficient, if we are merely interested in the
existence of an item in the array.  Basically, it's a very simple
proposition to set up a sequential array search.

program example_of_sequential_search;

  var
    a: array[1..15] of integer;
    i, number: integer;
    found: boolean;

  begin
    randomize;
    found := false;

    write('The array is: ');
    for i := 1 to 15 do
      begin
        a[i] := random(10) + 1;
        write(a[i], ' ');
      end;
    writeln;

    writeln('Enter a number, and we shall see if it is in the array');
    readln(number);

    i := 1;
    while i <= 15 do
      begin
        if a[i] = number then
          begin
            writeln(number, ' was found at position ', i);
            { i := 15; can be done to break the loop on the first
              encounter of the one if we are interested in just
              whether the number exists in the array }
            found := true;
          end;
        inc(i);
      end;
    if not found then
      writeln(number, ' was not found in the array.');
  end.

Binary Search
=============
The other type of algorithm we will discuss is the binary search.  It is
to searching an array what the quicksort is to sorting an array.  Basically,
what it will do is keep halfing the array...

This method of array search has a prerequisite of having the data sorted.
Basically, we probably would want to sort data anyway to make it in
a readily presentable format for the user, so this doesn't necessarily
matter  (searches and sorts are products of data processing programs
normally, anyway).

program example_of_binary_search;

  const
    first = 1;
    last = 15;
  var
    a: array[first..last] of integer;
    i, number: integer;
    found: boolean;
    location: integer;

  procedure bsearch(var number, location: integer;
                      lowend, highend: integer; var found: boolean);
    var
      midpoint: integer;
    begin
      if lowend > highend then
        found := false
      else
        begin
          midpoint := (lowend + highend) div 2;
          if number = a[midpoint] then
            begin
              found := true;
              location := midpoint;
            end
          else if number < a[midpoint] then
            bsearch(number, location, lowend, midpoint-1, found)
          else if number > a[midpoint] then
            bsearch(number, location, midpoint+1, highend, found);
        end;
    end;

  begin
    randomize;
    found := false;

    write('The array is: ');
    for i := 1 to 15 do
      begin
        { to insure we have sorted data }
        a[i] := 3*i;
        write(a[i], ' ');
      end;
    writeln;

    writeln('Enter a number, and we shall see if it is in the array');
    readln(number);

    bsearch(number, location, first, last, found);

    if found then
      writeln(number, ' was found at position ', location)
    else
      writeln(number, ' was not found. ');

end.

As you may be able to pick out of this, it is possible to write an iterative
version of the bsearch procedure.  With sorting the array, though, this one
is a little better than simply going through the array one by one, but it
still has it's drawback of having to actually sort the information.

Another method available for use, which we will not discuss here is called
hashing, which is a very complex matter.

What should you use?  The serial search I described originally could be
very good, for a limited number of searches on a small array size.

If it's not good to do the serial search, and you needed to sort the data
anyway, the binary search is best.

Another method you may see as possible to use will be covered later, called
the binary search tree.  The cost in that approach will be basically building
the tree initially, then traversing it.  The tree is built based on specific
rules, which we can exploit to cause a search.

Practice Programming Problem #16
================================
Randomly generate 1000 numbers from 1-10000 into an array.
Then generate another 500 numbers from 1-10000.
If there is a number from the second set of numbers that happens
to be in the first set of numbers, write out to the file named
LOCATION.TXT something such as:

5322 was found in position 532.

Only indicate the first instance of the number you encounter.

Next Time
=========
We will cover some basic concepts of the use of pointers.  Please
write any comments you have to ggrotz@2sprint.net.  As I look at
my formatted version, so far there has been 116 pages written of
this tutorial, from part 1, not counting this one.  As I look through
my line count figures, this one is the smallest. (interesting facts,
huh?)

I will ask for feedback on how I do with regards to any of the pointer
related texts coming up.  Please do that.  Thank you.






