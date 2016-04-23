{Well here's a simple gif decoder for everyone:}

{
GIF Decompressor:
DECGIF.BAS by Rich Geldreich March 1992
DECGIF.PAS translated to Pascal, Paul Hurst 1995
}
 
Uses Crt;
Const
  BufferLength = 18000;

Var
  ByteBuffer: Byte;
  Powers: Array[0..8] Of Integer;
  Prefix: Array[0..4096] Of Integer;
  Suffix: Array[0..4096] Of Integer;
  OutCode: Array[0..1024] Of Integer;
  MaxCodes: Array[0..12] Of Integer;
  Powers2: Array[0..16] Of Integer;
  CodeMask: Array[0..8] Of Integer;
  Buffer: Array[1..BufferLength] Of Byte;
  Numread: Word;
  Red, Green, Blue: Byte;
  a,b,c: Integer;
  s, Fn: String;
  f: File;
  BackGround: Byte;
  XEnd, YEnd, TotalX, TotalY, BitsPixel, XStart, YStart, XLength, YLength,
  CodeSize, ClearCode,EOFCode, FirstFree, InitCodeSize,MaxCode,BitMask,
  FreeCode, BlockLength, BitsIn, BytesLeft, Num, OutCount, X, Y, Code,
  Address,Aa, TempChar, CurCode, OldCode, FinChar, InCode
  : Integer;
Procedure OM; Begin TextMode(LastMode);  End;
 
Function Ex(base, ras: LongInt): LongInt;
Var i,t : LongInt;
Begin
  if (ras = 0) then begin Ex := 1; Exit; End;
  if ras = 1 then begin Ex := Base; Exit; End;
  t := base;
  For i := 1 To ras-1 Do t := t * base;
  ex := t;
End;
Procedure ErrSound;
Begin
  Sound(500); Delay(10); NoSound;
End;
Begin
  For A := 0 To 7 Do Powers[a+1] := Ex(2, a);
  clrscr;
   B := 4; For A := 0 to 11 do begin  MaxCodes[A] := B;  B:=B*2; end;
  b := 1; c := 2;
  for A := 1 to 8 do begin  CodeMask[a] := B;  B:=B+c;  C:=C*2; end;
  B := 1;
  For A := 0 to 14 do begin  Powers2[A] := B;  B:=B*2; end;
 
  WriteLn('SHOWGIF.PAS, Basic version by Rich Geldreich, Translated to TP by
Paul Hurst');  Write('filename: '); ReadLn(fn);
  Assign(F, fn); Reset(F,1);

  s := '';
  For a:= 1 To 6 Do Begin BlockRead(f,bytebuffer,SizeOf(bytebuffer));
    s := s + Chr(bytebuffer);
  End;
  If s <> 'GIF87a' Then Begin WriteLn('Sorry format not accepted!'); Halt;
End;  BlockRead(F, TotalX, SizeOf(TotalX));
  BlockRead(F, TotalY, SizeOf(TotalY));
 
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  BitsPixel := (ByteBuffer And 7) + 1;
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  BackGround := ByteBuffer;
  BlockRead(f, ByteBuffer, SizeOf(ByteBuffer));
  If ByteBuffer <> 0 Then Begin OM; WriteLn('Error!1'); ErrSound;  Halt; End;
  Asm Mov AX, 13h; Int 10h; End;
  For A := 0 To Ex(2, BitsPixel) - 1 Do Begin
    BlockRead(F, Red, SizeOf(Red));
    BlockRead(F, Green, SizeOf(Green));
    BlockRead(F, Blue, SizeOf(Blue));
    Port[$3c7] := A;  Port[$3c8] := A;
    Port[$3c9] := Red Div 4;
    Port[$3c9] := Green Div 4;
    Port[$3c9] := Blue Div 4;
  End;
  {line(0,0)-(319,199),0,background}
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  If ByteBuffer <> Ord(',') Then Begin OM; WriteLn('Error!2'); ErrSound; Halt;
End;  BlockRead(F,XStart, SizeOf(XStart));
  BlockRead(F,YStart, SizeOf(YStart));
  BlockRead(F,XLength, SizeOf(XLength));
  BlockRead(F,YLength, SizeOf(YLength));
  XEnd := XLength + XStart - 1; YEnd := YLength + YStart - 1;
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  If ((ByteBuffer And 128) = 128) Or ((ByteBuffer And 64) = 64) Then Begin
    OM; WriteLn('Error!3'); ErrSound; Halt;
  End;
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  CodeSize := ByteBuffer;
  ClearCode := Powers2[CodeSize];
  EOFCode := ClearCode + 1; FirstFree := ClearCode + 2;
  FreeCode := FirstFree; CodeSize := CodeSize + 1;
  InitCodeSize := COdeSize; MaxCode := MaxCodes[CodeSize - 2];
  BitMask := CodeMask[BitsPixel];
  BlockRead(F, ByteBuffer, SizeOf(ByteBuffer));
  BlockLength := ByteBuffer + 1;
  BitsIn := 8; BytesLeft := 0; Num := 0;
  OutCount := 0;
  X := XStart; Y := YStart;
  Repeat
    Code := 0;
    For Aa := 0 To CodeSize - 1 Do Begin
      BitsIn := BItsIn + 1;
      If BitsIn = 9 Then Begin
        BytesLeft := BytesLeft - 1;
        If BytesLeft <= 0 Then Begin
          BlockRead(F, Buffer, SizeOf(Buffer), numread);
          BytesLeft := BufferLength;
          Address := 0;
        End;
        Address := Address + 1;
        TempChar := Buffer[Address];
        BitsIn := 1;
        Num := Num + 1;
        If Num = BlockLength Then Begin
          BytesLeft := BytesLeft - 1;
          If BytesLeft <= 0 Then Begin
            BlockRead(F, Buffer, SizeOf(Buffer), numread);
            Address := 0;
            BytesLeft := BufferLength;
          End;
          BlockLength := TempChar + 1;
          Address := Address + 1;
          TempChar := Buffer[Address];
          Num := 1;
        End;
      End;
      If (TempChar And Powers[BitsIn]) > 0 Then Code := Code + Powers2[Aa];
    End;  {next}
 

    If Code <> EOFCode Then Begin
      If Code = ClearCode Then Begin
        CodeSize := InitCodeSize;
        MaxCode := MaxCodes[CodeSize - 2];
        FreeCode := FirstFree;
        Code := 0;
        For Aa := 0 To CodeSize - 1 Do Begin
          BitsIn := BitsIn + 1;
          If BitsIn = 9 Then Begin
            BytesLeft := BytesLeft - 1;
            If BytesLeft <= 0 Then Begin
              BlockRead(F, Buffer, SizeOf(Buffer),numread);
              Address := 0;
              BytesLeft := BufferLength;
            End;
            Address := Address + 1;
            TempChar := Buffer[Address];
            BitsIn := 1;
            Num := Num + 1;
            If Num = BlockLength Then Begin
              BytesLeft := BytesLeft - 1;
              If BytesLeft <= 0 Then Begin
                BlockRead(F, Buffer, SizeOf(Buffer),numread);
                Address := 0;
                BytesLeft := BufferLength;
              End;
              BlockLength := TempChar + 1;
              Address := Address + 1;
              TempChar := Buffer[Address];
              Num := 1;
            End;
          End;
          If (TempChar And Powers[BitsIn]) > 0 Then begin
            Code := Code + Powers2[Aa];
        End;
      End; {next}
      CurCode := Code;
      OldCode := Code;
      FinChar := Code And BitMask;
      Mem[$A000:Y*320 + X] := FinChar; X := X + 1;
      If X > XEnd Then Begin X := XStart; Y := Y + 1; End;
    End
    Else Begin
      CurCode := Code;
      InCode := Code;
      If Code >= FreeCode Then Begin
        CurCode := OldCode;
        OutCode[OutCount] := FinChar;
        OutCount := OutCount + 1;
      End;
      If CurCode > BitMask Then Begin
        Repeat
          OutCode[OutCount] := Suffix[CurCode];
          OutCount := OutCount + 1; CurCode := PreFix[CurCode];
        Until CurCode <= BitMask;
      End;
 
      FinChar := CurCode And BitMask;
      OutCode[OutCount] := FinChar;
      OutCount := OutCount + 1;
      For A := OutCount - 1 DownTo 0 Do Begin
        Mem[$A000:Y*320+X] := OutCode[A];
        X := X + 1;
        If X > XEnd Then Begin X := XStart; Y := Y + 1; End;
      End;
      OutCount := 0;
      PreFix[FreeCode] := OldCode;
      Suffix[FreeCode] := FinChar;
      OldCode := InCode;
      FreeCode := FreeCode + 1;
      If (FreeCode >= MaxCode) And (CodeSize < 12) Then Begin
        Codesize := CodeSize + 1;
        MaxCode := MaxCode + MaxCode {*2}
      End;
    End;
    End;
  Until Code = EOFCode;
  Close(F);
  Sound(1500); Delay(1); NoSound;
  ReadKey;
  OM;
End.

It works and is fairly fast. only does 320x200 non interlaced, no local color
map. Hope you enjoy...  If anyone makes this better could ya post it for
everyone (and me) :)
