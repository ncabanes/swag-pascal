(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0019.PAS
  Description: Encryption Routine
  Author: ERIC MILLER
  Date: 08-24-94  13:34
*)

{
 JM> FUNCTION ConvertTxt (S : String) : String;
 JM> Var X : Byte;
 JM> Begin
 JM>   ConvertTxt[0] := S[0];
 JM>   For X := 1 to Length(S) do
 JM>     ConvertTxt[X] := Chr(Ord(S[X]) XOR (Random(128) or 128));
 JM> End;
 JM> To encrypt a string, you just call ConvertTxt(string). Call
 JM> the function again, with the same parameters to decrypt.
 JM> Anyone have anything better, or have any suggestions?

  Here is basically the same function again.  However note the
  RandSeed assignment - RandSeed is set to the length of the
  string before a string is processed.  Since the length of
  the string never changes, you can randomly pick any string
  and be able to decrypt it.  RandSeed is used to make Random
  return a specific sequence of psuedo-random numbers, and
  this encryption method relies on the same sequence in order
  for it to decrypt.
 }

  PROCEDURE EnDecrypt(VAR S: String);
  VAR
    X: Byte;
  BEGIN
    RandSeed := Length(S);
    FOR X := 1 TO Length(S) DO
      S[X] := Chr(Ord(S[X]) XOR (Random(128) OR 128));
  END;

  VAR
    S: String;
  BEGIN
    Write('Enter a string: ');
    Readln(S);
    EnDecrypt(S);
    WriteLn;
    WriteLn;
    Writeln('The encrypted string is ', S);
    EnDecrypt(S);
    WriteLn;
    WriteLn;
    Writeln('The decrypted string is ', S);
  END.


