(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0016.PAS
  Description: 16-Recursion; system unit commands
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                        Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
          Part 13: Recursion; system unit commands not covered yet.
                 copyright(c) 1995-96 by Glenn Grotzinger

There were 2 simple problems presented...The first one...

program part12_1;

  const
    maxstacksize = 500;

  type
    stack = record
      elements: array[1..maxstacksize] of char;
      capacity: byte;
    end;

  var
    thestack: stack;
    i: byte;
    ch: char;

  procedure startstack(var thestack: stack);
    begin
      with thestack do
        capacity := 0;
    end;

  procedure place(var thestack: stack; element: char);
    begin
      with thestack do
        begin
          if capacity = maxstacksize then
            writeln('**ERROR**  Trying to place element on full stack!')
          else
            begin
              inc(capacity);
              elements[capacity] := element;
            end;
        end;
    end;

  procedure remove(var thestack: stack; var element: char);
    begin
      with thestack do
        begin
          if capacity = 0 then
            writeln('**ERROR**  Trying to remove element from empty stack!')
          else
            begin
              element := elements[capacity];
              dec(capacity);
            end;
        end;
    end;

 begin
   randomize;
   startstack(thestack);
   write('Enter a string: ');
   while ch <> #10 do
     begin
       read(ch);
       place(thestack, ch);
     end;
   writeln;
   writeln;
   write('The string reversed is: ');
   while thestack.capacity <> 0 do
     begin
       remove(thestack, ch);
       write(ch);
     end;
 end.
And now the second one...

program part12_2; uses crt;

  const
    maxqueuesize = 50;

  type
    queue = record
      elements: array[1..maxqueuesize] of integer;
      front, back: integer;
      count: integer;
    end;

  procedure startqueue(var thequeue: queue);
    begin
      with thequeue do
        begin
          front := 1;
          back := maxqueuesize;
          count := 0;
        end;
    end;

  procedure incqueue(var thenum: integer);
    begin
      if thenum = maxqueuesize then
        thenum := 1
      else
        inc(thenum);
    end;

  procedure place(var thequeue: queue; element: integer);
    begin
      with thequeue do
        if count = maxqueuesize then
          writeln('**ERROR** Trying to place element in full queue.')
        else
          begin
            elements[back] := element;
            incqueue(back);
            inc(count);
          end;
    end;

  procedure remove(var thequeue: queue; var element: integer);
    begin
      with thequeue do
        if count = 0 then
          writeln('**ERROR** Trying to remove element from empty queue.')
        else
          begin
            element := elements[front];
            incqueue(front);
            dec(count);
          end;
    end;

  var
    thequeue: queue;
    int, count: integer;

  begin
    randomize;
    startqueue(thequeue);
    clrscr;
    while thequeue.count <> maxqueuesize do
      begin
        int := random(1000) + 1;
        if int <= 50 then
          place(thequeue, int);
        inc(count);
      end;
    while thequeue.count <> 0 do
      begin
        remove(thequeue, int);
        write(int, ' ');
        if thequeue.count mod 10 = 0 then
          writeln;
      end;

    writeln(count, ' numbers generated from 1-1000 to get these 50 ',
                   'numbers from 1-50');
  end.

Forward
=======
Very useful to defeat the fact with the compiler that a function has to be
defined above another function in order to use the first function in that
second function.  Above the function that it needs to be in, say something
like:

function a(var input: integer): string; forward;

Then on down below in the code, you need to go ahead and define the
procedure or function entirely, with code.  For the header, you would
use something like this:

function a;

Doing this would accomplish being able to use a function defined after
a code call of the function for some purpose.  Successive recursion using
two seperate functions (a calls b; b calls a; and so on and so forth),
would be one example of having to use a forward.

The $M compiler directive
=========================
I described the $M compiler directive back in part 8.  Please review it
there.  Basically, the first number of the compiler directive is the
program stack size.  It is very important.  The default, if the $M is not
defined is 16K.  The maximum it can be defined to is 64K.  You may have to
use this compiler directive to increase the stack size so a recursion may
complete.  If the stack is filled, a runtime 202 error occurs.

Recursion
=========
Recursion, to put it simply, is the execution of a function or procedure
directly within that same function or procedure.  It is hard, sometimes,
logically to see use of recursion, but when you see a thoroughly repetitive
action, recursion could be used.

Recursion should be used with a procedure which basically has a small
number or NO parameters, since the recursion places a new occurrence of
the procedure on the stack, along with those variables.  It is quite
possible for a procedure to recurse itself upwards of thousands of times.
Therefore, you could easily run out of memory in the stack in running your
program.

Basically, in logic, recursion is the repetition of a procedure as a regular
or irregular loop by calling the procedure inside of the procedure, with
some regulated terminating code.

NOTE: Recursion must be done with relative caution in Pascal.  It is
really, REALLY easy to shoot oneself in the foot, literally, by use
of recursion.  It has it's advantages, but since Pascal is unlimited
by how, and why you use recursion, versus other languages, which may
limit it or not allow it all together.

As an example, we will look at taking a factorial of a number.  Basically,
to use an example, 4! (factorial) is 4 X 3 X 2 X 1.  Algebraically, we
could see a factorial (n!) as n X (n-1) X (n-2) X (n-3)...(n - (n+1)).
Let's try looking at a code example that does it...after that, I will
explain the process in detail that goes behind how it works.  It's a
simple, elegant one line set of code in a function that does all the
multiplications for any number we put in there.

I will try my best to explain what exactly is going on here in this
example of recursion.  That, I find, is the hardest thing to see in
the concept of how recursion works, is because it is hard to
conceptualize how the variables and functions work, in a manner that
is understandable.

In all of the books I have read, I have not seen an adequate description
of the actual logic and action of recursion -- enough to allow people to
understand the idea of what is going on.  Most teachers I've heard of and
talked to, just say what I have already said to this point, and shy away
from actually requiring written code using recursion, or explaining code
using recursion to enable people to truly understand what is going on.

I seek to change those observed facts, by trying to fully explain this
example below, so people may be able to understand them sufficiently.
I hope this explanation could be the best people have ever seen, and
I *definitely* want e-mail and feedback on how well I do in explaining
the concepts of what is going on (via showing all variable changes at
all points, and order of execution of the code), because it is one of
the hardest concepts in programming that I have come across in
understanding.  (I will also ask for input like this in the part I write
later on readdressing pointers)

program example_of_recursion;

  function factorial(a: longint): longint;
    var
      c: longint;
    begin
{1}   c := 1;  
{2}   if a > 1 then {
{3}     c := a * factorial(a-1);
{4}   factorial := c;
    end;

  begin
    writeln(factorial(4));
  end.
to explain the path of logic in this program in calling the function
factorial with regard to the variables, the biggest problem, I think,
with understanding recursion -- if you don't understand the main body
of the program, something is definitely wrong with you! :>  Line #'s
are placed in {}'s above this paragraph, and below this paragraph.

   { call to factorial }
   {1} a = 4             c = 1
   {2} 4 > 1 = true
   {3} c = 4 * factorial(3);
      { call to factorial }
      {1} a = 3             c = 1
      {2} 3 > 1 = true
      {3} c = 3 * factorial(2);
         { call to factorial }
         {1} a = 2             c = 1
         {2} 2 > 1 = true
         {3} c = 2 * factorial(1);
            { call to factorial }
            {1} a = 1             c = 1
            {2} 1 > 1 = false (so the chain of calls ends...)
            {3} skipped because 2 is false.
            {4} c = 1; factorial function is 1.
            { end call to factorial }
         {4} c = (2 * 1) = 2; factorial function is 2.
         { end call to factorial }
      {4} c = (3 * 2) = 6; factorial function is 6.
      { end call to factorial }
   {4} c = (4 * 6) = 24; factorial function is 24.
   { **FINAL** termination of factorial -- return of value 24 }

If you check the code, the final value is correct.  4! = 24.  Basically,
with the layout I used, you can see especially also, why memory (stack
space allocated for procedure and functions specifically) runs out
quick, and why I say to keep the parameters and local variables for that
matter to a minimum....

Recursion can be used in procedures, as well as functions, for any
repetitive action.  They are just like the function call above, which
recursed when or until an action became true.

To be able to extend for example, the part 8 dir clone to list and search
for files (list all files in all dirs), we would need to add another
boolean variable to get permission to run through all dirs encountered.
We can re-call the directory list procedure with a regulating if variable
of it being a directory.

For more practice (I won't post the solution for these ones), you may wish
to do this.  As another practice, you may wish to try and recode an integer
power function (the "simplistic" power function) that I included in my
solution to part 7's programming problem to use recursion.

Practice Programming Problem #13
================================
Code a program in Pascal and entirely Pascal that will make a catalog of
the additive size of all files in all dirs on a drive specified on the
command-line to a text file named FILESLST.TXT.

Sample output
-------------
c:\>sizelist c:

Drive: C
C:                       131,123
C:\DOS                 5,231,131
...                     ...
C:\UTIL                3,212,985
C:\UTIL\ACAD             131,123
                   =============
                     527,212,122

Notes:
1) The additive end of the listing (under the ='s) is the total size of
the files on the drive.  You may use the function offered by the DOS
unit to check yourself in your addition.
2) The spacing is not exact above.  Make it look SIMILIAR to what I have
above, but make it reasonably attractive...
3) Use a forward.
4) Be sure to check to be sure the drive is specified EXACTLY like above.
5) Please use recursion for going through the drive (actually, recursion
is probably the best way to do this).  But, be sure you put the directories
in the order listed above.
6) Sizes of subdirectories are not counted in the size of a main directory.
7) Be sure to error-check the command-line.

Next Time
=========
We will discuss the functions of the CRT unit.  Be sure to write comments,
encouragements, problems, errors, to ggrotz@2sprint.net.


