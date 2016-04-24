(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0065.PAS
  Description: TV Popup Menu Bug
  Author: PER-ERIC LARSSON
  Date: 05-26-95  23:20
*)

{
Tried to use the "Popup menu" in turbo vision ?
Is it documented how to do it ?
Well anyway if you do you'll find it doesn't release the memory used by its
topics - don't know if this is a "known" bug ?

Here is an inherited unit to use in addition to the menus unit:
}

unit pelmenus;
interface
uses menus;

type
 PpelMenuPopup=^TpelMenuPopup;
 TpelMenuPopup=object(TMenuPopup)
     destructor done;virtual;
 end;
implementation

destructor TpelMenuPopup.Done;
begin
  TMenuView.Done;
  DisposeMenu(Menu);
end;
end.

