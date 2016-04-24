(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0034.PAS
  Description: MODE-X Information
  Author: DAVID MOHORN
  Date: 11-26-94  05:04
*)


■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
■■■■■■■■    SyNeRgY DeSiGn presents a production by LORD HELMET    ■■■■■■■■
■■■■■■■■                        MODE X                             ■■■■■■■■
■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

The purpose of this file is to provide the information necessary for using 
mode x in your programs. Some knowledge of the VGA card and assembly program-
ming are required to understand this text, although I'll try to make it as
complete and easy as possible. I was working on a textfile about 3D graphics,
but this will be delayed for a while since I started experimenting with the
VGA card some time ago. This file should be an even greater help for coders
so it will surely make up for this delay.

What is mode x ?
----------------

Now there's a difficult question and to be honest, I can't really answer it.
Ask this question to ten coders and you will get at least five different 
answers. The problem is : mode x is non-standard. In my opinion it's the
ordinary mode 13 hex (320x200x256) with some registers altered adding some pos-
sibilities to the normal graphics output. Mode x is a great help for programs
that require fast graphics output and it's excellent for scrollers. Before I go
on I will explain some things about mode 13h and the VGA card in general. If
you know the VGA card well enough you can skip this part, but don't go thinking
"hey, I don't need this VGA crap" too easily, because the clues to mode x are
included in the following paragraph, so I would surely advise you to read it.

The VGA card & mode 13h
-----------------------

As you may know by now, the VGA card's memory is mapped into the computer's
central memory at segments A000h & B000h. In most modes, these segments aren't
both used at the same time, but one's used for color output (segment A000h),
whereas the other is used for monochrome output (segment B000h), allowing more
than one graphics card to be present in your computer. Segment B000h isn't nor-
mally used in mode 13h with color output (there are some VGA cards which do 
allow the use of the second segment, such as the Trident cards), so forget
about that one. Segment A000h is the important one. Now, when normally using
this part of memory for graphics output you might think that it is organized as
follows :
                        ┌───────────────────────┐
               OFFSET 0 │. <- pixel 0           │
                        │                       │
                        │                       │
                        │                       │
                        │                       │
                        │                       │
           OFFSET 63999 │        pixel 63999 ->.│
                        └───────────────────────┘

What this means is : the VGA memory would be organized as one big chunk of
memory, 64000 bytes long. If you still think this is the case, FORGET IT. 
The VGA memory ISN'T organized like this, but in bitplanes. Those of you who 
have worked with EGA must surely know what programming with bitplanes means. 
Let's take a look at how the VGA memory really is organized :

        Bit plane 3     ->       ┌───────────────────────┐ -
        Bit plane 2     ->    ┌──┴────────────────────┐  │ |
        Bit plane 1     -> ┌──┴────────────────────┐  │  │ | each plane
        Bit Plane 0  -> ┌──┴────────────────────┐  │  │  │ | is 64000
                        │                       │  │  │  │ | bytes long
                        │                       │  │  │  │ |
                        │                       │  │  │  │ |
                        │                       │  │  │  │ |
                        │                       │  │  ├──┘ -
                        │                       │  ├──┘ 
                        │                       ├──┘
                        └───────────────────────┘
                        
So, as you can see, the VGA memory consists of four bit planes of 64000 bytes
each, just like the EGA. All four bit planes are mapped at adress A0000h. The
way the bit planes in VGA mode 13h are used differs from the EGA. In EGA modes
the bit planes are used to determine the value of the pixels (0-16). They are 
(in EGA) organized as four 64000 bytes long bit chains (and not byte chains).
In VGA mode 13h they are organised as four byte chains. The four bit planes are
chained together and the pixels are spread over these bit planes. More 
specific : the first pixel = pixel 0 (1 byte) is mapped in bit plane 0 at
offset 0, pixel 1 is mapped in bit plane 1 at offset 0, pixel 2 in bit plane
2 at offset 0, pixel 3 in bit plane 3 at offset 0, pixel 4 in bit plane 0 at
offset 1 and so on. So far for the VGA mode 13h.

