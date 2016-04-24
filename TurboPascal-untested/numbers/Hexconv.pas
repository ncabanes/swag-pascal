(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0013.PAS
  Description: HEXCONV.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

Var
  n    : Word;
  long : LongInt;

Function Byte2Hex(numb : Byte): String;       { Converts Byte to hex String }
  Const
    HexChars : Array[0..15] of Char = '0123456789ABCDEF';
  begin
    Byte2Hex[0] := #2;
    Byte2Hex[1] := HexChars[numb shr  4];
    Byte2Hex[2] := HexChars[numb and 15];
  end; { Byte2Hex }

Function Numb2Hex(numb: Word): String;        { Converts Word to hex String.}
  begin
    Numb2Hex := Byte2Hex(hi(numb))+Byte2Hex(lo(numb));
  end; { Numb2Hex }

Function Long2Hex(L: LongInt): String;     { Converts LongInt to hex String }
  begin
    Long2Hex := Numb2Hex(L shr 16) + Numb2Hex(L);
  end; { Long2Hex }


begin
  long := 65536;
  n    := 256;
  Writeln(Long2Hex(long));
  Writeln(Numb2Hex(n));
end.

