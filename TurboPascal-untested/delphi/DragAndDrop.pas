(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0289.PAS
  Description: Drag And Drop
  Author: GAVIN CARTER
  Date: 05-30-97  18:17
*)

{
If anyone is still intrested I think I've got simple code that works fine.
Just put a list box on the form, and then drag to the box, it will the add
the path of the file to the listbox. }

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs,
  StdCtrls, shellapi;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;

   procedure FormCreate(Sender: TObject);
  private

procedure WMDROPFILES(var Message: TWMDROPFILES); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.WMDROPFILES(var Message: TWMDROPFILES);
const
   cnmaxfilenamelen = 255;
var
   i,ncount : integer;
   acfilename : array [0..255] of char;

begin

     ncount := dragqueryfile (message.drop, $FFFFFFFF,acfilename,cnmaxfilenamelen);
     for i := 0 to ncount -1 do
     begin
     dragqueryfile (message.drop,i,acfilename,cnmaxfilenamelen);
     listbox1.items.add(acfilename);
     end;

     dragfinish(message.drop);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
DragAcceptFiles( Handle, True );

end;

end.

