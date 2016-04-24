(*
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0012.PAS
  Description: 12-Applications Development
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
*)

                        Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
                     Part 9 -- Applications Development
             All parts copyright (c) 1995-6 by Glenn Grotzinger

Hello.  This time, I'm not going to go present the solution to part 8
immediately, because I want to sue the part 8 problem to demonstrate
applications development.  The basic reason I'm doing this is because
programs should be designed and then programmed, normally, and not the
other way around.  Normally in design, we have different tools available
for us to use.  The ones I'm aware of are pseudocode and flowcharting.
I can't cover flowcharting through text, but I can cover pseudocode.

What is pseudocode?
===================
Pseudocode is basically English-like descriptions of what is going on.
I gave you an example of it in part 8 (with capital letters for emphasis,
as I will continue to do so) as it pertains to a good line parsing
function.  We will go through and design a solution to part 8 in this
part.

How to start out?
=================
It is good to start with the global way of things.  Let's start with a
few facts we know from our knowledge from part 8.

        1) We're wanting listings of files.
        2) We're wanting stats on the operating system as well as the
           drive we access.

Knowing our purposes in these two statements, we know we need usage of
the DOS or WinDOS unit.

Globally, by looking at the way we know the output needs to be, we can
figure out that globally, the program is going to have to do the
following:

        1) Write the ID of the program. {mydir by...}
        2) Parse the command-line to determine what needs to be done.
        3) Write resultant headers based on results in 2.
        4) If successful, while there are valid files, list the files
           as dictated in 2.
        5) Show the global drive and operating system stats.

Starting to break down the global stuff and writing pseudocode
==============================================================
We know this is the basic idea of things that we will have to do in
order to complete this program.  We need to move from this down to
the specific details.  Let's start with 1.

We need to write the ID of the program (Global 1).
--------------------------------------------------
Also, we need to look at factors for initialization code.  We need
some filespec variable clear...Also we know we need to count files
and dirs, as well as set a pause flag to our default (false).

        PROCEDURE WRITEID;
           WRITE PROGRAM NAME AND AUTHOR NAME, COPYRIGHT INFO...
           SET PAGE COUNT TO # OF LINES USED (page pausing!)
        SET PAUSE TO FALSE, AND SET #DIRS AND #FILES TO 0.

Parse the command-line (Global 2).
----------------------------------
I will start globally, and move down to specifics here.  Keep in mind
that the functions said that path/filename and parameter should be
interchangeable (Function 5 as specified in the problem).  Here, what
seems logical is to use the most definable command-line parameter and
eliminate things down to the least specific.  Here, the command params
? and P are the most specific while the path is the least specific.

        IF PARAMETERS > 2 THEN SHOW SOME HELP AND QUIT.
        PULL ALL PARAMETERS INTO AN ARRAY (MAX 2).
        FOR EACH PARAMETER GIVEN TO PROGRAM IN ARRAY
         IF THE PARAMETER IS 2 CHARACTERS LONG AND THE
           FIRST CHARACTER IS - OR /
             IF SECOND CHARACTER OF PARAMETER IS ? SHOW SOME HELP AND QUIT.
             IF SECOND CHARACTER IS P, SET A PAUSE FLAG TO TRUE.
               ELSE SHOW SOME HELP AND QUIT.
             END-IF.
         ELSE SET FILESPEC TO THE COMMAND-LINE PARAMETER.
         END-IF.
        PARSE THE FILESPEC.

Now, this is a general description of what's going on in part 2 of our
global listing we made.  Now for specifics here.  The only ones I see
are showing the help and quitting, and parsing the filespec.

Show help and quit.
        WRITE THE HELP.
        SET PAGE COUNT TO NUMBER OF LINES USED (Page count for pause!)
        HALT THE PROGRAM.

Parsing the filespec.  I gave you this pseudocode in part 8.

Write resultant headers based on 2. (Global 3)
----------------------------------------------
        WRITE THE HEADER WITH PARSED PATH INTERPRETATION.

