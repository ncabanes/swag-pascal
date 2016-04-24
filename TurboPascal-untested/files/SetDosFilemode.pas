(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0025.PAS
  Description: Set DOS Filemode
  Author: LOU DUCHEZ
  Date: 08-27-93  21:23
*)

LOU DUCHEZ

>Could someone post all the different File Modes availl with FileMode, and a
>short descript of each one?

The FileMode byte reserves certain bits to specify different capabilities.
They are:

76543210
--------
.....000  - Read access
.....001  - Write access
.....010  - Read/write access
....0...  - Reserved - must be zero
.000....  - Sharing mode - compatibility mode ["no sharing"?]
.001....  - Sharing mode - read/write access denied
.010....  - Sharing mode - write access denied
.011....  - Sharing mode - read access denied
.100....  - Sharing mode - full access permitted
0.......  - Inherited by child processes
1.......  - Private to current process

I got this out of a pocket DOS/BIOS reference -- hope it helps.

