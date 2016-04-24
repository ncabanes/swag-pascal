(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0067.PAS
  Description: Totally Erased files
  Author: DAVID DRZYZGA
  Date: 11-26-94  05:03
*)


Program Zap;

Procedure ZapIt(FileName : String; Pattern : Char; LastPass : Boolean);
Var
  NumRead,
  NumWritten  : Word;
  Buffer      : Array[1..4096] Of Char;
  BufferSize  : Word;
  ZapFile     : File;
  ZapFilePos  : LongInt;

Begin
  BufferSize := SizeOf(Buffer);
  Assign(ZapFile, FileName);
  {$I-} Reset(ZapFile, 1); {$I+}
  If IOResult <> 0 Then Begin
    WriteLn('File not found');
    Halt;
  end;
  Repeat
    ZapFilePos := FilePos(ZapFile);
    BlockRead(ZapFile, Buffer, BufferSize, NumRead);
    FillChar(Buffer, BufferSize, Pattern);
    Seek(ZapFile, ZapFilePos);
    BlockWrite(ZapFile, Buffer, NumRead, NumWritten);
  Until (NumRead = 0) Or (NumWritten <> NumRead);
  Close(ZapFile);
  if LastPass Then Erase(ZapFile);
End;

begin
  ZapIt(ParamStr(1), #005, False);  {0101}
  ZapIt(ParamStr(1), #010, False);  {1010}
  ZapIt(ParamStr(1), #000, False);  {0000}
  ZapIt(ParamStr(1), #255, True );  {1111}
end.

{
Here's the comments for the above procedure:

   Get the buffer size for later use
   Get the file name from the first command line parameter
   Try to open the file
   If there was an error opening file, show the user and exit
   otherwise repeat this code
     Save the current file position
     Read a block of data from the file into a buffer
     Fill buffer with specified bit pattern
     Reset file position to where we read this block from and
     write the block back to the file
   until we're done or there was a conflict in the read/write size
   close the file
   delete the file from disk if it's the last pass
}


