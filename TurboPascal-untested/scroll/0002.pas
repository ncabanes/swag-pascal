Program Scroll;
Uses
  Crt, Dos;
Const
  Null       = #0;
  UpArrow    = #72;
  LeftArrow  = #75;
  RightArrow = #77;
  DownArrow  = #80;
  PageUp     = #73;
  PageDown   = #81;
  ESC        = #27;

Type
  StrPtr = ^LineBuffer;

  LineBuffer = Record
    Line   : String[255];
    Next   : StrPtr;
    Prev   : StrPtr;
    Up23   : StrPtr;
    Down23 : StrPtr;
  end;
Var
  F       : Text;
  First,
  Last,
  Prev,
  Current : StrPtr;
  Line    : Byte;
  Row     : Byte;

Function PadString( S : String ) : String;
Var
  X : Byte;
begin
  if ord(S[0]) > 79 then S[0]:=Chr(80);
  For X := (Length(S) + 1) to 79 Do
    S[X] := ' ';
  S[0] := Chr(79);
  PadString := S;
end;

Procedure Normal;
begin
  TextColor(15);
  TextBackGround(0);
end;

Procedure HighLite;
begin
  TextColor(10);
  TextBackGround(7);
end;

Procedure AddString;
Var
  S : String;

begin
  if First = Nil then
  begin
    Line := 1;
    New(Current);
    Current^.Prev   := Nil;
    Current^.Next   := Nil;
    Current^.Up23   := Nil;
    Current^.Down23 := Nil;
    ReadLn(F, S);
    Current^.Line   := S;
    Last  := Current;
    First := Current;
  end
  else
  begin
    Prev := Current;
    New(Current);
    Current^.Prev:=Prev;
    Current^.Next:=Nil;
    ReadLn(F,Current^.Line);
    if Line = 23 then
    begin
      Current^.Up23 := First;
      First^.Down23 := Current;
      Current^.Down23:= Nil;
    end
    else
    begin
      if Line > 23 then
      begin
        Current^.Up23 := Prev^.Up23^.Next;
        Current^.Up23^.Down23 := Current;
        Current^.Down23:=Nil;
      end
      else
      begin
        Current^.Up23:=Nil;
        Current^.Down23:=Nil;
      end;
    end;
    Prev^.Next:=Current;
    Last:=Current;
    if Line<=60 then
      Line:=Line + 1;
  end;
end;

Procedure DrawScreen( This : StrPtr);
Var
  TRow : Byte;
begin
  TRow:=1;
  While TRow<=23 Do
   begin
     GotoXY(1,TRow);
     Write(PadString(This^.Line));
     This:=This^.Next;
     TRow:=TRow + 1;
   end;
end;

Procedure Scrolling;
Var
  InKey : Char;
begin
  While (MemAvail>272) and (not Eof(F)) Do AddString;
  if not Eof(F) then
   begin
     GotoXY(1,1);
     TextColor(10);
     Write('Entire File not Loaded');
   end;
  Current:=First;
  Window(1,1,1,79);
  ClrScr;
  HighLite;
  GotoXY(1,1);
  Write(PadString(ParamStr(1)));
  Window(2,1,24,80);
  Normal;
  DrawScreen(First);
  Row:=1;
  Window(2,1,25,80);
  While InKey<>#27 Do
  begin
    InKey:=ReadKey;
    Case InKey of
      Null :
      begin
        InKey:=ReadKey;
        Case InKey of
          UpArrow :
          begin
            if Current^.Prev = Nil then
            begin
              Sound(2000);
              Delay(50);
              NoSound;
            end
            else
            begin
              if Row = 1 then
              begin
                GotoXY(1,1);
                Normal;
                Write(PadString(Current^.Line));
                GotoXY(1,1);
                InsLine;
                Current:=Current^.Prev;
                HighLite;
                Write(PadString(Current^.Line));
              end
              else
              begin
                GotoXY(1,Row);
                Normal;
                Write(PadString(Current^.Line));
                Row:=Row - 1;
                GotoXY(1,Row);
                HighLite;
                Current:=Current^.Prev;
                Write(PadString(Current^.Line));
              end;
            end;
          end;

          DownArrow :
          begin
            if Current^.Next = Nil then
            begin
              Sound(2000);
              Delay(50);
              NoSound;
            end
            else
            begin
              if Row = 23 then
              begin
                GotoXY(1,23);
                Normal;
                Write(PadString(Current^.Line));
                GotoXY(1,1);
                DelLine;
                GotoXY(1,23);
                Current:=Current^.Next;
                HighLite;
                Write(PadString(Current^.Line));
              end
              else
              begin
                GotoXY(1,Row);
                Normal;
                Write(PadString(Current^.Line));
                Row:=Row + 1;
                GotoXY(1,Row);
                HighLite;
                Current:=Current^.Next;
                Write(PadString(Current^.Line));
              end;
            end;
          end;

          PageDown :
           begin
            if (Row = 23) and (Current = Last) then
            begin
              Sound(2000);
              Delay(50);
              NoSound;
            end
            else
            begin
              Normal;
              if Current^.Down23 = Nil then
              begin
                Current:=Last;
                DrawScreen(Last^.Up23);
                Row:=23;
                GotoXY(1,Row);
                HighLite;
                Write(PadString(Current^.Line));
              end
              else
              begin
                Current:=Current^.Down23^.Next;
                DrawScreen(Current^.Up23);
                Row:=23;
                GotoXY(1,Row);
                HighLite;
                Write(PadString(Current^.Line));
              end;
            end;
          end;

          PageUp :
          begin
            if (Row = 23) and (Current^.Up23 = Last) then
            begin
              Sound(2000);
              Delay(50);
              NoSound;
            end
            else
            begin
              Normal;
              if Current^.Up23 = Nil then
              begin
                Current:=First;
                DrawScreen(First);
                Row:=1;
                GotoXY(1,Row);
                HighLite;
                Write(PadString(First^.Line));
              end
              else
              begin
                Current:=Current^.Up23^.Prev;
                DrawScreen(Current);
                Row:=1;
                GotoXY(1,Row);
                HighLite;
                Write(PadString(Current^.Line));
              end;
            end;
          end;
        else
        begin
          Sound(2000);
          Delay(50);
          NoSound;
        end;

        end;
      end;

    else
    begin
      Sound(2000);
      Delay(50);
      NoSound;
    end;

    end;
  end;
end;

begin
  if ParamCount < 1 then
  begin
    WriteLn('Invalid Number of Parameters!!!');
    Halt(1);
  end;
  Assign(F, Paramstr(1));
  Reset(F);
  Current:=Nil;
  First:=Nil;
  Scrolling;
  GotoXY(1, 23);
  WriteLn;
  WriteLn;
end.

