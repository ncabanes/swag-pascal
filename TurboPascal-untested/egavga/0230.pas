{
From: myles@giaec.cc.monash.edu.au (Myles Strous)

         DOS Super VGA / VESA programming notes - by Myles.
         --------------------------------------------------
         
         
         Send updates and errors to myles@giaec.cc.monash.edu.au 
         Comments on my grammar and style are not welcome. 8-)


         These notes currently only cover the high-resolution 
         256-colour modes.  I may extend that to HiColor and TrueColor 
         modes if and when I get the time.  (If anyone else wants to 
         do that bit, feel welcome !)

         This document is meant to be a pointer, not a comprehensive 
         treatise.

         My information base is biased by my Turbo Pascal hobbyist's 
         background. Please feel free to send me corrections or 
         updates.

         Introduction:
         -------------
         
         
         SuperVGA programming uses screen data that can easily exceed
         1 MB in size. However, the normal VGA card only offers a 64k
         memory access at A000h (some cards provide 128k).
         
         How do you get to all that video memory ?
         You know it's there - after all, your card documentation states
         that you have e.g. 512k of memory on your video card, enough to
         handle e.g. 800 x 600 x 256.
         
         You may even have experimented and found that you can change to 
         this mode, but can only write pixels to a narrow band at the
         top of the screen.(Surprise! That narrow band is 64k in size.)
         (Except, of course, if it 128k - read on.)
         
         The answer is in a technique called bank switching, where you 
         use the 64k at A000h as a window onto your video card's memory.
         
         The techniques and functions to do this vary from card to
         card, because of historical reasons. Read on.
         

         History: 
         --------

         IBM defined MDA (monochrome), CGA, EGA, the MCGA (found  in  
         some early  PS/2  models,  it  never  became  a  wide-spread 
         standard), and in 1987, the VGA (and the 8514/A).

         VGA was backwards compatible with all the previous standards,
         including the   320x200,256-colour   MCGA   mode.  It  also  
         introduced a new mode, 640x480 with 16 colours,  which  was  
         basically an extension of EGA's 640x350,16-colour mode, with 
         one major advantage - square pixels (so that if you plotted  
         the points  for  a  circle,  it looked like a circle, not an 
         ellipse). There was also a 640*480 2-colour mode on the MCGA.

         If you wanted higher resolutions you had to pay quite a bit  
         for IBM's   professional   level   card,   the   8514/A,  a  
         high-resolution card capable  of  256-colour  modes  up  to  
         1024x768 (interlaced). 
         However, this card was proprietary - IBM didn't  
         release the register-level details.


         Each of the other video card manufacturers then came up with 
         their own  high  resolution  cards.  However,  they were all 
         implemented differently.   640x480  in  256  colours,  for   
         example, may  have been mode 34h on one manufacturer's card, 
         mode 56h on another's, and mode 62h on yet another.   (N.B.  
         These are just false numbers to give you the idea.) Similarly 
         for 800x600, 1024x768, and other modes.

         Also, some manufacturers implemented 128k banks. Manufacturers 
         also differed on whether banks (as a subsection of the video 
         card's memory) could start only 64k apart, or 4k apart (i.e. 
         possibly overlapping), or ....
         You get the picture. Non-standard.

         That 64k of memory:
         -------------------

  
         For 256-colour modes, each byte in  the  64k  is  simply  a
         palette value,  or  the  colour  number  of  a  pixel  (Yes, 
         256-colour graphics is just pixel painting by the numbers).  
         This means  the  number  is  just  an array index into a 256
         member array of 6-bit red, green and blue values, giving you 
         256 colours out of 256k (2^18) possible values.

         -------------------------------------------------------------
         HiColor and  TrueColor  cards use a different RAMDAC chip (a 
         digital to analogue chip converting the digital  values  in  
         video memory to analogue output for the monitor). 

         HiColor and TrueColor modes represent their colours directly 
         - you  specify  the  red-green-blue  values  for each pixel, 
         rather than choosing from a limited array of colours.

         15-bit modes provide 32k colours - each colour is represented 
         as a  two-byte  value  xrrrrrgggggbbbbb,  where the x bit is 
         unused.  16-bit modes provide 64k colours, and  provide  an  
         extra bit  for  green  (I think) - rrrrrggggggbbbbb.  24-bit 
         modes use three-byte values, one byte (8-bits) each for red, 
         green, and blue.

         SuperVGA does not support the 32-bit and 64-bit modes found  
         on some specialist hardware, although you may sometimes find 
         32-bit (and maybe even 64-bit ?) files.
         Some SuperVGA cards e.g. the S3-864, have pseudo-32-bit 
         modes. (Further information, anyone ?)

         32-bits provides another byte for an alpha value - which is a 
         transparency value used for overlaying one image on another - 
         also good for such things as  anti-aliasing  edges.  64-bit  
         values are  like  32-bit,  but provide 2 bytes each for red, 
         green, blue, and alpha.           
         --------------------------------------------------------------

         Programmers have to write routines to detect  (or  ask  the  
         user:-p) which card is present, and then write card-specific 
         routines to handle the graphics routines for that card. If a 
         new card  comes out, from a different manufacturer or even a 
         different model  of  card  from  the  same   manufacturer,   
         programmers have to write new routines to support that card, 
         which means that first they have to get  details  from  the  
         manufaturer, and if they do it properly, they needed to find 
         a card to test their routines, (or a beta tester to do it for 
         them).  You  could provide these routines either in the body
         of your code, or write external  drivers  or  configuration  
         files.  It is possible to write moderately generic code that 
         loads the specific details from an external file.

         The manufacturers usually provide drivers for a few programs 
         (Autocad, Windows, etc.). Also, the information supplied
         in the user manual that comes with the card is usually only the
         mode numbers for that card, not the bank-switching code. Sigh.
         

         Not surprisingly, most programs don't support ALL the cards  
         available, and  many  programmers  choose not to support any 
         SuperVGA cards.   It  isn't  worth  the  effort,  and  your  
         customers always  ask  when  you  are going to support THEIR 
         particular card.

         The manufacturers were miffed  enough  by  this  that  they  
         actually got  together  and  formed  the  Video  Electronics 
         Standards Association (VESA).  They defined a new  standard  
         programmer's interface so that programmers would only have to 
         write one set of graphics routines for SuperVGA.  This  was  
         the VESA  standard. It has nothing to do with VESA Local Bus 
         (VLB), which is another standard from the same group about a 
         completely different  hardware  problem.   (You think that's 
         confusing - VESA are coming/have come out with another VESA  
         standard for sound device interfacing.) This standard is also 
         known as the VESA VBE standard (Video BIOS Extensions).

         The VESA VBE standard implements video card routines through 
         an  extension of  the  Interrupt  10h BIOS routines 
         (subfunction 4Fh).

         Most video cards in existence implement VESA through the use 
         of a  VESA VBE TSR  (TSR = Terminate and Stay Resident 
         program, also known as a memory-resident program.), often 
         known as a  VESA driver  (not  entirely  accurate), although 
         newer video cards may implement the VESA VBE standard in 
         hardware.  Let  me  re-iterate that  this  is  an entirely 
         different matter from whether they are a VESA Local Bus (VLB) 
         card.

         A VESA VBE driver should have been  included  on  the  disk  
         of  drivers and utilities you got with your video card. 
         However, this, along with a number  of  VESA  VBE drivers  
         available  on  Internet, may be out of date.  Most VESA TSRs
         are specific to a particular card.

         If you don't have a VESA VBE driver that provides  support
         for  version 1.2  of the VESA VBE standard, look for a 
         shareware VESA utility, last seen as UNIVBE50.ZIP, by Kendall  
         Bennett  of  SciTech Software. This is a shareware TSR that 
         provides VESA extensions for practically every SuperVGA card 
         in existence. Inexpensive personal  registration.  Licences  
         available for including it with your own programs.

         The current version of the VESA VBE standard is 1.2 - you 
         should really try  and  get a driver which supports version 
         1.2, as there are a number of useful extra extensions on 
         earlier versions (such as 32k/64k/16.7M colour modes)



         VESA subfunctions (as of VESA standard version 1.2) are:
 
  subfunction 00 - get SuperVGA information
  subfunction 01 - get SVGA mode information
  subfunction 02 - set SuperVGA video mode
  subfunction 03 - get current video mode
  subfunction 04 - save/restore SuperVGA video state
  subfunction 05 - bank switch
  subfunction 06 - get/set logical scan line length
  subfunction 07 - get/set display start
  subfunction 08 - get/set DAC palette control


         There is supposedly a version 2.0 of the VESA video standard 
         coming out, with BitBlt, fillBox, drawLine, etc.

         -----------------------------------------------------------
         A note on VESA and speed :

         Some people who should know better, if they'd bothered to 
         stop and think about things, and investigate VESA, have 
         stated that programming using the VESA VBE is s-l-o-w, 
         apparently because they hear the word "BIOS" and tune out,
         because in the past it has been emphasised that using the 
         BIOS to e.g. draw a pixel, is incredibly slow, compared to 
         writing your own routines to just move graphics data into 
         video memory.

         However, apart from setting values and graphics mode, usually 
         at the beginning of your program, and getting information 
         pertaining to the mode you are using (a few BIOS calls at
         most, done once only), you don't have to use the BIOS much at 
         all. Once you've set a bank, the VESA standard allows you to 
         write directly to video memory (well, a 64k subset of it), 
         indeed almost encourages it. True, you can use function 05 to 
         change banks, but you'll find that the time spent changing 
         banks is minimal compared to other aspects of your program, 
         e.g. the time spent on floodfills and line drawing, etc. 
         However, if you begrudge even the time spent changing banks, 
         the VESA VBE standard also includes a function returning the 
         direct address of the video card's bank changing routine, so 
         you can use it directly in a far call.
         
         In other words, using the VESA VBE will not slow down your 
         program, and will allow it to work on most video cards in 
         SuperVGA modes without much extra work from you the 
         programmer.


         -----------------------------------------------------------

         Warning: VESA is not a completely simple solution. You have  
         to find  out  whether  the  card  it  is being used on has 2 
         "windows", whether one or both windows are readable  and/or  
         writeable, how  big are the jumps by which you can move the 
         window around (granularity), how big the windows are,  etc.  
         While these routines will only have to be written once, there 
         is a bit of work to be done at the start to make your  VESA  
         routines generic to all VESA cards.

         -----------------------------------------------------------

         Information and code.
         ---------------------

  ******  N.B. I am not willing to 
  supply FTP sites for these files - 
  I suggest you either use ARCHIE, or find out HOW
  to use archie - news.answers and comp.answers may
  be good places to start.
  Requests for FTP sites will be deleted from my mail
  without consideration.


         SVGABG55.ZIP - Jordan Hargrave's set of Super VGA BGI  drivers.
         If your card is not one of those catered for, it will also use
         a VESA driver. Shareware, register for source.  Uses the Graph 
         unit.  This is just like using the Borland BGI.

         VESATP11.ZIP - shareware (nagware) TPU , register for source. 
         On initialising  a  Super  VGA  mode,  you  get  an SuperVGA 
         advertisement for registration.  Otherwise much like the BGI 
         interface, except you don't use the Graph unit.

         EGOF11-6.ZIP
         EGOF11-7.ZIP - shareware, Turbo Pascal units. Mode X and VESA.

         VGADOC3.ZIP - includes card-specific information  and  code  
         (Turbo Pascal), also includes VESA information and code. Will 
         identify your card (including the DAC  -  256  colour,  32k  
         colour, 16.7M  colour),  and  let you do a quick demo in all 
         available modes. Very extensive, freeware. Top quality. 
         Compiler/author, Finn Thoegersen.

         VESASP12.ZIP - an unofficial version of the  official  VESA  
         standard, typed  in by a friendly demo coder going under the 
         pseudonym of  Patch.   Includes  ASM  information  on  VESA  
         routines.

         VESADRV2.ZIP - a collection of VESA drivers, not necessarily 
         implementing version  1.2  of  the  VESA  standard. Some, at 
         least, are earlier.

         VDRIV.ZIP - an even older collection of VESA drivers.

         VESA24_2.ZIP - C/ASM source for  VESA  usage.  
         Originally by Randy Buckland, with modifications by Don 
         Lewis.

         VGAKIT52.ZIP - C ?

         SWAG9402.ZIP
         SWAG9405.ZIP - one or both of these collections 
         of Turbo Pascal code collections have VESA routines included.

         UNIVBE50.ZIP -  the  universal  VESA   driver.   Shareware   
         (advertisement as  TSR  is  loaded).  Regularly  updated and 
         improved.  By Kendall Bennett, from SciTech Software.

         MGL - MegaGraphics Library - for C/C++, also  from  SciTech  
         Software.

         SVGAKT50 - for C/C++, also from SciTech Software.

         RBNG42 - Ralf Brown's extensive interrupt list in electronic
         form, includes VESA int 10h extensions.

         More details on these and others as and when I have the time.

         -------------------------------------------------------------

         Other sources I have seen/used:
         ------------------------------

         N.B. Only the most recent of these cover up to version 1.2 of
         the standard.

         "PC Interrupts", 2nd ed. by Ralf Brown and Jim Kyle.
         Addison-Wesley, 1994. ISBN 0201624850

         "Super VGA graphics programming secrets" by  Steve  Rimmer.
         Windcrest/McGraw-Hill, 1993. ISBN 0-8306-4427-X (hbk) (C/ASM)
         ISBN 0-8306-4428-8 (pbk)

         "PC INTERN System Programming :  the  encyclopedia  of  DOS
         programming know how" by Michael Tischer. Abacus, 1992. ISBN
         1-55755-145-6 (C/TP/ASM)

        "PC Magazine Turbo Pascal 6.0 : techniques and utilities", by
         Neil J. Rubenking. Ziff-Davis Press, 1991. ISBN 1-56276-010-6

         "Programmer's guide to the EGA and VGA cards", 2nd  ed.  by  
         Richard F.  Ferraro. Addison-Wesley, 1990. ISBN

         Program Now (UK  programmer's  magazine),  September  1993,  
         p.60-64, Dave  Bolton's  Turbo  Pascal  programming  column, 
         "Raising the VESA standard."

         Dr Dobbs Journal, April 1990, p.  65H-70.  "VESA  VGA  BIOS  
         extensions :  a  software  standard  for  Super  VGA"  by Bo 
         Ericsson.

         This one doesn't have VESA, but it's goes  into  plenty  of
         detail, with  lots  of  code, on programming VGA and earlier 
         (ASM/C): "Programmer's  guide  to  the  PC  &  PS/2  video   
         subsytems" by  Richard  Wilton.  Microsoft Press, 1987. ISBN 
         1-55615-103-9

         ------------------------------------------------------

         The VESA standard itself is available from:

         Video Electronics Standards Association
         2150 North First Street, Suite 440
         San Jose, California. 95131-2029
         
         Phone (408) 435-0333
         FAX   (408) 435-8225
         
         You may see an address of South Bascombe Avenue or some such 
         quoted in  some sources. This is an old address, and mail is 
         no longer forwarded from this address, so don't use it.

         Cost: $20 to non-members, for VBE 1.2 
         
         $50 for the complete VESA Programmers Toolkit, which includes 
         VBE 1.2, programmers guidelines for direct color modes, SVPMI 
         1.0 SuperVGA protected mode interface, the VESA XGA extensions
         standard, the standard for 800x600 mode (an older one ?), video
         cursor interface and the VGA pass-through connector standard.
         
         If you are not  USA, add $20 international shipping charge.

         Make sure you  specify  the  VESA  VBE 1.2 standard 
         (for VGA BIOS extensions), or the VESA Programmers Toolkit, as
         VESA also has standards for the VESA Local  Bus,  an  audio
         interface, power  management  signalling, and others, all of
         which are "VESA standards". They will FAX you an order form if
         you give them your FAX number.


         ----------------------------------------------------
