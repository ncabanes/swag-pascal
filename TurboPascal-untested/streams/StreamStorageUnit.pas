(*
  Category: SWAG Title: STREAM HANDLING ROUTINES
  Original name: 0004.PAS
  Description: Stream Storage Unit
  Author: MARCOS DELLA
  Date: 11-26-94  04:57
*)


Unit Storage;

{  STORAGE.PAS - 13 Jan 91

   This unit was created to replace the original system storage that was
   created for the DMG.  It is designed to be object oriented and will
   also alow for external compression routines to be designed into the
   system with a registration code for each.

   The system will take a buffer pointer and run it through the compressor
   until it reaches a NULL (0) character in the buffer.  This limits you
   to storing only readable messages.  Once the compressor is finished,
   the resulting bitstream is then written to the disk.  An index number
   is returned for where this was written.

   The system that reads the messages only needs an index and filename.
   It will create a buffer for the message up to the memory restraints.

   You MUST do a .done when you are through with the buffer or the space
   will not be released to the heap.

   NOTES:
      The compression algorythm on this system is VERY rudimentary and is
      designed for text only type of material.  It strips all spaces out of
      your text and compresses the next character with 128.  This generally
      saves around 20% storage of a typical text file.  The other change
      is to do the same with the lower case 'e' character.  This is then
      combined with a 64.  Between the two you get around %30 compression
      on your text files... Pretty nifty...

      Note that there is no modifications or remaps of any character ranging
      from 000..159.  This is so that you can take a standard FIDO file and
      read it without remapping the soft carriage returns and linefeeds
      (8D and 8A).

}

{$F+,O+,S-,R-}

Interface

Uses Dos, Objects;

CONST stStoreError      = -120;
      stStoreReadErr    = 197;
      stStoreWriteErr   = 198;
      stStoreUnknownErr = 199;

TYPE  PBuffer  = ^BBuffer;
      BBuffer  = ARRAY [0..65530] OF BYTE;
      PCharBuf = ^CharBuf;
      CharBuf  = ARRAY [0..65530] OF CHAR;

TYPE  PList    = ^LList;
      LList    = RECORD
                    OldItem : LONGINT;
                    NewItem : LONGINT;
                    Next    : PList;
                 END;

TYPE  PStorage = ^TStorage;
      TStorage = OBJECT(TBufStream)
                    SFileName   : FNameStr;
                    SCleanName  : FNameStr;
                    SCleanIndex : PList;
                    SMode       : WORD;
                    SIndex      : LONGINT;
                    SHoldBuf    : POINTER;
                    SHoldBufLen : WORD;
                    CONSTRUCTOR Init(AFileName : FNameStr; AMode, Size : WORD);
                    PROCEDURE WriteMsg(VAR Buf);
                    PROCEDURE ReadMsg(VAR Buf : PCharBuf; Index : LONGINT);
                    PROCEDURE DeleteMsg(Index : LONGINT);
                    PROCEDURE CleanUpMsg;
                    FUNCTION NewIndex(Index : LONGINT) : LONGINT;
                    PROCEDURE DeleteCleanUp;
                    PROCEDURE Compress(VAR Buf); VIRTUAL;
                    PROCEDURE DeCompress(VAR Buf); VIRTUAL;
                    DESTRUCTOR Done; VIRTUAL;
                 END;

Implementation

CONST MarkerWord   = $93D2;
      RegBasicComp : BYTE = $01;

VAR   ExpandSize   : WORD;
      CompressSize : WORD;
      Marker       : WORD;

{----------------------------------------------------------------------------}

CONSTRUCTOR TStorage.Init;
BEGIN
   TBufStream.Init(AFileName,AMode,Size);
   IF Status <> stOk THEN
      Status := stStoreError
   ELSE
      BEGIN
         SFileName   := FEXPAND(AFileName);
         SCleanName  := '';
         SCleanIndex := NIL;
         SMode       := AMode;
         SIndex      := 0;
         SHoldBuf    := NIL;
         SHoldBufLen := 0
      END
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.WriteMsg;
VAR   WritePosn    : WORD;
      p            : PBuffer;
