                       Turbo Pascal for DOS Tutorial
                            by Glenn Grotzinger
          Part 18: Chained or Linked lists, the linked list sort
                copyright(c) 1995-96 by Glenn Grotzinger

Here is a solution from last time...

{$M 64000,0,655360}
program part17; uses crt;

  type
    arptr = ^atype;
    atype = array[1..15000] of integer;
  var
    a: arptr;
    number: integer;
    c, i, j, PIVOT, t: integer;
    found: boolean;
    location: integer;
    outfile: text;

  procedure quicksort(L, R: integer);
    { nothing to say we couldn't sort the data... }
    begin
      if wherex = 79 then
        begin
          gotoxy(1, wherey);
          clreol;
        end
      else
        write(#254);

      if L < R then
        begin
          i := L + 1;
          j := R;
          PIVOT := A^[L];

          repeat
            while a^[i] <= PIVOT do inc(i);
            while a^[j] > PIVOT do dec(j);
            if i < j then
              begin
                t := A^[i];
                A^[i] := a^[j];
                A^[j] := t;
              end;
          until i > j;

          a^[l] := A^[j];
          a^[j] := PIVOT;

          quicksort(L, j-1);
          quicksort(i, R);
        end;
    end;

  procedure bsearch(number, lowend, highend: integer; var found: boolean);
    var
      midpoint: integer;
    begin
      if lowend > highend then
        found := false
      else
        begin
          midpoint := (lowend + highend) div 2;
          if number = a^[midpoint] then
            begin
              found := true;
              location := midpoint;
            end
          else if number < a^[midpoint] then
            bsearch(number, lowend, midpoint-1, found)
          else if number > a^[midpoint] then
            bsearch(number, midpoint+1, highend, found);
        end;
    end;

  begin
    if maxavail - sizeof(a) > 0 then
      new(a)
    else
      begin
        writeln('Out of memory!');
        halt(1);
      end;
    randomize;
    assign(outfile, 'LOCAT2.TXT');
    rewrite(outfile);

    for c := 1 to 15000 do
      a^[c] := random(25000) + 1;

    quicksort(1, 15000);

    for c := 1 to 15000 do
      begin
        number := random(25000) + 1;
        bsearch(number, 1, 15000, found);
        if found then
          writeln(outfile, c, ') ', number, ' was found at position ',
                  location, '.');
      end;
    dispose(a);
    close(outfile);

end.


Now we will discuss the idea of the linked list or chained list.  Basically,
there are 4 types of linked lists that we can discuss, the singularly linked
linear list (SLLL), singularly linked circular list (SLCL), doubly linked
linear list (DLLL), and the doubly linked circular list (DLCL).  I will
use the abbreviations I placed in the parentheses for any future references
to these data types.

These are basically the preferred ways to allocate large amounts of storage
space on the heap.  All linked lists are basically describable in the best
analogy as a chain.  They are record structures which have pointers that
interconnect them.  The method that these structures are connected
distinguish the type of linked list it is.  We will look at an example of
the use of SLLL's, observe the advantages of linked lists through what we
do with the example, and study the things to look out for on all 4 types.

SLLL Concepts
=============
This is the simplest type, in sense.  It involves a record structure which
is connected in a chain in a linear fashion with one link forward to the
next link.  A sample record structure for an SLLL follows below.

type
  nodeptr = ^node;
  nodetype = record
    ourinfo: integer;
    nextnode: nodeptr;
  end;

An example of an SLLL conceptually is something like this:

NODE-->NODE-->NODE-->NODE-->NODE-->NODE-->NODE-->nil

As we remember from earlier, nil is what we set a pointer to, if we do not
want it to point to anything...In the use of an SLLL, it is also what we
will use to indicate whether we are at the end of the list or not.

We will see from the slll_demo program that there are several specialized
issues we need to take into consideration with working with any linked or
chained list.

1) We need to make a special case to insert or delete a node from the start
of the list.
2) We need to be sure to maintain nil pointers in any insert or delete
operation.
3) NEVER NEVER NEVER WORK DIRECTLY WITH THE HEAD TRACKING POINTER WE
ORIGINALLY ALLOCATE UNLESS WE DESIGN OUR CODE COMPLETELY AROUND RECURSION.
As a result, you will cause what is called a heap leak.  This is where
the pointer loses track of where the data it points to is stored.  Logically,
looking at the model above, if we disconnect one of the pointers, represented
by the arrows, we lose track of the rest of the list, or chain.  Work with
a temporary pointer for each linked list function. What I say by recursion,
you will see later in this document.
4) With regards to the example I wrote, I tried to demonstrate any and all
functions that we might need with an SLLL.
5) Pointers that point at nil CAN NOT be deallocated.  You will see this
fact manifest itself by the memory statement at the end being 8 bytes
smaller than it was at the start.

SLLLs Demonstrated
==================
Here is the SLLL_DEMO program.  I will place stop notes in there, as well
as comments.

