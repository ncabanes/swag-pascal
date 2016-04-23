                        Turbo Pascal for DOS Tutorial
                             by Glenn Grotzinger
            Part 11 -- data representation; reading specs sheets
                  copyright (c) 1995-96 by Glenn Grotzinger

Is there still any interest in this tutorial?  If so, tell me! :>

Here is a solution to last chapter's problem.  Here is the unit.

UNIT10

{$O+}
unit unit10;

interface
  uses dos;
  function parse_filespec(filename: string):string;
  procedure copyafile(inname, outname: string);
  procedure writehelp;
  procedure process;

implementation

function parse_filespec(filename: string):string;
    const
      all_files = $27;
    var
      dir: dirstr;
      name: namestr;
      ext: extstr;
      attr: word;
      f: text;
    begin
      filename := fexpand(filename);
      if filename[length(filename)] <> '\' then
        begin
          assign(f, filename);
          getfattr(f, attr);
          if (doserror = 0) and (attr and $10 > 0) then
            filename := filename + '\';
        end;
      fsplit(filename, dir, name, ext);
      if name = '' then name := '*';
      if ext = '' then ext := '.*';
      parse_filespec := dir+name+ext;
    end;

  procedure copyafile(inname, outname: string);
    var
      infile, outfile: file;
      buffer: array[1..8192] of byte;
      bytesw, bytesr: integer;
      time: longint;
      attribute: word;

    begin
      assign(infile, inname);
      getfattr(infile, attribute);
      reset(infile, 1);
      write('Copying ', inname, ' (', filesize(infile), ' bytes)...');
      assign(outfile, outname);
      setfattr(outfile, attribute);
      rewrite(outfile, 1);
      repeat
        blockread(infile, buffer, sizeof(buffer), bytesr);
        if bytesr > 0 then
          blockwrite(outfile, buffer, bytesr, bytesw);
      until bytesr = 0;
      getftime(infile, time);
      setftime(outfile, time);
      close(infile);
      close(outfile);
      writeln('done...');
    end;

  procedure writehelp;
    begin
      writeln('Provide a source and a destination.');
      halt(1);
    end;

  procedure process;
    begin
      if paramcount <> 2 then
        writehelp;
      copyafile(parse_filespec(paramstr(1)), parse_filespec(paramstr(2)));
    end;

end.
And here is the main program

program part10; uses unit10, overlay;


  {$O UNIT10.TPU}


  begin
    ovrinit('PART10.OVR');
    if OvrResult <> 0 then
      begin
        case OvrResult of
          -1: writeln('Overlay manager error.');
          -2: writeln('Overlay file not found.');
          -3: writeln('Not enough memory for Overlay Buffer.');
          -4: writeln('Overlay I/O error.');
        end;
        halt(1);
      end;
    OvrInitEMS;
    case OvrResult of
      0: writeln('Overlay loaded to EMS memory!');
     -5: writeln('No EMS driver found! Loading to conventional.');
     -6: writeln('Not enough EMS memory!');
    end;
    process;
  end.


Basically, the plan for this tutorial is to go through all standard data
types and show how TP stores them in memory, so we will be able to interpret
a binary data file we may create.  Then, using the information we presented
on how things are stored, we will get a spec sheet on a common format, and
interpret the data, so we may be able to obtain data from that file through
a Pascal program.

Byte
====
The basic idea of a byte has been covered in part 7 of the tutorial.
Please refer back to there for a refresher on the concept of what a byte is.

Basically, a byte can be used to substitute or represent a char type,
or a number type....The number types, stored as a byte, have a limit of
0..255 as an unsigned number (byte), and -128..127 with a signed number
(shortint).  The terms in the parentheses are what we would define the
byte to be to get the specified range.  I will explain later in this
tutorial the difference between a "signed" and "unsigned" number, actually
signed and unsigned data space for numbers.

The number for an unsigned number is formed, much like we were doing the
binary computations in part 7.

Numbers as Integers
===================
There are several types of numbers we can define...

Byte, and ShortInt: as described above in the byte description...

Integer types are either as signed (range: -32768..32767) or unsigned
(0..65535) words.  A word is a unit of 2 bytes in TP.  Basically, in
a unsigned integer, the number is calculated from right to left in binary
much like a byte.  Since it is easier, for us to show binary storage
repsentation as hexadecimal units of bytes, we will use hexadecimal values
for an example.

