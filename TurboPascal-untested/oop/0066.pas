{From: q3817075@bonsai (Olaf Lueder)}
{
: I'm writing a program using BP7.0 and TurboVision. I have DialogBox
: which contains some Datafields and a listbox. The problem is now that
: when the selection in the listbox changes I want to change the
: contents of the datafields. The way i'm doing it now is first get the
: data with Dlg^.GetData(Data) and then delete Dlg^ from the destkop
: (and ofcourse dispose it). Now I modify the data and creates the
: dialogbox all over before I insert it again. This is not really what I
: wannet - How do I do the same without having to delete and then insert
: the dialogbox...
There are various ways to solve your problem...

At first: There is the 'FocusItem'-method, which is called by the
HandleEvent
          of the ListBox, whenever a new Item is focused by pressing the
arrow-
          keys or using the mouse.

That's the method you'll have to modify.

You could do it in the follow way:

  procedure tNewListBox.FocusItem(Item: integer);
  var Data: record
              InputLine1: string[20];
              InputLine2: integer;
              CheckBox1 : word;
              .
              .
              List      : pCollection;
              Item      : integer;
            end;
  begin
    inherited FocusItem(Item);
    Owner^.GetData(Data);
    (* here you can modify Data using the values of your actually list-item*)
    (* for example: Data.InputLine1:=pListBoxItem(List^.at(Item))^.Name    *)
    Owner^.SetData(Data);
  end;

But there still be a problem...

Owner^.SetData calls ListBox^.SetData, and ListBox^.SetData calls
 ListBox^.NewList and this method calls dispose(List, done)...

So you have to redefine the NewList-method:

  procedure tNewListBox.NewList(AList: pCollection);
  begin
    List := AList;
    if AList = nil then SetRange(0)
                   else SetRange(AList^.Count);
    if Range > 0 then FocusItem(0);
    DrawView;
    (* we don't call dispose(List, done *)
  end;

It's a solution of your problem, but it isn't a nice one...

Much better way is to use messages.

What does we have ?

We've a ListBox, and of course a Collection with our data.
Now you can send a Message from the ListBox to the Owner of itself and
every
 subview of your dialog can hear that a new list-item was focused...
Storing a pointer of the focused list-item at the InfoPtr of the
Event-record-
every subview can take required data and change itself.

Short (???) Demo:
}

program Test;
uses Objects, Drivers, App, Menus, Views, Dialogs, Validate;

const cmListItemFocused         = 1000;
      cmTestDialog              = 1001;

type  pListData                 = ^tListData;
      tListData                 = record
                                    FirstName: string[20];
                                    LastName : string[30];
                                    Age      : longint;
                                    Sex      : word;
                                  end;
      pDataCollection           = ^tDataCollection;
      tDataCollection           = object(tCollection)
        constructor Init;
         procedure FreeItem(Item: pointer); virtual;
        (* you have to add 'GetItem' and 'PutItem' and to registrate it *)
      end;
      pNewInputLine             = ^tNewInputLine;
      tNewInputLine             = object(tInputLine)
        constructor Init(var Bounds: TRect; AMaxLen: Integer);
        procedure HandleEvent(var Event: tEvent); virtual;
        procedure Modify(AData: pointer); virtual;
      end;
      pFirstNameInputLine       = ^tFirstNameInputLine;
      tFirstNameInputLine       = object(tNewInputLine)
        procedure Modify(AData: pointer); virtual;
      end;
      pLastNameInputLine        = ^tLastNameInputLine;
      tLastNameInputLine        = object(tNewInputLine)
        procedure Modify(AData: pointer); virtual;
      end;
      pAgeInputLine             = ^tAgeInputLine;
      tAgeInputLine             = object(tNewInputLine)
        procedure Modify(AData: pointer); virtual;
      end;
      pNewRadioButtons          = ^tNewRadioButtons;
      tNewRadioButtons          = object(tRadioButtons)
         constructor Init(var Bounds: TRect; AStrings: PSItem);
        procedure HandleEvent(var Event: tEvent); virtual;
        procedure Modify(AData: pointer); virtual;
      end;
      pSexRadioButtons          = ^tSexRadioButtons;
      tSexRadioButtons          = object(tNewRadioButtons)
        procedure Modify(AData: pointer); virtual;
      end;
      pNewListBox               = ^tNewListBox;
      tNewListBox               = object(tListBox)
        procedure FocusItem(Item: integer); virtual;
      end;
      pTestListBox              = ^tTestListBox;
      tTestListBox              = object(tNewListBox)
        function GetText(Item: integer; MaxLen: integer): string; virtual;
        destructor Done; virtual;
      end;
      pTestDialog               = ^tTestDialog;
      tTestDialog               = object(tDialog)
        constructor Init;
      end;
      tTestApp                  = object(tApplication)
        procedure HandleEvent(var Event: TEvent); virtual;
         procedure InitMenuBar; virtual;
        procedure TestDialog;
      end;

var   TestApp: tTestApp;

FUNCTION NewDataItem(AFirstName, ALastName: string; AAge: longint;
                     ASex: word): pListData;
var Item: pListData;
begin
  GetMem(Item, SizeOf(tListData));
  with Item^ do begin
    FirstName:=AFirstName;
    LastName:=ALastName;
    Age:=AAge;
    Sex:=ASex;
  end;
  NewDataItem:=Item;
end;

CONSTRUCTOR tDataCollection.Init;
begin
  inherited Init( 5, 0);
   insert(NewDataItem('Olaf', 'Lueder', 23, 1));
  insert(NewDataItem('second', 'person', 55, 0));
  insert(NewDataItem('third', 'person', 77, 1));
  insert(NewDataItem('fourth', 'person', 11, 0));
  insert(NewDataItem('fifth', 'person', 33, 1));
end;

PROCEDURE tDataCollection.FreeItem(Item: pointer);
begin
  FreeMem(Item, SizeOf(tListData));
end;

CONSTRUCTOR tNewInputLine.Init(var Bounds: TRect; AMaxLen: Integer);
begin
  inherited Init(Bounds, AMaxLen);
  Options:=Options or ofPostProcess;
end;

PROCEDURE tNewInputLine.HandleEvent(var Event: tEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What=evCommand) and (Event.Command=cmListItemFocused) then
    Modify(Event.InfoPtr);
 end;

PROCEDURE tNewInputLine.Modify(AData: pointer);
begin
  Abstract;
end;

PROCEDURE tFirstNameInputLine.Modify(AData: pointer);
var Str: string;
begin
  Str:=Copy(tListData(AData^).FirstName, 1, MaxLen);
  SetData(Str);
end;

PROCEDURE tLastNameInputLine.Modify(AData: pointer);
var Str: string;
begin
  Str:=Copy(tListData(AData^).LastName, 1, MaxLen);
  SetData(Str);
end;

PROCEDURE tAgeInputLine.Modify(AData: pointer);
var S: string[3];
 begin
  Str(pListData(AData)^.Age, S);
  SetData(S);
end;

CONSTRUCTOR tNewRadioButtons.Init(var Bounds: TRect; AStrings: PSItem);
begin
  inherited Init(Bounds, AStrings);
  Options:=Options or ofPostProcess;
end;

PROCEDURE tNewRadioButtons.HandleEvent(var Event: tEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What=evCommand) and (Event.Command=cmListItemFocused) then
    Modify(Event.InfoPtr);
end;

PROCEDURE tNewRadioButtons.Modify(AData: pointer);
begin
  SetData(pListData(AData)^.Sex);
end;

 PROCEDURE tSexRadioButtons.Modify(AData: pointer);
begin
  SetData(pListData(AData)^.Sex);
end;

PROCEDURE tNewListBox.FocusItem(Item: integer);
begin
  inherited FocusItem(Item);
  Message(Owner, evCommand, cmListItemFocused, List^.At(Item));
end;

FUNCTION tTestListBox.GetText(Item: integer; MaxLen: integer): string;
var S: string;
begin
  with pListData(List^.At(Item))^ do begin
    Str(Age, S);
    case Sex of
      0: S:=S+', male';
      1: S:=S+', female';
    end;
    GetText:=LastName+', '+FirstName+', '+S;
  end;
end;

DESTRUCTOR tTestListBox.Done;
begin
  NewList(nil);
  inherited Done;
end;

CONSTRUCTOR tTestDialog.Init;
var R: tRect;
    View: pView;
begin
  R.Assign( 0, 0, 76, 10);
  inherited Init(R, 'Test-Dialog');
  Options:=Options or ofCentered;
  R.Assign( 15, 2, 37, 3);
  View:=New(pFirstNameInputLine, Init(R, 20));
  insert(View);
  R.Assign( 2, 2, 15, 3);
  Insert(New(pLabel, Init(R, '~F~irstName:', View)));
  R.Assign( 53, 2, 74, 3);
  View:=New(pLastNameInputLine, Init(R, 30));
  insert(View);
  R.Assign( 41, 2, 52, 3);
   Insert(New(pLabel, Init(R, '~L~astName:', View)));
  R.Assign( 15, 4, 20, 5);
  View:=New(pAgeInputLine, Init(R, 3));
  pInputLine(View)^.SetValidator(New(pRangeValidator, Init( 0, 150)));
  insert(View);
  R.Assign( 2, 4, 15, 5);
  Insert(New(pLabel, Init(R, '~A~ge:', View)));
  R.Assign( 32, 4, 74, 5);
  View:=New(pSexRadioButtons, Init(R,
    NewSItem('~f~emale',
    NewSItem('~m~ale',
    nil))));
  insert(View);
  R.Assign( 25, 4, 30, 5);
  insert(New(pLabel, Init(R, '~S~ex:', View)));
  R.Assign( 15, 6, 74, 9);
  View:=New(pTestListBox, Init(R, 1, nil));
  pListBox(View)^.NewList(New(pDataCollection, Init));
  insert(View);
  R.Assign( 2, 6, 15, 7);
  Insert(New(pLabel, Init(R, 'L~i~st:', View)));
end;

 PROCEDURE tTestApp.HandleEvent(var Event: tEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmTestDialog) then begin
   TestDialog;
    ClearEvent(Event);
  end;
end;

PROCEDURE tTestApp.InitMenuBar;
var R: tRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(pMenuBar, Init(R, NewMenu(
    NewItem('~T~est', '', kbAltT, cmTestDialog, hcNoContext,
  nil))));
end;

PROCEDURE tTestApp.TestDialog;
begin
  ExecuteDialog(New(pTestDialog, Init), nil);
end;

begin
  with TestApp do begin
    Init;
    Run;
    Done;
  end;
end.

