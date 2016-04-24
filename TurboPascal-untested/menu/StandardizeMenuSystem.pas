(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0003.PAS
  Description: Standardize Menu system
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:02
*)


Unit Menus;
{This unit provides a standardized menu system.}

Interface
Uses Crt;

Type
    MenuLineType = String[25];
    MenuArryType = Array[1..25] of MenuLineType;
    MenuRec      = Record
        MenuArray  : MenuArryType;
        NbrEntries : Integer;
    End; {MenuRec}

    LocationRec = Record
        Col : Integer;
        Row : Integer;
    End;

    ScreenLocation = (NW, N, NE, W, C, E, SW, S, SE);

Procedure CreateMenu (Var Menu : MenuRec);
{Initializes the menu to empty before starting a new menu}

Procedure AddToMenu (Var Menu : MenuRec;
                         NewEntry : MenuLineType);
{Adds a new line entry to the menu being built}

Procedure ShowMenu (Var Menu     : MenuRec;
                        Position : ScreenLocation;
                    Var ItemSelected : Integer);
{Displays the current menu on the screen at the location defined by
Position}

Procedure ChangeMenuColors (Border, Background, Foreground, SelectBack,
                            SelectFore : Integer);
{Sets the colors used in the menu}

Implementation
Type
    MenuColorRec = Record
        MenuBorder : Integer;
        MenuBackGnd : Integer;
        MenuForeGnd : Integer;
        MenuSelectBack : Integer;
        MenuSelectFore : Integer;
    End;

Var
    MenuColor : MenuColorRec;

Function RowWidth (Var Menu : MenuRec): Integer;
Var
    ix, wide : integer;
Begin
    wide := 0;
    For ix := 1 to Menu.NbrEntries Do
        If Length(Menu.MenuArray[ix]) > wide Then
            wide := Length(Menu.MenuArray[ix]);
    RowWidth := wide;
End;

Procedure FindPosition (Var Menu     : MenuRec;
                            Position : ScreenLocation;
                        Var LocOut   : LocationRec);
{This function calculates the beginning position for the first line as
 a column and a row.}

Var
    ix : Integer;
Begin
    Case Position of
      NW : Begin
             LocOut.Col := 2;
             LocOut.Row := 2;
           End;
      N  : Begin
             LocOut.Col := 39 - RowWidth(Menu) Div 2;
             LocOut.Row := 2;
           End;
      NE : Begin
             LocOut.Col := 79 - RowWidth(Menu);
             LocOut.Row := 2;
           End;
      W  : Begin
             LocOut.Col := 2;
             LocOut.Row := 12 - Menu.NbrEntries Div 2;
           End;
      C  : Begin
             LocOut.Col := 39 - RowWidth(Menu) Div 2;
             LocOut.Row := 12 - Menu.NbrEntries Div 2;
           End;
      E  : Begin
             LocOut.Col := 79 - RowWidth(Menu);
             LocOut.Row := 11 - Menu.NbrEntries Div 2;
           End;
      SW : Begin
             LocOut.Col := 2;
             LocOut.Row := 25 - Menu.NbrEntries;
           End;
      S  : Begin
             LocOut.Col := 39 - RowWidth(Menu) Div 2;
             LocOut.Row := 25 - Menu.NbrEntries;
           End;
      SE : Begin
             LocOut.Col := 79 - RowWidth(Menu);
             LocOut.Row := 25 - Menu.NbrEntries;
           End;
    End; {Case}
End;

Procedure CreateMenu (Var Menu : MenuRec);
{Initializes the menu to empty before starting a new menu}
Begin
    Menu.NbrEntries := 0;
    MenuColor.MenuBorder := Yellow;
    MenuColor.MenuBackGnd := Lightgray;
    MenuColor.MenuForeGnd := Black;
    MenuColor.MenuSelectBack := Cyan;
    MenuColor.MenuSelectFore := Blue;
End;

Procedure AddToMenu (Var Menu : MenuRec;
                         NewEntry : MenuLineType);
{Adds a new line entry to the menu being built}
Begin
    inc(Menu.NbrEntries);
    Menu.MenuArray[Menu.NbrEntries] := NewEntry;
End;

Procedure ShowMenu (Var Menu : MenuRec;
                        Position : ScreenLocation;
                    Var ItemSelected : Integer);
Var
    CurrPosition,
    HoldPosition : LocationRec;
    ix, wide     : Integer;
    Ch           : Char;
{Displays the current menu on the screen at the location defined by
Position}

