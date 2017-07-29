## Pascal Tutorial: Learning Pascal  
by Glenn Grotzinger

### Part 3 -- While and Repeat Loops; Case Statements
all parts copyright 1995-96 (c) by Glenn Grotzinger.

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0006.PAS
  Description: 06-While and Repeat Loops; Case Statements
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```
             


Hello again.  I haven't gotten much input about continued
interest in this tutorial.  I may discontinue it if the interest
doesn't pick up. I am planning on taking this tutorial through all
of the Pascal data structures, and maybe special topics (advanced
ones, too, listen up self-professed Pascal experts -- you may even
learn something. :>).  I haven't gotten any suggestions on the special
topics!!!  Please give comments to ggrotz@2sprint.net.

An example of a solution of last week's programming problem:

```pascal
program part2;

  { This program accompanies part 2.  It is a program designed to take a
    number representing the dimensions of a multiplication table from the
    user, and then write a multiplication table out to the screen. }

  var
    dimension: integer;
    i, j: integer;

  begin { part 2 }

    {take input for the dimension}
    write('What dimension number do you want for a table? ');
    readln(dimension);
    writeln;

    { if dimension not greater than 15, process table }
    if dimension <= 15 then
      begin

        { write top line of table }
        write('   ');
        for i := 1 to dimension do
          write(i:4);
        writeln;

        { write top rule line }
        write(#201:3);
        for i := 1 to (dimension * 4) do
          write(#205);
        writeln;

        { write rest of table }
        for i := 1 to dimension do
          begin
            if i < 10 then
              write(' ');
            write(i,#186);
            for j := 1 to dimension do
              write(i*j :4);
            writeln;
          end;
      end

    { else it's greater than 15, write an error message }
    else
      writeln('You must give a dimension that''s 15 or lower.');
  end.
```

If there are any questions as to understanding, or difficulties
in solving the practice problems I pose (only way to improve your
own programming talent is to practice...), write ggrotz@2sprint.net.

On to the new stuff....

### WHILE loops

It is possible to have a loop to perform a set of
commands a non-set number of times, until a condition is met.  It
can be a contrived one (we can code the basic idea of a FOR loop
using a while loop or the repeat loop. We see this in the recode
of tutorial6 from last time I will make using a while loop instead
of a for loop.

```pascal
program tutorial7;
  var
    i: integer;
  begin
    writeln('I''m going to write something 10 times.');
    i := 1;
    while i <= 10 do
      begin
        writeln('something', '(Time #':15, i, ')');
        i := i + 1;
      end;
  end.
```

As we see when we run this program, it produces the same output
as program tutorial6 did.  The statements in the while loop
function while the condition is true.  When i becomes 11, the loop
breaks off and the program ends. Like the IF statements, we can
place multiple conditions by connecting them like before with the
AND or OR identifiers...

### REPEAT loops

This is another loop we can use.  The WHILE loop will
function while a condition is true. The REPEAT loop stops fun-
ctioning when a condition is true. We see the idea of this again,
when we reconstruct program tutorial6 using the repeat loop...

```pascal
program tutorial8;
  var
    i: integer;
  begin
    writeln('I''m going to write something 10 times.');
    i := 1;
    repeat
      writeln('something', '(Time #':15, i, ')');
      i := i + 1;
    until i > 10;
  end.
```

The programs tutorial6, tutorial7, and tutorial8 perform the same
things, with loops, using different ideas.  The difference of the
while and repeat loops over the for loop is that UNDER NO CIRCUM-
STANCES IS THE INDEX VARIABLE FOR A FOR LOOP TO BE CHANGED WHILE
INSIDE THE LOOP. The conditional variable for a while or repeat
loop can be easily changed as we saw in tutorial7 and tutorial8.
There are many choices and options we can implement with the while
and repeat loops. Menu systems are often implemented like this
Continue until user wants to quit. is the basic logic.).

### CASE statement

As we saw in tutorial5, we may want to make a choice based
on many, multiple options.  This statement is analogous to a series
of IF statements on the same variable.  The CASE statement reduces
the wordiness of such a construct, and makes things easier.  I was
eluding to this statement before when I mentioned then that there
is a better way of doing it.  Well, here it is.  We use the example
of tutorial9 below, which is a rewrite of tutorial5, to illustrate
the use and syntax of a case statement.  Keep in mind that the operator
we use in the case statement (like option below) must be a character
or an integer...

```pascal
program tutorial9;
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
    case option of
      '+': begin   { sub procedures can be coded as well }
             writeln(one, ' + ', two, ' = ', one + two, '.');
             writeln('See, I can add.');
           end
      '-': writeln(one, ' - ', two, ' = ', one - two, '.');
      '*': writeln(one, ' * ', two, ' = ', one * two, '.');
      '/': writeln(one, ' / ', two, ' = ', one / two :0:3, '.');
    else {catch rest}
      writeln('Use +, -, *, or / as your operator.  Try again.');
    end; {case includes an implied begin.  We MUST end. }
  end.
```

As I said in the note, case statements include an implied BEGIN.  We must
say end; to complete the case statement.  The case statement is formatted
for each of our choices above, and the else can be used as a catch-all in
case the user places something in there that we don't account for in the
program, so we can write an error message to the user.  The syntax of the
case statement is basically as above.  You see everything that can be done
with the case statement under Pascal.

### Random and Randomize

We can generate random numbers by doing the following.
At the beginning of the program, call randomize.  Then do
random(*a number*).  What will happen is it will produce an
integer from 0 and less than the number you put in.  Random(3)
will produce a random number from 0-2.  Example.

```pascal
program tutorial10;
  { write 10 random numbers between 1 and 20 }
  var
    number: integer;
    i: integer;
  begin
    randomize;
    { start the random number generator.  Only call once, but must call! }
    for i := 1 to 10 do
      writeln('Random number (#', i,') = ', random(20) + 1);
      { produce random number from 1-20 instead of 0-19 like random(20) only
        does }
  end.
```

### The Upcase and Length Functions, addressing strings

upcase(char) command will place a letter into uppercase.  This
command is useful for input prompts where the user is asked to give input
that involves a character or a string.  To illustrate the use of this
command, which may be placed in a write statement, or an assign (it is
what is defined as a function.  We will see what that is next time.).
write(upcase('c'));  will produce a C on the screen.  Another example,
which uppercases a string.  We use the function length(string) which is
useful for that purpose.  Given a string into that function, it will
return an integer length of the string.

```pascal
     for i := 1 to length(inputstring) do
       upcasestring := upcasestring + upcase(inputstring[i]);
```

This for loop will accomplish it.  The thing we see also, with the illus-
trations of the upcase and length functions, is that we can address any
part of the string by stringname[position in string].  For example, the
string "Charleston" can be there as inputstring.  If we wanted the 5th
character of the string, we say inputstring[5].  inputstring[5] would
be equal to 'l', since it's the 5th character of the string.

### Programming Practice Problem Notes

I am beginning to see the problems get more difficult as there are
more things we know, and we can do more useful and fun things with our
coding.  You may even want to start setting out and solving simple
mathematical problems for homework, or coding up a simple program that can
figure up your checkbook ... it can be done with what you know now, believe
it or not.  Think about what you can do with your new found knowledge.  Do
not try and overextend yourself trying to do things you have no knowledge of
as of yet.  Attempt this practice programming problem as you hopefully have
the others.  It's a rather fun one, as it's an actual game.  We see we are
coming far and there is a lot farther road to go.  There's lots more
concepts we have to learn, which will enable us to do a whole lot more.
Look forward to several more parts, hopefully...

### Practice Programming Problem #3

Create a program in Pascal and entirely Pascal that will enable the
user to play a guessing game using the keyboard and the monitor as input and
output.  The points to be addressed in programming this game:

1. The number range of the guessing game must be from 1 to 100.
2. The user must be given 6 opportunities to guess the number.
3. After the user guesses at the number, the program is to answer the
   user by saying whether their guess was high or low and tell them the
   number of guesses they have remaining.
4. If they guess the correct number, give them a congrats message.  If
   they exhaust their attempts, give them a try again message, revealing
   the correct number.
5. Give them the opportunity to play again by asking whether they want to
   play again (Give them a Y/N prompt.).  Be sure to take care of all 4
   variants of this choice by using the most efficient method you have
   available to you.
6. Remember as always to code as efficiently as possible.  This one can
   be printed out on one page (38 lines to be exact for my sample of this
   one).  Use that as a coding goal for your learning.
7. If you get stuck, e-mail me about it, and I'll see if I can help.  Have
   faith.  You have the ability to do it.

#### sample output

```txt
I'm thinking of a number between 1 and 100.  What is it?
50
It's higher. (5 guesses remaining)
75
It's lower.  (4 guesses remaining)
63
It's higher. (3 guesses remaining)

If right:
Congratulations!  You got the number right!

If wrong:
Sorry, you ran out of choices.  The number I was thinking of is 68.

Play again:
Do you want to play again? (Y/N)
```

The right / wrong / play again messages are not statically required.  I am
only giving examples of what they may be.  Your goal for this game should
be to program it so it is playable and user-friendly.  I recommend you to
use the prompt structure right above, though.

### Next Time

We will discuss functions and procedures and their use next time.  Please
refer your comments to ggrotz@2sprint.net.