List files as dictated by filespec in 2. (Global 4)
---------------------------------------------------
We know, basically, in the DIR implementation we want to list all files
except ones with the volume lables.  We know the file constants are
additive but to ease things in typing, we can go ahead and add them up.
All files except volumeID in the constants is equal to $37.  Also, we will
keep in mind the following points that were brought up in the directions.

        1) (Function 1) Show us for each filename on one line a size,
           file attributes, date and time.
        2) (Function 3) All integers or longints > 999 should be
           delineated by commas, or periods, whichever you use.
        3) (Function 4) Write r for read-only, a for archive, s for
           system, and h for hidden.
        4) If we need to pause, be sure to implement it!
        5) Be sure to indicate if there are no files.

        START FILE LISTING.
        WHILE WE STILL HAVE FILES
           IF A FILENAME IS A DIRECTORY ($10) THEN
              WRITE DIRECTORY NAME WIHT [DIR] DESIGNATION.
              INCREMENT # OF DIRS BY 1.
           ELSE
              WRITE FILENAME, FILESIZE, DATE, TIME AND ATTRIBUTES.
              INCREMENT # OF FILES BY 1.
              INCREMENT SIZE OF FILES IN DIR BY SIZE OF THIS FILE.
           END-IF.
           INCREMENT PAGELENGTH BY 1.
           IF PAGELENGTH > 23 AND PAUSE IS TRUE
              WRITE PAUSE INDICATOR, READ FOR KEY, AND SET LINE
              COUNTER BACK TO 0.
           END-IF.
        IF THERE IS A DOS ERROR OR THERE ARE NO DIRS AND NO FILES
           WRITE THAT THERE ARE NO FILES THERE.

There's our global listing for part 4.  Now we need to consider the
individual actions, basically, obtaining numbers with commas, the date,
the time, and the file attributes.

Numbers with commas (Code explained later)
        MAKE A STRING OUT OF THE NUMBER.
        FIND LENGTH OF NUMBER.
        WHILE THERE ARE MORE THAN 3 DIGITS TO CONSIDER
             COUNT OFF 3 DIGITS FROM THE RIGHT TO THE LEFT.
             PLACE A COMMA, AND SUBTRACT 3 DIGITS FROM LENGTH TOTAL.
        END-WHILE.
        COUNT OFF REST OF DIGITS.

The date and time.  Basically, the issue here is pulling the information
for the date, except the year, where we must consider the last 2 digits
instead of 4 digits.  In getting the last 2 digits, we also need to keep
in mind that the year 2000 will be coming in 4 years...  With the
time, it will be in military time, so we may recycle code, say from part
4 (It is always good to save code and copy so you do not have to
invent the wheel and then turn around and invent it again...:)).  Note
the repeated appearances of the strings "Make XXX a string." and "If
XXX < 10, pad number with zero."  To pad a number, I mean, if I have
9, then padding it with a zero would make it 09.  In good programming
planning, if repeated code happens, isolate that code as a function or
procedure to save lines of code.  AT the end, you will see that I have
done that.

        UNPACK THE DATE AND TIME FROM THE SYSTEM.
        MAKE MONTH A STRING.
        IF MONTH < 10, PAD NUMBER WITH 0.
        MAKE DAY A STRING.
        IF DAY < 10, PAD NUMBER WITH 0.
        IF YEAR > OR = 2000
           2YEAR IS YEAR - 2000
        ELSE
           2YEAR IS YEAR - 1900
        MAKE 2YEAR A STRING.
        IF YEAR < 10, PAD NUMBER WITH 0.
        FINAL-FILE-DATE IS MONTH-DAY-2YEAR.
                          (or DAY-MONTH-2YEAR, whichever you prefer)

        IF HOUR > OR = 12
           HOUR IS HOUR - 12
           MERIDIAN IS PM.
        ELSE
           MERIDIAN IS AM.
        END-IF.
        IF HOUR = 0 THEN HOUR = 12.
        MAKE HOUR A STRING.
        IF HOUR < 10, PAD STRING WITH 0.
        MAKE MIN A STRING.
        IF MIN < 10, PAD STRING WITH 0.
        TIME IS HOUR:MINmeridian.

