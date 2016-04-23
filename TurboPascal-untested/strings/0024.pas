{ Converts a byte into hexadecimal string, and a word into hexadecimal string.
  Part of the Heartware Toolkit v2.00 (HTstring.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Byte_To_Hex(X : byte) : String2;
{ DESCRIPTION:
    Converts a byte into hexadecimal string.
  SAMPLE CALL:
    S := Byte_To_Hex(255);
  RETURNS:
    The hexadecimal representation of the specified value in a 2-bytes type
      string }
var
  Digits : array [0..15] of char = '0123456789ABCDEF';

BEGIN { Byte_To_Hex }
  Byte_To_Hex := Concat(Digits[X shr 4],Digits[X and 15]);
END; { Byte_To_Hex }



FUNCTION Word_To_Hex(X : word) : String4;
{ DESCRIPTION:
    Converts a word into hexadecimal string.
  SAMPLE CALL:
    S := Word_To_Hex(65535);
  RETURNS:
    The hexadecimal representation of the specified value in a 4-bytes type
      string }

BEGIN { Word_To_Hex }
  Word_To_Hex := Concat(Byte_To_Hex(X shr 8),Byte_To_Hex(X and $FF));
END; { Word_To_Hex }
