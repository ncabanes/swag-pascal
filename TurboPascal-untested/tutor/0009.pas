                        Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
                      Part 6 -- Arrays and Their Usage.
             All parts copyright 1995-96 (c) by Glenn Grotzinger

        Hello again...Let's get started...An example of the solution of
the program presented in part 5 is below.

program part5;
  const
    income_tax = 0.15;    { set our 15% tax rate }
  type
    string20 = string[20];  { not needed, but good to demonstrate }
  var
    employee: string20;
    hours, rate: real;
    infile, outfile: text;
    grosspay, overtimepay, intax, netpay: real;

  procedure writeheaders;   { writes the headers on our report }
    begin
      writeln(outfile, 'The International Widget, Inc.':51);
      writeln(outfile, 'PayOut And Deductions Sheet':49);
      writeln(outfile);
      writeln(outfile, 'Employee', 'Hours':17, 'Rate':7, 'GrossPay':10,
                       'Overtime':10, 'IncomeTax':11, 'NetPay':9);
    end;

  function writeline(fillchar: char; strlength: integer):string;
  { handy function that fills a certain length of a string with a fixed
    character }
    var                    
      i: integer;
      str: string;
    begin
      str := '';
      for i := 1 to strlength do
        str := str + fillchar;
      writeline := str;
    end;

  procedure processrecord(hrs, rate: real;var gpay, opay, itax, npay: real);
    { does all of our required calculations for us }
     var
       rpay: real;
     begin
       if hrs > 40 then  { if overtime then }
         begin
           rpay := rate * 40;                { regular pay up to 40   }
           opay := (hrs - 40) * rate * 1.5;  { overtime rate after 40 }
         end
       else
         begin
           rpay := hrs * rate; { figure as normal }
           opay := 0;          { set overtime pay to 0, no overtime hours }
         end;
       gpay := opay + rpay;        { get our gross pay }
       itax := gpay * income_tax;  { get our deduction }
       npay := gpay - itax;        { actual pay to worker }
     end;

  begin
    assign(infile, 'WORKER.TXT');     { prepare input file  }
    reset(infile);
    assign(outfile, 'PAYOUT.TXT');    { prepare output file }
    rewrite(outfile);
    writeheaders;                         { write headers of report }
    writeln(outfile, writeline('=', 72));
    readln(infile, employee, hours, rate);
    while not eof(infile) do { while not end of file, read,process&write }
      begin
        writeln('Processing ', employee);
        processrecord(hours, rate, grosspay, overtimepay, intax, netpay);
        writeln(outfile, employee, hours:5:2, rate:7:2, grosspay:9:2,
                         overtimepay:10:2, intax:10:2, netpay:11:2);
        readln(infile, employee, hours, rate);
      end;
    writeln('Processing ', employee);
    processrecord(hours, rate, grosspay, overtimepay, intax, netpay);
    writeln(outfile, employee, hours:5:2, rate:7:2, grosspay:9:2,
                     overtimepay:10:2, intax:10:2, netpay:11:2);

    close(infile);
    close(outfile);    { close files }
  end.

The Structure of an Array
=========================
        For a lot of things, it is very useful to know exactly how things
are done by the computer in programming.  The array is one of them.  An
array is simply a group, or set of groups of like defined items.  An example
of such a thing is:

firstarray: array[1..3] of integer;

What we are doing is defining three integers that we want to indicate by
numbers as 1(1st), 2(2nd), and 3(3rd) in the set of integers.  Arrays are
often used to correlate like items in a program to make them easier to
process.  Often it is with such data as this:  Say we want to work with
the high temperatures for each day of one month.  It is correlated info,
so it is a very good candidate for an array.  The numbers between the []
are minimum..maximum index values for the array (to keep track of which
part of the array we want).  There are 31 days in a month(maximum), so we
would store them as something like this:

temperatures: array[1..31] of integer;

We are defining the total number of integer units we want in the array.
Which brings up the question: How is this stored in memory?

RULE: ALL MEMORY STORAGE BY COMPUTER OF ANY ITEM IS LINEAR!!!!

This rule is always helpful to remember when we work with arrays.  It
does point out logic rather readily of handling arrays.  Now I will
illustrate how to access items of the array.  Keep in mind that array
items can be read from the keyboard or text file, and written just like
variables we have worked with before.

