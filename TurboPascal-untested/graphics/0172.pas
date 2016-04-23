{
>> I'm searching for the description of the structure of the
>> BMP-format And also of the PCX-format...

First the BMP format;

Bitmap-File Formats

Windows  bitmap files  are stored  in a  device-independent bitmap (DIB) format
that allows  Windows to display the  bitmap on any type  of display device. The
term "device independent" means that the bitmap specifies pixel color in a form
independent of  the method used  by a display  to represent color.  The default
filename extension of a Windows DIB file is .BMP.

Bitmap-File Structures

Each bitmap file contains a  bitmap-file header, a bitmap-information header, a
color  table,  and  an  array  of  bytes  that  defines  the  bitmap  bits. The
bitmap-file header contains  information about the type, size,  and layout of a
device-independent bitmap  file. The header  is defined as  a TBITMAPFILEHEADER
structure.

The  bitmap-information  header,  defined  as  a  TBITMAPINFOHEADER  structure,
specifies the  dimensions, compression type,  and color format  for the bitmap.
The color table,  defined as an array of TRGBQUAD  structures, contains as many
elements as there are colors in the  bitmap. The color table is not present for
bitmaps  with  24  color  bits  because  each  pixel  is  represented by 24-bit
red-green-blue (RGB) values  in the actual bitmap data area.  The colors in the
table should appear in order of  importance. This helps a display driver render
a bitmap on  a device that  cannot display as  many colors as  there are in the
bitmap. If the  DIB is in Windows version  3.0 or later format, the  driver can
use the  biClrImportant member of the  TBITMAPINFOHEADER structure to determine
which colors are important.

The   TBITMAPINFO   structure   can   be   used   to   represent   a   combined
bitmap-information  header  and  color  table.  The  bitmap  bits,  immediately
following  the color  table, consist  of an  array of  BYTE values representing
consecutive rows,  or "scan lines," of  the bitmap. Each scan  line consists of
consecutive bytes  representing the pixels  in the scan  line, in left-to-right
order. The number of bytes representing a scan line depends on the color format
and the  width, in pixels,  of the bitmap.  If necessary, a  scan line must  be
zero-padded to end on a 32-bit boundary. However, segment boundaries can appear
anywhere in the bitmap. The scan lines in the bitmap are stored from bottom up.
This  means that  the first  byte in  the array  represents the  pixels in  the
lower-left corner of the bitmap and the  last byte represents the pixels in the
upper-right corner.

The biBitCount member of the  TBITMAPINFOHEADER structure determines the number
of bits that define each pixel and  the maximum number of colors in the bitmap.
These members can have any of the following values:

Value   Meaning

1       Bitmap is monochrome and the color table contains two entries. Each bit
        in the bitmap array represents a pixel.  If the bit is clear, the pixel
        is displayed with  the color of the first entry  in the color table. If
        the bit  is set, the  pixel has the  color of the  second entry in  the
        table.
4       Bitmap  has  a  maximum  of  16  colors.  Each  pixel  in the bitmap is
        represented by a 4-bit index into  the color table. For example, if the
        first byte in  the bitmap is 0x1F, the byte  represents two pixels. The
        first  pixel contains  the color  in the  second table  entry, and  the
        second pixel contains the color in the sixteenth table entry.
8       Bitmap  has  a  maximum  of  256  colors.  Each  pixel in the bitmap is
        represented by a 1-byte index into the color table. For example, if the
        first byte in the bitmap is 0x1F,  the first pixel has the color of the
        thirty-second table entry.
24      Bitmap  has a  maximum of  2^24 colors.  The bmiColors  (or bmciColors)
        member is NULL, and each 3-byte sequence in the bitmap array represents
        the relative intensities  of red, green, and blue,  respectively, for a
        pixel.

The biClrUsed member of the TBITMAPINFOHEADER structure specifies the number of

color indexes in the color table actually used by the bitmap. If the biClrUsed
member is set to zero, the bitmap uses the maximum number of colors 
corresponding to the value of the biBitCount member.
An alternative form of bitmap file uses the BITMAPCOREINFO, TBITMAPCOREHEADER, 
and TRGBTRIPLE structures.

Bitmap Compression

Windows  versions 3.0  and later  support run-length  encoded (RLE) formats for
compressing bitmaps that use 4 bits per pixel and 8 bits per pixel. Compression
reduces the disk and memory storage required for a bitmap.

Compression of 8-Bits-per-Pixel Bitmaps

When  the biCompression  member of  the TBITMAPINFOHEADER  structure is  set to
BI_RLE8,  the  DIB  is  compressed  using  a  run-length  encoded  format for a
256-color bitmap. This  format uses two modes: encoded  mode and absolute mode.
Both modes can occur anywhere throughout a single bitmap.

Encoded Mode

A unit of  information in encoded  mode consists of  two bytes. The  first byte
specifies the  number of consecutive pixels  to be drawn using  the color index
contained in the second byte.

The  first byte  of the  pair can  be set  to zero  to indicate  an escape that
denotes  the  end  of  a  line,  the  end  of  the  bitmap,  or  a  delta.  The
interpretation of  the escape depends  on the value  of the second  byte of the
pair, which must be in the range  0x00 through 0x02. Following are the meanings
of the escape values that can be used in the second byte:

Second byte     Meaning

0       End of line.
1       End of bitmap.
2       Delta.  The  two  bytes  following  the  escape contain unsigned values
        indicating the horizontal  and vertical offsets of the  next pixel from
        the current position.

Absolute Mode

Absolute mode is signaled  by the first byte in the pair  being set to zero and
the second  byte to a value  between 0x03 and 0xFF.  The second byte represents
the number of  bytes that follow, each of  which contains the color index  of a
single pixel.  Each run must  be aligned  on  a word boundary.  Following is an
example of an 8-bit RLE bitmap  (the two-digit hexadecimal values in the second
column represent a color index for a single pixel):

Compressed data Expanded data

03 04   04 04 04
05 06   06 06 06 06 06
00 03   45 56 67 00       45 56 67
02 78   78 78
00 02   05 01             Move 5 right and 1 down
02 78   78 78
00 00   End of line
09 1E   1E 1E 1E 1E 1E 1E 1E 1E 1E
00 01   End of RLE bitmap

Compression of 4-Bits-per-Pixel Bitmaps

When  the biCompression  member of  the TBITMAPINFOHEADER  structure is  set to
BI_RLE4, the DIB is compressed using a run-length encoded format for a 16-color
bitmap. This format uses two modes: encoded mode and absolute mode.

Encoded Mode

A unit of information in encoded mode consists  of two bytes. The first byte of
the pair contains the  number of pixels to be drawn using  the color indexes in
the second byte.

The second byte contains two color  indexes, one in its high-order nibble (that
is, its low-order 4  bits) and one in its low-order nibble.  The first pixel is
drawn using the  color specified by the high-order nibble,  the second is drawn
using the color in  the low-order nibble, the third is drawn  with the color in
the high-order nibble,  and so on, until all the  pixels specified by the first
byte have been drawn. The first byte of the pair can be set to zero to indicate
an escape that  denotes the end of a  line, the end of the  bitmap, or a delta.
The interpretation of the escape depends on the value of the second byte of the
pair. In encoded  mode, the second byte has  a value in the range  0x00 through
0x02. The  meaning of these  values is the  same as for  a DIB with  8 bits per
pixel.

Absolute Mode

In absolute  mode, the first byte  contains zero, the second  byte contains the
number of color indexes that follow, and subsequent bytes contain color indexes
in their high- and low-order nibbles, one  color index for each pixel. Each run
must be  aligned on a  word boundary. Following  is an example  of a 4-bit  RLE
bitmap (the one-digit hexadecimal values in the second column represent a color
index for a single pixel):

Compressed data   Expanded data

03 04   0 4 0
05 06   0 6 0 6 0
00 06   45 56 67 00       4 5 5 6 6 7
04 78   7 8 7 8
00 02   05 01     Move 5 right and 1 down
04 78   7 8 7 8
00 00   End of line
09 1E   1 E 1 E 1 E 1 E 1
00 01   End of RLE bitmap

Bitmap Example

The following example is a text dump of a 16-color bitmap (4 bits per pixel):



Win3DIBFile
              BitmapFileHeader
                  Type       19778
                  Size       3118
                  Reserved1  0
                  Reserved2  0
                  OffsetBits 118
              TBITMAPINFOHeader
                  Size            40
                  Width           80
                  Height          75
                  Planes          1
                  BitCount        4
                  Compression     0
                  SizeImage       3000

                  XPelsPerMeter   0
                  YPelsPerMeter   0
                  ColorsUsed      16
                  ColorsImportant 16
              Win3ColorTable
                  Blue  Green  Red  Unused
[00000000]        84    252    84   0
[00000001]        252   252    84   0
[00000002]        84    84     252  0
[00000003]        252   84     252  0
[00000004]        84    252    252  0
[00000005]        252   252    252  0
[00000006]        0     0      0    0

[00000007]        168   0      0    0
[00000008]        0     168    0    0
[00000009]        168   168    0    0
[0000000A]        0     0      168  0
[0000000B]        168   0      168  0
[0000000C]        0     168    168  0
[0000000D]        168   168    168  0
[0000000E]        84    84     84   0
[0000000F]        252   84     84   0
              Image
    .
    .                                           Bitmap data
    .





Now the PCX format;


Introduction
This booklet was designed to aid developers and users in understanding the 
technical aspects of the .PCX file format and the use of FRIEZE.  Any comments,

questions or suggestions about this booklet should be sent to:

ZSoft Corporation
Technical Services
ATTN: Code Librarian
450 Franklin Rd. Suite 100
Marietta, GA  30067



Technical Reference Manual information compiled by:
Dave Steier & Dean Ansley


Revision 5

To down load additional information and the source for a complete Turbo Pascal 
program to show .PCX files on a CGA/EGA/VGA graphics display, call our BBS at 
(404)427-1045.  You may use a 9600 baud  modem or a 2400 baud standard modem. 
Your modem should be set for 8 data bits, 1 stop bit, and NO parity.

Image  File (.PCX) Format

If you have technical questions on the format, please do not call technical 
support.  ZSoft provides this document as a courtesy to its users and 
developers.  It is not the function of Technical Support to provide programming

assistance.  If something is not clear, leave a message on our BBS, Compuserve,

or write us a letter at the above address.
The information in this section will be useful if you want to write a program
to 
read or write PCX files (images).  If you want to write a special case program 
for one particular image format you should be able to produce something that 
runs twice as fast as "Load from..." in PC Paintbrush.
Image files used by PC Paintbrush product family and FRIEZE (those with a .PCX
extension) begin with a 128 byte header.  Usually you can ignore this header, 
since your images will probably all have the same resolution.  If you want to 
process different resolutions or colors, you will need to interpret the header 
correctly.  The remainder of the image file consists of encoded graphic data. 
The encoding method is a simple byte oriented run-length technique.  We reserve

the right to change this method to improve space efficiency.  When more than
one 
color plane is stored in the file, each line of the image is stored by color 
plane (generally ordered red, green, blue, intensity), As shown below.
Scan line 0:  RRR... (Plane 0)
 GGG... (Plane 1)
 BBB... (Plane 2)
 III...  (Plane 3)
Scan line 1:  RRR...
 GGG...
 BBB...
 III...  (etc.)

The encoding method is:
    FOR  each  byte,  X,  read from the file
        IF the top two bits of X are  1's then
            count = 6 lowest bits of X
            data = next byte following X
        ELSE
            count = 1
            data = X
Since the overhead this technique requires is, on average,  25% of the 
non-repeating data and is at least offset whenever bytes are repeated, the file

storage savings are usually considerable.
ZSoft .PCX FILE HEADER FORMAT
Byte Item Size Description/Comments
0 Manufacturer 1 Constant Flag, 10 = ZSoft .pcx
1 Version 1 Version information
   0 = Version 2.5 of PC Paintbrush
   2 = Version 2.8 w/palette information
   3 = Version 2.8 w/o palette information
   4 = PC Paintbrush for Windows(Plus for Windows uses Ver 5)
   5 = Version 3.0 and > of PC Paintbrush and PC Paintbrush +, includes 
Publisher's Paintbrush . Includes 24-bit .PCX files
2 Encoding 1 1 = .PCX run length encoding
3 BitsPerPixel 1 Number of bits to represent a pixel (per Plane) - 1, 2, 4, or
8
4 Window 8 Image Dimensions: Xmin,Ymin,Xmax,Ymax
12 HDpi 2 Horizontal Resolution of image in DPI*
14 VDpi 2 Vertical Resolution of image in DPI*
16 Colormap 48  Color palette setting, see text
64 Reserved 1 Should be set to 0.
65 NPlanes 1 Number of color planes
66 BytesPerLine 2 Number of bytes to allocate for a scanline plane.  MUST be an

EVEN number.  Do NOT calculate from Xmax-Xmin.
68 PaletteInfo 2 How to interpret palette- 1 = Color/BW, 2 = Grayscale (ignored

in PB IV/ IV +)
70 HscreenSize 2 Horizontal screen size in pixels.
New field found only in PB IV/IV Plus
72 VscreenSize 2 Vertical screen size in pixels.
New field found only in PB IV/IV Plus
74 Filler 54 Blank to fill out 128 byte header.  Set all bytes to 0

NOTES:
All sizes are measured in BYTES.
All variables of SIZE 2 are integers.
*HDpi and VDpi represent the Horizontal and Vertical resolutions which the
image 
was created (either printer or scanner); i.e. an image which was scanned might 
have 300 and 300 in each of these fields.

Decoding .PCX Files
First, find the pixel dimensions of the image by calculating [XSIZE = Xmax - 
Xmin + 1] and [YSIZE = Ymax - Ymin + 1].  Then calculate how many bytes are 
required to hold one complete uncompressed scan line:
TotalBytes = NPlanes * BytesPerLine
Note that since there are always an even number of bytes per scan line, there 
will probably be unused data at the end of each scan line.  TotalBytes shows
how 
much storage must be available to decode each scan line, including any blank 
area on the right side of the image.  You can now begin decoding the first scan

line - read the first byte of data from the file.  If the top two bits are set,

the remaining six bits in the byte show how many times to duplicate the next 
byte in the file.  If the top two bits are not set, the first byte is the data 
itself, with a count of one.
Continue decoding the rest of the line.  Keep a running subtotal of how many 
bytes are moved and duplicated into the output buffer.  When the subtotal
equals 
TotalBytes, the scan line is complete.  There should always be a decoding break

at the end of each scan line.  But there will not be a decoding break at the
end 
of each plane within each scan line.  When the scan line is completed, there
may 
be extra blank data at the end of each plane within the scan line.  Use the 
XSIZE and YSIZE values to find where the valid image data is.  If the data is 
multi-plane, BytesPerLine shows where each plane ends within the scan line.
Continue decoding the remainder of the scan lines (do not just read to 
end-of-file).  There may be additional data after the end of the image
(palette, 
etc.)
Palette Information Description
EGA/VGA 16 Color Palette Information
The palette information is stored in one of two different formats.  In standard

RGB format (IBM EGA, IBM VGA) the data is stored as 16 triples.  Each triple is

a 3 byte quantity of Red, Green, Blue values.  The values can range from 0-255,

so some interpretation may be necessary.  On an IBM EGA, for example, there are

4 possible levels of RGB for each color.  Since 256/4 = 64, the following is a 
list of the settings and levels:
Setting  Level
0-63  0
64-127  1
128-192  2
193-254  3
24-Bit .PCX Files
24 bit images are stored as version 5 or above as 8 bit, 3 plane images.
24 bit images do not contain a palette.
Bit planes are ordered as lines of red, green, blue in that order.

VGA 256 Color Palette Information
ZSoft has recently added the capability to store palettes containing more than 
16 colors in the .PCX image file.  The 256 color palette is formatted and 
treated the same as the 16 color palette, except that it is substantially 
longer.  The palette (number of colors x 3 bytes in length) is appended to the 
end of the .PCX file, and is preceded by a 12 decimal.  Since the VGA device 
expects a palette value to be 0-63 instead of 0-255, you need to divide the 
values read in the palette by 4.
To access a 256 color palette:
First, check the version number in the header; if it contains a 5 there is a 
palette.
Second, read to the end of the file and count back 769 bytes.  The value you 
find should be a 12 decimal, showing the presence of a 256 color palette.
CGA Color Palette Information
NOTE: This is no longer supported for PC Paintbrush IV/IV Plus.
For a standard IBM CGA board, the palette settings are a bit more complex. Only

the first byte of the triple is used.  The first triple has a valid first byte 
which represents the background color.  To find the background, take the 
(unsigned) byte value and divide by 16.  This will give a result between 0-15, 
hence the background color.  The second triple has a valid first byte, which 
represents the foreground palette.  PC Paintbrush supports 8 possible CGA 
palettes, so when the foreground setting is encoded between 0 and 255, there
are 
8 ranges of numbers and the divisor is 32.
CGA Color Map
Header Byte #16
Background color is determined in the upper four bits.
Header Byte #19
Only upper 3 bits are used, lower 5 bits are ignored.  The first three bits
that 
are used are ordered C, P, I.  These bits are interpreted as follows:
c: color burst enable - 0 = color; 1 = monochrome
p: palette - 0 = yellow; 1 = white
i: intensity - 0 = dim; 1 = bright
PC Paintbrush Bitmap Character Format
NOTE: This format is for PC Paintbrush (up to Vers 3.7) and PC Paintbrush Plus 
(up to Vers 1.65)
The bitmap character fonts are stored in a particularly simple format.  The 
format of these characters is as follows:

Header
font width byte  0xA0 + character width  (in pixels)
font height byte  character height  (in pixels)
Character Width Table
char widths (256 bytes)  each char's width + 1 pixel of kerning
Character Images
(remainder of the file)  starts at char 0  (Null)
The characters are stored in ASCII order and as many as 256 may be provided. 
Each character is left justified in the character block, all characters take up

the same number of bytes.
Bytes are organized as N strings, where each string is one scan line of the 
character.
For example, each character in a 5x7 font requires 7 bytes.  A 9x14 font uses
28
bytes per character (stored two bytes per scan line in 14 sets of 2 byte 
packets).  Custom fonts may be any size up to the current maximum of 10K bytes 
allowed for a font file.  There is a maximum of 4 bytes per scan line.Sample
"C" 
Routines
The following is a simple set of C subroutines to read data from a .PCX file.
/* This procedure reads one encoded block from the image file and stores a
count 
and data byte.
Return result:  0 = valid data stored, EOF = out of data in file */
encget(pbyt, pcnt, fid)
int *pbyt; /* where to place data */
int *pcnt; /* where to place count */
FILE *fid; /* image file handle */
{
int i;
 *pcnt = 1; /* assume a "run" length of one */
 if (EOF == (i = getc(fid)))
  return (EOF);
 if (0xC0 == (0xC0 & i))
  {
  *pcnt = 0x3F & i;
  if (EOF == (i = getc(fid)))
   return (EOF);
  }
 *pbyt = i;
 return (0);
}
/* Here's a program fragment using encget.  This reads an entire file and
stores 
it in a (large) buffer, pointed to by the variable "bufr". "fp" is the file 
pointer for the image */
int i;
long l, lsize;
 lsize = (long )hdr.BytesPerLine * hdr.Nplanes * (1 + hdr.Ymax - hdr.Ymin);
 for (l = 0; l < lsize; )             /* increment by cnt below */
  {
  if (EOF == encget(&chr, &cnt, fp))
   break;
  for (i = 0; i < cnt; i++)
   *bufr++ = chr;
  l += cnt;
  }
The following is a set of C subroutines to write data to a .PCX file.
/* Subroutine for writing an encoded byte pair (or single byte if it doesn't
encode) to a file.
It returns the count of bytes written, 0 if error */
encput(byt, cnt, fid)
unsigned char byt, cnt;
FILE *fid;
{
  if (cnt) {
 if ((cnt == 1) && (0xC0 != (0xC0 & byt)))
  {
  if (EOF == putc((int )byt, fid))
   return(0);     /* disk write error (probably full) */
  return(1);
  }
 else
  {
  if (EOF == putc((int )0xC0 | cnt, fid))
   return (0);      /* disk write error */
  if (EOF == putc((int )byt, fid))
   return (0);      /* disk write error */
  return (2);
  }
 }
   return (0);
}/* This subroutine encodes one scanline and writes it to a file.
It returns number of bytes written into outBuff, 0 if failed. */
encLine(inBuff, inLen, fp)
unsigned char *inBuff;    /* pointer to scanline data */
int inLen;   /* length of raw scanline in bytes */
FILE *fp;   /* file to be written to */
{
unsigned char this, last;
int srcIndex, i;
register int total;
register unsigned char runCount;     /* max single runlength is 63 */
  total = 0;
  runCount = 1;
  last = *(inBuff);
/* Find the pixel dimensions of the image by calculating
[XSIZE = Xmax - Xmin + 1] and [YSIZE = Ymax - Ymin + 1].
Then calculate how many bytes are in a "run" */
  for (srcIndex = 1; srcIndex < inLen; srcIndex++)
 {
 this = *(++inBuff);
 if (this == last)     /* There is a "run" in the data, encode it */
  {
  runCount++;
  if (runCount == 63)
   {
   if (! (i = encput(last, runCount, fp)))
    return (0);
   total += i;
   runCount = 0;
   }
  }
 else  /* No "run"  -  this != last */
  {
  if (runCount)
   {
   if (! (i = encput(last, runCount, fp)))
    return(0);
   total += i;
   }
  last = this;
  runCount = 1;
  }
 } /* endloop */
  if (runCount) /* finish up */
 {
 if (! (i = encput(last, runCount, fp)))
  return (0);
 return (total + i);
 }
  return (total);
}
FRIEZE Technical Information
General FRIEZE Information

FRIEZE is a memory-resident utility that allows you to capture and save graphic

images from other programs.  You can then bring these images into PC Paintbrush

for editing and enhancement.
FRIEZE 7.10 and later can be removed from memory (this can return you up to 90K

of DOS RAM, depending on your configuration). To remove FRIEZE from memory, 
change directories to your paintbrush directory and type the word "FRIEZE".

7.00 and Later FRIEZE
The FRIEZE command line format is:
FRIEZE {PD} {Xn[aarr]} {flags} {video} {hres} {vres} {vnum}
Where:
{PD} Printer driver filename (without the .PDV extension)
{Xn[aarr]}
  X=S for Serial Printer, P for Parallel Printer, D for disk file.
   (file is always named FRIEZE.PRN)
  n = port number
  aa = Two digit hex code for which return bits cause
    an abort (optional)
  rr = Two digit hex code for which return bits cause
   a retry (optional)
  NOTE:  These codes represent return values from serial or parallel port  BIOS

calls.  For values see and IBM BIOS reference (such as Ray Duncan's Advanced 
MS-DOS Programming).
{flags}Four digit hex code
 First Digit controls Length Flag
 Second Digit controls Width Flag
  Third Digit controls Mode Flag
  Fourth Digit controls BIOS Flag
   0 - None
   1 - Dual Monitor Present
   2 - Use internal (true) B/W palette for dithering
    2 color images
   4 - Capture palette along with screen IN VGA ONLY
    Frieze 8.08 & up ONLY)
NOTE: The length, width and mode flags are printer driver specific.  See 
PRINTERS.DAT on disk 1 (or Setup Disk) for correct use.  In general width flag 
of 1 means wide carriage, and 0 means standard width.  Length flag of 0 and
mode
flag of 0 means use default printer driver settings.
If you need to use more than one BIOS flag option, add the needed flag values
