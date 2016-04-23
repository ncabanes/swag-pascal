{
▒Hello.  I was toying around With TVision, trying to make derive an Object fr
▒TDialog which would be a simple 'Delay box' (i.e. a message would display, t
▒the box would cmOK itself after two seconds).  I tried a simple Delay() comm
▒in HandleEvent, which seemed to work fine, but when I held down the mouse bu
▒on the menu, it locked up and sometimes my memory manager woudl report crazy
▒error messages.  Can anyone offer a suggestion on how to do this safely?  Th
▒are certain situations when clicking an 'OK' button is just a hassle.  Thank

Try trapping the mouse events in the HandleEvent method of the dialog
box.
}

Type
  tDelayDialog = Object(tDialog)
    Procedure HandleEvent(Var Event : tEvent); VIRTUAL;
  end;

Procedure tDelayDialog.HandleEvent(Var Event : tEvent);
Const
  cDelay = 2000;
begin
  if Event.What and evMouse <> 0 then (* This filters out mouse   *)
                                      (* events before they reach *)
                                      (* the parent               *)
  ELSE
  begin
    Delay(cDelay);
    Event.Command := cmOK;          (* Set up the command       *)
    INHERITED HandleEvent(Event);   (* Let the parent handle it *)
  end;
end;