Advantages of linked lists: We will see here, that the data is not static,
we can place data independently at different positions WITHOUT shuffling
data, remove data in the same fashion, and definitely are capable of handling
*A LOT* more data than 64KB, since we only have a 4 byte stub in that area.

Take a good look at this program and seek to understand EXACTLY how it works.
As you will remember from last time, a direct assignment to a pointer is
making it point to something while a reference to the pointer (via ^) changes
the contents of the data it points to.  I recommend you draw out what is
going on via pencil and paper, using boxes to represent the records and
arrows representing pointers.  It will help you VASTLY to do this in
understanding what is going on.  Remember a pointer can only point to one
thing at a time.  When you look at this program, seek to answer the
following questions taking any "housekeeping functions" out of consideration:

1) Why is the insert code different than the build code?
2) Why is the delete code different than the cleanup code?
3) On the "divisible by 8" search, why is the NEXT node being searched for
this and not the current node?
4) Why did I say to always use a temporary variable? Or Why does the
statement p := list; always occur?
5) Observe methods of moving through the list.

program slll_demo; uses crt;

  { Program written by Glenn Grotzinger for a demonstration of all of the
    functions/uses of a linked list that the author could think of.
    the variable used throughout called p, and sometimes t, are temporary
    variables.

    Note: This probably isn't completely optimized. }

  type
    nodeptr = ^nodetype;
    nodetype = record
      thenum: integer;
      nextnode: nodeptr;
    end;

  var
    list: nodeptr;

  procedure buildlist(var list: nodeptr);

    { This procedure builds up the list for us. }

    var
      p: nodeptr;
      i: integer;
    begin
      new(list);       { This is creating the head of the list }
      list^.thenum := 1;
      p := list;       { Set and move temporary pointer }
      for i := 2 to 18 do
        begin
          new(p^.nextnode);
          p^.nextnode^.thenum := i;
          p := p^.nextnode;
         { p := p^.nextnode advances the temporary pointer to the next node.
           this is a memory storage address or pointer and not a direct
           variable, referencing a node of the linked list.  Anything, in
           reality does not become a pointer until the new function is used. }
        end;
      p^.nextnode := nil;   { set last pointer to nothing }
    end;

  procedure writelist(list: nodeptr);

    { This procedure serves the function of writing out the list for us
      to the screen when called }

    var
      p: nodeptr;
    begin
      p := list;
      while p <> nil do { while we're not at the end of the list }
        begin
          write(p^.thenum:3);
          p := p^.nextnode;
        end;
    end;

  procedure insert(var list: nodeptr);

    { This procedure will serve to insert a node into the list either in
      the middle or the end.  The logic can be done for the head of the
      list. }

    var
      p: nodeptr;
    begin
      new(p);
      p^.thenum := 20;
      p^.nextnode := list;
      if p^.nextnode = nil then  { maintenance of the end of list marker }
        p^.nextnode^.nextnode := nil;
      list := p;
    end;

  procedure delete(var list: nodeptr);
    { This is a procedure that will serve to delete a node from the list,
      and consequently deallocate the memory.  It is possible to remove
      the node without deallocating the memory, though it is a bad practice
      to do so }

    var
      p, t: nodeptr;
    begin
      p := list;
      t := p^.nextnode^.nextnode;
      dispose(p^.nextnode);
      p^.nextnode := t;
    end;

  procedure insertbythree(var list: nodeptr);

    { This procedure moves through the linked list and determines where
      the new nodes needs to be inserted, then calls the insert function
      written before }

    var
      p: nodeptr;
      i: integer;
    begin
      p := list;
      i := 1;
      while p <> nil do
        begin
          p := p^.nextnode;
          inc(i);
          if i mod 3 = 0 then
            insert(p^.nextnode);
        end;
    end;

  procedure findanddispose(var list: nodeptr);

    { This procedure finds and disposes the first number in the list
      divisible by 8. }

    var
      p, t: nodeptr;

    begin
      p := list;
      while (p^.nextnode <> nil) and (p^.nextnode^.thenum mod 8 <> 0) do
        p := p^.nextnode;
      delete(p);
    end;

  procedure cleanup(var list: nodeptr);

    { This procedure removes the list from memory. }

    var
      p, t: nodeptr;
    begin
      p := list;
      while p <> nil do
        begin
          t := p^.nextnode;
          dispose(p);
          p := t;
        end;
    end;

  begin
    clrscr;
    writeln;writeln;
    writeln('Free memory available: ', memavail, ' bytes.');
    buildlist(list);
    writeln('Free memory available: ', memavail, ' bytes.');
    write('The list is: ');
    writelist(list);
    writeln;writeln;
    writeln('Now we will insert a 20 in every third position');
    insertbythree(list);
    writeln('Free memory available: ', memavail, ' bytes.');
    write('The list is: ');
    writelist(list);
    writeln;writeln;
    write('Now we will search for and take the first # divisible by 8 ');
    writeln('out of the list.');
    findanddispose(list);
    writeln('Free memory available: ', memavail, ' bytes.');
    write('The list is: ');
    writelist(list);
    writeln;writeln;
    writeln('Now we will be good little programmers and clean up our list. :)');
    cleanup(list);
    writeln('Free memory available: ', memavail, ' bytes.');
  end.

Hopefully, you can go through here, and follow the logic (actually, you will
need to do that successfully to understand what is going on).

Linked lists are very modular in nature.  Therefore, a good understanding
of what is going on here is essential.  As a proof to be able to think
through the logic of using pointers in linked structures, write out and
logically explain on your sheet of paper how to perform the following
(I will not provide a solution for this one -- code it up yourself and
try and figure it out -- this is an important skill you will need to start
developing as a programmer at this point, since you're at a pretty advanced
level now (:))), and then code it up as a program:

1) Create 1000 nodes in an SLLL that consists of integers numbered from 1
to 1000.
2) Print this list to a text file.
3) Reverse the direction of the linked list.  By doing this, I mean, instead
of the linked list looking like this conceptually:

                   NODE-->NODE-->NODE-->nil

