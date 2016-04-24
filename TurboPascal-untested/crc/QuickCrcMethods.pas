(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0011.PAS
  Description: Quick CRC Methods
  Author: SEAN PALMER
  Date: 08-27-93  21:48
*)

{
SEAN PALMER

Here are some that make their tables on the fly (to save echo space)

I believe crc should be inited to 0 at start

This CRC-16 is not identical to the one used by the Xmodem and Zmodem
File transfer protocols. The polynomial is the same
(X^16+X^12+X^5+X^0 or 0x8408) but the bit-ordering is the opposite,
and preconditioning and postconditioning is used as in 32-bit CRCs.
This method is also used by the European version of X.25.
}

Var
  crc16table : Array [Byte] of Word;

Procedure makeCRC16table;
Var
  crc : Word;
  i,n : Byte;
begin
  For i := 0 to 255 do
  begin
    crc := i;
    For n := 1 to 8 do
      if odd(crc) then
        crc := (crc shr 1) xor $8408
      else
        crc := crc shr 1;

    crc16table[i] := crc;
  end;
end;

Function updateCRC16(c : Byte; crc : Word) : Word;
begin
  updateCRC16 := crc16table[lo(crc) xor c] xor hi(crc);
end;

{this is the same crc used For zModem crc32}

Var
  crc32table : Array [Byte] of LongInt;

Procedure makeCRC32table;
Var
  crc : LongInt;
  i,n : Byte;
begin
  For i := 0 to 255 do
  begin
    crc := i;
    For n := 1 to 8 do
      if odd(crc) then
        crc := (crc shr 1) xor $EDB88320
      else
        crc := crc shr 1;

    crc32table[i] := crc;
  end;
end;

Function updateCRC32(c : Byte; crc : LongInt) : LongInt;
begin
  updateCRC32 := crc32table[lo(crc) xor c] xor (crc shr 8);
end;

