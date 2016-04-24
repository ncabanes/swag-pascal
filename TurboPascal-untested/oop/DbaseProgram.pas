(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0092.PAS
  Description: Dbase Program
  Author: SHMATIKOV V.
  Date: 01-02-98  07:35
*)


uses Objects, Drivers, Views, Menus, Dialogs, App, Layout, OODB;
                                     { layout and OODB are at the end !!}
const

   DBFileName = 'dbdemo.dat';

   MaxLen = 25;
   CollLimit = $7F; CollDelta = 4;
   InvPID = 1;

   cmInfo     = 100;

   cmOpen     = 101;
   cmShut     = 102;
   cmStat     = 103;

   cmCreate   = 105;
   cmGet      = 106;
   cmDelete   = 107;

   cmCommit   = 108;
   cmAbort    = 109;

type

   NameString = String [MaxLen];

   ModDialData =
      record
         NameData : NameString
      end;

   TInvCard =
      record
         Name : NameString;
         ID   : Word
      end;
   PInvCard = ^TInvCard;

{ ----- TCatCollection ----- }

      TCatCollection =
         object (TSortedCollection)
            procedure FreeItem (Item: Pointer);                  virtual;
            function  GetItem  (var S: TStream): Pointer;        virtual;
            procedure PutItem  (var S: TStream; Item: Pointer);  virtual;
            function  Compare  (Key1, Key2 : Pointer): Integer;  virtual;
         end;
      PCatCollection = ^TCatCollection;

{ ----- TDemoApplication class ----- }

   TDemoApplication =
      object (TApplication)

         DB        : PBase;
         DBFile    : PDosStream;

         constructor Init;
         destructor  Done;                             virtual;
         procedure   InitMenuBar;                      virtual;
         procedure   InitStatusLine;                   virtual;
         procedure   HandleEvent (var Event: TEvent);  virtual;
         procedure   Idle;                             virtual;

         function    NameDialog (Title: TTitleStr):
                                PDialog;               virtual;

         procedure   About;                            virtual;

         procedure   OpenDB;                           virtual;
         procedure   ShutDB;                           virtual;
         procedure   StatInfo;                         virtual;

         procedure   CreateMod;                        virtual;
         procedure   GetMod;                           virtual;
         procedure   DeleteMod;                        virtual;

         procedure   Commit;                           virtual;
         procedure   Rollback;                         virtual;

      end;
   PDemoApplication = ^TDemoApplication;

{ -- Implementation of TCatCollection -- }

   procedure TCatCollection.FreeItem (Item: Pointer);

      begin
         Dispose (Item)
      end;  { FreeItem }

   function TCatCollection.GetItem (var S: TStream): Pointer;

      var Item : PInvCard;

      begin
         New (Item);
         with S do
              with Item^ do
                   begin
                      Read (Name, SizeOf(Name));
                      Read (ID,   SizeOf(ID))
                   end;
         GetItem := Item
      end;  { GetItem }

   procedure TCatCollection.PutItem (var S: TStream; Item: Pointer);

      begin
         with S do
              with TInvCard(Item^) do
                   begin
                      Write (Name, SizeOf(Name));
                      Write (ID,   SizeOf(ID))
                   end
      end;  { PutItem }

   function TCatCollection.Compare (Key1, Key2 : Pointer): Integer;

      var
         N1, N2 : NameString;
      begin
         N1 := TInvCard(Key1^).Name; N2 := TInvCard(Key2^).Name;
         if N1 > N2
            then Compare := 1
            else if N1 < N2
                    then Compare := -1
                    else Compare := 0
      end;  { Compare }

{ -- End of TCatCollection implementation -- }

{ ----- TDemoApplication implementation ----- }

{ ----- Init ----- }

   constructor TDemoApplication.Init;

      begin
         TApplication.Init;
         DB := nil
      end;

{ ----- Done ----- }

   destructor TDemoApplication.Done;

      begin
         if DB <> nil
            then begin
                    Dispose (DB, Done);
                    Dispose (DBFile, Done)
                 end;
         TApplication.Done
      end;

{ ----- InitMenuBar ----- }

   procedure TDemoApplication.InitMenuBar;

      var
         MenuRect: TRect;

      begin
         GetExtent (MenuRect);
         MenuRect.B.Y := MenuRect.A.Y + 1;
         MenuBar := New (PMenuBar, Init (MenuRect, NewMenu (
             NewItem ( '~I~nfo', '', kbNoKey, cmInfo, hcNoContext,
             NewSubMenu ( '~D~atabase', hcNoContext, NewMenu (
                NewItem ( '~O~pen', 'F3', kbF3, cmOpen, hcNoContext,
                NewItem ( '~S~hut', 'F4', kbF4, cmShut, hcNoContext,
                NewItem ( 'S~t~atistics', '', kbNoKey, cmStat, hcNoContext,
                NewLine (
                NewItem ( '~E~xit', 'Alt-X', kbAltX, cmQuit, hcNoContext,
                   nil )))))),
             NewSubMenu ( '~M~odules', hcNoContext, NewMenu (
                NewItem ( '~C~reate', 'F5', kbF5, cmCreate, hcNoContext,
                NewItem ( '~G~et', 'F6', kbF6, cmGet, hcNoContext,
                NewItem ( '~D~elete', '', kbNoKey, cmDelete, hcNoContext,
                   nil )))),
             NewSubMenu ( '~T~ransaction', hcNoContext, NewMenu (
                NewItem ( '~C~ommit', '', kbNoKey, cmCommit, hcNoContext,
                NewItem ( '~R~ollback', '', kbNoKey, cmAbort, hcNoContext,
                   nil ))),
                  nil )))))))
      end;

