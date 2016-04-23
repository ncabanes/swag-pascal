{$A+,B-,D-,E+,F-,I+,L-,N-,O-,R+,S-,V-}
{$M 4048,65536,655360}

Program ReadText;

{ Author Trevor J Carlsen - released into the public domain 1991         }
{        PO Box 568                                                      }
{        Port Hedland                                                    }
{        Western Australia 6721                                          }
{        Voice +61 91 73 2026  Data +61 91 73 2569                       }
{        FidoNet 3:690/644                                               }

{ This example Programs displays a Text File using simple Word wrap. The }
{ cursor keys are used to page Forward or backwards by page or by line.  }
{ The Program makes some important assumptions.  The main one is that no }
{ line in the File will ever exceed 255 Characters in length.  to get    }
{ around this restriction the ReadTxtLine Function would need to be      }
{ rewritten.                                                             }

{ The other major restriction is that Files exceeding a size able to be  }
{ totally placed in RAM cannot be viewed.                                }

{$DEFinE TurboPower (Remove the period if you have Turbo Power's TPro)  }

Uses
  {$ifDEF TurboPower }
  tpCrt,
  colordef;
  {$else}
  Crt;
  {$endif}

Const
  {$ifNDEF TurboPower }
  BlackOnLtGray = $70;      LtGrayOnBlue = $17;
  {$endif}
  LineLength    = 79;       MaxLines     = 6000;
  ScreenLines   = 22;       escape       = $011b;
  Home          = $4700;    _end         = $4f00;
  upArrow       = $4800;    downArrow    = $5000;
  PageUp        = $4900;    PageDown     = $5100;

Type
  LineStr    = String[Linelength];
  StrPtr     = ^LineStr;

Var
  TxtFile    : Text;
  Lines      : Array[1..MaxLines] of StrPtr;
  NumberLines: 1..MaxLines+1;
  CurrentLine: 1..MaxLines+1-ScreenLines;
  st         : String;
  finished   : Boolean;
  OldExitProc: Pointer;
  TxtBuffer  : Array[0..16383] of Byte;
  OldAttr    : Byte;

Function LastPos(ch : Char; S : String): Byte;
  { Returns the last position of ch in S or zero if ch not in S }
  Var
    x   : Word;
    len : Byte Absolute S;
  begin
    x := succ(len);
    Repeat
      dec(x);
    Until (x = 0) or (S[x] = ch);
    LastPos := x;
  end;  { LastPos }

Function Wrap(Var S,CarryOver: String): String;
  { Returns a String of maximum length Linelength from S. Any additional }
  { Characters remaining are placed into CarryOver.                      }
  Const
    space = #32;
  Var
    temp      : String;
    LastSpace : Byte;
    len       : Byte Absolute S;
  begin
    FillChar(temp,sizeof(temp),32);
    temp := S; CarryOver := ''; wrap := temp;
    if length(temp) > LineLength then begin
      LastSpace := LastPos(space,copy(temp,1,LineLength+1));
      if LastSpace <> 0 then begin
        Wrap[0]   := chr(LastSpace - 1);
        CarryOver := copy(temp,LastSpace + 1, 255)
      end  { if LastSpace... }
      else begin
        Wrap[0]   := chr(len);
        CarryOver := copy(temp,len,255);
      end; { else }
    end; { if (length(S))...}
  end;  { Wrap }

Function ReadTxtLine(Var f: Text; L: Byte): String;
  Var
    temp : String;
    len  : Byte Absolute temp;
    done : Boolean;
  begin
    len := 0; done := False;
    {$I-}
    While not eoln(f) do begin
      read(f,temp);
      if Ioresult <> 0 then begin
        Writeln('Error reading File - aborted');
        halt;
      end;
    end; { While }
    if eoln(f) then readln(f);
    ReadTxtLine := st + Wrap(temp,st);
    finished := eof(f);
  end;  { ReadTxtLine }

Procedure ReadTxtFile(Var f: Text);
  Var
    x : Word;
  begin
    st          := '';
    NumberLines := 1;
    Repeat
      if NumberLines > MaxLines then begin
        Writeln('File too big');
        halt;
      end;
      if (MaxAvail >= Sizeof(LineStr)) then
        new(Lines[NumberLines])
      else begin
        Writeln('Insufficient memory');
        halt;
      end;
      FillChar(Lines[NumberLines]^,LineLength+1,32);
      if length(st) > LineLength then
        Lines[NumberLines]^  := wrap(st,st)
      else if length(st) <> 0 then begin
        Lines[NumberLines]^  := st;
        st := '';
      end else
        Lines[NumberLines]^  := ReadTxtLine(f,LineLength+1);
      Lines[NumberLines]^[0] := chr(LineLength);
      if not finished then
        inc(NumberLines);
    Until finished;
  end;  { ReadTxtFile }

Procedure DisplayScreen(line: Word);
  Var
    x : Byte;
  begin
    GotoXY(1,1);
    For x := 1 to ScreenLines - 1 do
      Writeln(Lines[x-1+line]^);
    Write(Lines[x+line]^)
  end;

Procedure PreviousPage;
  begin
    if CurrentLine > ScreenLines then
      dec(CurrentLine,ScreenLines-1)
    else
      CurrentLine := 1;
  end;  { PreviousPage }

Procedure NextPage;
  begin
    if CurrentLine < (succ(NumberLines) - ScreenLines * 2) then
      inc(CurrentLine,ScreenLines-1)
    else
      CurrentLine := succ(NumberLines) - ScreenLines;
  end;   { NextPage }

Procedure PreviousLine;
  begin
    if CurrentLine > 1 then
      dec(CurrentLine)
    else
      CurrentLine := 1;
  end;  { PreviousLine }

Procedure NextLine;
  begin
    if CurrentLine < (succ(NumberLines) - ScreenLines) then
      inc(CurrentLine)
    else
      CurrentLine := succ(NumberLines) - ScreenLines;
  end; { NextLine }

Procedure StartofFile;
  begin
    CurrentLine := 1;
  end; { StartofFile }

Procedure endofFile;
  begin
    CurrentLine := succ(NumberLines) - ScreenLines;
  end;  { endofFile }

Procedure DisplayFile;

  Function KeyWord : Word; Assembler;
    Asm
      mov  ah,0
      int  16h
    end;

  begin
    DisplayScreen(CurrentLine);
    Repeat
      Case KeyWord of
        PageUp    : PreviousPage;
        PageDown  : NextPage;
        UpArrow   : PreviousLine;
        DownArrow : NextLine;
        Home      : StartofFile;
        _end      : endofFile;
        Escape    : halt;
      end; { Case }
      DisplayScreen(CurrentLine);
    Until False;
  end; { DisplayFile }

Procedure NewExitProc;Far;
  begin
    ExitProc := OldExitProc;
    {$ifDEF TurboPower}
    NormalCursor;
    {$endif}
    Window(1,1,80,25);
    TextAttr := OldAttr;
    ClrScr;
  end;

Procedure Initialise;
  begin
    CurrentLine := 1;
    if ParamCount <> 1 then begin
      Writeln('No File name parameter');
      halt;
    end;
    OldAttr := TextAttr;
    assign(TxtFile,Paramstr(1));
    {$I-}  reset(TxtFile);
    if Ioresult <> 0 then begin
      Writeln('Unable to open ',Paramstr(1));
      halt;
    end;
    SetTextBuf(TxtFile,TxtBuffer);
    Window(1,23,80,25);
    TextAttr := BlackOnCyan;
    ClrScr;
    Writeln('              Next Page = [PageDown]     Previous Page = [PageUp]');
    Writeln('              Next Line = [DownArrow]    Previous Line = [UpArrow]');
    Write('         Start of File = [Home]   end of File = [end]   Quit = [Escape]');
    Window(1,1,80,22);
    TextAttr := LtGrayOnBlue;
    ClrScr;
    {$ifDEF TurboPower}
    HiddenCursor;
    {$endif}
    OldExitProc := ExitProc;
    ExitProc    := @NewExitProc;
  end;

begin
  Initialise;
  ReadTxtFile(TxtFile);
  DisplayFile;
end.



