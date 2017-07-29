## Turbo Pascal for DOS Tutorial
by Glenn Grotzinger
### Part 19: Binary Trees
copyright (c) 1995-96 by Glenn Grotzinger

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0022.PAS
  Description: 22-Binary Trees
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```

OK.  I stated no real problem that needed solving earlier, so we will start
getting into some new material.  This is an extension to part 18, in a small
way, since it involves pointered structures similar to the linked lists,
but the procedures for handling them are much different, so I am covering
them in a seperate section.

#### What is a Binary Tree?
A binary tree is a set of nodes with 2 possible paths for each node, left
or right.  Hence, a binary tree node would look something like this:

type
  nodeptr = ^node;
  node = record
    ourinfo: integer;
    left, right: nodeptr;
  end;

Conceptually (my best low ASCII rendering, trust me!), a binary tree would
look something like this.  We can see from below that the possible paths of
those two directions are any numerous.  As with the linked lists, nil ends
the path (knowing, it is probably garbled, but....).

                            NODE
                   _________/  \_________
                  /                      \
               NODE                      NODE
           ____/  \____              ____/  \____
          /            \            /            \
       NODE            nil        nil             NODE
   ____/  \____                               ____/  \____
  /            \                             /            \
nil           nil                         NODE           nil
                                      ____/  \____
                                     /            \
                                  NODE            nil
                              ____/  \____
                             /            \
nil           nil


#### Rules of a Binary Tree
Now that we see what the basic idea of a binary tree is, we will now study
the rules for it.  The basic rules of a binary tree is the following for
any node in a binary tree commonly used for the purpose that they are used
for a lot of times -- as a binary search tree or BST.  Any program code
in this section will make use of BSTs...:

        1) values smaller than the value currently stored in a questioned
           node goes to the left.
        2) values larger than the value currently stored in a questioned
           node goes the right.
        3) values which are equal to other values in the tree are not placed
into the tree.

Let us see this by manually examining how we might build a small binary tree.

#### Example of a Binary Tree Manual Build
Let us examine how we would build a binary tree for a set of values and
how a program would traverse the tree with a very short example.

1) Let us start examining a tree build with a value set data of 27, 54,
   32, 18, and 5.
   a) 27 is naturally the first or root node of the tree.  There is no
      issue there.
   b) 54 > 27 so 54 would go to the right.  Our resultant tree looks now
      like this:
                                 27
                                   \
54

   c) 32 > 27.  So we would move to the right.  Now we see 54 as the main
      node  32 < 54, so we would go to the left.  So the resultant tree
      after this addition looks like this:

                                 27
                                   \
                                    54
                                   /
32

   d) 18 < 27.  So we would move to the left.  So our tree looks like this:

                                 27
                                /  \
                              18    54
                                   /
32

   e) 5 < 27.  So we would move to the left.  Now we see 18 as the current
      node.  5 < 18.  Then we would move to the left again.  So the final
      binary tree for those 5 values looks like this:

                                 27
                                /  \
                              18    54
                             /     /
5     32

This is a reasonable binary tree structure.  Any paths not used are
set to nil in the process.  We should see now how binary trees are
constructed.

2) Now lets study traversal of the tree.  It would depend on if we
visit the actual node first or last.  (I will give a detailed explanation
of that last statement later.)  Normally, as a standard, it's good to
use the left side first.  Therefore, lets look at the tree built in #1.

The order the numbers would come up in is 5-18-27-32-54 on a basis that we
handle or visit the head node of the tree last in moving through the binary
tree. If you remember the discussion of the array binary search, we had to
sort the data to accomplish it.  Here it is taken care of already for us.

#### Basic Idea of Programming for Binary Trees
You may have figured out already from our preliminary discussions, that
recursion is a _major_ staple of binary tree programming (read ALWAYS use
it!).  Note that a binary tree can be divided up into smaller and smaller
trees, hence our ability to use recursion.  Any functions involved almost
always ends up using some order of the following pseudocode, assuming a
name of PROCEDURE for the procedure:

PERFORM PROCEDURE ON LEFT SIDE OF TREE
PERFORM ACTION ON ROOT NODE (the top node of the tree)
PERFORM PROCEDURE ON RIGHT SIDE OF TREE

We will see this idea be paramount in all the code we use.  If you have
noticed in your previous work about recursion, there is always a control
statement present.  Here, it will always be searching for the nil nodes.
*ALWAYS* remember to replace the nil nodes if they come up....binary
search trees are the perferred method generally, for setting up searches.

```pascal
program binary_tree_example;

  type
    nodeptr = ^node;
    node = record
      somedata: integer;
      left, right: nodeptr;
    end;

  var
    tree: nodeptr;
    afile: text;
    i: integer;

  procedure deletetree(var tree: nodeptr);
     { This procedure is a function designed to remove a binary tree
       from memory }

    begin
      { Given the background information, and other procedures as examples,
        you should be able to come up with this one }
    end;

  procedure inserttree(anumber: integer; var tree: nodeptr);
     { This procedure is a function designed to create a binary tree
       in memory by inserting a node in the proper position in the tree }

    begin
      if tree = nil then
        begin
          new(tree);
          tree^.somedata := anumber;
          tree^.left := nil;
          tree^.right := nil;
        end
      else
        begin
          if anumber > tree^.somedata then
            inserttree(anumber, tree^.right);
          if anumber < tree^.somedata then
            inserttree(anumber, tree^.left);
        end;
    end;

  procedure searchthrutree(anumber: integer; tree: nodeptr);
    { This procedure is designed to search through a binary tree for a
      particular value given in the variable anumber. }
    begin
      { Given the background information and other procedures as examples,
        you should be able to come up with this one. }
    end;

  procedure writeouttree(tree: nodeptr);
    { This procedure outputs a binary tree. }
    begin
      if tree <> nil then
        begin
          writeouttree(tree^.left);
          write(afile, tree^.somedata, ',');
          writeouttree(tree^.right);
        end;
    end;

  begin
    randomize;
    tree := nil;
    { the last statement is required for the nil markers set up via the
      BST procedures listed above }

    assign(afile, 'BTEST.TXT');
    rewrite(afile);
    writeln(memavail, ' bytes available before tree creation.');
    for i := 1 to 10 do
      inserttree(random(5)+1, tree);  {This creates the tree. }
    writeln(memavail, ' bytes available after tree created.');
    for i := 1 to 10 do
      searchthrutree(random(5)+1, tree);
    writeln(afile);
    writeln(afile);
    writeln(afile, 'I will now output the binary tree for the example.');
    writeouttree(tree);
    writeln;
    close(afile);
    writeln('Now deleting tree out of memory');
    deletetree(tree);
    writeln(memavail, ' bytes available after tree deletion.');
  end.
