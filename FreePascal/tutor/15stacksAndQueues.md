## Turbo Pascal for DOS Tutorial
by Glenn Grotzinger
### Part 12: Stacks and Queues
copyright(c) 1995-96 by Glenn Grotzinger

```txt
  Category: SWAG Title: PASCAL TUTORS
  Original name: 0015.PAS
  Description: 15-Stacks and Queues
  Author: GLENN GROTZINGER
  Date: 11-28-96  09:37
```

Solution to part 11's problem....

```pascal
program part11; uses dos;

  { Lists files and data in a ZIP file. }

  type
    ziplocfileheader = record
      zipver: integer;
      bitfield: word;
      compmethod: integer;
      packtime: longint;
      crc32: longint;
      compsize: longint;
      uncompsize: longint;
      filelen: integer;
      xtralen: integer;
    end;

    zipcds = record
      ver: byte;
      hostos: byte;
      verxtr: byte;
      targos: byte;
      bitfield: word;
      compmethod: integer;
      packtime: longint;
      crc32: longint;
      compsize: longint;
      uncompsize: longint;
      filelen: integer;
      xtralen: integer;
      comtlen: integer;
      disknum: integer;
      intattr: integer;
      extattr: longint;
      roffset: longint;
    end;

    endcdsheader = record
      numdisk: integer;
      numdiska: integer;
      numfiles: integer;
      entries: integer;
      size: longint;
      ofs: longint;
      comtlength: integer;
    end;

  var
    zipfile: file;
    outfile: text;
    locfile: ziplocfileheader;
    dirstr: zipcds;
    endcds: endcdsheader;
    filechar: char;
    filelength: array[1..20] of char;
    id: array[1..4] of char;
    i: integer;
    totsize, compsize, uncompsize: longint;
    param1, param2: string;

  { Example structure of a ZIP file.
      localheader1
      loccompresseddata1
      localheader2
      loccompresseddata2
      centraldirectorystructure1
      centraldirectorystructure2
      endofcentraldirectorystructure }

  procedure readzip;

    { ZIP is a random data binary file.  We read the ID to check it, then
      differentiate it from there.  We also devise a test of whether the
      "ZIP file" is a valid ZIP file here. }

    begin
      blockread(zipfile, id, sizeof(id));
      totsize := totsize + 4; { totsize is a seek index }
      if (id[1] <> 'P') and (id[2] <> 'K') then
        begin
          writeln('Corrupted ZIP file, or not a ZIP file.');
          halt(1);
        end;
      case id[3] of
        #05: begin
               blockread(zipfile, endcds, sizeof(endcds));
               totsize := totsize + sizeof(endcds);
             end;
        #03: begin
               blockread(zipfile, locfile, sizeof(locfile));
               totsize := totsize + sizeof(locfile);
             end;
        #01: begin
               blockread(zipfile, dirstr, sizeof(dirstr));
               totsize := totsize + sizeof(dirstr);
             end;
      end;
    end;

  function zero(int: integer):string;
    {places zero on the beginning of a number if it's < 10 }
    var
      strng: string;
      numerr: integer;
    begin
      str(int, strng);
      if int < 10 then
        strng := '0' + strng;
      zero := strng;
    end;

  function strip(str: string):string;

    { removes null characters from random-read filename }

    var
      tstr: string;
      i: integer;
    begin
      tstr := '';
      for i := 1 to length(str) do
        if str[i] <> #0 then
          tstr := tstr + str[i];
      strip := tstr;
    end;

  function exist(filename: string):boolean;
    { file existence test }
    var
      thefile: text;
    begin
      assign(thefile, filename);
      {$I-}reset(thefile);{$I+}
      if IOResult <> 0 then
        exist := false
      else
        begin
          exist := true;
          close(thefile);
        end;
    end;

  procedure header(filename: string);
    { writes header of data }
    var
      s: string;
    begin
      writeln(outfile, 'Files contained in ':41, filename);
      writeln(outfile);
      writeln(outfile, 'NAME', 'COMP-SIZE':21, 'DATE':9,'TIME':12,
              'UNCOMP-SIZE':15, 'COMP-METHOD':13);
      fillchar(s, 75, '-');
      { fillchar fills a set of contiguous bytes of any type defined by
        the position s is in, for x number of spaces (75), with a char-
        acter represented by - }
      s[0] := #74;  { set length byte }
      writeln(outfile, s);
    end;

  procedure footer(compsize, uncompsize: longint);
    { write footer of data }
    var
      s: string;
    begin
      fillchar(s, 75, '-');
      s[0] := #74;
      writeln(outfile, s);
      writeln(outfile, compsize:22, uncompsize:34);
      writeln(outfile);
      writeln(outfile, endcds.numfiles, ' files; Effective compression',
                       ' ratio: ', (compsize / uncompsize)*100 :0:1, '%');
    end;

  procedure writehelp;
    { help for incorrect usage }
    begin
      writeln('ZIPLIST <zipfile> <datafile>');
      halt(1);
    end;

  procedure writedata(locfile: ziplocfileheader);
    var
      dt: datetime;
    begin
      unpacktime(locfile.packtime, dt);
      { this handles the MS-DOS time format }
      writeln(outfile, strip(filelength):12, locfile.compsize:10,
      zero(dt.month):7,'-',zero(dt.day),'-',dt.year,
      zero(dt.hour):6,':', zero(dt.min),
      locfile.uncompsize:10, locfile.compmethod:12);
    end;

  begin
    if paramcount <> 2 then  { incorrect parameters? }
      writehelp;
    totsize := 0;compsize := 0;uncompsize := 0;
    param1 := paramstr(1);
    param2 := paramstr(2);
    assign(zipfile, param1);
    if exist(param1) = false then
      begin
        writeln(param1, ' does not exist!');
        halt(1);
      end;
    reset(zipfile, 1);
    assign(outfile, param2);
    rewrite(outfile);

    header(param1);
    readzip;

    while id[3] = #03 do
     { process local file headers and compressed data }
      begin
        blockread(zipfile, filelength, locfile.filelen);
        compsize := compsize + locfile.compsize;
        uncompsize := uncompsize + locfile.uncompsize;
        writedata(locfile);
        totsize := totsize + locfile.filelen;
        totsize := totsize + locfile.xtralen;
        fillchar(filelength, sizeof(filelength),#0);
        seek(zipfile, totsize);
        totsize := totsize + locfile.compsize;
        seek(zipfile, totsize);
        readzip;
      end;

    while id[3] = #01 do
      { process central directory structure }
      begin
        totsize := totsize + dirstr.filelen;
        seek(zipfile, totsize);
        totsize := totsize + dirstr.xtralen;
        seek(zipfile, totsize);
        readzip;
      end;

    footer(compsize, uncompsize);

    writeln(outfile);

    { handle ZIP comment }
    if endcds.comtlength = 0 then
      writeln(outfile, 'No comment in ZIP file.')
    else
      for i := 1 to endcds.comtlength do
        begin
          blockread(zipfile, filechar, sizeof(filechar));
          write(outfile, filechar);
        end;

    close(zipfile);
    close(outfile);
  end.
```

