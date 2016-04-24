(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0019.PAS
  Description: Window Memory Stream
  Author: ROBERT WARREN
  Date: 02-15-94  07:53
*)

{
        Useful for transferring  objects which have been registered to the clipboard or any global memory situation.
        Also could be used to make a copy of any streamable object. Merely stream the object to memory and then
        re-instantiate a new object through the use of a TStream.Get. Solves the
        problem of passing objects to another program because it removes any method pointer info.

        NOTE: This works only for streams which are not larger than 64K. In order
                                to make this work for larger streams you have to ensure that your
                                writes and puts (and gets and reads...) don't straddle each 64K boundary.
                                I haven't added the pointer math to this unit yet.
}

{ Author Robert Warren CIS ID 70303,537 }

Unit MemStream;

interface

        Uses WinTypes,WinProcs, WObjects;

        type

                PMemStream = ^TMemStream;
                TMemStream = object(TStream)

                                Handle: Word;
                                Address: Pointer;
                                Size: Longint;       { allocated size }
                                Position: Longint;   { current position in stream }
                                AllocFlags: LongInt; { flags required when allocating / reallocating }
                                FreeMemory: Boolean; { Flag indicating whether to free global
                                                                                                                         memory when disposing of object }

                        constructor Init(AllocSize: Longint; Flags: LongInt; FreeMem: Boolean);
                        constructor InitWithHandle(aHandle: THandle; Flags: LongInt; FreeMem: Boolean);
                        destructor Done; virtual;
                        function GetPos: Longint; virtual;
                        procedure Grow(howMuch: LongInt); virtual;
                        function GetSize: Longint; virtual;
                        procedure Read(var Buf; Count: Word); virtual;
                        procedure Write(var Buf; Count: Word); virtual;
                        procedure Seek(Pos: Longint); virtual;
                        procedure Truncate; virtual;
                end;

implementation

{
 creates a memory stream of given size using the flags. The FreeMem argument
 is used to determine whether to delete the global block of memory when the
 object is disposed of. Sometime you don't want to delete the block if for
 example it has been placed in the clipboard or passed using DDE.
}
constructor TMemStream.Init(AllocSize: Longint; Flags: LongInt;FreeMem: Boolean);
begin
 TStream.Init;
 Handle:=GlobalAlloc( Flags, AllocSize);
 Address:=GlobalLock(Handle); { so much for real mode }
 Size:=AllocSize;
 Position:=0;
 FreeMemory:= FreeMem;
end;

{
 same as above but allows for the creation of a object given an already
 allocated memory block. Perhaps some data FROM a clipboard
}
constructor TMemStream.InitWithHandle(aHandle: THandle; Flags: LongInt;FreeMem: Boolean);
begin
 TStream.Init;
 Size:=GlobalSize(Handle);
 Address:=GlobalLock(Handle);
 Position:=0;
 FreeMemory:= FreeMem;
end;


destructor TMemStream.Done;
begin
 TStream.Done;
 GlobalUnlock(Handle);
 If FreeMemory then GlobalFree(Handle);
end;

function TMemStream.GetPos: LongInt;
begin
        GetPos:=Position;
end;

function TMemStream.GetSize: LongInt;
begin
        GetSize:=Size;
end;


procedure TMemStream.Read(var Buf; Count: Word);
var
 varAddress: PChar;
 stAddress: PChar;
 i: LongInt;
begin
 varAddress:=@Buf;
 stAddress:=PChar(MakeLong(Position+LoWord(LongInt(Address)),HiWord(LongInt(Address))));
 for i:=0 to Count -1 do
         varAddress[i]:=stAddress[i];
 inc(Position,Count);
end;

procedure TMemStream.Grow(HowMuch: LongInt);
begin
 GlobalUnlock(Handle);
 Inc(Size,HowMuch);
 GlobalRealloc(Handle, Size, AllocFlags);
 GlobalLock(Handle);
end;

procedure TMemStream.Write(var Buf; Count: Word);
var
 varAddress: PChar;
 stAddress: PChar;
 i: LongInt;
 growSize: Integer;
begin

 if Position + Count >= Size then
         begin
                if count < 1023
                         then growSize:=1024
                         else growSize:=count + 1;

                Grow(growSize);
         end;

 varAddress:=@Buf;
 stAddress:=PChar(MakeLong(Position+LoWord(LongInt(Address)),HiWord(LongInt(Address))));
 for i:=0 to Count -1 do
         stAddress[i]:=varAddress[i];
 inc(Position,Count);
end;

procedure TMemStream.Seek(Pos: Longint);
begin
 Position:=Pos;
end;

procedure TMemStream.Truncate;
begin
        GlobalUnlock(Handle);
        GlobalReAlloc(Handle,Position,AllocFlags);
        Address:=GlobalLock(Handle);
        Size:=Position;
end;

end.


