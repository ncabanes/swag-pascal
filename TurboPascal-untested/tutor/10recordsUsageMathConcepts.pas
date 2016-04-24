(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0010.PAS
  Description: 10-Records usage & Math Concepts
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                         Turbo Pascal for DOS Tutorial
                              by Glenn Grotzinger
         Part 7 -- Records usage and Mathematics Concepts of Computers
                All parts copyright 1995 (c) by Glenn Grotzinger

        Here is a solution to part 6...

{$B+}
program part6;

  type
    ltrtype = array['A'..'Z'] of longint; {type dec for arrays}

  var
    ltrstorage, sums: ltrtype; { hold array and sums array }
    filelist, counts: text;
    filename: string;
    filenums: integer;
    ltrs: longint;

  procedure countletters(str: string; var ltrstorage, sums: ltrtype);
    var
      i: integer; {65..90}
      j: char;
    begin
      for i := 1 to length(str) do  { for length of string }
        for j := 'A' to 'Z' do    { for 26 letters }
          if upcase(str[i]) = j then
            begin
              inc(ltrstorage[j]); {var = var + 1 }
              inc(sums[j]);
              ltrs := ltrs + 1;
            end;
    end;

  procedure countfile(filename: string; var ltrstorage:ltrtype; var
                      filenums: integer);
    var
      cntfile: text;
      chkstr: string;

    begin
      writeln('Processing ', filename);
      filenums := filenums + 1;
      assign(cntfile, filename);
      reset(cntfile);
      readln(cntfile, chkstr);
      while not eof(cntfile) do
        begin
          countletters(chkstr, ltrstorage, sums);
          readln(cntfile, chkstr);
        end;
      countletters(chkstr, ltrstorage, sums);
      close(cntfile);
    end;

  procedure writefdata(filename: string; var ltrstorage: ltrtype);
    var
      i: integer;
      j: char;
    begin
      { write headers }
      writeln(counts, 'Alphabetical Count Data':53);
      writeln(counts, 'for ':40, filename);
      writeln(counts);
      writeln(counts, 'Letter':10, 'Count':10, 'Letter':25, 'Count':10);
      for i := 1 to 13 do
        writeln(counts, chr(i+64):8, ltrstorage[chr(i+64)]:12,
                chr(i+77):23, ltrstorage[chr(i+77)]:12);
      writeln(counts);
      writeln(counts);
      for j := 'A' to 'Z' do
        ltrstorage[j] := 0; { zero back out storage array }
    end;

  procedure doend(filenums: integer; ltrstorage: ltrtype);
    var
      i: integer;
      j: char;

    begin
      writeln(counts, filenums, ' files processed.');
      writeln(counts, ltrs, ' letters processed.');
      writeln(counts);
      writeln(counts);
      writefdata('all files', sums);
    end;

  begin
    assign(filelist, 'FILES.TXT');
    reset(filelist);
    assign(counts, 'FRNDDATA.TXT');
    rewrite(counts);
    readln(filelist, filename);
    filenums := 0;
    while (not eof(filelist)) and (filenums < 9) do
      begin
        countfile(filename, ltrstorage, filenums);
        writefdata(filename, ltrstorage);
        readln(filelist, filename);
      end;
    countfile(filename, ltrstorage, filenums);
    writefdata(filename, ltrstorage);
    doend(filenums, ltrstorage);
    if not eof(filelist) then
      writeln(counts, 'You gave me more than 10 files to process!');
    close(filelist);
    close(counts);
  end.

On with the show....

Records Definition
==================
        You can group up different types of data using records.  We MUST
use the type statement pretty well to use this record type.  Here is an
example of the defining of a record type in the type section.

  type
    employeerecord = record
      number: longint;
      surname: string[18];
      firstname: string[10];
      position: string[10];
      yrsworked: integer;
    end;

As you can see, we are grouping many different types of information into
one record type.  Then for the var section, all we need to do is define
ONE variable to be of type employeerecord and we'll have the record variable.

Accessing Records in a Program
==============================
        You can work with sections of a record variable, or the whole record
variable.  The whole record variable can be accessed just by calling the
record variable used.  The parts of it require the use of a . followed by
the name of the part as specified in the type statement.  Also, the WITH
command may be used to simplify typing in working with a specific record.
The WITH command specifies a specific record variable to work with.  An
example can be seen below.

program tutorial18;

  type
    {Employeerecord as above}
  var
    workrecord: employeerecord;
  begin
    { get workrecord into memory here. }
    writeln(workrecord.number);
    writeln(workrecord.surname);
    writeln('I''m getting sick of typing workrecord all the time!');
    with workrecord do
      writeln(firstname);
      writeln(position);
      writeln(yrsworked);
    end;
  end.

Hopefully, you can see what exactly is going on in working with records.
WITH only reduces typing.  It's good to use to reduce clutter if you do
a lot with one type of record in a section of code.  Also, keep in mind
that record types can be used in an array....

  var
    workinfo: array[1..10] of employeerecord;

Each section of the record works just like ordinary variables, and are
addressable like ordinary variables.  Also the whole record itself can
be addressable and moved around (written possibly to binary files?) to
other like records....The above array can be addressed like this:

3rd record in array, surname: workinfo[3].surname

Mathematics Concepts in Computers
=================================
Hopefully, you got the mathematics lesson from someone, or are already
familiar with conversion of number bases.  If not, I will run through
a quick example...

Convert 10 (base 10) to base 2.

A base tells us how many numbers are used in counting.  Typical numerical
usage is base 10 (we use the numbers 0-9 in that order -- we always start
from zero in counting.   To look at this problem, we look at the right
and move to the left with regards to number bases.  To use the example of
543 in base 10, it's 5X10^2+4X10^1+3X10^0. Remember, anything to the 0th
power is 1. All number bases work this way.  The exception is the changing
of the multiple.  We use 10 in the example above.  Using that background,
10 in base 10 is 1X10^1+0x10^0.  So, if we go through the process of actually
converting a base from base 10....

10 / 2 = 5 rem 0. (we keep going until the quotient is 0.  Right now it is 5.)
5 /  2 = 2 rem 1.
2 / 2 = 1 rem 0.
1 / 2 = 0 rem 1. (We quit here.  Then look at the remainders from down to
 up to get our converted base).

1010 is 10 in base 2....Now, if we want to go to base 10 from another number.

Convert 4A (base 16 to base 10).
Here, since we want to go to base 10, all we need to do is extend out the
base into something we can understand...

4 X 16 + A(10) X 1 = 64 + 10 = 74 (base 10)

What does all of this have to do with computers in programming.  Let's
analyze a few things...

If you've seen $ and # and what do they mean?
---------------------------------------------
$ is a typical designator in computers that a number is in base 16. # is
a typical designator in computers that a number is in base 10.  You
probably have seen it by now in the ASCII table studies we have done.
For example, Z is ASCII character $5A and #90.  These are both one in the
same.  As we see below:

5X16^1+A(10)X16^0 = 80 + 10 = 90 (base 10).
9x10^1+0x10^0 = 5x16^1+10(A)x16^0 (base 16).  {90/16 = 5 rem 10}

How does my computer store data?
================================
Why do we bother to mess with the different number systems in computing?
base 10 is human-understandable, so we use it sometimes.  Base 2 is
obvious, since this is how the computer talks. (hence BI-nary)  All
computer storage is actually a series of 1's and 0's or ON's and OFF's.
(2 possible combinations, hence base 2). For example, lets convert #65 to
base 2 and see how our computers store an A.  Let's start from the highest
we know we can on the power list for 2's. There are 256 ASCII characters
because it was decided sometime in the computer stone age that there would be a
total of 8 bits, the elementary unit of storage in a computer, per byte,
or next major unit that you all should be familar with in using DOS/
Windows/whatever.  If we analyze that using a good permutation scheme..
2 possible orientations, 8 positions...2^8 or 256 total combinations.
So, we will start from 7, since there is no byte #256.  128 goes into 65
0 times.  64 goes into 65 one time with 1 left.  32 goes into 1 0 times.
16 goes into 1 0 times.  8 goes into 1 0 times.  4 goes into 1 0 times.
2 goes into 1 0 times. 1 goes into 1 one time. (stepping down powers of
2.). So typically in expressing a list of bits for a byte, we use 0's
for the filler for all 8 spaces, since we NEED to work for 8 bits with
a respective byte.  So an ASCII related system (there are others) would
represent #65 as 0 1 0 0 0 0 0 1.  8 bits, all 0 or 1.  If your computer
deals with an A, it actually deals with the bit series 01000001.

In using a computer, we don't need to know about bits, since each
completely meaningful unit to most of us comprises 8 bits.  We don't
need to normally think of 01000001, the way the computer does it.  But
for some things in programming, we do, though.

Base 16 is also used a lot.  Reason?  It's a real handy way to define
a byte.  Let's look at the A.  According to the ASCII table, A is $41.
16 = 2^4 so we can see it's a lot handier way to tag around the implied
bits of a byte with this... If we look at the bit sequence, a high end
of 4 bits would have to be multiplied by 16.  So if we look at the meaning
of 0100 and 0001, we will see why we use base 16... 0100 is 4.  0001 is 1.
Concenate them together, we get 41...Neat, eh?

We don't really have all that much concern for base 16 in this tutorial,
because in pascal, base 10 will work as well.  we do need to be concerned
about base 2, though, because the computer uses it.

Reasons for knowing what this stuff is...
=========================================
We have reasons that we need to know how to convert between the number
bases, and be familar with what a bit is...You may be familiar with what
is called the high and low orders of a byte.  To use the example of the A
bit series we converted earlier:

0      1      0       0                     0       0       0       1      
      high order                                    low order

There are pascal commands which use the bits for things.  Also, some
fixed file formats use these (such as compression -- that's actually whats
going on -- it works at bit level to compress the number of bytes used) and
if you wish to if you ever develop something....)  One must have an idea
of where the bits are coming from, hence all the stuff I was going through
before.  If you read through your TP programmer's reference and see it
talking about orders of bytes and what goes on with those particular
commands, now, you should have the background to know about it and predict
what would happen on those commands.

First good commands to know about for working with bits
=======================================================
        We always want to go for the most efficient code available.  If we
ever need to work with multiplying or dividing powers of 2, we can do it
much speedier and easier by having the computer do bit shifts instead of
doing an actual multiply or divide command when we are dealing with small
numbers.  Shifting information around is much easier for the CPU than
actually doing the computation.  Let us demonstrate.

00000010 (base 2) = 2 (base 10)
00000010 (shift 1 byte to the left) => 00000100 or 4 (base 10)
00000010 (shift 1 byte to the right) => 00000001 or 1 (base 10)

Going one way or the other in shifting bytes have the effect of multiplying
or dividing by 2^(# of bytes we move).  Play with these commands and you
will see.  It's a bit shift that it does, and is MUCH faster than an actual
divide when it comes to any power of 2. Examples:

writeln(2 shl 1);   {or 2 X 2^1}
writeln(2 shr 1);   {or 2 / 2^1}

Those two commands work this way: <number> command <# of bits to shift>
# of bytes to shift turns out to be the power of 2 we do the work on...

HI(byte) pulls the high order of the expression.
LO(byte) pulls the low order of the expression.
swap(byte) swaps the orders.

These are all functions.

Other Math Functions offered by Pascal
======================================
Abs(X)          Takes absolute value of X.
Arctan(X)       Takes arctangent of X.
Cos(X)          Takes cosine of X.
Exp(X)          Takes exponential (base e) of argument.
Frac(X)         Returns fraction of X.
Int(X)          Returns integer part of X.
Ln(x)           Takes base e logarithm of X.
Pi              Returns value of pi.
Round(X)        Rounds X(real) to an integer.
sin(X)          Takes sine of X.
sqr(x)          Takes square of X.
sqrt(x)         Takes square root of X.
trunc(x)        Truncates X w/o rounding.

It is a good idea to learn basic trigonometry and analytical geometry in
programming.  For example, I know from my studies that Tan(x) would be
1/Arctan(x) or sin(X) / cos(X).  This stuff is good to know. The reasons?
Graphics.  All one needs to draw anything, really, is a good spot placement
procedure and knowledge of trigonometry, and analytical geometry.  Just
know and define a resolution and then start drawing knowing your knowledge.
As a test, to help out....How would one draw a circle given a central point
and radius?  (Gotoxy in the CRT or WinCRT unit will be of use.  It will
place the cursor at a specified position so you can write something.).
If anyone wants a text-based solution on this one if they can't figure
it out, e-mail ggrotz@2sprint.net.  I will place one in the next part.

Other stuff that may prove useful
=================================
In your programming experience, you may have wondered if there is a way
to get a string to an integer, or an integer to a string to do things
with it?  Well, there is.  VAL and STR.

Val is used like this:  Val(string, integer, errorinteger);
string is the string you want to try and convert to an integer.
integer is the integer that holds the successful conversion.
errorinteger is <> 0 when there is an error in conversion (always check
   this before you move on after using a VAL!!!

Str is used like this: string := str(integer);
string is the string you want to hold the conversion in...
integer is the integer that we want to convert...

Another good command to know is POS: integer := pos(substr, str);
It returns 0, if substr isn't there, but it returns a positive value
corresponding to the start of the substring in the string, if it's there.
For example, if we want to find the first use of the word AT in a string...

int := pos('AT', 'THAT');

int will be 3.

Conclusion
==========
I know all of this mathematics, and talk of bits is probably confusing.
If you don't understand it right now, don't worry about it and go back
at leisure and study it.  It is the basic extent of mathematics behind
the actual operation of a computer and what we all as programmers need
to keep in the back of our minds for some things.  You should know what
a bit is, an order of a byte is, and that there are 8 bits in a byte.
These things should help out in some matters.  You should know the why
parts of these things in some cases...You should especially, though,
understand the parts about the commands SHR, SHL, HI, LO, and SWAP,
and the concepts of orders based on the storage of a byte, as, though
we will not see these in this part, we will undoubtedly see them some-
time before this tutorial is over, more than likely, even we may not
see them.  But you may need to work at bit level with bytes sometime,
so this information is present here now for both the novices and the
experts that may see this.  Also, converting the number bases is a
needed thing.

Practice Programming Problem #7
===============================
        The concept of a record is relatively straight forward.  So I
will not try to come up with a problem for basic usage of records.
But the concept of writing code to do some of the number conversions
is not.  These functions can be very useful for later use in your
programming (save them after you write them!).  Write a function for
your code library that will perform a base 10 to base X number
conversion (X being a variable we can define in the function header to
be an integer.) on an integer.  Also write a function that will perform a
base x to a base 10 conversion.  Inbed these two functions in a program
that will take a number from the keyboard (you can use whatever prompt
you deem to be the least confusing as possible) and a base to convert
the number to.  Put out a prompt as to the answer of what the new base
number of the input is, as well as a restatement of the original number
inputted using a reverse conversion of base (Show us that both of the
functions work and are correct.  If the 2nd computed statement DOES
not equal what is put in, there is an error.), not a direct reprint of
the input variable.  To prove we are not writing out the original input
number that we placed in the keyboard, place a 0 in the keyboard input
variable after you perform the function to convert it to the user's
desired base.

Sample Output
-------------
Enter a number: 10
What base do you want to convert it to? 5

10 (base 10) is 20 (base 5).
To check: 20 (base 5) is 10 (base 10).

Notes:
1) You will have to build the converted number base as a string,
because any base beyond 10 requires the use of the alphabet for parts
of the number.
2) The best way I see to handle the "What do we use for the number
in the result?" question is to define a constant string in the function
to be something like '0123456789ABC...', and address a proper part
of the constant string when we build the converted number for conversion.
3) Remember we count from x^0 units on the right!!!!!
4) You will need to probably make the high end limit to be base 36.
5) Hint: the base x to base 10 function will need to input a string
for the input number and output a longint, while the base 10 to base
x function will need to input a longint and output a string.
6) A side note for usage.  You can link these two to get from any base
to any base using base 10 as the intermediary.

Next Time
=========
We will cover the DOS file function commands out of TP.  Hold on to
your newsreaders because part 8 (right now) is 531 lines, and I'm not
through yet.  This will be one of our special topics.  If you not
familiar with the following concepts in DOS, look up in your DOS
manual and try and pick it up before next time: Read-only file,
hidden file, system file, volume label, command-line parameter, MD,
RD, delete (or erase), the use of * and ? as wildcards.  As always,
any comments, questions, gripes, etc, send them to ggrotz@2sprint.net.

