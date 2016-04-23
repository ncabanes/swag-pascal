{
Sean Palmer

> I did not mean to imply that I expected a library that could provide
> access to XMS With simple Pointer dereferences.  I understand the
> difficulty of accessing >1MB from a Real-mode Program.  I would be
> happy(ECSTATIC in fact) if I could find a library that would allow an
> allocation to XMS, returning a handle to the block, and allow
> access(copying) of the block via a Procedure call.  Of course, the
> catch is that the library would have to be able to deal With random
> allocations and deallocations-like a heap manager For XMS.  I know that
> there are VMM's out there that can do this-I just can't get my hands
> on one!

Try this:

turbo pascal 6.0 source
}

Unit xms;  {this Unit won't handle blocks bigger than 64k}

Interface

Function  installed : Boolean;
Function  init(Var h : Word; z : Word) : Boolean;   {alloc xms}
Procedure avail(Var total, largest : Word);  {how much free?}
Function  save(h, z : Word; Var s) : Boolean; {move main to xms}
Function  load(h, z : Word; Var s) : Boolean; {move xms to main}
Procedure free(h : Word);                     {dispose xms}
Function  lock(h : Word) : LongInt;
Function  unlock(h : Word) : Boolean;
Function  getInfo(h : Word; Var lockCount, handlesLeft : Byte;
                  Var sizeK : Word) : Boolean;
Function  resize(h, sizeK : Word) : Boolean;

Implementation

{Error codes, returned in BL reg}

Const
  FuncNotImplemented   = $80;          {Function is not implemented}
  VDiskDeviceDetected  = $81;          {a VDISK compatible device found}
  A20Error             = $82;          {an A20 error occurred}
  GeneralDriverError   = $8E;          {general driver error}
  UnrecoverableError   = $8F;          {unrecoverable driver error}
  HmaDoesNotExist      = $90;          {high memory area does not exist}
  HmaAlreadyInUse      = $91;          {high memory area already in use}
  HmaSizeTooSmall      = $92;          {size requested less than /HMAMIN}
  HmaNotAllocated      = $93;          {high memory area not allocated}
  A20StillEnabled      = $94;          {A20 line is still enabled}
  AllExtMemAllocated   = $A0;          {all extended memory is allocated}
  OutOfExtMemHandles   = $A1;          {extended memory handles exhausted}
  InvalidHandle        = $A2;          {invalid handle}
  InvalidSourceHandle  = $A3;          {invalid source handle}
  InvalidSourceOffset  = $A4;          {invalid source offset}
  InvalidDestHandle    = $A5;          {invalid destination handle}
  InvalidDestOffset    = $A6;          {invalid destination offset}
  InvalidLength        = $A7;          {invalid length}
  OverlapInMoveReq     = $A8;          {overlap in move request}
  ParityErrorDetected  = $A9;          {parity error detected}
  BlockIsNotLocked     = $AA;          {block is not locked}
  BlockIsLocked        = $AB;          {block is locked}
  LockCountOverflowed  = $AC;          {lock count overflowed}
  LockFailed           = $AD;          {lock failed}
  SmallerUMBAvailable  = $B0;          {a smaller upper memory block is avail}
  NoUMBAvailable       = $B1;          {no upper memory blocks are available}
  InvalidUMBSegment    = $B2;          {invalid upper memory block segment}

  xmsProc : Pointer = nil; {entry point For xms driver, nil if none}

Var
  copyRec : Record
    size : LongInt;    {Bytes to move (must be even)}
    srcH : Word;       {handle (0=conventional mem)}
    srcP : Pointer;
    dstH : Word;
    dstP : Pointer;
  end;


Function installed : Boolean;
begin
  installed := (xmsProc <> nil);
end;

Function init(Var h : Word; z : Word) : Boolean; Assembler;
Asm
  mov  dx, z
  test dx, $3FF
  jz   @S
  add  dx, $400
 @S: {allow For partial K's}
  mov  cl, 10
  shr  dx, cl  {convert to K}
  mov  ah, 9
  call xmsProc {allocate XMS block}
  cmp  ax, 1
  je   @S2
  xor  al, al
 @S2:
  les  di, h
  mov  es:[di], dx
end;

Procedure avail(Var total, largest : Word); Assembler;
Asm
  mov  ah, 8
  call xmsProc  {query free xms}
  les  di, total
  mov  es:[di], dx
  les  di, largest
  mov  es:[di], ax
end;

Function copy : Boolean; Assembler;
Asm  {internal}
  push ds
  mov  si, offset copyRec {it's in DS, right?}
  mov  ah, $B
  call xmsProc  {copy memory}
  cmp  ax,1
  je   @S
  xor  al,al
 @S:
  pop  ds
end;

Function save(h, z : Word; Var s) : Boolean;
begin
  if odd(z) then
    inc(z);
  With copyRec do
  begin
    size := z;
    srcH := 0;
    srcP := @s; {source, from main memory}
    dstH := h;
    dstP := ptr(0,0); {dest, to xms block}
  end;
  save := copy;
end;

Function load(h, z : Word; Var s) : Boolean;
begin
  if odd(z) then
    inc(z);
  With copyRec do
  begin
    size := z;
    srcH := h;
    srcP := ptr(0,0); {source, from xms block}
    dstH := 0;
    dstP := @s; {dest, to main memory}
  end;
  load := copy;
end;

Procedure free(h : Word); Assembler;
Asm
  mov  dx, h
  mov  ah, $A
  call xmsProc
end;

Function lock(h : Word) : LongInt; Assembler;
Asm
  mov  ah, $C
  mov  dx, h
  call xmsProc {lock xms block}
  cmp  ax, 1
  je   @OK
  xor  bx, bx
  xor  dx, dx
 @OK:  {set block to nil (0) if err}
  mov  ax, bx
end;

Function unlock(h : Word) : Boolean; Assembler;
Asm
  mov  ah, $D
  mov  dx, h
  call xmsProc {unlock xms block}
  cmp  ax, 1
  je   @S
  xor  al, al
 @S:
end;

Function getInfo(h : Word; Var lockCount, handlesLeft : Byte;
                 Var sizeK : Word) : Boolean; Assembler;
Asm
  mov  ah, $E
  mov  dx, h
  call xmsProc  {get xms handle info}
  cmp  ax, 1
  je   @S
  xor  al, al
 @S:
  les  di, lockCount
  mov  es:[di], bh
  les  di, handlesLeft
  mov  es:[di], bl
  les  di, sizeK
  mov  es:[di], dx
end;

Function resize(h, sizeK : Word) : Boolean; Assembler;
Asm
  mov  ah, $F
  mov  dx, h
  mov  bx, sizeK
  call xmsProc {resize XMS block}
  cmp  ax ,1
  je   @S
  xor  al, al
 @S:
end;

begin
  Asm {there is a possibility these ints will trash the ds register}
    mov ax, $4300 {load check Function For xms driver}
    int $2F  {call multiplex int}
    cmp al, $80
    jne @X
    mov ax, $4310
    int $2F {get adr of entry point->es:bx}
    mov Word ptr xmsProc, bx
    mov Word ptr xmsProc+2, es
   @X:
  end;
end.

