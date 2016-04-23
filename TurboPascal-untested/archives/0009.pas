Program TestComp;  { tests Compression }

{ kludgy test of Compress Unit }

Uses Crt, Dos, Compress;

Const
  NumofStrings = 5;

Var
  ch : Char;
  LongestStringLength,i,j,len : Integer;
  Textfname,Compfname : String;
  TextFile : Text;
  ByteFile : File;
  CompArr : tCompressedStringArray;
  st : Array[1..NumofStrings] of String;
  Rec : SearchRec;
  BigArr : Array[1..5000] of Byte;
  Arr : Array[1..NumofStrings] of tCompressedStringArray;

begin
  Writeln('note:  No I/O checking in this test.');
  Write('Test <C>ompress or <U>nCompress? ');
  Repeat
    ch := upCase(ReadKey);
  Until ch in ['C','U',#27];
  if ch = #27 then halt;
  Writeln(ch);
  if ch = 'C' then begin
    Writeln('Enter ',NumofStrings,' Strings:');
    LongestStringLength := 0;
    For i := 1 to NumofStrings do begin
      Write(i,': ');
      readln(st[i]);
      if length(st[i]) > LongestStringLength then
        LongestStringLength := length(st[i]);
    end;
    Writeln;
    Writeln('Enter name of File to store unCompressed Strings in.');
    Writeln('ANY EXISTinG File With THIS NAME WILL BE OVERWRITTEN.');
    readln(Textfname);
    assign(TextFile,Textfname);
    reWrite(TextFile);
    For i := 1 to NumofStrings do
      Writeln(TextFile,st[i]);
    close(TextFile);
    Writeln;
    Writeln('Enter name of File to store Compressed Strings in.');
    Writeln('ANY EXISTinG File With THIS NAME WILL BE OVERWRITTEN.');
    readln(Compfname);
    assign(ByteFile,Compfname);
    reWrite(ByteFile,1);
    For i := 1 to NumofStrings do begin
      CompressString(st[i],CompArr,len);
      blockWrite(ByteFile,CompArr,len);
    end;
    close(ByteFile);
    FindFirst(Textfname,AnyFile,Rec);
    Writeln;
    Writeln;
    Writeln('Size of Text File storing Strings: ',Rec.Size);
    Writeln;
    Writeln('Using Typed Files, a File of Type String[',
             LongestStringLength,
             '] would be necessary.');
    Writeln('That would be ',
             (LongestStringLength+1)*NumofStrings,
             ' long, including length Bytes.');
    Writeln;
    FindFirst(Compfname,AnyFile,Rec);
    Writeln('Size of the Compressed File: ',Rec.Size);
    Writeln;
    Writeln('Now erase the Text File, and run this Program again, choosing');
    Writeln('<U>nCompress to show that the Compression retains all info.');
  end else begin                        { ch = 'U' }
    Write('Name of Compressed File: ');
    readln(Compfname);
    assign(ByteFile,Compfname);
    reset(ByteFile,1);
    blockread(ByteFile,BigArr,Filesize(ByteFile));
    close(ByteFile);
    For j := 1 to NumofStrings do begin
      i := 1;
      While BigArr[i] <> 0 do inc(i);
      move(BigArr[1],Arr[j],i);
      move(BigArr[i+1],BigArr[1],sizeof(BigArr));
    end;
    For i := 1 to NumofStrings do
      st[i] := GetCompressedString(Arr[i]);
    For i := 1 to NumofStrings do
      Writeln(st[i]);
  end;
end.
