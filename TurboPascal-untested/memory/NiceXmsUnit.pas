(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0031.PAS
  Description: Nice XMS unit
  Author: PETER BEFFTINK
  Date: 11-02-93  06:05
*)

{
PETER BEEFTINK

See below an XMS Unit I picked up somewhere.  I must admit that I have never
been successful at using it, but maybe you have more luck.
}

Unit MegaXMS;

Interface

Var
  Present  : Boolean; {True if XMM driver is installed}
  XMSError : Byte;    {Error number. if 0 -> no error}

Function  XMMPresent : Boolean;
Function  XMSErrorString(Error : Byte) : String;
Function  XMSMemAvail : Word;
Function  XMSMaxAvail : Word;
Function  GetXMMVersion : Word;
Function  GetXMSVersion : Word;
Procedure MoveFromEMB(Handle : Word; Var Dest; BlockLength : LongInt);
Procedure MoveToEMB(Var Source; Handle : Word; BlockLength : LongInt);
Function  EMBGetMem(Size : Word) : Word;
Procedure EMBFreeMem(Handle : Word);
Procedure EMBResize(Handle, Size : Word);
Function  GetAvailEMBHandles : Byte;
Function  GetEMBLock(Handle : Word) : Byte;
Function  GetEMBSize(Handle : Word) : Word;
Function  LockEMB(Handle : Word) : LongInt;
Procedure UnlockEMB(Handle : Word);
Function  UMBGetMem(Size : Word; Var Segment : Word) : Word;
Procedure UMBFreeMem(Segment : Word);
Function  GetA20Status : Boolean;
Procedure DisableLocalA20;
Procedure EnableLocalA20;
Procedure DisableGlobalA20;
Procedure EnableGlobalA20;
Procedure HMAGetMem(Size : Word);
Procedure HMAFreeMem;
Function  GetHMA : Boolean;

Implementation

Uses
  Dos;

Const
  High = 1;
  Low  = 2;
  NumberOfErrors = 27;

  ErrorNumber : Array [1..NumberOfErrors] Of Byte =
    ($80,$81,$82,$8E,$8F,$90,$91,$92,$93,$94,$A0,$A1,$A2,$A3,
     $A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$B0,$B1,$B2);

  ErrorString : Array [0..NumberOfErrors] Of String = (
    'Unknown error',
    'Function no implemented',
    'VDISK device driver was detected',
    'A20 error occured',
    'General driver errror',
    'Unrecoverable driver error',
    'High memory area does not exist',
    'High memory area is already in use',
    'DX is less than the ninimum of KB that Program may use',
    'High memory area not allocated',
    'A20 line still enabled',
    'All extended memory is allocated',
    'Extended memory handles exhausted',
    'Invalid handle',
    'Invalid source handle',
    'Invalid source offset',
    'Invalid destination handle',
    'Invalid destination offset',
    'Invalid length',
    'Invalid overlap in move request',
    'Parity error detected',
    'Block is not locked',
    'Block is locked',
    'Lock count overflowed',
    'Lock failed',
    'Smaller UMB is available',
    'No UMBs are available',
    'Inavlid UMB segment number');

Type
  XMSParamBlock= Record
    Length  : LongInt;
    SHandle : Word;
    SOffset : Array [High..Low] Of Word;
    DHandle : Word;
    DOffset : Array [High..Low] Of Word;
  end;

Var
  XMSAddr : Array [High..Low] Of Word; {XMM driver address 1=Low,2=High}

Function XMMPresent: Boolean;
Var
  Regs : Registers;
begin
  Regs.AX := $4300;
  Intr($2F, Regs);
  XMMPresent := Regs.AL = $80;
end;

Function XMSErrorString(Error : Byte) : String;
Var
  I, Index : Byte;
begin
  Index := 0;
  For I := 1 To NumberOfErrors Do
    if ErrorNumber[I] = Error Then
      Index := I;
  XMSErrorString := ErrorString[Index];
end;

Function XMSMemAvail : Word;
Var
  Memory : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 8
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Memory, DX
   @@2:
  end;
  XMSMemAvail := Memory;
end;

Function XMSMaxAvail : Word;
Var
  Temp : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 8
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp, AX
   @@2:
  end;
  XMSMaxAvail := Temp;
end;

Function EMBGetMem(Size : Word) : Word;
Var
  Temp : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 9
    Mov  DX, Size
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp, DX
   @@2:
  end;
  EMBGetMem := Temp;
end;

