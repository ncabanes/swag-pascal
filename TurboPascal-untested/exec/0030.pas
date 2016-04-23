{
  This code is provided as is, without guarrantees or support of any kind. 
  We have two programs, one of which launches another, and passes
  shared data to it. You can place anything in that shared data,
  including instructions on when to launch a third or fourth program. 
  The shared data could be of virtually any size, the record we
  chose here was picked more or less at random.
}
{$M 1024, 0, 0}
{$R+,S+}
program Home;
Uses
  Dos,
  SharInfo;

Const
  SD: TData =
    (S: 'Hi, this message came from Home.Exe.';
    I: 42);

var
  AddrStr: String[11];
  Temp: String[5];

  procedure HandleInput;
  var
    vSeg, vOfs, Code: Word;
    PData: ^TData;
  begin
    Val(ParamStr(1), vSeg, Code);
    Val(ParamStr(2), vOfs, Code);
    PData := Ptr(vSeg, vOfs);
    WriteLn('Home hears: ', PData^.S);
    WriteLn('The magic number is: ', PData^.I);
  end;

begin
  FillChar(AddrStr[1], 11, #32);
  Str(Seg(SD), AddrStr);
  Str(Ofs(SD), Temp);
  Move(Temp[1], AddrStr[length(AddrStr) + 2], length(Temp));
  Inc(AddrStr[0], succ(length(temp)));
  WriteLn('===============');
  WriteLn('Execing Visitor');
  WriteLn('===============');
  Swapvectors;
  Exec('Visitor.Exe', AddrStr);
  Swapvectors;
  WriteLn('==========================');
  WriteLn('We have returned to home. ');
  WriteLn('==========================');
  WriteLn;
  WriteLn('Home Says: ', SD.S);
  WriteLn('Here''s a number visitor gave us: ', SD.I);
end.

{======================}
{$M 2024, 0, 2000}
{$S+,R+}
program Visitor;
Uses
  Dos,
  SharInfo;

var
  vSeg, vOfs, Code: Word;
  PData: ^TData;

  procedure ReportError;
  begin
    WriteLn('This program is a subprogram of Home');
    Halt(1);
  end;

  procedure SendDataBack;
  var
    AddrStr: String[11];
    Temp: String[5];
    SD: TData;
  begin
    SD.S := 'Hi, this message came from Visitor.Exe.';
    SD.I := 42;
    FillChar(AddrStr[1], 11, #32);
    Str(Seg(SD), AddrStr);
    Str(Ofs(SD), Temp);
    Move(Temp[1], AddrStr[length(AddrStr) + 2], length(Temp));
    Inc(AddrStr[0], succ(length(temp)));
    Exec('Home.Exe', AddrStr);
  end;

begin
  if ParamCount <> 2 then ReportError;
  Val(ParamStr(1), vSeg, Code);
  if Code <> 0 then ReportError;
  Val(ParamStr(2), vOfs, Code);
  if Code <> 0 then ReportError;
  PData := Ptr(vSeg, vOfs);
  WriteLn;
  WriteLn('Visitor hears: ', PData^.S);
  WriteLn;
  PData^.S := 'This is a message from visitor. ';
  PData^.i := 231;
  {SendDataBack;}
end.

{======================}

Unit SharInfo;
{
  Here 's the data being shared between the two programs. 
  I've declared a record with a string and an integer, but
  it wouldn't matter what the contents of this record 
  happened to be. The fields could be of virtually any type
  and could contain any type of data.
}
Interface
Type
  TData = Record
    S: String;
    I: Integer;
  end;
Implementation
end.