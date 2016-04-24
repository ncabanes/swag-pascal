(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0022.PAS
  Description: Fast File Copy
  Author: MARK OUELLET
  Date: 05-26-95  23:05
*)

{
>   I need a QUICK way to Copy/Move files!  (This must be able to
>   work over Drives)
>   the :
>   Repeat
>     BlockRead(...);
>     BlockWrite(...);
>   UNTIL ();
>   Is To slow!  How does MS-DOS do it?

Ok here is an example based on what I told you.

THIS IS TESTED CODE. CURRENTLY SET TO COMPILE IN PROTECTED MODE UNDER
BORLAND PASCAL 7.X.  ALLMOST NO ERROR CHECKING IS DONE. IF THE PROGRAM
CAN'T AT LEAST ALLOCATE ONE BUFFER IT WILL CRASH AS NO CHECK IS MADE TO
SEE IF WE HAVE BUFFERS OR NOT

First a few numbers.
    The following code managed to copy a > 10 MEG file at a rate of 640K/second
or about 300 clock ticks. That was acheived on a >10 Meg file, in a DOS BOX
under OS/2. Program reported 6.2 Meg of heap buffer used. That performance was
also across drives that reside on the same hard-disk ie: different partitions
of the same physical hard-disk which means head movement was unavoidable.

    The target drive had 40Meg free. The same transfer from that drive to one
that had only 13 Meg free was 275K /Second which is still pretty good.

Here is the code:
}

program FastCopy;
{$A+,B-,D-,E+,F+,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,$10000}

 const
  MaxBufCnt = 1000;
 type
  BufPtr = ^BufRec;
  BufRec = array[0..8190] of byte;


 var
  InFile, OutFile : file; {IF is In File, OF is OutFile}
  Buffer : array[1..MaxBufCnt] of BufPtr;
  BufLen : array[1..MaxBufCnt] of word;
  BufSiz : array[1..MaxBufCnt] of word;
  BufCnt : byte;
  Total : longint;
  SizeofFile : longint;
  IndexR,IndexW : byte;
  BytesWritten : word;
  BR, BW : longint;
  Timer1,Timer2 : longint;
  Ticks : ^Longint;

begin
 Ticks := Ptr(Seg0040, $006c);
 if paramcount < 2 then begin
  writeln('Usage:', paramstr(0), ' <Infile> <Outfile>');
  halt;
 end;
 assign(InFile, paramstr(1));
 assign(OutFile, paramstr(2));
 writeln;
 writeln('Copying ', paramstr(1), ' to ', paramstr(2));
 reset(InFile, 1);
 rewrite(OutFile, 1);
 BufCnt := 0;
 SizeOfFile := filesize(InFile);
 Total := 0;
 while (MaxAvail>8192) and (BufCnt<MaxBufCnt) and (Total<SizeOfFile) do begin
  Inc(BufCnt);
  if MaxAvail<32768 then
   BufSiz[BufCnt] := MaxAvail
  else
   BufSiz[BufCnt] := 32768;
  getmem(Buffer[BufCnt], BufSiz[BufCnt]);
  BufLen[BufCnt] := 0;
  Total := Total + BufSiz[BufCnt];
 end;
 writeln(Total:10, ' Bytes of buffer used');
 BW := 0;
 BR := 0;
 Timer1 := Ticks^;
 while not eof(InFile) do begin
  IndexR := 0;
  while (not eof(InFile)) and (IndexR < BufCnt) do begin
   Inc(IndexR);
   blockread(InFile, Buffer[IndexR]^, BufSiz[IndexR], BufLen[IndexR]);
   BR := BR + BufLen[IndexR];
   write(#13, BR:10, ' bytes read, ', BW:10, ' bytes written.');
  end;
  for IndexW := IndexR+1 to BufCnt do
   BufLen[IndexW] := 0;
  for IndexW := 1 to IndexR do begin
   BlockWrite(OutFile, Buffer[IndexW]^, BufLen[IndexW], BytesWritten);
   BW := BW + BytesWritten;
   write(#13, BR:10, ' bytes read, ', BW:10, ' bytes written.');
   if BytesWritten <> BufLen[IndexW] then begin
    writeln;
    writeln('Error writing to file... Disk might be full');
    Halt;
   end;
  end;
 end;
 Close(InFile);
 Close(OutFile);
 Timer2 := ticks^;
 writeln;
 writeln('Copy took ', Timer2-Timer1, ' timer ticks to complete');
 writeln('Throughput is ', SizeOfFile div (Timer2-Timer1), ' bytes/tick');
 writeln('or if you prefer ', (SizeOfFile div (Timer2-Timer1)) * 18.2:8:0, '
bytes/second'); for IndexR := 1 to BufCnt do
  freemem(Buffer[IndexR], BufSiz[IndexR]);
 writeln;
 writeln('Copy complete');
end.
{
    Compile to PROTECTED MODE or modify accordingly. No need to reduce the Max
number of buffers. The program initializes it's buffers at the start to take
all available HEAP. The more DPMI memory the happyer it gets!!!

    Again the logic here is to load as much of the file as possible so that you
don't keep moving the heads from the file you are copying to the copy you are
writing.
    Note that the last few buffers won't be perfect multiples of 1024 but that
problem is overcompensated by the fact we are reading so many 32K buffers.

Give it a try and let me know what you think.
}