Get file attributes.  I gave hint #6 for this part to build your string
and said I'd explain later.  A string in pascal (a pascal string),
actually is stored using length + 1 bytes.  The first byte is a number
representing the total length of the string.  The rest of it is the
string.  Since we use a background of -'s, that's all we need to start
the string from...Then use proper position to assign things...and again
using the file attribute constants, remembering that they are additive.
Starting from the largest to smallest...Say, we want to reassign the
3rd character of STR, we just say str[3] := 's' ro something like that.

        SET STRING TO ----.
        IF FILEATTR >= $20 THEN
           FILE HAS ARCHIVE BIT.
           FILEATTR = FILEATTR - $20.
        END-IF.
        IF FILEATTR >= $04 THEN
           FILE HAS SYSTEM BIT.
           FILEATTR = FILEATTR - $04.
        END-IF.
        IF FILEATTR >= $02 THEN
           FILE HAS HIDDEN BIT.
           FILEATTR = FILEATTR - $02.
        END-IF.
        IF FILEATTR >= $01 THEN
           FILE HAS READ-ONLY BIT.
           FILEATTR = FILEATTR - $01.
        END-IF.

Show the global stats and operating system info (Global 5)
----------------------------------------------------------
Basically, this is a write operation.  But we need to know how to get
the information...

Volume label.  Using the hint in the problem.

        SEARCH FOR FILE WITH VOLUMEID ATTRIBUTE IN ROOT DIR OF
           DRIVE WE ARE ACCESSING.
        IF THE FILE EXISTS, FILENAME IS THE VOLUMEID
        ELSE LEAVE IT BLANK.

Total files and total dirs and total size of the files listed are
simply writing variables (be sure to run these numbers through the
comma delineator function).

Total size used on drive.  The drive is designated as a number, and the
nice thing about our pase_filespec thing is that the first character
always ends up being the drive letter of the drive we want to work with.
So, to go from drive letter to number, we can always set a constant
guide string (sort of like my suggestion in part 7 to do this for bases
> 11 as to ease things) defined as: ABCDEFGHIJKLMNOPQRSTUVWXYZ.  I know
this is probably overkill, but it will cover things OK so we don't have
to write a large case statement.  Run this one through the delineator.

        DRIVE NUMBER IS LETTER POSITION IN CONSTANT STRING.
        FREE-ON-DISK FOR DRIVE NUMBER.

Total size on drive.  Similar to total siz eused.  Uses constant guide
string...also ran through delineator.

        DRIVE NUMBER IS LETTER POSITION IN CONSTANT STRING.
        TOTAL-ON-DISK FOR DRIVE NUMBER.

DOS version.  Getting this is exactly like described in part 8.  Nothing
out of the ordinary.

This finishes up my pseudocode description for the part 8 problem.  Now,
for my best solution that I could come up, with the suggestion (probably
could be faster if I didn't do it, but I went ahead and used the save
format for the record as some help, and allowed for 999,999,999 as a
possible total file size in the layout -- too big to really worry, though
it probably slows it up a little...)

Keep in mind too, that this pseudocode was revised, after I found out that
some of my original statements turned out to be wrong in my logic planning.
It's OK to create incorrect pseudocode.  It is only a planning tool, and
does not have to be correct.  The only thing anyone will really care about
being correct is your final source code -- correct meaning that it works
properly.

The source code for my implementation of MYDIR.