To read the 5th temperature in the array from the keyboard, we would use
something like this: readln(temperatures[5]);

Note: in addressing an array, we can even use mathematical expressions...

Usage of Arrays
===============
If we wished to write out (one per line) to the screen, all the contents
in the array, we would do something like this...keep in mind that array
variables work exactly the same way as the variables have that we have
been working with so far:

for i := 1 to 31 do
  writeln(i, temperatures[i]);

Note: often for/while/repeat loops are used to work with arrays to process
the whole array using an index variable in the counter.  Keep this in mind
for your programming.

The indexes can be defined to be anything that was valid for use in the for
loop, such as:
     array1: array[1..10] of integer;
     array2: array[-15..0] of real;
     array3: array['a'..'z'] of char;

This naturally has limits, which you will find if you cross them (compiler
warning).  What the array is of can be any valid data type.  Can we define
an array of an array?  Yes.

Double Level Tables and Above
=============================
        We can define infinitely, as our memory allows, the number of arrays
of arrays we want to define.  Say, for our temperature example, we wanted
to define the limits of an array for the whole year.  We know there are
12 months in the year, so we would need 12 occurences of the array we
defined previously for the high temperatures for each day:  A definition
of this array would be:

temperatures: array[1..12] of array[1..31] of integer;

This is a very definable array that we could use to store all of our high
temperatures for each day of the year.

Is there a shortcut, though?  Yes, there is.  You can use a comma in the
first set of [] to define the limits of the 2nd array.  Why?  We see in
the next paragraph.  An example of a better definition of this array is:

temperatures: array[1..12, 1..31] of integer;

We see the parts of each array in the first one there...Remember above
that I said computers store things linearly.  It helps us when we know
this in processing such a thing above.  Actually, for double
level, triple level, etc, tables, the 2nd array, 3rd array, etc is seen as
minor units within the previous defined array.  Say, we had this array:

array1: array[1..2, 1..2, 1..2] of char;

It would be set up in linear memory like this:

array1    char   char    char  char        char   char  char   char
        [1,1,1] [1,1,2] [1,2,1] [1,2,2] [2,1,1] [2,1,2] [2,2,1] [2,2,2]
           array1[1,1]  array[1,2]        array1[2,1]  array1[2,2]
                  array1[1]                       array1[2]

I placed labels on there so we could see the layout.  It would continue
ad infinitum for a 3rd level or a 4th level on anything.  So, as an
example of how we can address the array of temperatures above, and work
with one, here is a little code that writes 'em all to the screen, 12
columns of integers (one for each month), 31 lines(one for each day
in the month):

for i := 1 to 12 do
  begin
    for j := 1 to 31 do
      write(temperatures[i, j], ' ');
    writeln;
  end;

Defining Constant Arrays
========================
It can be done.  It's done like this:

