(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0079.PAS
  Description: Execute a Popup Menu at ?
  Author: KAI BOELLERT
  Date: 02-21-96  21:04
*)

{
>I'm new to Pascal and Turbo Vision and I am writing a program that
>needs pop-up menus.  I've tried several times to use TMenuBox objects
>but have had no luck at all.  Could someone please point me in the
>right direction?  I am looking for a good Turbo Vision tutorial or a
>short example using TMEnuBox with submenus from the first pop-up menu.

You can create popup menus using an instance of the TMenuPopup class.
For a complete reference of this class have a look at the online help
because the (german) manual doesn't describes TMenuPopup.

Use the following procedure to execute a popup menu:
}
procedure ExecutePopupMenu (At:TPoint; PopupMenu:PMenuPopup);
  { shows the "PopupMenu" at the position "At" }
var
  Bounds : TRect;
  D      : Integer;
begin
  if Application^.ValidView(PopupMenu) <> nil then
  begin
    D:=0;
    Inc(At.Y);              
    Application^.GetBounds(Bounds);
    if At.Y + PopupMenu^.Size.Y > Bounds.B.Y then 
    begin
      Dec(At.Y, PopupMenu^.Size.Y+1);
      if At.Y < Bounds.A.Y then
      begin
        At.Y:=Bounds.A.Y;
        Inc(At.X); D:=1;
      end;
    end;
    if At.X + PopupMenu^.Size.X > Bounds.B.X then    
      Dec(At.X, PopupMenu^.Size.X+D);
    Application^.MakeLocal(At, At);
    PopupMenu^.MoveTo(At.X, At.Y);    
    Application^.Insert(PopupMenu);   
    Message(PopupMenu, evBroadcast, cmCommandSetChanged, nil);
    Message(PopupMenu, evCommand, cmMenu, nil);
    DisposeMenu(PopupMenu^.Menu);                
    Dispose(PopupMenu, Done);
  end;
end;

Before executing the popup menu this procedure is doing some
calculations to guarantee that regardless of the parameter "At" the
popup menu is always showed within the current screen boundaries of
"Application".

- Kai