Begin
         ClrScr;
         FindPosition(Menu, Position, CurrPosition);
         HoldPosition := CurrPosition;
         TextBackGround(MenuColor.MenuBackGnd);
         TextColor(MenuColor.MenuForeGnd);
         ItemSelected := 1;
         GoToXY(CurrPosition.Col, CurrPosition.Row - 1);
         TextBackGround (MenuColor.MenuBorder);
         wide := RowWidth(Menu);
         for ix := 1 to wide + 1 Do
             Write(' ');
         While ItemSelected <= Menu.NbrEntries Do
         Begin
             GoToXY(CurrPosition.Col - 1, CurrPosition.Row);
             TextBackGround (MenuColor.MenuBorder);
             Write (' ');
             TextBackGround (MenuColor.MenuBackGnd);
             Write (Menu.MenuArray[ItemSelected]);
             For ix := Length(Menu.MenuArray[ItemSelected]) to wide Do
                 Write(' ');
             TextBackGround (MenuColor.MenuBorder);
             Write (' ');
             Inc(CurrPosition.Row);
             Inc(ItemSelected);
         End;
         GoToXY(CurrPosition.Col, CurrPosition.Row);
         TextBackGround (MenuColor.MenuBorder);
         for ix := 1 to wide + 1 Do
             Write(' ');
         ItemSelected := 1;
         CurrPosition.Row := HoldPosition.Row;
         Repeat
             GoToXY(CurrPosition.Col, CurrPosition.Row);
             TextBackground (MenuColor.MenuSelectBack);
             TextColor (MenuColor.MenuSelectFore);
             Write (Menu.MenuArray[ItemSelected]);
             For ix := Length(Menu.MenuArray[ItemSelected]) to wide Do
                 Write (' ');
             Ch := Readkey;
             TextBackGround (MenuColor.MenuBackGnd);
             TextColor (MenuColor.MenuForeGnd);
             if Ch = #0 Then
             Begin
                 Ch := ReadKey;
                 GoToXY(CurrPosition.Col, CurrPosition.Row);
                 Write (Menu.MenuArray[ItemSelected]);
                 For ix := Length(Menu.MenuArray[ItemSelected]) to wide Do
                     Write (' ');
                 Case Ch of
                 #80 : Begin
                       Inc(CurrPosition.Row);
                       Inc(ItemSelected);
                       If ItemSelected > Menu.NbrEntries Then
                       Begin
                          ItemSelected := 1;
                          CurrPosition.Row := HoldPosition.Row;
                         End;
                       End;
                 #72  : Begin
                       Dec(CurrPosition.Row);
                       Dec(ItemSelected);
                       If ItemSelected < 1 Then
                       Begin
                          CurrPosition.Row := Menu.NbrEntries + HoldPosition.Row
                           - 1;
                          ItemSelected := Menu.NbrEntries;
                         End;
                       End;
                  End;
             End;
         Until (Ch = #27) or (Ch = #13);
End;

Procedure ChangeMenuColors (Border, Background, Foreground, SelectBack,
                            SelectFore : Integer);
{Sets the colors used in the menu}
Begin
    MenuColor.MenuBorder := Border;
    MenuColor.MenuBackGnd := Background;
    MenuColor.MenuForeGnd := Foreground;
    MenuColor.MenuSelectBack := SelectBack;
    MenuColor.MenuSelectFore := SelectFore;
End;

End.

{ ----------------------DEMO PROGRAM FOLLOWS ----------------------}


Program MenuDemo;
Uses Menus, Dos, Crt;
Var
    Menu : MenuRec;
    ItemSelected : Integer;
Begin
    CreateMenu(Menu);
    AddToMenu(Menu, 'DISPLAY MEMBERS');
    AddToMenu(Menu, 'ADD A MEMBER');
    AddToMenu(Menu, 'DELETE A MEMBER');
    AddToMenu(Menu, 'MEMBER FINANCES');
    AddToMenu(Menu, 'QUIT');
    ShowMenu(Menu, NW, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, N, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, NE, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, W, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, C, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, E, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, SW, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, S, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
    ShowMenu(Menu, SE, ItemSelected);
    TextBackGround (Black);
    TextColor (White);
    ClrScr;
    Writeln ('SELECTED ', Menu.MenuArray[ItemSelected]);
    Readln;
End.
