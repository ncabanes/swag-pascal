(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0068.PAS
  Description: Erase File ABSOLUTE
  Author: ERIK APPELDOORN & JAN DOGGEN
  Date: 11-26-94  05:03
*)

{
Erik Appeldoorn

I've made a programm which erases a file absolutely and completely. Even when
it is undeleted it containes nothing.. So far so good.. But when I make a
sector-dump of the disk, it appears that there is still some text on the disk.
I don't get it. Nowhere in my programm I allocated text to memory, but the same
three sentences apear four times in the sector-dump. In the original file the
sentences begin at sentence number 1103. In the sector-dump the four blocks
appear at numbers 72 & 130 & 188 & 248. The totall dump is 251 sentences.
The floppy was newly formatted. What could be happening? Here's part of the
code.
}

var ZapFile:File;
    ZapFileName:String;
    ZapFilePos:Longint;
    Buffer:array [1..406] of byte;
    NumWritten, BufferSize, NumRead: word;

Procedure deleting(ZapFileName:string);
begin
    Buffersize:=SizeOf(Buffer);
    Assign(ZapFile,ZapFileName);
    {$I-}
    Reset(ZapFile,1);
    {$I+}
    repeat
        ZapFilePos:=FilePos(ZapFile);
        BlockRead(ZapFile,Buffer,BufferSize,NumRead);
        FillChar(Buffer,BufferSize,#255);
        Seek(ZapFile,ZapFilePos);
        BlockWrite(ZapFile,Buffer,NumRead,NumWritten);
    until (NumRead=0) or (NumWritten<>NumRead);
    close(ZapFile);
    Erase(ZapFile);
end;


{
Jan Doggen

I only had time to take a quick look; here are my suggestions:
- forget the reads
- make a CONST buffer, fill it with garbage or zeroes
  (*in* the proc, so that it takes only stack space)
- FS := FileSize(ZapFile)
  NrBlocks := FS DIV BufferSize
  LastBlockSize := FS MOD BufferSize
  For i:=1 to nrblocks blockwrite
  If lastblocksize<>0 write that amount (never mind that the buffer is
  larger)
  close the file
- forget the $I. You don't query IOResult after $I, so all subsequent
  I/O (on *all* files) goes wrong until you do. RTM.
- Instaed of this, use a FileExist function before you call your
  proc.
}
