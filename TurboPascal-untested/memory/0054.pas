{
*************** Generalized file I/O buffering *****************

The enclosed TP unit BUFFERS exports a new object BUFFERFILE. This
object allows to define a variable number of buffers with a buffersize
of up to $FFE0 bytes each. It exports a number of methods to tailor
the behaviour of the buffer to a specific applications needs - See the
following procedures for details in this area:

 - SETWRITEBIAS
 - SETREADBIAS
 - RESETBIAS
 - ENABLEINBOUND
 - ENABLEOUTBOUND
 - DISABLEINBOUND
 - DISABLEOUTBOUND

The buffers may be allocated in expanded memory if desired. Performance
will be somewhat affected by this fact.

All methods use the same names as their counterparts in the system unit,
the there should not be any problem implementing them. The only minor
difference is the fact, that the READ and WRITE procedures do not accept
the optional fourth parameter, which in the system unit will return the
number of bytes actually read or written. This was done for performance
reasons but should be very easy to change.

The unit is implemented using some of Turbo Pascals object oriented
language constructs (actually my second step in this area). Some of the
object oriented stuff is not really very pure code - some access to the
imported data areas is direct, etc. This was done as to achieve some decent
performance.

Last but not least a small example on how to use the code:

Program Test;
VAR
  BF : BufferFile;
  L  : LongInt;
begin
  BF.Init(16384,5,True);
  BF.SetWriteBias;           {Purely optional - may improve performance}
  BF.Assign('TEST.FIL');
  BF.Rewrite(4);
  For L:=1 to 20000 do BF.Write(L,1);
  BF.Done;
end.

The code is herbey given to the public domain. If you discover any errors,
I would appreciate if you would let me know.

Rolf Ernst 72311,254
}

Unit Buffers;

InterFace
{*********************************************************************}
{****              Written 1989 by Rolf Ernst                     ****}
{****                                                             ****}
{****  Code requires Turbo Professional for the expanded memory   ****}
{****  access. The procedures used should not take more than a    ****}
{****  few lines to reproduce though.                             ****}
{****                                                             ****}
{****  This code is hereby in the public domain.                  ****}
{*********************************************************************}

Uses Dos, TpEms;

