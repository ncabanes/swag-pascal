(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0004.PAS
  Description: ENCRYPT1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

program Encrypt1;

Function EncryptDecrypt(S : String ; K : String) : String;
Var
  I,Q : Integer;
  O   : String[255];
begin
  Q := 1;
  O := '';
  For I := 1 to Length(S) Do
    begin
      O := O + Chr(Ord(S[I]) Xor Ord(K[Q]));
      Inc(Q); If Q > Length(K) Then Q := 1;
    end;
  EncryptDecrypt := O;
end;
{
A couple of thoughts on this.

1. If K is short then the decryption is very easy.
2. The routine would be VERY slow as it is using String concatenation.  It
   would be MUCH faster if the O := "" line was changed to O[0] := S[0] and
   the O := O + ... line was replaced With -
   O[I] := ...

TeeCee

}

begin
    WriteLn( EncryptDecrypt ('Hola, que tal estas?', 'ejemplo') );
    
    WriteLn( EncryptDecrypt ( 
        EncryptDecrypt ('Hola, que tal estas?', 'ejemplo'), 
        'ejemplo' ) 
    );
end.