{ ----- InitStatusLine ----- }

   procedure TDemoApplication.InitStatusLine;

      var
         StatusRect: TRect;

      begin
         GetExtent (StatusRect);
         StatusRect.A.Y := StatusRect.B.Y - 1;
         StatusLine := New (PStatusLine, Init (StatusRect,
            NewStatusDef (0, $FFFF,
               NewStatusKey ('~Alt-X~ - Exit', kbAltX, cmQuit,
               NewStatusKey ('~F3~ - Open database', kbF3, cmOpen,
               NewStatusKey ('~F10~ - Menu', kbF10, cmMenu,
                  nil ))),
                 nil )))
      end;

{ ----- HandleEvent ----- }

   procedure TDemoApplication.HandleEvent (var Event: TEvent);

      begin
         TApplication.HandleEvent (Event);
         with Event do
              if What = evCommand
                 then begin
                         case Command of

                              cmInfo   : About;

                              cmOpen   : OpenDB;
                              cmShut   : ShutDB;
                              cmStat   : StatInfo;

                              cmCreate : CreateMod;
                              cmGet    : GetMod;
                              cmDelete : DeleteMod;

                              cmCommit : Commit;
                              cmAbort  : Rollback;

                              else
                                         Exit
                          end;
                          ClearEvent (Event)
                      end
      end;

{ ----- Idle ----- }

   procedure TDemoApplication.Idle;

      begin
         TApplication.Idle;
         if DB <> nil
            then DB^.IdlePack
      end;

{ ----- NameDialog ----- }

   function TDemoApplication.NameDialog (Title: TTitleStr): PDialog;

      var
         X, Y     : Word;
         R        : TRect;
         Dial     : PDialog;
         Bruce    : PView;

      begin
         if DB = nil
            then begin
                    HandleError ( ^C'Open database at first !' );
                    NameDialog := nil;
                    Exit
                 end;
         Randomize;
         X := 2 + Random (50); Y := 2 + Random (12);
         R.Assign (X,Y,X+28,Y+9);
         New (Dial, Init (R, Title));
         with Dial^ do
              begin
                 R.Assign (2,6,12,8);
                 Insert (New (PButton, Init (R, '~O~k', cmOK, bfDefault)));
                 R.Assign (14,6,24,8);
                 Insert (New (PButton,
                              Init (R, '~C~ancel', cmCancel, bfNormal)));
                 R.Assign (3,3,25,4);
                 Bruce := New (PInputLine, Init (R, MaxLen));
                 Insert (Bruce);
                 R.Assign (2,2,20,3);
                 Insert (New (PLabel, Init (R, 'Module name:', Bruce)))
              end;
         NameDialog := Dial
      end;

{ ----- About ----- }

   procedure TDemoApplication.About;

      var
         R: TRect;

      begin
         R.Assign (15,3,65,16);
         Inform
            ( R,
              ^C'This program is intended to demonstrate'^M +
              ^C'some features of OODBMS'^M +
              ^C'(object-oriented database management system).'^M +
              ^C'OODBMS as well as this demo'^M +
              ^C'is developed independently by Shmatikov V.'^M^M +
              ^C'Spring 1992',
              nil )
      end;

{ ----- OpenDB ----- }

   procedure TDemoApplication.OpenDB;

      var
         Dial    : PDialog;
         C       : Word;
         DBIsNew : Boolean;
         Invent  : PCatCollection;

      begin
         DBIsNew := False;
         if DB = nil
            then begin
                    if Confirm ( ^C'You are to open database.'^M +
                                 ^C'Choose Ok to proceed ...' ) =
                       cmCancel
                       then Exit;
                    New (DBFile, Init (DBFileName, stOpen));
                    if DBFile^.Status <> stOk
                       then begin
                               Dispose (DBFile, Done);
                               New (DBFile, Init (DBFileName, stCreate));
                               DBIsNew := True;
                            end;
                    New (DB, Init (DBFile));
                    if DBIsNew
                       then begin
                               New (Invent, Init (CollLimit, CollDelta));
                               DB^.Put (InvPID, Invent);
                               Inc (DB^.PIDCurrent);
                               Dispose (Invent, Done)
                            end;
                    DB^.Commit
                 end
            else HandleError ( ^C'Database is in use already !' )
      end;

