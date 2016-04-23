{
>Has anyone written a function for creating a pathname ?
>I'm having a problem with putting together a function that you
>can pass a pathname to, such as: C:\WINDOWS\SYSTEM\STUFF
>and have it create the path if it's at all possible.
>the problem I'm having seems to stem from the fact that 'MKDIR()'
>can only handle making one directory which is under the current one.

 This is because DOS' MkDir itself will fail if any element of a
 path is missing.  You'll need to parse and build the path, going
 directory by directory.

 Here's some example code that you may use to create a MakePath
 function...
}

PROGRAM MakePath;     { Create a path.  July 21,1994  Greg Vigneault  }

VAR   Try, Slash  : BYTE;
      Error       : WORD;
      TmpDir, IncDir, NewDir, OurDir : STRING;
BEGIN
  WriteLn;

  NewDir := 'C:\000\111\222'; { an example path to create }

  GetDir (0,OurDir); { because we'll use CHDIR to confirm directories }
  WHILE NewDir[Length(NewDir)] = '\' DO DEC(NewDir[0]); { clip '\' }
  IncDir := ''; { start with empty string }
  REPEAT
    Slash := Pos('\',NewDir); { check for slash }
    IF (Slash <> 0) THEN BEGIN
      IncDir := IncDir + Copy( NewDir, 1, Slash ); { get directory }
      NewDir := Copy( NewDir, Slash+1, Length(NewDir)-Slash ); END
    ELSE
      IncDir := IncDir + NewDir;
    TmpDir := IncDir;
    IF (Length(TmpDir) > 3) THEN { clip any trailing '\' }
      WHILE TmpDir[Length(TmpDir)] = '\' DO DEC(TmpDir[0]);
    REPEAT
      {$I-} ChDir(TmpDir); {$I+} { try to log into the directory... }
      Error := IoResult;
      IF (Error <> 0) THEN BEGIN { couldn't ChDir, so try MkDir... }
        {$I-} MkDir(TmpDir); {$I+}
        Error := IoResult;
      END;
      IF (Error <> 0) THEN INC(Try) ELSE Try := 0;
    UNTIL (Error = 0) OR (Try > 3);
    IF (Error = 0) THEN WriteLn('"',TmpDir,'" -- okay');
  UNTIL (Slash = 0) OR (Error <> 0);

  IF (Error <> 0) THEN WriteLn('MkDir ',TmpDir,' failed!',#7);

  ChDir(OurDir);  { log back into our starting directory }

  WriteLn;
END {MakePath}.
