## Turbo Pascal for DOS Beginning Tutorial
by Glenn Grotzinger
### Part 5 -- Reading and Writing to Text Files.
All parts copyright 1995-96 (c) by Glenn Grotzinger

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0008.PAS
  Description: 08-Reading and Writing to Text Files
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```


```pascal
program part4; uses crt;

  { This program offers a menu-type system in order to convert a number
    of seconds to hours, minutes, and seconds; and to convert a military
    time to AM/PM time }

  var
    choice: integer;

  procedure showmenu;
    { This procedure shows the main menu. }
    begin
      writeln('1. Convert a number of seconds to hours, minutes, and',
              ' seconds.');
      writeln('2. Convert a given military time to AM/PM time.');
      writeln('3. Quit the program.');
      writeln;
      writeln('Please enter a choice:');
    end;

  procedure convseconds;
     var
       totalseconds: integer;
       hours, minutes, seconds: integer;
       temp: integer;
     begin
       clrscr;
       write('Enter a total number of seconds: ');
       readln(totalseconds);
       writeln;
       temp := totalseconds div 60;
       seconds := totalseconds mod 60;
       hours := temp div 60;
       minutes := temp mod 60;
       writeln;
       writeln(totalseconds, ' seconds is ', hours, ' hours, ', minutes,
              ' minutes, ', seconds, ' seconds.');
       writeln;
       writeln('Press ENTER to continue:');
       readln;
     end;

  procedure convmilitary;
    { Version 1.1.  Bug found and e-mailed to me.  It is appreciated. }
    { Involved the reporting of times from 0000 to 0059...Looks to }
    { be fixed now. (wrote this in a very dazed state -- post-surgery)}

    var
      hours, minutes: integer;
      meridian: char;
    begin
      clrscr;
      write('Enter a military time''s hours: ');
      readln(hours);
      write('Enter a military time''s minutes: ');
      readln(minutes);
      if hours >= 12 then
        begin
          meridian := 'P';
          hours := hours - 12;
        end
      else
        meridian := 'A';
      if hours = 0 then
         hours := 12;
      writeln;
      write('It is ');
      write(hours);
      write(':');
      if minutes < 10 then
        write('0');
      write(minutes);
      writeln(' ', meridian, 'M.');
      writeln;
      writeln('Press ENTER to continue:');
      readln;
    end;

  begin
    choice := 10;
    while choice <> 3 do
      begin
        clrscr;
        showmenu;
        readln(choice);
        case choice of
          1: convseconds;
          2: convmilitary;
        end;
      end;
  end.
