{
In a previous mailed with the subject "[Delphi] Serios bug when closing
windows???" bimmer@ibm.net(Per Bakkendorff) writes:
>When you have a delphi application running, and you are shutting down windows,
>(don't close your app first), NONE of your destructors are called!!!!

At first I thought the problem was programmer's code, but then I realized
that it really is a bug or at least a very lazy "feature".

The problem seems to be that when you close down Windows, it will first
send a WM_QueryEndSession message to all running top-level windows. This
is handled and processed correctly by the TForm object in VCL.

Then assuming that all applications indicated that it was ok to close down,
Windows will send WM_EndSession messages to all windows. This message is
not handled by VCL. The application is simply brought down with a bang.
No windows are closed, no destructor called and no exit procedures called.

The solution is to handle the WM_EndSession message yourself. There are
several ways of handling messages in Delphi, but the only reliable way
of handling the WM_ENDSESSION is to use the HookWindow method of
Application.

In the message handler, check to see if the message is a WM_ENDSESSION.
If so, we should close down the application. We could have called the
Close method of the main window, but the Windows API documentation states
that the system might go down anytime after return from the WM_ENDSESSION,
and a posted WM_QUIT message might never arrive to the application.

The solution is to simply call Halt instead. This will call all registred
exit procedures, including the ones in Controls and DB units. These will
free the application and screen objects and take the BDE down correctly.

A simple example follows:
}

unit Tst2u;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DBGrids, DB, DBTables;

type
  TForm1 = class(TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBGrid1: TDBGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function HookProc(var Message: TMessage): boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  FlagFileName = 'C:\Flag.Fil';

procedure CreateFlagFile;
var
  F: System.Text;
begin
  System.Assign(F, FlagFileName);
  System.Rewrite(F);
  Writeln(F, 'This is a dummy flag file');
  System.Close(F);
end;

procedure KillFlagFile;
var
  F: File;
begin
  System.Assign(F, FlagFileName);
  System.Erase(F);
end;

procedure MyExitProc; far;
begin
  KillFlagFile;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.HookMainWindow(HookProc);
end;

function TForm1.HookProc(var Message: TMessage): boolean;
begin
  Result := false;
  if Message.Msg = WM_EndSession then
  begin
    if WordBool(Message.wParam) then
    begin
      { Windows is closing down - clean up!! }

      { This should execute all ExitProcs, close windows and call destructors... }
       Halt; { This works! }

      { This should close things down properly,
        but do we have enough time to handle any posted messages before Windows
        is already down??  This will result in a PostQuitMessage that might
        never arrive!}
{      Close;} { This doesn't always work - avoid it }
    end;
  end;
end;

initialization
  CreateFlagFile;
  AddExitProc(MyExitProc);
end.

This unit demonstrates that the exit procedures are called when closing
the app normally and when closing down Windows and using HookMainWindow.
Without the HookMainWindow call, the exit proc will not be called. This
is specially important for DB applications. Without the Halt, LCK files
will not be deleted, buffers might not be flushed, changes posted and
so on.
