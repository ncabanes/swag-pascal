(*
  Category: SWAG Title: STREAM HANDLING ROUTINES
  Original name: 0008.PAS
  Description: LARGE MEMORY STREAMS
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:59
*)


{
  Streams : stream su aree di memoria.
}
unit Streams;

{$V-}
{$IFDEF Final}        { Remove debug code for final version}
{$D-,I-,L-,R-,S-,G+}
{$ELSE}
{$D+,I+,L+,R+,S+}
{$ENDIF}

interface

uses
  Objects,
  Strings,
  Arit;

{--------------------- Classe TMemStream : stream su aree di memoria (< 64KB) }

type
  PMemStream = ^TMemStream;
  TMemStream = object(TStream)
    constructor Init(BlockPtr : PChar; BlockSize : word);
    destructor Done; virtual;
    function GetPos : longint; virtual;
    function GetSize : longint; virtual;
    procedure Read(var Buf; Count : word); virtual;
    procedure Seek(Pos : longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count : word); virtual;
  private
    StartPtr,CurPtr : PChar;
    Size : word;
  end;

{------------------ Classe TBigMemStream : stream su aree di memoria (> 64KB) }

type
  TLongRec = record
    case integer of
      0 : (L : longint);
      1 : (LoW : word;
           HiW : word);
  end;

  PBigMemStream = ^TBigMemStream;
  TBigMemStream = object(TStream)
    constructor Init(BlockPtr : PChar; BlockSize : longint);
    destructor Done; virtual;
    function GetPos : longint; virtual;
    function GetSize : longint; virtual;
    procedure Read(var Buf; Count : word); virtual;
    procedure Seek(Pos : longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count : word); virtual;
  private
    MemOfs : word;
    MemSeg : word;
    CurPos : TLongRec;
    Size : longint;
  end;

{------------------------------------------- Classe TBuffer : buffer dinamici }

type
  PBuffer = ^TBuffer;
  TBuffer = object(TObject)
    Size,Len,AllocSize : word;
    BufPtr : PChar;
    constructor Init(StartSize,Alloc : word);
    destructor Done; virtual;
    function GetLen : word;
    function GetBuffer : PChar;
    procedure Append(const Buf; Count : word);
    procedure Insert(var Buf; Count : word; Pos : word);
    procedure AppendChar(C : char);
    procedure AppendStr(S : PChar);
    procedure Overwrite(var Buf; Count : word; Pos : word);
    procedure Reset;
    procedure Truncate(NewLen : word);
    procedure Delete(From,N : word);
  private
    procedure Realloc(NewLen : word);
  end;

{--------------- Classe TAllocStream : stream di scrittura su buffer dinamici }

type
  PAllocStream = ^TAllocStream;
  TAllocStream = object(TStream)
    constructor Init(StartSize,Alloc : word);
    destructor Done; virtual;
    function GetPos : longint; virtual;
    function GetSize : longint; virtual;
    procedure Seek(Pos : longint); virtual;
    procedure Truncate; virtual;
    procedure Write(var Buf; Count : word); virtual;
    function GetBuffer : PChar;
  private
    CurPos : word;
    Buffer : TBuffer;
  end;

{----------------- Classe TSCollection : collection non ordinate di stringhe  }

type
  PSCollection = ^TSCollection;
  TSCollection = object(TCollection)
    procedure FreeItem(Item : pointer); virtual;
  end;

{-------------------------- Classe TErrCollection : gestione error metodo At  }

type
  PErrCollection = ^TErrCollection;
  TErrCollection = object(TCollection)
    procedure Error(Code,Info : integer); virtual;
  end;

implementation {==============================================================}

uses
  WinTypes,
  WinProcs;

{----------------- Metodi di TMemStream : stream su aree di memoria (< 64 KB) }

constructor TMemStream.Init(BlockPtr : PChar; BlockSize : word);
begin
  inherited Init;
  StartPtr := BlockPtr;
  CurPtr := BlockPtr;
  Size := BlockSize;
end; { Init }

destructor TMemStream.Done;
begin
  StartPtr := nil;
  CurPtr := nil;
  Size := 0;
  inherited Done;
end; { Done }

function TMemStream.GetPos : longint;
begin
  GetPos := CurPtr-StartPtr;
end; { GetPos }

function TMemStream.GetSize : longint;
begin
  GetSize := Size;
end; { GetSize }

procedure TMemStream.Read(var Buf; Count : word);
begin
  if Status = stOk then begin
    if (CurPtr-StartPtr)+Count > Size then begin
      FillChar(Buf,Count,0);
      Error(stReadError,0);
    end else begin
      move(CurPtr^,Buf,Count);
      inc(CurPtr,Count);
    end;
  end;
end; { Read }

procedure TMemStream.Seek(Pos : longint);
begin
  if Pos >= Size then Error(stReadError,0)
  else CurPtr := StartPtr+Pos;
end; { Seek }