```

This is a whole program for working with a binary tree.  I purposely left
out 2 of the procedures, because the background information I gave earlier,
plus pointer logic you should have learned from part 18 should allow you to
logically come up with it.  Do like I recommended in part 18 and draw it
out.  Example code is often not available for many problems, but the
information _is_ there to be used.  To program it is a needed skill to be
able to figure out things on your own given some information.  Code should
not be handed out readily, IMO, unless there is no other way.

#### Practice Programming Problem #19
One noted thing I have noticed with the binary search tree method especially,
is that searches can be done very quickly with any kind of data -- working
with arrays have a small way of being kludgy.  Here we will see an example.

You need to create a binary data file named SOMEWRDS.DAT which should
contain 50 non-duplicated words, randomly defined (do not alphabetize them)
out of 70 total words in the file.

Allow users to type words into the keyboard, until they type the word
"quit".  Case-sensitivity should not matter in any usage of words.
Write out to the user whether the word they typed was found in your
database or not.

Do not be concerned with reporting of run-time errors.  Do be concerned,
though, with the removal of the final binary-tree you use.

Also for the delete code you write for binary trees, explain why your
code does what it is supposed to do.

Note
----
1) Exercise prudent practice as programmers.  In the event it was not
covered, accuracy is a programmer's #1 concern, followed by efficiency
in speed, memory usage, and disk usage.
2) This program should be friendly to the user, letting the user know
precisely what is going on in all cases, even if a common error occurs,
and cleaning up anything that may be of a problematic nature from those
errors.  You should have enough experience from previous parts to be
able to determine what those errors are you would commonly encounter here.
3) The goal here for this program is to create a high-quality application.

#### Final Statements for this Part
I know many people may wish to someday release their creations to the public,
or make programs for themselves or other's general usage. This is why I am
being so vague now about describing programs, and will be from now on.
Creativity and neatness is one of the major qualities that need to be
developed by those who program.

Also for all who program: The way to solve the problem is not always handed
to you.  You have to identify problems that are encountered, sit down and
solve them.  I estimate I'm probably 4-6 parts away from completing this
whole tutorial, and 2 parts away from completing the parts of the tutorial
regarding conventional Pascal programming.  By now, most, if not all the
tools have been presented for you to do this, and not need me to give you
clues, and point you in the direction of what to do to solve the problem.
Most if not all problems you will encounter in normal programming practice
anywhere are normally presented in the form that this one is in -- a
statement of what the program is expected to do.

In short, I feel those who have been new programmers that have been following
my tutorial from part 1 are about ready for the *REAL* world of programming.
<grin>

Next Time
---------
I will cover several short random topics, which some of which may be
suggested by those who e-mail me.  I know I will cover hooking interrupts,
calling an interrupt procedure, and linking an OBJ into Pascal code,
incorporating assembler code into pascal code, and including inline
statements in pascal program code.  Is there any more people would like to
see?  E-mail me.  Also, I haven't gotten any comments from anyone
about how I am doing.  Is anyone interested?  Email ggrotz@2sprint.net.

Note: I am sorry if I offended anyone by the "Final Statements for This
Part" section.  I am apologizing in advance if I come off too harsh.

