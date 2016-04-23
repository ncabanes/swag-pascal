SECTION 20 - Networks
  
This document contains information that is most often provided
to users of this section.  There is a listing of common
Technical Information Documents that can be downloaded from the
libraries, and a listing of the five most frequently asked
questions and their answers.

TI555    File and record locking in Turbo Pascal
TI1201   Installing Turbo Pascal on a network

Q.   "How do I open a file in read only mode?"

A.   Turbo Pascal gives you the ability to open files in several
     different modes. Typically, you will want to change the
     file mode after you call Assign but before you call Reset or
     ReWrite. You make the change by assigning numerical values
     to the built in FileMode variable.

Q.   "What is the default value for FileMode? What values are
     associated with a shared Read/Write mode and a shared Read
     only mode."

A.   By default, FileMode is set to 2. Set FileMode to 66 to
     acheive a shared Read/Write mode, and set it to 64 to get a
     shared Read only mode.

Q.   "How can I implement file and record locking in my own
     code?"

A.   Turbo Pascal has no built in functions for file and record
     locking, so you have to go to the assembler level (or
     call MsDos/Intr) to implement this feature. With DOS
     versions 3.0 and later, you can access file and record
     locking via Interrupt $21, Service $5C, SubFunctions 0 and
     1. (See TI555, and the next Q/A.).

Q.   "Beside the method described above, is there a second way to
     access file and record locking routines?"

A.   Real world implementations of record and file locking tend
     to be very complex to implement. As a result, it is standard
     practice for programmers to gain access to this kind of
     functionality by purchasing a ready made database toolkit
     such as the Borland Database Engine (release date, summer
     94), the B Tree Filer from Turbo Power software, or the
     Paradox Engine.

Q.   "How can I get access to Netware and other network
     routines?"

A.   Turbo Pascal provides no built in access to Netware or
     other network functions other than the calls that are built
     into Windows, such as WNetAddConnection,
     WNetCancelConnection, and WNetGetConnection. In the
     Compuserve library for Section 20 there are (as of May 94)
     various toolkits available, such as the MAPI.ZIP and
     TPAPI.ZIP files.
