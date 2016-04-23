
Program ChgPic;
Uses Dos, Strings;
Const
    FindPath : String = 'C:\windows\*.bmp';
    WallPaper : String = 'WALLPAPER';
Type
    PicPtr  = ^NameRec;
    LinePtr = ^LineRec;
    NameRec = Record
        PicName : String[12];
        Next    : PicPtr;
    End;
    LineRec = Record
        ALine : String[80];
        NextLine : LinePtr;
    End;
Var
	DirInfo    : SearchRec;
    First, hldptr : PicPtr;
    Current    : PicPtr;
    FirstLine, CurrentLine,
    TmpLine, LastLIne : LinePtr;
    Count, Ix,
    Nbr        : Integer;
    FileIn, FileOt : Text;
    WorkLine       : String[80];
    CkWallPaper    : String[9];
    HoldName       : String[12];
    TestMode       : boolean;

Begin
    If ParamCount > 0 Then
    Begin
       TestMode := True;
    End;
    First := Nil;
    Count := 0;
	FindFirst(FindPath, AnyFile, DirInfo);
    While DosError = 0 Do
    Begin
        New (Current);
        if First = Nil Then
        Begin
            First := Current;
            Current^.Next := Nil;
        End
        Else
        Begin
            Current^.Next := First;
            First := Current;
        End;
        Current^.PicName := DirInfo.Name;
        Inc(Count);
        FindNext(DirInfo);
    End;
    Randomize;
    Nbr := Random(Count) + 1;
    Current := First;
    HoldName := Current^.PicName;
    For Ix := 1 to Nbr Do
    Begin
        hldptr := Current;
        Current := Current^.Next;
        HoldName := Current^.PicName;
        Dispose (hldptr);
    End;
    If TestMode Then
       Writeln (HoldName);
    While Current <> Nil Do
    Begin
         HldPtr := Current;
         Current := Current^.Next;
         Dispose (hldptr);
    End;
    FirstLine := Nil;
    Assign (FileIn, 'c:\windows\win.ini');
    Reset (FileIn);
    While NOT EOF(FileIn) Do
    Begin
        Readln(Filein, WorkLine);
        CkWallPaper := Copy (WorkLine, 1, 9);
        For Ix := 1 to Length(CkWallPaper) Do
            CkWallPaper[Ix] := UpCase(CkWallPaper[Ix]);
        New (CurrentLine);
        if (CkWallPaper = WallPaper) Then
        Begin
           CurrentLine^.ALine := 'WallPaper=' + HoldName;
            if TestMode Then
                Writeln(CurrentLine^.ALine);
        End
        Else
            CurrentLIne^.ALine := WorkLine;
        CurrentLIne^.NextLine := Nil;
        If FirstLine = NIL Then
            FirstLine := CurrentLIne
        Else
            LastLIne^.NextLIne := CurrentLine;
        LastLine := CurrentLine;
    End;
    Close (FileIn);
    Rewrite(FileIn);
    CurrentLine := FirstLine;
    While CurrentLine <> NIL Do
    Begin
        Writeln(FileIn, CurrentLine^.ALine);
        CurrentLIne := CurrentLIne^.NextLine;
    End;
    Close(FileIn);
    If TestMode Then
       Readln;
End.