An integer type is written to disk, to test something.  The sequence of
two bytes is:  3F 4D  .  What is the number in base 10 form?

If we remember from our hex notation, and the way things work:

   3 * 16^3 + 15 * 16^2 + 4 * 16^1 + 13 * 16^0 = 16205

An integer is ALWAYS two bytes, whether or not the number may technically
fill two bytes in this manner described before.  For example, 13 in base
10 is stored in memory and on disk by TP in integer form as 00 0D .  We
could equally store this number as a byte if we knew that this variable
location would never be requested to hold a number that is greater than
255.  For example, if we knew we were going to hold days of the month
in memory, we would never have a number greater than 31, so a byte type
for this number would be appropriate.

A longint type is always a signed number, but we do need to know, that
it is what is called a double word, or two words put together.  Therefore,
we know that a longint type is 4 bytes, and has a maximum limit of 2bil.
A longint is ALWAYS 4 bytes, whether or not the number may fill 4 bytes.
13 in base 10 would be stored in a longint as 00 00 00 0D .

Char
====
A character is stored in memory as a byte, with the byte value
representing the corresponding character as it refers to the
ASCII chart.

byte representation 67 as a char is C.

Signed vs. Unsigned Integer Numbers
===================================
We have talked before in this part about signed and unsigned numbers.  In
part 7, essentially, we have covered unsigned numbers, when we were
describing binary logic.  Let's describe what a signed number is.

A signed number is represented by either using a base system of 0..1, or
1..0 in binary.  In a signed number, the leftmost bit is either 0 for a
positive number, and 1 for a negative number.  For positive numbers, the
remaining bits are considered using a 0..1 scheme as we did in part 7
with the binary computations.  For a negative number, we count starting
from 1 and go down to 0.

Let's observe what that difference is, by demonstrating how 3 and -3 would
be shown in a shortint (signed) type in binary.

Let's start with 3 in binary as a signed number. That is a positive number
so the leftmost bit will be 0.  Then we will use a 0..1 counting system
to finish out the number using standard binary notation.  So, 3 will be
represented in a shortint value as:

                             0000     0010 

just like it was an unsigned number.  Now, lets observe what -3 would look
like.  That is a negative number, so the leftmost bit would be a 1.  Since
we use a 1..0 system, we would start with 1's in everything.  We know 3 is
10 in binary, so we use a reverse system and come up with:

                             1111     1101

To illustrate further, in binary counting (to a computer) -1..-5 would be
(represented in hex) as $FF,$FE,$FD,$FC,$FB; as opposed to $01,$02,$03,
$04,$05 for 1..5 .  In a signed system, negative number counting starts at
-1, which explains why the equal range of a shortint is -128..127, and
there are equally 128 items (positive and negative).

As practice, look at the integers.dat now, in a hex viewer, and see exactly
how the numbers are stored.  They are two bytes in length, and should count
from one to ten, as we did in the program.  It should look like this in
your hex viewer....

00 01 00 02 00 03 00 04 00 05 00 06 00 07 00 08 00 09 00 0A

I recommend very heavily that you get a hex viewer to be able to help out.

Boolean
=======
0 = False; 1 = True

Common Pascal Strings
=====================
Now we will start to discuss the format of grouped data.  The first format
we will discuss will be the common pascal string.  The format of a pascal
string formatted group of characters is the following.

