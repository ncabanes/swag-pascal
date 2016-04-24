(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0010.PAS
  Description: SOUNDINF.PAS
  Author: JOE DICKSON
  Date: 05-28-93  13:57
*)

{
JOE DICKSON

> Hello there.. I was just wondering if anyone had any idea
> on how to play a wav/voc File over the pc speaker. I have a
> Program called PC-VOICE, written by Shin K.H. (Is he here?)
> that will play voc's and wav's (whats the difference?) over
> the speaker.. I don't know assembly, just pascal, but I've
> got a friend that can show me how to link the assembly stuff
> in With the Pascal, so that shouldn't be a problem..
> Also, I've tried and failed to find the format of a voc/wav
> File, so if anyone has that, it would be much appriciated.
}

Header-- CT-VOICE Header Block
-=-
The header is a data block that identifies the File as a CT-format File.  This
means that you can use the header to check whether the File is an actual
CT-format File.

Bytes $00 - $13 (0-19)

The first 19 Bytes of a VOC File contain the Text "Creative Voice File", as
well as a Byte With the value $1A.  This identifies the File as a VOC File.

Bytes $14 - $15 (20-21)

These Bytes contain the offset address of the sample data as a
low-Byte/high-Byte value.  At this point, this value is $001A because the
header is exactly $1A Bytes long.

However, if the length of the header changes later, the Programs that access
the VOC data in this File will be able to use the values stored in these two
Bytes to determine the location at which the sample data begins.

Bytes $16 - $17 (22-23)

These two Bytes contain the CT-Voice format version number as a
low-Byte/high-Byte value.  The current version number is still 1.10 (NOTE--This
may have changed, this was published in 92) so Byte $17 contains the main
version number ($01) and Byte $16 contains the version subnumber ($0A).  The
version number is very important because later CT-Voice format versions may use
an entirely different method For storing the sample data than the current
version.

To ensure that the data contained in the File will be processed correctly, you
should always check the File's version number.  if a different version number
appears, an appropriate warning should be displayed.

Bytes $18 - $19 (24-25)

The importance of the version number is obvious in Bytes $18 and $19.  These
Bytes contain the complement of the version number, added to $1234, as a
low-Byte/high-Byte value.

Therefore, With the current version number $010A, Byte $18 contains the value
$29, While Byte $19 contains $11.  This results in the Word value $1129.  If
you check this value and succesfully compare it to the version number stored in
the previos two Bytes, you can be almost certain that you're using a VOC File.

This completes the desciprtion of Bytes contained in the header.  Everything
that follows these Bytes in the File belongs to the File's data blocks.

The Data Blocks--  The eight data blocks of the CT-Voice format have the same
structure, except For block 0.  Each block begins With a block identifier,
which is a Byte containing a block-Type number between 0 and 7.  This number is
followed by three Bytes specifying the length of the block, and then the
specified number of additional data.

The three length Bytes contain increasing values (i.e., the first Byte
represents the lowest value and the third Byte represents the highest).  SO the
block's length can be calculated by using the formula:

Byte1 + Byte2*256 + Byte3*65536

In all other cases, the CT-Voice format stores values requiring more than one
Byte in a low Byte followed by  a high-Byte, which corresponds to the Word data
Type.

Block 0 - end Block

The end block has the lowest block number.  It indicates that there aren't any
additional data blocks.  When such a block is reached, the output of VOC data
during the playback of digitized Sounds stops.  Therefore, this block should be
located only at the end of a VOC File.  The end block is the only block that
doesn't have Bytes indicating its block length.

+----------------------------+
| STRUCTURE of THE end BLOCK |
|                            |
| Block Type: 1 Byte = 0     |
| Block Length: None         |
| Data Bytes: None           |
+----------------------------+

Block 1 - New Voice Block

The block Type number 1 is the most frequently used block Type.  It contains
playable sample data.  The three block length Bytes are followed by a Byte
specifying the sampling rate (SR) that was used to Record the Sounds.

Calculatin The Sampling Rate-- Since only 256 different values can be stored in
a singly Byte, the actual sampling rate must be calculated from the value of
this Byte.

Use the following formula to do this:

  Actual_sampling_rate = -1000000 div (SR - 256)

To convert a sampling rate into the corresponding Byte value, reverse the
equation:

  SR = 256 - 1000000 div actual_sampling_rate

The pack Byte follows the SR Byte.  This value indicates whether and how the
sample data have been packed.

The value 0 indicates that the data hasn't been packed; so 8 bits form one data
value.  This is the standard Recording format.  However, your Sound Blaster
card is also capable of packing data on a hardware level. (good luck trying to
recreate that)

A value of 1 in the pack Byte indicates that the original 8 bit values have
been packed to 4 bits.  This results in a pack rate of 2:1.  Although the data
requires only half as much memory, this method also reduces the Sound quality.

The value 2 indicates a pack rate of 3:1, so the data requires only a third of
the memory.  Sound quality reduces significantly.

A pack Byte value of 3 indicates a pack rate of 4:1, so 8 original bits have
been packed down to 2.  This pack rate results in A LOT of reduction in Sound
quality.

The pack Byte is followed by the actual sample data.  The values contained in
the block length Bytes also indicate the length of the sample data.  To
determine the length of the actual sample data in Bytes, simply subtract the SR
and pack Bytes from the block length.