BEGIN
   p := PBuffer(@Buf);
   SIndex := GetSize;
   TBufStream.Seek(SIndex);
   Marker := MarkerWord;
   TBufStream.Write(Marker,SIZEOF(Marker));
   ExpandSize := 0;
   WHILE (p^[ExpandSize] <> 0) DO
      INC(ExpandSize);
   TBufStream.Write(ExpandSize,SIZEOF(ExpandSize));
   Compress(Buf);
   CompressSize := 0;
   WHILE (p^[CompressSize] <> 0) DO
      INC(CompressSize);
   TBufStream.Write(CompressSize,SIZEOF(CompressSize));
   WritePosn := 0;
   WHILE WritePosn < CompressSize DO
      IF CompressSize - WritePosn > BufSize THEN
         BEGIN
            TBufStream.Write(p^[WritePosn],BufSize);
            INC(WritePosn,BufSize)
         END
      ELSE
         BEGIN
            TBufStream.Write(p^[WritePosn],CompressSize - WritePosn);
            WritePosn := CompressSize
         END;
   Flush;
   IF Status <> stOk THEN
      Status := stStoreError
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.ReadMsg;
VAR   DeleteCheck : BYTE;
BEGIN
   IF (SHoldBuf <> NIL) AND (SHoldBufLen > 0) THEN
      BEGIN
         FREEMEM(SHoldBuf,SHoldBufLen);
         SHoldBuf := NIL;
         SHoldBufLen := 0
      END;
   Seek(Index);
   Read(Marker,SIZEOF(Marker));
   IF Marker = MarkerWord THEN
      BEGIN
         Read(ExpandSize,SIZEOF(ExpandSize));
         Read(CompressSize,SIZEOF(CompressSize));
      END
   ELSE
      BEGIN
         Seek(Index);
         ExpandSize := GetSize - Index;
         IF ExpandSize >= SIZEOF(CharBuf) THEN
            ExpandSize := SIZEOF(CharBuf) - 1;
         CompressSize := ExpandSize
      END;
   Read(DeleteCheck,1);
   IF (DeleteCheck < $FF) OR (Marker <> MarkerWord) THEN
      BEGIN
         SHoldBufLen := ExpandSize + 1;
         GETMEM(SHoldBuf,SHoldBufLen);
         FILLCHAR(SHoldBuf^,SHoldBufLen,0);
         BBuffer(SHoldBuf^)[0] := DeleteCheck;
         Read(BBuffer(SHoldBuf^)[1],CompressSize - 1);
         IF Marker = MarkerWord THEN
            DeCompress(SHoldBuf^);
      END
   ELSE
      BEGIN
         SHoldBufLen := 1;
         GETMEM(SHoldBuf,1);
         BBuffer(SHoldBuf^)[0] := 0;
         Error(stStoreError,stStoreReadErr)     {Disk Read Error}
      END;
   PCharBuf(Buf) := @SholdBuf^;
   IF Status <> stOk THEN
      Status := stStoreError
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.DeleteMsg;
VAR   CompressType : BYTE;
BEGIN
   Seek(Index);
   Read(Marker,SIZEOF(Marker));
   IF Marker = MarkerWord THEN
      BEGIN
         Seek(Index + SIZEOF(Marker) + SIZEOF(ExpandSize) + SIZEOF(CompressSize));
         CompressType := $FF;   {Mark Compression Type as Deleted!}
         Write(CompressType,SIZEOF(CompressType))
      END;
   IF Status <> stOk THEN
      Status := stStoreError
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.CleanUpMsg;
VAR   Dir     : DirStr;
      FName   : NameStr;
      Ext     : ExtStr;
      T       : TBufStream;
      TmpPtr  : POINTER;
      TFile   : FILE;
      OldItem : LONGINT;
      NewItem : LONGINT;
      LinkPtr : PList;
