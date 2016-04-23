{
this unit implements a text-device that links to a PChar string. When you
want to use a Pascal string, you can patch it, or convert your string to
PChar before using it. An example is included.
From: master@alterdial.uu.net (Nick Vermeulen)
}
Unit StrDev;
(*
    This unit allows string manipulation with standard Read/Write proc's,
    using dataconversion and variable parameter-count as implemented by
    Read/Write proc's.

    example:

    Uses Strings, StrDev;

    Var  f: Text;
         s: Array[0..30] of Char;
         i: Integer;

    Begin
      AssignStrDevice(f, s, SizeOf(s));  { link s to f }
      Rewrite(f);                        { s will be overwritten }
      i := 12;
      Write(f, 'testing', i:12);         { write string + integer to s }
      Close(f);                          { NEEDED! buffer flushes to s }
      WriteLn(s);                        { show result }
      Append(f);                         { demonstrate appending }
      Write(f, 'appending!');            { try to make s smaller! }
      Close(f);
      WriteLn(s);
      StrCopy(s, '1 2 3');               { fill s with data }
      Reset(f);                          { open for reading }
      While not Eof(f) Do
      Begin
        Read(f, i);                      { read integers from s }
        WriteLn(i);
      End;
      Close(f);
    End.
*)

Interface

Uses Strings, Dos;

Procedure AssignStrDevice(var T: Text; aStr: PChar; aSize: Word);

Implementation

Type
  UData = Record          { typecasted over device's UserData (16 bytes) }
            Str  : PChar; { 4 bytes, string to use }
            Size : Word;  { 2 bytes, size of the string }
            p    : PChar; { 4 bytes, current pos in string }
            fill : array[1..6] of byte;
          End;

Function WindowRead(var F: TextRec): Integer; far;
{}
Begin
  With F, UData(UserData) Do
  Begin
    BufEnd := StrEnd(Str)-p;
    If (BufEnd > BufSize) Then
      BufEnd := BufSize;
    BufPos := 0;
    StrLCopy(PChar(BufPtr), p, BufEnd);
    Inc(p, BufEnd);
    WindowRead := 0;
  End;
End;

Function WindowWrite(var F: TextRec): Integer; far;
{}
Begin
  With F, UData(UserData) do
  Begin
    StrLCopy(p, PChar(BufPtr), Size-(p-Str)-1);
    Inc(p, Size-(p-Str)-1);
    BufPos := 0;
  End;
  WindowWrite := 0;
End;

Function WindowOpen(var F: TextRec): Integer; far;
{}
Begin
  WindowOpen := 0;
  With F, UData(UserData) do
  Begin
    Case Mode of
      fmInput:
        Begin
          InOutFunc := @WindowRead;
          FlushFunc := nil;
          p         := Str;
        End;
      fmInOut:
        Begin
          InOutFunc := @WindowWrite;
          FlushFunc := nil;
          Mode      := fmOutput;
          p         := StrEnd(Str);
        End;
      fmOutput:
        Begin
          InOutFunc  := @WindowWrite;
          FlushFunc  := nil;
          p          := Str;
        End;
    End;
  End;
End;

Function WindowClose(var F: TextRec): Integer; far;
{}
Begin
  WindowClose := 0;
End;

Procedure AssignStrDevice(var T: Text; aStr: PChar; aSize: Word);
{}
Begin
  With TextRec(T), UData(UserData) do
  Begin
    Handle := $FFFF;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    Str := aStr;
    Size := aSize;
    OpenFunc := @WindowOpen;
    CloseFunc := @WindowClose;
  End;
End;

End.

