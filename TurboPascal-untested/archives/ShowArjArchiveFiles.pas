(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0008.PAS
  Description: SHOW ARJ Archive Files
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)


Program ReadArj;
Uses
 Crt,
 Search;

Const
  ArjID = #96#234;

Type
  Array10 = Array[1..10] of Byte;
  Array12 = Array[1..12] of Char;

  AFileRec = Record
               FileDate       : LongInt;
               CompressedSize : LongInt;
               originalSize   : LongInt;
               DudSpace       : Array10;
               FileName       : Array12
             end;

  Array60K = Array[1..61440] of Byte;

Var
  Buffer : Array60K;

  ArjFileRec : AFileRec;

  ArjFileSize,
  ArjRecStart,
  ArjRecStop,
  Index,
  Index1 : LongInt;

  ArjFile : File;

begin
  ClrScr;
  fillChar(Buffer, sizeof(Buffer), 0);
  fillChar(ArjFileRec, sizeof(ArjFileRec), 0);
  ArjFileSize := 0;
  ArjRecStart := 1;
  ArjRecStop := 0;
  assign(ArjFile, 'TEST.ARJ');
  {$I-}
  reset(ArjFile, 1);
  {$I+}
  if (ioresult <> 0) then
    begin
      Writeln(' ERRor OPENinG TEST.ARJ');
      halt(255)
    end;
  ArjFileSize := Filesize(ArjFile);
  Index := ArjFileSize - 50;
  blockread(ArjFile, Buffer, Index);
  close(ArjFile);
  Index1 := 50;
  ArjFileRec.Filename := '            ';
  While ((Index1 + 33) < ArjFileSize) do
    begin
      ArjRecStart := StrPos(Buffer[Index1], Index, ArjID) + 11;
      ArjRecStop := StrPos(Buffer[Index1 + ArjRecStart + 22], 13, #0);
      move(Buffer[ArjRecStart + Index1], ArjFileRec, (ArjRecStop + 21));
      With ArjFileRec do
        begin
          Writeln(' ',FileName, '  Compressed size = ', CompressedSize:6,
                    '  original size = ', originalSize:6);
          FileName := '            ';
          inc(Index1, CompressedSize + ArjRecStop + ArjRecStart);
          dec(Index, CompressedSize + ArjRecStop + ArjRecStart)
        end
    end
end.


