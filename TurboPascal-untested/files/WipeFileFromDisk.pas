(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0027.PAS
  Description: Wipe file from Disk
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  22:11
*)

{
> I'm looking For a turbo pascal routine that will wipe Files
> off of disks the way (or similar to the way) that Norton's
> Wipeinfo wipe's Files.  I'd like the call to be something
> like wipeFile(fn:String);  Preferrably, I would also like
> the deleted directory entry wiped to prevent one from seeing
> what the File that used to be there was named, or how large
> it was.  Any help would greatly be appreciated.

> Here is my wipe File. The directory entry is not cleared.
Well, today an idea occured: clearing directory entries is not as
difficult as I tought. No Assembler needed, no strange Dos calls, just
plain TP. Here an updated version. Even the CIA won't get your Files
back!
}

Procedure DosWipe(Path : PathStr);
{ wipes Files according to Department of Defense standard DOD 5220.22-M }
Var
  DataFile : File;
  DirInfo  : SearchRec;

  Procedure WipeFile(Var DataFile : File);
  Const
    NullByte : Byte = 0;
    FFByte   : Byte = $FF;
    F6Byte   : Byte = $F6;
  Var
    Result : Word;
    Count  : Byte;
    Count2 : LongInt;
  begin
    Reset(DataFile, 1);
    For Count := 1 to 3 do
    begin
      Seek(DataFile,0);
      For Count2 := 0 to FileSize(DataFile) - 1 do
        BlockWrite(DataFile, FFByte, 1, result);
      Seek(DataFile,0);
      For Count2 := 0 to FileSize(DataFile) - 1 do
        BlockWrite(DataFile, NullByte, 1, result);
    end;

    Seek(DataFile, 0);
    For Count := 0 to FileSize(DataFile) - 1 do
      BlockWrite(DataFile, F6Byte, 1, result);
    Close(DataFile);
  end;

  Procedure ClearDirEntry;
  begin
    Reset(DataFile);
    Truncate(DataFile);                  { erase size entry }
    Close(DataFile);
    Rename(DataFile, 'TMP00000.$$$');    { erase name entry }
  end;

Var
  D : DirStr;
  N : NameStr;
  E : ExtStr;
begin
  FSplit(Path, D, N, E);
  FindFirst(Path, Archive, DirInfo);

  While DosError = 0 do
  begin
    Assign(DataFile, D+DirInfo.Name);
    WipeFile(DataFile);
    ClearDirEntry;
    Erase(DataFile);
    FindNext(DirInfo);
  end;
end;


