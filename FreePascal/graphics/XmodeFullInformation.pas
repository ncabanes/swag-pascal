(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0147.PAS
  Description: X-Mode Full Information
  Author: ROBERT SCHMIDT
  Date: 11-26-94  05:02
*)

(*
Here is a great text for a start:
Title:  INTRODUCTION TO MODE X

Version:        1.7

Author:  Robert Schmidt

Copyright: (C) 1993 of Ztiff Zox Softwear - refer to Status below.

Last revision:  28-Aug-93

Figures: 1. M13ORG - memory organization in mode 13h
  2. MXORG - memory organization in unchained modes

  The figures are available both as 640x480x16 bitmaps
  (in GIF format), and as 7-bit ASCII text (ASC) files.

C sources: 1. LIB.C v1.1 - simple graphics library for planar,
                   256-color modes - optionally self-testing.

                Excerpts from the source(s) appear in this article.
                Whenever there are conflicts, the external source file(s),
  _not_ the excerpts provided here, are correct (or, at
  least, newest).

Status:  This article, its associated figures and source listings
  named above, are all donated to the public domain.
  Do with it whatever you like, just don't claim it's your
  work, or make money on it without doing some work
                yourself.  Please distribute the archive in its entirety.

  The standard disclaimer applies.

Index:  0. ABSTRACT
  1. INTRODUCTION TO THE VGA AND ITS 256-COLOR MODE
  2. GETTING MORE PAGES AND PUTTING YOUR FIRST PIXEL
  3. THE ROAD FROM HERE
  4. BOOKS ON THE SUBJECT
                5. BYE - FOR NOW


0. ABSTRACT

This text gives a fairly basic, yet technical, explanation to what, why
and how Mode X is.  It first tries to explain the layout of the VGA
memory and the shortcomings of the standard 320x200 256-color mode,
then gives instructions on how one can progress from mode 13h to a
multipage, planar 320x200 256-color mode, and from there to the
quasi-standard 320x240 mode, known as Mode X.

A little experience in programming the standard VGA mode 13h
(320x200 in 256 colors) is assumed.  Likewise a good understanding of
hexadecimal notation and the concepts of segments and I/O ports is
assumed.  Keep a VGA reference handy, which at least should have
definitions of the VGA registers at bit level.

Throughout the article, a simple graphics library for unchained (planar)
256-color modes is developed.  The library supports the 320x200 and
320x240 modes, active and visible pages, and writing and reading
individual pixels.


1. INTRODUCTION TO THE VGA AND ITS 256-COLOR MODE

Since its first appearance on the motherboards of the IBM PS/2 50, 60
and 80 models in 1987, the Video Graphics Array has been the de facto
standard piece of graphics hardware for IBM and compatible personal
computers.  The abbreviation, VGA, was to most people synonymous with
acceptable resolution (640x480 pixels), and a stunning rainbow of colors
(256 from a palette of 262,144), at least compared to the rather gory
CGA and EGA cards.

Sadly, to use 256 colors, the VGA BIOS limited the users to 320x200
pixels, i.e. the well-known mode 13h.  This mode has one good and one
bad asset.  The good one is that each pixel is easily addressable in
the video memory segment at 0A000h.  Simply calculate the offset using
this formula:

offset = (y * 320) + x;

Set the byte at this address (0A000h:offset) to the color you want, and
the pixel is there.  Reading a pixel is just as simple: just read a
byte.  This was heaven, compared to the hell of planes and masking
registers needed in 16-color modes.  Suddenly, the distance from a
graphics algorithm on paper to an implemented graphics routine was cut
down to a fraction.  The results were impressively fast too!

The bad asset is that mode 13h is also limited to only one page, i.e.
the VGA can only hold one screenful at any one time.  Most 16-color
modes let the VGA hold more than one page, and this enables you to show
one of the pages to the user, while drawing on another page in the
meantime.  Page flipping is an important concept in making flicker free
animations.  Nice looking and smooth scrolling is also almost impossible
in this mode using plain VGA hardware.

Now, the alert reader might say: "Hold on a minute!  If mode 13h enables
only one page, this means that there is memory for only one page.  But I
know for a fact that all VGAs have at least 256 Kb RAM, and one 320x200
256-color page should consume only 320*200=64000 bytes, which is less
than 64 Kb.  A standard VGA should room a little more than four 320x200
pages!"  Quite correct, and to see how the BIOS puts this limitation on
mode 13h, I'll elaborate a little on the memory organization of the VGA.

The memory is separated into four bit planes.  The reason for this stems
from the EGA, where graphics modes were 16-color.  Using bit planes, the
designers chose to let each pixel on screen be addressable by a single
bit in a single byte in the video segment.  Assuming the palette has
not been modified from the default, each plane represent one of the EGA
primary colors: red, green, blue and intensity.  When modifying the bit
representing a pixel, the Write Plane Enable register is set to the
wanted color.  Reading is more complex and slower, since you can
only read from a single plane at a time, by setting the Read Plane
Select register.  Now, since each address in the video segment can
access 8 pixels, and there are 64 Kb addresses, 8 * 65,536 = 524,288
16-color pixels can be accessed.  In a 320x200 16-color mode, this makes
for about 8 (524,288/(320*200)) pages, in 640x480 you get nearly 2
(524,288/(640*480)) pages.

In a 256-color mode, the picture changes subtly.  The designers decided
to fix the number of bit planes to 4, so extending the logic above to 8
planes and 256 colors does not work.  Instead, one of their goals was to
make the 256-color mode as easily accessible as possible.  Comparing the
8 pixels/address in 16-color modes to the 1-to-1 correspondence of
pixels and addresses of mode 13h, one can say that they have
succeeded, but at a certain cost.  For reasons I am not aware of, the
designers came up with the following effective, but memory-wasting
scheme:

The address space of mode 13h is divided evenly across the four bit
planes.  When an 8-bit color value is written to a 16-bit address in the
VGA segment, a bit plane is automatically selected by the 2 least
significant bits of the address.  Then all 8 bits of the data is written
to the byte at the 16-bit address in the selected bitplane (have a look at
figure 1).  Reading works exactly the same way.  Since the bit planes are so
closely tied to the address, only every fourth byte in the video memory is
accessible, and 192 Kb of a 256 Kb VGA go to waste.  Eliminating the
need to bother about planes sure is convenientand beneficial, but in
most people's opinion the loss of 3/4 of VGA memory is too much.

To accomodate this new method of accessing video memory, the VGA
designers introduced a new configuration bit called Chain-4, which
resides as bit number 3 in index 4 of the Sequencer.  In 16-color modes,
the default state for this bit is off (zero), and the VGA operates as
described earlier.  In the VGA's standard 256-color mode, mode 13h, this
bit is turned on (set to one), and this turns the tieing of bit
planes and memory address on.

In this state, the bit planes are said to be chained together.

Note that Chain-4 in itself is not enough to set a 256-color mode -
there are other registers which deals with the other subtle changes in
nature from 16 to 256 colors.  But, as we now will base our work with
mode X on mode 13h, which already is 256-color, we won't bother about
these for now.


2. GETTING MORE PAGES AND PUTTING YOUR FIRST PIXEL

The observant reader might at this time suggest that clearing the
Chain-4 bit after setting mode 13h will give us access to all 256 Kb of
video memory, as the two least significant bits of the byte address
won't be `wasted' on selecting a bit plane.  This is correct.  You might
also start feeling a little uneasy, because something tells you that
you'll instantly loose the simple addressing of mode 13h.  Sadly, that
is also correct.

At the moment Chain-4 is cleared, each byte offset addresses *four*
sequential pixels.  Before writing to a byte offset in the video
segment, you should make sure that the 4-bit mask in the Write Plane
Enable register is set correctly, according to which of the four
addressable pixels you want to modify.  In essence, it works like a
16-color mode with a twist.  See figure 2.

So, is this mode X?  Not quite.  We need to elaborate to the VGA how to
fetch data for refreshing the monitor image.  Explaining the logic
behind this is beyond the scope of this getting-you-started text, and it
wouldn't be very interesting anyway.  Here is the minimum snippet of
code to initiate the 4 page variant of mode 13h, written in plain C,
using some DOS specific features (see header for a note about the
sources included):

----8<-------cut begin------

/* width and height should specify the mode dimensions.  widthBytes
   specify the width of a line in addressable bytes. */

int width, height, widthBytes;

/* actStart specifies the start of the page being accessed by
   drawing operations.  visStart specifies the contents of the Screen
   Start register, i.e. the start of the visible page */

unsigned actStart, visStart;

/*
 * set320x200x256_X()
 * sets mode 13h, then turns it into an unchained (planar), 4-page
 * 320x200x256 mode.
 */

set320x200x256_X()
 {

 union REGS r;

 /* Set VGA BIOS mode 13h: */

 r.x.ax = 0x0013;
 int86(0x10, &r, &r);

 /* Turn off the Chain-4 bit (bit 3 at index 4, port 0x3c4): */

 outport(SEQU_ADDR, 0x0604);

 /* Turn off word mode, by setting the Mode Control register
    of the CRT Controller (index 0x17, port 0x3d4): */

 outport(CRTC_ADDR, 0xE317);

 /* Turn off doubleword mode, by setting the Underline Location
    register (index 0x14, port 0x3d4): */

 outport(CRTC_ADDR, 0x0014);

 /* Clear entire video memory, by selecting all four planes, then
    writing 0 to the entire segment. */

 outport(SEQU_ADDR, 0x0F02);
 memset(vga+1, 0, 0xffff); /* stupid size_t exactly 1 too small */
 vga[0] = 0;

 /* Update the global variables to reflect dimensions of this
    mode.  This is needed by most future drawing operations. */

        width   = 320;
 height = 200;

        /* Each byte addresses four pixels, so the width of a scan line
           in *bytes* is one fourth of the number of pixels on a line. */

        widthBytes = width / 4;

        /* By default we want screen refreshing and drawing operations
           to be based at offset 0 in the video segment. */

 actStart = visStart = 0;

 }

----8<-------cut end------

As you can see, I've already provided some of the mechanics needed to
support multiple pages, by providing the actStart and visStart variables.
Selecting pages can be done in one of two contexts:

 1) selecting the visible page, i.e. which page is visible on
    screen, and

 2) selecting the active page, i.e. which page is accessed by
    drawing operations

