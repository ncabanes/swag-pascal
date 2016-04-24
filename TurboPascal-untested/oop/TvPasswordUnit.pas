(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0057.PAS
  Description: TV Password Unit
  Author: MARK VAN LEEUWEN
  Date: 02-28-95  10:04
*)

Unit Passwd;
{***************************************************************************
Written by Mark S. Van Leeuwen.
This Code is Public Domain.
Please Include my Name in any application that uses this code.
***************************************************************************}

Interface

Uses Objects,Dialogs,Views,Drivers;

Type
PPasswordLine=^TPasswordLine;
TPasswordLine=Object(TInputline)
Data1  :String;
Constructor Init(Var Bounds :TRect; AMaxLen :Integer);
Procedure GetData(Var Rec);Virtual;
Procedure SetData(Var Rec);Virtual;
Procedure HandleEvent(Var Event :TEvent);Virtual;
End;

Implementation

{**************** Constructor for the Password Inputline Data **************}
Constructor TPasswordLine.Init(Var Bounds :TRect; AMaxlen :Integer);
Begin
Data1:='';
TInputline.Init(Bounds,AMaxLen);
End;
{******************* Get Data from Procedure *******************************}
Procedure TPasswordLine.GetData(Var Rec);
Begin
String(Rec):=Data1;
End;
{****************** Set Data to Procedure **********************************}
Procedure TPasswordLine.SetData(Var Rec);
Begin
Data1:=String(Rec);
SelectAll(True);
End;
{******************** Handle Inputline Event *******************************}
Procedure TPasswordLine.HandleEvent(Var Event :TEvent);
Var
C :String[1];
Begin
  With Event Do
    If (What = evKeyDown) And (KeyCode = kbEsc) Then
    Begin
      What := Command;
      Command := cmClose;
    End;
   Case Event.What Of
    evKeyDown:
      Begin
         If(UpCase(Event.CharCode) In ['A'..'Z','0'..'9']) Then
           Begin
         C:=Event.CharCode;
         Data1:=Concat(Data1,C);
         Event.CharCode:='*';
         End;
        If(Event.KeyCode = kbBack) OR (Event.KeyCode = kbDel) Then
          Begin
          If(Integer(Data1[0]) <> 0)Then
            Begin
            Dec(Data1[0]);
            End;
          Event.KeyCode:=kbBack;
        End;
      End;
    evBroadcast:
      Begin
      End;
  End;
TInputLine.HandleEvent(Event);
End;
End.

{ -----------------   DEMO ---------------- }

Program TestPwd;

{***************************************************************************
Written by Mark S. Van Leeuwen.
This Code is Public Domain.
This is a Test Program that shows the use of the unit.
Please Include my Name in any application that uses this code.
***************************************************************************}

Uses Objects,App,Dialogs,Drivers,Passwd,Views,StdDlg,MsgBox,Menus;

Const
cmPassword = 1001;

Type
PTestApp=^TTestApp;
TTestApp=Object(TApplication)
Procedure HandleEvent(Var Event:TEvent);Virtual;
Procedure InitStatusLine;Virtual;

End;

Procedure TTestApp.HandleEvent(Var Event:TEvent);
Procedure Password;
Var
 D         : PDialog;
 Control   : Word;
 A         : PView;
 R         : TRect;
 S         : String;
 Begin
  R.Assign(0,0,30,08);
  D := New(PDialog, Init(R, 'Enter Password'));
  With D^ Do
  Begin
  Options := Options or ofCentered;

    R.Assign(02, 05, 12, 07);
    Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));

    R.Assign(15, 05, 25, 07);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

    R.Assign(02,03,28,04);
    Insert(New(PStaticText, Init(R,'Password is not Displayed.')));

    R.Assign(02,02,28,03);
    A:= New(PPasswordLine, Init(R,10));
    Insert(A);
    R.Assign(02,01,28,02);
    Insert(New(Plabel, Init(R,'Enter Password:',A)));

   End;
    Control:=Desktop^.ExecView(D);
    IF Control <> cmCancel THEN
      Begin
      A^.GetData(S);
      MessageBox(S,nil,mfInformation+mfOkButton);
    End;
    Dispose(D, Done);
 End;

Begin
 TApplication.HandleEvent(Event);
  case Event.What of
    evCommand:
      begin
        case Event.Command of
         cmPassword             : Password;
         else
          Exit;
        end;
        ClearEvent(Event);
      end;
  end;
end;
{***************************************************************************}
{**************** Application Status Line Procedure ************************}
{***************************************************************************}
 Procedure TTestApp.InitStatusLine;
 Var
 R :Trect;
 Begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F2~ Password', kbF2, cmPassword,
      NewStatusKey('~F10~ Menu', kbF10, cmMenu,
      NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,nil)))), nil)));
End;


Var
TMyApp  :TTestApp;

Begin
TMyapp.Init;
TMyapp.Run;
TMyapp.Done;
End.

