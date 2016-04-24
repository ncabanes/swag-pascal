(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0038.PAS
  Description: Unpdated Encryption unit
  Author: SWAG TEAM SUPPORT
  Date: 08-30-97  10:21
*)

unit Crypt;

interface

function EnDecrypt(S: String): String;
function hextostr(s: string): string;
function strtohex(s: string): string;

implementation

Const
  Digit: Array[0..$F] of Char = '0123456789ABCDEF';

function EnDecrypt(S: String): String;
VAR
  i: integer;
  t: string;
BEGIN
  t:=s;
  RandSeed := Length(t);
  FOR i := 1 TO Length(t) DO
    t[i] := Chr(Ord(t[i]) XOR Random(256));
  Result:=t
END;

Function HexB(B:Byte): String;
 { Converts BYTE value to string }
Begin
  HexB:=Digit[B shr 4]+Digit[B and $F]
End;

function hex_val(hex: string) : INTEGER;
VAR
  hex_out: INTEGER;
  hex_temp: INTEGER;
  hex_mas: string;
BEGIN
  hex_mas := '0123456789ABCDEF';
  hex_out := 0;
  WHILE length(hex) > 0 DO begin
    hex_temp := Pos(hex[1],hex_mas);
    hex_out := hex_out * 16 + (hex_temp)-1;
    hex := copy(hex,2,255);
  END;
  hex_val := hex_out;
END;

function strtohex(s:string): string;
var
  i: integer;
  t: string;
begin
  t:='';
  for i:=1 to length(s) do
    t:=t+hexb(byte(s[i]));
  strtohex:=t
end;

function hextostr(s: string): string;
var
  i: integer;
  t,u: string;
begin
  t:=''; i:=0;
  while i<length(s) do
    begin
      u:=s[i+1]+s[i+2];
      t:=t+chr(hex_val(u));
      inc(i,2);
    end;
  hextostr:=t
end;

end.

