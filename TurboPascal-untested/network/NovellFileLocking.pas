(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0008.PAS
  Description: Novell File Locking
  Author: JEFF SHANNON
  Date: 08-27-93  21:42
*)

{
JEFF SHANNON

Novell/File Locking/Sharing

> Does anyone have any samples of network File sharing/access code For Turbo
> Pascal/Borland Pascal 6-7.

This is from the Advanced Turbo Pascal Techniques book by Chris Ohlsen and
Gary Stroker.  It's For TP 5.5 but I'm sure you could make use of it.

Oops, I hope I didn't violate any copyright laws by posting this code.  I
doubt the authors of the book would sue me as it is a FINE book and I
recommend it to all.  Now the publishers are a different story...
}

Unit FileLock;

Interface

Uses
  Dos;

Function Lock(Var UnTyped; pos, size : LongInt) : Boolean;
Function UnLock(Var UnTyped; pos, size : LongInt) : Boolean;

Implementation

Function Lock(Var UnTyped; pos, size : LongInt) : Boolean;
Var
  reg : Registers;
  f   : File Absolute UnTyped;

begin
  pos  := pos * FileRec(f).RecSize;
  size := size * FileRec(f).RecSize;
  reg.AH := $5C;
  reg.AL := $00;
  reg.BX := FileRec(f).Handle;
  reg.CX := Hi(pos);
  reg.DX := Lo(pos);
  reg.SI := Hi(size);
  reg.DI := lo(size);
  Intr($21, reg);
  if ((reg.Flags and FCarry) <> 0) then
    Lock := False
  else
    Lock := True;
end;

Function UnLock(Var UnTyped; pos, size : LongInt) : Boolean;
Var
  reg : Registers;
  f   : File Absolute UnTyped;
begin
  pos  := pos * FileRec(f).RecSize;
  size := size * FileRec(f).RecSize;
  reg.AH := $5C;
  reg.AL := $01;
  reg.BX := FileRec (f).Handle;
  reg.CX := Hi(pos);
  reg.DX := Lo(pos);
  reg.SI := Hi(size);
  reg.DI := Lo(size);
  Intr($21, reg);
  if ((reg.Flags and FCarry) <> 0) then
    Unlock := False
  else
    Unlock := True;
end;

end.

