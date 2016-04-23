
The ability to place graphics inside ListBoxes and ComboBoxes 
can improve the look of your application and set your user 
interface apart from the others. 

Q: How do I stick graphics in a Listbox or ComboBox???

Here is an step-by-step example.....

1.  Create a form.

2.  Place a ComboBox and Listbox component on your form.

3.  Change the Style property of the ComboBox component to 
csOwnerDrawVariable and the Style property of the ListBox to 

lbOwnerDrawVariable.

An Owner-Draw TListBox or TComboBox allows you to display 
both objects (ex. graphics) and strings as the items.  For 
this example, we are adding both a graphic object and a 
string.

4.  Create 5 variables of type TBitmap in the Form's VAR 
section.

5.  Create a Procedure for the Form's OnCreate event.

6.  Create a Procedure for the ComboBox's OnDraw Event.

7.  Create a Procedure for the ComboBox's OnMeasureItem.

8. Free the resources in the Form's OnClose Event.



{START OWNERDRW.PAS}
unit Ownerdrw;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);

    procedure ComboBox1MeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TheBitmap1, TheBitmap2, TheBitmap3, TheBitmap4,

  TheBitmap5 : TBitmap;
implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  TheBitmap1 := TBitmap.Create;
  TheBitmap1.LoadFromFile('C:\delphi\images\buttons\globe.bmp');
  TheBitmap2 := TBitmap.Create;
  TheBitmap2.LoadFromFile('C:\delphi\images\buttons\video.bmp');
  TheBitmap3 := TBitmap.Create;
  TheBitmap3.LoadFromFile('C:\delphi\images\buttons\gears.bmp');
  TheBitmap4 := TBitmap.Create;
  TheBitmap4.LoadFromFile('C:\delphi\images\buttons\key.bmp');

  TheBitmap5 := TBitmap.Create;
  TheBitmap5.LoadFromFile('C:\delphi\images\buttons\tools.bmp');
  ComboBox1.Items.AddObject('Bitmap1: Globe', TheBitmap1);
  ComboBox1.Items.AddObject('Bitmap2: Video', TheBitmap2);
  ComboBox1.Items.AddObject('Bitmap3: Gears', TheBitmap3);
  ComboBox1.Items.AddObject('Bitmap4: Key', TheBitmap4);
  ComboBox1.Items.AddObject('Bitmap5: Tools', TheBitmap5);
  ListBox1.Items.AddObject('Bitmap1: Globe', TheBitmap1);
  ListBox1.Items.AddObject('Bitmap2: Video', TheBitmap2);

  ListBox1.Items.AddObject('Bitmap3: Gears', TheBitmap3);
  ListBox1.Items.AddObject('Bitmap4: Key', TheBitmap4);
  ListBox1.Items.AddObject('Bitmap5: Tools', TheBitmap5);

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TheBitmap1.Free;
  TheBitmap2.Free;
  TheBitmap3.Free;
  TheBitmap4.Free;
  TheBitmap5.Free;
end;

procedure TForm1.ComboBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);

var
  Bitmap: TBitmap;
  Offset: Integer;
begin
  with (Control as TComboBox).Canvas do
  begin
    FillRect(Rect);
    Bitmap := TBitmap(ComboBox1.Items.Objects[Index]);
    if Bitmap <> nil then
    begin
      BrushCopy(Bounds(Rect.Left + 2, Rect.Top + 2, Bitmap.Width,
                Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
                Bitmap.Height), clRed);
      Offset := Bitmap.width + 8;
    end;
    { display the text }
    TextOut(Rect.Left + Offset, Rect.Top, Combobox1.Items[Index])

  end;
end;

procedure TForm1.ComboBox1MeasureItem(Control: TWinControl; Index:
                                      Integer; var Height: Integer);
begin
  height:= 20;
end;

procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Bitmap: TBitmap;
  Offset: Integer;
begin
  with (Control as TListBox).Canvas do
  begin
    FillRect(Rect);
    Bitmap := TBitmap(ListBox1.Items.Objects[Index]);
    if Bitmap <> nil then

    begin
      BrushCopy(Bounds(Rect.Left + 2, Rect.Top + 2, Bitmap.Width,
                Bitmap.Height), Bitmap, Bounds(0, 0, Bitmap.Width,
                Bitmap.Height), clRed);
      Offset := Bitmap.width + 8;
    end;
    { display the text }
    TextOut(Rect.Left + Offset, Rect.Top, Listbox1.Items[Index])
  end;
end;

procedure TForm1.ListBox1MeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  height:= 20;
end;

end.

{END OWNERDRW.PAS}

{START OWNERDRW.DFM}
object Form1: TForm1
  Left = 211
  Top = 155
  Width = 435
  Height = 300
  Caption = 'Form1'
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  PixelsPerInch = 96
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 16
  object ComboBox1: TComboBox
    Left = 26
    Top = 30
    Width = 165
    Height = 22
    Style = csOwnerDrawVariable
    ItemHeight = 16
    TabOrder = 0

    OnDrawItem = ComboBox1DrawItem
    OnMeasureItem = ComboBox1MeasureItem
  end
  object ListBox1: TListBox
    Left = 216
    Top = 28
    Width = 151
    Height = 167
    ItemHeight = 16
    Style = lbOwnerDrawVariable
    TabOrder = 1
    OnDrawItem = ListBox1DrawItem
    OnMeasureItem = ListBox1MeasureItem
  end
end
{END OWNERDRW.DFM}