A first question that pops up is : how come I don't notice the fact that the
pixels are chained over the four bit planes when using mode 13h ? Well, because
this is done automatically by the VGA card. It looks at the two least signifi-
cant bits in the offset address to determine on which plane the pixel
should be mapped. The offset within this bit plane is the original offset divi-
ded by four. This may sound confusing, so here's an example :
Suppose I want to set the pixel value of the pixel at position (50,50) to 150.
Therefore I would change the byte value of the byte at address A000:3EB2
(offset = 50*320 + 50 = 16050 = 3EB2 hex) to 150. In assembler it would look
about like this :
                        mov     ax,0A000h
                        mov     es,ax
                        mov     di,3EB2h
                        mov     al,150
                        stosb

Now, the VGA card will look at the 2 least significant bits in the offset, in
this case 3EB2h = 0011111010110010 binary. These bits are 10 binary = 2, so the
pixel will be mapped in bit plane 2. The offset within this bit plane is
3EB2h / 4 = 0FACh = 4012.
This automatic mapping is also the reason why you can only access one page in
mode 13h (a page is a piece of memory on the card large enough to contain an
entire screen, so in mode 13h a page is 64000 bytes long) : since the offset
range is limited to 65536, it's impossible to reach the other 3 pages (don't
try using 386 inctruction code to force 32-bits offsets, it won't work).


Those of you who have tried to make smooth animations such as vectors, sprites
and scrollers know that it's impossible to achieve this when accessing the 
VGA memory directly. A first solution here would be to use a 'virtual page' :
a 64000 bytes long array in central memory in which the screen output is
first built and then copied to the screen. This works but has 2 disadvantages :
it takes 64000 bytes and has to be copied (which takes some time). Therefore,
a multipage system is the best solution : several pages allowing pageswapping
and no time is lost during the swapping. As you already noticed, it's impossi-
ble to achieve this in standard mode 13h (except for some cards, which use seg-
ment B000h as a second page), although there's enough space for four pages.
This is where mode x comes in.

Mode x - that's the way to do it
--------------------------------

