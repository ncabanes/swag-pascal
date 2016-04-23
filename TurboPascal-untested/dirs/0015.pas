{
LAWRENCE JOHNSTONE

│Can someone give me some code (in TP) that recognizes all Sub-dirs
│and Sub-sub-dirs, etc. in drive C and changes into every single one
│of them one at a time?
}

PROGRAM EveryDir;

USES
  DOS

PROCEDURE ProcessDirs( Path: DOS.PathStr );
VAR
  SR : SearchRec;
BEGIN
  IF Path[Length(Path)] <> '\' THEN { Make sure last char is '\' }
    Path := Path + '\';

  { Change to directory specified by Path.  Handle root as special case }
  {$I-}
  IF (Length(Path) = 3) AND (Copy(Path, 2, 2) = ':\') THEN
    ChDir(Path)
  ELSE
    ChDir(Copy(Path, 1, Length(Path) - 1);
  IF IOResult <> 0 THEN
    EXIT; { Quit if we get a DOS error }
  {$I-}

  { Process all subdirectories of that directory, except for }
  { the '.' and '..' aliases                                 }
  FindFirst(Path + '*.*', Directory, SR);
  WHILE DosError = 0 DO
  BEGIN
    IF ((SR.Attr AND Directory) <> 0) AND
        (SR.Name <> '.') AND (SR.Name <> '..') THEN
      ProcessDirs( Path + SR.Name );
    FindNext(SR);
  END; { while }
END; {ProcessDirs}

VAR
  CurDir : DOS.PathStr;

BEGIN
  GetDir(3, CurDir);  { Get default directory on C }
  ProcessDirs('C:\'); { Process all directories on C }
  ChDir(CurDir);      { Restore default directory on C }
END.
