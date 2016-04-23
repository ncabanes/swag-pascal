                       Turbo Pascal for DOS Tutorial
                            by Glenn Grotzinger
                   Part 15: Concepts of Sorting Arrays
                copyright (c) 1995-96 by Glenn Grotzinger

Here is a solution from last time...keep in mind to be as efficient as
possible in coding...I figure that many will try simply writing those frames
out.

program part14; uses crt;

  var
    esccount: byte;
    chr: char;

  procedure setitup;
    begin
      { green border of 4 units }
      textbackground(green);
      clrscr;
      window(5,5, 76, 21);

      { red border of one unit }
      textbackground(red);
      clrscr;
      window(6,6,75,20);

      { set up black background }
      textbackground(black);
      clrscr;

      { write keypress statement }
      highvideo;
      textcolor(lightcyan);
      writeln('Keypress Detector (Press ESC 5 times to quit)');

      { preserve Keypress detector title. }
      window(6,7,75,20);
    end;

  function status(char1: char;var esccount: byte): string;
    var
      char2: char;
    begin
      if char1 = #0 then
        begin
          char2 := readkey;
          case char2 of
            #59: status := 'F1';
            #60: status := 'F2';
            #61: status := 'F3';
            #62: status := 'F4';
            #63: status := 'F5';
            #64: status := 'F6';
            #65: status := 'F7';
            #66: status := 'F8';
            #67: status := 'F9';
            #68: status := 'F10';
            #82: status := 'Insert';
            #71: status := 'Home';
            #73: status := 'PageUp';
            #81: status := 'PageDown';
            #83: status := 'Delete';
            #79: status := 'End';
            #77: status := 'Right';
            #72: status := 'Up';
            #80: status := 'Down';
            #75: status := 'Left';
          end;
        end
      else
        case char1 of
          #8: status := 'Backspace';
          #9: status := 'TAB';
          #13: status := 'ENTER';
          #27: begin
                 status := 'ESC';
                 inc(esccount, 1);
                 { the 1 is not required here, but the inc and dec
                   functions can be used with values greater than
                   one like this in this case }
               end;
          #32: status := 'SPACE';
        else
          status := char1;
        end;
    end;

  procedure endit;
    var
      i: byte;
    begin
      window(1,1,80,25);
      gotoxy(1,1);
      for i := 1 to 25 do
        begin
          delline;
          delay(100);
        end;
    end;

  begin
    esccount := 0;
    setitup;

    while esccount <> 5 do
      begin
        chr := readkey;
        normvideo;
        textcolor(lightblue);
        write('You pressed the ');
        highvideo;
        textcolor(green);
        write(status(chr, esccount));
        normvideo;
        textcolor(lightblue);
        writeln(' key.');
      end;

    endit;
  end.
Now, we will discuss the use of sorting with regards to arrays into a
particular order.  Sometimes we may need numbers, such as dates in
chronological order, or a list of names in alphabetical order.

Swapping Units
==============
The integral part of a sorting routine is a unit swap.  As a rule, we
MUST have a temporary variable, because a simple assign set will not work.

For example, to swap the contents in variables a and b, we need a temporary
variable we will call temp.  Then code such as what is below will do...

temp := b;
b := a;
a := temp;

The swap should ideally be performed with the smallest units possible,
based on the sorting key.  The idea of a sorting key will be explained
later.  You may end up using pointers to get it to move the smallest
amount of data, which will be explained in a future part.  The less
amount of data the computer can move, the better.

The BubbleSort (or the brute force sort)
========================================
Basically, in this sorting method, each and every item in the array is
compared each and every other item in the array.  This is a largely
inefficient method for sorting items, but easy to code, and useful for
small amounts of data.

