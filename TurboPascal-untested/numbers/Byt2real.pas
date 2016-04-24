(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0007.PAS
  Description: BYT2REAL.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

Type
  bsingle = Array [0..3] of Byte;

{ converts Microsoft 4 Bytes single to TP Real }

Function msb_to_Real (b : bsingle) : Real;
Var
  pReal : Real;
  r     : Array [0..5] of Byte Absolute pReal;
begin
  r [0] := b [3];
  r [1] := 0;
  r [2] := 0;
  move (b [0], r [3], 3);
  msb_to_Real := pReal;
end; { Function msb_to_Real }

{
Another Turbo Pascal routine to convert Microsoft single to TP LongInt

index := ((mssingle and not $ff000000) or $00800000) shr (24 -
((mssingle shr 24) and $7f)) - 1;
}

