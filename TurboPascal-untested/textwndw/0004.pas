{
>   Okay...it works fine, but I want to somehow be able to kindo of remove t
> Window.  I'm not sure if there is any way of doing this?

You need to save the screen data at the location you wish to make
a Window, then after you're done With the Window simply restore
the screen data back to what it was.  Here's some example
routines of what you can do, you must call InitWindows once at
the begining of the Program before using the OpenWindow
Procedure, then CloseWindow to restore the screen.
}

Uses
  Crt;

Type
  ShadeType = (Shading, NoShading);
  ScreenBlock = Array [1..2000] of Integer;
  ScreenLine  = Array [1..80] of Word;
  ScreenArray = Array [1..25] of ScreenLine;
  WindowLink  = ^WindowControlBlock;
  WindowControlBlock = Record
    X,Y      : Byte;          { start position }
    Hight    : Byte;          { Menu Hight     }
    Width    : Byte;          { Menu width     }
    ID       : Byte;          { Menu number    }
    BackLink : WindowLink;    { previous block }
    MenuItem : Byte;          { select item    }
    ScreenData : ScreenBlock; { saved screen data }
  end;
  String30 = String[30];
  ScreenPtr = ^ScreenRec;
  ScreenRec = Array [1..25,1..80] of Integer;


Var
  Screen       : ScreenPtr;
  ActiveWindow : Pointer;

Procedure InitWindows;
begin
  If LastMode = Mono Then
    Screen := Ptr($B000,0)
  Else
    Screen := Ptr($B800,0);
  ActiveWindow := Nil;
end;

Procedure OpenWindow(X, Y, Lines, Columns, FrameColor,
                     ForeGround, BackGround : Byte;
                     Title : String30; Shade : ShadeType);
Var
  A, X1, X2,
  Y1, Y2        : Integer;
  OldAttr       : Integer;
  WindowSize    : Integer;
  Block         : WindowLink;
begin
  OldAttr := TextAttr;

  WindowSize := (Lines + 3) * (Columns + 5) * 2 +
                 Sizeof(WindowControlBlock) - Sizeof(ScreenBlock);

  If MemAvail < WindowSize Then
  begin
    WriteLn;WriteLn('Program out of memory');
    Halt;
  end;

  GetMem(Block,WindowSize);
  Block^.X := X - 2;
  Block^.Y := Y - 1;
  Block^.Hight := Lines + 3;
  Block^.Width := Columns + 5;
  Block^.BackLink := ActiveWindow;

  ActiveWindow := Block;
  A := 1;
  For Y1 := Block^.Y to Block^.Y+Block^.Hight-1 Do
  begin
    Move(Screen^[Y1, Block^.X], Block^.ScreenData[A], Block^.Width * 2);
    A := A + Block^.Width;
  end;

  TextColor(FrameColor);
  If BackGround = Black Then
    TextBackGround(LightGray)    { This will keep exploding Window visable }
  Else
    TextBackground(BackGround);

  X1 := X + Columns Div 2;
  X2 := X1 + 1;
  Y1 := Y + Lines Div 2;
  Y2 := Y1 + 1;

  Repeat
    Window(X1, Y1, X2, Y2);
    ClrScr;
    If Columns < 20 Then
      Delay(20);
    If X1 > X Then
      Dec(X1);
    If X2 < X + Columns Then
      Inc(X2);
    If Y1 > Y Then
      Dec(Y1);
    If Y2 < Y + Lines Then
      Inc(Y2);
  Until (X2 - X1 >= Columns ) And (Y2 - Y1 >= Lines);

  Window(X - 1, Y, X + Columns, Y + Lines);
  TextBackground(BackGround);
  ClrScr;
  TextColor(FrameColor);
  Window(1, 1, 80, 24);
  GotoXY(X - 2, Y - 1);
  Write('┌');
  For A := 1 to Columns + 2 Do
    Write('─');

  Write('┐');
  For A := 1 to Lines Do
  begin
    GotoXY(X - 2, Y + A - 1);
    Write('│');
    GotoXY(X + Columns + 1, Y + A - 1);
    Write('│');
  end;
  GotoXY(X - 2, Y + Lines);
  Write('└');
  For A := 1 to Columns + 2 Do
    Write('─');
  Write('┘');
  If Shade = Shading Then
  begin
    For A := Y to Y + Lines + 1 Do
      Screen^[A, X + Columns + 2] := Screen^[A, X + Columns + 2] And $07FF;
    For A := X - 1 to X + Columns + 1 Do
      Screen^[Y + Lines + 1, A] := Screen^[Y + Lines + 1, A] And $07FF;
  end;
  If Title <> '' Then
  begin
    TextColor(FrameColor);
    GotoXY(X + ((Columns - Length(Title)) div 2) - 1, Y - 1);
    Write(' ', Title, ' ');
  end;
  Window(1, 1, 80, 24);
end;

Procedure CloseWindow;
Var
  Block   : WindowLink;
  A       : Integer;
  Y1      : Integer;
  WindowSize : Integer;
begin
  If ActiveWindow = Nil Then
    Exit;
  Block := ActiveWindow;
  WindowSize := (Block^.Hight) * (Block^.Width) * 2 +
                 Sizeof(WindowControlBlock) - Sizeof(ScreenBlock);
  A := 1;
  For Y1 := Block^.Y to Block^.Y+Block^.Hight - 1 Do
    begin
    Move(Block^.ScreenData[A], Screen^[Y1, Block^.X], Block^.Width * 2);
    A := A + Block^.Width;
    end;
  ActiveWindow := Block^.BackLink;
  FreeMem(Block, WindowSize);
end;

begin
  InitWindows;
  OpenWindow(10, 5, 10, 50, LightGreen, LightBlue, Magenta,
                     'Test Window', Shading);
  ReadKey;
  OpenWindow(20, 6, 6, 30, Green, Yellow, Blue,
                     'Test Window 2', Shading);
  ReadKey;
  CloseWindow;
  ReadKey;
  CloseWindow;
  ReadKey;
  GotoXY(1,24);

end.
