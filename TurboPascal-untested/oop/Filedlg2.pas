(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0005.PAS
  Description: FILEDLG2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
>Really like to see is a Real world example.  In particular a
>collection of Filenames in the current directory sorted and  the
>ability to scroll these Strings vertically.  I don't want to go

I don't know if this will help that much, but it does what you requested
<g>...  This Compiled in Real mode under BP7 and ran without problems. Although
untested in TP6, it should run fine.
}
Program Example;

Uses
  App,
  Dialogs,
  Drivers,
  Menus,
  MsgBox,
  Objects,
  StdDlg,
  Views;

Const
  cmAbout       = 101;

Type
  TExampleApp = Object(TApplication)
    Procedure CM_About;
    Procedure CM_Open;
    Procedure HandleEvent(Var Event: TEvent); Virtual;
    Constructor Init;
    Procedure InitStatusLine; Virtual;
  end;

Procedure TExampleApp.CM_About;
begin
  MessageBox(
    ^C'Example O-O Program' + #13 + #13 +
    ^C'by Bill Himmelstoss (1:112/57)', nil, mfInFormation + mfOkButton
  );
end;

Procedure TExampleApp.CM_Open;
Var
  FileDialog: PFileDialog;
  Filename: FNameStr;
  Result: Word;
begin
  FileDialog := New(PFileDialog, Init('*.*', 'Open a File', '~N~ame',
    fdOpenButton, 100));
  {$ifDEF VER70}
  Result := ExecuteDialog(FileDialog, @Filename);
  {$endif}
  {$ifDEF VER60}
  Result := cmCancel;
  if ValidView(FileDialog) <> nil then
    Result := Desktop^.ExecView(FileDialog);
  if Result <> cmCancel then
    FileDialog^.GetFilename(Filename);
  Dispose(FileDialog, Done);
  {$endif}
  if Result <> cmCancel then
    MessageBox(^C'You chose '+Filename+'.', nil, mfInFormation + mfOkButton);
end;

Procedure TExampleApp.HandleEvent(Var Event: TEvent); begin
  {$ifDEF VER60}
  TApplication.HandleEvent(Event);
  {$endif}
  {$ifDEF VER70}
  inherited HandleEvent(Event);
  {$endif}

  Case Event.What of
    evCommand:
    begin
      Case Event.Command of
        cmAbout: CM_About;
        cmOpen: CM_Open;
      else
        Exit;
      end;
      ClearEvent(Event);
    end;
  end;
end;

Constructor TExampleApp.Init;
Var
  Event: TEvent;
begin
  {$ifDEF VER60}
  TApplication.Init;
  {$endif}
  {$ifDEF VER70}
  inherited Init;
  {$endif}

  ClearEvent(Event);
  Event.What := evCommand;
  Event.Command := cmAbout;
  PutEvent(Event);
end;

Procedure TExampleApp.InitStatusLine;
Var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef($0000, $FFFF,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit,
    nil)),
  nil)));
end;

Var
  ExampleApp: TExampleApp;

begin
  ExampleApp.Init;
  ExampleApp.Run;
  ExampleApp.Done;
end.

