(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0031.PAS
  Description: Filesize & ZeroByte Files
  Author: DAVID DANIEL ANDERSON
  Date: 09-26-93  10:17
*)

(*
From: DAVIDDANIEL ANDERSON         Refer#: 2239
Subj: FileSize in DOS                Conf: (232) T_Pascal_R

The FileSize "returns the number of components" in a file.  Thus, it
may not work as you might assume on untyped files, or files of records.

The file should be declared as a file of byte or char or as a text
file, in order to use FileSize.

An alternative to FileSize is to use the SearchRec type in the DOS
unit.  This program deletes a file if it is 0 bytes.  The filespec is
provided by the user on the command line, and can contain wildcards.
*)

PROGRAM delete_0_byte_files;
USES Dos;
VAR
   MaybeZero   : File of Byte;   { the file in question }
   DirInfo     : SearchRec;      { a record of the file }
   FMask       : PathStr;        { entire path as specified by user }
   MZName      : PathStr;        { path of file in question }
   FDir        : DirStr;         { dir of file in question }
   FName       : NameStr;        { name of file in question }
   FExt        : ExtStr;         { ext of file in question }
   NZero       : Word;           { number of files deleted }

BEGIN
     NZero := 0;
     IF ParamCount = 1 THEN
        FMask := ParamStr(1)     { use command line info, if it exists }
     ELSE BEGIN
        Writeln('You must specify a file_mask, such as "*.*"!');
        Halt;
     END;
     FSplit(FExpand(FMask),FDir,FName,FExt);  { split cmdlind info into }
     IF (FName = '') THEN                       { components }
        FMask := FMask + '*.*';          { if only a DOS path was specified, }
     FindFirst(FMask, Archive, DirInfo);    { append a wildcard spec }

     WHILE DosError = 0 DO               { check every valid file for size }
     BEGIN                               { append path to name, to allow }
          MZName := FDir+DirInfo.Name;  { paths and drives other than current }
          Assign(MaybeZero,MZName);    { use Assign since Erase can only work }
                                             { on *files*, -not- file names }
          IF (DirInfo.Size = 0) THEN BEGIN  { THE MEAT! use the SearchRec }
             Writeln('Deleting ',MZName);     { for determining file size }
             Erase(MaybeZero);             { give a message and delete it }
             NZero := NZero + 1;           { incremented counter, of course }
          END;

          FindNext(DirInfo);               { look for another matching file }
     END;
     Writeln('Files Deleted: ',NZero);     { simply display total # deleted }
END.

