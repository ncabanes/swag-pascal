(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0056.PAS
  Description: Another Example of TV Dir Collection
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:01
*)

{
The following example will demonstrate how to create a listbox
of file items and enable the user to double click on any item and
produce a Message Box with the listbox item selected.
}
{$X+}
Program Simple_ListBox;

Uses
  Objects, Drivers, Views, Menus, Dialogs, App, Crt, Dos, MsgBox;

Const
 cmNewCollect = 102;
 DisableNewcollect: TCommandSet = [102];

Type

 Tmyapp = object(Tapplication)
     Constructor Init;
     Procedure Initstatusline; Virtual;
     Procedure Initmenubar; Virtual;
     Procedure NewCollect; Virtual;
     Procedure HandleEvent(var Event: TEvent); Virtual;
   End;

  PListBox = ^RListBox;
  RListBox = object(TlistBox)
    Constructor Init(var Bounds:TRect; ANumCols:Word; AScrollBar:
                         PScrollBar);
    Procedure Process;
    Destructor Done; Virtual;
  End;

  PMyDialog = ^MyDialog;
  Mydialog = object(Tdialog)
    Constructor Init(var bounds:trect; MyTitle:ttitlestr);
    Destructor done; Virtual;
    Procedure HandleEvent(var Event: TEvent); Virtual;
  End;

Var
  NameList: PstringCollection;
  Plist: ^Rlistbox;
  MyApp: Tmyapp;

Constructor Mydialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
Begin
  TDialog.Init(Bounds, MyTitle);
End;

Destructor Mydialog.Done;
Begin
  TDialog.done;
  Dispose(NameList, Done);
  EnableCommands(DisableNewCollect);
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
      Index:=(Plist^.Focused);
      Messagebox(Plist^.GetText(Index,20) ,nil,mfOkButton);
    end;
  ClearEvent(Event);
End;

Constructor TMyapp.Init;
Begin
  TApplication.Init;
End;

Constructor RListBox.Init(var Bounds:TRect; ANumCols:Word;AScrollBar:
                          PScrollBar);
Begin
  TListBox.Init(Bounds, ANumCols, AScrollBar);
End;

Destructor RListBox.Done;
Begin
  Tlistbox.Done;
End;

Procedure TMyApp.InitStatusLine;
Var
  R:Trect;
Begin
  GetExtent(R);
  R.A.Y := R.B.Y -1;
  Statusline :=new(Pstatusline, init(R,
  NewStatusDef(0,$FFFF,
  NewStatusKey('~Alt-X~ Exit',kbAltX, cmQuit,
  NewStatusKey('~F10~ Menu',kbF10,cmMenu,
  Nil)),Nil)
  ));
End;

Procedure Rlistbox.Process;
var
  DirInfo: SearchRec;
Begin
  NameList:=New(Pstringcollection,Init(50,10));
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
  R : TRect;
  pBor : ^TScrollBar;
  Col: word;
Begin
  Plist^.Process;
  R.Assign(10,10,60,20);
  MyBox := New(PmyDialog, Init(R, 'Scroll Collection'));
  Col:=1;
  R.Assign(40, 1, 41, 9);
  PBor:= New(Pscrollbar, Init(R));
  R.Assign(9, 1, 40, 9);
  Plist:=New(PListbox, Init(R,Col,PBor));
  Plist^.Newlist(Namelist);
  MyBox^.Insert(PBor);
  MyBox^.Insert(PList);
  Desktop^.insert(myBox);
End;

Procedure TMyApp.HandleEvent(var Event: TEvent);
Begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
    Begin
      case Event.Command of
        cmNewCollect: Begin
                        DisableCommands(DisableNewCollect);
                        Newcollect;
                      End
      else
        ClearEvent(Event);
        Exit;
      End;
      ClearEvent(Event);
    End;
End;

Procedure TMyApp.InitMenubar;
var
  R:Trect;
Begin
  GetExtent(R);
  R.B.Y := R.A.Y +1;
  MenuBar :=new(PMenubar, init(R, Newmenu(
  NewSubMenu('~L~istbox Menu',hcnocontext, Newmenu(
  NewItem('~B~ox','',kbF9,cmnewcollect,hcnocontext,
  NewLine(
  NewItem('~E~xit','',kbf10,cmquit,hcnocontext,
  Nil)))), Nil))));
End;

Begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
End.