BEGIN
   FSplit(SFileName,Dir,FName,Ext);
   SCleanName := Dir + FName + '.$$$';
   T.Init(SCleanName,stCreate,1024);
   Seek(0);
   OldItem := 0;
   WHILE OldItem < GetSize - 1 DO BEGIN
      Read(Marker,SIZEOF(Marker));
      IF Marker <> MarkerWord THEN
         Error(stStoreError,stStoreUnknownErr);
      Read(ExpandSize,SIZEOF(ExpandSize));
      Read(CompressSize,SIZEOF(CompressSize));
      GETMEM(TmpPtr,CompressSize);
      Read(TmpPtr^,CompressSize);
      IF (Status = stOk) AND (BBuffer(TmpPtr^)[0] < $FF) THEN
         BEGIN
            NewItem := T.GetPos;
            T.Write(Marker,SIZEOF(Marker));
            T.Write(ExpandSize,SIZEOF(ExpandSize));
            T.Write(CompressSize,SIZEOF(CompressSize));
            T.Write(TmpPtr^,CompressSize);
            GETMEM(LinkPtr,SIZEOF(LList));
            LinkPtr^.OldItem := OldItem;
            LinkPtr^.NewItem := NewItem;
            LinkPtr^.Next := SCleanIndex;
            SCleanIndex := LinkPtr
         END;
      FREEMEM(TmpPtr,CompressSize);
      OldItem := GetPos
   END;
   T.Done;
   IF Status <> stOk THEN
      BEGIN
         ASSIGN(TFile,SCleanName);
         ERASE(TFile);
         SCleanName := '';
         Status := stStoreError
      END
END;

{----------------------------------------------------------------------------}

FUNCTION TStorage.NewIndex;
VAR   PLink : PList;
BEGIN
   PLink := SCleanIndex;
   NewIndex := -1;
   WHILE (PLink <> NIL) AND (PLink^.OldItem <> Index) DO
      PLink := PLink^.Next;
   IF (PLink <> NIL) AND (PLink^.OldItem = Index) THEN
      NewIndex := PLink^.NewItem
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.DeleteCleanUp;
VAR   TFile : FILE;
      PLink : PList;
BEGIN
   IF SCleanName <> '' THEN
      BEGIN
         {$I-} ASSIGN(TFile,SCleanName);
         ERASE(TFile); {$I+}
         ErrorInfo := IOResult;
         IF ErrorInfo <> stOk THEN
            Status := stStoreError;
         SCleanName := '';
         WHILE SCleanIndex <> NIL DO BEGIN
            PLink := SCleanIndex;
            SCleanIndex := PLink^.Next;
            FREEMEM(PLink,SIZEOF(LList))
         END
      END
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.Compress;
VAR   p          : PBuffer;
      ReadPosn   : WORD;
      WritePosn  : WORD;
      SpaceCount : WORD;
BEGIN
   p := PBuffer(@Buf);
   ReadPosn := 0;
   WritePosn := 0;
   WHILE (p^[ReadPosn] <> 0) AND (ReadPosn < 65530) DO BEGIN
      SpaceCount := 0;
      WHILE (p^[ReadPosn + SpaceCount] = 32) DO
         INC(SpaceCount);
      IF SpaceCount > 1 THEN
         BEGIN
            INC(ReadPosn,SpaceCount);
            WHILE SpaceCount > 0 DO
               IF SpaceCount > 255 THEN
                  BEGIN
                     p^[WritePosn] := 255;
                     p^[WritePosn + 1] := 255;
                     INC(WritePosn,2);
                     DEC(SpaceCount,255)
                  END
               ELSE
                  BEGIN
                     p^[WritePosn] := 255;
                     p^[WritePosn + 1] := SpaceCount;
                     INC(WritePosn,2);
                     SpaceCount := 0
                  END;
            SpaceCount := 2
         END;
      IF SpaceCount = 1 THEN
         IF (p^[ReadPosn + 1] >= 64) AND (p^[ReadPosn + 1] <= 127) THEN
            BEGIN
               p^[WritePosn] := p^[ReadPosn + 1] + 128;
               INC(WritePosn);
               INC(ReadPosn,2)
            END
         ELSE
            SpaceCount := 0;
      IF SpaceCount = 0 THEN
         BEGIN
            IF p^[ReadPosn + 1] = 101 THEN
               BEGIN
                  p^[WritePosn] := p^[ReadPosn] + 64;
                  INC(ReadPosn,2)
               END
            ELSE
               BEGIN
                  p^[WritePosn] := p^[ReadPosn];
                  INC(ReadPosn)
               END;
            INC(WritePosn)
         END
   END;
   p^[WritePosn] := 0;
   MOVE(p^[0],p^[1],WritePosn + 1);
   p^[0] := RegBasicComp
END;

{----------------------------------------------------------------------------}

PROCEDURE TStorage.DeCompress;
VAR   p         : PBuffer;
      ReadPosn  : WORD;
      Count     : WORD;
      Total     : WORD;
