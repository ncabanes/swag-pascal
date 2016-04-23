
(*                          SWAG submission
|                             RECOMP v0.1
|               As posted on: GDSOFT BBS (219) 875-8133
|
|                         ~~~~~~~~~~~~~~~~~~~
|   Author:     David Daniel Anderson
|   Program:    Recompress nested ZIP archives
|   Date:       October 18, 1995
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Here is the basis for a program to recompress archives which may
or may not contain nested archives.  It will recompress all nested
archives that it recognizes, up to at least six levels deep.

Although this program is fully functional, it has severe limitations
which preclude me from releasing it as a ready-to-use program.

As written, this should only be for personal use, and to serve as an
example of how to construct a release-worthy recompression program.

Limitations of this program foundation:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
It doesn't recognize anything besides ZIP files.
It is hardcoded to use v2 of PKZIP/ PKUNZIP.
It doesn't preserve directory structures in the ZIP files.
It doesn't preserve the file attributes of the archived files.
It doesn't preserve the extension of the main ZIP, it will always
   be renamed to *.ZIP.
It doesn't preserve the authenticity verification, comments, or date
   of the original archive.
It has almost no error detection.  If an extraction fails, you are
   out of luck.
It lacks an Exit or ExitOnError procedure.
It doesn't verify that "COMSPEC" is set, and valid.
In short, while the logic seems solid, it is not robust enough to
   handle varied or unexpected conditions.
*)

PROGRAM Recompress_Nested_ZIP_files;
{$M 8192,0,0} {$I-}
USES DOS;
VAR RecursionLevel: BYTE;

PROCEDURE CheckIO;
BEGIN
  IF IOResult <> 0 THEN Halt (7);
END;

FUNCTION getFileName (fn : STRING): STRING;
BEGIN
  IF (Pos ('.', fn) > 0)
    THEN getFileName := Copy (fn, 1, (Pos ('.', fn) - 1))
    ELSE getFileName := fn;
END;

FUNCTION IsDir (CONST FileName: PATHSTR): BOOLEAN;
VAR
  Attr  : WORD;
  cFile : FILE;
BEGIN
  Assign (cFile, FileName);
  GetFAttr (cFile, Attr);
  IF (DosError = 0) AND ((Attr AND Directory) = Directory)
    THEN IsDir := TRUE
    ELSE IsDir := FALSE;
END;

FUNCTION GetFilePath (CONST PSTR: STRING; VAR sDir: DIRSTR): PATHSTR;
VAR
  jPath     : PATHSTR;  { file path,       }
  jDir      : DIRSTR;   {      directory,  }
  jName     : NAMESTR;  {      name,       }
  jExt      : EXTSTR;   {      extension.  }
BEGIN
  jPath := PSTR;
  IF jPath = '' THEN jPath := '*.*';
  IF (NOT (jPath [Length (jPath)] IN [':', '\'])) AND IsDir (jPath) THEN
    jPath := jPath + '\';
  IF (jPath [Length (jPath)] IN [':', '\']) THEN
    jPath := jPath + '*.*';

  FSplit (FExpand (jPath), jDir, jName, jExt);
  jPath := jDir + jName+ jExt;

  sDir := jDir;
  GetFilePath := jPath;
END;

FUNCTION IsFile (CONST FileName: PATHSTR): BOOLEAN;
VAR
  Attr  : WORD;
  cFile : FILE;
BEGIN
  Assign (cFile, FileName);
  GetFAttr (cFile, Attr);
  IF (DosError = 0) AND ((Attr AND Directory) <> Directory)
    THEN IsFile := TRUE
    ELSE IsFile := FALSE;
END;

PROCEDURE EraseFile (CONST FileName : STRING);
VAR
  cFile : FILE;
BEGIN
  IF IsFile (FileName) THEN BEGIN
    Assign (cFile, FileName);
    SetFAttr (cFile, 0);
    Erase (cFile); CheckIO;
  END;
END;

PROCEDURE RezipThem (dirname: PATHSTR);
VAR
  fn: NAMESTR;
  fileinfo: SEARCHREC;
  Compression : STRING [4];
BEGIN
  FindFirst (dirname, Directory, fileinfo);
  WHILE DosError = 0 DO
  BEGIN
    fn := getFileName (fileinfo. Name);
    WriteLn ('Level: ', RecursionLevel, '; compressing: ', fn);
    erasefile (fn + '.zip');
    IF RecursionLevel > 1
      THEN compression := '-e0 '   { STORING the nested ZIP files }
      ELSE compression := '-ex ';  { results in smaller ZIP overall }
    SwapVectors;
    Exec (GetEnv ('COMSPEC'),' /c pkzip -# '+compression+fn+'.zip -m '+
          fileinfo.Name+'\*.*');
    SwapVectors;
    IF IsDir (fileinfo. Name) THEN RmDir (fileinfo. Name);
    FindNext (fileinfo);
  END;
  Dec (RecursionLevel);
END;

PROCEDURE UnzipThem (zipname: PATHSTR);
VAR
  StartDir: PATHSTR;
  fn: NAMESTR;
  fileinfo: SEARCHREC;
BEGIN
  Inc (RecursionLevel);
  IF RecursionLevel = 1 THEN
    WriteLn ('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  GetDir (0, StartDir);
  FindFirst (zipname, Archive, fileinfo);
  WHILE DosError = 0 DO
  BEGIN
    fn := getFileName (fileinfo. Name);
    WriteLn ('Level: ', RecursionLevel, '; extracting:  ', fn);
    MkDir (fn + '.dir');
    ChDir (fn + '.dir');
    SwapVectors;
    Exec (GetEnv ('COMSPEC'), ' /c pkunzip -# ..\' + fileinfo. Name);
    SwapVectors;
    UnzipThem ('*.zip');
    ChDir (StartDir);
    FindNext (fileinfo);
  END;
  RezipThem ('*.dir');
END;

VAR
  fPath: PATHSTR; fDir: DIRSTR;
BEGIN
  RecursionLevel := 0;
  fPath := GetFilePath (ParamStr(1), fDir);
  UnzipThem (fPath);
END.
