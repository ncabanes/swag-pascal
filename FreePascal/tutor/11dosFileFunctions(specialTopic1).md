## Turbo Pascal for DOS Tutorial
by Glenn Grotzinger
### Part 8 -- DOS file functions (special topic 1)
All parts copyright (c) 1995 by Glenn Grotzinger

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0011.PAS
  Description: 11-DOS File functions (special topic 1)
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```

Here's a solution to part 7....

```pascal
program part7;

  { demos 2 functions defined in part 7 to be written.  Convert base 10
    to anybase, and convert anybase to base 10 }

  function power(int, ord: integer):longint;
    { support function required for xbase2dec.  Simplistic
      implementation of taking a power. }
    var
      i, endit: longint;
    begin
      endit := 1;
      for i := 1 to ord do
        endit := endit * int;
      power := endit;
    end;

  function dec2xbase(int: longint; base: integer):string;
    { converts base 10 to any base < 37 }
    const
      numguide: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      { the guide string I mentioned as a hint }
    var
      i: integer;
      hold, chkprod1, chkprod2: longint;
      endstr: string;
    begin
      if base > 36 then
        dec2xbase := '!' { a signal character to say our function failed }
      else
        begin
          endstr := '';
          hold := int;
          while chkprod1 <> 0 do
            begin
              chkprod1 := hold div base; { using method described when I }
              chkprod2 := hold mod base; { demoed doing it manually }
              endstr := numguide[chkprod2 + 1] + endstr;
                        { actual representation }
              hold := chkprod1;
            end;
          dec2xbase := endstr;
        end;
    end;

  function xbase2dec(int: string; base: integer):longint;
    { converts any base < 37 to base 10 }
    const
      numguide: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var
      i, powr: integer;
      endresult: longint;
      intlength: integer;
    begin
      if base > 36 then
        xbase2dec := -1 {signal fucntion has failed }
      else
        begin
          endresult := 0;
          i := 1;
          powr := length(int) - 1;
          while i <> length(int)+1 do   { compute back to base 10 }
            begin
              endresult := endresult + (pos(int[i], numguide)-1) *
                           power(base, powr);
              i := i + 1;
              powr := powr - 1;
            end;
        end;
      xbase2dec := endresult;
    end;

  var
    numread, numbase: longint;
    convbase: string;
  begin
    write('Enter a number (base 10): ');
    readln(numread);
    write('What base do you want to convert to? ');
    readln(numbase);
    writeln;
    convbase := dec2xbase(numread, numbase);
    if convbase = '!' then
      writeln('Use a base less than 37')
    else begin
      writeln(numread, ' (base 10) is ', convbase, ' (base ', numbase, ').');
      numread := 0;
  { required setting of initial read var to 0 to prove our functions work }
      writeln('To check: ', convbase, ' (base ', numbase, ') is ',
               xbase2dec(convbase, numbase), ' (base 10).');
    end;
  end.