BEGIN
   p := PBuffer(@Buf);
   ReadPosn := 0;
   Total := 0;
   WHILE (p^[Total + 1] <> 0) DO
      INC(Total);
   IF p^[0] = RegBasicComp THEN
      BEGIN
         MOVE(p^[1],p^[0],Total);
         p^[Total] := 0;
         WHILE (p^[ReadPosn] <> 0) AND (ReadPosn < SholdBufLen) DO BEGIN
            CASE p^[ReadPosn] OF
               255      : BEGIN
                             Count := p^[ReadPosn + 1];
                             MOVE(p^[ReadPosn + 2],p^[ReadPosn + Count],SHoldBufLen - ReadPosn - 2);
                             FILLCHAR(p^[ReadPosn],Count,32);
                             INC(ReadPosn,Count)
                          END;
               192..254 : BEGIN
                             MOVE(p^[ReadPosn],p^[ReadPosn + 1],SHoldBufLen - ReadPosn);
                             p^[ReadPosn] := 32;
                             DEC(p^[ReadPosn + 1],128);
                             INC(ReadPosn,2)
                          END;
               160..191 : BEGIN
                             MOVE(p^[ReadPosn],p^[ReadPosn + 1],SHoldBufLen - ReadPosn);
                             p^[ReadPosn + 1] := 101;
                             DEC(p^[ReadPosn],64);
                             INC(ReadPosn,2)
                          END;

               000..159 : INC(ReadPosn)
            END
         END
      END
END;

{----------------------------------------------------------------------------}

DESTRUCTOR TStorage.Done;
VAR   TFile : FILE;
      PLink : PList;
BEGIN
   IF (SHoldBuf <> NIL) AND (SHoldBufLen > 0) THEN
      FREEMEM(SHoldBuf,SHoldBufLen);
   TBufStream.Done;
   IF SCleanName <> '' THEN
      BEGIN
         ASSIGN(TFile,SFileName);
         ERASE(TFile);
         ASSIGN(TFile,SCleanName);
         RENAME(TFile,SFileName);
         SCleanName := ''
      END;
   WHILE SCleanIndex <> NIL DO BEGIN
      PLink := SCleanIndex;
      SCleanIndex := PLink^.Next;
      FREEMEM(PLink,SIZEOF(LList))
   END

END;

{----------------------------------------------------------------------------}

END.

{  --------------------------    TEST PROGRAM ------------------------ }

Program StorageTest;

