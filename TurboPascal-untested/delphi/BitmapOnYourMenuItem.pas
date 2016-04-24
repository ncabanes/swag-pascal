(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0291.PAS
  Description: Bitmap on your menu item
  Author: CHAMI
  Date: 05-30-97  18:23
*)


Is that a bitmap I see on your menu item?
--------------------------------------------------------------------------------
Have you been envious of the Windows 95 Start Menu, because of the way it's able to display bitmaps on its menu items? Well, it's not too hard to add small bitmaps to your menu items by using the following function:
procedure AddBitmapToMenuItem(
  PopupMenu : TPopupMenu;
  nItemPos  : integer;
  Bitmap    : TBitmap );
begin
  SetMenuItemBitmaps(
    PopupMenu.Handle,
    nItemPos,
    MF_BYPOSITION,
    Bitmap.Handle,
    Bitmap.Handle );
end;


The Windows API function "SetMenuItemBitmaps()" is mostly used to set bitmaps for "checkable" menu items -- menu items with two bitmaps for checked and unchecked states. To keep the "AddBitmapToMenuItem()" function simple, we're not changing menu item's size according to the size of the bitmap. This means, you can only pass bitmaps that are small enough to fit in the default size of your menu items.
To keep the bitmaps for your menu items built into your application:

(a) Drop a "TImage" component on your form.
(b) Assign a bitmap of your choice to the "Picture" property of the newly created "TImage" component.
(c) Call "AddBitmapToMenuItem()" function as follows from your "FormCreate()" event (assuming that the pop-up menu that you're assigning the bitmap to is named "PopupMenu1," the image component you're using is named "Image1," and the position of the actual menu item you want to set the bitmap on is 0 -- 1st item = 0, 2nd item = 1, 3rd item = 2, etc.):


AddBitmapToMenuItem( 
  PopupMenu1, 
  0, 
  Image1.Picture.Bitmap );


To load the menu item bitmaps at the run-time:

procedure TForm1.
  FormCreate(Sender: TObject);
var
  BMP : TBitmap;
begin
  BMP := TBitmap.Create;
  BMP.LoadFromFile(
    'MyBitmap.BMP' );
  AddBitmapToMenuItem(
    PopupMenu1, 0, BMP );
end;