Hello.  Basically, we are dealing in this part with specialized types of
data structures called stacks and queues.

#### Stacks
A stack is best analagous to a stack of papers on a desk, only able to
either place a sheet on the top of the stack, or take a sheet off the
top of the stack.  It is generally defined as a record format, which
can take on the following:

stack = record
  elements: array[1..maxstacksize] of <whatever>;
  capacity: integer; {range of 0..maxstacksize}
end;

It is best described as a last in/ first out data structure, much like the
sheet of paper analogy.  The elements array holds whatever information
we need, while capacity tells us how many elements are still in the array.

The best description I can use for this and queues is that it's a limited
defined access structure.

I will now describe the basic actions of working with stacks.  The best
way to think about coding this is to use the stack of paper as a view-
point, and using the sample stack record above.

To initialize or effectively kill a stack currently in usage is to set
capacity to 0.  We can do this, because all work with a stack ultimately
comes down to usage of capacity as an index.  If we have 0 sheets of paper
on an imaginary stack, essentially, the stack is empty.

Now, let's add a sheet of paper to our imaginary stack.  We recognize that
there is one more sheet of paper on the stack now.  Then we have to place
that sheet on the stack...also, we have to keep in mind if we have hit our
arbitrarily set limit of sheets on the stack, and notify of such thing.

