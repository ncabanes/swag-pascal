{
I conceived and made something I find highly useful, hope you do to.. If you
use this in combination with DJ's Streams unit, you can store text files and
that kind of things in your EXE.. On its own, it's great for the usual Config record.
}

Unit ExeS;

INTERFACE

Uses
  Objects;

Type
  PExeStream = ^TExeStream;
  TExeStream = Object(TBufStream)
    Constructor Init(FileName: FNameStr; Mode, Size: Word);
    Procedure Seek(Pos: Longint); Virtual;
    Function GetPos: Longint; Virtual;
    Function GetSize: Longint; Virtual;
  Private
    AddOffset: LongInt;
  End;

Implementation

Constructor TExeStream.Init(FileName: FNameStr; Mode, Size: Word);

  Type
    ExeHdrType = Record
    Signature: Word;
    Rest, Blocks: Word;
  End;

  Var
    ExeFil: File Of ExeHdrType;
    ExeHdr: ExeHdrType;
    ExeLen: LongInt;
    fm: Integer;
  
  Begin
    fm := FileMode;
    FileMode := 64;
    System.Assign(ExeFil, FileName);
    System.Reset(ExeFil);
    System.Read(ExeFil, ExeHdr);
    System.Close(ExeFil);
    FileMode := fm;
    Inherited Init(FileName, Mode, Size);
    AddOffset := (ExeHdr.Blocks - 1) * LongInt(512) + ExeHdr.Rest;
    Seek(0);
  End;

Procedure TExeStream.Seek(Pos: Longint);

  Begin
    Inherited Seek(Pos + AddOffset);
  End;

Function TExeStream.GetPos: Longint;

  Var
    p: LongInt;

  Begin
    p := Inherited GetPos;
    GetPos := p - AddOffset;
  End;

Function TExeStream.GetSize: Longint;

  Var
    s: LongInt;

  Begin
    s := Inherited GetSize;
    GetSize := s - AddOffset;
  End;

End.

{ -------------------   DEMO PROGRAM -----------------------}
Below is a simple example program to show its potential use:

Program TestExeS;

Uses
  ExeS;

Type
  TConfig = Record
    Value1: String;
    Value2: Word;
  End;

Var
  InS: PStream;
  Config: TConfig;

Begin
  InS := New(PExeStream, Init(ParamStr(0), stOpen, 2048));
  If InS = nil Then
    Begin
      Writeln('Something is really wrong!');
      Halt;
    End
  Else If InS^.Status <> stOk Then
    Begin
      Writeln('Something is really wrong!');
      Halt;
    End;
  If InS^.GetSize > 0 Then
    Begin
      InS^.Read(Config, SizeOf(TConfig));
      InS^.Seek(0);
      Writeln('Old config:');
      Writeln('Value 1: ', Config.Value1);
      Writeln('Value 2: ', Config.Value2);
    End
  Else
    Writeln('No config info found.');
  Writeln;
  Write('Enter new value 1: ');
  Readln(Config.Value1);
  Write('Enter new value 2: ');
  Readln(Config.Value2);
  InS^.Write(Config, SizeOf(TConfig));
  Dispose(InS, Done);
End.