When we define a string without a subscript, we are defining a maximum of
255 characters. When we define for example, a string[20], we are defining
a max of 20 characters.  In reality, we are defining the number of char-
acters + 1.  A string has a first byte (0th byte) that represents the
actual character length of the data stored in the string, as an unsigned
byte. (Actually, the length function reads this byte when you call it,
but it's also possible to read and refer to the byte, and even SET it.)

Refer back to part 8 where I said you could individually set each part
of the string.  It's possible to actually build a string by setting the
length byte, then setting the rest of the string as characters.  Say,
to set the dynamic length of a string to 4, we can do this, as in this
example, which will only write "Hello" instead of "Hello world!".  We
are setting the 0'th part of the string as a character, which we need
to do:

program test; 
  var
    p: string;
  begin
    p := 'Hello world!';
    p[0] := #5;
    writeln(p);
  end.

Blocked Character Strings
=========================
It's also possible to work with an array of characters as a string, by
referring to the whole array.  The maximum length must be set by the
length of the array, essentially.

str: array[1..20] of char;

if we read this structure in as a whole, it will have 20 characters in it,
in which we can write back out to the screen by saying WRITE(STR);, or
actually convert to a string by counting through to find the actual length
and then setting the length byte.

Null Terminated Strings
=======================
This is a length of characters, which are terminated by a null character,
or #0.  The strings unit is documented to work with these strings, but it's
easier to get away with simply converting it into something we can work
with through Pascal itself, if we have to do much with it.

Arrays
======
The general structure of an array was described in part 6.  It is basically
usable as a grouping of items.

Records
=======
A record is stored in memory basically as a grouping of data types.  The
record type below:

  datarecord = record
    int: integer;
    character: char;
  end;

would be stored in memory like this:

 INT CHARACTER


Now, we have described all of the pertinent items we need to know to be
able to work through a spec sheet on a common format.  Basically, data
for spec sheets are sometimes presented as the record format, in either
Pascal or C format.  We don't need to really do any work for that, but
most of the time, it will be presented in a byte by byte offset format.

Let us look at this structure file for an example.  It is of the standard
sound file called a MOD file. (you can find them anywhere, almost)  We
will cover just the header of the file for now...
-------------------------------------------------------------------------

Protracker 1.1B Song/Module Format:
 
Offset  Bytes  Description
   0     20    Songname. Remember to put trailing null bytes at the end...
 
Information for sample 1-31:
 
Offset  Bytes  Description
  20     22    Samplename for sample 1. Pad with null bytes.
  42      2    Samplelength for sample 1. Stored as number of words.
               Multiply by two to get real sample length in bytes.
  44      1    Lower four bits are the finetune value, stored as a signed
               four bit number. The upper four bits are not used, and
               should be set to zero.
               Value:  Finetune:
                 0        0
                 1       +1
                 2       +2
                 3       +3
                 4       +4
                 5       +5
                 6       +6
                 7       +7
                 8       -8
                 9       -7
                 A       -6
                 B       -5
                 C       -4
                 D       -3
                 E       -2
                 F       -1
 
  45      1    Volume for sample 1. Range is $00-$40, or 0-64 decimal.
  46      2    Repeat point for sample 1. Stored as number of words offset
               from start of sample. Multiply by two to get offset in bytes.
  48      2    Repeat Length for sample 1. Stored as number of words in
               loop. Multiply by two to get replen in bytes.
 
Information for the next 30 samples starts here. It's just like the info for
sample 1.
 
Offset  Bytes  Description
  50     30    Sample 2...
  80     30    Sample 3...
   .
   .
   .
 890     30    Sample 30...
 920     30    Sample 31...
 
Offset  Bytes  Description
 950      1    Songlength. Range is 1-128.
 951      1    Well... this little byte here is set to 127, so that old
               trackers will search through all patterns when loading.
               Noisetracker uses this byte for restart, but we don't.
 952    128    Song positions 0-127. Each hold a number from 0-63 that
               tells the tracker what pattern to play at that position.
1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
               inserted when they increased the number of samples from
               15 to 31. If it's not there, the module/song uses 15 samples
               or the text has been removed to make the module harder to
               rip. Startrekker puts "FLT4" or "FLT8" there instead.
 
Source: Lars "ZAP" Hamre/Amiga Freelancers

--------------------------------------------------------------------------

Building the basic record format
================================
We will need to essentially, for any standard file, built record format(s)
for the file.  Let us start with this one.

It says above that the first 20 bytes would be a song title.  The description
best seems to define it as a null-terminated string, but we know the maximum
limit.  So, lets just call it a blocked character string of length 20.  So
we will use this description for part of our component record:

songname: array[1..20] of char;

If we read on through the file, it states data for samples 1-31.  They are
varied data, so that infers that we need to build another record format.
But for the position so far in our current record format, we will use
this, since we know that there are a group of 31 samples...we will call
our alternate record for the sample data, samplerec.

sampledata: array[1..31] of samplerec;

Alternate Sample Record
=======================
22 bytes are defined for a samplename.  Same logic for songname.  So this
unit of our sample record will be

samplename: array[1..22] of char;

The next part is a sample length defined by 2 bytes.  So, we could either
call this a word, or an integer:

samplelength: integer;

One byte for a finetune value.  Logical definition:

finetune: byte;

Volume is defined as one byte.  So...

volume: byte;

Repeat point and Repeat length are both defined as words above so...

repeatpoint: integer;
repeatlength: integer;

It is indicated above that we are done with the samples.  Therefore, our
final record format for the samples would be:

samplerec = record
  samplename: array[1..22] of char;
  samplelength: integer;
  finetune: byte;
  volume: byte;
  repeatpoint: integer;
  repeatlength: integer;
end;

Finishing the Record Format
===========================
Continuing on...

songlength is a byte.  So

songlength: byte;

A byte is defined next that seems like a filler byte.  So...

filler: byte;

The next set of 128 bytes are defined as "song positions 0-127".  Each byte
is also defined to hold a number, so lets keep to that:

positions: array[0..127] of byte;

The next 4 bytes to finish out our headers is the moduleid.  it's 4 bytes,
text, so...

id: array[1..4] of char;

Having gone through the header format for this file, we have come up with
a record we can use to read all the header data, that we would need to read
for a mod file.  Therefore, we can use a final type listing in our program
to read a mod file header of:

samplerec = record
  samplename: array[1..22] of char;
  samplelength: integer;
  finetune: byte;
  volume: byte;
  repeatpoint: integer;
  repeatlength: integer;
end;

modrecord = record
  songname: array[1..20] of char;
  sampledata: array[1..31] of samplerec;
  songlength: byte;
  filler: byte;
  positions: array[0..127] of byte;
  id: array[1..4] of char;
end;

We can use this format to gain any information we know about a file.  To
test this format, we need to write a program that pulls the information
out of a standard file, that we know, and check to see if they're identical.
For MODs, we would need to get a player, and load up the player, in order
to get data we are familiar with from the spec sheet, such as the id being
"M.K.".

All the data we need to know to extract data out, and get formatted data
from standards files, have been presented.

Practice Programming Problem #11
================================
In keeping with the topic of this tutorial, I am asking you to write a
program entirely in Pascal that will take a ZIP file name from the command-
line and then print a list of all the files within that zip file.  With
each filename, list the compressed size, uncompressed size, date, time,
and compression method, one per file.  At the end, list the total number
of files, total compressed and uncompressed size, effective compression
ratio, and write the comment. Then output this list to a file taken on
the command-line.  For example, a command-line will always be:

ZIPLIST FILENAME.ZIP OUTPUT.TXT

Be sure to design this program with any error checks you may need to perform.
Don't forget to devise a check to be sure you are dealing with a ZIP file
on the first parameter.  Here, we have gone to look at some references,
and have found the following out of a specs list:

--------A-ZIP-------------------------------
The ZIP archives are created by the PkZIP/PkUnZIP combo produced
by the PkWare company. The PkZIP programs have with LHArc and ARJ
the best compression.
The directory information is stored at the end of the archive, each local
file in the archive begins with the following header; This header can be used
to identify a ZIP file as such :
OFFSET              Count TYPE   Description
0000h                   4 char   ID='PK',03,04
0004h                   1 word   Version needed to extract archive
0006h                   1 word   General purpose bit field (bit mapped)
                                      0 - file is encrypted
                                      1 - 8K/4K sliding dictionary used
                                      2 - 3/2 Shannon-Fano trees were used
                                    3-4 - unused
                                   5-15 - used internally by ZIP
                                 Note:  Bits 1 and 2 are undefined if the
                                        compression method is other than
                                        type 6 (Imploding).
0008h                   1 word   Compression method (see table 0010)
000Ah                   1 dword  Original DOS file date/time (see table 0009)
000Eh                   1 dword  32-bit CRC of file (inverse??)
0012h                   1 dword  Compressed file size
0016h                   1 dword  Uncompressed file size
001Ah                   1 word   Length of filename
                                 ="LEN"
001Ch                   1 word   Length of extra field
                                 ="XLN"
001Eh               "LEN" char   path/filename
001Eh               "XLN" char   extra field
+"LEN"
After all the files, there comes the central directory structure.

(Table 0009)
Format of the MS-DOS time stamp (32-bit)
The MS-DOS time stamp is limited to an even count of seconds, since the
count for seconds is only 5 bits wide.

  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16
 |<---- year-1980 --->|<- month ->|<--- day ---->|

  15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
 |<--- hour --->|<---- minute --->|<- second/2 ->|

(Table 0010)
PkZip compression types
0 - Stored / No compression
1 - Shrunk / LZW, 8K buffer, 9-13 bits with partial clearing
2 - Reduced-1 / Probalistic compression, lower 7 bits
3 - Reduced-2 / Probalistic compression, lower 6 bits
4 - Reduced-3 / Probalistic compression, lower 5 bits
5 - Reduced-4 / Probalistic compression, lower 4 bits
6 - Imploded / 2/3 Shanno-Fano trees, 4K/8K sliding dictionary
[7..9 also exist] => note added by Glenn Grotzinger from Phil Katz's
description

--- Central directory structure
The CDS is at the end of the archive and contains additional information
about the files stored within the archive.
OFFSET              Count TYPE   Description
0000h                   4 char   ID='PK',01,02
0004h                   1 byte   Version made by
0005h                   1 byte   Host OS (see table 0011)
0006h                   1 byte   Minimum version needed to extract
0007h                   1 byte   Target OS
                                 see above "Host OS"
0008h                   1 word   General purpose bit flag
                                 see above "General purpose bit flag"
000Ah                   1 word   Compression method
                                 see above "Compression method"
000Ch                   1 dword  DOS date / time of file (see table 0009)
0010h                   1 dword  32-bit CRC of file 
0014h                   1 dword  Compressed size of file
0018h                   1 dword  Uncompressed size of file
001Ch                   1 word   Length of filename
                                 ="LEN"
001Eh                   1 word   Length of extra field
                                 ="XLN"
0020h                   1 word   Length of file comment
                                 ="CMT"
0022h                   1 word   Disk number ??
0024h                   1 word   Internal file attributes (bit mapped)
                                    0 - file is apparently an ASCII/binary file
                                 1-15 - unused
0026h                   1 dword  External file attributes (OS dependent)
002Ah                   1 dword  Relative offset of local header from the
                                 start of the first disk this file appears on
002Eh               "LEN" char   Filename / path; should not contain a drive
                                 or device letter, all slashes should be forward
                                 slashes '/'.
002Eh+              "XLN" char   Extra field
+"LEN"
002Eh               "CMT" char   File comment
+"LEN"
+"XLN"

(Table 0011)
PkZip Host OS table
0 - MS-DOS and OS/2 (FAT)
1 - Amiga
2 - VMS
3 - *nix
4 - VM/CMS
5 - Atari ST
6 - OS/2 1.2 extended file sys
7 - Macintosh
8-255 - unused

--- End of central directory structure
The End of Central Directory Structure header has following format :
OFFSET              Count TYPE   Description
0000h                   4 char   ID='PK',05,06
0004h                   1 word   Number of this disk
0006h                   1 word   Number of disk with start of central directory
0008h                   1 word   Total number of file/path entries on this disk
000Ah                   1 word   Total number of entries in central dir
000Ch                   1 dword  Size of central directory
0010h                   1 dword  Offset of start of central directory relative
                                 to starting disk number
0014h                   1 word   Archive comment length
                                 ="CML"
0016h               "CML" char   Zip file comment

EXTENSION:ZIP
OCCURENCES:PC,Amiga,ST
PROGRAMS:PkZIP,WinZIP
REFERENCE:Technote.APP

Source: FILEFMTS (c) 1994,1995 Max Maischein


Sample output for this program
==============================

                       Files contained in FILENAME.ZIP

NAME         COMP-SIZE     DATE     TIME     UNCOMP-SIZE  COMP-METHOD       
---------------------------------------------------------------------
FOOBAR10.TXT       732  10-01-1993  02:30          1021       7
 FOBAR11.ZIP     11021  12-01-1995  22:03         23923       6
...
---------------------------------------------------------------------
               1520032                          4023232

15 files; Effective compression ratio: 65.3%

< write the comment here, or write "No ZIP comment." if there is no
ZIP comment >


Notes:
1) Note how I have the sample output.  It needs to be EXACTLY as I have
listed it.
2) The orders and the methods you need to use to read files should be
evident from the specs file.  They will be random reads...
3) With the random reads, it is about impossible to tell what you got
read unless you check first...Notice a good way to check out of the
first field of each record...
4) The "MS-DOS Time Format" can be done really easily.  Just think DOS
unit.
5) Do not read anything unless you HAVE to....
6) Since this is a program that happens to use another program's data,
more than likely, the data are correct, so there is no need to check
any of the data beyond determining whether it's an actual ZIP file.

With this data listed, you should be able to do anything related to listing,
stripping comments, showing comments, and so on and so forth.

Next Time
=========
We will cover the use of stacks and queues.  Send any comments,
encouragements, problems, etc, etc. to ggrotz@2sprint.net.  Haven't
seen anything of that type, ya know....

