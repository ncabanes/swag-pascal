
{ method #1 }

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Edit1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function ComboBox_Item_Exists(ComboBox: tComboBox; str: string): Integer;
var i: Integer;
begin
         if ComboBox.Items.Count = 0 then
         // ComboBox is empty
         begin
              Result := -1;  // not found
              Exit;
         end else
                  for i := 0 to ComboBox.Items.Count -1 do
                  begin
                       if ComboBox.Items[i] = str then
                       begin
                            Result := i; // eureka
                            // str at pos i in ComboBox
                            Exit; // look no further
                       end
                       else Result := -1; // not found
                  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
     ComboBox1.ItemIndex := ComboBox_Item_Exists(ComboBox1, Edit1.Text);
end;

end.

What do you think about this replace ?

function ComboBox_Item_Exists(ComboBox: tComboBox; str: string): Integer;
begin
   Result := ComboBox.Items.IndexOf( Str );
end;

