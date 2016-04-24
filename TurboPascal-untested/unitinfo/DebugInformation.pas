(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0001.PAS
  Description: DEBUG Information
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

Provided you have a copy of Borland Pascal 7.0, you can Single-step, trace
into, put breakpoints etc. in routines contained in SYSTEM.TPU.

to do so, you must take the following steps:
-  Extract all Files from RTLSYS.ZIP
-  Assemble all .Asm Files With the following switches:

   TAsm *.Asm /mx /zi

(Ignore the Single error, as well as all warnings)

-  Compile SYSTEM:

   BPC SYSTEM /$D+ /$L+

-  Add the directory wherein you keep the .Asm Files to the inCLUDE directories
list of BPC.CFG and/or the "Options/Directories" of the IDE.
That's it.  The benefits are enormous, especially it you do a lot of debugging
with a stand-alone debugger (TD, TD286 or TD386).  Like I used to do -- Until I
discovered the joy of using the new IDE of BP 7.  Well, too late the hero, I
guess...