program example_of_bubblesort;

  var
    thearray: array[1..20] of integer;
    temp: integer;
    i, j: integer;

  begin
    randomize;
    { generate numbers for array and write them as unsorted }
    write('The unsorted array: ');
    for i := 1 to 20 do
      begin
        thearray[i] := random(50) + 1;
        write(thearray[i], ' ');
      end;
    writeln;

    { the bubblesort. }
    for i := 1 to 20 do
      for j := i+1 to 20 do
        if thearray[i] > thearray[j] then { compare and swap }
          begin
            temp := thearray[i];
            thearray[i] := thearray[j];
            thearray[j] := temp;
          end;

    write('The sorted array: ');
    for i := 1 to 20 do
      write(thearray[i], ' ');
    writeln;

end.
As it is a purely iterative solution, you should have no exact trouble
seeing what is going on.  But to further another point as to exactly
how it works, and why it is so inefficient, we will sort a sample set
of numbers manually according to this algorithm to see what is going on.

1       3       2       5       4

We will start out with the following short description of what is going
on within the two for loops for 5 values of data:

1) i = 1; j = 2; Position1 = 1; Position2 = 3; 1 > 3 = false;
2) i = 1; j = 3; Position1 = 1; Position3 = 2; 1 > 2 = false;
3) i = 1; j = 4; Position1 = 1; Position4 = 5; 1 > 5 = false;
4) i = 1; j = 5; Position1 = 1; Position5 = 4; 1 > 4 = false;

5) i = 2; j = 3; Position2 = 3; Position3 = 2; 3 > 2 = true; we swap the
two values...so our resultant array is...

1       2       3       5       4

6) i = 2; j = 4; Position2 = 2; Position4 = 5; 2 > 5 = false;
7) i = 2; j = 5; Position2 = 2; Position5 = 4; 2 > 4 = false;

8) i = 3; j = 4; Position3 = 3; Position4 = 5; 3 > 5 = false;
9) i = 3; j = 5; Position3 = 3; Position5 = 4; 3 > 4 = false;

10) i = 4; j = 5; Position4 = 5; Position5 = 4; 5 > 4 = true; we swap
the two values...so the resultant array is...

1       2       3       4       5

11) Effective termination of loop;

As we can see, we took 10 steps in the algorithm to swap 2 elements of
the array in order to sort it.  Basically, this is a very inefficient
algorithm in comparison to other types that are available, as we are
considering portions of the array that are already sorted.  As a note,
to sort the items in descending order instead of ascending order, change
the comparison between the two positions i and j of the array from > to <.

QuickSort
=========
This is a much faster recursive solution for sorting than the bubblesort.
It makes use of a pivot marker, which moves according to what exactly is
contained in the array.  It also will make use of a "divide and conquer"
approach.  Here is a short example...

program example_of_quicksort;

  var
    thearray: array[1..20] of integer;
    i, j, PIVOT, t: integer;

  procedure quicksort(L, R: integer);
    begin
      if L < R then
        begin
          i := L + 1;
          j := R;
          PIVOT := thearray[L];

          repeat
            while thearray[i] <= PIVOT do inc(i);
            while thearray[j] > PIVOT do dec(j);
            if i < j then
              begin
                t := thearray[i];
                thearray[i] := thearray[j];
                thearray[j] := t;
              end;
          until i > j;

          thearray[L] := thearray[j];
          thearray[j] := PIVOT;

          quicksort(L, j-1);
          quicksort(i, R);
        end;
    end;

  begin
    randomize;
    write('The unsorted array is: ');
    for i := 1 to 20 do
      begin
        thearray[i] := random(50) + 1;
        write(thearray[i], ' ');
      end;

    quicksort(1, 20);

    write('The sorted array is: ');
    for i := 1 to 20 do
      write(thearray[i], ' ');
  end.

This is a recursive solution, so it will be a little different.  Let's
start with the same number sequence we had above and see how quicksort
works...keep in mind that quicksort is about as inefficient as bubble-
sort with smaller sets...Once you get into larger sets, quicksort beats
bubblesort hands down -- it more intelligently seeks the proper array
units to swap.

1       3       2       5       4