const
  months: array[1..12] of string[3] = ('Jan', 'Feb', 'Mar', 'Apr', 'May',
          'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

Ord And Chr
===========
These are two functions we can use to work with the ASCII table.  They
are system functions.

Ord(char) gives us an integer that represents the character we put in
the ()'s.  Chr(integer) gives us a character which corresponds to the
ASCII code number that is given in integer.

Boolean type
============
A type called boolean exists.  It can either be set to true or false.

Final Notes
===========
As a final note, defining arrays, if you play around with doing that and
using them (I hope you do..:>), you may get an error from the compiler
that your data structure as defined is too large.  The reason is that
Pascal defaults to operating and compiling your programs like they were
going to work on an 8088 class machine.  The maximum addressable memory
there is 64KB.  If that happens, it means you have too many variables
defined.  There is a way to get around this, which will be covered in
a future part of this tutorial.  Don't give up on this, and remember:
Experimentation is the best tool for learning how this stuff works...

Practice Programming Problem #6
===============================
        Once upon a time, a friend of yours did you a really big favor.
Now they want you to repay that favor.  They are in college and doing
a statistical study on the average number of times that each letter of
the alphabet is used.  To accomplish that, to your unfortunate ears,
your friend wants you to sit down with a sheet of paper and a book
and start tallying letters on a table that's written on that sheet of
paper.  You know this is very time consuming and there is probably a
better way.  You realize that with your programming knowledge that you
have and several text files that you have on your hard drive that you
can make a program that will accomplish the task much faster.  They
asked you to count through a 200 page book originally, so you decide
that documentation of some shareware (5 text files) that you have are
counted and summarized will do sufficiently for what your friend intends.

Write a program in Pascal and entirely Pascal that will read no more
than 10 text file names from a file named FILES.TXT (you can create it,
one filename (full path) per line, be sure you can find them on your
drive (I recommend to get them as a whole to be no less than 200KB in
size (all files combined), and as large as you want them to be as a
whole -- I am only stating a good set of minimums -- the no more than 10
part is a good required part of the program to do.).  For each and every
file in this list, count the number of times each letter is used (whether
the letter is uppercased or lowercased is irrelevant <do not differentiate,
say, between A and a), do not count different cases based on that.)
Then output to FRNDDATA.TXT a listing of the total numbers of each letter
encountered.  Also, output other statistical data such as total number of
letters encountered (better define this one as a longint or real) and
total number of files used.

Notes and Hints:
1) We want counts for EACH file with EACH letter to be printed out.
2) Hint: Use an array to store the data for your numbers counted.
3) Total number of letters encountered DO NOT include numbers, wierd
characters, etc, etc.  If you are foreign to the U.S. and have other
characters in your alphabet than A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,
R,S,T,U,V,W,X,Y, and Z and their lowercased cousins, program this
utility using your alphabet.
4) Hint: Remember to take totals, we need data from ALL of our
samples to be used.
5) Hint: We don't need 52 IF statements or a large case statement.
Look at the ASCII table and see why I say this.
6) The program specifications say that FILES.TXT should not have more
than 10 files.  If it does, just design your program to stop at file
#10 and write an error message at the end of the output.
7) As with the last program, we need to write action indications to the
screen so we know the program is running and has not crashed.
8) If you see negative numbers for sums, or screwy numbers, remember
to initialize any arrays you may be adding things to.  Also, if you
see the negative numbers, integer type overflowed (Integer max: 32000).
If this happens, define all integers associated with that area to
longint (Integer max: 2 billion).

Sample of FILES.TXT (It should look like this, just be sure the files
you list are on your drive and are TEXT files, and not word processor
files)
---------------------------------------------------------------------
c:\mouse\readme.txt
c:\4dos\4dos.doc
d:\pastutr\pascal1.txt
c:\config.sys
d:\ezycom\ezy1.prn

Sample of FRNDDATA.TXT
---------------------------------------------------------------------
                        Alphabetical Count Data
                        for c:\mouse\readme.txt

Letter             Count                    Letter              Count
  A                 12                        N                   6
  B                 10                        O                   7
  C                  4                        P                   2
  D                 92                        Q                   2
  E                 20                        R                   4
  F                 32                        S                   2
  G                 23                        T                   3
  H                  2                        U                   4
  I                  2                        V                   2
  J                 34                        W                   2
  K                 21                        X                   4
  L                123                        Y                   5
  M              12341                        Z                   2

(repeat above for rest of files in FILES.TXT)

At end:
-------------------------------------------------------------------------
5 files processed.
15232 letters encountered.

                        Alphabetic Count Data
                           for all files

(repeat a letter count system like we did for each file we did)



Next time
=========
We will cover the use of records, and a few other nice commands, plus a
little mathematics.  Inevitably, in the sciences, math is used somewhere.
We're getting to the point of needing that.  I've tried to show partial
code to do things now that we're getting farther.  If people are having
problems integrating the code into a program to see how it works (if you
do, maybe you should work on the previous parts?), tell me and I'll go
back to posting complete programs.  With reference to mathematics, if
you do not know how to convert number bases, ask a parent or your favorite
mathematics professor. :>

After that, we will have most of the basics covered.  That does not mean I
will quit.  This is, my guess, about 2 parts away from the halfway point
(don't quote me on that:>).  Anyway, there's lots more to cover, and a few
special topics coming up.  To illustrate, the tutorial after the records
tutorial will involve the use of DOS compatible commands, in other words
those things you do in DOS (the first special topic) -- we're gonna go
over how to do those things in Pascal.

Please send any comments, questions, requests for help with the sample
programs (you SHOULD be doing them as you get each of these parts) to
ggrotz@2sprint.net.
