(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0423.PAS
  Description: Delayed scrolling / delayed OnChange?
  Author: ERIK SPERLING JOHANSEN
  Date: 01-02-98  07:34
*)

Erik Sperling Johansen >erik@info-pro.no> Stefan Hoffmeister wrote:
If the user keeps either key pressed and the change of the item
(ComboBox.OnChange) takes a long(ish) time an annoying delay will be
noticed.

As a "work around" I would like to react to the change of the
ItemIndex only after a short period of time, e.g. 100 ms.
Here's an example. Written in D2, but technique should work OK in D1 too. Just a simple form with a combo and a label. You probably should consider using Yield in addition to the call to Application.ProcessMessages, to avoid slowing down the PC when the forms message queue is empty. 


--------------------------------------------------------------------------------

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs,
  StdCtrls;


const
  // Just some message constant
  PM_COMBOCHANGE = WM_USER + 8001;

  // 500 ms
  CWantedDelay = 500;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    procedure ComboBox1Change(Sender: TObject);
  private
    procedure PMComboChange(var message : TMessage); message PM_COMBOCHANGE;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  PostMessage(Handle, PM_COMBOCHANGE, 0, 0);
end;

procedure TForm1.PMComboChange(var message : TMessage);
const
  InProc    : BOOLEAN = FALSE;
  StartTick : LONGINT = 0;
begin
  if InProc then begin
    // Update the starting time for the delay
    StartTick := GetTickCount;

  end else begin
    // We're in the loop
    InProc := TRUE;

    // Initial starting time
    StartTick := GetTickCount;

    // Wait until wanted time has elapsed.
    // If proc gets called again, starting time will change
    while GetTickCount - StartTick < CWantedDelay do Application.ProcessMessages;

    // Increment a counter, just for illustration of when to do the actual OnChange work
    Label1.Caption := IntToStr ( StrToIntDef ( Label1.Caption, 0 ) + 1);

    // We're finished with the loop
    InProc := FALSE;
  end;
end;

end.