{ ----- ShutDB ----- }

   procedure TDemoApplication.ShutDB;

      var
         Dial : PDialog;
         C    : Word;

      begin
         if DB <> nil
            then begin
                    if Confirm ( ^C'You are about to close database'^M +
                                 ^C'Choose Ok to do it !' ) =
                       cmCancel
                       then Exit;
                    Dispose (DB, Done); DB := nil;
                    Dispose (DBFile, Done); DBFile := nil
                 end
            else HandleError ( ^C'No database is in use now !' )
      end;

{ ----- StatInfo ----- }

   procedure TDemoApplication.StatInfo;

      type
           InfoRec =
              record
                 FileName            : PString;
                 NumObj,   SizeObj,
                 NumHoles, SizeHoles,
                 SizeAnc,  TotalSize : Longint
              end;

      var
         R       : TRect;
         DataRec : InfoRec;
         i       : Integer;

      begin
         if DB = nil
            then begin
                    HandleError ( ^C'Open database at first !' );
                    Exit
                 end;
         with DB^ do
              with DataRec do
                   begin
                      FileName^ := DBFileName;
                      NumObj := 0; SizeObj := 0;
                      For i := 2 to DBIndex^.Count - 1 do
                          if (IndRec(DBIndex^.At(i)^).Base = i) and
                             (IndRec(DBIndex^.At(1)^).Base <> i)
                             then begin
                                     Inc (NumObj);
                                     SizeObj := SizeObj +
                                                IndRec(DBIndex^.At(i)^).Size
                                  end;
                      NumHoles := HolesIndex^.Count; SizeHoles := 0;
                      For i := 0 to NumHoles-1 do
                          SizeHoles := SizeHoles +
                                       IndRec(HolesIndex^.At(i)^).Size;
                      SizeAnc := DBFile^.GetSize - SizeObj - SizeHoles;
                      TotalSize := DBFile^.GetSize
                   end;
         R.Assign (10,2,70,15);
         Inform
            ( R,
              'Database file "%s" is in use'^M^M +
              ' - %d user object(s) hold(s) %d byte(s) in file'^M +
              ' - %d hole(s) hold(s) %d byte(s) in file'^M +
              ' - Ancillary information holds %d byte(s)'^M +
              ' - Total size of database is %d byte(s)',
              @DataRec )
      end;

{ ----- CreateMod ----- }

   procedure TDemoApplication.CreateMod;

      var
         NewDial  : PDialog;
         C        : Word;
         DialData : ModDialData;
         Card     : PInvCard;
         Invent   : PCatCollection;
         PID      : Word;

      begin
         NewDial := NameDialog ('New module');
         if NewDial = nil
            then Exit;
         C := DeskTop^.ExecView (NewDial);
         if C <> CmCancel
            then begin
                    NewDial^.GetData (DialData);
                    if DialData.NameData <> ''
                       then begin
                               Invent := PCatCollection (DB^.Get (InvPID));
                               New (Card);
                               PID := DB^.Create;
                               Card^.Name := DialData.NameData;
                               Card^.ID := PID;
                               Invent^.Insert (Card);
                               DB^.Put (PID, NewDial);
                               DB^.Destroy (InvPID);
                               DB^.Put (InvPID, Invent);
                               Dispose (Invent, Done)
                            end
                 end;
         Dispose (NewDial, Done)
      end;

{ ----- GetMod ----- }

   procedure TDemoApplication.GetMod;

      var
         Dial,
         DialFromDB : PDialog;
         C          : Word;
         DialData   : ModDialData;
         Card       : PInvCard;
         Invent     : PCatCollection;
         Ind        : Integer;

      begin
         Dial := NameDialog ('Get');
         if Dial = nil
            then Exit;
         C := DeskTop^.ExecView (Dial);
         if C <> CmCancel
            then begin
                    Dial^.GetData (DialData);
                    New (Card);
                    Card^.Name := DialData.NameData;
                    Invent := PCatCollection (DB^.Get (InvPID));
                    if Invent^.Search (Card, Ind)
                       then begin
                               DialFromDB :=
                                   PDialog (DB^.Get
                                           (TInvCard(Invent^.At(Ind)^).ID));
                               C := ExecView (DialFromDB);
                               Dispose (DialFromDB, Done)
                            end;
                    Dispose (Invent, Done)
                 end;
         Dispose (Dial, Done)
      end;

