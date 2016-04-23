{
The following example is to demonstrate the use of a Pick List.
This Pick List will read a line of data and validate the field
as well as keep a history of valid commands.
}
{$X+}
Program PickListExample;

uses Objects, App, Menus, Drivers, Views, Dialogs, MsgBox;

type
  YourKeySet = set of char;

const
   cmMakeDialog = 101;
   ValidSet  : YourKeySet = [#0..#31,'0'..'9'];

type

  PFInputLine = ^TFInputLine;
  TFInputLine = object(TInputLine)
    ValidKeys : YourKeySet;
    constructor Init(var Bounds: TRect; AMaxLen: integer;
                     ChrSet: YourKeySet);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
    function DataSize: word; virtual;
  end;

PMyApp = ^TMyApp;
TMyApp = object(TApplication)
  procedure InitMenuBar;virtual;
  procedure InitStatusLine;virtual;
  procedure MakeDialog;
  procedure HandleEvent(var Event: TEvent);virtual;
 end;

constructor TFInputLine.Init(var Bounds: TRect; AMaxLen: integer;
                             ChrSet: YourKeySet);
begin
  TInputLine.Init(Bounds,AMaxLen);
  ValidKeys:= ChrSet;
end;

procedure TFInputLine.HandleEvent(var Event: TEvent);
var
  Number : longint;
  Code : integer;
begin
  case Event.What of
    evKeyDown :
      begin
        if not(Event.CharCode in ValidKeys) then
          ClearEvent(Event)
         else
           if Data^ <> '' then
             begin
               val(Data^, Number, Code);
               if (Code <> 0) or (Number < 0) or (Number > 65535) then
                 begin
                   Data^ := '';
                   MessageBox('Valid number is 0 to 65536.',nil,mfOkButton);
                   ClearEvent(Event);
                 end;
             end;
      end;
  end;
  TInputLine.HandleEvent(Event);
end;

procedure TFInputLine.GetData(var Rec);
var
  Code : integer;
begin
  Val(Data^,word(Rec), Code);
end;

procedure TFInputLine.SetData(var Rec);
begin
  Str(word(Rec),Data^);
end;

function TFInputLine.DataSize: word;
begin
  DataSize := SizeOf(word);
end;

procedure TMyApp.InitMenuBar;
  var R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~T~est', hcNoContext, NewMenu(
      NewItem('~D~ialog','F2',kbF2,cmMakeDialog,hcNoContext,
      NewLine(
      NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
      nil)))),nil))));
end;

procedure TMyApp.MakeDialog;
var
 R : TRect;
 Dialog : PDialog;
 D : word;
 InputLine : PInputLine;
 Lable,Hist : PView;
begin
 GetExtent(R);
 R.Assign(10,5,60,15);
 Dialog := New(PDialog,Init(R,'Demo Dialog'));
 With Dialog^ do
   begin
     R.Assign(5,4,20,5);
     InputLine := New(PFInputLine,Init(R,15,ValidSet));
     Insert(InputLine);
     R.Assign(5,3,20,4);
     Lable := New(PLabel,Init(R,'InputLine',Inputline));
     Insert(Lable);
     R.Assign(21,4,23,5);
     Hist := New(PHistory,Init(R,InputLine,0));
     Insert(Hist);
   end;
 D := Desktop^.ExecView(Dialog);
 Dispose(Dialog,Done);
end;

procedure TMyApp.InitStatusLine;
var
 R : TRect;
begin
 GetExtent(R);
 R.A.Y := R.B.Y - 1;
 StatusLine :=  New(PStatusLine,Init(R,
                  NewStatusDef(0,$FFFF,
                    NewStatusKey('~A~lt-X',kbAltX,cmQuit,
                nil),nil)));
end;

procedure TMyApp.HandleEvent(var Event: TEvent);
begin
  TApplication.HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmMakeDialog: MakeDialog;
    else
      Exit;
    end;
    ClearEvent(Event);
  end;
end;

var
 MyApp: TMyApp;

begin
 MyApp.Init;
 MyApp.Run;
 MyApp.Done;
end.