```
OK.  On to new stuff...

#### Addressing Files
To address a file, we use the assign statement.  We use a text variable to
refer to the file, and a string to refer to the actual pathname and filename
of the file.

To open a file, we use a reset(<file variable>); statement to read it.

To write a new file, we use a rewrite(<file variable>); statement.

To close a file after we are done accessing it for read or write, we use
the close(<filevar>).

#### Special Identifiers
There are functions defined in standard Pascal which aid us in processing
text files.  They are eof(<filevar>) and eoln(<filevar>).  They return
boolean values.  They are signals we can use in loops to aid us in finding
our way in text files.  EOF signals when we are at the end of a file.
EOLN signals when we are at the end of a line of text in a file.

NOTE: Keep in mind, we can have as many files defined as we need.  The only
limitation is that we can only have a maximum of the number of files defined
in the FILES= statement of the config.sys of the particular machine we are
on open at any one time.  It is always prudent to close files after you are
done with them.


#### Text file concepts and reading/writing to text files
A sample program to illustrate all the items above.  We will be doing a
character by character read on an input file named DATA.TXT using eoln
and eof properly, and uppercasing the output of the file using the
standard upcase function. The output will be written to another output file
named UPCASED.TXT.

```pascal
program tutorial15;
  var
    infile, outfile: text;
    inputchar: char;
  begin
    assign(infile, 'DATA.TXT'); { associate var infile with DATA.TXT }
    reset(infile); { open DATA.TXT for read }
    assign(outfile, 'UPCASED.TXT'); { assoc. var outfile with UPCASED.TXT }
    rewrite(outfile); { open UPCASED.TXT for write }
    while not eof(infile) do { while we're not at the EOF for infile }
      begin
        while not eoln(infile) do { while not EOLN for infile }
          begin
            read(infile, inputchar);
            write(outfile, upcase(inputchar)); { process and output }
          end;
        writeln(outfile);  { when end of line, advance both files down }
        readln(infile);    { one line }
      end;
    close(infile);     { we're done with both of these files.  Close 'em }
    close(outfile);    { time. }
  end.
```

This program is primarily for illustration purposes of all the new concepts
we need to know in order to access files (there is a lot better way out
there of doing it).  As long as we remember what exactly is read and
considered as each type of variable (integer, char, string[limit], etc,
etc), we can read all sorts of data from a text file and write data back
out to a text file.  To illustrate:  If we have the following input file
as on disk...

14 23 34 53 32 Glenn Grotzinger
23 23 12 33 23 Clinton Sucks!

If we perform ONE read from a varied amount of different types from the
first position of the first line, we will see the following:

 CHARread: 1
 INTEGERread: 14
 STRING[20]read: 14 23 34 53 32 Glenn
 STRINGread: 14 23 34 53 32 Glenn Grotzinger

readln/writeln goes to the next line, whichever references what we are doing
to the text file.

We must keep these general rules in mind (I hope you played around with the
read and write commands a lot, that playing will help you A LOT!).

Another illustration to see usage of files.  It's the BETTER rewrite of
tutorial15.  We must also keep in mind that to read a text file, EOLN
is not necessarily required, but EOF is ALWAYS REQUIRED.  Improvements:
We can use a string and write a function to uppercase the whole string.
Plus, there's one little logic error above...Figure out why I do the
reads and writes different below and you'll have mastered the idea of
reading/writing files...(I intended to just demo the commands earlier,
this is a demo of how they should be used logically...)

```pascal
program tutorial16;

  var
    inputstring: string;
    infile, outfile: string;

  function upstr(instring: string):string;
    { This function uppercases a whole string }
    var
      i: integer;
      newstr: string;
    begin
      newstr := '';
      for i := 1 to length(instring) do
        newstr := newstr + upcase(instring[i]);
      { we can piece strings together using +.  Keep it in mind }
    end;

   begin
     assign(infile, 'DATA.TXT');
     reset(infile);
     assign(outfile, 'UPCASED.TXT');
     rewrite(outfile);
     readln(infile, inputstring);
     while not eof(infile) do
       begin
         writeln(outfile, upstr(inputstring));
         readln(infile, inputstring);
       end;
     writeln(outfile, upstr(inputstring));
     close(infile);
     close(outfile);
   end.

Remember to play with the logic in accessing text files.  And in reading and
writing files, BE SURE YOU USE FILES THAT YOU CAN STAND TO LOSE IF YOU ARE
NOT COMPLETELY COMFORTABLE WITH PROGRAMMING FOR FILE ACCESS.  IF A FILE
BY A NAME YOU USE FOR A PROGRAM ALREADY EXISTS ON THE DRIVE, AND YOU REWRITE
IT, IT WILL BE COMPLETELY LOST!  THIS MEANS ANY UNDELETE PROGRAM WILL *NOT*
BE ABLE TO RECOVER THE FILE!!!!!!!!!!!   I will cover in a later part
how to find out whether files exist on the drive as well as other commands
and functions used in Pascal to perform DOS-like functions (delete files,
make directories, remove directories, and so forth).

#### Printer Output
The printer can basically be treated as a write-only file (you only
rewrite it, not reset it).  To use the printer?  Use the unit printer, like
you did the unit crt or wincrt before then write to a text file variable
named lst....Printer defines everything you need to write to the printer.
Printer assumes LPT1, so if your printer is on something else, you can
define the text file variable to be the port address for the printer....

```pascal
program tutorial17; uses printer;
  var
    str: string;
    infile: text;
  begin
    assign(infile, 'PRINTME.TXT');
    reset(infile);
    readln(infile, str);
    while not eof(infile) do
      begin
        writeln(lst, str);
        readln(infile, str);
      end;
    writeln(lst, str);
    writeln('File sent to printer on LPT1..');
  end.
```


#### Practice Programming Problem Notes
Probably ALL programs I pose on these in the future will involve
at least ONE data file off of disk.  If it is a binary one that I have
created for express purpose of these problems, I will be attaching it to
the tutorial message as a binary file attachment.  If its a text file,
I will probably ask you to create it, giving you the format.  If you have
been doing source code, you should be able to use a text file editor.

#### Practice Programming Problem #5
Write a program in Pascal and entirely Pascal which will conduct
a worker-pay recording.  Be sure the program is modular and uses functions
and procedures to the best benefit, as well as efficiently coded (be sure
you are using format codes!).  We will be reading worker names and data
from a file in the current directory with the program named WORKER.TXT.
Format of input and output files will be covered later.  What we will be
doing is figuring out how much to pay each of these employees in our data
file.  Points to keep in mind:

   1) Gross pay is hourly rate * hours-worked for hours worked below 40.
   2) 40 hours of time is full-time pay, beyond 40 hours is time and a half.
      Therefore, we must pay them 1/2 more than we normally would at the
      hourly computed rate for any hours above 40 from point 1.
   3) Income Taxes are 15% of computed gross pay (before taxes, etc).
   4) We must indicate all of these deductions by computations in the output.
   5) We may have 1 employee, we may have 10,000.  We need to give the
      user some indication as to what we are doing (all we will see is
      a blank prompt otherwise.) so they won't think our program has hung
      or crashed.  Write a message such as "Processing <employee name>" to
      the screen for each employee.

Write a report of what our deductions are from each person's salary, and
what we are paying each employee to a file named PAYOUT.TXT.

Format of WORKER.TXT (I recommend you type this in *EXACTLY* and use it)
```txt
Glenn Grotzinger    44.25  7.34
Joe Schmoe          65.32  4.35
Jim Nabors          40.00  10.01
Sheila Roberts      32.12  6.25
Kathy York          23.21  11.10
```

(the area between all the --- is the WORKER.TXT to use.... -- another note:
be sure there aren't any blank lines at the bottom of the file -- those
cause problems...)
First thing on each line is employee name (max of 20 chars).
Second thing is total hours worked.
Third thing is pay rate.

Format of PAYOUT.TXT
```txt
                      The International Widget, Inc.
PayOut And Deductions Sheet

#### Employee              Hours  Rate  GrossPay  Overtime  IncomeTax  NetPay
Glenn Grotzinger      34.25  7.34   345.23     32.34     15.34    305.23
...


```
(The numbers should be correct, and the file should appear sort of like
this, but with more entries (equivalent to the number of entries in the
WORKER.TXT file.  This is only a sample illustration.)

Note:  In any program, you should always make accounts for changes in the
number of lines of text in an input file.  Use EOF.  Do not use a
defined set loop.  Also, as a tip, to get the output the way you want it
to look, it doesn't hurt to type it out as a sample, so you know how to
space it when you go into the programming part of it.

#### Next Time
We will discuss arrays and their usage.  If there is a difficulty in inter-
preting data files for text files, tell me, and I will probably attach them
as binaries in the future.  Please send all comments, inquiries, etc, etc
to ggrotz@2sprint.net.  P.S.  Sorry this one ain't too fun...Couldn't think
of anything better to get you the practice in using text files...

