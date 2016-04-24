(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0005.PAS
  Description: ENCRYPT2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{The following very simple routine will encrypt and decrypt a Text File a line
at a time.  The CR/LF is left unencrypted and the algorithm ensures that no
encrypted Character can be < asciiz 127 *provided that* the Text For encrypting
has no hi-bit Characters.

Obviously this is just a skeleten example (untested) With no error checking but
it should demonstrate what you need to do. After encrypting Text just reverse
the parameters and run the Program again to decrypt the encrypted Text.
}
Program encrypt_Text;

Var
  inText,
  outText  : Text;
  st       : String;

Function ConvertTxt(s: String): String;
  Var x : Byte;
  begin
    ConvertTxt[0] := s[0];
    For x := 1 to length(s) do
      ConvertTxt[x] := chr(ord(s[x]) xor (Random(128) or 128));
  end;  { ConvertTxt }

begin
  RandSeed  := 1234567;{ set to whatever value you wish - this is your "key" }
  assign(inText,ParamStr(1));
  reset(inText);
  assign(outText,ParamStr(2));
  reWrite(outText);
  While not eof(inText) do begin
    readln(inText,st);
    Writeln(outText,ConvertTxt(st));
  end;
  close(inText);
  close(outText);
end.

