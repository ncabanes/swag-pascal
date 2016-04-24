(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0040.PAS
  Description: Disk Serial Numbers
  Author: PETER KLAPPROTH
  Date: 08-27-93  21:57
*)

{
PETER KLAPPROTH

> If anyone happens to know how to find the serial number
> of a diskette, please let me know, code is nice :)
> It is stored in byte 42, 41, 40, and 39 (counting the first one as
> 0) of ths first sector of the disk.  The code I have for it uses the
> TPro package to read the sector.

annother way to read/write the diskId is the following small peace of code.
}

type
  TInfoBuffer = record
    InfoLevel : word; {may be 0}
    Serial    : longInt;
    VolLabel  : array [0..10] of char;
    FileSystem: array [0..7] of char;
  end;

function GetSerial(DiskNum : Byte; var I : TInfoBuffer) : word; assembler;
asm
  mov  ah, 69h
  mov  al, 00h
  mov  bl, DiskNum
  push ds
  lds  dx, I
  int  21h
  pop  ds
  jc   @bad
  Xor  ax, ax
 @bad:
end;

function SetSerial(DiskNum : Byte; var I : TInfoBuffer) : word; assembler;
asm
  mov  ah, 69h
  mov  al, 01h
  mov  bl, DiskNum
  push ds
  lds  dx, I
  int  21h
  pop  ds
  jc   @bad
  xor  ax, ax
 @bad:
end;


