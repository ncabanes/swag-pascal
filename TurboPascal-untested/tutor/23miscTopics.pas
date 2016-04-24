(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0023.PAS
  Description: 23-Misc Topics
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                        Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
                       Part 20: Miscallaneous Topics
                     copyright (c) by Glenn Grotzinger

Hello.  Here is a solution for the programming problem that was given in
part 19 with a little background explanation.

PART19A.PAS
-----------
This was the program written to generate the binary data file for use with
the actual word checker.  A text file was written to facilitate reading in
the data, one word per line, to ease implementation.

program part19a;

  var
    infile: text;
    outfile: file;
    datastring: string[14];
  begin
    assign(infile, 'SOMEWRDS.TXT');
    assign(outfile, 'SOMEWRDS.DAT');
    reset(infile);
    rewrite(outfile, 1);

    readln(infile, datastring);
    while not eof(infile) do
      begin
        blockwrite(outfile, datastring, sizeof(datastring));
        writeln(datastring);
        readln(infile, datastring);
      end;
    blockwrite(outfile, datastring, sizeof(datastring));
    writeln(datastring);

    close(infile);
    close(outfile);
  end.

PART19B.PAS
-----------
This is the actual word checker.  It is made so the words typed into the
keyboard do not have to be case sensitive with reference to the datafile.
All prevalent errors have error-checking code.

program part19b;

  type
    strtype = string[14];
    nodeptr = ^node;
    node = record
      str: strtype;
      left, right: nodeptr;
    end;

  var
    tree: nodeptr;
    datastring: strtype;
    infile: file;

  procedure opendatafile(var infile: file; afile: string);
    begin
      assign(infile, afile);
      {$I-}reset(infile, 1);{$I+}
      if IOResult <> 0 then
        begin
          writeln('Terminating.  ', afile, ' does not exist!');
          halt(1);
        end;
    end;

  function upstr(instr: strtype):strtype;
    var
      i: byte;
      tempstr: strtype;
    begin
      tempstr := '';
      for i := 1 to length(instr) do
        tempstr := tempstr + upcase(instr[i]);
      upstr := tempstr;
    end;

  procedure memoryerror;
    begin
      writeln('Out of memory.');
      halt(1);
    end;

  procedure deletetree(var tree: nodeptr);
    begin
      if tree <> nil then
        begin
          deletetree(tree^.right);
          deletetree(tree^.left);
          dispose(tree);
        end;
    end;

  procedure inserttree(datastring: strtype; var tree: nodeptr);
    begin
      if tree = nil then
        begin
          if memavail - sizeof(tree) > 0 then
            new(tree)
          else
            memoryerror;
          tree^.str := datastring;
          tree^.left := nil;
          tree^.right := nil;
        end
      else
        begin
          if upstr(datastring) > tree^.str then
            inserttree(upstr(datastring), tree^.right);
          if upstr(datastring) < tree^.str then
            inserttree(upstr(datastring), tree^.left);
        end;
    end;

  procedure buildsearch(var infile: file; var tree: nodeptr);
    var
      datastring: strtype;
    begin
      blockread(infile, datastring, sizeof(datastring));
      while not eof(infile) do
        begin
          inserttree(datastring, tree);
          blockread(infile, datastring, sizeof(datastring));
        end;
      inserttree(datastring, tree);
      close(infile);
    end;

  procedure searchtree(datastring: strtype; tree: nodeptr);
    begin
      if tree = nil then
        writeln(datastring, ' was not found in the data file.')
      else
        begin
          if datastring = tree^.str then
            writeln(datastring, ' was found in the data file.')
          else
            begin
              if datastring > tree^.str then
                searchtree(datastring, tree^.right);
              if datastring < tree^.str then
                searchtree(datastring, tree^.left);
            end;
        end;
    end;

  procedure promptwrite;
    begin
      writeln('Type QUIT to terminate.');
      writeln('Type a word, and we''ll see if it''s in the database.');
      writeln;
    end;

  begin
    writeln('Database checker.');
    writeln;
    opendatafile(infile, 'SOMEWRDS.DAT');
    buildsearch(infile, tree);
    promptwrite;
    readln(datastring);
    while (upstr(datastring) <> 'QUIT') do
      begin
        searchtree(upstr(datastring), tree);
        promptwrite;
        readln(datastring);
      end;
    deletetree(tree);
  end.
The written explanation of the delete code that was written in the example,
to completely remove the BST from memory...

We know that in a pointer-linked structure if we remove a node that has
links assigned to it, that we will cause a heap leak and render the rest
of the data structure unremovable from memory.  In a BST, that case becomes
when both right and left branches of the node are nil.  We have to use
recursion, evidently, since the problem of deleting the entire binary tree
comes down to many smaller problems of deleting nodes with both sides
assigned to nil, basically.  So basically, if we observe those lines of
code, recursion occurs until both the left and right sides of nodes become
nil, and then a dispose occurs.  In working back up in returning from the
procedure calls, the tree is essentially disposed of from the bottom up to
the root node, in reverse from the way the insert code illustration created
it.

Contents for Part 20
====================
Since this part contains many random varied topics, a table of contents is
in order....

        A) Linking OBJ code into Pascal programs.
        B) Including ASM or inline statements in Pascal programs.
        C) Hooking an interrupt in pascal programs.
        D) Calling an interrupt procedure.
        E) Conditional Compiler Compilation.