Type
  PtrRec = Record
    Ofs, Seg : Word;
  end;

  BigBlock = Array[0..1] Of Byte;
  BigBlockPtr = ^BigBlock;
  BufferPtr = ^BufferDesc;
  BufferDesc = object
    BufferAddr : BigBlockPtr;
    EmsHandle  : Word;
    InEms      : Boolean;
    Size       : Word;
    Next       : Pointer;
    Constructor Init(BufferSize : Word; UseEms : Boolean);
    Function    Map(Offset, Length : Word) : BigBlockPtr; Virtual;
    Destructor  Done;
  end;

  FileBufferPtr = ^FileBufferDesc;
  FileBufferDesc = Object(BufferDesc)
    PosBuffer   : LongInt;
    BytesUsed   : Word;
    Initialized : Boolean;
    Modified    : Boolean;
    Constructor Init(BufferSize : Word; UseEms : Boolean);
  end;

  BufferChain = object
    NumberOfBuffers, BlockSize:Word;
    BufferHead, BufferTail : FileBufferPtr;
    Procedure Init(BufSize, BufNum : Word; UseEms : Boolean);
    Procedure ChainAtEnd(VAR B : FileBufferPtr);
    Function  BuffersUnUsed:Word;
    Procedure Done;
  end;

  BufferFile=Object
    F              : File;
    FSize          : LongInt;
    CurrentPos     : LongInt;
    RecordSize     : Word;
    BlockSize      : Word;
    BufferS        : BufferChain;
    FlushAll       : Boolean;
    ReadAll        : Boolean;
    NoBufferReads  : Boolean;
    NoBufferWrites : Boolean;
    NoBufferIng    : Boolean;

    Procedure Init(BufSize, BufNum:Word; UseEms : Boolean);
              {Initialize BufNum buffers for the file, each being
               Bufsize bytes big - use Expanded memory if UseEms is TRUE}

    Procedure Flush;
              {Write all modified buffers to disk - does not cause DOS to
               flush its buffers}

    Function  FreeBuffer : FileBufferPtr;
              {Find an available Buffer - Flush a buffer if necessary}

    Procedure Read(VAR A; NumRecs : Word);
              {Read a record buffered}

    Procedure DisableOutBound;
              {Disable buffering when writing to a file}

    Procedure Write(VAR A; NumRecs : Word);
              {Write a record buffered}

    Function  Eof:Boolean;
              {Return true if the current position in the file is at its end}

    Procedure Seek(NewPos : LongInt);
              {Go to a new position in the file}

    Function  FileSize:LongInt;
              {Returns the size of a buffered file taking any data in the
               buffers into consideration}

    Procedure Assign(Name : PathStr);
              {Assign a name to a buffered file}

    Function  FilePos:LongInt;
              {Returns the current position in a buffered file}

    Procedure Rewrite(RecSize : Word);
              {Create a new file or overwrite an existing one}

    Procedure Reset(RecSize:Word);
              {Open an existing file}

    Procedure SetWriteBias;
              {Indicate, that the majority of the file operations will be
               sequential writes - when a buffer needs to be flushed ALL
               buffers will be flushed}

    Procedure SetReadBias;
              {Indicate, that the majority of the file operations will be
               sequential reads - when a buffer needs to be read ALL buffers
               will be read from disk}

    Procedure ResetBias;
              {Reset file access characteristics to its default values}

    Procedure DisableInBound;
              {Disable buffering when reading from a dataset}

    Procedure EnableInBound;
              {Enable buffering when reading from a dataset}

    Procedure EnableOutBound;
              {Enable buffering when writing to a dataset}

    Procedure Done;
              {Close the file and free all buffers}

  end;


Implementation



Procedure EmsError;
begin
  Writeln('Severe Error in EMS handler');
  readln;
  halt;
end;

Function MemToEms(BytesIn : LongInt) : Word;
begin
  MemToEms:=(BytesIn+16383) shr 14;
end;

Procedure MapBuffer(Handle : Word; BytesInBuffer:Word);
VAR
  I : Word;
begin
  For I:=0 to Pred(MemToEms(BytesInBuffer)) do begin
    If Not MapEmsPage(Handle,i,i) then EmsError;
  end;
end;

Procedure BufferFile.SetWriteBias;
begin
  FlushAll:=True;
  ReadAll:=False;
end;

Procedure BufferFile.DisableInBound;
begin
  NoBufferReads:=True;
end;

Procedure BufferFile.EnableInBound;
begin
  NoBufferReads:=false;
end;

Procedure BufferFile.DisableOutBound;
begin
  Flush;
  NoBufferWrites:=True;
end;

Procedure BufferFile.EnableOutBound;
begin
  NoBufferWrites:=False;
end;

Procedure BufferFile.ResetBias;
begin
  FlushAll:=False;
  ReadAll:=False;
  NoBufferReads:=False;
  NoBufferWrites:=False;
end;

Procedure BufferFile.SetReadBias;
begin
  FlushAll:=False;
  ReadAll:=True;
end;


Constructor BufferDesc.Init(BufferSize : Word; UseEms : Boolean);
begin
  InEms:=UseEms and EmsInstalled and
    (EmsPagesAvail>=MemToEms(Buffersize));
  Size:=BufferSize;
  If InEms then begin
    EmsHandle:=AllocateEMSPages(MemToEms(Size));
    If EmsHandle=EmsErrorCode then EmsError;
    BufferAddr:=EmsPageFramePtr;
  end else GetMem(BufferAddr,Size);
  Next:=Nil;
end;

Function BufferDesc.Map(Offset, Length : Word) : BigBlockPtr;
VAR
  HighOffset : Word;
  MyPointer  : BigBlockPTr;