program part8; uses dos;

  { a dir command.  Supports command params /? and /P.
    shows filename, filesizes with commas, time, date, attributes.
    For total, shows drivesize in bytes, bytes used on drive.
    Volume label of drive, total number of files, total numbers of
    directories. }

  type
    writerec = record     { format to write out the dirinfo }
      filename: string[12];
      filesize: string[11]; { largest size => 999,999,999 bytes }
      filedate: string[8];
      filetime: string[7];
      fileattr: string[4];
    end;

  var
    dirinfo: searchrec;
    writeinfo: writerec;
    params: array[1..2] of string;
    i: integer;
    pause: boolean;
    filespec: string;
    dirs, files, totalsize: longint;
    pagelen: integer;

  function parse_filespec(filename: string):string;

    const
      all_files = $37;
      { all file constants in base 16 added together but VolumeID }
    var
      dir: dirstr;   { required types for some of the commands as }
      name: namestr; { defined in the DOS unit. }
      ext: extstr;
      attr: word;    { attribute must be a word. }
      f: text;       { required for a command we had to assign file for }

    begin
      filename := fexpand(filename);  { expand filename }
      if filename[length(filename)] <> '\' then { if end not \ }
        begin
          assign(f, filename);
          getfattr(f, attr);            { get the file attribute }
          if (doserror = 0) and (attr = $10) then
            filename := filename + '\'; { if it's a directory put \ }
        end;
      fsplit(filename, dir, name, ext); { split filename up. }
      if name = '' then name := '*'; { if it's still a directory, }
      if ext = '' then ext := '.*';  { specify ALL FILES }
      parse_filespec := dir + name + ext;  { re-form filename }
    end;

  function zero(innum: integer):string;
    var
      tstr: string[2];
    begin
      str(innum, tstr);
      if innum < 10 then
        tstr := '0' + tstr;
      zero := tstr;
    end;

  procedure showid;
    begin
      writeln('MYDIR (c) 1996 by Glenn Grotzinger.');
      writeln;
      pagelen := pagelen + 2;
    end;

  procedure writeheader(filespec: string);
    begin
      writeln('File listing for: ', filespec);
      writeln;
      pagelen := pagelen + 2;
    end;

  function number(n: longint):string;
    var
      i, j: integer;
      s, r: string;
      m: integer;
    begin
      str(n, s); { get the longint to a workable string }
      r := '';   { r is a holding string for our delineated number }
      i := length(s);
      { set an integer to the length of our number.  We will be going
      from the right end and moving to the left in placing our delin-
      eations, and building r from the right to the left. }
      if i > 3 then begin
      while i > 3 do   { while we don't have 3 numbers left }
        begin
          for j := i downto i-2 do  { count off 3 digits and move to r}
            r := s[j] + r;
          r := ',' + r;  { write a comma or period to r }
          i := i - 3;    { subtract 3 digits }
        end;
      for j := i downto 1 do
      { we only have 3 digits left, or less now.  Just count off the
        digits }
        r := s[j] + r;
      number := r;  { feed r to the function }
      end
    else
      number := s;
    end;

  procedure getdatetime(dirinfo: searchrec; var writeinfo: writerec);
    { type uses datetime record }
    var
      dt: datetime;
      a,b,c: string; { temp strings for use }
      tmpyr: integer; { we need to define this one to do the year }
    begin
      unpacktime(dirinfo.time, dt); { unpack date and time }
      { start with date }
      { month }
      a := zero(dt.month);
      { day -- same as month }
      b := zero(dt.day);
      { year -- reported as 4 digits.  We need to get it down to 2. }
      { keep in mind the valid range that TP will report year. }
      if dt.year > 1999 then      { if year 2000 or above }
        tmpyr := dt.year - 2000
      else                        { else would be before 2000 }
        tmpyr := dt.year - 1900;
      { now that we have our last 2 digit year, perform similar to day
        & month }
      c := zero(tmpyr);
      writeinfo.filedate := a + '-' + b + '-' + c; { set final date }
      { now start with the time -- it's reported as military time --
        we need to deal with it as such }
      { military time determination }
      if dt.hour >= 12 then
        begin
          dt.hour := dt.hour - 12;
          c := 'pm';
        end
      else
        c := 'am';
      if dt.hour = 0 then
        dt.hour := 12;
      { hours -- deal with as we did days now }
      a := zero(dt.hour);
      { minutes }
      b := zero(dt.min);
      writeinfo.filetime := a + ':' + b + c;
    end;

  function getfileattr(dirinfo: searchrec):string;
    var
      left: word;
      str: string;

    begin
      str := '----';
      left := dirinfo.attr;
      if left >= $20 then  { archive file }
        begin
          str[2] := 'a';
          left := left - $20;
        end;
      if left >= $04 then  { system file }
        begin
          str[3] := 's';
          left := left - $04;
        end;
      if left >= $02 then  { hidden file }
        begin
          str[4] := 'h';
          left := left - $02;
        end;
      if left >= $01 then  { read-only file }
        begin
          str[1] := 'r';
          left := left - $01;
        end;
      getfileattr := str;
    end;

  procedure writefinfo(dirinfo: searchrec;writeinfo: writerec);
    var
      i: integer;
    begin
      with writeinfo do
        begin
          filename := dirinfo.name;
          filesize := number(dirinfo.size);
          getdatetime(dirinfo, writeinfo);
          fileattr := getfileattr(dirinfo);
          write(filename);
          for i := length(filename) to 12 do
            write(' ');
          writeln(filesize:12, filedate:12, filetime:12, fileattr:12);
        end;
    end;

  function getvolumeID(drive: char):string;
    { volume label exists as a file in the root directory with a special
      attribute called VolumeID and the name of the file is the volume
      label }
    var
      fstr: string;
      dinfo: searchrec;
    begin
      fstr := drive + ':\*.*';
      findfirst(fstr, VolumeID, dinfo);
      if doserror = 0 then  { Volume label exists so...}
         getvolumeID := dinfo.name
      else
         getvolumeID := ''; { leave it blank if no volume label }
    end;

  procedure showhelp;
    begin
      writeln('Help:');
      writeln('  MYDIR <filespec> /<parameters>');
      writeln('  filespec is the filename/dirname(s) we want to list.');
      writeln('  parameters are ? or P (case insensitive)');
      writeln('       ? --> This help.');
      writeln('       P --> pause on screen page.');
      halt(1);
   end;

  function bytesfree(drive: char):longint;
    const
      guide = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var
      dno: integer;
    begin
      dno := pos(upcase(drive), guide);
      bytesfree := diskfree(dno);
    end;

  function bytesthere(drive: char):longint;
    { in TP, this won't work if you have a partition > 1 gigabyte }
    const
      guide = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    var
      dno: integer;
    begin
      dno := pos(upcase(drive), guide);
      bytesthere := disksize(dno);
    end;

  begin
    { initialization code }
    showid; { should be the first thing we do }
    pause := false;
    filespec := '';
    totalsize := 0;
    dirs := 0;
    files := 0;
    { check # of parameters }
    if paramcount > 2 then
      showhelp;
    { pull in parameters }
    for i := 1 to paramcount do
      params[i] := paramstr(i);
    { check 'em for ? and P parameters, and filespec }
    for i := 1 to paramcount do
      if (length(params[i]) = 2) and
         (params[i][1] in ['-','/']) then
         case upcase(params[i][2]) of
           '?': showhelp;
           'P': pause := true;
         else
           showhelp;
         end
      else
        filespec := params[i];
    filespec := parse_filespec(filespec);

    { go into start }
    writeheader(filespec);
    findfirst(filespec, $37, dirinfo);
    while doserror = 0 do
      begin
        if dirinfo.attr = $10 then
          begin
            write(dirinfo.name);
            for i := length(dirinfo.name) to 12 do
              write(' ');
            writeln('[DIR]':49);
            inc(dirs);
          end
        else
          begin
            writefinfo(dirinfo, writeinfo);
            inc(files);
            totalsize := totalsize + dirinfo.size;
          end;
        inc(pagelen);
        if (pagelen > 23) and (pause) then
          begin
            write('--Pause--');
            readln;
            pagelen := 0;
          end;
        findnext(dirinfo);
      end;
    if (doserror in [1..17]) or ((dirs = 0) and (files = 0)) then
      writeln('No files found.');
    writeln;
    writeln('Volume label: ', getvolumeid(filespec[1]), 'Total Files: ':20,
             number(files), 'Total Dirs: ':20, number(dirs));
    writeln('DOS Version: ', lo(dosversion), '.', hi(dosversion));
    writeln;
    writeln(number(totalsize), ' bytes.');
    writeln(number(bytesfree(filespec[1])), ' bytes free out of ',
            number(bytesthere(filespec[1])), ' total bytes.');

  end.
Next Time
=========
We will cover reading and writing from binary files in part 10, as well
as use of units, overlays, and include files in programming.  Part 10
will be a long program, which will stress the ideas represented here
mainly, but will also involve material in part 10.  It will be a tedious
one, but does not require a lot of programming knowledge to complete.
This problem will also be set up for a programming contest.  If there
are any comments, please write ggrotz@2sprint.net.

