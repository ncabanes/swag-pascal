(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0013.PAS
  Description: 13-Binary files; units,overlays, and inc
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                         Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
        Part 10 -- binary files; units, overlays, and include files.
             All parts copyright 1995-6 (c) by Glenn Grotzinger.

        There was no prior problem, so lets get started...

Typed binary files
==================
We know that files can be of type text.  We can also make them type "file
of <datatype>".  We can read and write binary data types to disk.  Here's
an example.   Keep in mind that with typed binary files, you can only
read and write the type of file you define it to be.  For the example
below, we can only deal with integers with this file.  The type we may
use may be anything that we have covered up to this point.  We also
will see that reading, accessing and writing of typed binary files will
be no different than accessing text files, except we can not make use
of readln and writeln (as those are for text files only).

program integers2disk;
{ writing integers 1 thru 10 to a disk data file, then reading 'em back }
   var
     datafile: file of integer;
     i: integer;
   begin
     assign(datafile, 'INTEGERS.DAT');
     rewrite(datafile);
     for i := 1 to 10 do
       write(datafile, i);
     close(datafile);  { done with write }
     reset(datafile);  { now lets start reading }
     read(datafile, i);
     while not eof(datafile) do { we can use the same concept }
       begin
         writeln(i);
         read(datafile, i);
       end;
     writeln(i);
     close(datafile);
   end.

You will notice the numbers 1 through 10 come up.  Look for the file
named INTEGERS.DAT, and then load it up in a text editor.  You will
notice that the file is essentially garbage to the human eye.  That,
as you see, is how the computer sees integers.  In part 11, I will
explain storage methods of many many different variables, and introduce
a few new types of things we can define.  We can use records, integers,
characters, strings, whatever...with a typed file as long as we comply
with the specific type we assign a file to be in the var line.

Untyped Binary Files
====================
We can also open binary files as an untyped, unscratched (essentially)
file.  There we simply use the declaration "file". (I think this is ver7
dependent, am I right?)  Anyway, in addition to this, we have to learn
a few new commands in order to use untyped files.

BLOCKREAD(filevar, varlocation, size of varlocation, totalread);

filevar is the untyped file variable.
varlocation is the location of where we read the variable into.
size of varlocation is how big varlocation is.
totalread is how much of varlocation that was readable. (optional)

BLOCKWRITE(filevar, varlocation, totalread, totalwritten);

filevar is the untyped file variable.
varlocation is the location of where we read the variable into.
totalread is how much of varlocation was readable. (optional)
totalwritten is how much of varlocation that was written. (optional)

SizeOf(varlocation)

Function that gives total size of a variable in bytes.

Maximum readable by BlockRead: 64KB.

Reset and Rewrite have a record size parameter if we deal with an untyped
file.

Probably, the best thing to make things clearer is to give an example.
This program does the same thing as the last one does, but only with
an untyped file.  See the differences in processing...

program int2untypedfile;

  var
    datafile: file;
    i: integer;
    numread: integer;

  begin
    clrscr;
    assign(datafile, 'INTEGERS.DAT');
    rewrite(datafile, 1);
    for i := 1 to 10 do
      blockwrite(datafile, i, sizeof(i));
    close(datafile);
    reset(datafile, 1);
    blockread(datafile, i, sizeof(i), numread);
    while numread <> 0 do
      begin
        writeln(i);
        blockread(datafile, i, sizeof(i), numread);
      end;
    close(datafile);
  end.
      
This program performs essentially the same function as the first example
program, but we are using an untyped file.  Blockread and blockwrite are
used in very limited manners here.  It's *VERY GOOD* for you to experiment
with their use!!!!!!!   As far as the EOF goes on a comparison, blockread
returns how many records it actually read.  We use that as an equivalent.

The 2 missing DOS file functions
================================
We now have the tools to perform the 2 missing DOS file functions that you
probably recognized were gone from part 8, copying files, and moving files.

Copying files essentially, is repeated blockreads and blockwrites until
all the input file is read and all the output file is written.  We can
do it with either typed or untyped files.  An untyped file example may
be found on page 14 of the Turbo Pascal 7.0 Programmer's Reference.

Moving files is a copy of an input file to a new location, followed by
erasure of the input file.

Units
=====
A unit is what you see probably on your drive in the TP/units directory.
Compiled units are TPU files.  They are accessed via USES clauses at the
start.  CRT, DOS, and WinDos are some of the provided units we have already
encountered.  Nothing is stopping us from writing our own, though.  The
actual coding of procedures/functions that we place into units is no
different.  The format of the unit, though, is something we need to think
about.  An example is the best thing for that.  This is a simple
implementation of a unit, with examples to give you some idea of a
skeleton to place procedures and functions into.

unit myunit;

  interface
     { all global const, type, and var variables go here as well as any
       code we may want to run as initialization for starting the unit. }

     { procedures and function headers are listed here }

     procedure writehello(str: string);

  implementation
     { actual procedural code goes here, as it would in a regular program }

     procedure writehello(str: string);  { must be same as above }
       begin
         writeln(str);
       end;

  end.

The unit up above is compilable to disk/memory, but unrunable.  Essentially,
what it is is a library of procedures/functions that we may use in other
programs.  Let's get an example out on how to use one of our own units.

program tmyunit; uses myunit; { must match ID at beginning }
  var
    str: string;
  begin
    str := 'Hello!  Courtesy of myunit!';
    writehello(str);
  end.

Though this program/unit combination is ludicrous, it does illustrate
exactly how to incorporate your own unit with MANY functions into your
programming, if your project gets too big, or for portability's sake
on some of your frequently used procedures.

Overlays
========
This will describe how to use TP's overlay facility.  It must be used with
units.  Typically, my thoughts are that if you get a large enough project
to dictate the use of overlays (we can use 'em on anysize projects, but
the memory taken up by the overlay manager far uses more memory on smaller
projects to make it an advantage to habitually do this).  We will use
the overlay facility with the unit/program set above for example purposes.

ONLY CODE IN UNITS HAVE AN OPPORTUNITY TO BE OVERLAID!  System, CRT, Graph,
and Overlay (if I remember right) are non-overlayable.

{$O+} is a compiler directive for UNITS only which designate a unit which
is OK to overlay.  {$O-} is the default, which says it's not OK to overlay
a unit.

To get to the overlay manager, we must use the overlay unit.

After the overlay unit, we need to use the {$O <TPU name>} compiler
directive to specify which units that we want to compile as an overlay.

WARNING: It is good to check your conversion to overlays in a program
with a copy of your source code.  If you alter it with overlays in mind
and it doesn't work (it's known to happen -- a procedure works ONLY when
it's not overlaid...), you won't have to go through the work to alter
it back if it doesn't work right...

NOTE: You must compile to disk, then run when you work with overlays.

Results come back in the OvrResult variable.  Here's a list...

                  0       Success
                 -1       Overlay manager error.
                 -2       Overlay file not found.
                 -3       Not enough memory for overlay buffer.
                 -4       Overlay I/O error.
                 -5       No EMS driver installed.
                 -6       Not enough EMS memory.

As for examples, let's look at the unit set up to overlay.  As we can
see, the only real difference (which is a good policy to make), is that
there is the {$O+} compiler directive there now...

{$O+}
unit myunit;

  interface
     { all global const, type, and var variables go here as well as any
       code we may want to run as initialization for starting the unit. }

     { procedures and function headers are listed here }

     procedure writehello(str: string);

  implementation
     { actual procedural code goes here, as it would in a regular program }

     procedure writehello(str: string);  { must be same as above }
       begin
         writeln(str);
       end;

  end.

Now lets look into the program itself.  It's error-reporting from the
overlay manager isn't great.  It stops the program if the overlay won't
load, but doesn't do a thing, really, with the ems section.

program tmyunit; uses myunit, overlay;

  {$O MYUNIT.TPU}        { include myunit in the overlay }
  var
    str: string;
  begin
    ovrinit('TMYUNIT.OVR'); { final overlay file name/init for program. }
    if OvrResult <> 0 then
      begin
        writeln('There is a problem');
        halt(1);
      end
    else
      write('Overlay installed ');
    ovrinitems;        {init overlay for EMS.  Usable after ovrinit}
    if OvrResult <> 0 then
      writeln('There was a problem putting the overlay in EMS')
    else
      writeln('in EMS memory.');
    str := 'Hello!  Courtesy of myunit!';
    writeln;
    writehello(str);
  end.

EXE Overlays
============
Here's how to set up EXE overlays.  The DOS copy command features the B
switch.  For example, to take the programs source file above and attach the
overlay to the end of the EXE (be sure you run any exe packers/encryptors
before you do this!), use the following:

        COPY /B TMYUNIT.EXE+TMYUNIT.OVR

Then the change that needs to be made in the source for the program is to
change the overinit line to read TMYUNIT.EXE instead of TMYUNIT.OVR.  You
should be able to handle doing this and understanding what is going on.

Include Files
=============
Use the {$I <filename>} compiler directive at the position the include
file is to be placed.  An include file is code that is in another file,
which may be considered as "part of the program" at the position the
{$I ..} compiler directive is at.

Copy function
=============
You can use the copy function to get a portion of a string into another
part of a string.  For example...

        str := copy('TurboPascal', 5, 3);
        writeln(str);      { writes oPa }

Programming Practice for Part #10
=================================
Write a copy equivalent which will copy one file from a given source to
a given destination.  Be sure it works with any accepted DOS combination
of statements.  Make the display of the program look something like this.

copying README.TXT (32,212 bytes)...done.

Code as much of this program up into a unit as possible, and make the unit
into an overlay.  Write the done when the file copies...Do not bother to
support any software switches.  Be sure the file is an exact copy, meaning
the date and time are identical as well as the file attributes.

Next Time
---------
Interfacing with a common format; how data types are stored in memory and
on disk.  You may wish to obtain use of a hex viewer for this next part.
Send comments to ggrotz@2sprint.net.



