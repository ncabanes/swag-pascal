(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0050.PAS
  Description: TStream for XMS
  Author: HELGE HELGESEN
  Date: 05-25-94  08:11
*)


{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V-,X+,Y+}
{.$DEFINE OPRO}
{
  This unit adds an XMS-memory stream to TStream or IdStream
  depending on the define above.
  (c) 1994 Helge Olav Helgesen
  If you have any comments, please leave them in the Pascal
  conference on Rime or U'NI, or on InterNet to me at
  helge.helgesen@midnight.powertech.no
}
{$IFNDEF MSDOS}
  !! This unit must be compiled under real mode !!
{$ENDIF}
Unit Xms;

interface

uses
{$IFDEF OPRO}
  OpRoot,
{$ELSE}
  Objects,
{$ENDIF}
  OpDos, OpXms;

type
  PXmsStream = ^TXmsStream; { pointer to TXmsStream }
  TXmsStream = object({$IFDEF OPRO}IdStream{$ELSE}TStream{$ENDIF})
    XmsSizeInK, { allocated size in kilobytes }
    XmsHandle: word; { XMS Handle }
    TotalSize, { total size in bytes }
    CurOfs, { current offset into the stream }
    UsedSize: longint; { size of used stream }

    constructor Init(MemNeeded: word); { allocate ext. memory and init vars }
    destructor  Done; virtual; { deallocate ext. memory }

    procedure   Seek(WhereTo: longint); virtual; { seek within stream }
    function    GetPos: longint; virtual; { get curret offset }
    function    GetSize: longint; virtual; { get used size of stream }
    procedure   SetPos(Ofs: longint; Mode: byte); virtual; { seek using POS mode
 }

    procedure   Truncate; virtual; { truncate stream to current size }

    procedure   Write(var Buf; Count: Word); virtual; { writes Buf to the stream
 }
    procedure   Read(var Buf; Count: Word); virtual; { reads Buf from the stream
 }
  end; { TXmsStream }

{$IFNDEF OPRO}
var
  InitStatus: byte; { detailed error code from last Init or Done }
{$ENDIF}

const
  RealMemHandle = 0; { handle for Real Memory }
{$IFNDEF OPRO}
  PosAbs     = 0;               {Relative to beginning}
  PosCur     = 1;               {Relative to current position}
  PosEnd     = 2;               {Relative to end}
{$ENDIF}

{$IFDEF OPRO}
procedure SaveStream(const FileName: string; var S: IdStream);
  { Saves a stream to disk, old file is erased! }
procedure LoadStream(const FileName: string; var S: IdStream);
  { Loads a stream from disk }
{$ELSE}
procedure SaveStream(const FileName: string; var S: TStream);
  { Saves a stream to disk, old file is erased! }
procedure LoadStream(const FileName: string; var S: TStream);
  { Loads a stream from disk }
{$ENDIF}

implementation

constructor TXmsStream.Init;
  { You should already have tested if XMS is installed! }
begin
  if not inherited Init then Fail;
  InitStatus:=AllocateExtMem(MemNeeded, XmsHandle);
  if InitStatus>0 then Fail;
  XmsSizeInK:=MemNeeded;
  TotalSize:=LongInt(MemNeeded)*LongInt(1024);
  UsedSize:=0;
  CurOfs:=0;
end; { TXmsStream }

destructor TXmsStream.Done;
begin
  FreeExtMem(XmsHandle);
  inherited Done;
end; { TXmsStream.Done }

procedure TXmsStream.Seek;
begin
{$IFDEF OPRO}
  if idStatus=0 then
{$ELSE}
  if Status=stOk then
{$ENDIF}
  CurOfs:=WhereTo;
end; { TXmsStream }

function TXmsStream.GetPos;
begin
{$IFDEF OPRO}
  if idStatus=0 then
{$ELSE}
  if Status=stOk then
{$ENDIF}
  GetPos:=CurOfs else GetPos:=-1;
end; { TXmsStream.GetPos }

function TXmsStream.GetSize;
begin
{$IFDEF OPRO}
  if idStatus=0 then
{$ELSE}
  if Status=stOk then
{$ENDIF}
  GetSize:=UsedSize else GetSize:=-1;
end; { TXmsStream.GetSize }

procedure TXmsStream.Truncate;
begin
{$IFDEF OPRO}
  if idStatus=0 then
{$ELSE}
  if Status=stOk then
{$ENDIF}
  UsedSize:=CurOfs;
end; { TXmsStream.Truncate }

procedure TXmsStream.Write;
var
  NumberisOdd: boolean;
  x: word;
  Source, Dest: ExtMemPtr;
