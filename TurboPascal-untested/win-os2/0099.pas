
Hi,
  Below I attach a TPW 1.5 unit  which provides a dynamically sized
memory stream with no 64K limit. Enjoy.

Eyal Doron

--------------------------Cut here--------------------------
{===============================================================================}
{ Unit wHugeMem, written by Eyal Doron,
1997.                                   }
{                                                                              
}
{ This unit implements a memory stream which is allocated from the
global       }
{ Windows memory pool. The size of the memory stream grows dynamically,
and     }
{ is limited only by the available real and virtual memory. Uses
include:       }
{ * A temporary
stream.                                                         }
{ * A convenient method to randomly access or write to a memory
handle.         }
{                                                                              
}
{
Variables:                                                                   
}
{   Handle - The actual memory
handle.                                          }
{   Size   - The current size of the
stream.                                    }
{   AllocSize - The amount of currently allocated
memory.                       }
{   Base   - A pointer to the beginning of the allocated
memory.                }
{   Owner  - A boolean which determines if the stream owns the handle.
If so,   }
{            the memory will be de-allocated in the destructor,
otherwise no.   }
{   ReallyTruncate - A boolean which determines if Truncate calls
will          }
{                    also de-allocate memory. The default is no, to
speed up    }
{                   
access.                                                    }
{                                                                              
}
{
Constructors:                                                                
}
{                                                                              
}
{
Init(InitialSize)                                                            
}
{   Initialize a new memory stream, and allocate "InitialSize" bytes.
Note      }
{   that the size of the stream, in contrast to the allocated memory, is
zero.  }
{ InitExt(ExtHandle: THandle; InitialSize: longint; AOwner:
boolean)            }
{   Initialize a new memory stream, using an externally provided memory
handle. }
{   Specifying InitialSize=-1 will take it to be given by the allocated
size    }
{   of the memory
block.                                                        }
{===============================================================================}

{$W-,R+,G+}
Unit WHugeMem;

{ Implements a memory stream }

interface

Uses
  WObjects,WinTypes,WinProcs;

type
  TLongType = record
    case Word of
      0: (Ptr: Pchar);
      1: (Long: Longint);
      2: (Lo: Word; Hi: Word);
  end;

  PHugeMemStream = ^THugeMemStream;
  THugeMemStream = object(TStream)
    Size,Current,AllocSize: longint;
    Handle: THandle;
    Base  : TLongType;
    Owner,ReallyTruncate: boolean;
    constructor Init(InitialSize: longint);
    constructor InitExt(ExtHandle: THandle; InitialSize: longint;
AOwner: boolean);
    function    GetPos : longint;   virtual;
    function    GetSize: longint;   virtual;
    procedure   Seek(Pos: Longint); virtual;
    procedure   Truncate;           virtual;
    procedure   Read(var Buf;  Count: Word); virtual;
    procedure   Write(var Buf; Count: Word); virtual;
    destructor  Done; virtual;
  end;

implementation

const
  K64 = $10000;

procedure AHIncr; far; external 'KERNEL' index 114;



{ THugeMemStream methods }

constructor THugeMemStream.init(InitialSize: longint);
begin
  TStream.init;
  Size:=0; Current:=0; AllocSize:=0; Base.Ptr:=Nil; Handle:=0;
  ReallyTruncate:=false;
  if InitialSize>0 then
  begin
    Handle:=GlobalAlloc(GMEM_Moveable,InitialSize);
    AllocSize:=GlobalSize(Handle);
    Base.Ptr:=GlobalLock(Handle);
  end;
  Owner:=true;
end;              { THugeMemStream.init }

constructor THugeMemStream.initExt(ExtHandle: THandle; InitialSize:
longint;
                                   AOwner: boolean);
begin
  TStream.init;
  AllocSize:=GlobalSize(ExtHandle);
  if InitialSize=-1 then InitialSize:=AllocSize;
  Size:=InitialSize; Current:=0; Base.Ptr:=Nil; Handle:=0;
  ReallyTruncate:=false;
  if InitialSize>0 then
  begin
    Handle:=ExtHandle; Base.Ptr:=GlobalLock(Handle);
  end;
  Owner:=AOwner;
