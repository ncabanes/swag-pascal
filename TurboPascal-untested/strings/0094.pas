{
LH>    Very nice - and a dandy tutorial on OOP streaming.

Thanks for the compliment.

LH>    My little step-up speeds things up by 3x, but I imagine yours is
LH>    a hefty margin faster than that.

I further modified the original and my streaming version to send their
outputs to a text file. In the original I used a variable of type
Text, and in the streaming version, I used a variable of type
pBufStream. This was to eliminate any screen scrolling delays. I ran
both versions on COMMAND.COM, which has a file size of 47845 bytes on
my system. In going back over my code, I also noticed that I had
declared the read buffer as vInByte: BYTE. I changed this to vInChar:
CHAR and eliminated the call to Chr(vInByte) when appending characters
to the result string.

The original took 243201.838 ms and the streaming version took
2351.532 ms to scan the file. The absolute numbers are less important
than the ratio, which is 103.423. So in this instance the use of
streams and in-memory searching resulted in a speed-up of almost 104x.

I tried buffer sizes of 512 to 16384 bytes in increments of 512 bytes
and found that 8192 was optimum on my system. The worst buffer size
was 1024 bytes. This required 2765.426 ms to scan the file, an
increase of 17.6% over the optimum. This was a very interesting and
unexpected result, given that 1024 is the figure used in the TV and
OWL documentation. Of course, this is probably very system dependent.
I run dual IDE drives, one formatted FAT and the other formatted OS/2
HPFS. The above results were obtained off the FAT drive. 

On the HPFS drive, the best time was turned in by a buffer size of
4608 bytes. This size had given the second-best results on the FAT
drive at 2368.464 ms, but clocked in on the HPFS drive at 2373.780.
Using an 8192 byte buffer on the HPFS drive resulted in a time of
2449.082 ms.

Comparing the speeds on the FAT and HPFS drives in this case isn't
really apples and apples, since the two drives are from different
manufacturers. A better test would be to use two logical partitions on
the same drive. Even at that though the average boost in speed was
around 100x over the original.
}
PROGRAM FindStr;
 (* Searches any file for printable strings of 6 or more characters. *)
 (* Useful for extracting messages and internal documentation from .EXE's *)

 USES
   Objects;

 VAR
   vInFile,
   vOutFile : pBufStream;
   vMemFile : pMemoryStream;
   vS       : STRING;
   vInChar  : CHAR;
 BEGIN
   vInFile := New(pBufStream, Init(ParamStr(1), stOpenRead, 8192));
   IF vInFile = NIL THEN
     BEGIN
       WriteLn('Unable to open input file');
       Halt;
     END;
   vOutFile := New(pBufStream, Init(ParamStr(2), stCreate, 8192));
   IF vOutFile = NIL THEN
     BEGIN
       WriteLn('Unable to create output file');
       Dispose(vInFile, Done);
       Halt;
     END;
   vMemFile := New(pMemoryStream, Init(vInFile^.GetSize, 8192));
   IF vMemFile = NIL THEN
     BEGIN
       WriteLn('Insufficient memory');
       Dispose(vInFile, Done);
       Dispose(vOutfile, Done);
       Halt;
     END;
   vInFile^.Seek(0);
   vOutFile^.Seek(0);
   vMemFile^.CopyFrom(vInFile^, vInFile^.GetSize);
   IF vInFile <> NIL THEN
     Dispose(vInFile, Done);
   vMemFile^.Seek(0);
   WriteLn('>>Searching ', ParamStr(1),'<<');
   WITH vMemFile^ DO
     WHILE (Status = stOK) DO
       BEGIN
         vS := '';
         Read(vInChar, 1);
         WHILE ((vInChar > #31) AND (vInChar < #127) AND (Status = stOK)) DO
           BEGIN
             vS := vS + vInChar;
             Read(vInChar, 1);
           END;
           IF Length(vS) > 5 THEN
             BEGIN
               vS := vS + #13#10;
               vOutFile^.Write(vS[1], Length(vS));
             END;
       END;
   IF vMemFile <> NIL THEN
     Dispose(vMemFile, Done);
   IF vOutFile <> NIL THEN
     Dispose(vOutFile, Done);
   WriteLn('>>End of file<<');
 END.
