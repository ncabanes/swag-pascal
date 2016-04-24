(*
  Category: SWAG Title: STREAM HANDLING ROUTINES
  Original name: 0006.PAS
  Description: Simple STREAM Example
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:09
*)

{
This program example will demonstrate how to save your
desktop using a stream.  It will give you the ability
to insert windows on the destop and save the state in a
.DSK file and load them from the file to restore its'
state.  Streams REQURE registration of decendant object
types.  Many fall folly to using objects in a stream
that have not been registered.

}

Program Simple_Stream;

Uses Objects, Drivers, Views, Menus, App;

Type
  PMyApp = ^MyApp;
  MyApp = Object(TApplication)
     Constructor Init;
     Procedure InitStatusLine; Virtual;
     Procedure InitMenuBar; Virtual;
     Procedure HandleEvent(var Event: TEvent); Virtual;
     Procedure NewWindow;
     Destructor Done; Virtual;
  End;

  PMyWindow = ^TMyWindow;
  TMyWindow = Object(TWindow)
     Constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
  End;

  PMyDeskTop = ^TMyDeskTop;
  TMyDeskTop = object(TDeskTop)
     Windw: PMyWindow;
     Constructor Load(var S:TBufStream);
     Procedure Store(var S: TBufStream); Virtual;
  End;

Const
  cmNewWin   = 101;
  cmSaveDesk = 102;
  cmLoadDesk = 103;

  RMyDeskTop: TstreamRec = (
     ObjType : 1001;
     VmtLink : Ofs(TypeOf(TMyDeskTop)^);
     Load    : @TMyDeskTop.Load;
     Store   : @TMyDeskTop.Store
  );

  RMyWindow: TstreamRec = (
     ObjType : 1002;
     VmtLink : Ofs(TypeOf(TMyWindow)^);
     Load    : @TMyWindow.Load;
     Store   : @TMyWindow.Store
  );

Procedure SaveDeskStream;
Var
  SaveFile:TBufStream;
Begin
  SaveFile.Init('Rdesk.dsk',stCreate,1024);
  SaveFile.Put(DeskTop);
  If Savefile.Status <>0 then
    write('Bad Save',Savefile.Status);
  SaveFile.Done;
End;

Procedure LoadDeskStream;
Var
  SaveFile:TBufStream;
Begin
  SaveFile.Init('Rdesk.dsk',stOpen,1024);
  DeskTop^.insert(PMyDeskTop(SaveFile.Get));
  If Savefile.Status <>0 then
    write('Bad Load',Savefile.Status)
  else
    DeskTop^.ReDraw;
  SaveFile.Done;
End;

{ ** MyApp **}
Constructor MyApp.Init;
Begin
  TApplication.Init;
  RegisterType(RMyDesktop);
  RegisterType(RDesktop);
  RegisterType(Rwindow);
  RegisterType(RMywindow);
  RegisterType(RFrame);
  RegisterType(RMenuBar);
  RegisterType(RStatusLine);
  RegisterType(RBackground);
End;

Destructor MyApp.Done;
Begin
  TApplication.Done;
End;

Procedure MyApp.InitMenuBar;
Var
  R: TRect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcNoContext, NewMenu(
    NewItem('~N~ew', 'F4', kbF4, cmNewWin, hcNoContext,
    NewLine(
       NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
       Nil)))),
    NewSubMenu('~D~eskTop', hcNoContext, NewMenu(
       NewItem('~S~ave Desktop','',kbF2,cmSaveDesk,hcNoContext,
       NewItem('~L~oad Desktop','',kbF3,cmLoadDesk,hcNoContext,
    nil))),nil)))));
End;

Procedure MyApp.InitStatusLine;
Var
  R: TRect;
Begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
  NewStatusDef(0, $FFFF,
    NewStatusKey('', kbF10, cmMenu,
    NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
    NewStatusKey('~F4~ New', kbF4, cmNewWin,
    NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
    nil)))),
  nil)));
End;

Procedure MyApp.HandleEvent(var Event: TEvent);
Begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    Begin
      Case Event.Command of
        cmNewWin: NewWindow;
        cmSaveDesk:SaveDeskStream;
        cmLoadDesk:LoadDeskStream;
      else
        Exit;
      End;
      ClearEvent(Event);
    End;
End;

Procedure MyApp.NewWindow;
Var
  Window:PMyWindow;
  R: TRect;
Begin
  R.Assign(0, 0, 24, 7);
  R.Move(Random(55), Random(16));
  Window := New(PMyWindow, Init(R, 'Demo Window', 1));
  DeskTop^.Insert(Window);
End;

{ ** MyDeskTop **}
Constructor TMyDeskTop.Load(Var S: TBufStream);
Begin
  TDeskTop.Load(S);
  GetSubViewPtr(S,Windw);
End;

Procedure TMyDeskTop.Store(Var S: TBufStream);
Begin
  TDeskTop.Store(S);
  PutSubViewPtr(S,Windw);
End;

{ ** MyWindow **}
Constructor TMyWindow.Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
Begin
  TWindow.init(Bounds,WinTitle,WindowNo);
End;

{ Main Program }
Var
  MyTApp:MyApp;

Begin
  MyTApp.Init;
  MyTApp.Run;
  MyTApp.Done;
End.

