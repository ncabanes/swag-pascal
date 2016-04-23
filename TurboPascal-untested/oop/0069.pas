{
672: How to Create a Listbox and Get a Double Click
   Pascal   All       TI-09/30/94

Demonstrates handling double click on a
listbox.

  PRODUCT  :  Pascal                                 NUMBER  :  672
  VERSION  :  All
       OS  :  DOS
     DATE  :  September 30, 1994                       PAGE  :  1/1

    TITLE  :  How to Create a Listbox and Get a Double Click
{

The following example demonstrates how to create a listbox
of file items and enable the user to double click on any item.
This produces a Message Box containing the listbox selected

item.

}
{$X+}
Program Simple_ListBox;

Uses
  Objects, Drivers, Views, Menus, Dialogs, App, Crt, Dos, MsgBox;

Const
 cmNewCollect = 102;

Type

 TMyApp = object(TApplication)
     Constructor Init;
     Procedure Initstatusline; Virtual;
     Procedure Initmenubar; Virtual;
     Procedure NewCollect; Virtual;
     Procedure HandleEvent(var Event: TEvent); Virtual;
   End;

  PListBox = ^RListBox;
  RListBox = object(TListBox)
    Constructor Init(var Bounds:TRect; ANumCols:Word; AScrollBar:

                         PScrollBar);
    Procedure Process;
    Destructor Done; Virtual;
  End;

  PMyDialog = ^MyDialog;
  MyDialog = object(TDialog)
    Constructor Init(var Bounds: TRect; MyTitle:TTitleStr);
    Destructor Done; Virtual;
    Procedure HandleEvent(var Event: TEvent); Virtual;
  End;

Var
  NameList: PStringCollection;
  PList: ^Rlistbox;
  MyApp: TMyApp;

Constructor Mydialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
Begin
  TDialog.Init(Bounds, MyTitle);

End;

Destructor Mydialog.Done;
Begin
  TDialog.Done;
  Dispose(NameList, Done);
End;

Procedure MyDialog.HandleEvent(var Event:TEvent);
var
  Index: integer;
Begin
  TDialog.HandleEvent(Event);
  if (Event.Double = true) and (Event.What = evNothing) then
    begin
      sound(100);
      delay(100);
      nosound;
      Index:=(PList^.Focused);
      Messagebox(PList^.GetText(Index,20) ,nil, mfOkButton);
    end;
  ClearEvent(Event);
End;

Constructor TMyApp.Init;

Begin
  TApplication.Init;
End;

Constructor RListBox.Init(var Bounds:TRect; ANumCols:Word;
AScrollBar:
                          PScrollBar);
Begin
  TListBox.Init(Bounds, ANumCols, AScrollBar);
End;

Destructor RListBox.Done;
Begin
  TListBox.Done;
End;

Procedure TMyApp.InitStatusLine;
Var
  R:TRect;
Begin
  GetExtent(R);
  R.A.Y := R.B.Y -1;
  Statusline :=new(PStatusLine, init(R,
  NewStatusDef(0,$FFFF,
  NewStatusKey('~Alt-X~ Exit',kbAltX, cmQuit,

  NewStatusKey('~F10~ Menu',kbF10,cmMenu,
  Nil)),Nil)
  ));
End;

Procedure RListBox.Process;
var
  DirInfo: SearchRec;
Begin
  NameList:=New(PStringCollection, Init(50,10));
  With NameList^ do
  Begin
    FindFirst('*.*', Archive, DirInfo);
    while DosError = 0 do
      Begin
        Insert(Newstr(Dirinfo.Name));
        FindNext(DirInfo);
      End;
  End;
End;

Procedure TMyApp.NewCollect;
Var
  MyBox: PMyDialog;
  R: TRect;
  PBorland: ^TScrollBar;

  Col: word;
Begin
  Plist^.Process;
  R.Assign(10,10,60,20);
  MyBox := New(PMyDialog, Init(R, 'Scroll Collection'));
  Col:=1;
  R.Assign(40, 1, 41, 9);
  PBorland:= New(PScrollBar, Init(R));
  R.Assign(9, 1, 40, 9);
  Plist:=New(PListbox, Init(R,Col,PBorland));
  Plist^.Newlist(Namelist);
  MyBox^.Insert(PBorland);
  MyBox^.Insert(PList);
  Desktop^.Insert(MyBox);
End;

Procedure TMyApp.HandleEvent(var Event: TEvent);
Begin
  TApplication.HandleEvent(Event);

  if Event.What = evCommand then
    Begin
      case Event.Command of
        cmNewCollect: Newcollect;
      else
        ClearEvent(Event);
        Exit;
      End;
      ClearEvent(Event);
    End;
End;

Procedure TMyApp.InitMenubar;
var
  R: TRect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y +1;
  MenuBar :=new(PMenubar, Init(R, Newmenu(
  NewSubMenu('~L~istbox Menu', hcNoContext, Newmenu(
  NewItem('~B~ox','',kbF9, cmnewcollect, hcnocontext,
  NewLine(

  NewItem('~E~xit','', kbf10, cmquit, hcnocontext,
  Nil)))), Nil))));
End;








PRODUCT  :  Turbo Pascal                           NUMBER  :  672
VERSION  :  6.0
     OS  :  MS/PC DOS
   DATE  :  June 23, 1994                            PAGE  :  2/5

  TITLE  :  How to Create a Listbox and Get a Double Click




Begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.


DISCLAIMER: You have the right to use this technical information
subject to the terms of the No-Nonsense License Statement that

you received with the Borland product to which this information
pertains.
PACHXA296:PACHXA296