Selecting the active page is just a matter of offsetting our graphics
operations by the address of the start of the page, as demonstrated in
the put pixel routine below.  Selecting the visual page must be passed
in to the VGA, by setting the Screen Start register.  Sadly enough, the
resolution of this register is limited to one addressable byte, which
means four pixels in unchained 256-color modes.  Some trickery is needed
for 1-pixel smooth, horizontal scrolling, but I'll make that a subject
for later.  The setXXXStart() functions provided here accept byte
offsets as parameters, so they'll work in any mode.  If widthBytes and
height are set correctly, so will the setXXXPage() functions.

----8<-------cut begin------

/*
 * setActiveStart() tells our graphics operations which address in video
 * memory should be considered the top left corner.
 */

setActiveStart(unsigned offset)
 {
 actStart = offset;
 }

/*
 * setVisibleStart() tells the VGA from which byte to fetch the first
 * pixel when starting refresh at the top of the screen.  This version
 * won't look very well in time critical situations (games for
 * instance) as the register outputs are not synchronized with the
 * screen refresh.  This refresh might start when the high byte is
 * set, but before the low byte is set, which produces a bad flicker.
 */

setVisibleStart(unsigned offset)
 {
 visStart = offset;
 outport(CRTC_ADDR, 0x0C);  /* set high byte */
 outport(CRTC_ADDR+1, visStart >> 8);
 outport(CRTC_ADDR, 0x0D);  /* set low byte */
 outport(CRTC_ADDR+1, visStart & 0xff);
 }

