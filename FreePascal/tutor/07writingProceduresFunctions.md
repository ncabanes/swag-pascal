## Turbo Pascal for DOS Beginning Tutorial
by Glenn Grotzinger

### Part 4 -- Writing Procedures and Functions
all parts copyright 1995-96 (c) by Glenn Grotzinger.

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0007.PAS
  Description: 07-Writing Procedures & Functions
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```


Hello, again, and lets get started...

An example of a solution of last week's programming problem:

```pascal
program part3;

  { This program enables a user to play a guessing game.
    Range: 1-100     Guesses: 6 }

  var
    choice: char;
    randnum, number_given, attempts: integer;

  begin
    randomize; { start random # generator }
    while upcase(choice) <> 'N' do   { while we want to play }
      begin
        randnum := random(100) + 1;  { generate random number for game }
        attempts := 6; { set initial number of attempts }
        number_given := 1000; { stuff number_given so while kicks in }
        writeln('I''m thinking of a number between 1 and 100.  What is it?');
        while (attempts > 0) and (number_given <> randnum) do
           { while we still have attempts to guess }
          begin
            readln(number_given);
            if number_given = randnum then
               writeln('Congratulations!  You got the number right!')
            else
               begin
                 attempts := attempts - 1;
                 if attempts = 0 then
                   writeln('Sorry, you ran out of choices. ',
                           ' The number I was thinking of is ',
                           randnum, '.')
                 else
                   if number_given > randnum then
                     writeln('It''s lower.  (', attempts,
                           ' guesses remaining)')
                   else
                     writeln('It''s higher. (', attempts,
                           ' guesses remaining)');
              end;
          end;
        writeln;
        writeln('Do you want to play again? (Y/N)');
        readln(choice);
      end;
   end.
```

If there are any questions or difficulties, write ggrotz@2sprint.net.

On to the new stuff...

### PROCEDURE writing

This is a way a lot of things work in Pascal.  For example, the
write command is a procedure.  We say the procedure name, then a list of
parameters which describe what we want to write.  Write is defined in
Pascal itself, but we can write our own procedures to do things.  Before
the main part of the program, and after our variable declarations, we
place our procedures.  Procedures are essentially whole separate programs
which perform small tasks in a bigger program. Here is a short example of
what I mean:

```pascal
program tutorial11;

  var
    one, two: integer;
    final: integer;

  procedure addtwonumbers(first, second: integer; var answer: integer);
    begin
      answer := first + second;
    end;

  begin
    writeln('Adding two numbers:');
    writeln('Type two numbers in (space after each number) to add.');
    readln(one, two);
    addtwonumbers(one, two, final);
    writeln('The answer is ', final, '.');
  end.
```

The procedure enables us to perform more modular, understandable, and
easier to debug programs.  We always code logical parts of the program
together in procedures and functions (will be discussed later).  This
example is pretty simplistic, as we include only one statement in a
procedure (generally a waste of time), which could easily be in the body
of the program.  We can use one statement procedures in more logical things,
such as conversions of one set of unit to another.  We describe the parts
of the procedure declaration above, and the calling of the procedure.

We can define a series of statements as long as they are the same type, and
we don't want to keep them without the use of the VAR section of the
procedure.  We don't care about, and don't modify first, and second, so we
place them in there without the var.  We modify the variable used as
answer, so we MUST have the VAR before it in order to have the variable
survive in a modified state by calling the procedure.  Play around with
what happens in tutorial11 when you remove the var from in front of the
third statement.  When we call the procedure, we use variables which match
and make sense to what we want each variable we want. we use one, and two
for the numbers to add, because our procedure is designed
to add those first two numbers.  Then we put final in the last one, because
that is our final answer.  We can SAFELY use the same variable names for
the procedure and the globals, but it is a good idea not to, as it will not
always be possible to correlate our items in that way.  We should always
have a goal to write procedures/functions with ability to drop them into
another program where all the parameters are passed to it.  We can easily
drop the procedure written above into any other program that needs a similar
function.  It is possible to have a parameterless procedure as well, if it
is predicted as required.  Say...In a multi-function menu system or something
that does a set thing (clrscr is an example).

NOTE: It is always good to keep your old code when you write and use
parameter passing in your procedures and functions, so you can easily 
re-use your code and save time in having to rewrite old code.

### FUNCTION writing

Function declarations are exactly like procedures, except that functions
have the capability to return a value.  We see in the example, below, which
is a rewrite of tutorial11.

```pascal
program tutorial12;
  var
    one, two: integer;
    final: integer;

  function addtwonumbers(first, second: integer):integer;
    var
      answer: integer;
    begin
      answer := first + second;
      addtwonumbers := answer;
      {we can also do addtwonumbers := first + second;}
    end;

  begin
    writeln('Adding two numbers:');
    writeln('Type two numbers in (space after each number) to add.');
    readln(one, two);
    final := addtwonumbers(one, two);
    writeln('The answer is ', final, '.');
  end.
```

In the function, we see we MUST define the final answer to the value of
the function.  The end part :integer; defines the return value of the
function.  The way to set up a function should be evident from this example.

### SETS

It's possible in an IF/WHILE/REPEAT to set up a test on a group of statements.
For example:
```txt
   IF character in ['a'..'z'] then
   { if character is in the lowercase alphabet }
   IF character in ['1','2','3','5']
   { if character is 1, 2, 3, or 5 }
   IF number in [0..23] then
   { if number is between 0 and 23 }
```

### TYPE and CONST statements.
It's possible to type-delineate variables.  Such as for example, we may want
to limit a string from it's standard 255 characters (if we say just string),
to say 10 characters (string[10]), we can not use something like that in
a procedure or function (we will see the types used a lot).  Therefore, we
use the type section to redefine this so we can use them in procedures/
functions.

It's also possible to set constants in a pascal program.  Say, if we want
to set up a constant tax rate, we just define it in a constant section.

We see this in an example:

```pascal
program tutorial13;
  const
    tax_rate = 0.14; {14% tax rate}
  type
    string[15] = string15;
    { string[15] redefined so we can use it in a procedure/function,
      though we will not have procedures or functions here. }
  var
    total_pay: real;
    your_name: string15;
    {if we make type dec, we must carry it across.  This variable is
     a string with a limit of 15 characters. }
  begin
    writeln('Who are you? (15 char. max)');
    readln(your_name);
    writeln('How much did you earn this paycheck?');
    readln(total_pay);
    writeln('Assuming, you have a ', tax_rate * 100 :0:0, '% income tax ',
            'rate, you will have to pay $', total_pay * tax_rate :0:2,
            ' in income tax this paycheck.');
  end.
```

The use of tax_rate is a prime reason that we would want to define a
constant.  Instead of using that number everywhere we needed it, we used
the reference of tax_rate.  Why?  If the income tax ever changed in this
example, we would not need to go through the whole program and change that
number.  All we need to do is change that reference.
    
### Clearing the screen

This will be the first example of a command that we must call a unit for
to get.  The unit you call (as I did in tutorial1) would be CRT for TP/DOS,
and WINCRT for TP/WIN.  You use the statement clrscr; for this.  This
program example clears the screen.

```pascal
program tutorial14; uses crt;
  begin
    clrscr;
    writeln('I cleared the screen for you.');
  end.
```

#### Final Note

You should lay out your programs in logical units using functions and
procedures, making them parameter passing if possible, and logical.
The best may be (especially for programs that do multiple things which
are unrelated on code level) to not parameter pass.  Whatever works
functionally is the best, and if you can't figure out a way to parameter
pass to the procedure or function....

### Programming Practice Problem Notes

This is the first program, that I would expect you to write using
functions and procedures.  All programs you should write in the future
should strive to use parameter-passed procedures.  The reasons are many-
fold for this, which I stated before.  Be sure you do this.  This program
should not be any more difficult than any of the previous programming
problems I gave.  All I expect this one to be is an exercise for you to
learn in using procedures and functions.  If you want more practice beyond
this problem in writing things using procedures and parameters, I suggest
you recode the programming problem out of part 2.  If you can get it more
easier understood to look at, and using parameter-passed procedures for the
logical parts of it, and make it work right, then you got it.

### Practice Programming Problem #4

Write a program in pascal and entirely Pascal which will present
a simple menu driven system (readable, and by pages -- use clrscr in the
appropriate spots) which will enable the user by choice to do the following,
as indicated by sample output for the menu.

#### sample output for menu

```txt
1. Convert a number of seconds to hours, minutes, and seconds.
2. Convert a given military time to AM/PM time.
3. Quit the program.

Please enter your choice now:
```

#### sample output for option 1

```txt
Please enter a number of seconds: 3600

3600 seconds is 1 hour, 0 minutes, and 0 seconds.

Press ENTER to continue:
```

#### sample output for option 2

```txt
Enter a military time's hours: 14
Enter a miltiary time's seconds: 00

It is 2:00 PM.

Press ENTER to continue:
```

Notes: 

1. there are 60 seconds in a minute, 60 minutes in an hour.

2. "military time" is 24-hr time.  For example, 16:00 would be 4 P.M.

3. The program must continue to function in the menu system until the user wishes to quit.

4. Remember to ask the user for appropriate data that you need.

5. Be sure to pause the screen to enable the user to see the results of their query.  You may accomplish this by just calling readln;. It will call the computer to wait until the user presses a key.

6. Be SURE your program is easily understood.


The solution to this program will be presented in the next part.  Good luck!

### Next time

Next time, we will discuss the usage of text files for reading in
data and writing out results. We really are moving along with the concepts
rather readily...


