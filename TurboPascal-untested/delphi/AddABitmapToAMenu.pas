(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0036.PAS
  Description: Add a Bitmap to a Menu
  Author: KURT CLAEYS
  Date: 11-22-95  15:49
*)


Maybe like this :

var
   Bmp1 : TPicture;

...

Bmp1 := TPicture.Create;
Bmp1.LoadFromFile('c:\where\b1.BMP');
SetMenuItemBitmaps(	MenuItemTest.Handle,
			0,
			MF_BYPOSITION,
			Bmp1.Bitmap.Handle,
			Bmp1.Bitmap.Handle);
...

Create a Picture.
Load a .BMP from somewhere into the picture.
Use the SetMenuItemBitmaps API call to connect the Picture to the Menu with
these
parameters :
- MenuItemTest is the name given to the horizontal Menuitem
- 0,1 ...   is the position of the item on which you want to place the
bitmap. (start counting
with 0)
- The first of the two bitmap-handles is the one for the bitmap displayed
for the unchecked
menuitem.
- The second is the one for the checked menuitem. These can be the same or not.

All this can by coded in the .Create of a form.

Result : It works, but only the right-top of the bitmap is displayed. Rest
us to change the height and/or width of the menuitem according to the bitmap

