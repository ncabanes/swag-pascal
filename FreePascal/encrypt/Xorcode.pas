(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0014.PAS
  Description: XORCODE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{
 Is if possible For you to post a sample code on how to use xor to
 encrypt a File???   I'm shifting ORD value around to do excryptions
 and I think your method is better..  So I would like to learn it..

Sure, here's a simple example that reads a user-entered line and
encrypts it using the xor method.  By XOR-ing it again the line is
decrypted.  This won't keep NSA fooled For more than a few seconds, but
so long as you keep the passWord hidden it should suffice.
}


Program Sample;

Uses
  Crt;

Const
  PassWord : Array[1..8] of Char = 'Sha Zamm';

Var
  PassBits : Array[1..8] of Byte Absolute PassWord;
  ALine    : String[80];
  LineBits : Array[0..80] of Byte Absolute ALine;
  I, J(*, K*)  : Integer;
begin
  WriteLn('Enter a line of Text to encrypt:');
  ReadLn(ALine);
  J := 0;
  For I := 1 to Length(ALine) Do
  begin
    Inc(J);
    If J > 8 Then
      J := 1;
    LineBits[I] := LineBits[I] xor PassBits[J];
  end;
  WriteLn('Encrypted:  ',ALine);
  J := 0;
  For I := 1 to Length(ALine) Do
  begin
    Inc(J);
    If J > 8 Then
      J := 1;
    LineBits[I] := LineBits[I] xor PassBits[J];
  end;
  WriteLn('Decrypted:  ',ALine);
end.