1) 1 < 5 = true so continue.... i = 2; j = 5; PIVOT = 4;
   3 <= 4 = true so i = 3; 2 <= 4 = true so i = 4;
   5 <= 4 = false so quit;

   4 > 5 so quit;
   4 < 5 = true, so swap values.  The resulting swap is...

1       3       2       4       5

   4 > 5 = false so continue on repeat loop...

   i = 4; j = 5; PIVOT = 4; 4 <= 4 = true so i = 5;
   5 <= 4 = false so quit;

   5 > 4 = true so j = 4; 4 > 4 = false so quit;

   5 > 4 = true so quit repeat loop.

   j = 4; i = 5; 4 is left side. 4th element is 4.

2) Quicksort called for left side of 1, and right side of 3.  Then quicksort
for left side of 5, and right side of 5. Essentially, we keep cutting the
array in half based by where the pivot lands.  We will process the quicksort
for the left side as 2a) and the quicksort for the right side as 2b).

2a) Our number set for this instance of quicksort is:

1       3       2

    1 < 3 = true so continue.

    i = 2; j = 3; PIVOT = 2; 3 <= 2 = false so quit;
    i = 2; j = 3; PIVOT = 2; 2 > 2 = false so quit;

    2 < 3 = true so swap values...the resulting swap is...

1       2       3

    2 > 3 = false so quit repeat loop.

    Quicksort called twice for left side of 1, 2 and 2,3.  The results of
    both of these sorts end up being false, so they will terminate
    readily.


2b) 5 < 5 = false so terminate quicksort.


As we can see, the algorithm sets itself up so it ignores portions of the
array that are already sorted.  For larger arrays, it will provide a great
performance boost as we are ignoring the parts of the array that happen
to be sorted by using this particular algorithm.

The version of quicksort pictured sorts in ascending order.  To make it
sort in descending order, change the two while loops to read the following:

while thearray[i] <= PIVOT do inc(i);
while thearray[j] > PIVOT do dec(j);

ShellSort
=========
This is a non-recursive sort that performs close in performance to quicksort.
We can follow what is going on, so I will just simply write an example of
the use of the shellsort, and describe how to change it to sort in descending
order instead of ascending order...

program example_of_shellsort;

  var
    thearray: array[1..20] of integer;
    i: integer;

  procedure shellsort(n: integer);
    const
      m = 3;   { total number of sort passes }
    var
      i: array[1..m] of integer;
      j, k, p, s, t, incr: integer;
    begin
      i[m] := 1;
      for j := m - 1 downto 1 do i[j] := 2 * i[j];
      for j := 1 to m do
        begin
          incr := i[j];
          for k := 1 to incr do
            begin
              s := incr + k;
              while s <= n do
                begin
                  p := s;
                  t := thearray[p];
                  thearray[k-incr] := t;
                  while t < thearray[p-incr] do
                    begin
                      thearray[p] := thearray[p-incr];
                      dec(p, incr);
                    end;
                  thearray[p] := t;
                  inc(s, incr);
                end;
            end;
        end;
    end;

  begin
    randomize;
    write('The unsorted array is: ');
    for i := 1 to 20 do
      begin
        thearray[i] := random(50) + 1;
        write(thearray[i], ' ');
      end;
    writeln;

    shellsort(20);  { 20 is high end of array }

    write('The sorted array is: ');
    for i := 1 to 20 do
      write(thearray[i], ' ');
    writeln;
  end.
To get it to sort in ascending order instead of descending order, change the
line:

while t < a[p-inc] do

to

while t > a[p-inc] do

Practice
========
You should practice using these sorting methods.  They stay basically as
indicated for any use, except for changing the identities of the item
type in the array we sort.  For strings, we can alphabetize them by using
the strings in the sorting routine for ascending order.  Look at the ASCII
chart...It sees characters as numbers... a < b < c ...et al...  With
strings, be sure to sort them case insensitively, especially, if we
alphabetize a list or something like that....

Next Time
=========
We will cover methods of searching an array for data.  send comments to
ggrotz@2sprint.net

  
