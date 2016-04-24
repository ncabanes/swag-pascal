(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0001.PAS
  Description: CHECKSUM.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

(*
> I finished Programming a Program in turbo pascal 7, and as some shareware
> Programs like RemoteAccess, Fastecho and more i want my Program to use a
> KEY File to know if the Program is registered or not (i will supply a key
> For every sysop according to his bbs name and his name), any examples to
> do such a Procedure?

You could do like I did in Terminate, make a big KeyFile around 4-8k and
included all kind of checksums calculated on crc-sums and the name etc.

Calculate the Crc-sums in different ways, use always the GlobalChecksum to find
out if there has been no errors in the File. If error in the global checksum:

  SetFAttr(keyFile,Archive)      { if the File has been set to readonly }
  Erase(keyFile,archive)

Ask user to install a new copy of the keyFile.

Then somebody has changed it or an error has occured.

The next things is to use a different checksum For each release you make of
your Program, then people will get annoyed over waiting For a new pirate key
and hopefully will send you some money.
The cracker cannot calculate the checksum if you have no code in the Program,
but he can crack the current version, but if you release a new version often,
people will get tired of that and pay. A checksum can be calculated in many
different ways like below:
*)
Var

  KeyRec : Record
    Crc  : Array[1..100] of LongInt;
    Name : String[80];
    GlobalChecksum;
  end;

Var
  Sum : LongInt;
  X   : Word;

begin
  Sum := 0;
  For x := 1 to Sizeof(KeyRec) Do
    Inc(Sum, Mem[Seg(KeyRec) : Seg(KeyRec) + x]);
  { This will add all ascii values to crc, the cracker will prop. find
    this out, but if you then : }
  Dec(Sum,3248967);
  { How should he find out if there is no code in your Program at the }
  { present version }
end.

