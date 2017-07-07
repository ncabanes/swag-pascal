(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0005.PAS
  Description: 05-IF statements and FOR Loops
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                        Turbo Pascal for DOS Tutorial
                     Part 2 -- IF statements and FOR loops.
                             by Glenn Grotzinger
            all parts copyright 1995-96 (c) by Glenn Grotzinger.

        Hello again.  This part got in a little late (finals in COBOL
programming).  We'll get started with IF statements and FOR loops after
we get the old business taken care of.  Before, we saw this set of code:

    first_number := 3;
    second_number := first_number * 2;
    first_number := second_number - 5;
    result := first_number + second_number;

The question was what the value of all the variables would be at the end of
the code.  Let's look.  The first statement is a simple assign statement,
assigning first_number the value of 3.  The second statement assigns second_
number the value of first_number (3) * 2 which is 6.  The third statement
then assigns the first_number the value of second_number (6) - 5 which is
1.  And then the final statement assigns result to the addition of first and
second number.  So, the values of all the variables would be
first_number := 1; second_number := 6; and result := 7;.

The example of a solution of last weeks programming question:

program part1;

  { This program accompanies part1.  It is a program designed to take 2
    numbers as input from the keyboard and perform an addition,
    multiplication, and subtraction on the number, writing the
    results out to the monitor. }

  var
    num1, num2: integer;

  begin { part1 }

    { take input for the 2 numbers }
    write('Please enter the 1st number: ');
    readln(num1);
    write('Please enter the 2nd number: ');
    readln(num2);

    writeln;  { place an empty line }
    writeln('Adding ', num1, ' and ', num2, ' gives ', num1 + num2, '.');
    writeln('Subtracting ', num2, ' from ', num1, ' gives ',
             num1 - num2, '.');
    {It is OK to break a command-line of code line this, as long as you
     don't break it on a literal statement}
    writeln('Multiplying ', num1, ' and ', num2, ' gives ', num1 * num2,
            '.');

  end. { part1 }

OK.  Let's move on to other topics....

Format Codes for Read, Write, Readln, and Writeln
=================================================
For all of these commands, we can use formatting codes to place our output,
or input from any source, or to any source (these are always applicable).
Typically, remember that a monitor in text mode has 80 columns and 25 rows.

     writeln('I am centered on the screen.':62);

This is a good first example.  What will happen is that writeln will place
the end of this text (the .) on screen position 62 columns relative to where
the write pointer is before this command is executed.  Another example.

     write(1 / 3 :8:3);
     write(1 / 4 :8:3);

Remember that for the screen placement that write/read will invalidate them
if they are not compliant (your code for that line must be greater than the
actual # of characters in the statement you write/read).  With the example
above, we see that it can be done with any type of variable we can write,
or read that is useful.  Above, I'm using expressions of division to
illustrate a point I mentioned last time about regular non-integer division
using decimals.  We'd get something like 3.3333333333E-01 for the first state-
ment, that is if we didn't use the second :# statement.  Obviously, if we
write a program we want to be understandable, we have to use something to
get regular decimal output (incidentally, the 3.33... stuff is how Pascal
stores real numbers in memory -- as scientific notation.).  So we use the
second statement.  The number is the number of decimal places we want to
use for the number.  So, to use those examples above, with a nice little
counter rule (so we can see what is happening only) would look like this:

0000000001111111
1234567890123456
   0.333   0.250

We see that the first number is kicking in...The last position is the 8th
column from the last write position (if we had writeln'd the first one, they
would be lined up on 2 separate lines).  And the answers are reported for
us in decimal format to the 3rd decimal place.  Just play around with
writing different things with these codes, and you'll get the idea of how
to use these codes when writing or reading something.

Quick note
==========
We use ' marks to enclose statements.  What if we want to write one?  Pascal
recognizes that if you place two of them together inside those ' marks, it
will write the actual ' to the output file.  Also, if you can locate an
ASCII table, you can write ASCII codes (lines and such) to screen like this:
       write(#225);
will write ASCII character 225.  You should be able to locate an ASCII chart
in your DOS manual, or your Pascal references that came with your compiler.

IF statements
=============
A lot of times, we need to make decisions on a particular course of action.
IF statements are one of those tools.  If a condition is true, then perform
action is basically the logic behind this statement.  We can also assign an
alternate action for the condition.  We will see with this provisional little
example.

program tutorial4;
  var
    first_number, second_number: integer;
  begin
    writeln('Type an integer in, please.');
    readln(first_number);
    writeln('Type another integer in, please.');
    readln(second_number);
    writeln;
    if first_number > second_number then
       writeln(first_number, ' is greater than ', second_number, '.')
    else
       writeln(first_number, ' is not greater than ', second_number, '.');
  end.

Basically, we made a decision based on the size of the two numbers and
wrote the result of that decision.  Note the format of the test statement.
You can use any of the symbols you remember to relate things together.
                Not equals is <> in pascal.
                Greater than or equal to is >= in pascal.
                Less than or equal to is <= in pascal.

        This type also introduces a new type of variable called boolean.
It can only have two values: true, and false.  This type is often good to
test conditions of run-time, such as you see with a lot of programs out
there which can be configured.  IF statements can be used with boolean
variables easily as well.
        Begin and end (end with a ; after it) can also be used in if-else
statements to execute MORE than one line of code if the condition is met,
or not met.  We use the next example.  We also use a multiple-choice
option for function.  We see also a way (not a good one, since there will
be better methods we will cover later.), to allow a catch-all system.
This is also an illustration of something we can most definitely do, is
nest if-else statements.

program tutorial5;
  var
    one, two: integer;
    option: char;
  begin
    writeln('Enter an integer.');
    readln(one);
    writeln('Enter another integer.');
    readln(two);
    writeln('Use a mathematical symbol to indicate what you want to do');
    writeln('with these two numbers.');
    readln(option);
    if option = '+' then
       begin
         writeln(one, ' + ', two, ' = ', one + two, '.');
         writeln('See, I can add.');
       end
    else
       if option = '-' then
          writeln(one, ' - ', two, ' = ', one - two, '.')
       else
          if option = '*' then
              writeln(one, ' * ', two, ' = ', one * two, '.')
          else
              if option = '/' then
                  writeln(one, ' / ', two, ' = ', one / two :0:3, '.')
             { we want to have the decimal point, so we MUST have the
               first one as well to be set to 0. }
              else
                writeln('Use +, -, *, or / as your operator.  Try again.');
  end.

We can do pretty much as many nested ifs as we can, though we need to mini-
mize it as much as possible.  Also, keep in mind, we can use AND or OR to
multiply conditions.  Say, on the division, if we wanted to only honor a
division if the first number was greater than the second number  For that
section of code...

      if (option = '/') and (one > two) then
      ...

Code that's applicant to the IF statement above will execute ONLY when both
conditions are true.  If there are problems that come up in a program using
this, keep in mind the {$B+} compiler directive.  Compiler directives are
placed above the program; part of the program.  Type it as I typed it in the
illustration.  What this does is make it evaluate all the statements of what
I showed above.  Default for Pascal w/o this directive is short-circuit
evaluation.  If option is not / in the above statement, it will not bother to look at the
one > two part of it.  This won't hurt the statement I made above, but it
may for others.  It's something to experiment with...there are no set rules
on when to use the {$B+}.

FOR loops
=========
This is a means to repetively execute commands a SET number of times.
They are implemented by an index variable, generally, an integer, but
can also be a character.  THE INDEX VARIABLE VALUE IS NOT ADDRESSABLE
OUTSIDE A FOR LOOP!  Always remember that, though one of those index
variables may be used as a "clean slate" variable for other things.
Examples of FOR loops are...

      for i := 1 to 7 do
      { starts at 1, counts to 7, stepping/adding by 1 each execution }
         ...
      for letter := 'a' to 'z' do
      { starts at a, counts through the alphabet, stepping to z by 1 letter }

      for i := 10 downto 1 do
      { starts at 10, counts down to 1, stepping/subtracting by 1 }

For this short example, keep in mind that the index variables CAN be
addressed inside of the for loop for the values we want....  For counter
variables, it's generally OK to use some letter like i or j or whatever...
Do make your variables DESCRIPTIVE, though.  That's a good programming
practice...

program tutorial6;
  var
    i: integer;
  begin
    writeln('I''m going to write something 10 times.');
    for i := 1 to 10 do
      writeln('something', '(Time #':15, i, ')');
  end.

Type this one in and run it, and you'll see what it does.  It writes the
first statement above, then writes...

   something         (Time #1)
   something         (Time #2)
   ...
   something         (Time #10)

We can see a good, real use for this, and keep in mind that groups of
statements can be executed in a for loop, just like if statements by
using begin and end; operators, and for loops can be nested as well...

Practice Programming Problem Notes
=====================================
Have people been able to do them adequately?  Please tell me.  Always be
sure to type the examples I give out to see how they work.  Experimentation
and doing the practice programming problems are the best things you can do
to learn by using this tutorial.  Remember, also, to print each of these
parts out as reference for later parts.  Make as a goal for the problems I
present at the end to follow all the guidelines, and try to make them as
SHORT as possible in # of lines of code.  Also, someone suggested a mailing
list to continue this.  If someone would tell me how to set it up (hint,
hint), we may go to that.  Any comments, questions, requests to look at
practice problem code, may be sent to ggrotz@2sprint.net.  Always keep in
mind that there are many different solutions possible to one problem, and
don't be upset if your program didn't look EXACTLY like mine.  If the
output is ACCURATE and your output looks exactly like mine, then your program
is good, and correct.

Practice Programming Problem #2
===============================
        Create a program in Pascal and entirely Pascal that will query the
user for a dimension number to be entered from the keyboard which can not
be greater than 15 (write an error message if it is), and then write out
a multiplication table with the dimension given by the user, with 3 column
spaces between each digit and the double-line (you must use the formatting
codes to accomplish this) to the screen.  Your program must calculate
everything, and nothing can be hard-coded (for example:
write('1   2   3   4   5   6') or something like that).

Example output for this program after execution should be something
like this on your screen (if you see garbage around the lookup columns,
those are continuous double lines <ASCII codes>):
--------------------------------------------------------------------------
What dimension number do you want for a table? 4

     1   2   3   4
  ╔════════════════
 1║  1   2   3   4
 2║  2   4   6   8
 3║  3   6   9  12
 4║  4   8  12  16

Note how I have the numbers lined up in the table.  Your program should do
this as well.  If a dimension is greater than 9, your program should allow
for it by lining up the row counters like you have the answer columns.
Treat what you see above for the table literally (the left side of the file
as the left side of the screen) For example:

 9
10

Good luck, and a solution to this problem will appear in part 3!  Remember
to document your code (sort of like I did with the part 1 answer), and try
to keep it short.  The shorter program is the better program, of two programs
that give correct output.  On this one, cosmetics are tedious, but to get
the job done remember that FOR loops are for things that repeat a set number
of times (if you want a goal for practice on getting this one the least
number of lines possible, my solution for this problem is 50 lines long for
code.)

Next Time
=========
Next time, we will discuss the use of while and repeat loops, and the
case statement.  By all means, send comments, and queries on problems
you may be encountering with problems in this tutorial to ggrotz@2sprint.net.


