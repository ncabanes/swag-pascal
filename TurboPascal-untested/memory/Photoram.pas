(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0048.PAS
  Description: PhotoRAM
  Author: ROB ROSENBERGER
  Date: 01-27-94  17:39
*)

{$A+,B-,D+,E+,F-,I-,L+,N-,O-,R+,S+,V+}
{$M 2048,0,0}
PROGRAM PhotoRAM(INPUT,OUTPUT);

   {Rob Rosenberger             VOX: (618) 632-7345
    Barn Owl Software           BBS: (618) 398-5703
    P.O. Box #74                HST: (618) 398-2305
    O'Fallon, IL 62269          CIS: 74017,1344

   This program simply snapshots memory to disk.  It was developed so a user
from across the country could take a snapshot of his memory configuration and
present it for inspection.

   You'll need to change the "TotalRAM" constant if you have a system with
less than 640k of memory.

Version 1.00: released to the public domain on 27 August 1989.
   See above for the reason why this program was created.}


CONST
   TotalRAM = 640; {total memory, in kilobytes}

VAR
   Index     : WORD;
   PhotoFile : FILE;

BEGIN {PhotoRAM}
{Initialize.}
Index := 0;


{Check for question mark, it means they want the help screen.}
IF ((PARAMSTR(1) = '')
 OR (PARAMSTR(1) = '?'))
 THEN {display a help screen}
    BEGIN
    WRITELN(OUTPUT,^M^J'Syntax:   PHOTORAM filename'^M^J);
    WRITELN(OUTPUT,'A public domain program by Rob Rosenberger (who?)'^M^J);
    WRITELN(OUTPUT,'Takes a "snapshot" of RAM and sends it to the filename');
    WRITELN(OUTPUT,'you specify.  You must have at least 640k of free disk');
    WRITELN(OUTPUT,'space for the snapshot file.'^M^J);
    HALT(0)
    END;

{If we get this far, PARAMSTR(1) contains a filename.}
{Open the file.}
ASSIGN(PhotoFile,PARAMSTR(1));
REWRITE(PhotoFile,1);

FOR Index := 0 TO ((TotalRAM DIV $40) - $1)
 DO BEGIN
    BLOCKWRITE(PhotoFile,PTR(Index,$0000)^,$8000);
    BLOCKWRITE(PhotoFile,PTR(Index,$8000)^,$8000)
    END;

CLOSE(PhotoFile)
{And that's all he wrote!}
END. {PhotoRAM}