procedure TMemStream.Truncate;
begin
  CurPtr := StartPtr;
end; { Truncate }

procedure TMemStream.Write(var Buf; Count : word);
begin
  if Status = stOk then begin
    if (CurPtr-StartPtr)+Count > Size then
      Error(stWriteError,0)
    else begin
      move(Buf,CurPtr^,Count);
      inc(CurPtr,Count);
    end;
  end;
end; { Write }

{-------------- Metodi di TBigMemStream : stream su aree di memoria (> 64 KB) }

procedure AHIncr; far; external 'KERNEL' index 114;

constructor TBigMemStream.Init(BlockPtr : PChar; BlockSize : longint);
begin
  TStream.Init;
  MemSeg := Seg(BlockPtr^);
  MemOfs := Ofs(BlockPtr^);
  CurPos.L := 0;
  Size := BlockSize;
end; { Init }

destructor TBigMemStream.Done;
begin
  MemSeg := 0;
  MemOfs := 0;
  CurPos.L := 0;
  Size := 0;
end; { Done }

function TBigMemStream.GetPos : longint;
begin
  GetPos := CurPos.L;
end; { GetPos }

function TBigMemStream.GetSize : longint;
begin
  GetSize := Size;
end; { GetSize }

procedure TBigMemStream.Read(var Buf; Count : word);
var
  CurPtr : pointer;
  BufPtr : PChar;
  MaxCount : longint;
begin
  if Status = stOk then begin
    if CurPos.L+Count > Size then begin
      FillChar(Buf,Count,0);
      Error(stReadError,0);
    end else begin
      CurPtr := Ptr(MemSeg+CurPos.HiW*Ofs(AHIncr),MemOfs+CurPos.LoW);
      BufPtr := @Buf;
      MaxCount := 65536-CurPos.LoW;
      if Count > MaxCount then begin
        move(CurPtr^,Buf,MaxCount);
        inc(CurPos.L,MaxCount);
        dec(Count,MaxCount);
        inc(BufPtr,MaxCount);
        CurPtr := Ptr(MemSeg+CurPos.HiW*Ofs(AHIncr),MemOfs+CurPos.LoW);
      end;
      move(CurPtr^,BufPtr^,Count);
      inc(CurPos.L,Count);
    end;
  end;
end; { Read }

procedure TBigMemStream.Seek(Pos : longint);
begin
  if Pos >= Size then Error(stReadError,0)
  else CurPos.L := Pos;
end; { Seek }

procedure TBigMemStream.Truncate;
begin
  CurPos.L := 0;
end; { Truncate }

procedure TBigMemStream.Write(var Buf; Count : word);
var
  CurPtr : pointer;
  BufPtr : PChar;
  MaxCount : longint;
begin
  if Status = stOk then begin
    if CurPos.L+Count > Size then
      Error(stWriteError,0)
    else begin
      CurPtr := Ptr(MemSeg+CurPos.HiW*Ofs(AHIncr),MemOfs+CurPos.LoW);
      BufPtr := @Buf;
      MaxCount := 65536-CurPos.LoW;
      if Count > MaxCount then begin
        move(Buf,CurPtr^,MaxCount);
        inc(CurPos.L,MaxCount);
        dec(Count,MaxCount);
        inc(BufPtr,MaxCount);
        CurPtr := Ptr(MemSeg+CurPos.HiW*Ofs(AHIncr),MemOfs+CurPos.LoW);
      end;
      move(BufPtr^,CurPtr^,Count);
      inc(CurPos.L,Count);
    end;
  end;
end; { Write }

{---------------------------------------------------------- Metodi di TBuffer }

constructor TBuffer.Init(StartSize,Alloc : word);
begin
  Size := StartSize;
  AllocSize := Max(16,Alloc);
  Len := 0;
  if Size = 0 then BufPtr := nil
  else begin
    GetMem(BufPtr,Size);
    FillChar(BufPtr^,Size,0);
  end;
end; { Init }

destructor TBuffer.Done;
begin
  if BufPtr <> nil then FreeMem(BufPtr,Size);
end; { Done }

function TBuffer.GetLen : word;
begin
  GetLen := Len;
end; { GetLen }

function TBuffer.GetBuffer : PChar;
begin
  GetBuffer := BufPtr;
end; { GetBuffer }

procedure TBuffer.Realloc(NewLen : word);
var
  Temp : PChar;
