(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0017.PAS
  Description: 17-The CRT unit
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                       Turbo Pascal for DOS Tutorial
                           by Glenn Grotzinger
                          Part 14: The CRT unit.
                copyright (c) 1995-96 by Glenn Grotzinger

Hello.  Here is a solution from last time...

{$M 65520,0,655360}
{$B+}
program part13; uses dos;

  var
    drive, s: string;
    drivesize: longint;
    thefile: text;

  function number(n: longint): string; forward;

  procedure listdirsizes(filedir: string);
    var
      size: longint;
      f: string;
      dirinfo: searchrec;
    begin
      size := 0;
      f := filedir + '\*.*';
      findfirst(f, $27, dirinfo); { allfiles - VolumeID - directory }
      while doserror = 0 do
        begin
          size := size + dirinfo.size;
          findnext(dirinfo);
        end;
      writeln(thefile, filedir, number(size):50-length(filedir));
      drivesize := drivesize + size;
      findfirst(f, $10, dirinfo);
      while doserror = 0 do
        begin
         { for some reason, the findfirst above doesn't work right. }
         { Unable to determine exactly why...:<                     }
          if (dirinfo.attr = $10) and (dirinfo.name <> '.')
             and (dirinfo.name <> '..') then
            begin
              s := filedir + '\' + dirinfo.name;
              listdirsizes(s);
            end;
          findnext(dirinfo);
        end;
    end;

  function number;
    var
      i, j: integer;
      s, r: string;
      m: integer;
    begin
      str(n, s);
      r := '';
      i := length(s);
      if i > 3 then
        begin
          while i > 3 do
            begin
              for j := i downto i-2 do
                r := s[j] + r;
              r := ',' + r;
              i := i - 3;
            end;
          for j := i downto 1 do
            r := s[j] + r;
          number := r;
        end
      else
        number := s;
    end;

  procedure writehelp;
    begin
      writeln('Include a drive like this: c:');
      halt(1);
    end;

  begin
    assign(thefile, 'FILESLST.TXT');
    rewrite(thefile);
    if paramcount <> 1 then
      writehelp;
    drive := paramstr(1);
    if (length(drive) <> 2) or (drive[2] <> ':') then
      writehelp;
    drive[1] := upcase(drive[1]);
    writeln(thefile, 'Drive: ', drive[1]);
    listdirsizes(drive);
    writeln(thefile, '===============':50);
    writeln(thefile, number(drivesize):50);
    close(thefile);
  end.

In this part, we will try to discuss the complete usage of the CRT unit.
The CRT unit will allow with text different things, such as PC speaker
control, control of the screen for screen clears, positioning of the
cursor, changing the color of text and background, and so forth.

Basically, when the uses crt, or wincrt, is used, direct writes to the
screen are initiated, and can not be redirected to text file.

Boolean variables.
==================
There is a list of boolean control variables accessible through CRT.

CheckBreak.  It is true by default. If it's false, CTRL+BREAK will be
unfunctional.

CheckEOF.  It is true by default.  If it's false, CTRL+Z when pressed
will not represent an EOF in the program.

CheckSnow.  Enables and disables "snow checking" on CGA adapters.

DirectVideo.  Enables and disables direct video writes.

Keypressed.  Will return true if a key has been pressed.  Usable in a
loop for doing something until the user stops it.  A function like this
is similarly used for example in screen savers to stop the display.
Here is a small example to see how it acts.

program the_key_pressed; uses crt;
  begin
    repeat
      write(#254);
    until keypressed;
  end.

This program should write ascii character #254 to the screen repeatedly
until the user presses a key.

Screen Manipulation Commands
============================
Clreol;  Clears to the end of the line for the currently active window
from the current cursor position.  The concept of "currently active
window" will be explained later.

Clrscr;  Clears the screen.  Already used and demonstrated.

Delline;  Deletes the current line containing the cursor.

Insline;  Inserts line at current position.

PC Speaker Sounds and Machine Delay
===================================
These are the basics of controlling the PC Speaker to make sounds.
The first thing is that there is an ASCII character #7 which will cause
a standard DOS PC Speaker beep.

Then there are some pascal procedures which will offer much more control.
You will have to experiment with it using different numbers in the delay
and sound value.

Delay(milliseconds: word); will delay the program for approximately the
number time in Milliseconds.
Sound(hertz: word); will start up the PC speaker at a specified frequency.
NoSound; will stop the PC speaker.

Here is an example of use of the PC speaker through TP.

program test_of_pc_speaker; uses crt;
  begin
    sound(1500);
    delay(500);
    nosound;
  end.
Basically, we're emitting a sound of 1500 Hz, for a time of .5 seconds.

Note: The delay procedure can be used anytime to "freeze" up the system
for a specified period of time, say if we want to delay between writes.   

Screen Positioning
==================
These is a command to control positioning of writing on the screen.

gotoxy(x, y); is a procedure that will position the cursor at the point
defined by x, y.  The standard defintion of the screen positioning is
a cartesian system like this for the standard video mode (on most systems
when you boot them up).

(1, 1)(2,1)----------------------------------------------...  (x, 1)
(1, 2)
  |
(1, 4)
  |
  |
  |
  |
  |
  |
 ...
(1, y)

x and y is defined by the current video mode, which is settable.  We will
discuss how to set the current video mode.   The standard video mode at
bootup is 80x25.

wherex is the current x position of the cursor, while wherey is the current
position of the y variable.  gotoxy(wherex, wherey+1) is valid as an
example, and will move the cursor DIRECTLY down one unit, irreguardless
of where it is (as long as x and y are valid, most of these commands are
inactive if they get bad data)

The view window can also actually be changed.  The window function can
be used for this purpose.  The window is measured by the coordinate of
the upper left hand corner of the window (x1, y1), and the lower right
hand corner of the window(x2, y2).  The syntax if we call window is
window(x1,y1,x2,y2);  This is one procedure that you really need to
experiment with to see its effects.  As a note, most, if not all of the
screen writing commands are affected by this window...

Changing Text Color, Appearance, and Mode
=========================================
These are functions and procedures which control the appearance of text.

HighVideo; will select high intensity characters.
LowVideo; will select low intensity characters.
NormVideo; will select the original intensity at startup.

Textcolor(color); and Textbackground(color); are used to control the
foreground and background color respectively.  Foreground colors
work from 0-15 and the background colors are from 0-8.  Blinking
foreground text adds 128 to the value.  A list of text color constants
which are equated with these numbers can be found on page 192 of the
TP programmer's reference.

LastMode is a word variable which will hold the current video mode that
the system was in when the program started execution.

Changing text mode actually involves changing what x and y as was originally
stated in the description of gotoxy.  textmode(modeconstant); actually
does this.  As with everything in this part, you should experiment with
all of the commands and procedures defined, because you can't exactly
be showed the effects of these commands in this tutorial.  A list of
mode constants can be found on page 26 of the TP programmer's reference.

Here is a sample program which demonstrates several of the functions and
procedures listed, and gives us an idea of what can be done with
manipulation of text windows, colors, and so forth.  Be sure to run this
one, and experiment with changing some of the values and actions to see
what happens.

program demo_of_fun_text_manipulation; uses crt;
  var
    oldx, oldy: byte;
  begin
    { save original position of cursor so we can return there later }
    oldx := wherex;
    oldy := wherey;

    window(2,2,20,20);
    textbackground(Blue);
    clrscr; { blue background now b/c blue when clrscr was called }
    highvideo;
    window(10,10,15,15);
    textbackground(Green);
    clrscr;
    textcolor(LightCyan + blink);
    write('Hello, how are we doing today?');
    window(1,1,80,25);
    gotoxy(oldx, oldy);
  end.
Reading Characters from the Keyboard
====================================
You may have been wondering, how to directly read things from the keyboard.
The CRT offers a function called readkey, which is a parameterless function
that returns a character.  Unlike read or readln, it does not require a
CR to initiate.  You may see this by replacing a character read from the
keyboard somewhere in your program with something like this:

                answer := readkey;

You will notice that you did not have to press ENTER to move on.  Also,
you will notice that the character didn't echo.  Very useful for password
applications.

The next advantage of readkey is that it can be used to read about every
key or key combination on the keyboard.  For this tutorial, we will discuss
simply the keys that can be accessed via one keypress using a basic standard
to be discussed in the next paragraph.

Extended keys, like the function keys, or the arrow keypad may be read
using readkey.  These keys generate a #0 character as their first character
followed by an extended scan code.  These vary depending upon which key
is depressed.  To read extended keys, we would have to use a structure
such as this:

            char := readkey;
            if char = #0 then
              char := readkey;

Most of the one press keys on the keyboard may be detected using this
method.  Examples of those keys which can't be detected using the
method described by the snippet of code above are the shift keys,
capslock, ScrollLock, NumLock, F11, F12, the CTRL keys, and the ALT
keys.  There are other methods available for those keys and key comb-
inations.  I recommend as practice that you set up a reader program that
will tell you what the extended character codes are for each of the
extended keys (any key not on the basic keyboard).

Practice Programming Problem #14
================================
Create a program in Pascal and entirely Pascal that will do the following:

1) Using normal text mode, set up a screen that has a green background
all the way around the screen as a frame of 4 units in size all the way
around.  Inside of that, place a red frame of 1 unit all the way around.

2) Inside all of the frames described in part 1, set up a title that
states "Keypress Detector" on the first line available below the red
frame, in an high-intensity light cyan.  Be sure this title is NEVER
overwritten by scrolling text.

3) The "Keypress Detector" title should be on a black background.  Also,
the text which shows what keys we have pressed are should be a dull
lightblue on a black background.  The exception to the last statment is
that any standard key identity in the statement should be in a bright
green, and any extended key identity in the statment should be in a
bright red.  Key identity will be evident as I give a sample.

(properly inside the "frame")

Keypress Detector (press ESC 5 times to terminate)
You pressed the F1 key.
You pressed the SPACE key.
You pressed the LEFT key.
You pressed the Backspace key.

Note: Some of the keys on the keyboard are singular control characters.
Look at your ASCII chart.  For example, the TAB key is actually ASCII
character #9, and character #9 should be recognized as such...

F1, SPACE, LEFT, and BACKSPACE are the key identities as I described
earlier...

4) Make sure that in order to terminate the program, the ESC key gets
pressed 5 times, not consecutively (be sure to indicate the ESC key has
been pressed each time).  Upon termination, the entire screen should
visibly scroll up until none of what we wrote is visible anymore (clue:
use delay).

Next Time
=========
We will discuss the usage of the QuickSort and ShellSort algorithms.
Please by all means send comments to ggrotz@2sprint.net.


