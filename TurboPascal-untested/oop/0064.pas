{
From: Ken.Burrows@telos.org (Ken Burrows)

>I am trying to write a TVision program that displays a list of items in a
>list box. After highligting the item that the user wants and hitting the OK
>button, I want to copy the highlighted item into a string variable.
>I can Display the list of items (A TCollection) in the list box. However,
>I don't know how to return the highlighted value.

There are a number of ways of getting the data out of the list box. The easiest
is to have the list box itself broadcast the data back to the dialog.
When you call getdata, you are calling the dialogs getdata method. Unless you
have overidden the method, it's a bit undefined as to what you are getting
back. Since the list box is inserted into the dialog, to get the item that was
focused, use TheListBox^.List^.At(TheListBox^.Focused) and typecast it as the
data type that the list box is listing.

Here is a working example.
}

Program ListBoxDemo;
Uses App,Menus,Dialogs,Views,Drivers,Objects,Dos,MsgBox;

Type
   MyListBox = Object(TListBox)
                 procedure HandleEvent(var Event:TEvent); virtual;
               end;
   MyListBoxPtr = ^MyListBox;

   MyDialog = Object(TDialog)
                pl:MyListBoxPtr;
                constructor init;
                procedure HandleEvent(var Event:Tevent); virtual;
                Destructor Done; virtual;
              end;
   MyDialogPtr = ^MyDialog;

  TMyApp = Object(TApplication)
             procedure initstatusline; virtual;
           end;
Const
  EnterPressed    = 201;
  DoubleClicked   = 202;
  SpaceBarred     = 203;
  OkButton        = 204;

Function ListOfStuff:PStringCollection; {generic PStringCollection}
   var p:PStringCollection;
       sr:SearchRec;
   Begin
     p := nil;
     findfirst('*.*',0,sr);
     while doserror = 0 do
     begin
       if p = nil then new(p,init(5,3));
       p^.insert(newstr(sr.name));
       findnext(sr);
     end;
     ListOfStuff := p;
   End;

Procedure MyListBox.HandleEvent(var Event:TEvent);
   begin
     if  (Event.What = evMouseDown) and (Event.Double)
     then Message(Owner,evBroadCast,DoubleClicked,list^.at(focused))
     else if   (event.what = evkeydown) and (event.KeyCode = KbEnter)
          then Message(Owner,evBroadCast,EnterPressed,list^.at(focused))
          else if   (event.what = evkeydown) and (event.CharCode = ' ')
               then Message(Owner,evBroadCast,SpaceBarred,list^.at(focused))
               else inherited HandleEvent(event);
  End;

Constructor MyDialog.Init;
   var r:trect;
       ps:pscrollbar;
   Begin
     r.assign(0,0,17,16);
     inherited init(r,'Stuff');
     options := options or ofcentered;
     getextent(r); r.grow(-1,-1); dec(r.b.y,3); r.a.x := r.b.x - 1;
     new(ps,init(r));
     insert(ps);
     r.b.x := r.a.x; r.a.x := 1;
     new(pl,init(r,1,ps));
     insert(pl);
     pl^.newlist(ListOfStuff);
     r.assign(size.x div 2 - 4,size.y-3,size.x div 2 + 4,size.y-1);
     insert(new(Pbutton,init(r,'OK',OkButton,BfNormal)));
     selectnext(false);
  End;
Procedure MyDialog.HandleEvent(var Event:TEvent);
   Procedure ShowMessage(s:String);
      Begin
        MessageBox(#3+s+#13#3+'Item Focused : '+
                   PString(Event.InfoPtr)^,
                   nil,mfokbutton+mfinformation);
      End;
   Begin
     inherited HandleEvent(Event);
     if   (event.what = evBroadcast) or (event.what = evCommand)
     then case event.command of
           EnterPressed  : ShowMessage('Enter Pressed');
           DoubleClicked : ShowMessage('Double Clicked');
           SpaceBarred   : ShowMessage('Space Barred');
           OkButton      : MessageBox(#3'Ok Button Pressed'#13#3+
                                      'ItemFocused = '+
                                      PString(pl^.list^.at(pl^.focused))^,
                                      nil,mfokbutton+mfinformation);
         end; {case}

  End;
Destructor MyDialog.Done;
   Begin
     pl^.newlist(nil);   {required to clear the listbox}
     inherited done;
   End;

Procedure TMyapp.InitStatusline;
  var
    r : trect;
  begin
    GetExtent(R);
    r.a.y := r.b.y - 1;
     StatusLine := new(pstatusline,init(r,
     newstatusdef(0,$FFFF,
     newstatuskey('List Box Demo by Ken.Burrows@Telos.Org.'+
     '   Press [ESC] to Quit.',
     0,0,nil),nil)));
  end;

var
  a:TMyApp;
  m:longint;
Begin
  m := memavail;
  with a do
  begin
    init;
    executedialog(new(MyDialogPtr,init),nil);
    done;
  end;
  if m <> memavail then writeln('heap ''a trouble');
End.
