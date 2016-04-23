Uses Crt;

Type

   BufferType = Array[0..3999] of Byte; { screen size      }
   PtrBufferType = ^BufferType;         { For dynamic use  }

Var
  Screen: BufferType Absolute $B800:$0; { direct access to }
                                        { Text screen      }

Function CharS(Len:Byte; C: Char): String;
Var
  S: String;
begin                       { This Function returns a String of }
  FillChar(S, Len+1, C);    { Length Len and of Chars C.        }
  S[0] := Chr(Len);
  CharS := S;
end;

Function Center(X1, X2: Byte; S: String): Byte;
Var
  L, Max: Integer;
begin                           { This Function is used to center     }
  Max := (X2 - (X1-1)) div 2;   { a String between two X coordinates. }
  L := Length(S);
  if Odd(L) then Inc(L);
  Center := X1 + (Max - (L div 2));
end;


Procedure DrawBox(X1, Y1, X2, Y2: Integer; Attr: Byte; Title: String);
Var
  L, Y, X: Integer;
  S: String;

begin
  X := X2 - (X1-1);      { find box width  }
  Y := Y2 - (Y1-1);      { find box height }
  { draw box }
  S := Concat('╔', CharS(X-2, '═'), '╗');
  GotoXY(X1, Y1);
  TextAttr := Attr;
  Write(S);
  Title := Concat('╡ ', Title,' ╞');
  GotoXY(Center(X1, X2, Title), Y1);
  Write(Title);
  For L := 2 to (Y-1) do
    begin
      GotoXY(X1, Y1+L-1);
      Write('║', CharS(X-2, ' '), '║');
    end;
  GotoXY(X1, Y2);
   Write('╚', CharS(X-2, '═'), '╝');

end;

Procedure SaveBox(X1, Y1, X2, Y2: Integer; Var BufPtr: PtrBufferType);
Var
  Poff, Soff, Y, XW, YW, Size: Integer;

begin
  XW := X2 - (X1 -1);   { find box width  }
  YW := Y2 - (Y1 -1);   { find box height }
  Size := (XW*2 ) * YW; { size needed to store background }
  GetMem(BufPtr, Size); { allocate memory to buffer }
  For Y := 1 to YW do   { copy line by line to buffer }
    begin
      Soff := (((Y1-1) + (Y-1)) * 160) + ((X1-1)*2);
      Poff := ((XW * 2) * (Y-1));
      Move(Screen[Soff], BufPtr^[Poff], (XW * 2)); { Write to buffer }
    end;
end;

(*************** end of PART 1 of 2. *****************************)
(****** PART 2 of 2 ********************************)
Procedure RestoreBox(X1, Y1, X2, Y2: Integer; Var BufPtr: PtrBufferType);
Var
  Poff, Soff, X, Y, XW, YW, Size: Integer;
  F: File;

begin
  XW := X2 - (X1-1); { once again...find box width }
  YW := Y2 - (Y1-1); { find height }
  Size := (XW *2) * YW; { memory size to deallocate from buffer }
  For Y := 1 to YW do   { move back, line by line }
    begin
      Soff := (( (Y1-1) + (Y-1)) * 160) + ((X1-1)*2);
      Poff := ((XW*2) * (Y-1));
      Move(BufPtr^[Poff], Screen[Soff],  (XW*2));
    end;
  FreeMem(BufPtr, Size);
end;


Procedure Shadow(X1, Y1, X2, Y2: Byte);
Var
  Equip: Byte Absolute $40:$10;
  Vert, Height, offset: Integer;

begin
  if (Equip and 48) = 48 then Exit;

  For Vert := (Y1+1) to (Y2+1) do
    For Height := (X2+1) to (X2+2) do
      begin
        offset := (Vert - 1) * 160 + (Height-1) * 2 + 1;
        Screen[offset] := 8;
      end;
  Vert := Y2 + 1;
  For Height := (X1+2) to (X2+2) do
    begin
      offset := (Vert-1) * 160 + (Height-1) * 2 + 1;
      Screen[offset] := 8;
    end;
end;

Procedure Hello;
Var
  BufPtr: PtrBufferType;
begin
  { note, that if you use shadow, save an xtra 2 columns
    and 1 line to accomadate what Shadow does }
   {             V   V   }
  SaveBox(7, 7, 73, 15, BufPtr);
  DrawBox(7, 7, 71, 13, $4F, 'Hello');
  Shadow(7, 7, 71, 13);
  GotoXY(9, 9);
  Write('Hello Terry! I hope this is what you were asking For.');
  GotoXY(9, 11);
  Write('Press Enter');
  While ReadKey <> #13 do;
  RestoreBox(7, 7, 73, 14, BufPtr);
end;

Procedure Disclaimer;
Var
  BufPtr: PtrBufferType;
begin
  SaveBox(5, 5, 77, 21, BufPtr);
  DrawBox(5, 5, 75, 20, $1F, 'DISCLAIMER');
  Shadow(5, 5, 75, 20);
  Window(7, 7, 73, 19);
  Writeln('  Seeing as I came up With these Procedures For');
  Writeln('my own future Programs (I just recently wrote these)');
  Writeln('please don''t Forget who wrote them originally if you');
  Writeln('decide to use them in your own.  Maybe a ''thanks to Eric Miller');
  Writeln('For Window routines'' somewhere in your doCs?');
  Writeln;
  Writeln('  Also, if anyone can streamline this source, well, I''d');
  Writeln('I''d like to see it...not that too much can be done.');
  Writeln;
  Writeln('                    Eric Miller');
  Window(1,1,80,25);
  Hello;
  TextAttr := $1F;
  GotoXY(9, 18);
  Writeln('Press Enter...');
  While ReadKey <> #13 do;
  RestoreBox(5, 5, 77, 21, BufPtr);
end;

begin
  TextAttr := $3F;
  ClrScr;
  Disclaimer;
end.
(***** end of PART 1 of 2 ******************************)
