(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0084.PAS
  Description: Listbox example for TurboVision
  Author: BRAD PRENDERGAST
  Date: 05-30-97  18:17
*)

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 Program Name : ListBox2.Pas
 Written By   : Brad Prendergast
 E-Mail       : mrealm@ici.net
 Web Page     : http://www.ici.net/cust_pages/mrealm/BANDP.HTM
 Program
 Compilation  : Borland Turbo Pascal 7.0

 Program Description :
  This demonstration is of a ListBox that allows the jumping through the
  list by pressing an alphabetic character and then proceding to the first
  item in the list that begins with that character.  This demonstation is
  very basic, simple and non-complex.  It is meant to be built upon and the
  reenforcement of the ideas. Any questions or comments feel free to email
  me.

 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

Program ListBoxDemo2;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  uses
    app, objects, dialogs, views, drivers, menus;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  const
    cmList = 101;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  type
    PListWindow = ^TListWindow;
    TListWindow = object (tdialog)
                Constructor Init;
                  end;

    PKeyListBox = ^TKeyListBox;
    TKeyListBox = object (TListBox)
                searchcharacter: char;
                Constructor Init(var bounds : TRect; anumcols : word;
                                 ascrollbar : PScrollBar);
                Procedure HandleEvent(var event: TEvent); Virtual;
                  end;

    PDemoApp = ^TDemoApp;
    TDemoApp = object (TApplication)
             Constructor Init;
             Procedure InitMenuBar;Virtual;
             Procedure HandleEvent ( var event : TEvent); Virtual;
             Procedure List_It;
             Destructor Done;Virtual;
               end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  var
  {$IFDEF DEBUG}
    the : longint;
  {$ENDIF}
     DemoApp : TDemoApp;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Constructor TListWindow.Init;
    Var
      r       : Trect;
      list    : PListBox;
      scrol   : PScrollBar;
    Begin
      r.Assign ( 0, 0, 37, 14 );
      Inherited Init ( r, 'List Box Demo');
      options := options or ofcentered;
      r.Assign ( 32, 3, 33, 10 );
      scrol := New(PScrollBar,Init(r));
      Insert(scrol);
      r.assign( 4,3,32,10);
      list := New ( PKeyListBox, Init ( r, 1, scrol));
      Insert (List);
      r.Assign( 4, 2, 33, 3);
      Insert (New(Plabel,  init (r, '~S~elect from List : ', list)));
      r.Assign( 8, 11, 18, 13);
      insert (New(PButton, init (r, '~O~k', cmOk, bfDefault)));
      r.Move (11, 0);
      insert (new(PButton, init (r, '~C~ancel', cmCancel, bfNormal)));
      selectnext(false);
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Constructor TKeyListBox.Init(var bounds : TRect; anumcols : word;
                               ascrollbar : PScrollBar);
    Begin
    Inherited Init(bounds, anumcols, ascrollbar);
    searchcharacter := #0;

    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TKeyListBox.HandleEvent ( var event : TEvent);
    var
      thechar : char;
      thestr  : pstring;

      function StartWithCharacter(item: PString): boolean; 
        begin
          StartWithCharacter := (item <> nil) and (item^ <> '') and
                                ((item^[1] = searchcharacter) or
                                (item^[1] = char(ord(searchcharacter) + 32)));
         end;

    Begin
      if (event.what = evkeydown) then
        begin
          if (event.charcode <> #0) and not (event.charcode in [#13, #27, #32]) then
            begin
              thechar := event.charcode;
              if (thechar >= 'a') and (thechar <= 'z') then
                thechar := char(ord(thechar) - 32);
              searchcharacter := thechar;
            end
          else
            begin
              inherited handleevent(event);
              exit;
            end;
          clearevent(event);
          thestr := list^.firstthat(@startwithcharacter);
          if (thestr <> nil) then
            begin
              focusitem(list^.indexof(thestr));
              drawview;
            end;
        end
      else
        inherited handleevent(event);
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Constructor TDemoApp.Init;
    Begin
      Inherited Init;
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TDemoApp.InitMenuBar;
    var
      r : Trect;
    Begin
      GetExtent(r);
      r.b.y := r.a.y + 1;
      menubar := New (PMenuBar, Init (r, NewMenu(
                 newsubmenu ('~D~emo', hcNoContext, newmenu(
                   newitem  ('~L~istbox', '', kbNoKey, cmList, hcNoContext,
                             nil)), nil))));
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TDemoApp.HandleEvent (var event : TEvent);
    Begin
      if (Event.What = evCommand) then
        Begin
          case ( event.command ) of
            cmList    : List_It;
          end;
        End;
      Inherited HandleEvent(event);
      ClearEvent(event);
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TDemoApp.List_It;
    type
      TListBoxRec = record
                  list      : PCollection;
                  Selection : word;
                    end;
    var
      data   : TListBoxRec;
      name   : string;
      result : integer;
      bounds : TRect;
    Begin
      data.list := new(PStringCollection, Init(20, 10));
      data.list^.Insert(NewStr('Anchorage'));
      data.list^.Insert(NewStr('Atlanta'));
      data.list^.Insert(NewStr('Baltimore'));
      data.list^.Insert(NewStr('Boston'));
      data.list^.Insert(NewStr('New York'));
      data.list^.Insert(NewStr('New Mexico'));
      data.list^.Insert(NewStr('Nevada'));
      data.list^.Insert(NewStr('Chugiak'));
      data.list^.Insert(NewStr('Detroit'));
      data.list^.Insert(NewStr('Dallas'));
      data.list^.Insert(NewStr('Lowell'));
      data.list^.Insert(NewStr('Ketchican'));
      data.list^.Insert(NewStr('Haines'));
      data.list^.Insert(NewStr('Juneau'));

      data.selection := 0;
      result := ExecuteDialog(New(PListWindow, Init), @data);
      name := PString(data.List^.At(data.Selection))^;
      Dispose(data.List, Done);
      if (result = cmOK) then
        begin
          bounds.Assign(15, 5, 65, 12);
          InsertWindow(New(PWindow,
          Init(bounds, Concat('Chosen One: ', name), wnNoNumber)));
        end;
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Destructor TDemoApp.Done;
    Begin
      Inherited Done;
    End;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

Begin
  DemoApp.Init;
  DemoApp.Run;
  DemoApp.Done;
End.
