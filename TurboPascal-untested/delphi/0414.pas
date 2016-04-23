
Performing an action when Windows shuts down a Delphi app
From: wesjones@hooked.net (Wes Jones)

I did a little investigation, and here is what seems to be happening:

Normally, when you exit a Delphi application by using the system menu or by calling the Form's Close method, the following event handlers are called:

FormCloseQuery - the default action sets the variable CanClose=TRUE so form close will continue. 
FormClose 
FormDestroy 
If the application is active and you attempt to exit Windows, the event handlers are called in the following sequence:

FormCloseQuery 
FormDestroy 
The FormClose method never seems to be called.

Here is the flow of events when the user chooses to end the Windows session:

Windows sends out a WM_QUERYENDSESSION message to all application windows one by one and awaits a response 
Each application window receives the message and returns a non-zero value if it is OK to terminate, or 0 if it is not OK to terminate. 
If any application returns 0, the Windows session is not ended, otherwise, Windows sends a WM_ENDSESSION message to all application windows 
Each Application Window responds with a TRUE value indicating that Windows can terminate any time after all applications have returned from processing this message. This appears to be the location of the Delphi problem: Delphi applications seem to return TRUE and the FormDestroy method is called immediately, bypassing the FormClose method. 
Windows exits 
One solution is to respond to the WM_QUERYENDSESSION message in the Delphi application and prevent Windows from exiting by returning a 0 result. This can't be done in the FormCloseQuery method because there is no way to determine the source of the request (it can either be the result of the WM_QUERYENDSESSION message or the user just simply closing the application). 

Another solution is to respond to the WM_QUERYENDSESSION message by calling the same cleanup procedure you call in the FormClose method.

Example:


--------------------------------------------------------------------------------

unit Unit1;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls, Forms,
Dialogs;
type
  TForm1 = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  {---------------------------------------------------------------}
  { Custom procedure to respond to the WM_QUERYENDSESSION message }
  {---------------------------------------------------------------}
  procedure WMQueryEndSession(
             var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
  public
    { Public declarations }
  end;
var
  Form1    : TForm1;

implementation
{$R *.DFM}

{---------------------------------------------------------------}
{ Custom procedure to respond to the WM_QUERYENDSESSION message }
{ The application will only receive this message in the event   }
{ that Windows is requesing to exit.                            }
{---------------------------------------------------------------}
procedure TForm1.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  inherited;         { let the inherited message handler respond first }
  {--------------------------------------------------------------------}
  { at this point, you can either prevent windows from closing...      }
  { Message.Result:=0;                                                 }
  {---------------------------or---------------------------------------}
  { just call the same cleanup procedure that you call in FormClose... }
  { MyCleanUpProcedure;                                                }
  {--------------------------------------------------------------------}
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MyCleanUpProcedure;
end;

end.
