(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0120.PAS
  Description: VGA Palette Code
  Author: RODNEY JOHNSON
  Date: 08-24-94  13:49
*)


{ Here is the VGA palette changing code. }

Unit PalChg;
Interface
USES DOS;
Type
  TPalette16 = array[0..15] of array[0..2] of Byte;
  TPalette256 = array[0..255] of array[0..2] of Byte;
procedure SetVGAPalette16(PalBuf : TPalette16);
procedure SetVGAPalette256(PalBuf : TPalette256);
Implementation
procedure SetVGAPalette16(PalBuf : TPalette16);
var
  Reg:Registers;
begin
  reg.ax:=$1012;       {Code for chg. palette}
  reg.bx:=0;           {start with color 0}
  reg.cx:=16;          {change 16 colors}
  reg.es:=Seg(PalBuf); {address: segment}
  reg.dx:=Ofs(PalBuf); {address: offset}
  intr($10, reg);      {interrupt call}
end;
procedure SetVGAPalette256(PalBuf : TPalette256);
var
  Reg:                                  Registers;
begin
  reg.ax:=$1012;       {code for chg. palette}
  reg.bx:=0;           {start with color 0}
  reg.cx:=256;         {change 256 colors}
  reg.es:=Seg(PalBuf); {address: segment}
  reg.dx:=Ofs(PalBuf); {address: offset}
  intr($10, reg);      {interrupt call}
end;
End.