Procedure EMBFreeMem(Handle : Word);
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Ah
    Mov  DX, Handle
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure EMBResize(Handle, Size : Word);
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Fh
    Mov  DX, Handle
    Mov  BX, Size
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure MoveToEMB(Var Source; Handle : Word; BlockLength : LongInt);
Var
  ParamBlock : XMSParamBlock;
  XSeg, PSeg,
  POfs       : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  With ParamBlock Do
  begin
    Length        := BlockLength;
    SHandle       := 0;
    SOffset[High] := Ofs(Source);
    SOffset[Low]  := Seg(Source);
    DHandle       := Handle;
    DOffset[High] := 0;
    DOffset[Low]  := 0;
  end;
  PSeg := Seg(ParamBlock);
  POfs := Ofs(ParamBlock);
  XSeg := Seg(XMSAddr);

  Asm
    Push DS
    Mov  AH, 0Bh
    Mov  SI, POfs
    Mov  BX, XSeg
    Mov  ES, BX
    Mov  BX, PSeg
    Mov  DS, BX
    Call [ES:XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
    Pop  DS
  end;
end;

Procedure MoveFromEMB(Handle : Word; Var Dest; BlockLength : LongInt);
Var
  ParamBlock : XMSParamBlock;
  XSeg, PSeg,
  POfs       : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  With ParamBlock Do
  begin
    Length        := BlockLength;
    SHandle       := Handle;
    SOffset[High] := 0;
    SOffset[Low]  := 0;
    DHandle       := 0;
    DOffset[High] := Ofs(Dest);
    DOffset[Low]  := Seg(Dest);
  end;
  PSeg := Seg(ParamBlock);
  POfs := Ofs(ParamBlock);
  XSeg := Seg(XMSAddr);

  Asm
    Push DS
    Mov  AH, 0Bh
    Mov  SI, POfs
    Mov  BX, XSeg;
    Mov  ES, BX
    Mov  BX, PSeg
    Mov  DS, BX
    Call [ES:XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
    Pop  DS
  end;
end;

Function GetXMSVersion : Word;
Var
  HighB, LowB : Byte;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  HighB, AH
    Mov  LowB, AL
   @@2:
  end;
  GetXMSVersion := (HighB * 100) + LowB;
end;

Function GetXMMVersion : Word;
Var
  HighB, LowB : Byte;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  HighB, BH
    Mov  LowB, BL
   @@2:
  end;
  GetXMMVersion := (HighB * 100) + LowB;
end;

Function GetHMA : Boolean;
Var
  Temp : Boolean;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Temp := False;
  Asm
    Mov  AH, 0
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Cmp  DX, 0
    Je   @@2
    Mov  Temp, 1
   @@2:
  end;
  GetHMA := Temp;
end;

Procedure HMAGetMem(Size : Word);
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 1
    Mov  DX, Size
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure HMAFreeMem;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 2
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure EnableGlobalA20;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 3
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;


Procedure DisableGlobalA20;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 4
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure EnableLocalA20;
begin
  XMSError := 0;
  if Not(Present) Then Exit;
  Asm
    Mov  AH, 5
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Procedure DisableLocalA20;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 6
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Function GetA20Status : Boolean;
Var
  Temp : Boolean;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Temp := True;
  Asm
    Mov  AH, 6
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Or   AX, AX
    Jne  @@1
    Or   BL, BL
    Jne  @@2
    Mov  Temp, 0
    Jmp  @@1
   @@2:
    Mov  XMSError, BL
   @@1:
  end;
end;

Function LockEMB(Handle : Word) : LongInt;
Var
  Temp1,
  Temp2 : Word;
  Temp  : LongInt;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Ch
    Mov  DX, Handle
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp1, DX
    Mov  Temp2, BX
   @@2:
  end;
  Temp := Temp1;
  LockEMB := (Temp Shl 4) + Temp2;
end;

Procedure UnlockEMB(Handle : Word);
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Dh
    Mov  DX, Handle
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Function GetEMBSize(Handle : Word) : Word;
Var
  Temp : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Eh
    Mov  DX, Handle
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp, DX
   @@2:
  end;
  GetEMBSize := Temp;
end;

Function GetEMBLock(Handle : Word) : Byte;
Var
  Temp : Byte;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Eh
    Mov  DX, Handle
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp, BH
   @@2:
  end;
  GetEMBLock := Temp;
end;

Function GetAvailEMBHandles : Byte;
Var
  Temp : Byte;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 0Eh
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp, BL
   @@2:
  end;
  GetAvailEMBHandles := Temp;
end;

Function UMBGetMem(Size : Word; Var Segment : Word) : Word; {Actual size}
Var
  Temp1, Temp2 : Word;
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 10h
    Mov  DX, Size
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
    Jmp  @@2
   @@1:
    Mov  Temp2, BX
   @@2:
    Mov  Temp1, DX
  end;
  Segment := Temp2;
  UMBGetMem := Temp1;
end;

Procedure UMBFreeMem(Segment : Word);
begin
  XMSError := 0;
  if Not(Present) Then
    Exit;
  Asm
    Mov  AH, 10h
    Mov  DX, Segment
    Call [XMSAddr]
    Or   AX, AX
    Jne  @@1
    Mov  XMSError, BL
   @@1:
  end;
end;

Var
  Regs : Registers;
begin
  if Not(XMMPresent) Then
  begin
    WriteLn('XMS not supported!');
    Present := False;
    Exit;
  end;
  Present := True;
  With Regs Do
  begin
    AX := $4310;
    Intr($2F, Regs);
    XMSAddr[High] := BX;
    XMSAddr[Low]  := ES;
  end;
end.

