{
From: inof@asterix.rz.tu-clausthal.de (Oliver Fromme (TBH))

> I need to be able to get the size and colors from a JPEG/JFIF image file..
> Nothing more, nothing less... Structures would do, regardless of
> language (C, Asm, Pas, Basic). Anyone?

=============================================================================

This file was written by:

   Oliver Fromme
   Leibnizstr. 18-61
   38678 Clausthal
   GERMANY

Email:  fromme@rz.tu-clausthal.de


General Notes:
~~~~~~~~~~~~~~

  - All product names mentioned in this file are trademarks or registered
    trademarks of their respective owners.
  - This file contains information about the JPEG/JFIF format
  - This is NO official documentation, for private purposes only.
    There may be bugs and errors in this file.  Use the information
    on your own risk.
  - This file does NOT explain the principles of JPEG coding/decoding,
    i.e. DCT/IDCT, quantization, entropy codec.  I assume that the reader
    is familiar with these algorithms.
  - For further information please refer to the JPEG ISO standard.
  - The JPEG/JFIF format uses Motorola format for words, NOT Intel format,
    i.e. high byte first, low byte last.


JPEG/JFIF file format:
~~~~~~~~~~~~~~~~~~~~~~

  - header (2 bytes):  $ff, $d8 (SOI) (these two identify a JPEG/JFIF file)
  - for JFIF files, an APP0 segment is immediately following the SOI marker,
    see below
  - any number of "segments" (similar to IFF chunks), see below
  - trailer (2 bytes): $ff, $d9 (EOI)


Segment format:
~~~~~~~~~~~~~~~

  - header (4 bytes):
       $ff     identifies segment
        n      type of segment (one byte)
       sh, sl  size of the segment, including these two bytes, but not
               including the $ff and the type byte. Note, not intel order:
               high byte first, low byte last!
  - contents of the segment, max. 65533 bytes.

 Notes:
  - There are parameterless segments (denoted with a '*' below) that DON'T
    have a size specification (and no contents), just $ff and the type byte.
  - Any number of $ff bytes between segments is legal and must be skipped.


Segment types:
~~~~~~~~~~~~~~

   *TEM   = $01   usually causes a decoding error, may be ignored

    SOF0  = $c0   Start Of Frame (baseline JPEG), for details see below
    SOF1  = $c1   dito
    SOF2  = $c2   usually unsupported
    SOF3  = $c3   usually unsupported

    SOF5  = $c5   usually unsupported
    SOF6  = $c6   usually unsupported
    SOF7  = $c7   usually unsupported

    SOF9  = $c9   for arithmetic coding, usually unsupported
    SOF10 = $ca   usually unsupported
    SOF11 = $cb   usually unsupported

    SOF13 = $cd   usually unsupported
    SOF14 = $ce   usually unsupported
    SOF15 = $cf   usually unsupported

    DHT   = $c4   Define Huffman Table, for details see below
    JPG   = $c8   undefined/reserved (causes decoding error)
    DAC   = $cc   Define Arithmetic Table, usually unsupported

   *RST0  = $d0   RSTn are used for resync, may be ignored
   *RST1  = $d1
   *RST2  = $d2
   *RST3  = $d3
   *RST4  = $d4
   *RST5  = $d5
   *RST6  = $d6
   *RST7  = $d7

    SOI   = $d8   Start Of Image
    EOI   = $d9   End Of Image
    SOS   = $da   Start Of Scan, for details see below
    DQT   = $db   Define Quantization Table, for details see below
    DNL   = $dc   usually unsupported, ignore
    DRI   = $dd   Define Restart Interval, for details see below
    DHP   = $de   ignore (skip)
    EXP   = $df   ignore (skip)

    APP0  = $e0   JFIF APP0 segment marker, for details see below
    APP15 = $ef   ignore

    JPG0  = $f0   ignore (skip)
    JPG13 = $fd   ignore (skip)
    COM   = $fe   Comment, may be ignored

 All other segment types are reserved and should be ignored (skipped).


SOF0: Start Of Frame 0:
~~~~~~~~~~~~~~~~~~~~~~~

  - $ff, $c0 (SOF0)
  - length (high byte, low byte), 8+components*3
  - data precision (1 byte) in bits/sample, usually 8 (12 and 16 not
    supported by most software)
  - image height (2 bytes, Hi-Lo), must be >0 if DNL not supported
  - image width (2 bytes, Hi-Lo), must be >0 if DNL not supported
  - number of components (1 byte), usually 1 = grey scaled, 3 = color YCbCr
    or YIQ, 4 = color CMYK)
  - for each component: 3 bytes
     - component id (1 = Y, 2 = Cb, 3 = Cr, 4 = I, 5 = Q)
     - sampling factors (bit 0-3 vert., 4-7 hor.)
     - quantization table number

 Remarks:
  - JFIF uses either 1 component (Y, greyscaled) or 3 components (YCbCr,
    sometimes called YUV, colour).


