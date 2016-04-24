(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0159.PAS
  Description: Click and drag in a TListbox?
  Author: RICHARD HOWARD
  Date: 08-30-96  09:35
*)


{coolbox.pas}
{A note from the author:
   I needed to do some spiffy things with the listboxes so I wrote this.  If it already exists, then great, but I couldn't find it.  With this small program, you can multi-select items from ListBox1 and drag them to ListBox2. No big deal, except that you
   The really cool thing here is that you can select an item in ListBox2 and move it into a another spot within the list by using the arrows or by dragging and dropping.  Again, I couldn't find any code that already did this.  I hope you find this code us

Richard Howard 71553,2544
Mei Technology Corporation
26 August 1995}

unit CoolBox;
interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Spin;
type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    SpinButton1: TSpinButton; {for moving items in listbox2.}
    procedure ListBox2DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListBox2DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListBox2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure MoveUp(Sender: TObject);
    procedure MoveDown(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  MoveSelectedItem : Integer; {the item in ListBox2 being moved}
  DnListBox1 : Boolean; {indicates which listbox to work with}
  DnListBox2 : Boolean; {indicates which listbox to work with}
implementation
{$R *.DFM}
procedure TForm1.ListBox2DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if (Source is TListBox) then Accept := True;
  {because this is such a small program, 'ACCEPT := True' would work.  But
  larger programs need a little more control.}
end;
procedure TForm1.ListBox2DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i : Integer; {serves two purposes: 1) a counting variable for ListBox1,
               and 2) the item that the SELECTED item is being dropped on to
               in ListBox 2}
begin {procedure}
  {instructions for moving items from ListBox1 to ListBox2}
  if DnListBox1 then
  begin {if 1}
    for i := 0 to ListBox1.Items.Count - 1 do {look at ALL items in ListBox1}
    begin {for}
      if ListBox1.Selected[i] then
        ListBox2.Items.Insert(ListBox2.ItemAtPos(Point(X,Y), True), ListBox1.Items[i]);
        ListBox1.Selected[i] := False; {after copying to LB2, UNselect it}
    end; {for}
   DnListBox1 := False;
  end; {if 1}
  {instructions for moving an item WITHIN ListBox2}
  if DnListBox2 then
  begin {if 2}
    {i = the item UNDER the moving, selected item}
    i := ListBox2.ItemAtPos(Point(X, Y), True);
    ListBox2.Items.Move(MoveSelectedItem, i); {puts the moved item into place}
    ListBox2.ItemIndex := i; {select (highlight) the item you moved}
    if i = -1 then ListBox2.ItemIndex := ListBox2.Items.Count-1;
    DnListBox2 := False;
  end; {if 2}
end; {procedure}
procedure TForm1.ListBox2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin {procedure}
  DnListBox1 := False;{tells the OnDragDrop procedure which instructions to use}
  DnListBox2 := True;{tells the OnDragDrop procedure which instructions to use}
  if Button = mbLeft then
    if ListBox2.ItemAtPos(Point(X, Y), True) >= 0 then
      MoveSelectedItem := ListBox2.ItemIndex;
end; {procedure}
procedure TForm1.ListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  DnListBox1 := True;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  {I just threw these in here to look nice.  They can be pretty handy.}
  SendMessage(ListBox1.Handle, LB_SetHorizontalExtent, 1000, LongInt(0));
  SendMessage(ListBox2.Handle, LB_SetHorizontalExtent, 1000, LongInt(0));
end;
procedure TForm1.MoveUp(Sender: TObject);
var
  i : Integer;
begin {procedure}
  if ListBox2.ItemIndex > 0 then
  begin {if}
    i := ListBox2.ItemIndex;
    ListBox2.Items.Move(i, i-1);
    ListBox2.ItemIndex := i-1;
  end; {if}
end; {procedure}
procedure TForm1.MoveDown(Sender: TObject);
var
  i : Integer;
begin {procedure}
  if (ListBox2.ItemIndex < ListBox2.Items.Count-1) and
     (ListBox2.ItemIndex <> -1) then
  begin {if}
    i := ListBox2.ItemIndex;
    ListBox2.Items.Move(i, i+1);
    ListBox2.ItemIndex := i+1;
  end; {if}
end; {procedure}
end.
{*********************}
{coolproj.dpr}
program Coolproj;
uses
  Forms,
  Coolbox in 'COOLBOX.PAS' {Form1};
{$R *.RES}
begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
{*********************}
{Coolbox.dfm}
object Form1: TForm1
  Left = 245
  Top = 163
  Width = 349
  Height = 253
  Caption = 'Form1'
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = []
  PixelsPerInch = 96
  OnCreate = FormCreate
  TextHeight = 16
  object ListBox1: TListBox
    Left = 16
    Top = 24
    Width = 129
    Height = 177
    DragMode = dmAutomatic
    ItemHeight = 16
    Items.Strings = (
      'List 1'
      'List 2'
      'List 3'
      'List 4'
      'List 5'
      'List 6')
    MultiSelect = True
    TabOrder = 0
    OnDragOver = ListBox1DragOver
  end
  object ListBox2: TListBox
    Left = 168
    Top = 24
    Width = 129
    Height = 177
    DragMode = dmAutomatic
    ItemHeight = 16
    Items.Strings = (
      'Test 1'
      'Test 2'
      'Test 3'
      'Test 4')
    TabOrder = 1
    OnDragDrop = ListBox2DragDrop
    OnDragOver = ListBox2DragOver
    OnMouseDown = ListBox2MouseDown
  end
  object SpinButton1: TSpinButton
    Left = 308
    Top = 76
    Width = 20
    Height = 53
    DownGlyph.Data = {
      7E040000424D7E04000000000000360400002800000009000000060000000100
      0800000000004800000000000000000000000000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C00061898D00A5BF
      C200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D2E0E100A4A0A000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
      0303030000000303030300030303030000000303030000000303030000000303
      0000000000030300000003000000000000000300000003030303030303030300
      0000}
    TabOrder = 2
    UpGlyph.Data = {
      7E040000424D7E04000000000000360400002800000009000000060000000100
      0800000000004800000000000000000000000000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C00061898D00A5BF
      C200000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000D2E0E100A4A0A000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
      0303030000000300000000000000030000000303000000000003030000000303
      0300000003030300000003030303000303030300000003030303030303030300
      0000}
    OnDownClick = MoveDown
    OnUpClick = MoveUp
  end
end