{ ----- DeleteMod ----- }

   procedure TDemoApplication.DeleteMod;

      var
         Dial     : PDialog;
         C        : Word;
         DialData : ModDialData;
         Card     : PInvCard;
         Invent   : PCatCollection;
         Ind      : Integer;

      begin
         Dial := NameDialog ('Delete');
         if Dial = nil
            then Exit;
         C := DeskTop^.ExecView (Dial);
         if C <> CmCancel
            then begin
                    Dial^.GetData (DialData);
                    New (Card);
                    Card^.Name := DialData.NameData;
                    Invent := PCatCollection (DB^.Get (InvPID));
                    if Invent^.Search (Card, Ind)
                       then begin
                               DB^.Destroy (TInvCard(Invent^.At(Ind)^).ID);
                               Invent^.AtDelete (Ind);
                               DB^.Destroy (InvPID);
                               DB^.Put (InvPID, Invent)
                            end;
                    Dispose (Invent, Done)
                 end;
         Dispose (Dial, Done)
      end;

{ ----- Commit ----- }

   procedure TDemoApplication.Commit;

      var
         Dial : PDialog;
         C    : Word;

      begin
         if DB <> nil
            then begin
                    if Confirm
                       ( ^C'All changes you''ve made since last Commit '^M +
                         ^C'will be placed into the database forever !' ) =
                       cmCancel
                       then Exit;
                    DB^.Commit
                 end
            else HandleError ( ^C'No database is in use now !' )
      end;

{ ----- Rollback ----- }

   procedure TDemoApplication.Rollback;

      var
         Dial   : PDialog;
         C      : Word;

      begin
         if DB <> nil
            then begin
                    if Confirm
                       ( ^C'You are restoring database to its old state.'^M +
                         ^C'Changes since last Commit will be lost !' ) =
                       cmCancel
                       then Exit;
                    DB^.Abort;
                 end
            else HandleError ( ^C'No database is in use now !' )
      end;

procedure RegisterAll;

    const
       RCatCollection: TStreamRec =
           ( ObjType : 10001;
             VMTLink : Ofs(TypeOf(TCatCollection)^);
             Load    : @TCatCollection.Load;
             Store   : @TCatCollection.Store );

    begin
       RegisterObjects;
       RegisterViews;
       RegisterDialogs;
       RegisterType (RCatCollection)
    end;

{ ----- Program body ----- }

   var
      DA     : TDemoApplication;

   begin
      RegisterAll;
      DA.Init;
      DA.Run;
      DA.Done
   end.

   { ---------------------   LAYOUT.PAS ---------------------- }
   { CUT }

unit Layout;

interface

   uses Objects, MsgBox;

   procedure HandleError ( Mess: String );
   procedure Inform ( R: TRect; Mess: String; Params: Pointer );
   function  Confirm ( Mess: String ): Word;

implementation

   procedure HandleError ( Mess: String );
       var C: Word;
       begin
          C := MessageBox ( Mess, nil, mfError + mfOKButton )
       end;

   procedure Inform ( R: TRect; Mess: String; Params: Pointer );
       var C: Word;
       begin
          C := MessageBoxRect ( R, Mess, Params,
                                mfInformation + mfOKButton )
       end;

   function Confirm ( Mess: String ): Word;
       var R: TRect;
       begin
          R.Assign (10,4,60,12);
          Confirm := MessageBoxRect ( R, Mess, nil,
                                      mfConfirmation + mfOKCancel )
       end;

   end.

   { ---------------------   OODB.PAS ---------------------- }
   { CUT }

unit OODB;

interface

   uses Objects;

   const
      PIDLimit: Word = $7FFF;
      Delta = 4;
      Hallmark = 9999;
      IndexPointerLocation = 4;
      StorageStart = 8;

   type

      { Record type for object registration }

      IndRec =
         record
            ID        : Word;
            StartPos,
            Size      : Longint;
            Base      : Integer
         end;
      PIndRec = ^IndRec;

      { Stream for object size evaluation }

      TNullStream =
         object (TStream)
            SizeCounter : Longint;
            constructor Init;
            procedure   ResetCounter;                   virtual;
            procedure   Write (var Buf; Count: Word);   virtual;
            function    SizeInStream: Longint;          virtual;
         end;
      PNullStream = ^TNullStream;

      { Stream - database main storage }

      DBStream = TStream;
      PDBStream = ^DBStream;

      { Collection for indexes }

      TIndexCollection =
         object (TCollection)
            procedure FreeItem (Item: Pointer);                 virtual;
            function  GetItem (var S: TStream): Pointer;        virtual;
            procedure PutItem (var S: TStream; Item: Pointer);  virtual;
         end;
      PIndexCollection = ^TIndexCollection;

      { --- TBASE - the main class --- }

      TBase =
         object (TObject)

            BaseStream : PDBStream;         { Main storage pointer }
            DBIndex,                        { Database index }
            HolesIndex : PIndexCollection;  { Holes index }
            PIDCurrent : Word;              { Unique identifier }
            NS         : PNullStream;       { For object size evaluation }
            DoneFlag   : Boolean;           { True if OODB is being disposed }

            function  BytesInStream (P: PObject): Longint ;
                               virtual;
            procedure IndexSort (Cat: PIndexCollection; StOrd: Boolean);
                               virtual;
            function  IndexFound (Cat: PIndexCollection;
                                  LookFor: Longint;
                                  var Pos: Integer;
                                  PIDSorted: Boolean): Boolean;
                               virtual;
            function  HoleFound (S: Longint; var Pos: Longint): Boolean;
                               virtual;

            procedure   Abort;                          virtual;
            procedure   Commit;                         virtual;
            constructor Init (AStream: PDBStream);
            destructor  Done;                           virtual;
            function    Create: Word;                   virtual;
            procedure   Put (PID: Word; P: PObject);    virtual;
            function    Get (PID: Word): PObject;       virtual;
            procedure   Destroy (PID: Word);            virtual;

            function    ObjSize (PID: Word): Longint;   virtual;
            function    Count: Integer;                 virtual;

            procedure   IdlePack;                       virtual;

         end; { -- TBase -- }
      PBase = ^TBase;