+---------------------------------+
| STRUCTRE of THE NEW VOICE BLOCK |
|                                 |
| Block Type: 1 Byte = 1          |
| Block Length: 3 Bytes           |
| SR Byte: 1 Byte                 |
| Pack Byte: 1 Byte = 0,1,2,3     |
| Data Bytes: X Bytes.            |
+---------------------------------+

Block 2 - Subsequent Voice Block

Block Type 2 is used to divide sample data into smaller individual blocks. This
method is used by the Creative Labs Voice Editor when you want to work With a
sample block that's too large to fit into memory in one piece.  This block is
then simply divided into several smaller blocks.

Since these blocks contain only three length Bytes and the actual sample data,
blocks of Type 2 must always be preceded by a block of Type 1.  So, the
sampling rate and the pack rate are determined by the preceeding block Type 1.

+-----------------------------------------+
| STRUCTURE of THE SUBSEQUENT VOICE BLOCK |
|                                         |
| Block Type: 1 Byte = 2                  |
| Block Length: 3 Bytes                   |
| Data Bytes: X Bytes                     |
+-----------------------------------------+

Block 3 - Silence Block

Block Type 3 Uses a small number of Bytes to represent a mass of zeros.  First
there are the three familiar block length Bytes.  The length of a silence block
is always 3, so the lowest Byte contains a three, and then the other two Bytes
contain zeros.

The length Bytes are followed by two other Bytes, which indicate how many zero
Bytes should be replaced by the silence block.

This is followed by a Byte that indicates the sampling rate For the silence
block.  The SR Byte is encoded in the same way as indicated in block Type 1.

Silence blocks can be used to insert longer paUses or silences in a sample,
which reduces the required data to a few Bytes.  The Voice Editor will insert
these silence blocks through the Silence Packing Function.

+--------------------------------+
| STRUCTURE of THE SILENCE BLOCK |
|                                |
| Block Type: 1 Byte = 3         |
| Block Length: 3 Bytes = 3      |
| Duration: 2 Bytes              |
| Sample Rate: 1 Byte            |
+--------------------------------+

Block 4 - Marker Block

The marker block is an important element of the CT-Voice format.  It also has
three block length Bytes followed by two marker Bytes.  The block length Bytes
always contain the value 2 in the lowest Byte.

When the playback routine of "CT-VOICE.DRV" encounters a marker block, the
value of the marker Byte is copied to a memory location that was specified to
the driver.  The marker block is often used to determine where exactly in
playback you are.  This is useful For synchronizing the action of your Program
with the playback, For a Graphical intro For example.

Using the Voice Editor, you can divide large sample data blocks into smaller
ones, inserting marker blocks at important locations.  This doesnt affect the
playback of the sample.  However, you'll be able to determine, from your
Program, which point of the sample the playback routine is currently reading.

+-------------------------------+
| STRUCTURE of THE MARKER BLOCK |
|                               |
| Block Type : 1 Byte = 4       |
| Block Length: 3 Bytes = 2     |
| Marker: 2 Bytes               |
+-------------------------------+

Block 5 - Message Block

It's also possible to insert ASCII Texts Within a VOC File.  Use the message
block to do this.  if you want to identify a specific seciont of a sample File
by adding a title, simply add a block of Type 5, in which you can then store
the desired Text.

This block also has three block length Bytes.  These Bytes are followed by the
Text in ASCII format.  The Text must contain a 0 in the last Byte to indicate
the end of the Text.  This corresponds to the String convention of the C
Programming language.  This allows you to pring the Texts in a VOC File
directly from memory using the printf() Function in ANSI C.

+--------------------------------+
| STRUCTURE of THE MESSAGE BLOCK |
|                                |
| Block Type: 1 Byte = 5         |
| Block Length: 3 Bytes          |
| ASCII Data: X Bytes            |
| end Character: 1 Byte = 0      |
+--------------------------------+

Block 6 - Repeat Block

Another special Characteristic of the CT-Format is that it's possible to
specify, Within a VOC File, whether specific sample sequences should be
Repeated.  Blocks 6 and 7 are used to do this.

Block 6 has three block length Bytes, followed by two Bytes indicating how
often the following data block should be Repeated.  if the value specified here
is 4, the next block is played a total of five times (one "normal" playback and
four Repeats).

+-------------------------------+
| STRUCTURE of THE Repeat BLOCK |
|                               |
| Block Type: 1 Byte = 6        |
| Block Length: 3 Bytes = 2     |
| Counter: 2 Bytes              |
+-------------------------------+

Block 7 - Repeat end Block

Block 7 indicates that all blocks between block 6 and block 7 should be
Repeated.  With this block, several data blocks can be included in a Repeat
loop.  However, nested loops aren't allowed.  The driver is capable of handling
only one loop level.

Block Type 7 also has three block length Bytes, which actually aren't necessary
because this block doesnt contain any additional data.  Therefore, the block
length is always 0.

+-------------------------------+
| STRUCUTRE of Repeat end BLOCK |
|                               |
| Block Type: 1 Byte = 7        |
| Block Length: 3 Bytes = 0     |
+-------------------------------+

We've now described all the different block Types used in VOC Files.  These
Functions are fully supported by the CT-VOICE.DRV driver software.

if you'll be writing your own Sound Programs, you should follow this format
because it's easy to use and flexible.  When needed, new block Types are easily
added.  Programs that dont recognize block Types should be written so they
continue operating after an unrecognized block.  This is easy to do because
each Function specifies its own block length.

BiblioGraphy: Stolz, Axel  "The Sound Blaster Book", Abacus Copyright (c)1992,
A Data Decker Book Copyright (c) 1992