make it look like this:

                   nil<--NODE<--NODE<--NODE

DO NOT CREATE ANOTHER LINKED LIST IN MEMORY.  USE THE CURRENT ONE YOU HAVE
BUILT.

4) Print the new list to the same text file.  Instead of it being from 1
to 1000 as the first printing was, it should be from 1000 to 1.

CLUE: Think about how many temporary variables you will need (1?  Maybe 2?,
Possibly 3?).

SLCL Concepts
=============
This is essentially the same as an SLLL, except instead of being nil at the
end of the list, the end of the list points at the beginning of the list.
This type uses the same record format as the SLLL.

Conceptually, an SLCL looks like this:

  NODE--->NODE--->NODE--->NODE--->NODE
   ^                               |
   |                               V
  NODE                            NODE
   ^                               |
   |                               V
  NODE<---NODE<---NODE<---NODE<---NODE

As before with the SLLL, one of these nodes would be denoted as the head
of the list.

The only consideration that would differ that I could note, is that you
would use a comparison of your temporary pointer with your head pointer
in order to move through the list.

So instead of while p <> nil, it would be while p <> list in the above
example to make it that way.

DLLL Concepts
=============
This type of linked list uses a different kind of record format.  It looks
like this:

type
  nodeptr = ^node;
  node = record
    ourinfo: integer;
    lastnode, nextnode: nodeptr;
  end;

Conceptually, a DLLL looks like this:

                nil <--    <--    <--    <--
                       NODE   NODE   NODE   NODE
                           -->    -->    -->    --> nil

If you study up your logic from previously, this one shouldn't be too awfully
bad to figure out.

DLCL Concepts
=============
This type of list uses the same record format as the DLLL.  The conceptual
diagram looks much like the SLCL diagram, but with double links much like
the DLLL diagram, instead of single links.

Final Thoughts on Linked Lists
==============================
I did not provide examples of SLCLs, DLLLs, and DLCLs , merely for space,
and also by the fact that I have never had reason to use the other three
types.  I am presenting their basics here, merely for people's study, and
learning.  Using the knowledge learned from doing those logic problems
presented in the SLLLs, and references (though I find those to be VERY
sparse on the types other than SLLL), you should be able to come up with
the code to do the other three types pretty readily.  Always remember that
the best thing to do to work out the logic of what to do with the pointers
is to draw it out using the boxes and the arrows.

An Idea on Sorting Data Using Linked Lists
==========================================
Here, I will now present the reasoning behind my "recursion" statement,
plus an idea of sorting data upon build.  I don't have any stats on
this being more or less efficient than using one of the array sorts,
but if you can't use an array to sort in memory, you would have to resort
to this.

Here is a little code/pseudocode (with a bent toward sorting names
alphabetically)  For purposes of the recursion, we will call the
function INSERT:

IF WE ARE TO PUT NODE HERE
  GET DATA TO PUT INTO NODE (read data from file, or elsewhere)
WHILE DATA IS NOT DONE DO
  BEGIN
    IF NIL LIST THEN
      PUT NODE HERE
    ELSE
      PUT NODE HERE = NEWNAME <= NODE^.NAME
    IF WE ARE TO PUT NODE HERE THEN
      BEGIN
        new(p);
        SET DATA TO NODE
        p^.nextnode := LIST;
        if p^.nextnode = nil then
          p^.nextnode^.nextnode = nil;
        list := p;
      END
    ELSE
      INSERT(LIST^.NEXTNODE);
    IF WE ARE TO PUT NODE HERE THEN
      BEGIN
        GET INFO.
        DO NOT PUT NODE HERE (boolean variable set to false).
      END.
  END.

This general code does work for a high capacity.  I have used this code 
to sort a maximum of an 86KB list of 150 char items per line alphabetically
using memory alone, no disk swapping.

For practice: Do things as I have suggested throughout this document.
No real practice problem.

Next Time
=========
We will talk about binary trees.  Be sure to send comments to
ggrotz@2sprint.net.  I will say again that I apologize for the long
period of time it took to get this out.  I also apologize for the length
this document has become.  Be sure to please comment on how this
part is.