APP0: JFIF segment marker:
~~~~~~~~~~~~~~~~~~~~~~~~~~

  - $ff, $e0 (APP0)
  - length (high byte, low byte), must be >= 16
  - 'JFIF'#0 ($4a, $46, $49, $46, $00), identifies JFIF
  - major revision number, should be 1 (otherwise error)
  - minor revision number, should be 0..2 (otherwise try to decode anyway)
  - units for x/y densities:
     0 = no units, x/y-density specify the aspect ratio instead
     1 = x/y-density are dots/inch
     2 = x/y-density are dots/cm
  - x-density (high byte, low byte), should be <> 0
  - y-density (high byte, low byte), should be <> 0
  - thumbnail width (1 byte)
  - thumbnail height (1 byte)
  - n bytes for thumbnail (RGB 24 bit), n = width*height*3

 Remarks:
  - If there's no 'JFIF'#0, or the length is < 16, then it is probably not
    a JFIF segment and should be ignored.
  - Normally units=0, x-dens=1, y-dens=1, meaning that the aspect ratio is
    1:1 (evenly scaled).
  - JFIF files including thumbnails are very rare, the thumbnail can usually
    be ignored.  If there's no thumbnail, then width=0 and height=0.
  - If the length doesn't match the thumbnail size, a warning may be
    printed, then continue decoding.


DRI: Define Restart Interval:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  - $ff, $dd (DRI)
  - length (high byte, low byte), must be = 4
  - restart interval (high byte, low byte) in units of MCU blocks,
    meaning that every n MCU blocks a RSTn marker can be found.
    The first marker will be RST0, then RST1 etc, after RST7
    repeating from RST0.


DQT: Define Quantization Table:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  - $ff, $db (DQT)
  - length (high byte, low byte)
  - QT information (1 byte):
     bit 0..3: number of QT (0..3, otherwise error)
     bit 4..7: precision of QT, 0 = 8 bit, otherwise 16 bit
  - n bytes QT, n = 64*(precision+1)

 Remarks:
  - A single DQT segment may contain multiple QTs, each with its own
    information byte.
  - For precision=1 (16 bit), the order is high-low for each of the 64 words.


DAC: Define Arithmetic Table:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 Current software does not support arithmetic coding for legal reasons.
 JPEG files using arithmetic coding can not be processed.


DHT: Define Huffman Table:
~~~~~~~~~~~~~~~~~~~~~~~~~~

  - $ff, $c4 (DHT)
  - length (high byte, low byte)
  - HT information (1 byte):
     bit 0..3: number of HT (0..3, otherwise error)
     bit 4   : type of HT, 0 = DC table, 1 = AC table
     bit 5..7: not used, must be 0
  - 16 bytes: number of symbols with codes of length 1..16, the sum of these
    bytes is the total number of codes, which must be <= 256
  - n bytes: table containing the symbols in order of increasing code length
    (n = total number of codes)

 Remarks:
  - A single DHT segment may contain multiple HTs, each with its own
    information byte.


SOS: Start Of Scan:
~~~~~~~~~~~~~~~~~~~

  - $ff, $da (SOS)
  - length (high byte, low byte), must be 6+2*(number of components in scan)
  - number of components in scan (1 byte), must be >= 1 and <=4 (otherwise
    error), usually 1 or 3
  - for each component: 2 bytes
     - component id (1 = Y, 2 = Cb, 3 = Cr, 4 = I, 5 = Q), see SOF0
     - Huffman table to use:
        - bit 0..3: AC table (0..3)
        - bit 4..7: DC table (0..3)
  - 3 bytes to be ignored (???)

 Remarks:
  - The image data (scans) is immediately following the SOS segment.


End of part 1.
=============================================================================

I've written a JPEG Decoding Unit for Borland/Turbo Pascal 7.0.  It's very
fast, since it uses Assembly routines for the critical algorithms.
Check out the program QPEG which is a shareware image viewer (JPEG, GIF,
Targa, PCX, BMP) -- it uses that unit.  The QPEG package also contains a
more detailed description of the JPEG unit and an order form for it
(including source code).  I'm also writing a JPEG decoding DLL which will
be available soon.

If you have access to the Internet, then you can get QPEG via FTP from one
of these sites:
   ftp.tu-clausthal.de  /pub/msdos/graphics (primary site, Germany)
   ftp.rahul.net        /pub/bryanw/qpeg
   wuarchive.wustl.edu  /pub/msdos_uploads/graphics
If you don't have Internet access, just send 5 $US or 5 DM (cash) to me
(to cover my expenses), and you'll get the shareware version of QPEG.
You must have at least a 386 processor and a VGA graphics card.

See my address (normal mail and electronic mail) at the top of this file.

}