```

Now on with the show....This is going to be more of a special topics practice
thing.  As a note, all of the commands I use here will require you to use
the dos or windos unit....also, have your TP Programmers Reference handy to
look up several of the basic functions that I will list here.

#### A simple if successful...
How do we check if any of these, or our prior reset/rewrite calls are
successful?  We toggle the I compiler option before a valid file oper-
ator, then we check the variable in IOResult.  If IOResult <> 0, then
we know there is a problem.  For example, how do we check if a file
exists on the drive before we read from it?

function exists(filename: string):boolean;
  var
    ourfile: text; { can be defined to be any type we want }
  begin
    assign(ourfile, filename);  { let the program know about the file }
    {$I-}reset(ourfile);{$I+}   { toggle I, on a reset. Both MUST be there }
    if IOResult <> 0
    { did something go wrong?  With reset, if file did not exist, something
      would be wrong }
      exists := false           { indicate file doesn't exist }
    else  { file exists }
      begin
        close(ourfile); { we need to close the file since if it's there, }
        exist := true;  { we just opened it.  Also, indicate it's there. }
      end;
  end;

This method can be used with any file function like that as long as the
system is aware of the file, to indicate success, possibilities, etc.,
in whatever logical means the command indicates.  For reset, one logically
can say that if something goes wrong with it, the file isn't there, or the
path is invalid.  For rewrite, one logically can say if the path isn't
right or available, or if there's no disk space, or a variety of reasons.

The I compiler directive indicates turning ON or OFF input/output checking.
The default for most compilers is {$I+}.  As compiler directives go, we
must toggle it back, because the area after the change is in effect, and
we only want it for the case of the command we want to check.  If I/O
checking is on, the program would end in a run-time error (you may have
noticed this, if you have tried to access non-existent files in your
experimentation with reading/writing text files). If I/O checking is off
({$I-}, the result of the command is logged in a global variable named
IOResult.

Being able to subvert run-time errors is good to be able to do, especially
for a DOS file function type program, where you even deal with files.
If the user specifies an incorrect file to read, you can return an intel-
ligible, user-understandable error message that the filename they gave
does not exist on the drive.

A list of run-time error possibilities may be found on page 260 of the
TP7 programmers reference.

#### Straight Forward Things
I will list several commands for working with files and DOS
which are relatively straight-forward to use.  Unit used, then command,
then a short description.  Detailed descriptions follow if needed.  I
will mainly cover the DOS unit variants.  If you use TPW, look up the
WinDOS variant equivalents...Be sure to look each of these up in any
case.... By all means, play with each of these to understand them.
Notes on some of these things will appear later.

System: ChDir(Str: string);  { changes the current directory to path in Str }
DOS/WinDos: DiskFree(Drive: byte):longint; { free bytes on Drive }
DOS/WinDos: DiskSize(Drive: byte):longint; { total bytes on Drive }
DOS/WinDos: DosVersion: word; { tells us what version of DOS we have }
DOS: EnvCount: integer; { how many environment strings? }
DOS: EnvStr(index: integer): string; {return a specific environment string}
System: erase(file: filetype);  {erases an external file}
System: FilePos(file: filetype): longint; {returns current position in file}
System: FileSize(file: filetype): longint; {returns a file's size}
DOS: FSearch(filename: PathStr; dirlist: string):Pathstr {search for a file}
DOS: FSplit(...  {split a filename into a dir, name, and ext}
DOS/WinDos: Getdate(... { gets the current date of the operating system.}
System:GetDir(drive; str: string); {gets current directory}
DOS: GetEnv(...  {gets the specified environment variable}
DOS/WinDos: GetFAttr (... { returns file attributes of a file }
DOS/WinDos: GetFTime (... { get the date and time of a file }
DOS/WinDos: GetTime(... { get current time }
System: Halt(code); { quits program immediately with an errorlevel }
System: MkDir(str: string); { makes a directory named str }
DOS/WinDos: PackTime(... { packs a time/date }
System: Rename(file: filetype); { renames an external file }
System: RmDir(str: string); { removes a dir named str }
System: Seek(file: filetype); { finds an element # in a file }
DOS/WinDos: SetDate( ... { sets the date on the machine }
DOS/WinDos: SetFTime(... { sets the date and time of a file }
DOS/WinDos: SetTime(...  { set the time on the machine }
DOS/WinDos: UnpackTime(... { unpacks a time/date to datetime record }

Notes on some of the commands listed above that aren't that self-
explanatory
```txt
Diskfree(Drive: byte): longint;
DiskSize(Drive: byte): longint;
     Drive is a numerical byte: 0 is the current drive.
                                1 is A drive.
                                2 is B drive.
                                3 is C drive.
and so on and so forth.

NOTE: DiskFree and DiskSize are limited from what I understand to < 1 gig?
(Please correct me if I am not quoting this right).  I know there is a
limit there somewhere...

DosVersion(version: word);
     You have to use HI and LO functions here as described in part 7.
     The high order of this expression would be a minor revision number
     and the low order of this expression would be a major revision
     number.  For example, if you have DOS 6.20, the high order would be
     20, and the low order would be 6.

