(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0031.PAS
  Description: A small encryption unit
  Author: LUDOVIC RUSSO
  Date: 03-04-97  13:18
*)


{
Ludovic RUSSO offers you :
One recursive encrypt-decrypt program. Only the first char doesn't
change.
Because of the recursivity, the same char is *never* crpyted the same
way
(take a look at the points in the sentence)
}
 
PROGRAM RecursiveCrypt;
 
TYPE  str80=string[80];
 
PROCEDURE Crypt(var mess:str80;lg:integer);
BEGIN
  If lg>1 Then
  Begin
    crypt(mess,lg-1);
    mess[lg]:=chr((ord(mess[lg-1])+ord(mess[lg])) mod 256);
  End;
END;
 
PROCEDURE DeCrypt(var mess:str80;lg:integer);
BEGIN
  If lg>=2 Then
  Begin
    mess[lg]:=chr((ord(mess[lg])-ord(mess[lg-1])+256) mod 256);
    decrypt(mess,lg-1);
  End;
END;
 
VAR w:str80;
BEGIN
  w:='You can join me at lrusso@ice.unice.fr';
  crypt(w,length(w));writeln('Crypted word   : ',w);
  decrypt(w,length(w));writeln('Uncrypted word : ',w);
END.

