(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0140.PAS
  Description: FLC File Format
  Author: DARRYL LUFF
  Date: 05-26-95  23:06
*)

{
> Does anybody out there know how to load .FLC's in TP
> (V/7.0) not .FLI's but .FLC's. I have tried the
> package spx20.zip or whatever and it only had code for
> .FLI's if anyone knows please let me know!:)

Look for a file called FLXSPEC.TXT. It's about 30K uncompressed I think.
The .FLC format is a superset of the .FLI. Here are some parts from it:
==========
The Animator Pro animation file is a good example of a hierarchial
chunked file structure.  The data in an animation file is arranged
as follows:

     animation file:
          optional prefix chunk:
               settings chunk
               cel placement chunk
          frame 1 chunk:
               postage stamp chunk:
                    postage stamp data
               color palette chunk
               pixel data chunk
          frame 2 chunk:
               pixel data chunk
          frame 3 chunk:
               color palette chunk
               pixel data chunk
          frame 4 chunk:
               color palette chunk
          ring frame chunk:
               color palette chunk
               pixel data chunk


FLC - Animator Pro Flic Files

This is the main animation file format created by Animator Pro.
The file contains a 128-byte header, followed by an optional
prefix chunk, followed by one or more frame chunks.

The prefix chunk, if present, contains Animator Pro settings
information, CEL placement information, and other auxiliary data.

A frame chunk exists for each frame in the animation. In
addition, a ring frame follows all the animation frames.  Each
frame chunk contains color palette information and/or pixel data.

The ring frame contains delta-compressed information to loop from
the last frame of the flic back to the first.  It can be helpful
to think of the ring frame as a copy of the first frame,
compressed in a different way.  All flic files will contain a
ring frame, including a single-frame flic.


The FLC file header


A FLC file begins with a 128-byte header, described below.  All
lengths and offsets are in bytes.  All values stored in the
header fields are unsigned.

Offset  Length  Name         Description

  0       4     size         The size of the entire animation file,
                             including this file header.

  4       2     magic        File format identifier. Always hex AF12.

  6       2     frames       Number of frames in the flic.  This
                             count does not include the ring frame.
                             FLC files have a maximum length of 4000
                             frames.

  8       2     width        Screen width in pixels.

  10      2     height       Screen height in pixels.

  12      2     depth        Bits per pixel (always 8).

  14      2     flags        Set to hex 0003 after ring frame is
                             written and flic header is updated.
                             This indicates that the file was properly
                             finished and closed.

  16      4     speed        Number of milliseconds to delay between
                             each frame during playback.

  20      2     reserved     Unused word, set to 0.

  22      4     created      The MSDOS-formatted date and time of the
                             file's creation.

  26      4     creator      The serial number of the Animator Pro
                             program used to create the file.  If the
                             file was created by some other program
                             using the FlicLib development kit, this
                             value is hex 464C4942 ("FLIB").

  30      4     updated      The MSDOS-formatted date and time of the
                             file's most recent update.

  34      4     updater      Indicates who last updated the file.  See
                             the description of creator.

  38      2     aspectx      The x-axis aspect ratio at which the file
                             was created.

  40      2     aspecty      The y-axis aspect ratio at which the file
                             was created. Most often, the x:y aspect ratio
                             will be 1:1.  A 320x200 flic has a ratio of
                             6:5.

  42      38    reserved     Unused space, set to zeroes.

  80      4     oframe1      Offset from the beginning of the file to the
                             first animation frame chunk.

  84      4     oframe2      Offset from the beginning of the file to
                             the second animation frame chunk.  This value
                             is used when looping from the ring frame back
                             to the second frame during playback.

  88      40    reserved     Unused space, set to zeroes.


The FLC prefix chunk

An optional prefix chunk may immediately follow the animation
file header.  This chunk is used to store auxiliary data which is
not directly involved in the animation playback.  The prefix
chunk starts with a 16-byte header (identical in structure to a
frame header), as follows:

Offset  Length  Name         Description

  0       4     size         The size of the prefix chunk, including
                             this header and all subordinate chunks
                             that follow.

  4       2     type         Prefix chunk identifier. Always hex F100.

  6       2     chunks       Number of subordinate chunks in the
                             prefix chunk.

  8       8     reserved     Unused space, set to zeroes.

To determine whether a prefix chunk is present, read the 16-byte
header following the file header.  If the type value is hex F100,
it's a prefix chunk.  If the value is hex F1FA it's the first
frame chunk, and no prefix chunk exists.

....

The FLC frame chunks

Frame chunks contain the pixel and color data for the animation.
A frame chunk may contain multiple subordinate chunks, each
containing a different type of data for the current frame.  Each
frame chunk starts with a 16-byte header that describes the contents
of the frame:

Offset  Length  Name         Description

  0       4     size         The size of the frame chunk, including this
                             header and all subordinate chunks that follow.

  4       2     type         Frame chunk identifier. Always hex F1FA.

  6       2     chunks       Number of subordinate chunks in the
                             frame chunk.

  8       8     reserved     Unused space, set to zeroes.


Immediately following the frame header are the frame's subordinate
data chunks.  When the chunks count in the frame header is zero, it
indicates that this frame is identical to the previous frame.  This
implies that no change is made to the screen or color palette, but
the appropriate delay is still inserted during playback.

Each data chunk within a frame chunk is formatted as follows:

Offset  Length  Name         Description

  0       4     size         The size of the chunk, including this header.

  4       2     type         Data type identifier.

  6    (size-6) data         The color or pixel data.


The type values in the chunk headers indicate what type of graphics
data the chunk contains and which compression method was used to
encode the data.  The following values (and their associated mnemonic
names) are currently found in frame data chunks:

Value     Name        Description

  4    FLI_COLOR256   256-level color palette info
  7    FLI_SS2        Word-oriented delta compression
  11   FLI_COLOR      64-level color palette info
  12   FLI_LC         Byte-oriented delta compression
  13   FLI_BLACK      Entire frame is color index 0
  15   FLI_BRUN       Byte run length compression
  16   FLI_COPY       No compression
  18   FLI_PSTAMP     Postage stamp sized image