/*
 * setXXXPage() sets the specified page by multiplying the page number
 * with the size of one page at the current resolution, then handing the
 * resulting offset value over to the corresponding setXXXStart()
 * function.  The first page number is 0.
 */

setActivePage(int page)
 {
 setActiveStart(page * widthBytes * height);
 }

setVisiblePage(int page)
 {
 setVisibleStart(page * widthBytes * height);
 }

----8<-------cut end------

Due to the use of bit planes, the graphics routines tend to get more
complex than in mode 13h, and your first versions will generally tend to
be a little slower than mode 13h algorithms.  Here's a put pixel routine
for any unchained 256-color mode (it assumes that the 'width' variable
from the above code is set correctly).  Optimizing is left as an exercise
to you, the reader.  This will be the only drawing operation I'll cover
in this article.

----8<-------cut begin------

putPixel_X(int x, int y, char color)
 {

 /* Each address accesses four neighboring pixels, so set
    Write Plane Enable according to which pixel we want
    to modify.  The plane is determined by the two least
    significant bits of the x-coordinate: */

 outportb(0x3c4, 0x02);
 outportb(0x3c5, 0x01 << (x & 3));

 /* The offset of the pixel into the video segment is
    offset = (width * y + x) / 4, and write the given
    color to the plane we selected above.  Heed the active
    page start selection. */

 vga[(unsigned)(widthBytes * y) + (x / 4) + actStart] = color;

 }

char getPixel_X(int x, int y)
 {

 /* Select the plane from which we must read the pixel color: */

 outport(GRAC_ADDR, 0x04);
 outport(GRAC_ADDR+1, x & 3);

 return vga[(unsigned)(widthBytes * y) + (x / 4) + actStart];

 }

----8<-------cut end------


However, by now you should be aware of that the Write Plane Enable
register isn't limited to selecting just one bit plane, like the
ReadPlane Select register is.  You can enable any combination of all
four to be written.  This ability to access 4 pixels with one
instruction helps quadrupling the speed, especially when drawing
horizontal lines and filling polygons of a constant color.  Also, most
block algorithms can be optimized in various ways so that they need only
a constant number of OUTs (typically four) to the Write Plane Enable
register.  OUT is a relatively slow instruction.

The gained ability to access the full 256 Kb of memory on a standard
VGA enables you to do paging and all the goodies following from that:
smooth scrolling over large maps, page flipping for flicker free
animation... and I'll leave something for your own imagination.
*)