{ This program will demonstrate the ability to save and restore text info
  in an indexed file that is also Network aware. This should be interesting

  Note that the information both stored and retrived are limited to 65530
  characters in length.  In the current version, this will require you to
  have somewhere on your heap that much space. In the future this routine
  will be made EMS aware so that it will grab the best option for heap
  storage and manipulation out there...

  The OBJECT TStorage is a Child of the BufStream Object.  This means that
  it still retains all the lower level stuff from BufStream, DOSStream, and
  TStream if you have some sort of use for that.

  The routines provided are as follows:

  TStorage.Init(FNameStr, Mode, BufSize)
      This routine will initialize the file that you are going to be reading
      from or writing to.  You can use the stCreate, stOpenWrite, stOpenRead,
      or stOpen as your mode.  If you use the stCreate, the system will write
      over your previous file.  If you use stOpenWrite, you can ONLY write
      to the file, you cannot do reads and visa-versa with stOpenRead.  If
      you use stOpen, then you can do both operations at the same time.

      This is another item that in the future will be changed to do record
      locking of the specified section you are writing to so that other
      users on a network can read from the various other parts of the file.

      The BufSize defines the internal buffer size that the system will use
      to buffer your I/O reads.  Borland recommends around 1024 for standard
      usage.  You might make it bigger or smaller depending on your needs.

  TStorage.WriteMsg(Buf)
      This takes a buffer that you define that is NULL terminated (there is
      a #0 at the end of your text) and will write it out to the end of the
      file after running the buffer thru the internal compression routine
      (see TStorage.Compress). It will also set an internal variable
      TStorage.SIndex that is your key to retrieving this body of text.

  TStorage.ReadMsg(Buf : PCharBuf; Index)
      This is how you retrieve your text.  You pass the index that you got
      earlier from TStorage.SIndex to this routine and it will pass you a
      buffer that is defined as an array of characters [0..whatever] with
      the string being NULL terminated.  NOTE:  If the index that you pass
      is not the beginning of a stored pattern, the ReadBuf routine will
      assume that you are reading a STANDARD text file and will rewind
      and read the ENTIRE file into the buffer.  This is how you can use
      the same routine to read normal text files as well as those created
      by this Object.  If the message was deleted by the DeleteMsg routine,
      you will get an errorlevel of 100 (Disk Read Error) returned to you
      from the function.

  TStorage.DeleteMsg(Index)
      This function does not actually delete the message out of the stream
      as this would then mess up all subsequent index pointers.  Instead, it
      changes the compression routine variable to $FF indicating that the
      message is no longer valid.  To actually take the messages out of the
      stream, you need to use the CleanUpMsg procedure.

  TStorage.CleanUpMsg
      This procedure will scan the message stream, and re-write it out to a
      seperate file leaving out all the deleted messages.  It then creates
      a linked list of the old indexes and their new values.  This is then
      used by you, the user, to change all your old saved index values.
      NOTE:  Make sure that you do the index change BEFORE calling the
      TStorage.Done routine as this will remove your list from memory and
      all your pointers will be subsiquently screwed up.  If there is a
      problem and you need to restore the previous file, you can rename
      .$$$ file back to your filename.  The .$$$ file is not deleted until
      the TStorage.Done is called.

  TStorage.NewIndex(Index) : LONGINT
      When you call this routine with an old index number, it will return
      to you the new index reference number. You'll get a -1 if the system
      cannot fine an original index number.  To use this, you can scan
      through your recorded indexes in your data file sequentially and call
      this routine with each one you get.  Then replace the old value with
      the new value.  If you get a -1 as your return, then the old message
      was either originally deleted or lost to the system.  This will ALWAYS
      return a -1 if you haven't made a VALID call to TStorage.CleanUpMsg.
      It will also reset after a TStorage.Done has been executed.  Make sure
      that you use this after the TStorage.CleanUpMsg routine if you want
      to retain the changes made.

  TStorage.DeleteCleanUp
      If you decide that for some reason something went wrong somewhere and
      everything is screwed up, you can prevent TStorage.Done from replacing
      your original msg file by calling this routine.  It will remove the
      .$$$ file from the disk and clear out all TStorage.NewIndex references.

  TStorage.Compress(Buf)
      This is a compression routine that is VERY rudimentary.  I whipped
      this up in an hour or so just to demonstrate how it works.  You can
      create a child object and replace the compress and decompress routines
      with something more efficient if you'd like.  All you need to do is
      create a new RegComp variable other than 1 and make sure that your
      compression routine will downwardly call mine if the numbers don't
      match.  This way you can read files that were created with any
      compression routine that is in the line.

  TStorage.DeCompress(Buf)
      Same as the compression except that this goes backwards.  Again, this
      is a basic one that I whipped together in a matter of minutes so don't
      be too impressed by it

  TStorage.Done
      Here is where you clean up all the messes, close all the files, and
      return all the used heap back.  Remember to call this when your done
      using the routines

  ERRORS Returned
      When you check the TStorage.Status Integer, if you do not get an stOk
      returned, then something went wrong.  To identify it from this Unit,
      You can check TStorage.Status against stStoreError.  Errors also
      included are stStoreReadErr, stStoreWriteErr, and stStoreUnknownErr.
      These are stored in the TStorage.ErrorInfo location.

  ---------------------------------------------------------------------------

  These routines were originally designed as a message storage routine for a
  new BBS system message base that we are putting together, however we have
  used this storage format for a varity of purposes as you can store variable
  length messages to one file and only have to keep track of an index.  It
  also attempts to save on disk space which is ALWAYS at a premium around
  here.

  If you have any suggestions or improvments on this file or its usage, or
  would just like to chat, you can reach me at the following:

        Marcos R. Della
        5084 Rincon Ave.
        Santa Rosa, CA 95409

        CIS: 71675,765

  ---------------------------------------------------------------------------}

Uses Dos, Crt, Storage, Objects;

VAR   T   : TStorage;
      st1 : STRING;      {Kind of a pseudo buffer}
      st2 : STRING;      {Another pseudo buffer}
      st3 : STRING;
      p   : PCharBuf;    {Pointer to the return character buffer}

      idx1   : LONGINT;
      idx2   : LONGINT;
      idx3   : LONGINT;
      loop   : WORD;
      ch     : CHAR;
BEGIN
   CLRSCR;
   st1 := 'Now is the time for all good men to come to the aid of their '
        + 'country before the last of the Mohecians take over the world as '
        + 'we now know it.  This might be a very detrimental accident if '
        + 'it is allowed to happen' + #0;
   st2 := 'This is a message that will test the deletion function.' + #0;
   st3 := 'This message will survive the compression and deletion!' + #0;

   T.Init('TESTFILE.DAT',stOpenWrite,512);
   IF T.ErrorInfo = 2 THEN  {File Does Not Exist}
      BEGIN
         T.Done;
         T.Init('TESTFILE.DAT',stCreate,512)
      END;
   WriteLn('Filename:   ',T.SFileName);
   WriteLn('Mode:       ',T.SMode);

   T.WriteMsg(st1[1]);    {Our actual buffer is from 1..till we hit the NULL}
   IF T.Status <> stOk THEN    {Do your real error checking here if you are}
      T.Reset;                 {really interested}
   idx1 := T.SIndex;
   WriteLn('1st Index:  ',idx1);

   T.WriteMsg(st2[1]);
   IF T.Status <> stOk THEN
      T.Reset;
   idx2 := T.SIndex;
   Writeln('2nd Index:  ',idx2);

   T.WriteMsg(st3[1]);
   IF T.Status <> stOk THEN
      T.Reset;
   idx3 := T.SIndex;
   Writeln('3nd Index:  ',idx3);

   WriteLn;
   T.DeleteMsg(idx2);
   WriteLn('First Deletion Attempt (Write Only):   ',T.ErrorInfo);
   IF T.Status <> stOk THEN
      T.Reset;
   T.Done;

   T.Init('TESTFILE.DAT',stOpen,128);
   T.DeleteMsg(idx2);            {Must be open for read/write!}
   WriteLn('Second Deletion Attempt (Read/Write):  ',T.ErrorInfo);
   IF T.Status <> stOk THEN
      T.Reset;

   T.ReadMsg(p,idx2);
   WriteLn('Attempt to re-read:                    ',T.ErrorInfo);
   IF T.Status <> stOk THEN
      T.Reset;
   Write('"');
   Loop := 0;
   WHILE p^[Loop] <> #0 DO BEGIN
      Write(p^[Loop]);
      INC(Loop)
   END;
   WriteLn('"');
   Write('Cleaning up the deletion files.   Error returned: ');
   T.CleanUpMsg;
   WriteLn(T.ErrorInfo);
   WriteLn('Re-Index of #1 (Old/New):   ',idx1,'/',T.NewIndex(idx1));
   WriteLn('Re-Index of #2:             ',idx2,'/',T.NewIndex(idx2));
   WriteLn('Re-Index of #3:             ',idx3,'/',T.NewIndex(idx3));
   WriteLn;
   WriteLn('Removing Cleanup stuff and restoring old indexes');
   T.DeleteCleanUp;
   T.Done;

   T.Init('TESTFILE.DAT',stOpenRead,128);
   T.ReadMsg(p,idx1);
   WriteLn('Test that is being read back from the file:');
   WriteLn('---------------Index 1----------------------------');
   Loop := 0;
   WHILE p^[Loop] <> #0 DO BEGIN
      Write(p^[Loop]);
      INC(Loop)
   END;
   WriteLn;
   WriteLn;

   T.ReadMsg(p,idx3);
   WriteLn('---------------Index 3----------------------------');
   Loop := 0;
   WHILE p^[Loop] <> #0 DO BEGIN
      Write(p^[Loop]);
      INC(Loop)
   END;
   T.Done;

   WriteLn;
   WriteLn('-------------------------------------------');
   WriteLn('If you want to see what the compressed text looks like');
   WriteLn('then use a listing utility to list the file ',T.SFilename);
   WriteLn;
   WriteLn('Press a key to read a STANDARD text file');
   ch := READKEY;
   IF ch = #0 THEN
      ch := READKEY;
   CLRSCR;

   T.Init('TEST.PAS',stOpenRead,1024);
   T.ReadMsg(p,0);
   Loop := 0;
   WHILE p^[Loop] <> #0 DO BEGIN
      Write(p^[Loop]);
      INC(Loop)
   END;
   WriteLn;
   T.Done;
END.


