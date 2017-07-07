(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0020.PAS
  Description: 20-Primary Concepts of Pointers
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                        Turbo Pascal for DOS Tutorial
                            by Glenn Grotzinger
                     Part 17: Primary Concepts of Pointers
                   copyright(c) 1995-96 by Glenn Grotzinger

Hello.  Here is a solution from last time...

program part16;

  var
    a: array[1..1000] of integer;
    number: integer;
    c, i, j, PIVOT, t: integer;
    found: boolean;
    location: integer;
    outfile: text;

  procedure quicksort(L, R: integer);
    { nothing to say we couldn't sort the data, especially with the
      fact that we will be performing 500 search hits on this 1000
      unit array...the overhead of sorting the data will be of good
      benefit in the long run... }

    begin
      if L < R then
        begin
          i := L + 1;
          j := R;
          PIVOT := A[L];

          repeat
            while a[i] <= PIVOT do inc(i);
            while a[j] > PIVOT do dec(j);
            if i < j then
              begin
                t := A[i];
                A[i] := a[j];
                A[j] := t;
              end;
          until i > j;

          a[l] := A[j];
          a[j] := PIVOT;

          quicksort(L, j-1);
          quicksort(i, R);
        end;
    end;

  procedure bsearch(number, lowend, highend: integer; var location: integer;
                    var found: boolean);
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
            bsearch(number, lowend, midpoint-1, location, found)
          else if number > a[midpoint] then
            bsearch(number, midpoint+1, highend, location, found);
        end;
    end;

  begin
    randomize;
    assign(outfile, 'LOCATION.TXT');
    rewrite(outfile);

    for c := 1 to 1000 do
      a[c] := random(10000) + 1;

    quicksort(1, 1000);

    for c := 1 to 500 do
      begin
        number := random(10000) + 1;
        bsearch(number, 1, 1000, location, found);
        if found then
          writeln(outfile, c, ') ', number, ' was found at position ',
                  location, '.');
      end;

    close(outfile);

end.

Intro
=====
This will be the first of several parts on the use of pointers...This
part will contain the basic idea behind pointers and their use.  I
would like feedback from anyone about how well they felt they learned
from this tutorial, and the next two.  They all will be about pointers,
and I want to be sure I am doing OK in explaining them coherently. :>

The Concept of a Pointer
========================
A pointer is simply what it implies by the name.  Something that points.
A pointer is a 4 byte double word that stores the segment and offset in
memory where the variable is located.

We have referred to before a method of getting more than 64K in a data
structure, in the array section.  This is a way.  A pointer is placed on
what is referred to as the heap.  The heap is the remainder of conventional
memory not used by the program itself, the data stack, or any TSRs that
may be on the system at any one time.  The data stack is where variables
are normally allocated directly by name and can be a maximum of 64K in size.

Why would we want to use pointers?  Well, we have already eluded to one
reason, to get around the 64K data limit.  Another reason is to dynamically
allocate memory space.  Basically, any variables declared by name(s) in a
program is allocated at the initial start-up of a program, and is allocated
until the end of the program.  For a lengthy program with a lot of variables,
we may not want all variables to be allocated for something at the start.
Therefore, we can, with pointers, allocate and deallocate memory anytime
we wish in a program.

If we want to save memory in the data stack, 1 4-byte pointer compared to,
say, an array of 1000 integers would be preferable.  That is one function
of a pointer.

In using pointers, we must remember that they are not direct variables,
but addresses of variables.  Let us look at the first example program
below to see exactly what I mean by the last statement.  We also will
see how to properly create variable space address pointers in memory,
address that variable space, and then deallocate it.

program pointers_one;

  type
    strptr = ^string;
  var
    a, b, c: strptr;

  begin
    new(a);
    a^ := 'Turbo Pascal';
    new(b);
    b^ := 'is fun!!!!!!';

    writeln('a is now "', a^, '".');
    writeln('b is now "', b^, '".');

    new(c);
    c^ := a^;
    a^ := b^;
    b^ := c^;
    dispose(c);

    writeln;
    writeln('a is now "', a^, '".');
    writeln('b is now "', b^, '".');
    dispose(a);dispose(b);

  end.

We see the use of several use conventions in the program above.  We have
three pointers listed to be pointers of strings.  (as a note, any data
type that will eventually be a pointer should NORMALLY be defined under
the type declaration to facilitate the use of pointers in procedures.
We will see this later.)

In the declaration to allocate the pointers, we used the ^ sign first, then
the datatype.  We say that the pointer will eventually point to a string
variable.

To address each of the pointer variables, we used the ^ sign after the
particular variable name.  The ^ sign references the variable that the
pointer is pointing to, and NOT the pointer itself.  You may see this
by doing a debug trace for a, b, and c on that program.  You will
clearly see that the pointer's contents is NOT what the variable's
contents is...

The next thing to note is the assignment statements.  For a pointer
variable, we are not assigning direct values, but MOVING THE POINTER
address.  When we say a^ := c^, we are moving the pointer c to point
to the value that a points to.  **WE ARE NOT DIRECTLY CHANGING THE
VALUE OF THAT LOCATION IN MEMORY!!!**.

The last thing to note is the strategically placed uses of the functions
new() and dispose().  These are new functions to us that we will learn
and make use of in the system unit.  The new() function will allocate
the space for the pointer listed in the variable on the heap.  The
dispose() function will deallocate the space for the pointer on the heap.
As you can see, we created and removed the variables as we needed them.

The next thing you were probably wondering with pointers is how to get
a pointer to not point to anything.  Make it address a reserved word
called nil.  If I want pointer p to not point to anything, then I would
write:

        p := nil;

Whatever you do, do not set a pointer to nil before you dispose of the
pointer.  The system will lose track of the variable on the heap, and
therefore is LOST to the system.  Keep this issue in mind as we do
our work and examples with pointers.

Look up getmem() and freemem().

Another issue that wasn't covered above is how we determine how much
memory is in the heap.  Use the functions memavail and maxavail for
the purpose of finding out how much memory you can allocate and if the
pointer data structure is big enough, BE SURE TO CHECK AND SEE IF YOU
HAVE THE MEMORY TO ALLOCATE before you allocate it for a big structure.

Procedure or Function Pointers
==============================
A procedure or function may also be addressed as a pointer.  For that,
as you will see in the example, we can use a declaration for a variable
exactly like the procedure or function declaration.  It is very useful
to minimize code usage, and make things multi-functional.  This sheds
some light into the inner workings of the write command, as was wondered
in c.l.p.b. a little while ago...

program pointer_two;
  type
    compfunc = function(a, b: integer):integer;
  var
    compute: compfunc;
    first, second: integer;
    choice: char;

  {$F+}
  function compadd(a, b: integer): integer;
    begin
      compadd := a + b;
    end;
  function compsub(a, b: integer): integer;
    begin
      compsub := a - b;
    end;
  function compmult(a, b: integer): integer;
    begin
      compmult := a * b;
    end;
  function compdiv(a, b: integer): integer;
    begin
      compdiv := a div b;
    end;

{$F-}

  begin
    @compute := nil;
    write('Enter a first number: ');
    readln(first);
    write('Enter a second number: ');
    readln(second);
    write('Enter +, -, *, or / as a operation: ');
    readln(choice);
    case choice of
      '+': compute := compadd;
      '-': compute := compsub;
      '*': compute := compmult;
      '/': compute := compdiv;
    else
      writeln('Enter a correct option.');
    end;
    compute(first, second);
    writeln(first, ' ', choice, ' ',second,' = ',compute(first, second));

  end.
As you can see, we are assigning a particular function to the function
named compute.  After that, compute performs the specified function of
the function that we just assigned to it.  The rule is that those FAR
declarations MUST be present.  As well, you can see how to refer to the
procedure pointer (as @procedure).  As long as the declarations are
similar for all the functions, we can readdress functions/procedures
using a variable like we did above.

We see that we can probably cut down on a lot of code by using this
method if we had several different ways of doing things, with large
amounts of code for each thing.  For example, if we wanted to sort
something based on user input dependent upon many different methods
or types (say sort increasing by name, decreasing by name, increasing
on size, by date, et.al), we can set up our swapping procedure to be
the way the compute procedure is above.

Now, we will lead into a special usage of a pointered procedure called
exitproc.

ExitProc
========
This is a special defined procedure pointer in Pascal that will determine
the procedures that will be performed upon an exit, NO MATTER what happens,
EVEN IF THERE IS A RUN-TIME ERROR.  Here is your method on being able to
catch and log those run-time errors either to the screen, or to an errors
log.  The primary usage of an exit procedure, though, is to perform any
maintenance that needs to be done upon termination that may not get done
upon an abnormal termination, such as closing files. The way things work
are basically the same as above...

Here is a short example...I will force a run-time error in this program,
so we can see that the end gets run anyway.  As you may see, exitproc
is defined as a pointered procedure when we work with it.  The rest is
basically documented.

program pointer_three;

  var
    exitsave: procedure;
    afile: text;

  {$F+}    { must be far }
  procedure myexit; {must be parameterless}
    begin
      if exitcode <> 0 then
        writeln('There was a problem.');
      writeln('We are exiting...');
    end;
  {$F-}

  begin
    @exitsave := exitproc;  { saving the original exit procedure }
    exitproc := @myexit;    { set to new exit procedure }

    { I am placing a couple of error situations in here so you can
      experiment with what is going on...try it without errors too! }

    {1 - here is a standard file not found RTE.}
    assign(afile, '()()()().!!!');
    reset(afile);

    {2 - here is a division by zero.}
    { writeln(3 / 0); }

    exitproc := @exitsave;  { set the original exit procedure back }
  end.

Here is enough material that I believe that is enough to digest for right
now on use of pointers.  Practice allocating and using pointers very
heavily, as we will get into more advanced issues of using pointers in the
next two parts...Remember that ANY structure can be placed as a pointer,
except for files, and remember to define types for all pointers.

Practice Programming Problem #17
================================
Randomly generate 15000 numbers from 1-25000 into an array.
Then generate another 10000 numbers from 1-25000.
If there is a number from the second set of numbers that happens to be in
the first set of numbers, write out to the file named LOCAT2.TXT something
such as:

13131 was found at position 12000.

Only indicate the first instance of the number you encounter.
You may wish to write a "redrawing bar" for a process indicator.

Note: Be sure with the allocation for those first 15000 numbers that you
keep in line with the topic of this tutorial.

Next Time
=========
We will cover the concept of linked lists, or chained lists.  Practice
very heavily the idea of pointers, because you will need use of them
again in the next section.  E-mail ggrotz@2sprint.net with your comments.



