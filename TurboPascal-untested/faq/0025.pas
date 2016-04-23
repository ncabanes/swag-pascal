SECTION 5 - Graphics

This document contains information that is most often provided
to users of this section.  There is a listing of common
Technical Information Documents that can be downloaded from the
libraries, and a listing of the five most frequently asked
questions and their answers.
  
TI432   Printing graphics to an HP LaserJet
TI433   Printing graphics to an Epson

Q.   "Does Turbo Pascal run in Super VGA modes?"

A.   Yes, if you have a VESA compatable video card you can use
     the VESA16.BGI file to get high resolutions such as 1024X768
     or 800X600. If you also want 256 color support, you should
     turn to a third party solution. There are some helpful
     files, including freeware drivers, available here on the
     forum.

Q.   "How can I print my graphics code?"

A.   Download the files labeled TI432.ZIP and TI433.ZIP from 
     the libraries. Additional support is available from third 
     party vendors. You could pose a question in the forum asking
     for recommendations regarding third party graphics support 
     for printing.

Q.   "When will Borland upgrad the GRAPHICS TOOLBOX?"

A.   The GRAPHICS TOOLBOX is no longer available from Borland in
     any form, and there are absolutely no plans to upgrade it.
     It should, however, recompile with recent versions of
     Pascal including Versions 6.0 and 7.0.

Q.   "How can I use BGI calls in Windows?"

A.   Windows is a graphical operating environment, so there is
     no longer any need for the BGI when programming Windows. You
     will find that Windows has built in support for graphics
     that is much superior to anything available in the BGI unit.
     To get started, try using using the manuals and on-line docs
     to read about the Windows GDI.

Q.   "How can I add a mouse to my Graphics programs?"

A.   Outside of Windows, Borland offers no built in support for
     the mouse in your programs. However, adding mouse support
     is extremely simply. Those who know ASSEMBLER can add mouse
     support with the INT33 interface, others will find MOUSE
     libraries available here in the CIS libraries.
