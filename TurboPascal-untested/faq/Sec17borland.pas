(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0040.PAS
  Description: SEC17-BORLAND
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:08
*)

SECTION 17 - TP/BP DOS Programming
                           
This document contains information that is most often provided
to users of this section.  There is a listing of common
Technical Information Documents that can be downloaded from the
libraries, and a listing of the five most frequently asked
questions and their answers.
         
TI1184   Overview of Borland Pascal 7.0 and Turbo Pascal 7.0
TI1722   Declaring an array on the heap
TI1760   Creating a temporary stack in real or protected mode
TI1171   Problem Report Form
TI1719   Booting Clean
TI432   Printing graphics to an HP LaserJet
TI433   Printing graphics to an Epson
TI407   Using the serial port in a Pascal application
TI152   Interupt handler for 3.X and lower
TI226   Async routines for versions 3.X and lower
TI232   Absolute disk read for version 3.x and lower

LC2P01.FAQ   Linking C to Pascal Frequently Asked Questions
EZDPMI.ZIP   Unit encapsulating common DPMI requests for
             protected mode programming 
BIGSTU.PAS   How to cope with memory allocations > 64K 
PASALL.ZIP   Collection of Technical Information Sheets from 
             1986 on
NEWRTM.ZIP   Latest RMT.EXE and DPMI16BI.OVL
MOUSE.ZIP    General purpose mouse unit for text/graphic modes


Q.   "How do I link an object file that is a library of
     functions created in C?"

A.   Download the file "LC2P01.FAQ.  The C run-time library is
     needed by the object file.  Since Pascal can't link the C
     RTL as is, you will need the RTL source and will need to
     modify it so that it can be linked by TP.

Q.   "How do I get the ASCII key numbers for the Arrow keys?"

A.   Below is a short program that reveals this information.

     program DisplayAscii;
     uses Crt;
     var
       ch:char;
     begin
       repeat               { repeat until Ctrl-C }
            ch := Readkey;
            Write(Ord(CH):4);
       until ch = ^C;          
     end.

     The program can be terminated by pressing Ctrl-C.  You'll
     see that keypresses such as UpArrow actually generated two
     bytes:  a zero followed by the extended key code. 

Q.   "Why do I get runtime error 4 while using the following
     line:  reset(InFile)?"

A.   The error message means that you have run out of file
     handles.  The FILES= statement in your CONFIG.SYS doesn't
     change the fact that a process can, by default, open a
     maximum of 20 files (and DOS grabs 5 of those).  The
     SetHandleCount() API function can be used to increase the
     number of handles useable by your application.

Q.   "I am using overlays with BP7 with Objects.  If Overlay A
     calls a procedure or function in Overlay B, does Overlay A
     stay in memory while Overlay B runs?  Or does Overlay B
     wipe out Overlay A, and when Overlay B finishes, it reloads
     Overlay A?"

A.   It depends on the size of the overlays and the size of the
     overlay buffer you set up.  In general you can think of the
     overlay buffer as a pool of memory where overlaid units can
     be stored.  Every time you call a routine in an overlaid
     unit, that overlay is loaded into the buffer.  If the
     buffer is already full, then the oldest unit in the buffer
     is discarded to make room for the new one.  If you've got a
     small overlay buffer and large overlaid units, they may
     well kick each other out as they load.  If you've got a
     large overlay buffer the program may well keep everything
     in memory the entire time.
 
Q.   "I am getting DosError = 8 when using EXEC() to execute a 
     program from within my program.  How do I correct this?"

A.   DosError = 8 means that there is not enough memory 
     available to run the program being EXEC'ed.  Normally your
     program grabs all available memory and doesn't leave any 
     for the program being EXEC'ed.  Be sure to use the $M 
     directive which minimizes the memory required by your
     program.  

Q.   "I am getting DosError = 2 when using EXEC() to copy a 
     file from one directory to another.  The file does exist
     and the command line is correct.  What is the problem?"
A.   You might have assumed that because COMMAND.COM is on your
     path, EXEC will find it.  Nope.  EXEC needs the full path
     name.  You can use GetEnv('COMSPEC') to get the value of
     the environment variable COMSPEC which should be the full
     path.  
     
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

A.   Outside of Windows and Turbo Vision, Borland offers no built
     in support for the mouse in your programs. However, adding 
     mouse support is extremely simply. Those who know ASSEMBLER
     can add mouse support with the INT33 interface, others will
     find MOUSE libraries available here in the CIS libraries.

Q.   "Are any of the ToolBox programs that shipped with versions
     3.0 and 4.0 still available.  For instance, can I get an
     upgraded copy of the Database ToolBox or the Editor
     ToolBox."

A.   No. These programs are no longer in any form from any
     company. If you want to get a copy of them, you would need
     to purchase them from a current owner.

Q.   "Can the ToolBox programs be used from version 7.0?"

A.   It depends. As a rule, the answer is yes, all you need to do
     is recompile and they will run fine. This is totally
     fortuitous, however, and Borland has, and will, do nothing
     to update these programs. See TI1728 for help upgrading the
     Editor ToolBox.

Q.   "How can I convert my Turbo Pascal 3.0 program to version
     7?"

A.   There is a file called up UPGRADE.ZIP which is available on
     the forums. This can help in the process of upgrading the
     files. Most of the code from version 3.0 will run fine under
     7.0, but not all of it.

Q.   "When I use the Turbo Vision editors unit from Version 6.0 I
     never see the numbers 3, 4, 6 and 7 when I try to type them
     in."  

A.   This was a bug in the first version of TP6.0. The fix is
     available in EDITOR.PAT, found in LIB1.

Q.   "What ever happened to FreeMin and FreePtr?"

A.   These Turbo Pascal 5.x identifiers are no longer used by the
     heap manager.  Simply delete references to FreeMin from your
     code. If you're using routines that use FreePtr to compress
     the heap or perform other implementation-dependent
     operations on the heap, you'll need to update these
     routines. (If you just need to lower the top of memory in
     order to do an Exec, you can call the SetMemTop procedure
     from the Turbo Vision Memory unit.) See the Programmer's
     Guide for more information about how the heap manager
     works.