implementation

   { -- Implementation of TNullStream -- }

   constructor TNullStream.Init;
      begin
         TStream.Init;
         ResetCounter
      end;

   procedure TNullStream.ResetCounter;
      begin
         SizeCounter := 0
      end;

   procedure TNullStream.Write (var Buf; Count: Word);
      { Overrides TStream.Write method }
      begin
         SizeCounter := SizeCounter + Count
      end;

   function TNullStream.SizeInStream: Longint;
      begin
         SizeInStream := SizeCounter
      end;

   { -- End of TNullStream implementation -- }

   { -- Implementation of TIndexCollection -- }

   procedure TIndexCollection.FreeItem (Item: Pointer);

      begin
         Dispose (Item)
      end;  { FreeItem }

   function TIndexCollection.GetItem (var S: TStream): Pointer;

      var Item : PIndRec;

      begin
         New (Item);
         with S do
              with Item^ do
                   begin
                      Read (ID, SizeOf(ID));
                      Read (StartPos, SizeOf(StartPos));
                      Read (Size, SizeOf(Size));
                      Read (Base, SizeOf(Base))
                   end;
         GetItem := Item
      end;  { GetItem }

   procedure TIndexCollection.PutItem (var S: TStream; Item: Pointer);

      begin
         with S do
              with IndRec(Item^) do
                   begin
                      Write (ID, SizeOf(ID));
                      Write (StartPos, SizeOf(StartPos));
                      Write (Size, SizeOf(Size));
                      Write (Base, SizeOf(Base))
                   end
      end;  { PutItem }

   { -- End of TIndexCollection implementation -- }

   { -- TBASE IMPLEMENTATION -- }

   { ----- BytesInStream ------------------------------------------ }

   function TBase.BytesInStream (P: PObject): Longint ;

   { Determines the number of bytes required
     to put an object into the stream }

      begin
         with NS^ do
              begin
                 ResetCounter;
                 Put (P);
                 BytesInStream := SizeInStream
              end
      end;

   { ----- IndexSort ---------------------------------------------- }

   procedure TBase.IndexSort (Cat: PIndexCollection; StOrd: Boolean);

   { Bubble-sorts any index (DBIndex or HolesIndex) according either to
     StartPos'es in a stream (StOrd = True) or to PID's (StOrd = False) }

      var
         i, j, k : Integer;
         Min     : Longint;
         Aux     : PIndRec;

      begin

         with Cat^ do

              for i := 0 to Count-2 do

                  begin
                     if StOrd
                        then begin
                                Min := IndRec(At(i)^).StartPos; k := i;
                                for j := i+1 to Count-1 do
                                    if IndRec(At(j)^).StartPos < Min
                                        then begin
                                                k := j;
                                                Min := IndRec(At(k)^).StartPos
                                             end
                             end
                        else begin
                                Min := IndRec(At(i)^).ID; k := i;
                                for j := i+1 to Count-1 do
                                    if IndRec(At(j)^).ID < Min
                                       then begin
                                               k := j;
                                               Min := IndRec(At(k)^).ID
                                            end
                             end;
                     Aux := At (i);
                     AtPut (i,At(k)); AtPut (k,Aux)    { Bubble is up }
                  end  { for }

      end; { IndexSort }

   { ----- IndexFound --------------------------------------------- }

   function TBase.IndexFound
                  (Cat: PIndexCollection; LookFor: Longint;
                   var Pos: Integer; PIDSorted: Boolean)    : Boolean;

   { Looks for LookFor in Cat^ index (binary search) and returns True
     if hits it. Position for LookFor (Pos) is located by all means }

      var
         m, j  : Integer;
         Value : Longint;     { Value that is found }

      begin

         IndexFound := False;
         with Cat^ do
              begin
                 Pos := 0; j := Count-1;
                 if j < Pos
                    then Exit;
                 while j > Pos do
                       begin
                          m := ( Pos + j ) div 2;
                          if ( PIDSorted and
                               (IndRec(At(m)^).ID >= LookFor) )
                             or
                             ( not PIDSorted and
                               (IndRec(At(m)^).StartPos >= LookFor) )
                             then j := m
                             else Pos := m + 1
                       end; { while }
                 if PIDSorted
                    then Value := IndRec(At(Pos)^).ID
                    else Value := IndRec(At(Pos)^).StartPos;
                 if Value < LookFor
                    then Pos := Pos + 1
                    else if Value = LookFor
                            then IndexFound := True
              end  { with }

      end; { IndexFound }

   { ----- HoleFound ---------------------------------------------- }

   function TBase.HoleFound (S: Longint; var Pos: Longint): Boolean;

   { Looks for a hole in a storage stream.
     Linear search, FIRST-FIT }

      var
         Found : Boolean;
         i     : Integer;

      begin

         with HolesIndex^ do
              begin
                 Found := False; i := 0;
                 while not (Found or (i > Count-1)) do
                       begin
                          with IndRec(At(i)^) do
                               if Size >= S
                                  then begin
                                          Found := True;
                                          Pos := StartPos;
                                          Size := Size - S;
                                          if Size = 0
                                             then AtDelete(i)
                                       end; { if }
                          i := i + 1
                       end  { while }
              end;  { with }
         HoleFound := Found

      end; { HoleFound }

   { ----- Abort ---------------------------------------------- }

   procedure TBase.Abort;

   { Cancels transaction. Restores old DBIndex and HolesIndex }

      var
         HoleStart,               { Start of probable hole }
         Diff,                    { Length of probable hole }
         IndLoc      : Longint;   { Old DBIndex location in stream }
         i           : Integer;
         NewRec      : PIndRec;   { Hole registration card }

      begin

         Dispose (DBIndex, Done);    { Destroying old indexes }
         Dispose (HolesIndex, Done);
         with BaseStream^ do
              begin
                 Seek (IndexPointerLocation); Read (IndLoc,4);
                 Seek (IndLoc); DBIndex := PIndexCollection (Get)
              end;
         New (HolesIndex, Init(PIDLimit,Delta));
         with DBIndex^ do
              begin
                 HoleStart := StorageStart;
                 for i := 0 to Count-1 do
                     begin
                        Diff := IndRec(At(i)^).StartPos - HoleStart;
                        if Diff > 0
                           then begin
                                   New (NewRec);
                                   with NewRec^ do
                                        begin
                                           StartPos := HoleStart;
                                           Size := Diff
                                        end;
                                   HolesIndex^.Insert(NewRec)
                                end;  { if }
                        HoleStart := IndRec(At(i)^).StartPos +
                                        IndRec(At(i)^).Size
                     end;  { for }
                 BaseStream^.Seek (HoleStart); BaseStream^.Truncate
              end;  { with }
         IndexSort (DBIndex, False);
         IndexSort (HolesIndex, True);
         PIDCurrent := IndRec(DBIndex^.At(DBIndex^.Count-1)^).ID + 1

      end;  { Abort }

   { ----- Commit ---------------------------------------------- }

   procedure TBase.Commit;

   { Acknowledges transaction by putting DBIndex into the stream }

      var
         S,                      { Size of DBIndex }
         IndLoc     : Longint;   { Index location in stream }
         i, BasePos : Integer;   { Auxiliary variables }

      begin

         with DBIndex^ do
              begin

                 for i := 0 to Count-1 do
                     begin
                        BasePos := IndRec(At(i)^).Base;
                        if (BasePos <> -1) and (BasePos <> i)
                           then begin
                                   IndRec(At(i)^).Size :=
                                         IndRec(At(BasePos)^).Size;
                                   IndRec(At(i)^).StartPos :=
                                         IndRec(At(BasePos)^).StartPos;
                                   IndRec(At(i)^).Base := i;
                                   IndRec(At(BasePos)^).Base := -1
                                end
                     end;  { for }

                 i := 0;
                 while ( i < Count ) do
                       if IndRec(At(i)^).Base = -1
                          then AtDelete (i)
                          else i := i + 1;

                 for i := 0 to Count-1 do
                     IndRec(At(i)^).Base := i

              end;   { with }

         S := BytesInStream (DBIndex);
         if not HoleFound (S, IndLoc)
            then IndLoc := BaseStream^.GetSize;
         with IndRec(DBIndex^.At(0)^) do
              begin
                 ID := 0;
                 StartPos := IndLoc;
                 Size := S;
                 Base := 0
              end;
         IndexSort (DBIndex, True);
         with BaseStream^ do
              begin
                 Seek (IndLoc); Put (DBIndex);
                 Seek (IndexPointerLocation); Write (IndLoc,4)
              end;
         if not DoneFlag
            then Abort

      end;  { Commit }

   { ----- Init ---------------------------------------------- }

   constructor TBase.Init (AStream: PDBStream);

   { Opens an existing database stream or creates a new one }

      var
         Descr     : Longint;    { Stream descriptor }
         IndexCard : PIndRec;    { DBIndex registration card }

      begin

         TObject.Init;
         BaseStream := AStream;
         New (NS, Init);
         New (DBIndex, Init(PIDLimit,Delta));
         New (HolesIndex, Init(PIDLimit,Delta));
         DoneFlag := False;
         with BaseStream^ do
              begin
                 Descr := 0;
                 Seek (0);
                 if GetSize > 3 then
                    Read (Descr,4);
                 if Descr = Hallmark
                    then Abort
                    else begin
                            Descr := Hallmark;
                            Seek (0); Truncate; Write (Descr,4);
                            Seek (IndexPointerLocation); Write (Descr,4);
                            New (IndexCard);
                            With IndexCard^ do
                                 begin
                                    ID := 0;
                                    StartPos := StorageStart;
                                    Size := 0;
                                    Base := 0
                                 end;
                            DBIndex^.AtInsert (0,IndexCard);
                            Commit
                         end
              end  { with }

      end;  {  Init  }

   { ----- Done ---------------------------------------------- }

   destructor TBase.Done;

   { Done is done ! }

      begin
         DoneFlag := True;
         Commit;
         Dispose (NS, Done);
         Dispose (DBIndex, Done);
         Dispose (HolesIndex, Done)
      end;  { Done }

   { ----- Create ---------------------------------------------- }

   function TBase.Create : Word;

   { Generates unique identifier }

      begin
         if PIDCurrent < PIDLimit
            then begin
                    Create := PIDCurrent;
                    PIDCurrent := PIDCurrent + 1
                 end
            else Create := 0
      end;  { Create }

   { ----- Destroy ---------------------------------------------- }

   procedure TBase.Destroy (PID: Word);

   { Marks object registration card in DBIndex as destroyed (Base = -1).
     If object's base has existed in a stream, it becomes a hole.
     Object doesn't vanish from a stream until transaction is over
     (Commit or Done). }

      var
         Pos,                     { Number of object's card in DBIndex }
         HolePos,                 { Number of a potential hole }
         BasePos     : Integer;
         BaseStart,
         BaseSize    : Longint;   { Charasteristics of object's base }
         NewRec      : PIndRec;   { New hole }
         i           : Integer;

      begin

         with DBIndex^ do
           begin
             if not IndexFound (DBIndex, PID, Pos, True)
                then Exit;
             BasePos := IndRec(At(Pos)^).Base;
             IndRec(At(Pos)^).Base := -1;
             if (BasePos = -1) or (BasePos = Pos)
                then Exit;
             if IndexFound (HolesIndex, IndRec(At(BasePos)^).StartPos,
                            HolePos, False)
                then Halt (1);
             BaseStart := IndRec(At(BasePos)^).StartPos;
             BaseSize  := IndRec(At(BasePos)^).Size;
             if HolePos < HolesIndex^.Count
                then if BaseStart + BasePos =
                        IndRec(HolesIndex^.At(HolePos)^).StartPos
                        then begin
                               IndRec(HolesIndex^.At(HolePos)^).StartPos :=
                                      BaseStart;
                               IndRec(HolesIndex^.At(HolePos)^).Size :=
                                      IndRec(HolesIndex^.At(HolePos)^).Size +
                                      BaseSize;
                               Exit
                             end;
             if BaseStart + BaseSize < BaseStream^.GetSize
                then begin
                        New (NewRec);
                        NewRec^.StartPos := BaseStart;
                        NewRec^.Size := BaseSize;
                        HolesIndex^.AtInsert (HolePos, NewRec)
                     end
                else begin
                        BaseStream^.Seek (BaseStart);
                        BaseStream^.Truncate
                     end;
             AtDelete (BasePos);
             for i := BasePos to Count-1 do
                 if IndRec(At(i)^).Base <> -1
                    then IndRec(At(i)^).Base := IndRec(At(i)^).Base-1
           end  { with }

      end;  { Destroy }

   { ----- Put ---------------------------------------------- }

   procedure TBase.Put (PID: Word; P: PObject);

   { Puts an object into the database }

      var
         StreamPos, S : Longint;   { Location and size of an object }
         Pos,                      { Number of object registration card }
         BasePos      : Integer;   { Number of object's base card }
         NewRec       : PIndRec;   { Object registration card }

      begin

         if PID >= PIDLimit
            then Exit;
         with DBIndex^ do
              if IndexFound (DBIndex, PID, Pos, True)
                 then begin
                         BasePos := IndRec(At(Pos)^).Base;
                         if BasePos <> Pos
                            then begin
                                    if BasePos <> -1
                                       then Exit;
                                    PID := Create;
                                    if IndexFound (DBIndex, PID,
                                                   BasePos, True )
                                       then Halt (1);
                                    IndRec(At(Pos)^).Base := BasePos;
                                    Pos := BasePos
                                 end  { if }
                      end;  { if }
         S := BytesInStream (P);
         if not HoleFound (S, StreamPos)
            then StreamPos := BaseStream^.GetSize;
         New (NewRec);
         with NewRec^ do
              begin
                 ID := PID;
                 StartPos := StreamPos;
                 Size := S;
                 Base := Pos
              end;
         DBIndex^.AtInsert (Pos, NewRec);
         with BaseStream^ do
              begin
                 Seek (StreamPos); Put (P)
              end

      end;  { Put }

   { ----- Get ---------------------------------------------- }

   function TBase.Get (PID: Word): PObject;

   { Gets an object from the database }

      var
         Pos,                { Number of object registration card }
         BasePos : Integer;  { Number of object's base card }

      begin
         Get := Nil;
         if IndexFound (DBIndex, PID, Pos, True)
            then begin
                    BasePos := IndRec(DBIndex^.At(Pos)^).Base;
                    if BasePos <> -1
                       then begin
                               BaseStream^.Seek
                                   (IndRec(DBIndex^.At(BasePos)^).StartPos);
                               Get := BaseStream^.Get
                            end  { if }
                 end  { if }
      end;  { Get }

   { ----- ObjSize ---------------------------------------------- }

   function TBase.ObjSize (PID: Word): Longint;

   { Returns the size of an object }

      var
         Pos,                { Number of object registration card }
         BasePos : Integer;  { Number of object's base card }

      begin
         ObjSize := 0;
         if IndexFound (DBIndex, PID, Pos, True)
            then begin
                    BasePos := IndRec(DBIndex^.At(Pos)^).Base;
                    if BasePos <> -1
                       then ObjSize := IndRec(DBIndex^.At(BasePos)^).Size
                 end  { if }
      end;  { ObjSize }

   { ----- Count ---------------------------------------------- }

   function TBase.Count: Integer;

   { Returns the number of objects in the database }

      begin
         Count := DBIndex^.Count
      end;  { Count }

   { ----- IdlePack ---------------------------------------------- }

   procedure TBase.IdlePack;

   { Makes a single step of database packing.
     Method (just now) - simple sequential relocation.
     Before object is relocated, old index is gotten
     from the stream and then put back with proper amendments. }

      var
          P         : PObject;           { Relocated object }
          OldLoc,                        { Old location of relocated object }
          NewLoc,                        { New location of relocated object }
          IndLoc    : Longint;           { Location of old DBIndex }
          OldIndex  : PIndexCollection;  { Old DBIndex }
          Pos       : Integer;           { Posititon of relocated object
                                           in the index }

      begin

         with HolesIndex^ do
           with BaseStream^ do
             begin

               if Count = 0
                  then Exit;
               OldLoc := IndRec(At(0)^).StartPos + IndRec(At(0)^).Size;
               NewLoc := IndRec(At(0)^).StartPos;
               Seek (OldLoc); P := Get;
               if P = Nil
                  then begin
                          Reset;
                          Seek (NewLoc); Truncate;
                          AtDelete (0);
                          Exit
                       end;
               Seek (IndexPointerLocation); Read (IndLoc,4);
               Seek (IndLoc); OldIndex := PIndexCollection (Get);

               if IndexFound (OldIndex, OldLoc, Pos, False)
                  then begin
                          IndRec(OldIndex^.At(Pos)^).StartPos := NewLoc;
                          if not IndexFound (DBIndex,
                                             IndRec(OldIndex^.At(Pos)^).ID,
                                             Pos, True)
                             then Halt (1)
                       end
                  else begin
                          Pos := 0;
                          while (IndRec(DBIndex^.At(Pos)^).StartPos <>
                                 OldLoc) do
                                Pos := Pos + 1
                        end;
               IndRec(DBIndex^.At(Pos)^).StartPos := NewLoc;

               if OldLoc = IndLoc
                  then IndLoc := NewLoc;
               Seek (NewLoc); Put (P);
               Seek (IndexPointerLocation); Write (IndLoc,4);
               Seek (IndLoc); Put (OldIndex);
               Dispose (P,Done); Dispose (OldIndex, Done);

               IndRec(At(0)^).StartPos :=
                      NewLoc + IndRec(DBIndex^.At(Pos)^).Size;
               if Count > 1
                  then if ( IndRec(At(0)^).StartPos + IndRec(At(0)^).Size =
                            IndRec(At(1)^).StartPos )
                          then begin
                                 IndRec(At(0)^).Size :=
                                 IndRec(At(0)^).Size + IndRec(At(1)^).Size;
                                 AtDelete (1)
                               end

             end  { With }
      end;  { IdlePack }

    { -- End of TBase implementation -- }

   const
      RIndexCollection: TStreamRec =
         ( ObjType : 10000;
           VMTLink : Ofs(TypeOf(TIndexCollection)^);
           Load    : @TIndexCollection.Load;
           Store   : @TIndexCollection.Store );

begin

  { Unit body }

  RegisterType (RIndexCollection)

end.

