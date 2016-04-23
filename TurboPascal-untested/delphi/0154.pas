
{
> Can you add menu items to the standard popup menu of a form?
> 
> I want to do the same thing that Borland did for their PageControl
> component.  If you right-click on the Page Control, you get the same std
> menu but with a couple of new items inserted at the top (e.g. New Page).
> 
> I remember reading a post asking about how to create menus at runtime.
> I don't think it was answered through the newsgroup, so...
> How do you create menus at runtime?
> 

Do you mean add things to the right click menu when designing? Or create a popup 
when the program is running? 

When running simply create a TPopupMenu and assign it to the PopupMenu property.
This can either be done at design-time or run-time.  It won't show at design time 
however, since that menu is the form designers.

To add items to the context menu that is shown at design-time, you need to create 
a new component editor for your component.

You'll need to override GetVerbCount to return the number of items you want to
add to the menu, and GetVerb to actually fill the list of items.  You'll also
need to override ExecuteVerb to actually do the actions.

For example:
}

TMyEditor = class(TComponentEditor)
public
  function GetVerbCount : Integer; override;
  function GetVerb(Index : Integer); override;
  procedure ExecuteVerb(Index : Integer); override;\
end;

function TMyEditor.GetVerbCount : Integer;
begin
     Result := 2;
end;

function TMyEditor.GetVerb(Index : Integer);
begin
  case Index of
        0 : Result := 'Say Hi';
         1 : Result := 'Say Bye';
  end;
end;

procedure TMyEditor.ExecuteVerb(Index : Integer);
var
   MyMsg : String;
begin
     case Index of
        0 : MyMsg := 'Hi';
        1 : MyMsg := 'Bye;
     end;
     MessageDlg(MyMsg,mtInformation,[mbOK],0);
end;

You'll also need to register the component editor in the Register proc for the 
component.

procedure Register;
begin
     RegisterComponents('My Component Page',[TMyComponent]);
     RegisterComponentEditor(TMyComponent,TMyEditor);
end;

