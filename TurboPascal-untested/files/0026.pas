{
MICHAEL REECE

> Hi!  I was wondering.  How would you in Turbo Pascal be able to split a
> single File into two.  I want it to split it to a precise Byte For both
> Files. I want to be able to combine to Files together and split it to its
> original sizes and still be able to work (that no codes are missing etc.).

The following is kludgy and only semi tested, but may help you get started.
It's an old little thing I wrote to split large Files to put on a floppy, and
then put it back together again.
}

(* usage:  split <Filename> <new-name-for-second-half>
   ex: split nodelist.zip nodelist.zi2
*)
Program Split;

Const
  MaxBuffSize = 61140;

Type
  BuffType = Array[1..MaxBuffSize] of Byte;

Var
  F1, F2   : File;
  Mid      : LongInt;
  Buffer   : ^BuffType;
  BuffSize : LongInt;
  NumRead,
  NumWrite : Word;

begin
  Writeln('Splitting File "', ParamStr(1), '"');
  Assign(F1, ParamStr(1));
  Reset(F1, 1);
  Mid:=FileSize(F1) div 2;                     { calculate midpoint }
  Writeln('  Original size: ', FileSize(F1));
  Writeln('  File midpoint: ', Mid);
  Writeln('Creating File "', ParamStr(2), '"');
  Assign(F2, ParamStr(2));
  ReWrite(F2, 1);
  Writeln('Memory available: ', MaxAvail);    { allocate max buffer }
  BuffSize:=MaxAvail;
  if (BuffSize > MaxBuffSize) then
    BuffSize:=MaxBuffSize;
  GetMem(Buffer, BuffSize);
  Writeln('  Buffer size: ', BuffSize);
  Writeln('Seeking to midpoint');
  Seek(F1, Mid);
  Writeln('  Copying remainder of File');
  While (not Eof(F1)) do
  begin
    BlockRead(F1, Buffer^, BuffSize, NumRead);
    BlockWrite(F2, Buffer^, NumRead, NumWrite);
    if (NumRead <> NumWrite) then
    begin
      Writeln('Error in copy');
      Halt(1);
    end;
  end;
  Writeln('Seeking to midpoint');
  Seek(F1, Mid);
  Writeln('  Truncating File');
  Truncate(F1);
  Writeln('Closing Files');
  Close(F2);
  Close(F1);
  Writeln('Done.');
end.

{ That one splits a File in half. }

(* usage:  splice <Filename> <name-of-second-half>
   ex: split nodelist.zip nodelist.zi2
   this will append/splice nodelist.zi1 to nodelist.zip
*)
Program Splice;

Const
  MaxBuffSize = 61140;

Type
  BuffType = Array[1..MaxBuffSize] of Byte;

Var
  F1, F2   : File;
  Buffer   : ^BuffType;
  BuffSize : LongInt;
  NumRead,
  NumWrite : Word;

begin
  Writeln('Splicing File "', ParamStr(1), '"');
  Assign(F1, ParamStr(1));
  Reset(F1, 1);
  Writeln('  Original size: ', FileSize(F1));
  Writeln('Appending File "', ParamStr(2), '"');
  Assign(F2, ParamStr(2));
  Reset(F2, 1);
  Writeln('  Original size: ', FileSize(F1));
  Writeln('Memory available: ', MaxAvail);    { allocate max buffer }
  BuffSize:=MaxAvail;
  if (BuffSize > MaxBuffSize) then
    BuffSize:=MaxBuffSize;
  GetMem(Buffer, BuffSize);
  Writeln('  Buffer size: ', BuffSize);
  Writeln('Seeking to end');
  Seek(F1, FileSize(F1));
  Writeln('  Copying File');
  While (not Eof(F2)) do
  begin
    BlockRead(F2, Buffer^, BuffSize, NumRead);
    BlockWrite(F1, Buffer^, NumRead, NumWrite);
    if (NumRead <> NumWrite) then
    begin
      Writeln('Error in copy');
      Halt(1);
    end;
  end;
  Writeln('Closing Files');
  Writeln('Done.');
  Close(F2);
  Close(F1);
end.