What now, if we have to remove the sheet of paper from our imaginary stack
of paper?  We would need to check if we had a sheet of paper to remove.
Then after that, we would need to pull the sheet off of the stack, then
recognize that we removed the sheet.

How do we recognize if we have a full stack or an empty stack?  Look at the
value of capacity.  If it's 0, then it's empty.  If it's the value for the
maximum capacity of the stack we decide, then we know it's full.

Basically, in the last four paragraphs, I have, in discussing the actions
of working with stacks, have given you all the pseudocode you need to
be able to come up with the code to work with a stack.

It is basically good to develop all of these components as procedures.
If you come across a problem where a last in, first out solution is
needed, a stack may be the proper way to go.

#### Queues
A queue is set up much like a line at the local shop to pay the merchant
at the cash register.  The first element in is the first element out.
Much like a stack, a queue may be defined as a record format.

queue = record
  elements: array[1..maxqueuesize] of <whatever>;
  front, back: integer;
  count: integer;
end;

Notice that the differences we see here, are that to take from the front
of the so called line we need to know where the front is in the order.
The same idea occurs with the back.  We need to know where the back is
in the array.  Count just helps us in knowing how many values we currently
have in the queue.

To start up a queue, basically, we need to start the front at 1, the rear
at the maximum size, and count at zero.

To check whether it's full or  empty is basically set through count.  Check
count to be zero for a queue to be empty and maxsize for a queue to be full.

One sticky mess comes up when we try to add an element to the back of the
line.  How do we keep track of things?  We increment the back unless it's
maxqueuesize, then we set it to 1, essentially, to continue reusing the
array storage as a loop....

To add to the back of the line, we do like we did with the stack.  We add
the element to the back, then we increment the back count as described
above.

To take from the front of the line, we pull the element from the front of
the queue, and then increment the front count as described above.

Basically, the effect we are getting is much like a message scrolling
across a surface, like you may have seen on your television, and at
Times Square in NY (on several movies).

#### Conclusion
Both of these data storage schemes work beautifully, when you have a lot of
data to deal with that can be passed through quickly, but needs to be
released at other times...beyond that, at this point, I can't think of
anything that can be done by only using a stack or a queue, so my
suggestion for practice is to attempt coding each of these specialized
data types to do simple things.


#### Practice Programming Problem(s) #12
Here are a couple of things for this one.

1) Reverse a string of text inputted from the screen (not necessarily
a string) of a maximum of 500 characters, and output the text back to
the screen.

Sample
------
Enter a string: AbCdE

Your string reversed is: EdCbA

2) Use a queue to store a maximum set of numbers that is 50 numbers long.
These numbers will come from a series of randomly generated numbers by your
program.  The random numbers you will generate are from 1..1000, and
the ones that are from 1..50 will be written out to the screen when the
queue is filled up with those numbers.  Write the numbers in the queue out
in 5 rows of 10, and at the bottom, write out the total number of random
numbers you had to go through to get those 50 numbers in the proper range.

Sample
------
23 23 11 22 33 1 9 12 23 11
23 3 11 22 33 11 9 12 23 11
23 23 11 22 33 11 9 12 23 11
23 29 11 2 33 11 9 12 23 11
23 23 11 22 33 11 9 50 23 11

987 numbers were generated from 1-1000 to get the 50 numbers from 1-50.

#### Next Time
Recursion. (n) See Recursion. :>

Any comments?  Write ggrotz@2sprint.net.

