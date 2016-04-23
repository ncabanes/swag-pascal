{
From: russchinoy@aol.com (RussChinoy)
>Does anyone have know of where I can get a hold of a routine to delete
>all files off a floppy disk regardless, including all subdirectores?

Here's the source to a little DOS utility that I wrote to do exactly what
you are looking for (actually, it's slightly more flexible since you can
specify the starting directory; you can just specify the root), using a
recursive routine.
}

{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X+}
{$M 65520, 0, 0}

PROGRAM XRD;

{ This program deletes all files and subdirectories below the specified
  directory, and then removes the specified directory as well.          }

USES
    Dos,
    OpDos,
    OpCrt,
    OpString;

CONST
     Version = '1.01';

VAR
   XRDPath : PathStr;
   f       : file;

{*************************************************************************
**}

PROCEDURE Init;
VAR
   TempPath : PathStr;
   c        : char;
BEGIN
writeln;
writeln('XRD, Version ', Version, ', Copyright (c) 1992 RC Software');
writeln;
IF paramcount <> 1 THEN
   BEGIN
   writeln('   Purpose:  XRD removes the specified directory, and');
   writeln('             all files and subdirectories under it.');
   writeln;
   writeln('   Syntax:   XRD [d:]<path>');
   writeln;
   writeln('   Where:    d: is an optional drive specifier, and');
   writeln('             <path> is the path to be removed.');
   writeln;
   halt(1);
   END;

XRDPath := paramstr(1);

IF NOT IsDirectory(XRDPath) THEN
   BEGIN
   writeln('Error: specified path not found.');
   writeln;
   halt(2);
   END;

XRDPath := fexpand(XRDPath);

IF XRDPath[length(XRDPath)] <> '\'
   THEN XRDPath := XRDPath + '\';

XRDPath := StUpCase(XRDPath);

TempPath := copy(XRDPath, 1, length(XRDPath) - 1);

writeln('WARNING!!  You are about to remove the following directory');
writeln('           (and delete all files and subdirectories under it):');
writeln('           '#16' ', TempPath, ' ', #17);
write('Continue (Y/N)? ');

REPEAT
c := upcase(readkey);
IF c = #0 THEN
   BEGIN
   c := readkey;
   c := #255;
   END;
UNTIL c in ['Y', 'N'];
writeln(c);
writeln;

IF c = 'N' THEN halt(3);
END;

{*************************************************************************
**}

PROCEDURE DeleteAllFilesInDir(DirName : PathStr);
VAR
   s : searchrec;
BEGIN
FindFirst(DirName + '*.*', AnyFile, s);
WHILE DosError = 0 DO
      BEGIN
      IF (s.Attr <> Directory) AND
         (s.name <> '.') AND
         (s.name <> '..')
         THEN BEGIN
              gotoxy(1, wherey);
              clreol;
              write('Deleting: ', DirName + s.name);
              Assign(f, DirName + s.name);
              erase(f);
              IF IOResult <> 0 THEN
                 BEGIN
                 SetFAttr(f, Archive);
                 erase(f);
                 IF IOResult <> 0 THEN
                   BEGIN
                   gotoxy(1, wherey);
                   clreol;
                   writeln('Error: unable to delete ', DirName + s.name);
                   END;
                 END;
              END
         ELSE IF (s.Attr = Directory) AND
                 (s.name <> '.') AND
                 (s.name <> '..')
                 THEN DeleteAllFilesInDir(DirName + s.name + '\');
      FindNext(s);
      END;

IF (length(DirName) > 1) AND
   NOT ((length(DirName) = 3) AND (DirName[3] = '\')) THEN
   BEGIN
   gotoxy(1, wherey);
   clreol;
   write('Removing: ', copy(DirName, 1, length(DirName) - 1));

   rmdir(copy(DirName, 1, length(DirName) - 1));

   IF IOResult <> 0 THEN
      BEGIN
      gotoxy(1, wherey);
      clreol;
      writeln('Error: unable to remove ', copy(DirName, 1, length(DirName)
- 1));
      END;
   END;
END;

{*************************************************************************
**}

BEGIN
Init;

DeleteAllFilesInDir(XRDPath);

gotoxy(1, wherey);
clreol;
writeln('Done.');
writeln;
END.