begin
  MyPointer:=BufferAddr;
  Inc(PtrRec(MyPointer).Ofs,Offset);
  Map:=MyPointer;
  If InEms then begin
    HighOffset:=Pred(Offset+Length);
    Offset:=Offset Shr 14;
    HighOffset:=HighOffset shr 14;
    repeat
      If Not MapEmsPage(EMSHandle,Offset,Offset) then EmsError;
      INC(Offset);
    until Offset>HighOffset;
  end;
end;

Destructor BufferDesc.Done;
begin
  IF InEms then begin
    If Not DeallocateEmsHandle(Emshandle) then EmsError;
  end else FreeMem(BufferAddr,Size);
end;

Constructor FileBufferDesc.Init(BufferSize : Word; UseEms : Boolean);
begin
  BufferDesc.Init(BufferSize, UseEms);
  Initialized:=False;
  Modified:=False;
end;

Procedure BufferChain.Init(BufSize, BufNum : Word; UseEms : Boolean);
VAR
  I : Word;
begin
  NumberOfBuffers:=BufNum;
  BufferTail:=Nil;
  For i:=1 to BufNum do begin
    New(BufferHead,Init(BufSize,UseEms));
    BufferHead^.Next:=BufferTail;
    BufferTail:=BufferHead;
  end;
  While BufferTail^.Next<>Nil do BufferTail:=BufferTail^.Next;
end;

Procedure BufferChain.ChainAtEnd(VAR B : FileBufferPtr);
VAR
  BufPtr:FileBufferPtr;
begin
  If (NumberOfBuffers>1) and (B<>BufferTail) then begin
    BufferTail^.Next:=B;
    BufferTail:=B;
    If B=BufferHead then begin
      BufferHead:=B^.Next;
      B^.Next:=Nil;
    end else begin
      Bufptr:=BufferHead;
      While BufPtr^.Next<>B do Bufptr:=BufPtr^.Next;
      BufPtr^.Next:=B^.Next;
      B^.Next:=Nil;
    end;
  end;
end;


Procedure BufferFile.Init(BufSize, BufNum:Word; UseEms : Boolean);
VAR
  I : Word;
begin
  If (BufSize=0) or (BufNum=0) then begin
    NoBufferIng:=True;
    exit;
  end;
  UseEms:=UseEms and EmsInstalled and
    (EmsPagesAvail>=BufNum * MemToEms(Bufsize));
  Buffers.Init(BufSize, BufNum, USeEms);
  FlushAll:=False;
  ReadAll:=False;
  NoBufferReads:=False;
  NoBufferWrites:=False;
  NoBuffering:=False;
  BlockSize:=BufSize;
end;

Function BufferFile.FreeBuffer:FileBufferPtr;
VAR
  BufPtr,SavePtr : FileBufferPtr;
  LowPos : LongInt;
  MyPointer : Pointer;
begin
  BufPtr:=Buffers.BufferHead;
  LowPos:=$7fffffff;
  While BufPtr<>Nil do begin
    With BufPtr^ do begin
      If (Not Modified) or (Not initialized) then begin
        FreeBuffer:=BufPtr;
        Modified:=False;
        FreeBuffer:=BufPtr;
        Buffers.ChainAtEnd(BufPtr);
        Exit;
      end;
      If PosBuffer<LowPos then begin
        LowPos:=PosBuffer;
        SavePtr:=BufPtr;
      end;
      BufPtr:=Next;
    end;
  end;
  If FlushAll then begin
    Flush;
    FreeBuffer:=Buffers.BufferHead;
  end;
  With SavePtr^ do begin
    System.Seek(F,PosBuffer);
    MyPointer:=Map(0,BytesUsed);
    BlockWrite(F,MyPointer^,BytesUsed);
    BytesUsed:=0;
    Modified:=False;
  end;
  FreeBuffer:=SavePtr;
  Buffers.ChainAtEnd(SavePtr);