Linking OBJ code into Pascal programs
=====================================
This is a short program, which describes the exact process, USING A C
program's function (the topic of using C OBJ's came up).  If you do
this with C OBJ, the code must not make any calls to any C libraries,
or make any calls to a DLL.

A description of what's going on...

TEST1.H

int far pascal add2numbers(int num1, int num2)

  {
    return (num1 + num2);
  }

This is a C header file with a small defined function in it.  You MUST
define it using either void far pascal for a procedure or <datatype> far
pascal for a function.  I describe a function in test1.h.  For those who
wonder, a header file in C functions much like a unit does in Pascal.

For an OBJ you intend to use, each and every function must be defined in
the resultant pascal program.  (I know it is not liked, and you SHOULD
NEVER normally post attachments in c.l.p.b.) With differences
between so many different C compilers and syntaxes that exist in the world,
I will post the OBJ file I got from the compiler I use, for purposes of
enabling others to test this.  I recommend you to cut and paste it before
you uu or xx encode it if you need to obtain it.

begin 644 test1.obj
M@`D`!U1%4U0Q+D..B!\````;5$,X-B!";W)L86YD(%1U<F)O($,K*R`S+C`P
MD8@/``#I=G%"(`=415-4,2Y#3H@&``#E`0``C(@5``#F!&YU;3($"@8`!&YU
M;3$$"@@`2(@&``#E`08`AH@@``#F!F%N<W=E<@0"_O\$;G5M,00*"``$;G5M
M,@0*!@"DB`4``.<:`'*(!0``YQH`<H@*``#N`0``!@`4`&6(`P``Z8R(!0``
MZ@$+?98H```%7U1%6%0$0T]$105?1$%4001$051!!%]"4U,#0E-3!D1'4D]5
M4-&8!P`H&@`"`P$9F`<`2```!`4!#Y@'`$@```8'`0N:!@`(_P+_`U60$@``
M`0M!1$0R3E5-0D524P```#N("P``XQ@````C!`4`1H@%``#A&!ABH!X``0``
M58OL@^P"BT8(`T8&B4;^BT;^ZP"+Y5W*!`"ZB!```.@`!U1%4U0Q+D-V<4(@
<3I03```!`@````8`!@`'``\`"``4`!B*`@``=```
`
end

TEST2C.PAS

{$F+}
program test2c;

  {$L TEST1.OBJ}
  function add2numbers(num1, num2: integer): integer;external;
  
  begin
    writeln(add2numbers(2, 3));
  end.


This is the pascal code using the OBJ.  Basically, the $F+ compiler
directive is required.  Then observe the usage of the $L compiler
directive.  The $L specifies the OBJ file name to link in.
Also note the use of the external; statement at the end of the function
declaration.  That specifies that the function is defined externally,
and not in any Pascal unit or defined in the program itself.  The
function or procedure declaration listed in the pascal program must
match EXACTLY with the one defined in the OBJ file.  It does in this
case.

Including ASM or inline statements in Pascal
============================================
Pascal is a compiler, which translates the data into ASM, and then into
machine language.  Naturally, if it takes the data to ASM, it can use
straight assembler code as as well.  Take a look at the short procedure
mockup below.

procedure dothis; assembler;
  asm
   { assembler code goes in here }
  end;

asm is a keyword that may be used anywhere in code, which
tells the compiler to start looking for assembler code instead of pascal code.
The assembler keyword is one that can optionally be added to make the
compiler look for an asm keyword instead of the begin at a beginning of a
procedure or function.

An inline statement works much like a function call.  It makes it so
that machine language can be used in pascal code.  For example (the hex
codes are garbage I'm making up so don't use this in a real program),
an inline statement can look like this...

inline($80/$23/$14/$36);

The codes can go on infinitely, and are separated by /'s...

References
==========
There is so much specific information out there that is required to know
about computers that references are almost always needed.  Here are a few
of my recommendations.

   Ralf Brown's Interrupt List (INTERXXY.ZIP  XX being a version #, y
       being a through e. -- this is a big set of text files!)
       This is a listing of all known interrupt functions of a PC.

   The PC Game Programmer's Encyclopedia (PCGPE.ZIP)  This is a
       collection of text files...some hold tutorials about how to
       program in assembler and VGA, a lot of them hold specific
       information about how to program peripherals of your system.
       Another big download

   The SourceWare Archival Group collection (SWAG).  Very much known,
       this is a collection of pascal code which has been donated by
       programmers from all over the world that reference how to do
       various topics.  I recommend you use this code only as a reference
       for instruction and do not copy the code.  This is almost a 7.5MB
       download.

Hooking an Interrupt
====================
An interrupt is a signal made from the computer to the CPU for many
functions that occur in the computer.  There are many different types
and numbers of interrupts.  There are two basic types, though, hardware
and software interrupts.

A interrupt is put in simpler terms is an "attention order" from some
component of the system.  In most common systems, there are 255 of these
available, both software and hardware.

Below is an example where we hook an interrupt.  Hooking an interrupt
involves the replacement and augmentation of the basic system interrupt
process with something else, or nothing at all (if we want to temporarily
disable a piece of hardware for a security program, for example).

What this program does is hook the interrupt that handles the internal
PC timer.  That function is augmented by a count that is added by the
procedure "count" listed below.  As a background, for the PC timer,
approximately 18.2 timer ticks occur every second, or 0.054945 seconds
per tick.  Ultimately, you can see by running this program, that all it
does is wait for you to press a key. 

program writehello; uses dos;

  var
    intsave: procedure;
    counter: integer;

 {$F+}
 procedure count; interrupt;
   begin
     inc(counter);
     inline($9C); { prods an interrupt }
     intsave;
   end;
 {$F-}

 begin
   writeln('Press a key.');
   getintvec($1C, @intsave); { get current int. procedure. }
   setintvec($1C, @count);   { replace it with our procedure. }
   readln;
   setintvec($1C, @intsave); { save the regular int. procedure back }
   writeln(counter, ' timer ticks have passed.');
 end.

We will now describe what is different here....

getintvec() is a TP DOS unit function which pulls the procedure currently
  defined on that interrupt.
setintvec() is a TP DOS unit function that resets the function defined by
  the interrupt.
The interrupt keyword must be placed on the procedure definition, and the
  procedure definition must be defined as far, like you see.

A word of note for a procedure defined as an interrupt...the original
interrupt procedure must be called within that interrupt procedure.  The
inline($9C) seems to also be a required element.

NOTE: Hooking an interrupt is essentially a dangerous proposition, to a
degree.  Be sure that you are careful and learn what happens on each
interrupt and know what the interrupt does before you try to hook it.
Doing this actually CHANGES the hardware behavior of your system.
If attempting to hook an interrupt causes the system to behave adversely,
STOP the program right there (reboot the system even), and do not attempt
the code again until you are aware of what exactly happened and what is the
right thing to do to accomplish what you want.  For example, I once tried
hooking a replacement procedure on the interrupt for the hard disk, and I
had garbled output from the directory commands until I rebooted....

Basically, BE VERY CAREFUL IN HOOKING INTERRUPTS.

Calling Software Interrupt Procedures
=====================================
The system (hardware and operating system) has varied software interrupts
which may be called to perform certain functions in the system.  This is
how most of the file access works in the other functions of the DOS unit,
such as assign, reset, rewrite, and close; for example.

The record registers or tregisters are defined in the DOS unit or WinDOS
unit respectively. It looks like:

type
  registers = record
    case integer of
      0: (AX, BX, CX, DX, BP, SI, DI, DS, ES, Flags: Word);
      1: (AL, AH, BL, BH, CL, CH, DL, DH: byte);
    end;

This is considered a variant record, which may be used to discriminate
the latter part of the field if data dictates it.  If you are familiar
with the assembler language, you should recognize the fields from the
record.

Here is a sample program, which holds an example of a software interrupt
call.  In this case, the program is calling function 9 (?) of interrupt
$21, which involves writing a string out via regular BIOS calls (this is
what TP does when it writes out a string).  Note the conversion of the
pascal string to a blocked array string.  A string must end with a "$"
when using this function.

program writetest; uses dos;

  type
    strtype = array[0..255] of char;

  procedure writestring(astring: string);
    var
      tstr: strtype;
      i: byte;
      regs: registers;
    begin
      i := 1;
      repeat
        tstr[i] := astring[i];
        inc(i);
      until i = length(astring);
      astring[i+1] := '$'; 

      Regs.Ah := 9;
      Regs.Ds := Seg(astring);
      Regs.Dx := Ofs(astring);
      intr($21, regs);  {call interrupt $21 using regs register set }
    end;

  begin
    writestring('Hello all!');
  end.

Amazingly, this program is 304 bytes smaller as an EXE than the
equivalent program  listed below written using exclusively the TP write
procedure...remember, the most efficient code is USUALLY the code with
the shortest # of lines, but not ALWAYS.

program writetest1;
  begin
    write('Hello all!');
  end.

This program also introduces a few new function calls.  Intr() is a
Pascal function in the DOS unit which executes a function call.  It is
called like the example program.

Memory addresses, as you may have already seen from following pointers
using the debugger, are set up in a 20-bit segment/offset manner (20-bit
memory = 1024KB addressable -- they did this for the original 8088's...).
Seg() shows the memory segment of any variable you place in there.
Ofs() shows the memory offset of any variable you place in there.
Addr() shows the complete memory address of any variable you place in
there.

Consequently, we may also use the function MsDos() in this case to replace
the Intr() call above.  MsDos() is an Intr() call to interrupt $21 (the
DOS operating system control interrupt).

Conditional Compiler Compilation
================================
Let us first define a few more compiler directives for your collection of
knowledge....defaults marked with ~

                + state                      - state
                --------                    ----------
$N               FPU on                     ~FPU off
$G               286 code gen. on           ~286 code gen. off
$E              ~FPU emulation on            FPU emulation off

These are compiler directives often used conditionally.  Conditional
compilation is essentially another language, independent of the actual
language code.  Identifiers may not be used from code in compiler
directives and vice versa.  Let's look at a few of the pertinent
constants that Pascal defines in relation to this....

MSDOS => boolean: indicates that the operating system is MS-DOS or PC-DOS
CPU87 => boolean: true if there is a math coprocessor (FPU) present.

The only construct you will typically see is an if then or if then else.

The compiler directives I listed above are most commonly used with this
type of situation.  There are additional floating point data types available
called comp, single, double, and extended; which are usable via the FPU
generally.  The definitions of these variables may be defined using the
conditional compiler directives....

The conditional compiler directives we need to know are:

{$IFDEF <name>}                                If item defined
{$IFNDEF <name> }                              if item not defined 
{$ELSE}                                        ELSE directive
{$IFOPT <compiler directive>}                  If compiler opt..
{$ENDIF}                                       END IF STATEMENT
{$DEFINE <name>}                               define a statement
{$UNDEF <name>}                                undefine a statement.

Functionally, these work and compile the source code if certain things are
true.  For example, {$IFOPT N+} <some code> {$ENDIF} in some code will make
it so the code represented by <some code> will only be used if N+ is defined.

Here is a short example program using conditional compiler directives....

program condcomptest;

  begin
    {$IFDEF CPU87}
      writeln('There is a math coprocessor in the system.');
    {$ELSE}
      writeln('There is not a math coprocessor in the system.');
    {$ENDIF}
  end.
You will notice that only ONE writeln statement will execute itself.  The
dependence will be whether a FPU exists in your system.

Practice Programming Problem #20
================================
Write a program which will count the number of keystrokes a user presses
in a period of 15 seconds.  Use proper programming interest in this
program, and be sure to be friendly to the user with this program.

Background information.
   Keyboard interrupt is $09.  Interrupt occurs 2 times for every
   key pressed.

Notes: Unfortunately, in all attempts I've made, to make it TERMINATE
exactly on 15 seconds, it would cause a nasty problem.  The program will
have to read in at least one key after termination.  Do not worry about
this.

Next Time
=========
We use the BGI.  Write comments to ggrotz@2sprint.net.





