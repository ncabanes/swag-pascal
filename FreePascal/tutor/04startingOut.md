


## Pascal Tutorial: Learning Pascal  
by Glenn Grotzinger

###Part 1 -- Starting Out.  
all parts copyright (c) 1995-1996 by Glenn Grotzinger.

```txt
    Category: SWAG 
    Title: PASCAL TUTORS
    Original name: 0004.PAS
    Description: 04-Starting Out
    Author: GLENN GROTZINGER
    Date: 11-28-96  09:37
```

I am writing this tutorial as a means for people to start out and
learn a great deal about Pascal.  I write this part with the understanding
that you have looked at the compiler, and have figured out how to use it to
enter a program, how to compile and run a program within the IDE, save a
source code file, or compile at the DOS prompt, or in the IDE to create an
EXE file; but do not have any understanding of Pascal programming as a whole.
Any subsequent parts will be written assuming that you have read prior parts, and fully understand all the examples.  Please work through
the examples, entering them in yourself, to get used to programming in Pascal.
I also recommend that you print all parts out, so you may have reference
for any future parts that we see.
        As I am writing each part as we go, for right now, I will try
to have each part written and posted on a weekly basis.  

### About this part

This will be a lengthy part, since we are trying to introduce enough material
to get to the point of writing a simple program.

### The basics

My intent in this section is to familiarize you with the proper
starting structure to remember for to get ready to write a program.  Let's
look at the short example below. (I numbered the lines with {}'s for purposes
of this explanation.)

```pascal
{1} program tutorial1; uses crt;
{2}   var
{3}     world_stmt: string;
{4}   begin
{5}     world_stmt := 'Hello world!';
{6}     writeln(world_stmt);
{7}   end.
```

This is a relatively simple program for starting out.  Let us run through
what each line has.

- {1} this is the programID, and the uses clause.
    program <identifer>; uses <library>;
    is the syntax.  <identifier> may be anything that we may decide to
    call the program. <library> is a specification of additional libraries,
    or *units* of commands that we may want to use.

    crt is the name of one library we will use a lot in our programming.
    The commands that can be accessed in this library will be detailed later
    on in the tutorial.  If we want to use any of the commands in a library,
    we must tell the compiler to use the library, and the uses statement
    does this.  I will specify if any commands we use will come out of a
    unit.

- {2} var is a signal we use at the beginning of a program block to tell the
    compiler that we want to start defining variables.

- {3} This is a definition of a string, or sequence of text.  Variable defs.
    will be covered later in this part.  We are defining a variable named
    world_stmt to be a string.

- {4} begin says we want to begin a block of code.

- {5} & {6} are some program commands.  We will explain them later.

- {7} end; ends a program block.

### A few basic commands

I will now discuss **variable definitions**.

-    string: a section of text. "Hello world!" would be a string.
-    integer: a number which does not have a decimal part. 12 is an integer.
-    char: one part of a string.  "G" is a character, while "GG" is not.
-    real: a number which has a decimal part.  3.25 would be a real.

**Comments.**

If you wish to make some text as a remark to what something does,
use the { key or (* to start and the } or *) to end it.

**The assign.**

We use the := to assign a value to a variable.
Examples of that would be such as:
    
```pascal    
world_stmt := 'Hello world.';   { a definition of a string.  The
                                ' s must be there on each side }
choice_char := 'a';             { a definition of a character The
                                ' s must be there on each side }
money := 3.25;                  { a definition of a real }
coins := 10;                    { a definition of an integer }
```

**Arithmetic computations.**

We often have to do arithmetic to program and solve a problem.  I will
illustrate addition, subtraction, multiplication, and division.

```pascal
sum := 3 + 2;   { we're telling the computer to add 3 and 2 and then
                 place 5 in an integer called sum.  Assignments can
                 also work with this way }

sub := 10 - 7;  { we're telling the computer to subtract 7 from 10
                 and then place 3 in an integer called sub. }

mult := 3 * 2;  { we're telling the computer to multiply 3 by 2. }

divisn := 10 / 2; {dividing 10 by 2 }
```