Any expression that uses packed and unpacked date and time.
     There is two of the functions listed above called packtime and
     unpacktime.  There is a special record already defined in DOS
     called DateTime (or TDateTime in WinDOS).  Both of these are defined
     like this:

     DateTime { or TDateTime -- they're the same } = record
        Year, Month, Day, Hour, Min, Sec: word;
     end;
     A packed time is stored as a longint;

Good use of an erase/rename, etc, etc...
     Make a procedure that does the assign, and error checks, then do
     the command, if the command requires the file to be an assigned
     file variable.  For example:

     procedure deletefile(filename: string);
       var
         afile: text; { It can be anything we will find out }
       begin
         assign(afile, filename);
         {$I-}erase(afile);{$I+}
         if IOResult <> 0 then
           writeln('Erasure unsuccessful.');
         else
           writeln(filename, ' has been erased from your drive!');
       end;

Note: This erase command is recoverable by use of an undelete program.
The rewrite is not (all you'll see is a 0 byte file that replaces the
file you rewritten).

#### Parameter Passing
You may have noted that we can get parameters in from the command-
line to some programs we have used, such as PKZIP and PKUNZIP.
We can write and design our programs to do such a similar thing.

Paramcount: integer;  { holds the number of command-line parameters used }
Paramstr(num: integer): string { specific command-line parameter }

An example: Write a text file out to the screen using full error-checking,
and taking the filename from the command-line.  Describes a command-line
parameter describing a single file.

```pascal
program typefile;
  var
    param1, instr: string;
    thefile: text;
  begin
    if paramcount <> 1 then  { if there is not one command-line parameter }
      begin
        { show some help to the user }
        halt(1);    { quit the program right here }
      end;
    param1 := paramstr(1); { corresponds to %1 in batch file processing }
    { always good to do -- found that addressing the function directly as
      a string causes problems }
    assign(thefile, param1);
    {$I-}reset(thefile);{$I+}
    if IOResult <> 0 then
      begin
        writeln('This file doesn''t exist!');
        halt(1);
      end;
    readln(thefile, instr);
    { if the file is there, no need to error check reads, if our logic
      is correct }
    while not eof(thefile) do
      begin
        writeln(instr);
        readln(thefile, instr);
      end;
    writeln(instr);
  end.
```

Now, what if we want to determine a file based on a command-line parameter.
This isn't exactly complete error checking, as we aren't processing whether
the file we specify is a directory or not (EVERYTHING to DOS is a file of
some sort, including a directory, we can't exactly TYPE a directory...).
That was a demo of picking up command-line parameters, here's how we
process a filename parameter so we are addressing the correct thing,
EVEN a directory, and series of files (Remember wildcards in DOS?  The
usage of * and ? in specification of files).

We use Fexpand, Fsplit, and GetFattr with doing this, as well as some DOS
defined constants which distinguish between different attributes of files.
They are additive, BTW.

     File Attribute Constants
     ------------------------
        ReadOnly       $01
        Hidden         $02
        System File    $04
        Volume ID      $08
        Directory      $10
        Archive        $20
AnyFile        $3F

Look at the DOS dir command for an example.  Vary what you type in,
including directory names, and variants (.., \, and just a dirname).
See how it acts.  That's what we want to emulate.  I will lead in
to part 9 by placing something used in planning called pseudocode
here to do such a thing.

EXPAND FILENAME ON COMMAND LINE TO FULL DIR, NAME, AND EXTENSION.
IF THE END OF THE FILENAME DOES NOT HAVE A \ THEN
    GET FILE ATTRIBUTE.
    IF NO DOSERROR AND THE FILE IS A DIRECTORY
       ADD A \ TO THE END OF THE FILENAME.
END-IF.
SPLIT FILENAME INTO PROPER DIR, NAME AND EXT.
IF NO NAME, THEN PLACE A * THERE.
IF NO EXTENSION, THEN PLACE A .* THERE.
FULL FILENAME = DIR, NAME, AND EXTENSION TOGETHER.

You will have to interpret this into viable code for the programming
problem at the end of the part.

#### Listing a Sequence of Files
Now, to answer the question, what if we want to actually do something
with multiple files (specified with * and ?), instead of just one file
(if we want just one file, if we do the i/o checking on reset or
rewrite, we will get an error if they use * or ? in the name.).

We need to define the usage of a record as a searchrec type for DOS
(or TSearchRec for WinDos).

      searchrec = record
         fill: array[1..21] of byte;
         attr: byte;       { additive from the file attribute constants }
         time: longint;    { Packed Time }
         size: longint;    { Size of file }
         name: string[12]; { name of file }
      end;

This record, as well as DateTime is defined in the DOS unit, and we don't
NEED to define these in our programs...They are used with the FindFirst
and FindNext procedures, which are demoed below, listing all filenames
in the current directory.

```pascal
program tutorial19; uses dos;
  var
    fileinfo: searchrec;
  begin
    findfirst('*.*', $37, fileinfo);
    while doserror = 0 do         { 18 = no more files }
      begin
        writeln(fileinfo.name);
        findnext(fileinfo);
      end;
  end.
```

As a note: . and .. are filenames.  . is the base of the file system, ..
is the next directory up....

#### Executing a Program
You can execute a program from your program by using the exec procedure.
You also have to use the $M compiler directive.  It's a directive to
determine the stack size, as well as the minimum and maximum heap size.
You must set this for to get the memory to run the program.  The format
of the $M compiler directive is this:

  {$M <stacksize>,<minheapsize>,<maxheapsize>}

If you don't set this, maxheapsize defaults to all of your conventional
memory, definitely not good if we want to give the memory to a program
to even run (nothing will happen if the program doesn't have the memory
to run).  For example, we will use {$M $4000,0,0}.  Here is the format
of the EXEC command.

  exec(<command interpreter path>, <command>);

command interpreter path -> Where is COMMAND.COM?  We can use getenv
to get the environment variable named COMSPEC to get this.  I've had
people try to rebunk me to say that you could just say exec(<command>);.
It DOES NOT WORK! (the compiler says something about expecting a ,.
You must do it this way!) -- I'm only trying to head off this issue.

command -> This must be /C + whatever command you call....

Another command used in combination with this is called swapvectors.
It is a parameterless procedure which makes sure our program we call
doesn't literally stomp all over anything we may have done with the
system.  We call it before and after our exec procedure.

Here's an example:

{$M $4000,0,0}
```pascal
program tutorial20; uses dos;
  var
    command: string;
  begin
    write('Enter a DOS command: ');
    readln(command);
    command := '/C' + command;
    { we must put the /C there to satisfy COMMAND.COM }
    swapvectors;
    exec(getenv('COMSPEC'), command);
    swapvectors;
    if doserror <> 0 then
      writeln('Dos Error ', doserror, ' occurred.')
    else
      writeln('Successful shell to DOS.');
  end.
```

Use DosExitCode in addition to doserror to determine the results of the
exec'd procedure.  This function returns a word, which we have to use
the HI and LO functions on.  LO code results correspond to errorlevel
returned out of DOS (remember batch file programming?).  A list of HI
code results follow:

            0       Normal Termination
            1       Terminated by Ctrl+C
            2       Terminated by Device Error
            3       Terminated as a TSR.

#### Conclusion
We have covered the major issues in DOS file commands, as well as
listing some of the straight-forward commands that are in Pascal
to work with DOS.  If you looked those up, you would have found that
most of those things are pretty straight-forward.  Here is a practice
programming problem that duplicates the function of the DIR command
in DOS, showing us files with specified information.  It will be a
clone with different functions, though.  Let us see....

#### Practice Programming Problem #8
Write a program in Pascal and entirely Pascal that will show
us a listing of all files in a directory given on the command-line.
It should also support command line parameters that change function,
such as '/?' and '/P'.  Those are the two command-line parameters that
we should support (be sure we make it case insensitive).  /? or -?
will show us help and a listing of who wrote the program and then
terminate the program.  /P or -p should make it so we pause the screen
output on each page.  It also should handle any error-checking that
it may need to perform as presented in this part.

Functions:
1) Show us for each filename on one line, a size, file attributes, date
and time.
2) For the whole listing of files, show us: The volume label, Size of the
drive we listed, bytes free on the drive we listed, total number of
files listed, total number of directories listed, and DOS version that
is being used at the current time.
3) All integers or longints > 999 should be delinated by commas, or
periods, whatever you use.
4) Write r for read-only, a for archive, s for system, h for hidden.
Put the proper ones that apply by each file that it lists.
5) For reading command-line parameters, be sure to make the order
non-specific.  For example, MYDIR c:\windows /p and MYDIR /p c:\windows
should accomplish the same thing, viewing the windows directory with
page pausing.

