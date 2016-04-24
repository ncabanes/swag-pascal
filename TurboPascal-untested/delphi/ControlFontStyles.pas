(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0003.PAS
  Description: Control Font Styles
  Author: SWAG SUPPORT GROUP
  Date: 11-22-95  13:25
*)


Control Font Styles:

This code will change the font style of a Edit
when selected. This code could be implemented to
control font style on other objects.

With a Edit(Edit1) and a ListBox(ListBox1) on a form
Add the following Items to the ListBox:
   fsBold
   fsItalic
   fsUnderLine
   fsStrikeOut

procedure TForm1.ListBox1Click(Sender: TObject);
var
  X : Integer;
type
  TLookUpRec = record
    Name: String;
    Data: TFontStyle;
  end;
const
  LookUpTable: array[1..4] of TLookUpRec =

  ((Name: 'fsBold'; Data: fsBold),
   (Name: 'fsItalic'; Data: fsItalic),
   (Name: 'fsUnderline'; Data: fsUnderline),
   (Name: 'fsStrikeOut'; Data: fsStrikeOut));
begin
  X := ListBox1.ItemIndex;
  Edit1.Text := ListBox1.Items[X];
  Edit1.Font.Style := [LookUpTable[ListBox1.ItemIndex+1].Data];
end;