begin
  NewLen := ((NewLen+AllocSize) div AllocSize)*AllocSize;
  GetMem(Temp,NewLen);
  FillChar(Temp^,NewLen,#0);
  if BufPtr <> nil then begin
    move(BufPtr^,Temp^,Min(Len,NewLen));
    FreeMem(BufPtr,Size);
  end;
  if (NewLen > Len) then FillChar(Temp[Len],NewLen-Len,#0);
  BufPtr := Temp;
  Size := NewLen;
end; { Realloc }

procedure TBuffer.Append(const Buf; Count : word);
begin
  if Len+Count >= Size then Realloc(Len+Count+1);
  move(Buf,BufPtr[Len],Count);
  inc(Len,Count);
end; { Append }

procedure TBuffer.Insert(var Buf; Count : word; Pos : word);
begin
  if InRange(Pos,0,Len) then begin
    if Len+Count >= Size then Realloc(Len+Count+1);
    if Len > Pos then move(BufPtr[Pos],BufPtr[Pos+Count],Len-Pos);
    move(Buf,BufPtr[Pos],Count);
    inc(Len,Count);
  end;
end; { Insert }

procedure TBuffer.AppendChar(C : char);
begin
  if Len+1 >= Size then Realloc(Len+2);
  BufPtr[Len] := C;
  inc(Len);
end; { AppendChar }

procedure TBuffer.AppendStr(S : PChar);
begin
  if S <> nil then Append(S^,StrLen(S));
end; { AppendStr }

procedure TBuffer.Overwrite(var Buf; Count : word; Pos : word);
begin
  if InRange(Pos,0,pred(Len)) then begin
    Count := Min(Count,Len-Pos);
    move(Buf,BufPtr[Pos],Count);
  end;
end; { Overwrite }

procedure TBuffer.Reset;
begin
  Len := 0;
  FillChar(BufPtr^,Size,#0);
end; { Reset }

procedure TBuffer.Truncate(NewLen : word);
begin
  if NewLen < Len then begin
    if Size-NewLen > AllocSize then Realloc(NewLen);
    Len := NewLen;
    FillChar(BufPtr[Len],Size-Len,#0);
  end;
end; { Truncate }

procedure TBuffer.Delete(From,N : word);
var
  Last : word;
begin
  if (From < Len) and (N > 0) then begin
    Last := From+N;
    if Last < Len then move(BufPtr[Last],BufPtr[From],succ(Len-Last));
    Truncate(Len-N);
  end;
end; { Delete }

{----------------------------------------------------- Metodi di TAllocStream }

constructor TAllocStream.Init(StartSize,Alloc : word);
begin
  inherited Init;
  Buffer.Init(StartSize,Alloc);
  CurPos := 0;
end; { Init }

destructor TAllocStream.Done;
begin
  Buffer.Done;
  inherited Done;
end; { Done }

function TAllocStream.GetPos : longint;
begin
  GetPos := CurPos;
end; { GetPos }

function TAllocStream.GetSize : longint;
begin
  GetSize := Buffer.GetLen;
end; { GetSize }

procedure TAllocStream.Seek(Pos : longint);
begin
  if (Pos > Buffer.GetLen) or (Pos < 0) then Error(stWriteError,0)
  else CurPos := Pos;
end; { Seek }

procedure TAllocStream.Truncate;
begin
  if CurPos < Buffer.GetLen then Buffer.Truncate(succ(CurPos));
end; { Truncate }

procedure TAllocStream.Write(var Buf; Count : word);
var
  Len : word;
  B : array[0..65000] of char absolute Buf;
begin
  if Status = stOk then begin
    Len := Buffer.GetLen;
    if CurPos >= Len then Buffer.Append(Buf,Count)
    else begin
      Buffer.Overwrite(Buf,Min(Count,Len-CurPos),CurPos);
      if Count > Len-CurPos then
        Buffer.Append(B[Len-CurPos],Count-Len+CurPos);
    end;
    inc(CurPos,Count);
  end;
end; { Write }

function TAllocStream.GetBuffer : PChar;
begin
  GetBuffer := Buffer.GetBuffer;
end; { GetBuffer }

{----------------- Classe TSCollection : collection non ordinate di stringhe  }

procedure TSCollection.FreeItem(Item : pointer);
begin
  StrDispose(PChar(Item));
end; { FreeItem }

{-------------------------- Classe TErrCollection : gestione error metodo At  }

procedure TErrCollection.Error(Code,Info : integer);
var
  ErrDesc : record
    ErrCode : integer;
    ErrPosHi : word;
    ErrPosLo : word;
    ErrIndex : integer;
    ErrCount : integer;
  end;
  Buffer : array[0..80] of char;
begin
  asm
    mov   cx,[BP+20]
    mov   bx,[BP+22]
    verr  bx
    je    @1
    mov   bx,$FFFF
    mov   cx,bx
    jmp   @2
@1:
    mov   es,bx
    mov   bx,word ptr es:0
@2:
    mov   ErrDesc.ErrPosLo,cx
    mov   ErrDesc.ErrPosHi,bx
  end;
  ErrDesc.ErrCode := 212-Code;
  ErrDesc.ErrIndex := Info;
  ErrDesc.ErrCount := Count;
  WVSPrintF(Buffer,'Runtime error %d at %04X:%04X with index %d; Count=%d',ErrDesc);
  MessageBox(0,Buffer,nil,mb_Ok or mb_SystemModal);
  halt(0);
end; { Error }

{----------------------------------------------------------------------- Main }

end. { unit Streams }

