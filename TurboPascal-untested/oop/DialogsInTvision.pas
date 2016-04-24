(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0034.PAS
  Description: Dialogs in TVision
  Author: KEN BURROWS
  Date: 01-27-94  12:23
*)

{
>>> In a Turbo Vision DIALOG form, how do you (re)select the FIRST editable
>>> data field FROM ANYWHERES IN the DIALOG?

>> You don't select it. You let IT select itself. Since all the views
>> inserted into the dialog are descendents of TView, then they all
>> have a select method.

> Nice Idea, too bad it's not that simple 8-(

It rarely is with TV.
}
Program SelectAView_2; {tested. The only thing this does, is work}

   { If you want to have an object select itself, without haveing
     to explicitly define itself first, you must begin with an
     object that KNOWS how to select itself.
     Since Select is a method of the TView object, any descendent
     will know how.

     A method is then needed by the object,
     that contains the object that must select itself,
     to get its, request that it select itself
     to the object that must select itself.

     Use the evBroadcast event.

     The object, that contain the object that must select itself,
     generates a broadcast event onto it's event tree. (random shot
     in the dark) This broadcast, requests that any object that
     is set to select itself on the events command, should accept the
     broadcast.... , and then select itself.

     This is accomplished by taking your last instance definition
     of a object that you are inserting into your event queue and
     descending it once more to overide its HandleEvent method.

     In my example, I've used a simple TDialog and inserted a
     bunch of of TInputLine's and a TButton that generates an
     EvCommand of 'SelectFirst', and descended the HandleEvent
     to generate a evBroadCast event, to broadcast the SelectFirst
     Command.

     The TinputLine descendent, TMyLine, is directly descended
     from the type of object that I am linking into this TDialog
     objects event queue.

     Within a 'For i = 1 to 4' Loop, the TDialogs constructor
     will insert a TMyLine type, that will select itself whenever
     an evBroadCast event, broadcasts a SelectFirst command.

     As long as this object is a descendent of a TView, the
     TDialog will accept it, and treat like any other object.

     A TButton is installed to provide a method of generating
     an evBroadCast event that broadcasts a SelectFirst command.
   }


uses Objects,App,Dialogs,Views,Drivers;

type
  MyDlg = object(TDialog)
            constructor init;
            procedure HandleEvent(var Event:TEvent); virtual;
          end;

  MyLine = Object(TInputLine)
             Selector : Word;
             Constructor Init(var bounds:Trect;AMaxLen:Integer;
                              SelectKey:Word);
             Procedure HandleEvent(Var Event:TEvent); virtual;
           end;
  PMyLine = ^MyLine;

const
  SelectFirst = 1000;

Constructor MyLine.Init(var bounds:Trect;AMaxLen:Integer;
                        SelectKey:Word);
   Begin
     Inherited Init(Bounds,AMaxLen);
     EventMask := EventMask or evBroadcast;
     Selector := SelectKey;
   End;

Procedure MyLine.HandleEvent(Var Event:TEvent);
   Begin
     inherited HandleEvent(Event);
     if   (Event.What = EvBroadcast) and
          (Event.Command = Selector)
     then Select;
  End;

Constructor MyDlg.Init;
   var r:trect;
       i:integer;
   Begin
     r.assign(0,0,50,13);
     inherited init(r,'test dialog');
     options := options or ofcentered;
     getextent(r);
     r.grow(-3,-2);
     r.b.y := r.a.y + 1;
     for i := 1 to 4 do
        begin
          if   i = 2
          then insert(new(PMyLine,init(r,size.x,SelectFirst)))
          else insert(New(PInputLine,init(r,size.x)));
          inc(r.a.y,2); inc(r.b.y,2);
        end;
     inc(r.b.y);
     inc(r.a.x,(size.x div 2) - 14);
     dec(r.b.x,(size.x div 2) - 13);
     insert(new(Pbutton,init(r,'~S~elect FirstLine',
                             SelectFirst,bfdefault)));
     SelectNext(False);
   end;

Procedure MyDlg.HandleEvent(Var Event:TEvent);
   Begin
     inherited HandleEvent(Event);
     if   (Event.What = EvCommand) and
          (Event.Command = SelectFirst)
     then Message(owner,evBroadcast,Event.Command,nil);
   end;

var
  a : TApplication;
  m : longint;
type
  PMyDlg = ^MyDlg;

begin
  m := memavail;
  with a do
  begin
    Init;
    ExecuteDialog(new(PMyDlg,init),nil);
    done;
  end;
  if memavail <> m then writeln('memory allocation/deallocation error');
end.

