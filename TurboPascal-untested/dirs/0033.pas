{
 On 05-25-94 ROBERT HARRISON wrote to ALL...

 RH>   I'm trying to obtain the source for searching for files in all
 RH> directories and drives.  Anyone happened to have the information
 RH> they would like to share with me?  Thanks.

----------------- 8< ------------- }

USES DOS, Crt;

PROCEDURE Search;
VAR
  Err     : INTEGER;
  Attrib,
  CurrDir : STRING;
  DirInfo : SearchRec;

Begin
  FindFirst( '*.*', AnyFile, DirInfo );

  Err := 0;

  WHILE Err = 0 DO
  Begin
    { If the directory wasn't . or .., then find all files in it ... }
    IF ((DirInfo.Attr AND Directory) = Directory) AND
       (Pos( '.', DirInfo.Name ) = 0) THEN
    Begin
      {$I-}
      ChDir( DirInfo.Name );
      {$I+}

      { Find all files in subdirectory that was found }
      Search;
      DirInfo.Attr := 0;
    End
    ELSE
    Begin
      GetDir( 0, CurrDir );
      WriteLn( DirInfo.Name );
      FindNext( DirInfo );

      Err := DosError;
    End;
  End;

  {$I-}
  ChDir( '..' );
  {$I+}

  IF IOResult <> 0 THEN
    { Do Nothing...probably root directory... };
End;

VAR
  CurDir : STRING;

Begin
  ClrScr;
  GetDir( 0, CurDir );
  ChDir( 'C:\' );
  Search;
  ChDir( CurDir );
End.