end;

Procedure BufferFile.Flush;
VAR
  BufPtr : FileBufferPtr;
  MyPointer : Pointer;
begin
  If NoBuffering then exit;
  BufPtr:=Buffers.BufferHead;
  While BufPtr<>Nil do begin
    With BufPTr^ do begin
      If Modified then begin
        System.Seek(F,PosBuffer);
        MyPointer:=Map(0,BytesUsed);
        BlockWrite(F,BufferAddr^,BytesUsed);
        Modified:=False;
      end;
      BufPtr:=Next;
    end;
  end;
end;

Function  BufferCHain.BuffersUnUsed:Word;
VAR
  BufPtr : FileBufferPtr;
  Count : Word;
begin
  Count:=0;
  BufPtr:=BufferHead;
  While BufPtr<>Nil do begin
    With BufPtr^ do begin
      If (Not Initialized) or (Not Modified) then Inc(Count);
      BufPtr:=Next;
    end;
  end;
  BuffersUnUsed:=Count;
end;

Function BufferFile.FileSize:LongInt;
begin
  If NoBuffering then FileSize:=System.FIleSize(F) else
    FileSize:=Fsize div RecordSize;
end;

Function BufferFile.FilePos:LongInt;
begin
  If NoBuffering then FilePos:=System.FilePos(F) else
    FilePos:=CurrentPos div RecordSize;
end;

Procedure BufferFile.Read(VAR A; NumRecs : Word);
VAR
  I,J    : Word;
  BufPtr   :  FileBufferPtr;
  TargetPtr : BigBlockPtr;
  More  : Boolean;
  BaseBufferToGet : LongInt;
  MyPointer : Pointer;
begin
  If NoBuffering then BlockRead(F,A,NuMRecs) else begin
    NumRecs:=NumRecs*RecordSize;
    TargetPtr:=@A;
    Repeat
      BaseBufferToGet:=CurrentPos-(CurrentPos Mod BlockSize);
      BufPtr:=Buffers.BufferHead;
      More:=True;
      While (BufPtr<>Nil) and More Do begin
        With BufPtr^ do begin
          If (PosBuffer=BaseBufferToGet) and Initialized then more:=False else
          BufPtr:=Next;
        end;
      end;
      If BufPtr=Nil then begin
        If NoBufferReads then begin
          System.Seek(F,CurrentPos);
          BlockRead(F,TargetPtr^,NumRecs);
          Inc(CurrentPos,NumRecs);
          exit;
        end;
        BufPtr:=FreeBuffer;
        With BufPtr^ do begin
          System.Seek(F,BaseBufferToGet);
          PosBuffer:=BaseBufferToGet;
          MyPointer:=Map(0,BlockSize);
          BlockRead(F,MyPointer^,BlockSize,BytesUsed);
          Initialized:=True;
        end;
        If ReadAll then begin
          J:=Buffers.BuffersUnUsed;
          If J>0 then Dec(j);
          I:=1;
          While (I<= J) and (BufPtr^.BytesUsed=BlockSize) do begin
            Inc(BaseBufferToGet,BlockSize);
            BufPtr:=FreeBuffer;
            With BufPtr^ do begin
              PosBuffer:=BaseBufferToGet;
              MyPointer:=Map(0,BlockSize);
              BlockRead(F,MyPointer^,BlockSize,BytesUsed);
              Initialized:=True;
            end;
            Inc(I);
          end;
        end;
      end else begin
        With BufPtr^ do begin
          J:=CurrentPos-PosBuffer;
          I:=BytesUsed-j;
          If I>NumRecs then I:=NumRecs;
          MyPointer:=Map(J,I);
          Move(MyPointer^,TargetPtr^,I);
          Inc(CurrentPos,I);
          Dec(NumRecs,I);
          Inc(PtrRec(TargetPtr).Ofs,I);
        end;
      end;
    until NumRecs=0;
  end;
end;

