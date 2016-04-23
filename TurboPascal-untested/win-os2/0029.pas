unit BigArray;

{ This unit contains an objects that allows for the creation of
  arrays larger than 64K.                                       }

interface

{ The ifdefs allow compiling under windows or protected mode }

{$ifdef windows}
uses WinTypes, WinProcs, WinAPI;
{$else}
uses WinAPI;
{$endif}

const
  SegSize = 65536;                  { Size of a selector }

{ Our BigArray object will allow us to allocate large chucks of memory
  (>64k) and index our way through the items }
type
  PBigArray = ^TBigArray;
  TBigArray = object
    MemStart : THandle;
    MemOffset : longint;
    MemSize : longint;
    MaxItems : longint;
    ItemSize : longint;
    constructor Init(NoItems : longint; Size : Word);
    destructor Done; virtual;
    procedure PutData(var Item; Index : longint); virtual;
    procedure GetData(var Item; Index : longint); virtual;
    procedure Resize(NoItems : longint); virtual;
    function GetMeMSize : longint; virtual;
  end;

implementation

constructor TBigArray.Init(NoItems : longint; Size : Word);
{ Determine the size of the memory we need, allocate using the
  GlobalAlloc() routine, and initialize the fields }
begin
  MaxItems := NoItems;
  ItemSize := Size;
  { compute memory size }
  MemSize := MaxItems * ItemSize;
  { allocate the memory }
  MemStart := GlobalAlloc(gmem_Moveable, MemSize);
  { any error? }
  if MemStart = 0 then
    RunError(203);

  MemOffset := 0;
end;

destructor TBigArray.Done;
{ Free up the memory }
begin
  GlobalFree(MemStart);
end;

procedure TBigArray.PutData(var Item; Index : longint);
{ Put the item in the allocated memory }
var
  Sel, Off : word;
  P : pointer;
  FinishIt : boolean;
  TempItemSize : word;
begin
  if Index >= MaxItems then
    RunError(201);

  inc(MemOffset, ItemSize);

  { compute index into memory }
  Index := Index * ItemSize;
  { determine the starting selector to access }
  Sel := (Index div SegSize) * SelectorInc + MemStart;
  { determine the offset into that selector }
  Off := Index mod SegSize;

  if (SegSize - Off) < ItemSize then begin
    TempItemSize := SegSize - Off;
    FinishIt := true;
  end
  else begin
    TempItemSize := ItemSize;
    FinishIt := false;
  end;

  { lock the memory - this only applies to windows }
  GlobalLock(Sel);

  { get the pointer value }
  P := ptr(Sel, Off);

  { move the data into memory }
  Move(Item, P^, TempItemSize);

  { unlock the memory - this only applies to windows }
  GlobalUnLock(Sel);

  if FinishIt then begin
    Sel := Sel + SelectorInc;
    Off := 0;
    { lock the memory - this only applies to windows }
    GlobalLock(Sel);

    { get the pointer value }
    P := ptr(Sel, Off);

    { move the data into memory }
    Move(Item, P^, TempItemSize);

    { unlock the memory - this only applies to windows }
    GlobalUnLock(Sel);
  end;
end;

procedure TBigArray.GetData(var Item; Index : longint);
{ Get the item out of memory }
var
  Sel, Off : word;
  P : pointer;
  FinishIt : boolean;
  TempItemSize : word;
begin
  if Index >= MaxItems then
    RunError(201);

  { compute index into memory }
  Index := Index * ItemSize;
  { determine the starting selector to access }
  Sel := (Index div SegSize) * SelectorInc + MemStart;
  { determine the offset into that selector }
  Off := Index mod SegSize;

  if (SegSize - Off) < ItemSize then begin
    TempItemSize := SegSize - Off;
    FinishIt := true;
  end
  else begin
    TempItemSize := ItemSize;
    FinishIt := false;
  end;

  { lock the memory - this only applies to windows }
  GlobalLock(Sel);

  { get the pointer value }
  P := ptr(Sel, Off);

  { move the data from memory to the field }
  Move(P^, Item, TempItemSize);

  { unlock the memory - this only applies to windows }
  GlobalUnLock(Sel);

  if FinishIt then begin
    Sel := Sel + SelectorInc;
    Off := 0;
    { lock the memory - this only applies to windows }
    GlobalLock(Sel);

    { get the pointer value }
    P := ptr(Sel, Off);

    { move the data into memory }
    Move(Item, P^, TempItemSize);

    { unlock the memory - this only applies to windows }
    GlobalUnLock(Sel);
  end;

  dec(MemOffset, ItemSize);
end;

procedure TBigArray.Resize(NoItems : longint);
{ With a call to GlobalReAlloc() we can resize the array with out
  loosing any data.  Here we also reinitialize the fields }
var
  TempMem : THandle;
begin

  MaxItems := NoItems;
  { compute new memory size }
  MemSize := MaxItems * ItemSize;
  { resize the memory allocated }
  TempMem := GlobalReAlloc(MemStart, MemSize, gmem_Moveable);
  { any errors? }
  if TempMem = 0 then
    RunError(203);

  MemStart := TempMem;
end;

function TBigArray.GetMemSize : longint;
{ returns the current number of bytes allocated for the array }
begin
  GetMemSize := MemSize;
end;

end.

{------------------------    DEMO PROGRAM  --------------------- }

program TestBigArray;

{$ifdef Windows}
uses WinDos, WinCrt, WinTypes, WinProcs, BigArray;
{$else}
uses Dos, Crt, WinAPI, BigArray;
{$endif}

const
  elnum = 2000;
type
  TRec = record
    i : integer;
    r : real;
    s : string;
    a : array[0..3000] of char;
  end;

var
  Rec : TRec;
  BArray : PBigArray;
  X : longint;
begin

  clrscr;

  writeln('memory available = ', memavail);

  new(BArray, Init(elnum, SizeOf(TRec)));

  for x := 0 to elnum-1 do begin
    Rec.i := x;
    BArray^.PutData(Rec, x);
  end;

  for x := elnum-1 downto 0 do begin
    BArray^.GetData(Rec, x);
    if x <> Rec.i then
      writeln(Rec.i);
  end;

  writeln('first size of mem for array = ', BArray^.GetMemSize);

{  BArray^.Resize(20000);

  for x := 10000 to 19999 do begin
    Rec.i := x;
    BArray^.PutData(Rec, x);
  end;

  for x := 19999 downto 0 do begin
    BArray^.GetData(Rec, x);
    writeln(Rec.i);
  end;

  writeln('second size of mem for array = ', BArray^.GetMemSize);
}
  dispose(BArray, Done);
  readln;
end.
