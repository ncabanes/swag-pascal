(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0070.PAS
  Description: T.V. List Box
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:52
*)


Program ExampleProgram;

Uses Drivers, Objects, Views, App, Menus, Dialogs, Dos;
  Const
    cmLeft =  101;

  Type
    PDirCollection = ^TDirCollection;
    TDirCollection = Object(TSortedCollection)
      Constructor Init;
      Function Compare(Key1, Key2: Pointer): Longint; Virtual;
      Procedure FreeItem(Item: Pointer); Virtual;
    End;

    PMStaticText = ^TMStaticText;
    TMStaticText = Object(TStaticText)
      Function GetPalette: PPalette; Virtual;
    End;

    PTestDialog = ^TTestDialog;
    TTestDialog = Object(TDialog)
      Function Valid(Command: Word): Boolean; Virtual;
    End;

    TTestMain = Object(TApplication)
      Constructor Init;
      Procedure InitStatusLine; Virtual;
      Procedure Run; Virtual;
    End;
  {-------------- TDirCollection -------}
    Constructor TDirCollection.Init;
      Var
        {I: Integer;}
        Info: SearchRec;
        S: ^String;
      Begin
        TCollection.Init(100, 10);
        FindFirst('*.*', AnyFile, Info);
        While DosError=0 do
          Begin
            New(S);
            S^:=Info.Name;
            Insert(S);
            FindNext(Info);
          End;
      End;

    Function TDirCollection.Compare(Key1, Key2: Pointer): Longint;
      Begin
        If String(Key1^)<String(Key2^) then Compare:=-1
        Else If String(Key1^)>String(Key2^) then Compare:=1
        Else Compare:=0;
      End;

    Procedure TDirCollection.FreeItem(Item:Pointer);
      Type
        PString = ^String;
      Begin
        Dispose(PString(Item));
      End;


  {-------------- TStaticText ----------}
    Function TMStaticText.GetPalette: PPalette;
      Begin
        GetPalette := TView.GetPalette{@cMenuBar};
      End;

  {-------- TTestDialog --------}
  Function TTestDialog.Valid(Command: Word): Boolean;
    Begin
      Valid:=False;
      Case Command of
        cmLeft:;
      Else
        Valid:=true;
      End
    End;

  {-------- TTestMain ----------}
  Constructor TTestMain.Init;
    Var
      StaticText: PMStaticText;
      R: TRect;
    Begin
      TApplication.Init;
      GetExtent(R);
      R.B.Y:=R.A.Y+1;
      StaticText:= New(PMStaticText, Init(R, '                         Welcome to Turbo Vision'));
      Insert(StaticText);
      GetExtent(R);
      R.A.Y:=R.B.Y-1;
      StaticText:= New(PMStaticText,Init(R,' '));
      Insert(StaticText);
      R.Assign(70,24,79,25);
    End;

  Procedure TTestMain.InitStatusLine;
    Begin
    End;

  Procedure TTestMain.Run;
    Var
      Dialog: PTestDialog;
      ListBox: PListBox;
      DirCollection: PDirCollection;
      ScrollBar: PScrollBar;
      R:TRect;
    Begin
      R.Assign(5,3,30,18);
      Dialog := New(PTestDialog, Init(R, 'My Dialog'));

      R.Assign(20,2,21,13);
      ScrollBar:=New(PScrollBar,Init(R));
      Dialog^.Insert(ScrollBar);
      R.Assign(2,2,20,13);
      ListBox:= New(PListBox, Init(R, 1, ScrollBar));
      Dialog^.Insert(ListBox);
      DirCollection:=New(PDirCollection, Init);
      ListBox^.NewList(DirCollection);
      DeskTop^.ExecView(Dialog);
    End;

  Var
    TestMain: TTestMain;

  Begin
    TestMain.Init;
    TestMain.Run;
    TestMain.Done;
  End.
