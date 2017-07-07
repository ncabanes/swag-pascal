(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0024.PAS
  Description: 24-Use of the BGI
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                       Turbo Pascal for DOS Tutorial
                           by Glenn Grotzinger
                         Part 21: Use of the BGI.
                 copyright (c) 1995-6 by Glenn Grotzinger

Here is a solution to the problem presented last time.

program part20; uses dos;

  const
    oneminute = 273;  { # of timer ticks that happens in 15 seconds }

  var
    saveint09, saveint1c: procedure;
    timecounter, keycounter: integer;
    achar: char;
    timeup: boolean;

  {$F+}
  procedure counttime; interrupt;
    begin
      inc(timecounter);
      if timecounter = oneminute then
        timeup := true;
      inline($9C);
      saveint1c;
    end;

  procedure countkeys; interrupt;
    begin
      inc(keycounter);
      inline($9C);
      saveint09;
    end;

  {$F-}

  begin
    timeup := false;
    timecounter := 0;
    keycounter := 0;
    getintvec($09, @saveint09);
    getintvec($1C, @saveint1C);
    setintvec($09, @countkeys);
    setintvec($1C, @counttime);

    while timeup = false do
      read(achar);

    setintvec($09, @saveint09);
    setintvec($1C, @saveint1C);
    writeln('There were ', keycounter div 2, ' keys pressed.');
  end.


BGI Intro
=========
This part is basically about using the Borland Graphics Interface.  It is
not generally recommended to use it -- use assembler instead to make it a
lot quicker, and smaller.... but due to demand, and the ability to use the
BGI for basic graphics, we will talk about use of the BGI.  For heavy use
of graphics, assembler is indeed better....

BGI loader
==========
Here, I will describe how to make the BGI files functionally more useable
than in their current state....Compile with looking for the external BGI
files is fine, but will run into an annoyance quick, especially with a
distributed utility...it is easier to have the EXE available with the BGI
files binded to it than to make a user keep track of the BGI files....

There is a utility available in TP called BINOBJ.  The BGI files are video
control files, while CHR files are font definition files.  They both are
usable in graphics as binary files...and that is what BINOBJ does...it
converts binary files to OBJect files, which may be handled like described
before.  The proper usage of this utility is...

BINOBJ <binary file name> <object file name> <internal procedure name>

Here is a sample command-line.  To convert VESA16.BGI to an OBJ, do this:

BINOBJ VESA16.BGI VESA16.OBJ Vesa16driver

Locate the BGI files that should be in your TP/BGI directory.
You will need to copy them off to a separate directory.

After you convert all BGI files like this, I recommend you write a unit
to link the BGI files in -- optionally, if you need fonts, you may write
a unit to link those in likewise.  Be sure to define your proper external
procedures like it needs to be done.  Make use of meaningful
names, as you will have to remember them to make use of the graphics set.
For example, I call my unit bgivideo; for each procedure, I put the first
8 chars of the name of the file, and then driver for the BGI files.  These
function names will be easy to remember when we need to use them.

Going into Graphics Mode
========================
Now, hopefully you have your BGI video unit ready now, and sitting in
whatever directory you use to place your pascal code.  Now we will discuss
about how to go into graphics mode using the BGI.

Generally, going to graphics mode initially would require setting up the
BGI unit you created, and then performing an autodetect on the graphics,
followed by an init into graphics mode.

Let us look at some sample code...

program video_example_1;{1} uses graph, bgivideo;

var
  graphicsdriver, graphicsmode: integer;

procedure errormessage(driver: string);
  begin
    writeln('There was an error: ', grapherrormsg(graphresult), driver);
    halt(1);
  end;

begin
{2}if (registerbgidriver(@attdriver) < 0) then
     errormessage('ATT');
   if (registerbgidriver(@cgadriver) < 0) then
     errormessage('CGA');
   if (registerbgidriver(@egavgadriver) < 0) then
     errormessage('EGA/VGA');
   if (registerbgidriver(@hercdriver) < 0) then
     errormessage('Herc');
   if (registerbgidriver(@pc3270driver) < 0) then
     errormessage('PC 3270');

{3}detectgraph(graphicsdriver, graphicsmode);
   graphicsdriver := Detect;
{4}initgraph(graphicsdriver, graphicsmode, '');
{5}if GraphResult <> grOk then
    begin
      writeln('Video error.');
      halt(1);
    end;

{6}repeat
    putpixel(random(getmaxx), random(getmaxy), random(getmaxcolor));
   until keypressed;
   readln;

{7}closegraph;
end.

This is basically a random pixel place system using the video mode in the
recommended auto-detect.  Let's go through a few of the features of the
code, which were marked by {}'s.

{1} As we see, the graph, and bgivideo units are used here.  The graph
unit is the basic function interface for the BGI system.  We are familiar
with bgivideo from earlier.

{2} RegisterBGIDriver() must be called for any and all realistic
possibilities. I recommend that only the ones listed really need to be
checked.  If the function is less than zero, then there is a problem.
The errormessage function holds a function called grapherrormsg() which
will output a direct error as to why things aren't working right.

{3} detectgraph detects the graphics card.  it takes integers represented
by graphicsdriver, and graphicsmode....graphicsdriver will hold the
recommended video type, and graphicsmode will hold the recommended video
mode (it can be changed).  This is why we registered all the drivers...it
will use whichever one it needs, and ultimately, the program will work with
all video modes.

{4} initgraph() takes us into graphics mode.  It is called basically as
indicated in the program.  the third param '', is for when we load the
BGI files externally.  To do that, do not include BGIVIDEO and provide
a path to the BGI files....to get a full auto-detect capability, just
make all the BGI files available....it is easier in the long run to have
the BGI files combined in the exec.

{5} For almost any graphics function, a variable called graphresult is
changed.  There are graphics mode constants, which will be covered later,
which are in there representing different things.  grok is the one which
indicates that things are OK.

{6} This is the real meat of the procedure.  It keeps placing pixels of
random position and color on the screen until a key is pressed.  getmaxx
is the maximum screen position on the x axis.  getmaxy is the maximum screen
position on the y axis.  Graphics screens have the same kind of dimensional
setup as the crt graphics screens do.  The putpixel procedure takes a
x, y coordinate, then a color...getmaxcolor is a constant that holds the
maximum # of colors present in the current video mode.

{7} Closegraph is pretty much self-explanatory.  It shuts down graphics mode
and takes us back to text.

BGI Font Usage
==============
The CHR files you saw, are font files, which have an ability to be used in
graphics programs....

These files can be converted to OBJs, and I recommend that you do so for
purposes of using the fonts.....

Here is a small example of loading and using fonts -- I'm not repeating
the video load code, so I will omit that....

program video_example; uses graph, bgivideo;

var
  graphicsdriver, graphicsmode: integer;
  i: integer;

{1} {$L GOTH.OBJ}
procedure Gothfont; external;

procedure errormessage(driver: string);
  begin
    writeln('There was an error: ', grapherrormsg(graphresult), driver);
    halt(1);
  end;

begin
  { This is the video load code }

{2}  if registerbgifont(@gothfont) < 0 then
      errormessage('Script font');

    i := 100;
{3}  settextstyle(DefaultFont, HorizDir, 1);
{4}  setcolor(blue);
{5}  outtextxy(20, i, 'This is the DEFAULT font.');
{6}  inc(i, textheight('T')+2);
     readln;
{7}  cleardevice;
     settextstyle(Gothicfont, horizdir, 2);
     setcolor(green);
     outtextxy(20, i, 'This is the GOTHIC font.');
     readln;
     closegraph;
end.

This basically goes into graphic mode, and writes those two statements to
the screen.  We will go through the areas marked by {}'s..

{1} This is exactly like I described before.  This is how we load the CHR
file to not make it separate.  We do it exactly like the BGI files, and
set them up as external OBJ files.

{2} registerbgifont works exactly like registerbgidriver does...it registers
the font into the program -- load fonts judiciously -- only if you need
them.

{3} settextstyle() changes the font, direction, and size....things can
be written out either horizontally, or vertically.  Fonts letters are 8X8
pixels in size...so it is also possible to zoom the fonts...the third
is the factor in which it may be done...a 2 in the third parameter makes the
letters 16X16 pixels, and so on and so forth.

{4} setcolor(blue) sets the foreground graphics draw color to blue.

{5} outtextxy() puts out a text statement at coordinate x, y for graphics
mode.

{6} textheight is a function which guages the height in pixels of a text
placed in the statement.

Font file names
===============
DefaultFont; TriplexFont; SmallFont; SanSerifFont; GothicFont; represent
  fonts.
HorizDir; VertDir;

A VERY QUICK overview of commands available from BGI
====================================================
Due to the volume of commands available, all of them can not be sufficiently
covered in the space of this document.  Most if not all of them are
straight-forward to use.  Look at page 185 of the Turbo Pascal language
guide for a list of all of the BGI commands.

Conclusion
==========
IMO, Borland made the BGI very hard to use.  I have stumbled across many
things that looked like bugs in their system (I couldn't use their included
script font).  Beyond that, it works OK for light-duty graphics.  Anything
beyond that truly needs assembler.

There is enough knowledge here to set up and make use of BGI (not with-
standing the basic commands in that list -- for example, rectangle....
draws a rectangle....).

As another side note, you may have noticed that executables you create
using methods described here are large.  Get a program such as PKLITE,
or LZEXE, and compress it.  They compress down about 45-55%, in my
experience.  Graphics programs using BGI seem to characteristically
compile to be large.

Practice Programming Problem #21
================================
Make a program which will successively place rectangles on the screen in
random colors.  Since it is hard to illustrate what I'm wanting, given
this medium, I will place the final executable, named part21.EXE in the
file at Garbo.   Cut and paste the document after you save this, please.
Here are the basic stats behind the program:

1) Squares are used.  use the rectangle() function.  it takes for arguments,
the coordinates of the upper left hand corner, and the lower right hand
corner.
2) Each square drawn successively is one pixel larger than the previous....
3) Continually draw the squares until the user presses a key.
4) The colors are randomly determined.

Look at the program to get an idea of what I am looking for.  Also please
send comments back to ggrotz@2sprint.net if it happens to not work on your
system for no readily apparent reason.  I need to get an idea of how well
these sample video routines work.

Next Time
=========
Things will be indeterminate.  I will be covering object-oriented program-
ming.  As I have not set down and figured out how many parts object-oriented
programming will take to cover, I do not know.

E-mail ggrotz@2sprint.net and suggest anything that has to do with TP, which
I may have not covered.  If it sounds good, I will cover it!

