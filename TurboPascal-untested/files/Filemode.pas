(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0003.PAS
  Description: FILEMODE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

RB > I use a shared File to transfer info between
   > multitasker Windows that are running the same application.
   > Lately, I have been getting Runtime errors 2, 5 & 162 in the following spo

Try to set the "FileMode" Constant to 66 (read/Write) or
64 (read) beFore opening it.  Here's a map of valid values
to FileMode:

                               ----- Sharing Method -----
Access         Compatibility   Deny   Deny    Deny   Deny
Method            Mode         Both   Write   Read   None
___------------------------------------------------------
Read Only           0           16     32      48     64
Write Only          1           17     33      49     65
Read/Write          2*          18     34      50     66

 * = default

File locking is seldom useful For Real life applications.
Sometimes however, File locking MAY be appropriate, such as
when a Compiled list is produced at the Printer; if users
are allowed to update the database then, the list can contain
multiple instances of a Record or reference...  :-)

Use Record locking instead, when required, For most purposes
and add logic to prevent disasters and user misunderstandings.
Users will generally be more happy if they're not denied
Write access all the time...  :-)

RB > Perhaps I need to disable I/O checking and put in some Delays if
   > this File is being accessed simulataneously.  Also, the size of this File

Definately disable I/O checking.  Don't add Delays if you
can avoid it.  Beware of dead-lock situations which occur
when two or more users access the same File With inadequate
access rights and they're all put on hold Until the File
is released by the other...  One way to catch these situations
is to retry a specified number of times and then cancel the
operation With an error message perhaps.