All the previous problems are solved by changing the normal graphics system to
mode x. This is achieved by changing the chain four bit in the memory mode
register (port 3C4/3C5, index 4) from 1 to 0 (on some cards it's necessary to
alter more than one register, but I'll get to this later). What effect does
this have ? Simple, it just disables the automatic mapping and allows the user
to access the bit planes himself. This involves some changes in the way 
graphics output should be used. First, after this bit has been altered, you
gain control over all of the 256000 bytes video memory (4 pages in 320x200x256)
Second, since the automatic mapping is disabled, you have to access the bit
planes yourself (the chained bitplanes system remains, so you have to do exact-
ly what the VGA card does with automatic mapping). Last but not least, you have
to know how to change the current page. We'll get back to this later, first a
sample code which shows how to change to mode x (you have to change to mode
13h first) :

  mov   dx,3C4h                 ; select sequencer registers
  mov   al,4                    ; index 4 -> memory mode register
  out   dx,al                   
  inc   dx
  in    al,dx                   ; read the original value
  and   al,NOT 8                ; turn off chain 4 (bit 3)
  or    al,4                    ; turn off odd/even (bit 2)
  out   dx,al                   ; write the new value
  mov   dx,3CEh                 ; select graphics controller registers
  mov   al,5                    ; index 5 -> mode register
  out   dx,al
  inc   dx
  in    al,dx                   ; read original value
  and   al,NOT 16               ; turn off odd/even (bit 4)
  out   dx,al                   ; write new value
  dec   dx
  mov   al,6                    ; index 6 -> miscellanous register
  out   dx,al                   
  inc   dx
  in    al,dx                   ; read original value
  and   al,NOT 2                ; turn off chain odd/even (bit 1)
  out   dx,al                   ; write original value

  mov   dx,3D4h                 ; select CRCT registers
  mov   al,14h                  ; index 14h -> Underline location register
  out   dx,al
  inc   dx
  in    al,dx                   ; read original value
  and   al,NOT 64               ; turn off doubleword (bit 6)
  out   dx,al                   ; write new value
  dec   dx
  mov   al,17h                  ; index 17h -> Mode control register
  out   dx,al
  inc   dx
  in    al,dx                   ; read original value
  or    al,16                   ; turn on byte mode bit (bit 6)
  out   dx,al                   ; write new value

As you can see this sample code does nothing exceptional, it just alters cer-
tain bits in certain registers. The odd/even bits have to be changed to ensure
that the way the video memory is accessed is as I described above. Not changing
these bits can screw up the output (I'm not going to explain what these bits do
exactly, but take it from me : change them). The doubleword / word-byte bits
have to be changed to make sure all of the video memory can be accessed. As I
already explained, the chain four bit is the important one, but make sure to
change the others too for compatibility (only changing the chain four bit works
fine on my card, but I know it doesn't on some other cards).

Now that we know how to change to mode x, let's continue with the second step,
putting something on the screen (or rather on one of the pages). Let's use the
same example as for the standard mode 13h : suppose I want to change the pixel
value of the pixel at position (50,50) to 150. In normal mode 13h this would
involve changing the value of the byte at address A000:3EB2 to 150. In mode x
this means I have to do what the VGA card normally does for me : change the
byte value at offset 0FACh in bit plane 2 to 150 (look at the previous example
if you don't understand how I found these numbers). This is what it would look
like in assembler :

  mov   ax,A000h
  mov   es,ax                   ; select VGA memory segment
  mov   dx,3C4h                 ; select sequencer registers
  mov   al,2                    ; index 2 -> map mask register
  inc   dx
  mov   al,4                    ; change value to 4 : enable plane 2 only
  out   dx,al
  mov   di,0FACh                ; set offset to 0FACh
  mov   al,150                  ; value to write
  stosb

Nothing special here either. Now suppose I want to access a different page than
page 1 (say page 3). Quite simple, just increase the offset by 32000. Here's an
overview of the offset ranges for the four pages in mode x :

                page 1 : OFFSET 0     - 15999
                page 2 : OFFSET 16000 - 31999
                page 3 : OFFSET 32000 - 47999
                page 4 : OFFSET 48000 - 63999

If you try this out you will notice that it's impossible to see the changes on
the other pages (the current page selection interrupt routine doesn't work).
You have to select the current page through the Start Address. What exactly is
this ? Consider the screen as a window through which the contents of the video
memory can be viewed. In standard mode 13h this screen is as large as the
accessable video memory. In mode x the accessable video memory is four times
larger than as the screen size. The Start Address is used to determine which 
part of the video memory is shown on the screen. Suppose I use the offset 
ranges as shown above and I want to view page 3. Therefore, I would have to
change the Start Address to 32000. To alter the Start Address two registers
have to be changed : Start Address High and Start Addres Low. The reason for
this is the fact that the start addres is an offset and therefore a 16-bit
value, whereas the VGA registers are 8 bits large. Start Address High con-
tains the 8 most significant bits of this 16 bit value and start address low
the 8 least significant bits. Enough blabla; here's an assembler code which
changes the start address value to 32000 (standard value is 0) :

  mov   dx,3D4h                 ; select CRCT register
  mov   al,Ch                   ; index 12 -> start address high
  out   dx,al
  inc   dx
  mov   al,125                  ; 32000/256 = 125
  out   dx,al                   ; write new value
  dec   dx
  mov   al,Dh                   ; index 13 -> start address low
  out   dx,al
  inc   dx
  xor   al,al                   ; start address low = 0 (32000 mod 256 = 0)
  out   dx,al                   ; write new value (not really necessary since
                                ; standard value is 0)

That's about all there's to know about the use of mode x. Some things remain
to be told though, especially about certain applications for mode x.

Mode x - pro's and con's
------------------------

Now that you know how to use mode x, let's take a look at what can be done with
it. A first and easy application is, of course, a pageswapping routine. Since
more than one page is available pageswapping lies at hand. Only two pages are
needed for this purpose, but the two spare pages can come in handy. A great ad-
vantage here is the fact that, although being non-standard, mode x works on all
VGA cards (as far as I know). This is not the case with the Trident swapping
routine I mentioned earlier (Flame here to the coders who still use this tech-
nique; I know it's easy, but it only works on a quite small number of PC's).

Another great use of mode x is a scrolling routine (both vertically and hori-
zontally). By changing the start address by a certain amount continously, you
can scroll through the different pages. Try experimenting with this a bit and
you'll surely get some nice results.

Last but not least, mode x is great for combining with other applications such
as split screen and tweak mode (I'll get back to this one in a moment). Again,
experiment and you'll be astounished by the numerous advantages of mode x.

Now, after all these advantages you may get a bit too optimistic. Sorry to kill
the mood like this, but there are also some great disadvantages to mode x.
First, suppose you want to display an ordinary 320x200x256 picture in mode x.
Since the pages are spread over 4 bit planes, you'll need to access them (the
bit planes) every time you put a pixel on the screen. For a picture that is
not real-time calculated, there's a simple solution : divide the picture in 4
, one picture for each bit plane. This way you only have to access the map
mask register four times. For other real-time applications such as vectors, it
isn't all this simple. Suppose I want to put a wireframed vector on the screen.
I would have to change the linedrawing routine making it more complex. The most
simple solution is to calculate the new offset/bit plane for every pixel in the
line. This is the easiest solution, but also the slowest. A second solution
is to change the routine so that it draws 4 dotted lines on each bit plane,
reducing the number of map mask register accesses to 4. It's a real drag to
code, but it's the fastest way. A third possibility is to draw real-time pictu-
res on a 'virtual page' and then overlay it on the video pages. This is also
easy but slow. As you can see, I haven't figured out a good solution for this
problem, so if you have, please do let me know.

Mode x, mode y, tweaked mode, etc ...
-------------------------------------

As I mentioned before, mode x works on all VGA cards - although being non-
standard - but as I also mentioned before, it means something different to
some other coders. This bring us to mode y and tweaked mode. I can't really
tell what mode y is exactly, but I guess it's similar to tweaked mode (if some-
one knows what it is, let me know). Tweaked mode probably sounds more familiar
to most of you. It's also a non-standard mode (or rather modes) which also
works on all VGA cards and allows resolutions such as 320x400, 360x480 and so
on. The problem here is that tweaked mode implies mode x, since it's necessary
to access more than 64000 bytes of video memory. This makes it all a bit con-
fusing and I guess mode x and tweaked mode are one and the same to a lot of
coders. There are lots of sources available for mode x and tweaked mode, but
they are (unfortunately) almost always combined. I didn't find any file explai-
ning how mode x works with a 320x200 resolution. This is also the reason why I
wrote this textfile. I sure hope it helped you out and saved you the time it
took me to find out how mode x works. If you want to find out more about
tweaked mode, I would advise you to get one of the so many files available on
most BBS's (such as The Graphics Engine or VGAkit).

Epilogue
--------

Yep, this is about it. There isn't anything left to tell about mode x - at
least nothing I can think about. If you do have questions or experienced pro-
blems with this text, be free to let me know. Try not to ask too simple 
questions such as "what's a pixel ?" or "hey, I disassembled my mouse but
didn't find the VGA card", I won't respond to those. Don't ask me to teach you
everything on the VGA card or on assembler either, just things that concern
mode x. You can try to contact me concerning coding in general too. Here's
where you can reach me :

BBS's :
-------

ZEUS :  +32-(0)9-264.47.51 (refer to THOMAS VIDTS)
BUSTER : node 1 : +32-(0)53-77.23.47 (refer to RETARD ED)

INTERNET ADDRESS : VIDTS@WET.RUG.AC.BE

