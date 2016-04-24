(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0156.PAS
  Description: Re: OLE Automation with EXCEL
  Author: STEVE GINN
  Date: 08-30-96  09:35
*)


{
>I am interested in any info regarding the use of OLE Automation
>in Delphi 2.0 . The demo programs provided with Delphi help
>at first, but I seem to have come upon major stumbling blocks,
>and the online help is skimpy on the subject. Specifically, I want
>to communicate with Microsoft Excel. Executing the following
>code:
>

I don't remember where I got this but it seems to work for me in my exercises of learning OLE Auto
with Excel:
}

unit Excel1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, OleAuto,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    bFancyAry: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure bFancyAryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
var
   V: Variant;

procedure TForm1.Button1Click(Sender: TObject);
begin
   V := CreateOleObject('Excel.Sheet');
   V.Range('A1:D8').Formula := 'RAND()';
   V.Application.Sheets.Add;
   Caption := 'Num Sheets = ' + IntToStr(V.Application.Sheets.Count);
   ShowMessage('Excel Sheet Created');
end;

var
   A: Variant;
procedure TForm1.Button2Click(Sender: TObject);
begin
     A := CreateOleObject('Excel.Application'); //Start a new copy of Excel
     A.Visible := True;
     A.WorkBooks.Add;
     A.Sheets.Add;
     Caption := 'Num Sheets = ' + IntToStr(A.Sheets.Count);
end;

procedure TForm1.bFancyAryClick(Sender: TObject);
var
   i, j: Integer;
   Ch: Char;
   SimpAry: Variant;
begin
     SimpAry := CreateOleObject('Excel.Application'); //Start a new copy Excel
     SimpAry.Visible := True;
     SimpAry.WorkBooks.Add;
     SimpAry.Sheets.Add;
     for i := 1 to 10 do
         for j := 1 to 10 do
             SimpAry.Cells[j, i].Value := i * j;
     for i := 1 to 10 do begin
         Ch := Chr(64 + i);
         SimpAry.Cells[11, i].Value := Format('=Sum(%s1:%s10)', [Ch, Ch]);
end;
end;
end.

