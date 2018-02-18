(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0003.PAS
  Description: String Compression
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{You won't get that sort of compression from my routines, but here
they are anyway.  When testing, you'll get best compression if you
use English and longish Strings.
}
Uses Crt, Dos;
(*
Unit Compress;

Interface
*)
Const
  CompressedStringArraySize = 500;  { err on the side of generosity }

Type
  tCompressedStringArray = Array[1..CompressedStringArraySize] of Byte;
(*
Function GetCompressedString(Arr : tCompressedStringArray) : String;

Procedure CompressString(st : String; Var Arr : tCompressedStringArray;
                         Var len : Integer);
  { converts st into a tCompressedStringArray of length len }

Implementation
*)
Const
  FreqChar : Array[4..14] of Char = 'etaonirshdl';
  { can't be in [0..3] because two empty bits signify a space }


Function GetCompressedString(Arr : tCompressedStringArray) : String;
Var
  Shift : Byte;
  i : Integer;
  ch : Char;
  st : String;
  b : Byte;

  Function GetHalfNibble : Byte;
  begin
    GetHalfNibble := (Arr[i] shr Shift) and 3;
    if Shift = 0 then begin
      Shift := 6;
      inc(i);
    end else dec(Shift,2);
  end;

begin
  st := '';
  i := 1;
  Shift := 6;
  Repeat
    b := GetHalfNibble;
    if b = 0 then
      ch := ' '
    else begin
      b := (b shl 2) or GetHalfNibble;
      if b = $F then begin
        b := GetHalfNibble shl 6;
        b := b or GetHalfNibble shl 4;
        b := b or GetHalfNibble shl 2;
        b := b or GetHalfNibble;
        ch := Char(b);
      end else
        ch := FreqChar[b];
    end;
    if ch <> #0 then st := st + ch;
  Until ch = #0;
  GetCompressedString := st;
end;

Procedure CompressString(st : String; Var Arr : tCompressedStringArray;
                         Var len : Integer);
{ converts st into a tCompressedStringArray of length len }
Var
  i : Integer;
  Shift : Byte;

  Procedure OutHalfNibble(b : Byte);
  begin
    Arr[len] := Arr[len] or (b shl Shift);
    if Shift = 0 then begin
      Shift := 6;
      inc(len);
    end else dec(Shift,2);
  end;

  Procedure OutChar(ch : Char);
  Var
    i : Byte;
    bych : Byte Absolute ch;
  begin
    if ch = ' ' then
      OutHalfNibble(0)
    else begin
      i := 4;
      While (i<15) and (FreqChar[i]<>ch) do inc(i);
      OutHalfNibble(i shr 2);
      OutHalfNibble(i and 3);
      if i = $F then begin
        OutHalfNibble(bych shr 6);
        OutHalfNibble((bych shr 4) and 3);
        OutHalfNibble((bych shr 2) and 3);
        OutHalfNibble(bych and 3);
      end;
    end;
  end;

begin
  len := 1;
  Shift := 6;
  fillChar(Arr,sizeof(Arr),0);
  For i := 1 to length(st) do OutChar(st[i]);
  OutChar(#0);  { end of compressed String signaled by #0 }
  if Shift = 6
    then dec(len);
end;

{------}

(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0009.PAS
  Description: Test String Compression
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

(*
Program TestComp;  { tests Compression }

{ kludgy test of Compress Unit }

Uses Crt, Dos, Compress;
*)

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