Any of these can be combined in one statement, with the order of
operations being /, *, -, +.  ('s may be used to force one group of
numbers.  For example:

```pascal
answer := 3 + (2 + 6) * 4;
```

Rules:  We must use the following idea to determine whether things are
OK to do for arithmetic.

1. If we perform an arithmetic operation with anything with a real
   in it, the receiving variable in the assign must be defined as
   a real.

2. If we perform a division with two integers that have a chance
   of dividing to become a real, we must use a real for a receiving
   variable.  12 / 7 would be an example and be 1.71 (rounded to 2
   decimal places).

Note: dividing and getting a real or using a real in the other stuff
will result in answers such as 3.232133412E+02.  I will cover later
the way to make that look readable and normal.

We will now look at an **example** of some of the stuff above.

```pascal
program tutorial2;
  var
    first_number, second_number: integer;
    result: integer;
  begin
    first_number := 3;
    {assign first number the value of 3}
    second_number := first_number * 2;
    {assign 2nd number-multiply first number by 2}
    first_number := second_number - 5;
    {assign 1st number-old value of 1st number - 5}
    result := first_number + second_number;
    {assign result to be 1st number + 2nd number}
  end.
```

A question to understand what is going on.  Answer this one, and you
understand everything up to this point.  What is the value of each and
every one of the integer variables as listed in the tutorial2 after all
the statements execute? (Answer will appear in the next part).

**DIV and MOD**
     
These are special operators.  Div places the whole number of a division
in the receiving variable, and MOD places the remainder.  For example:

```pascal
whole := 12 div 7;  {whole becomes 1}
remainder := 12 mod 7; {remainder becomes 5}
```

7 goes into 12 one time with a remainder of five.

**reading and writing information.**

We will stick to use of the keyboard for reading information, and
the monitor for writing information right now.  Remember for any
variable, we must not define it to be the name of a command, when we
do this.

```pascal
read(a_number);
```

This command stops the program and waits for the user to input data
which will be placed in a_number and does NOT produce a movement to
a new line.

```pascal
readln(a_number);
```

This command does exactly as read, but produces a movement to a new
line.

```pascal
write(a_number);
```pascal

This command writes the contents of a_number to the screen without a
new line.

```pascal
 writeln(a_number);
```

This command does exactly as write, but produces a movement to a new
line on the screen.

These commands can be used with any combination of literal, variable,
or arithmetic expression. A literal is a defined statement.
3 is a literal in write(3);.  write(3); will write a 3 on the monitor.

```pascal
program tutorial3;
 var
   some_text: string;
 begin
   write('Type some text and press ENTER when done: ');
   readln(some_text);
   writeln('You just typed the following: ', some_text);
 end.
```

Proper events in this program will be (as it will appear on the screen):

```txt
Type some text and press ENTER when done: <input text here>
You just typed the following: <text here>
```

The readln prompts you to enter text which is rewritten with the last
writeln command.  If you type the examples in and compile them up to this
point (as I recommend -- it will help you learn), you will see exactly
how tutorial3 is supposed to work.

### The End of Part 1

All of my tutorial parts will be formatted much like this one.  First
I will cover some new topics, giving examples, then as the final act will
always be a programming problem, which I will leave you, the reader, to
solve, learning on your own.  The best thing to learn and get competent in
any language is to actually sit down and program.  Any of the programming
problems I leave you will not involve concepts that I have not covered in
previous text, though I will try my best to make them challenging to further
the reader's programming ability.  A solution to each of the problems  in each
part will be presented in the next part.  My rules to you.  These are for
your benefit.

1. Do not ask anyone else to help you in any programming sub, or anywhere
   in programming these little practice programs I give. You will not
   learn anything, if at all, and your time looking through this will be
   wasted.
   
2. Anyone who does know, please do not help anyone who is going through
   this tutorial.  They will not learn if someone else gives them the answer!

3. Try and at least attempt the practice programming problem.  Do not just
   sit and wait until I present a solution.  The syntax is easy to learn
   from having notes and such, but the logic of actually programming some-
   thing is only gotten by practice.

If you wish me to give your code from the practice programming problems in
this tutorial a quick look, send 'em to me at ggrotz@2sprint.net.

###Practice Programming Problem for Tutorial Part 1

Write a Pascal program (and entirely Pascal) which will accept
two integers from the keyboard, presenting the user with a prompt to
enter a number for each integer.  Then print out statements which tell us
what the two digits add up to, subtract to, and multiply to.
To be correct, you must act on the first number and then the second
number in your computations.  For example, 14 and 7 (in that order) would
be treated as 14+7, 14-7, and 14*7.

Example Monitor Screen (using 14 and 7):

```pascal
  Please enter the 1st number: 14
  Please enter the 2nd number: 7

  Adding 14 and 7 gives 21.
  Subtracting 7 from 14 gives 7.
  Multiplying 14 and 7 gives 98.
```

Good luck!  And a solution to this problem will appear in part two!

###Next Time

Next time, we will discuss the use of decision-making (IF statements) in
Pascal programming, as well as loops which repeat a defined, set number of
times (FOR loops).  Eventually, when the tutorial is over, we will have
covered most, if not all of the data and control structures, and a few
special topics of interest to you (in Pascal).  If you have any comments
please send them to ggrotz@2sprint.net.
