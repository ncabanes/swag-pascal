(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0001.PAS
  Description: 16BITCRC Routines
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
>I'm looking For code to calculate the CRC32 of a series of Characters.

  ...Unless you're CRCing a very large amount of data, this CRC-16
  routine should do.

  NOTE: This routine requires either TP6 or TP7 to compile.
}

{ Return a 16-bit CRC number For binary data. }

Function Crc16(Var Data; wo_Size : Word) : Word; Assembler;
Asm
  push   ds
  xor    dx, dx
  lds    si, Data
  mov    bx, wo_Size
@L1:
  xor    ah, ah
  lodsb
  mov    cx, 8
  shl    ax, cl
  xor    dx, ax
  mov    cx, 8
@L2:
  shl    dx, 1
  jnc    @L3
  xor    dx, $1021
@L3:
  loop   @L2
  dec    bx
  jnz    @L1
  pop    ds
  mov    ax, dx
end; { Crc16. }