Hints:
1) If a file with a volumeID attribute exists in the main directory of
a drive, the name of the file is the volumeID of the drive.
2) Work with the number as a string and go from the right end to the
left end to place commas as strings for function point 3.
3) You may want to use a designed record type to hold the final data
you are going to write as you go obtain it to make things easier.
4) This DIR listing command you are writing should function from the
command-line with regards to filespec exactly like the DOS dir
command.  Check this one by playing around with the DOS dir command.
5) Hint for the #5 function.  Hold the parameter strings in an array
and write some code to differentiate between command-line params and
the actual path you want to view.
6) For the string with the attributes, build your string.  You can
directly address and build a string with certain portions as long
as you start with a valid length of something.  I will explain this
in the next part.

Sample output for yourdir command.
```
C:\>mydir /?

MYDIR (c) 1996 by Glenn Grotzinger.  { put your name here, of course }

Help:
  MYDIR <filespec> /<parameters>
  filespec is the filename/dirname(s) we want to list.
  parameters are ? or P
       ? --> this help.
       P --> pause on each screen page.

C:\>mydir

MYDIR (c) 1996 by Glenn Grotzinger.

File listing for: C:\*.*

.                                                  [DIR]
..                                                 [DIR]
CONFIG.SYS              122    12-12-95    03:45pm  rash
DESCRIPT.ION            182    12-28-95    12:14am  -a--
ARCHIVE.ZIP      14,432,322    03-24-93    09:15pm  r--h

Volume label:          Total files: 3      Total dirs: 2
DOS Version: 6.22

14,432,626 bytes.
214,232,123 bytes used out of 543,212,123 total bytes.

You get the general idea....BTW, for me, this one is 310 lines..
The next practice program given will be in part 10.  This one
and the one in part 10 will be the longest and probably most
complex ones in the whole set of pascal tutorials.  It would be
good for ANYBODY who wants the practice to do these.

#### Next time
We will do the first part of the tutorial covering applications
development.  In doing that, we will develop this DIR equivalent
that I posed above.  Do practice, though, and do this one.  Any
comments, questions, etc, may go to ggrotz@2sprint.net.

