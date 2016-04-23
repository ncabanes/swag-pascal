{
>It's just a Fileviewer, I'm working on. I just want to be able to
>scroll the File up, down, etc.
}

Program ScrollDemo;
Uses
  Crt;
Type
  UpDown = (Up, Down);
  { Scroll Text screen up or down. }

Procedure Scroll({input } Direction : UpDown;
                          Lines2Scroll,
                          Rowtop,
                          RowBot,
                          ColStart,
                          ColStop,
                          FillAttr : Byte);
begin
  if (Direction = Up) then
  Asm
    mov ah, 06h
    mov al, Lines2Scroll
    mov bh, FillAttr
    mov ch, Rowtop
    mov cl, ColStart
    mov dh, RowBot
    mov dl, ColStop
    int 10h
  end
  else
  Asm
    mov ah, 07h
    mov al, Lines2Scroll
    mov bh, FillAttr
    mov ch, Rowtop
    mov cl, ColStart
    mov dh, RowBot
    mov dl, ColStop
    int 10h
  end
end; { Scroll }

{ Pause For a key press. }
Procedure Pause;
Var
  chTemp : Char;
begin
  While KeyPressed do
    chTemp := ReadKey;
  Repeat Until(KeyPressed)
end; { Pause }

Var
  Index : Byte;
  stTemp : String[80];
begin
  ClrScr;
  { Display 24 lines of Text. }
  For Index := 1 to 24 do
    begin
      stTemp[0] := #80;
      fillChar(stTemp[1], length(stTemp), (Index + 64));
      Write(stTemp)
    end;
  { Pause For a key press. }
  Pause;
  { Scroll Text down by 1 line. Use the Crt's Textattr }
  { Variable as the Text color to fill with. }
  Scroll(Down, 1, 0, 24, 0, 79, Textattr);
  { Pause For a key press. }
  Pause;
  { Scroll Text up by 1 line. Use the Crt's Textattr }
  { Variable as the Text color to fill with. }
  Scroll(Up, 1, 0, 24, 0, 79, Textattr);
  { Pause For a key press. }
  Pause
end.