Procedure BufferFile.Write(VAR A; NumRecs : Word);
VAR
  I,J : WOrd;
  BufPtr : FileBufferPtr;
  TargetPTr,MyPointer : Pointer;
  BaseBufferToGet : LongInt;
  BytesNeeded : LongInt;
  OK,More : Boolean;
begin
  If NoBuffering then BlockWrite(F,A,NumRecs) else begin
    TargetPtr:=@A;
    NumRecs:=NumRecs*RecordSize;
    Repeat
      BaseBufferToGet:=CUrrentPos-(CurrentPos Mod BlockSize);
      BufPtr:=Buffers.BufferHead;
      More:=True;
      While (BufPtr<>Nil) and More Do begin
        With BufPtr^ do begin
          If (Initialized) and (BaseBufferToGet=PosBuffer) then begin
            BytesNeeded:=CurrentPos-PosBuffer+NumRecs;
            If BytesNeeded>BytesUsed then begin
              If BytesNeeded>BlockSize then BytesUsed:=BlockSize else
              BytesUsed:=BytesNeeded;
              Fsize:=BaseBufferToGet+BytesUsed;
            end;
            More:=False;
          end else BufPtr:=Next;
        end;
      end;
      If BufPtr=Nil then begin
        If NoBufferWrites then begin
          If BaseBufferToGet<>CurrentPos then begin
            System.Seek(F,CurrentPos);
            BlockWrite(F,A,NumRecs);
            Inc(CurrentPos,NumRecs);
            exit;
          end;
        end;
        BufPtr:=FreeBuffer;
        With BufPtr^ do begin
          System.Seek(F,BaseBufferToGet);
          PosBuffer:=BaseBufferToGet;
          If PosBuffer<SyStem.FileSize(F) then begin
            MyPointer:=Map(0,BlockSize);
            BlockRead(F,MyPointer^,BlockSize,BytesUsed);
          end else BytesUsed:=0;
          Initialized:=True;
        end;
      end else begin
        With BufPtr^ do begin
          J:=CurrentPos-PosBuffer;
          I:=BytesUsed-j;
          If I>NumRecs then I:=NumRecs;
          MyPointer:=Map(J,I);
          Move(TargetPtr^,MyPointer^,I);
          Modified:=True;
          Inc(CurrentPos,I);
          Dec(NumRecs,I);
          Inc(PtrRec(TargetPtr).Ofs,I);
        end;
      end;
    until NumRecs=0;
  end;
end;

Function BufferFile.Eof:Boolean;
begin
  If NoBuffering then Eof:=System.Eof(F) else
    Eof:=CurrentPos=Fsize;
end;

Procedure BufferFile.Seek(NewPos : LongInt);
begin
  If NoBuffering then System.Seek(F,Newpos) else
    CurrentPos:=NewPos*RecordSize;
end;

Procedure BufferFile.Assign(Name : PathStr);
begin
  System.Assign(F,Name);
end;

Procedure BufferFile.Rewrite(RecSize:Word);
begin
  RecordSize:=RecSize;
  If Not NoBuffering then Recsize:=1;
  System.Rewrite(F,RecSize);
  Fsize:=0;
  CurrentPos:=0;
end;

Procedure BufferFile.Reset(RecSize : Word);
begin
  RecordSize:=RecSize;
  If Not NoBuffering then RecSize:=1;
  System.Reset(F,RecSize);
  Fsize:=System.FileSize(F);
  CurrentPos:=0;
end;

Procedure BufferChain.Done;
begin
  repeat
    with BufferHead^ do begin
      BufferTail:=BufferHead^.Next;
      Dispose(BufferHead,Done);
      BufferHead:=BufferTail;
    end;
  until Bufferhead=Nil;
end;

Procedure BufferFile.Done;
VAR
  BufferTail : BufferPtr;
  Ok : Boolean;
begin
  Flush;
  Close(F);
  If Not NoBuffering then Buffers.Done;
end;
end.

