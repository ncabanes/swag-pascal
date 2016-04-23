
Program LZHTest;
Uses
  LZH;

Const
  MaxBuf = 4096;                       { Must be bigger than the biggest chunk being asked For. }

Type
  BufType = Array[1..MaxBuf] of Byte;
  BufPtr = ^BufType;

Var
  InBuf, OutBuf : BufPtr;
  inFile, OutFile : File;
  s : String;
  Bytes_Written : LongInt;
  Size : LongInt;
  Temp : Word;


  {$F+}
  Procedure GetBlock(Var Target; NoBytes : Word; Var Actual_Bytes : Word);
  Const
    Posn : Word = 1;
    Buf : Word = 0;
  Var
    Temp : Word;
  begin
    if (Posn > Buf) or (Posn + NoBytes > succ(Buf)) then
      begin
        if Posn > Buf then
          begin
            blockread(inFile, InBuf^, MaxBuf, Buf);
            Write('+');
          end
        else
          begin
            move(InBuf^[Posn], InBuf^[1], Buf - Posn);
            blockread(inFile, InBuf^[Buf - Posn], MaxBuf - (Buf - Posn), Temp);
            Buf := Buf - Posn + Temp;
            Write('+');
          end;
        if Buf = 0 then
          begin
            Actual_Bytes := 0;
            Writeln;
            Exit;
          end;
        Posn := 1;
      end;
    move(InBuf^[Posn], Target, NoBytes);
    inc(Posn, NoBytes);
    if Posn > succ(Buf) then
      Actual_Bytes := NoBytes - (Posn - succ(Buf))
    else Actual_Bytes := NoBytes;
  end;


  Procedure PutBlock(Var Source; NoBytes : Word; Var Actual_Bytes : Word);
  Const
    Posn : Word = 1;
  Var
    Temp : Word;
  begin
    if NoBytes = 0 then                { Flush condition }
      begin
        blockWrite(OutFile, OutBuf^, pred(Posn), Temp);
        Exit;
      end;
    if (Posn > MaxBuf) or (Posn + NoBytes > succ(MaxBuf)) then
      begin
        blockWrite(OutFile, OutBuf^, pred(Posn), Temp);
        Posn := 1;
      end;
    move(Source, OutBuf^[Posn], NoBytes);
    inc(Posn, NoBytes);
    Actual_Bytes := NoBytes;
  end;

  {$F-}

begin
  if (paramcount <> 3) then
    begin
      Writeln('Usage:lzhuf e(Compression)|d(unCompression) inFile outFile');
      halt(1);
    end;
  s := paramstr(1);
  if not(s[1] in ['D', 'E', 'd', 'e']) then
    halt(1);
  assign(inFile, paramstr(2));
  reset(inFile, 1);
  assign(OutFile, paramstr(3));
  reWrite(OutFile, 1);
  new(InBuf);
  new(OutBuf);
  if (upCase(s[1]) = 'E') then
    begin
      Size := Filesize(inFile);
      blockWrite(OutFile, Size, sizeof(LongInt));
      LZHPack(Bytes_Written, GetBlock, PutBlock);
      PutBlock(Size, 0, Temp);
    end
  else
    begin
      blockread(inFile, Size, sizeof(LongInt));
      LZHUnPack(Size, GetBlock, PutBlock);
      PutBlock(Size, 0, Temp);
    end;
  dispose(OutBuf);
  dispose(InBuf);
  close(inFile);
  close(OutFile);
end.

