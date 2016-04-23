
ClipBoard Viewer
Erik Sperling Johansen <erik@info-pro.no>
Example source to implement a clipboard viewer follows.


--------------------------------------------------------------------------------

unit ClipboardViewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FNextViewerHandle : THandle;
    procedure WMDrawClipboard (var message : TMessage); 
   message WM_DRAWCLIPBOARD;
    procedure WMChangeCBCHain (var message : TMessage); 
  message WM_CHANGECBCHAIN;
  public
  end;

var
  Form1: TForm1;

implementation
{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Hook the clipboard viewer chain
  // Should also check for a possible null return value, which indicates
  // that the function failed.
  FNextViewerHandle := SetClipboardViewer(Handle);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // Remove ourselves from the clipboard viewer chain.
  ChangeClipboardChain(Handle, FNextViewerHandle);
end;

procedure TForm1.WMDrawClipboard (var message : TMessage);
begin
// Called whenever contents of the clipboard changes
  message.Result := SendMessage(WM_DRAWCLIPBOARD, FNextViewerHandle, 0, 0);
end;

procedure TForm1.WMChangeCBCHain (var message : TMessage);
begin
  // Called when there is a change in the Clipboard viewer chain.
  if message.wParam = FNextViewerHandle then begin
    // the next viewer in the chain is being removed. Update our internal var.
    FNextViewerHandle := message.lParam;
    // Return 0 to indicate message was processed
    message.Result := 0;
  end else begin
    // Pass message on to next window in chain.
    message.Result := SendMessage(FNextViewerHandle, WM_CHANGECBCHAIN,
message.wParam, message.lParam);
  end;
end;


end.
