{
 Designer:  Craig Ward (100554,2072)
 Date:      20/7/95

 Function:  Example of dealing with Windows Messages

***************************************************}
unit Winmess;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    {This is the procedure declaration for dealing with the Window's message to
     close the app's window - note that we would expect message handler's to be
     declared privately (why would we ever want an external unit to access another unit's
     message handlers!!!!)}
    procedure custWMSYS(var Message: TWMSYSCOMMAND); Message WM_CLOSE;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

{******************************************************************************}
implementation

{$R *.DFM}

{procedure that deals with the windows WM_CLOSE message -

 I'm sure that there are far easier ways of dealing with posting records, but
 this way illustrates some of the concepts behind Windows. Of course, in response
 to "mrYes" we could simply use "close;" but I've included a PostMessage method
 that provides an example of how to send messages to Windows.

 Note that this subroutine could be useful for database applications, where the
 a record has not yet been posted and the user tries to close down the form}
procedure TForm1.custWMSYS(var Message: TWMSYSCOMMAND);
var
 sTitle: string;
 pTitle: PChar;
 iTitle: integer;
begin
 {find title of the Form}
 sTitle := Form1.Caption;
  {now set case statement for user's response to dialog box}
  case messageDlg('Save changes?', mtWarning, [mbYes, mbNo, mbCancel], 0) of
    mrYes:
     begin
        {*********************************}
          {allocate room on buffer for pchar}
          pTitle := StrAlloc(256);
          {convert string to pchar}
          StrPCopy(pTitle, sTitle);
          {find window's handle}
          iTitle := FindWindow(nil, pTitle);
        {*********************************}
       {post message to Windows to close down the window}
       PostMessage(iTitle, WM_QUIT, 0, 0);
     end;
   mrNo:
      close;
   mrCancel:
      {do nothing}
  end;
end;

end.
