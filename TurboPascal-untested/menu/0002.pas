{
This is Turbo Pascal Unit is sent in reply to uuj@ufu107.phys.ufl.edu in
request For help on menu's.  I was purely fed up With the TMenu options,
and so I created my own menu Unit.  Although it is space consuming in data
initialization, this Unit enables Programmers to enhance their Programs.  If
user defined menus are required For your Program, a Text Program can be
created from the Program containing the initialization information.  A simple
call can clear the screen and push the menu onto your screen.  The info for
usage all exists within the Interface portion of the Unit, so I won't trouble
myself With typing everything down.  If this Unit is indeed helpful, please
send me a copy of the end product so I can view the work of which this
nineteen year old Programmer has helped with...
                                        L. Saxon Joseph Ralph Lewis
}


Unit JMenu;

Interface

Uses
  Crt;

Type
  WinCord = Record
    Xa : Byte;
    Xb : Byte;
    Ya : Byte;
    Yb : Byte;
  end;
  MenuList = Record
    MenuLink  : Integer;
    MenuName  : String;
    Question  : String;
    OpenState : String;
    NumItems  : Integer;
    Items     : Array [1..15] of String;
    ItemCode  : Array [1..15] of Char;
  end;

Var
  Win  : WinCord;
  List : MenuList;
  Xdc,
  Ydc  : Integer;
  Code : Char;

Procedure Border(X, Y : Integer; BackGround : Integer; Color : Integer);
Procedure MenuScr(X, Y : Integer; BackGround : Integer; Color : Integer);
Procedure Println(PStr : String);
Procedure Print(PStr : String);
Function  SrchErr(Cher : Char; List : MenuList) : Boolean;
Procedure ShowError;
Procedure Menu(X, Y :Integer; BackGround : Integer; Color : Integer;
               List : MenuList);
Procedure Command(X, Y :Integer; BackGround : Integer; Color : Integer;
                  List : MenuList);
Procedure InitMenu(Var List : MenuList);


Implementation

Procedure Border(X,Y : Integer; BackGround : Integer; Color : Integer);
Var
  Xdc, Ydc : Integer;
begin
  For Xdc := 2 to (X - 2) do
  begin
    GotoXY(Xdc + 1, 1);
    Write(chr(205));
    GotoXY(Xdc + 1, Y);
    Write(chr(205));
  end;
  For Ydc := 2 to (Y - 3) do
  begin
    GotoXY(1, Ydc + 1);
    Write(chr(186));
    GotoXY(X, Ydc + 1);
    Write(chr(186));
  end;
  GotoXY(2, 1);
  Write(chr(201));
  GotoXY(1, 2);
  Write(chr(201));
  GotoXY(2, 2);
  Write(chr(188));
  GotoXY(X - 1, 1);
  Write(chr(187));
  GotoXY(X, 2);
  Write(chr(187));
  GotoXY(X - 1, 2);
  Write(chr(200));
  GotoXY(1, Y - 1);
  Write(chr(200));
  GotoXY(2, Y);
  Write(chr(200));
  GotoXY(2, Y - 1);
  Write(chr(187));
  GotoXY(X, Y - 1);
  Write(chr(188));
  GotoXY(X - 1, Y);
  Write(chr(188));
  GotoXY(X - 1, Y - 1);
  Write(chr(201)); {188}
end;

Procedure MenuScr(X,Y : Integer; BackGround : Integer; Color : Integer);
begin
  Window(1, 1, 80, 25);
  TextBackground(Black);
  ClrScr;
  Win.Xa := 40 - Round(X / 2);
  Win.Xb := 40 + Round(X / 2);
  Win.Ya := 12 - Round(Y / 2);
  Win.Yb := 12 + Round(Y / 2);
  X := X + 1;
  Y := Y + 1;
  Window(Win.Xa, Win.Ya, Win.Xb, WIn.Yb);
  TextBackground(BackGround);
  TextColor(Color);
  ClrScr;
  Border(X, Y, BackGround, Color);
  GotoXY(3, 3);
end;

Procedure Println(PStr : String);
Var
  Xdc : Integer;
begin
  If Length(PStr) > (Win.Xb - Win.Xa - 4) then
  begin
    Writeln('Menu too small...');
    Halt
  end;
  Write(Pstr);
  Xdc := WhereY;
  GotoXY(3, Xdc + 1);
end;

Procedure Print(PStr : String);
Var
  Xdc : Integer;
begin
  If Length(PStr) > (Win.Xb - Win.Xa - 4) then
  begin
    Writeln('Menu too small...');
    Halt
  end;
  Write(Pstr);
end;

Function SrchErr(Cher : Char; List : MenuList) : Boolean;
begin
  SrchErr := True;
  For Xdc := 1 to List.NumItems do
    If Cher = List.ItemCode[Xdc] Then
      SrchErr := False;
end;

Procedure ShowError;
Var
  Me   : Char;
  T, H : Integer;
begin
  MenuScr(42, 8, Red, Yellow);
  Println('An Error has been detected.');
  Println('Please be careful in your');
  Println('Value Entering...');
  Print('  [Press Any Key to Continue]');
  Me := ReadKey;
  TextBackground(Black);
  ClrScr;
end;

Procedure Menu(X, Y : Integer; BackGround : Integer; Color : Integer;
               List : MenuList);
Var
  PrnStr : String;
  Cord   : Char;
begin
  MenuScr(X, Y, Background, Color);
  Xdc := Round(X / 2) - round(Length(List.MenuName) / 2);
  GotoXY(Xdc, 2);
  Println(List.MenuName);
  GotoXY(3, 4);
  Println(List.OpenState);
  For Xdc := 1 to List.NumItems do
  begin
    PrnStr := Concat('   ', List.ItemCode[Xdc], ' :  ', List.Items[Xdc]);
    Println(PrnStr);
  end;
  GotoXY(WhereX, WhereY + 1);
  Print(List.Question);
end;

Procedure Command(X, Y : Integer; BackGround : Integer; Color : Integer;
                  List : MenuList);
Var
  PrnStr : String;
  Cord   : Char;
begin
  MenuScr(X, Y, Background, Color);
  Xdc := Round(X / 2) - round(Length(List.MenuName) / 2);
  GotoXY(Xdc, 2);
  Println(List.MenuName);
  GotoXY(3, 3);
  Print(List.Question);
end;

Procedure InitMenu(Var List : MenuList);
begin
  TextBackGround(Black);
  Window(1, 1, 80, 25);
  ClrScr;
  List.MenuName  := '';
  List.OpenState := '';
  List.NumItems  := 0;
  For Xdc := 1 to 15 do
    List.Items[Xdc] := '';
  For Xdc := 1 to 15 do
    List.Itemcode[Xdc] := ' ';
  List.Question := '';
end;

end.