end;              { THugeMemStream.init }

function THugeMemStream.GetPos: longint;
begin GetPos:=Current; end;

function THugeMemStream.GetSize: longint;
begin GetSize:=Size; end;

procedure THugeMemStream.Seek(Pos: Longint);
begin
  if Status<>stOK then Exit;
  if (Pos<0) or (Pos>Size) then Error(stReadError,0)
  else Current:=Pos;
end;

procedure THugeMemStream.Truncate;
begin
  if Status<>stOK then Exit;
  Size:=Current;
  if ReallyTruncate then
    GlobalRealloc(Handle,Size,GMEM_ZeroInit);
  { Does not currently de-allocate memory }
end;                    { THugeMemStream.Truncate }

procedure THugeMemStream.Read(var Buf; Count: Word);
var
  Start,ToAddr: TLongType;
  l: word;
  P: PChar;
begin
  if Status<>stOK then Exit;
  if Current+Count>Size then
  begin
    Error(stReadError,0); FillChar(Buf,Count,0);
  end else
  begin
    P:=@Buf;
    Start.Long:=Base.Lo+Current;
    ToAddr.Hi := Base.Hi + (Start.Hi * Ofs(AHIncr));
    ToAddr.Lo := Start.Lo;
    if ToAddr.Lo>$FFFF-Count then  { Crossing a segment boundary }
    begin
      l:=$FFFF-ToAddr.Lo+1;
      Move(ToAddr.Ptr^,Buf,l);
      ToAddr.Hi:=ToAddr.Hi+Ofs(AHIncr); ToAddr.Lo:=0;
      Move(ToAddr.Ptr^,P[l],Count-l);
    end else Move(ToAddr.Ptr^,Buf,Count);
    Current:=Current+Count;
  end;
end;          { THugeMemStream.Read }

procedure THugeMemStream.write(var Buf; Count: Word);
var
  Start,ToAddr: TLongType;
  l: word;
  P: PChar;
  ll: longint;
  NewHandle: THandle;
begin
  if Status<>stOK then Exit;
  if Current+Count>AllocSize then
  begin
    ll:=Current+Count;
    ll:=K64*((ll-1) div K64)+K64;
{    message('Re-alloc to '+num2str(ll));}
    if Handle=0 then Handle:=GlobalAlloc(GMem_Moveable,ll)
    else begin
      GlobalUnlock(Handle);
      NewHandle:=GlobalReAlloc(Handle,ll,GMEM_Moveable);
      if NewHandle=0 then Error(stWriteError,0)
      else Handle:=NewHandle;
{      message('New size is '+num2str(GlobalSize(Handle)));}
    end;
    Base.Ptr:=GlobalLock(Handle);
    AllocSize:=GlobalSize(Handle);
  end;

  P:=@Buf;
  Start.Long:=Base.Lo+Current;
  ToAddr.Hi := Base.Hi + (Start.Hi * Ofs(AHIncr));
  ToAddr.Lo := Start.Lo;
  if ToAddr.Lo>$FFFF-Count+1 then  { Crossing a segment boundary }
  begin
{    message('write '+num2str(count)+' bytes');}
    l:=$FFFF-ToAddr.Lo+1;
{    message(num2str(l)+' bytes first');}
    Move(Buf,ToAddr.Ptr^,l);
    if Count>l then
    begin
      ToAddr.Hi:=ToAddr.Hi+Ofs(AHIncr); ToAddr.Lo:=0;
{      message(num2str(Count-l)+' bytes second');}
      Move(P[l],ToAddr.Ptr^,Count-l);
    end;
  end else Move(Buf,ToAddr.Ptr^,Count);
  Current:=Current+Count; if Current>Size then Size:=Current;
end;               { THugeMemStream.write }

destructor THugeMemStream.Done;
begin
  if Handle<>0 then
  begin
    GlobalUnlock(Handle);
    if Owner then GlobalFree(Handle);
  end;
  TStream.Done;
end;              { THugeMemStream.Done }


end.
