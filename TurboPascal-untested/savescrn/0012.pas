{ - SCREEN.PAS -}
unit screen;
Interface
uses crt,dos;
  type
       ScreenRec = Record
         Character:Byte;
         Attribute:Byte;
       end;
       SnapShot = record
         Screen:array[1..4000] of ScreenRec;
         StoreX:byte;
         StoreY:byte;
       end;
       ScreenStore=object
         Memory:SnapShot;
         constructor Init(InitX,InitY,InitChar,InitColor:byte);
         procedure storescreen;
         procedure restorescreen;
       end;
       ScreenStorePointer = ^ScreenStore;
Implementation
  CONSTRUCTOR ScreenStore.Init(InitX,InitY,InitChar,InitColor:byte);
    {** Initializes to Cleared Screens **}
    var
      Count:integer;
    begin
      Count:=1;
      while Count<=4000 do
        begin
          FillChar(Memory.Screen[Count].Character,
            SizeOf(Memory.Screen[Count].Character),InitChar);
          FillChar(Memory.Screen[Count].Attribute,
            SizeOf(Memory.Screen[Count].Attribute),InitColor);
          inc(Count);
        end;
      Memory.StoreX:=InitX;
      Memory.StoreY:=InitY;
    end;
  PROCEDURE ScreenStore.StoreScreen;
    var
      MonoAddress:  char absolute $B000:0000;
      ColorAddress: char absolute $B800:0000;
      begin
        if lastmode=mono then
          move(monoAddress,Memory.Screen,8000)
        else
          move(colorAddress,Memory.Screen,8000);
        Memory.StoreX:=WhereX;
        Memory.StoreY:=WhereY;
      end;
  {STORESCREEN}
  PROCEDURE ScreenStore.RestoreScreen;
    var
      MonoAddress:  char absolute $B000:0000;
      ColorAddress: char absolute $B800:0000;
      begin
        if lastmode=mono then
          move(Memory.Screen,monoAddress,8000)
        else
          move(Memory.Screen,colorAddress,8000);
        gotoxy(Memory.StoreX,Memory.StoreY);
      end;
  begin
  end.
