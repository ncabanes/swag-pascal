(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0211.PAS
  Description: Adding fields at run-time
  Author: R.F.P. VAN RIET
  Date: 03-04-97  13:18
*)


unit Unit1;
{ This program allows fields to be added on the fly.
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, DBTables, Grids, DBGrids, StdCtrls;

type
  TForm1 = class(TForm)
    Table1: TTable;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.Button1Click(Sender: TObject);
begin
     Memo1.Clear;
     if StrComp(PChar(Edit1.Text), PChar(''))= 0 then
     begin
          Memo1.Lines.Add('Invalid field name');
          Exit;
     end
     else begin
               with table1 do
               begin
                    Close;    // table must be closed !!!
                    with FieldDefs do
                    begin
                         try
                            Add(Edit1.Text, ftInteger, 0, False);
                         Except On EDatabaseError do
                                begin
                                     Memo1.Lines.Add('Error adding field ' +
Edit1.Text + ' to table.');
                                     Memo1.Lines.Add('Maybe ''' + Edit1.Text
+ ''' already exists as a field name');
                                end;
                         end;
                         CreateTable;
                         Open;
                    end;
               end;
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Table1.Open;
end;

end.
Ronan van Riet

Graaf Florishof 4
3632 BS Loenen a/d Vecht
The Netherlands
0294-233563

vanriet@worldaccess.nl (private)
4921781@ibk.fnt.hvu.nl (Utrecht Polytechnic, the Netherlands)