begin
{$IFDEF OPRO}
  if idStatus<>0 then
{$ELSE}
  if Status<>stOk then
{$ENDIF}
  Exit;
  if LongInt(Count)+LongInt(CurOfs)>LongInt(TotalSize) then
  begin
{$IFDEF OPRO}
    Error(101); { disk write error }
{$ELSE}
    Error(stWriteError, 0);
{$ENDIF}
    Exit;
  end; { if }
  NumberIsOdd:=Odd(Count);
  if NumberIsOdd then Dec(Count);
  Source.RealPtr:=@Buf;
  Dest.ProtectedPtr:=CurOfs;
  if Count>0 then
  x:=MoveExtMemBlock(Count, RealMemHandle, Source, { source data }
                     XmsHandle, Dest) { dest data }
  else x:=0;
  if x>0 then { new error }
  begin
{$IFDEF OPRO}
    Error(101); { disk write error }
{$ELSE}
    Error(stWriteError, x);
{$ENDIF}
    Exit;
  end; { if }
  Inc(CurOfs, Count); { adjust current offset }
  if CurOfs>UsedSize then UsedSize:=CurOfs;
  if not NumberisOdd then Exit;
  asm { get last byte to transfer }
    les  di, Buf
    mov  bx, Count
    mov  ax, es:[di+bx]
    inc  Count
    mov  x, ax
  end; { asm }
  Source.RealPtr:=@x;
  Inc(Dest.ProtectedPtr, Count-1);
  Count:=2;
  x:=MoveExtMemBlock(Count, RealMemHandle, Source, { source data }
                     XmsHandle, Dest); { dest data }
  if x>0 then { new error }
  begin
{$IFDEF OPRO}
    Error(101); { disk write error }
{$ELSE}
    Error(stWriteError, x);
{$ENDIF}
    Exit;
  end; { if }
  Inc(CurOfs);
  if CurOfs>UsedSize then UsedSize:=CurOfs;
end; { TXmsStream.Write }

procedure TXmsStream.Read;
var
  NumberisOdd: boolean;
  x: word;
  Source, Dest: ExtMemPtr;
begin
{$IFDEF OPRO}
  if idStatus<>0 then
{$ELSE}
  if Status<>stOk then
{$ENDIF}
  Exit;
  if LongInt(CurOfs)+LongInt(Count)>LongInt(UsedSize) then
  begin { read error }
{$IFDEF OPRO}
    Error(100); { read error }
{$ELSE}
    Error(stReadError, 0);
{$ENDIF}
    Exit;
  end; { if }
  NumberisOdd:=Odd(Count);
  if NumberisOdd then Inc(Count);
  Source.ProtectedPtr:=CurOfs;
  Dest.RealPtr:=@Buf;
  x:=MoveExtMemBlock(Count, XmsHandle, Source, { source data }
                     RealMemHandle, Dest); { dest data }
  if x>0 then
  begin
{$IFDEF OPRO}
    Error(100); { read error }
{$ELSE}
    Error(stReadError, x);
{$ENDIF}
    Exit;
  end; { if }
  if NumberisOdd then Dec(Count);
  Inc(CurOfs, Count);
end; { TXmsStream.Read }

procedure TXmsStream.SetPos;
begin
  case Mode of
    PosAbs: Seek(Ofs);
    PosCur: Seek(LongInt(Ofs)+LongInt(CurOfs));
    PosEnd: Seek(LongInt(UsedSize)-LongInt(Ofs));
  end; { case }
end; { TXmsStream.SetPos }

procedure SaveStream;
{
  Saves the stream to disk. No errorchecking is done
}
var
  Buf: pointer;
  x, BufSize: word;
  f: file;
  OldPos, l: longint;
begin
  Assign(f, FileName);
  Rewrite(f, 1);
  if S.GetSize=0 then
  begin
    Close(f);
    Exit;
  end; { if }
  if MaxAvail>65520 then BufSize:=65520 else BufSize:=MaxAvail;
  GetMem(Buf, BufSize);
  OldPos:=S.GetPos;
  l:=S.GetSize;
  S.Seek(0);
  while l<>0 do
  begin
    if l>BufSize then x:=BufSize else x:=l;
    S.Read(Buf^, x);
{$IFDEF OPRO}
    if S.PeekStatus<>0 then
{$ELSE}
    if S.Status<>0 then
{$ENDIF}
    begin
      Close(f);
      Exit;
    end; { if }
    BlockWrite(f, Buf^, x);
    Dec(l, x);
  end; { while }
  Close(f);
  FreeMem(Buf, BufSize);
  S.Seek(OldPos);
end; { SaveStream }

procedure LoadStream;
{
  Loads the stream from disk. No errorchecking is done, you must allocate
  enough memory yourself! Any old contents of the stream is erased.
}
var
  f: file;
  BufSize, x: word;
  l: longint;
  Buf: pointer;
begin
  if not ExistFile(FileName) then Exit;
  Assign(f, FileName);
  Reset(f, 1);
  S.Seek(0);
  S.Truncate;
  l:=FileSize(f);
  if l>0 then
  begin
    if MaxAvail>65520 then BufSize:=65520 else BufSize:=MaxAvail;
    GetMem(Buf, BufSize);
    while l<>0 do
    begin
      BlockRead(f, Buf^, BufSize, x);
      S.Write(Buf^, x);
{$IFDEF OPRO}
      if S.PeekStatus<>0 then
{$ELSE}
      if S.Status<>0 then
{$ENDIF}
      begin
        Close(f);
        Exit;
      end; { if }
      Dec(l, x);
    end; { while }
    FreeMem(Buf, BufSize);
  end; { if }
  Close(f);
  S.Seek(0);
end; { LoadStream }

end.

